"""Read original ATT51 Access and sidecar XML data without Word.

Source references: v5_attest_DB.read_db_path; v52_exp_fgis_ra.fill_fgis_ra_data,
doc_to_xml2 and get_xml_data; v5_res_main.read_fgis_ra_data.
This is a read-only inspection adapter, not the full exporter.
"""
from __future__ import annotations

import configparser
from dataclasses import asdict, dataclass
from datetime import date, datetime
import ntpath
from pathlib import Path, PureWindowsPath
import os
import re
import shutil
import sys
import tempfile
from typing import Any
from xml.etree import ElementTree as ET


class FsaSourceError(RuntimeError):
    pass


def read_ini(path: Path, section: str, key: str) -> str:
    """Read values as Windows INI files; tolerate the legacy CP1251 codepage."""
    raw = Path(path).read_bytes()
    for encoding in ("utf-8-sig", "cp1251"):
        try:
            decoded = raw.decode(encoding)
            break
        except UnicodeDecodeError:
            continue
    parser = configparser.ConfigParser(interpolation=None, strict=False,
                                       allow_no_value=True)
    parser.optionxform = str.lower
    parser.read_string(decoded)
    return parser.get(section, key, fallback="").strip()


def files_directory(database: Path) -> Path:
    """Equivalent of main_fs_path for MDB files in v5_attest_DB.read_db_path."""
    database = Path(database)
    if database.suffix.lower() == ".mdb":
        return database.with_suffix("").with_name(database.stem + "_files")
    return database.parent / "ARMv51_files"


def sidecar_for_document(document: str) -> str:
    """Original doc_to_xml2: directory/xml/Word_basename.xml (Windows paths)."""
    dirname, basename = ntpath.split(document)
    if not re.search(r"(?i)\.docx?$", basename):
        raise FsaSourceError(f"Expected Word protocol .doc/.docx: {basename!r}")
    return ntpath.join(dirname, "xml", re.sub(r"(?i)\.docx?$", ".xml", basename))


def resolve_relative_file(root: Path, relative: str) -> Path:
    """Interpret the relative Windows path stored in sout_factors.file."""
    p = PureWindowsPath(relative)
    if p.is_absolute() or p.drive or ".." in p.parts:
        raise FsaSourceError(f"Unsafe/non-relative protocol path: {relative!r}")
    candidate = root.joinpath(*p.parts)
    if not candidate.resolve(strict=False).is_relative_to(root.resolve(strict=False)):
        raise FsaSourceError(f"Protocol path escapes document directory: {relative!r}")
    return candidate


def parse_xml(path: Path) -> ET.Element:
    raw = Path(path).read_bytes()
    if re.search(br"(?i)<!\s*(?:DOCTYPE|ENTITY)\b", raw):
        raise FsaSourceError(f"DTD/entities are disallowed in research XML: {path}")
    try:
        return ET.fromstring(raw)
    except ET.ParseError as exc:
        raise FsaSourceError(f"Malformed XML {path}: {exc}") from exc


@dataclass(frozen=True)
class Sidecar:
    file: str
    protocol_number: str
    protocol_date: str
    signing_date: str
    measurement_dates: str
    factor_id: str
    fgis_state: str
    equipment: tuple[tuple[str, str], ...]
    personnel_count: int
    normative_documents_count: int


