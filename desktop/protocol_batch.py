"""Read-only diagnostic of all XML protocols linked from the original MDB.

A selected XML is not a global source of data. Each protocol's XML is resolved
from sout_factors.file by source_discovery; the real output remains disabled.
"""
from __future__ import annotations

from collections import Counter
from pathlib import Path

from att51_fsa.pipeline_2025 import (
    Original2025Options, analyze_2025,
)
from att51_fsa.resources import ResourceCatalog
from att51_fsa.sources import FsaSourceError, parse_xml
from source_discovery import discover_protocols
from internal_xml import FACTOR_NAMES
from factor_structure import inspect_factor_structure


def inspect_all_2025(
    workplace_mdb: Path,
    resources_mdb: Path,
    options: Original2025Options,
    *,
    rm_id: int | None = None,
    working_fgis_ini: Path | None = None,
) -> dict:
    """Inspect every existing XML linked by the MDB; never generate FGIS XML."""
    workplace_mdb, resources_mdb = Path(workplace_mdb), Path(resources_mdb)
    if working_fgis_ini is not None:
        working_fgis_ini = Path(working_fgis_ini)
        if not working_fgis_ini.is_file():
            raise FileNotFoundError(f"Не найдены указанные настройки ФГИС: {working_fgis_ini}")

    # One read of the MDB protocol index and one resource catalog for all rows.
    protocols = discover_protocols(workplace_mdb, rm_id=rm_id)
    catalog = ResourceCatalog.from_mdb(resources_mdb)
    records: list[dict] = []
    counts: Counter[str] = Counter()
    info = catalog.diagnostics
    resource_may_be_template = (
        info.device_count == 0 and info.person_count == 0 and
        "FGIS_RA" in info.tables_absent
    )
    for protocol in protocols:
        record = {
            "rm_id": protocol.rm_id,
            "factor_id_mdb": protocol.factor_id,
            "factor_name": FACTOR_NAMES.get(str(protocol.factor_id), ""),
            "xml": str(protocol.xml),
        }
        try:
            original_xml = parse_xml(protocol.xml)
            result = analyze_2025(
                original_xml, catalog, options,
                working_fgis_ini=working_fgis_ini,
            )
            record.update({
                "number": result.number,
                "factor_id_xml": result.factor_id,
                "status": result.status,
                "supported": result.supported,
                "measurement_count": len(result.measurement_traces),
                "errors": list(result.errors),
                "resource_errors": list(result.resource_errors),
                "resource_warnings": list(result.resource_warnings),
            })
            if result.status == "unsupported_factor":
                if str(protocol.factor_id) in FACTOR_NAMES:
                    record["measurement_structure_evidence"] = inspect_factor_structure(
                        original_xml
                    )
                record["explanation"] = (
                    "Обнаруженный внутренний XML не повреждён. "
                    "Преобразование данного фактора в ФГИС ещё не реализовано."
                )
            if result.factor_id != str(protocol.factor_id):
                record["factor_mismatch"] = True
                record["errors"].append("XML factor ID differs from MDB")
        except (FsaSourceError, ValueError, OSError) as error:
            record.update({
                "status": "source_read_error",
                "supported": False,
                "errors": [f"{type(error).__name__}: {error}"],
            })
        counts[record["status"]] += 1
        records.append(record)
    return {
        "workplace_mdb": str(workplace_mdb),
        "resources_mdb": str(resources_mdb),
        "rm_filter": rm_id,
        "found_linked_xml": len(protocols),
        "statuses": dict(sorted(counts.items())),
        "fgis_ini": str(working_fgis_ini) if working_fgis_ini else None,
        "resource_source_warning": (
            "В справочнике нет приборов, сотрудников и таблицы FGIS_RA. "
            "Это не доказывает, что выбран неправильный файл; сверяйте "
            "источник с настройкой оригинала [DB_res]."
            if resource_may_be_template else None
        ),
        "warnings": (
            ["Пользовательский fgis_ra.ini отсутствует: идентификаторы "
             "из локальных переопределений не могут быть учтены."]
            if working_fgis_ini is None else []
        ) + [
            "Проверяются только существующие XML, указанные в sout_factors.file; "
            "для списка отсутствующих XML используйте «Проверить протоколы базы».",
        ],
        "protocols": records,
        "not_exportable": True,
        "note": "Частичная диагностика шести видов факторов; итоговый XML ФГИС не формируется.",
    }
