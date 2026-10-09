"""Conservative read-only evidence for the original resource MDB selection.

The original ATT51 may use a local or shared res_orgs.mdb. A database with
zero devices/persons is NOT by itself evidence of the wrong file.
"""
from __future__ import annotations

import os
from pathlib import Path

from att51_fsa.sources import read_ini
from source_discovery import OriginalInstallation, discover_installations


def _equal_path(first: Path, second: Path) -> bool:
    return os.path.normcase(str(Path(first).resolve(strict=False))).casefold() == (
        os.path.normcase(str(Path(second).resolve(strict=False))).casefold()
    )


def resource_source_evidence(
    selected: Path,
    *,
    installations: tuple[OriginalInstallation, ...] | None = None,
) -> dict:
    selected = Path(selected)
    candidates = installations if installations is not None else discover_installations()
    found = []
    for installation in candidates:
        folder = Path(installation.folder)
        direct = folder / "options.ini"
        local = os.environ.get("LOCALAPPDATA", "")
        virtual_ini = None
        if local:
            # Do not guess the path of a relocated copy. The discovery layer
            # already inspected a possible VirtualStore and selected its MDB.
            try:
                from source_discovery import _virtualstore_folder
                virtual = _virtualstore_folder(folder)
                virtual_ini = virtual / "options.ini" if virtual else None
            except (OSError, ValueError):
                virtual_ini = None
        ini = virtual_ini if virtual_ini is not None and virtual_ini.is_file() else direct
        if not ini.is_file():
            continue
        flag = read_ini(ini, "DB_res", "res_flag").strip()
        raw_path = read_ini(ini, "DB_res", "res_path").strip()
        choices = tuple(Path(p) for p in installation.resources)
        found.append({
            "original_installation": str(folder),
            "settings_file": str(ini),
            "resource_mode": "shared" if flag == "1" else "local",
            "res_flag": flag if flag else None,
            "configured_res_path": raw_path if flag == "1" else None,
            "resolved_resource_paths": [str(p) for p in choices],
            "selected_matches_this_installation": any(
                _equal_path(selected, c) for c in choices
            ),
            "source_warnings": list(installation.warnings),
        })
    matched = sum(bool(x["selected_matches_this_installation"]) for x in found)
    if not found:
        status = "original_configuration_not_found"
        guidance = (
            "Рабочий options.ini оригинала не обнаружен. Подтвердите вручную "
            "установку и раздел [DB_res] без передачи всей MDB."
        )
    elif matched and len(found) == 1:
        status = "matches_original_setting"
        guidance = (
            "Выбранный путь соответствует настройке оригинала. "
            "Отсутствие записей ATT_DEVICE/ATT_PERSON или таблицы FGIS_RA "
            "не доказывает, что файл неправильный."
        )
    elif matched:
        status = "matches_one_of_multiple_installations"
        guidance = "Есть несколько установок оригинала; подтвердите рабочую."
    else:
        status = "differs_from_known_original_settings"
        guidance = (
            "Выбранный файл не совпадает с путём справочника, указанным "
            "обнаруженными настройками оригинала. Проверьте рабочую установку."
        )
    return {
        "selected_resource": str(selected),
        "status": status,
        "guidance": guidance,
        "checked_installations": found,
        "read_only": True,
    }