def read_sidecar(path: Path) -> Sidecar:
    """Preserve source values; do not calculate, normalize or invent FSA ids."""
    root = parse_xml(path)
    document = root if root.tag == "Document" else root.find(".//Document")
    if document is None:
        raise FsaSourceError(f"No Document element in {path}")
    factor = document.find("factor")
    devices: list[tuple[str, str]] = []
    if factor is not None:
        for group in ("si_guids", "si_guids_os", "si_guids_dop"):
            for node in factor.findall(f"{group}/si_guid"):
                devices.append((node.get("guid", ""), node.get("num", "")))
    persons = document.find("persons")
    nd = document.find("nd_data")
    return Sidecar(
        file=str(path),
        protocol_number=document.get("num_doc", ""),
        protocol_date=document.get("fill_date", ""),
        signing_date=document.get("sign_date", ""),
        measurement_dates=factor.get("izm_date", "") if factor is not None else "",
        factor_id=factor.get("facid", "") if factor is not None else "",
        fgis_state=document.get("fgis_state", ""),
        equipment=tuple(devices),
        personnel_count=len(persons) if persons is not None else 0,
        normative_documents_count=len(nd) if nd is not None else 0,
    )


class AccessReader:
    """Read original MDB without changing records; copy to app-local scratch if locked.

    A legacy Jet/ACE database can require a writable .ldb next to the source.
    No source-file permissions are changed and a live database is never
    compacted, repaired, copied back, or opened for exclusive writing.
    """
    PROVIDERS = ("Microsoft.Jet.OLEDB.4.0", "Microsoft.ACE.OLEDB.12.0")
    LOCK_MARKERS = (
        "could not lock file", "cannot lock file", "couldn't lock file",
        "блокировка файла невозможна", "невозможно заблокировать файл",
        "не удается заблокировать файл",
    )

    def __init__(self, database: Path, *, snapshot_root: Path | None = None):
        self.database = Path(database)
        if not self.database.is_file():
            raise FsaSourceError(f"Access file does not exist: {self.database}")
        if self.database.suffix.lower() != ".mdb":
            raise FsaSourceError("Only original .mdb files are accepted")
        if ";" in str(self.database):
            raise FsaSourceError("Semicolon in Access path is unsupported")
        self._connection = None
        self.provider = ""
        self.used_snapshot = False
        self._snapshot = None
        self._snapshot_root = Path(snapshot_root) if snapshot_root is not None else (
            Path(sys.executable).resolve().parent / "data"
            if getattr(sys, "frozen", False)
            else Path(__file__).resolve().parents[2] / "desktop" / "data"
        )

    @classmethod
    def _lock_error(cls, error: Exception) -> bool:
        message = str(error).casefold()
        return any(key in message for key in cls.LOCK_MARKERS)

    def _open(self, path: Path, client) -> tuple[Exception, ...]:
        failures = []
        for provider in self.PROVIDERS:
            conn = None
            try:
                conn = client.Dispatch("ADODB.Connection")
                # adModeRead | adModeShareDenyNone: do not deny other readers
                # or writers; disable OLE DB connection pooling.
                conn.Mode = 17
                conn.Open(
                    f"Provider={provider};Data Source={path};"
                    "Mode=Read;OLE DB Services=-4;"
                )
                self._connection, self.provider = conn, provider
                return ()
            except Exception as exc:
                failures.append(exc)
                if conn is not None:
                    try:
                        conn.Close()
                    except Exception:
                        pass
        return tuple(failures)

    @staticmethod
    def _is_network_path(path: Path) -> bool:
        value = str(path)
        if value.startswith("\\\\"):
            return True
        if sys.platform != "win32" or len(value) < 3 or value[1:3] != ":\\":
            return False
        try:
            import ctypes
            return ctypes.windll.kernel32.GetDriveTypeW(value[:3]) == 4
        except (AttributeError, OSError):
            return False

    def _open_snapshot(self, client):
        try:
            self._snapshot_root.mkdir(parents=True, exist_ok=True)
            self._snapshot = tempfile.TemporaryDirectory(
                prefix="mdb-read-", dir=str(self._snapshot_root))
            target = Path(self._snapshot.name) / "read-only.mdb"
            before = self.database.stat()
            shutil.copyfile(self.database, target)
            after = self.database.stat()
            if (before.st_size, before.st_mtime_ns) != (
                after.st_size, after.st_mtime_ns
            ) or target.stat().st_size != before.st_size:
                raise FsaSourceError(
                    "Рабочая MDB изменялась во время копирования. "
                    "Повторите проверку после завершения операций с базой."
                )
            errors = self._open(target, client)
            if errors:
                raise FsaSourceError(
                    "Не удалось прочитать временную копию MDB (исходная база не "
                    f"изменялась): {errors[-1]}"
                )
            self.used_snapshot = True
        except Exception:
            self._release_snapshot()
            raise

    def _release_snapshot(self):
        if self._snapshot is not None:
            scratch, self._snapshot = self._snapshot, None
            try:
                scratch.cleanup()
            except OSError as exc:
                raise FsaSourceError(
                    "Не удалось удалить временную копию MDB из папки приложения: "
                    f"{scratch.name}: {exc}"
                ) from exc

    def __enter__(self) -> "AccessReader":
        try:
            import win32com.client
        except ImportError as exc:
            raise FsaSourceError("Windows module pywin32 is required for ADO") from exc
        if self._is_network_path(self.database):
            # ADO may require a writable .ldb on the server even for SELECT.
            # Do not attempt to create any locking file on a network share.
            self._open_snapshot(win32com.client)
            return self
        failures = self._open(self.database, win32com.client)
        if not failures:
            return self
        if any(self._lock_error(exc) for exc in failures):
            # The original file is readable but Jet/ACE cannot coordinate
            # its lock file. This is not proof of a missing OLE DB driver.
            self._open_snapshot(win32com.client)
            return self
        raise FsaSourceError(
            "Не удалось открыть MDB только для чтения с Jet/ACE: "
            + "; ".join(str(err) for err in failures)
        )

    def __exit__(self, *args: object) -> None:
        try:
            if self._connection is not None:
                self._connection.Close()
                self._connection = None
        finally:
            self._release_snapshot()

    def table_names(self) -> frozenset[str]:
        """Query ADO schema in read-only mode; no CREATE/ALTER as original does."""
        if self._connection is None:
            raise FsaSourceError("ADO connection is not open")
        schema = self._connection.OpenSchema(20)  # adSchemaTables
        try:
            names = set()
            while not schema.EOF:
                name = schema.Fields("TABLE_NAME").Value
                if name:
                    names.add(str(name).upper())
                schema.MoveNext()
            return frozenset(names)
        finally:
            schema.Close()

    def select(self, query: str) -> list[dict[str, Any]]:
        if self._connection is None:
            raise FsaSourceError("ADO connection is not open")
        if not re.match(r"(?is)^\s*SELECT\s", query) or ";" in query:
            raise FsaSourceError("Only one read-only SELECT statement is permitted")
        rows: list[dict[str, Any]] = []
        result = self._connection.Execute(query)
        rs = result[0] if isinstance(result, tuple) else result
        try:
            while not rs.EOF:
                row: dict[str, Any] = {}
                for i in range(rs.Fields.Count):
                    field = rs.Fields.Item(i)
                    value = field.Value
                    if isinstance(value, (datetime, date)):
                        value = value.isoformat()
                    row[str(field.Name)] = value
                rows.append(row)
                rs.MoveNext()
        finally:
            rs.Close()
        return rows


