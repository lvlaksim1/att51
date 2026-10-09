"""The single read-only input and selection pipeline for both XML and Excel.

Neither format writer reads MDB, original protocol XML or resource catalogs.
Only this common service reads them and invokes verified prepare_protocol.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from att51_fsa.export_2025 import CustomerSettings, PreparedProtocol, prepare_protocol
from att51_fsa.labour_2025 import LabourOptions
from att51_fsa.aerosol_2025 import ChemicalOptions
from att51_fsa.pipeline_2025 import Original2025Options
from att51_fsa.resources import ResourceCatalog
from att51_fsa.sources import FsaSourceError, parse_xml
from whole_base_reports import read_inventory


@dataclass(frozen=True)
class ProtocolBatch:
    total: int
    protocols: tuple[PreparedProtocol, ...]
    issues: tuple[str, ...]
    resource_lines: tuple[str, ...]
    @property
    def ready(self) -> bool:
        return bool(self.protocols) and not self.issues
    @property
    def measurement_count(self) -> int:
        return sum(len(proposal.protocol.research_objects)
                   for proposal in self.protocols if proposal.protocol is not None)


def prepare_batch(
    database: Path, resources: Path, ini: Path | None, customer: CustomerSettings,
    *, labour: LabourOptions | None = None,
    chemical: ChemicalOptions | None = None,
) -> ProtocolBatch:
    """Never emit only a subset of source protocols; fail closed on any issue."""
    issues: list[str] = list(customer.validate())
    resource_lines: list[str] = []
    try:
        _, items, _ = read_inventory(Path(database))
    except (FsaSourceError, OSError, ValueError) as exc:
        items = []
        issues.append("База рабочих мест: " + str(exc))
    try:
        catalog = ResourceCatalog.from_mdb(Path(resources))
        info = catalog.diagnostics
        resource_lines = [
            "Ресурсы: приборов " + str(info.device_count)
            + ", сотрудников " + str(info.person_count)
            + ", нормативных документов " + str(info.normative_count)
            + ", связей ID ФГИС " + str(info.fgis_link_count)
            + ", методов ОА " + str(info.oa_method_count),
            "Отсутствующие таблицы в выбранной базе: "
            + (", ".join(info.tables_absent) if info.tables_absent else "нет"),
        ]
        if "FGIS_RA" in info.tables_absent:
            issues.append("В выбранной базе нет таблицы FGIS_RA: сопоставление ID "
                          "ФГИС невозможно. Возможно, выбран не тот ресурсный файл.")
        elif info.fgis_link_count == 0:
            issues.append("В выбранной базе таблица FGIS_RA не содержит связей "
                          "с ID ФГИС; проверьте выбор рабочей базы ресурсов.")
    except (FsaSourceError, OSError, ValueError) as exc:
        catalog = None
        issues.append("База ресурсов: " + str(exc))
    if not items:
        issues.append("Нет протоколов для выгрузки")
    prepared: list[PreparedProtocol] = []
    seen: set[tuple[str, str]] = set()
    opts = Original2025Options(labour=labour or LabourOptions(),
                               chemical=chemical or ChemicalOptions())
    for ix, item in enumerate(items, 1):
        context = (f"Протокол {ix}, РМ {item['rm_id']}, "
                   f"фактор {item['factor_id']}")
        path = item["xml"]
        if path is None or not path.is_file():
            issues.append(context + ": отсутствует связанный внутренний XML")
            continue
        try:
            original = parse_xml(path)
            doc = original if original.tag == "Document" else original.find(".//Document")
            factor = doc.find("./factor") if doc is not None else None
            if factor is None or factor.get("facid", "") != item["factor_id"]:
                issues.append(context + ": фактор XML и основной MDB не совпадают")
                continue
            if catalog is None:
                continue
            result = prepare_protocol(
                original, catalog, customer, options=opts,
                working_ini=Path(ini) if ini else None)
            if result.blockers:
                issues.extend(context + ": " + message
                              for message in result.blockers
                              if message not in customer.validate())
            if result.protocol is not None:
                key = (result.protocol.doc_id, result.protocol.creation_date)
                if key in seen:
                    issues.append(context + ": повторение номера и даты протокола")
                seen.add(key)
                if result.source is None or (
                    len(result.source.measurements) !=
                    len(result.protocol.research_objects)
                ):
                    issues.append(context + ": отсутствует единый исходный набор показателей")
                else:
                    prepared.append(result)
        except (FsaSourceError, OSError, ValueError) as exc:
            issues.append(context + ": ошибка исходных данных: " + str(exc))
    return ProtocolBatch(len(items), tuple(prepared),
                         tuple(dict.fromkeys(issues)), tuple(resource_lines))
