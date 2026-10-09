"""Safe, read-only discovery of ATT51's working files.

Evidence: original v5_attest_DB [DB]/sout_path, v5_res_main
[DB_res]/res_flag/res_path and v52_exp_fgis_ra sout_factors.file.
No directory-wide disk scan, database modifications or guessed XML paths.
"""
from __future__ import annotations

from dataclasses import dataclass
import os
from pathlib import Path
from typing import Iterable

from att51_fsa.sources import AccessReader, files_directory, read_ini, resolve_relative_file


ORIGINAL_DIR = "Аттестация-5.1(СОУТ)"


@dataclass(frozen=True)
class OriginalInstallation:
    folder: Path
    databases: tuple[Path, ...]
    resources: tuple[Path, ...]
    settings: tuple[Path, ...]
    warnings: tuple[str, ...]


@dataclass(frozen=True)
class Protocol:
    rm_id: int
    factor_id: int
    document: Path
    xml: Path

    @property
    def label(self) -> str:
        return f"РМ {self.rm_id}, фактор {self.factor_id}: {self.xml.name} — {self.xml.parent.parent.name}"


def default_install_roots() -> tuple[Path, ...]:
    """Known original folder; no recursive search across personal documents."""
    bases = []
    explicit = os.environ.get("ATT51_ORIGINAL_DIR", "").strip()
    if explicit:
        bases.append(Path(explicit))
    for key in ("ProgramFiles(x86)", "ProgramFiles"):
        if os.environ.get(key):
            bases.append(Path(os.environ[key]) / ORIGINAL_DIR)
    # Nonstandard installations can be selected explicitly in the GUI.
    return tuple(dict.fromkeys(bases))


def _configured_path(raw: str, original_root: Path) -> Path | None:
    value = raw.strip().strip('"').strip("'").strip()
    if not value or "\x00" in value:
        return None
    path = Path(os.path.expandvars(value))
    if not path.is_absolute():
        path = original_root / path
    return path


def _databases_from_setting(path: Path | None) -> tuple[Path, ...]:
    if path is None:
        return ()
    if path.is_file() and path.suffix.lower() == ".mdb":
        return (path,)
    if path.is_dir():
        # The original setting may point at a directory containing several MDBs.
        # Never silently choose one when the working database is ambiguous.
        return tuple(sorted(
            (p for p in path.iterdir()
             if p.is_file() and p.suffix.lower() == ".mdb"
             and p.name.lower() not in ("res_orgs.mdb", "user_data.mdb")),
            key=lambda p: p.name.casefold()))
    return ()


def inspect_installation(root: Path) -> OriginalInstallation | None:
    """Accept a folder only when both original Word add-in and INI exist."""
    root = Path(root)
    options = root / "options.ini"
    if not options.is_file() or not (root / "Attestation51.dot").is_file():
        return None

    warnings: list[str] = []
    configured_db = read_ini(options, "DB", "sout_path")
    mdbs = _databases_from_setting(_configured_path(configured_db, root))
    if not configured_db:
        warnings.append("В исходном options.ini отсутствует [DB] sout_path.")
    elif not mdbs:
        warnings.append("Путь [DB] sout_path не указывает на доступную рабочую MDB.")
    elif len(mdbs) > 1:
        warnings.append("В каталоге рабочей базы несколько MDB: требуется выбор.")

    resource_flag = read_ini(options, "DB_res", "res_flag")
    resource_value = read_ini(options, "DB_res", "res_path")
    if resource_flag == "1":
        resource = _configured_path(resource_value, root)
        if resource is not None and resource.is_dir():
            resource = resource / "res_orgs.mdb"
        if resource is None or not resource.is_file() or resource.suffix.lower() != ".mdb":
            resources: tuple[Path, ...] = ()
            warnings.append("Внешний справочник [DB_res] res_path недоступен; локальный не подставлен.")
        else:
            resources = (resource,)
    else:
        # Original VBA uses this path when res_flag is not 1.
        local = root / "res_orgs.mdb"
        resources = (local,) if local.is_file() else ()
        if not resources:
            warnings.append("Локальный res_orgs.mdb оригинальной установки отсутствует.")

    fgis_ini = root / "fgis_ra.ini"
    settings = (fgis_ini,) if fgis_ini.is_file() else ()
    if not settings:
        warnings.append("fgis_ra.ini не найден: параметры не подставляются.")

    return OriginalInstallation(root, mdbs, resources, settings, tuple(warnings))


def discover_installations(
    roots: Iterable[Path] | None = None,
) -> tuple[OriginalInstallation, ...]:
    candidates = default_install_roots() if roots is None else tuple(roots)
    found = []
    visited = set()
    for root in candidates:
        resolved = Path(root).resolve(strict=False)
        key = os.path.normcase(str(resolved)).casefold()
        if key in visited:
            continue
        visited.add(key)
        result = inspect_installation(resolved)
        if result is not None:
            found.append(result)
    return tuple(found)


def discover_protocols(database: Path, rm_id: int | None = None) -> tuple[Protocol, ...]:
    """List real XML siblings of Word documents recorded in sout_factors.

    There is no XML guess by filename or directory scan. Uses read-only ADO.
    """
    if rm_id is not None and (type(rm_id) is not int or rm_id <= 0):
        raise ValueError("Номер рабочего места должен быть положительным целым числом.")
    database = Path(database)
    document_root = files_directory(database)
    if not document_root.is_dir():
        raise FileNotFoundError(f"Отсутствует связанный каталог протоколов: {document_root}")
    query = "SELECT rm_id, factor_id, [file] FROM sout_factors"
    if rm_id is not None:
        query += f" WHERE rm_id={rm_id}"
    query += " ORDER BY rm_id, factor_id"
    result = []
    with AccessReader(database) as connection:
        if "SOUT_FACTORS" not in connection.table_names():
            raise ValueError("В рабочей базе отсутствует таблица sout_factors.")
        for item in connection.select(query):
            relative = str(item.get("file") or item.get("FILE") or "").strip()
            if not relative:
                continue
            try:
                document = resolve_relative_file(document_root, relative)
                if document.suffix.lower() not in (".doc", ".docx"):
                    continue
                xml = document.parent / "xml" / (document.stem + ".xml")
                if not xml.is_file():
                    continue
                result.append(Protocol(int(item.get("rm_id") or item.get("RM_ID")),
                                       int(item.get("factor_id") or item.get("FACTOR_ID")),
                                       document, xml))
            except (ValueError, TypeError, OSError):
                continue
    return tuple(result)