def candidate_factor(factor_id: int) -> bool:
    """Intersection of the two filters in fill_fgis_ra_data, before UI selections."""
    if factor_id in (16, 101, 105):
        return False
    if factor_id >= 10000 and factor_id not in (10009, 10099):
        return False
    return 0 < factor_id <= 26 or factor_id in (35, 37, 41, 10009, 10099)


@dataclass(frozen=True)
class Candidate:
    rm_id: int
    factor_id: int
    word_file: str
    xml_file: str
    status: str
    protocol_number: str = ""
    fgis_state: str = ""
    equipment_guids: tuple[str, ...] = ()


class AppSources:
    """Read the same working MDB, resource MDB and adjacent XML as original export."""

    def __init__(self, workplace_mdb: Path, resources_mdb: Path, *,
                 documents_root: Path | None = None):
        self.workplace_mdb = Path(workplace_mdb)
        self.resources_mdb = Path(resources_mdb)
        self.documents_root = Path(documents_root) if documents_root else files_directory(self.workplace_mdb)

    def inspect(self, rm_ids: list[int] | None = None) -> dict[str, Any]:
        if not self.documents_root.is_dir():
            raise FsaSourceError(f"Missing linked document directory: {self.documents_root}")
        with AccessReader(self.workplace_mdb) as main, AccessReader(self.resources_mdb) as resources:
            # Use the same first-GUID-then-factory-number rules as the real
            # res_orgs.mdb adapter; missing optional tables are reported,
            # never created as the original GUI would do.
            from .resources import ResourceCatalog
            catalog = ResourceCatalog.from_reader(resources)
            if rm_ids is None:
                rm_ids = [int(row["id"]) for row in main.select(
                    "SELECT id FROM struct_rm WHERE deleted=0 AND id>0 ORDER BY id"
                )]
            reports: list[Candidate] = []
            for rm_id in rm_ids:
                rm_id = int(rm_id)  # enforce a numeric ID before constructing SQL
                if rm_id <= 0:
                    raise FsaSourceError("rm_id must be positive")
                rows = main.select(
                    "SELECT factor_id, factor_name, izm_date, file FROM sout_factors "
                    f"WHERE rm_id={rm_id} AND factor_id<>16 AND factor_id<>101 AND "
                    "factor_id<>105 AND (factor_id<10000 OR factor_id=10009 "
                    "OR factor_id=10099) ORDER BY factor_id"
                )
                for row in rows:
                    factor_id = int(row["factor_id"])
                    if not candidate_factor(factor_id):
                        continue
                    word_file = resolve_relative_file(self.documents_root, str(row.get("file") or ""))
                    xml_file = word_file.parent / "xml" / (word_file.stem + ".xml")
                    if not xml_file.is_file():
                        reports.append(Candidate(rm_id, factor_id, str(word_file), str(xml_file), "missing_xml"))
                        continue
                    try:
                        entry = read_sidecar(xml_file)
                    except FsaSourceError:
                        reports.append(Candidate(rm_id, factor_id, str(word_file), str(xml_file), "malformed_xml"))
                        continue
                    # Original get_xml_data skips equipment lookup when fgis_state=2.
                    missing = tuple(
                        g or num for g, num in entry.equipment
                        if entry.fgis_state not in ("1", "2")
                        and catalog.device(g, num).requires_review
                    )
                    status = "excluded_by_fgis_state" if entry.fgis_state == "1" else (
                        "unmapped_equipment" if missing else "ready_for_further_mapping"
                    )
                    reports.append(Candidate(rm_id, factor_id, str(word_file),
                                             str(xml_file), status, entry.protocol_number,
                                             entry.fgis_state, tuple(g for g, _ in entry.equipment)))
        copies_used = [
            source for source, reader in (
                ("База рабочих мест", main),
                ("Справочник ресурсов", resources),
) if getattr(reader, "used_snapshot", False)
        ]
        return {
            "workplace_mdb": str(self.workplace_mdb),
            "resources_mdb": str(self.resources_mdb),
            "documents_root": str(self.documents_root),
            "temporary_snapshot_sources": copies_used,
            "snapshot_warning": (
                "Считывание выполнено по временной копии MDB. "
                "Если оригинал изменялся одновременно с копированием, "
                "снимок может быть несогласованным; для контрольной "
                "проверки остановите изменения исходной базы."
                if copies_used else None
            ),
            "candidates": [asdict(c) for c in reports],
            "note": "Read-only source inspection: individual equipment mapping uses the original GUID/serial/FGIS rules; full ND/person/indicator output and final XML are incomplete.",
        }
