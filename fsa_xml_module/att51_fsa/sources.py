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
import re
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
    parser = configparser.ConfigParser(interpolation=None, strict=False)
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
    """Windows ADODB, like the original; requires installed Jet or ACE provider.

    READ-ONLY mode; no Word automation, schema upgrades, write SQL or migrations.
    """
    PROVIDERS = ("Microsoft.Jet.OLEDB.4.0", "Microsoft.ACE.OLEDB.12.0")

    def __init__(self, database: Path):
        self.database = Path(database)
        if not self.database.is_file():
            raise FsaSourceError(f"Access file does not exist: {self.database}")
        if self.database.suffix.lower() != ".mdb":
            raise FsaSourceError("Only original .mdb files are accepted")
        if ";" in str(self.database):
            raise FsaSourceError("Semicolon in Access path is unsupported")
        self._connection = None
        self.provider = ""

    def __enter__(self) -> "AccessReader":
        try:
            import win32com.client
        except ImportError as exc:
            raise FsaSourceError("Windows module pywin32 is required for ADO") from exc
        last = None
        for provider in self.PROVIDERS:
            conn = win32com.client.Dispatch("ADODB.Connection")
            try:
                conn.Mode = 1  # adModeRead
                conn.Open(f"Provider={provider};Data Source={self.database};Mode=Read;")
                self._connection, self.provider = conn, provider
                return self
            except Exception as exc:
                last = exc
                try:
                    conn.Close()
                except Exception:
                    pass
        raise FsaSourceError(
            f"Unable to read MDB with Jet/ACE OLE DB (architecture or driver): {last}"
        )

    def __exit__(self, *args: object) -> None:
        if self._connection is not None:
            self._connection.Close()
            self._connection = None

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
            mappings = resources.select("SELECT rec_type, rec_guid, IntValue FROM FGIS_RA")
            available = {
                (int(row["rec_type"]), str(row["rec_guid"]).lower()): row["IntValue"]
                for row in mappings
                if row.get("rec_guid") is not None and row.get("rec_type") is not None
            }
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
                        g for g, _ in entry.equipment
                        if entry.fgis_state not in ("1", "2")
                        and g and (0, g.lower()) not in available
                    )
                    status = "excluded_by_fgis_state" if entry.fgis_state == "1" else (
                        "unmapped_equipment" if missing else "ready_for_further_mapping"
                    )
                    reports.append(Candidate(rm_id, factor_id, str(word_file),
                                             str(xml_file), status, entry.protocol_number,
                                             entry.fgis_state, tuple(g for g, _ in entry.equipment)))
        return {
            "workplace_mdb": str(self.workplace_mdb),
            "resources_mdb": str(self.resources_mdb),
            "documents_root": str(self.documents_root),
            "candidates": [asdict(c) for c in reports],
            "note": "Source inspection ONLY; ND/person/indicator mappings and final XML generation are not yet equivalent to original.",
        }
