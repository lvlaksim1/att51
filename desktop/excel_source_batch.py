"""Independent, read-only extraction of original protocol values for Excel.

Never calls FGIS XML preparation; every SOUT_FACTORS record gets a row.
Unverified ID-to-label mappings are not inferred.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

from att51_fsa.export_2025 import CustomerSettings
from att51_fsa.resources import ResourceCatalog
from att51_fsa.source_snapshot import (
    EMPTY, attr, first, joined, literal, value_or_missing, word_or_missing,
)
from att51_fsa.sources import FsaSourceError, parse_xml
from whole_base_reports import read_inventory


@dataclass(frozen=True)
class ExcelSourceBatch:
    total: int
    excel_rows: tuple[tuple[str, ...], ...]
    indicator_count: int
    issues: tuple[str, ...]


def _people(factor: ET.Element | None, catalog: ResourceCatalog | None,
            path: str) -> str:
    names = []
    if factor is not None:
        for node in factor.findall(path):
            name = attr(node, "fio", "name", "full_name")
            if not name and catalog is not None:
                resolved = catalog.person(attr(node, "guid"), attr(node, "snils"))
                if resolved.found:
                    name = resolved.display_name
            if name:
                names.append(name)
    return value_or_missing(joined(names))


def _equipment(factor: ET.Element | None, catalog: ResourceCatalog | None) -> str:
    names = []
    if factor is not None:
        for node in factor.findall("./si_guids/si_guid"):
            name = attr(node, "name", "device_name")
            if not name and catalog is not None:
                resolved = catalog.device(attr(node, "guid"), attr(node, "num"))
                if resolved.found:
                    name = resolved.display_name
            if name:
                names.append(name)
    return value_or_missing(joined(names))


def _measurement_nodes(doc: ET.Element):
    seen = set()
    for section_name in ("izm_data", "count_params2", "measurements",
                         "measure_data", "measurement_data"):
        section = doc.find("./" + section_name)
        if section is None:
            continue
        for node in section.iter():
            if node.tag.casefold() in ("param", "measurement", "value") and id(node) not in seen:
                seen.add(id(node))
                yield node


def _measurements(doc: ET.Element) -> list[tuple[str, str, str, str, str]]:
    methods = {}
    for node in doc.findall("./nd_data/nd"):
        ident, name = attr(node, "id"), attr(node, "name")
        if ident and name:
            methods.setdefault(ident, set()).add(name)
    rows = []
    for node in _measurement_nodes(doc):
        name = word_or_missing(attr(node, "name", "indicator_name", "param_name",
                                    "caption", "title", "label", "izm_name"))
        unit = word_or_missing(attr(node, "unit", "unit_name", "ed_izm", "edizm",
                                    "units", "measurement_unit", "unit_text"))
        method = attr(node, "method_name", "method")
        matched = methods.get(attr(node, "nd_izm1"), set())
        if not method and len(matched) == 1:
            method = next(iter(matched))
        technique = word_or_missing(attr(node, "oa_method", "method_oa"))
        values = [attr(node, key) for key in ("fact", "value", "result", "param1", "param2")]
        values = [value for value in values if value]
        if not values and node.text and node.text.strip() and not list(node):
            values = [literal(node.text)]
        for value in values or [EMPTY]:
            rows.append((name, value_or_missing(value), unit,
                         word_or_missing(method), technique))
    return rows


def _shared(doc: ET.Element | None, item: dict,
            customer: CustomerSettings) -> tuple[str, ...]:
    factor = doc.find("./factor") if doc is not None else None
    object_node = doc.find("./object") if doc is not None else None
    nodes = tuple(n for n in (object_node, doc, factor) if n is not None)
    return (
        value_or_missing(attr(doc, "num_doc")),
        value_or_missing(attr(factor, "start_date", "date_begin", "izm_date")),
        value_or_missing(attr(factor, "end_date", "date_end")),
        value_or_missing(attr(doc, "fill_date", "sign_date")),
        value_or_missing(customer.full_name or customer.fio),
        word_or_missing(customer.address_type),
        value_or_missing(customer.address),
        value_or_missing(customer.inn),
        word_or_missing(first(nodes, "object_type_name", "object_type")),
        value_or_missing(first(nodes, "object_name", "full_name_object", "factor_name")
                         or item.get("factor_name", "")),
    )


def _additional(doc: ET.Element | None, customer: CustomerSettings,
                catalog: ResourceCatalog | None) -> tuple[str, ...]:
    extra = doc.find("./dop_info") if doc is not None else None
    factor = doc.find("./factor") if doc is not None else None
    customer_node = doc.find("./customer") if doc is not None else None
    nodes = tuple(n for n in (extra, customer_node, doc) if n is not None)
    normative = joined(n.get("name", "") for n in doc.findall("./nd_data/nd")) if doc is not None else ""
    contacts = [customer.contacts, first(nodes, "contact", "contacts", "phone",
                                         "telephone", "email")]
    if doc is not None:
        contacts.extend(attr(node, "value", "phone", "email", "address") or literal(node.text)
                        for node in doc.findall(".//contact"))
    return (
        value_or_missing(joined(contacts)),
        value_or_missing(customer.application_date),
        value_or_missing(normative),
        value_or_missing(first(nodes, "sample_receive_date", "received_date")),
        value_or_missing(first(nodes, "sample_count", "samples_count")),
        value_or_missing(first(nodes, "sample_date", "sampling_date")),
        value_or_missing(first(nodes, "sample_place", "sampling_place", "sampling_address")),
        _equipment(factor, catalog),
        _people(factor, catalog, "./persons/pers"),
        _people(factor, catalog, "./exp_persons/pers"),
        (_people(factor, catalog, "./boss/pers")
         if factor is not None and factor.findall("./boss/pers")
         else _people(factor, catalog, "./boss")),
    )


def prepare_excel_sources(database: Path, resources: Path, ini: Path | None,
                          customer: CustomerSettings) -> ExcelSourceBatch:
    """Keep every protocol, even if its factor/ND/resource has no FGIS mapping."""
    # The optional INI affects FGIS ID transformations, not raw Excel.
    _, items, _ = read_inventory(Path(database))
    if not items:
        raise FsaSourceError("В рабочей MDB нет протоколов для Excel")
    warnings = []
    try:
        catalog = ResourceCatalog.from_mdb(Path(resources))
    except (FsaSourceError, OSError, ValueError) as exc:
        catalog = None
        warnings.append("Справочник оборудования и сотрудников: " + str(exc))
    result = []
    indicators = 0
    for index, item in enumerate(items, 1):
        context = f"Протокол {index}, РМ {item['rm_id']}, фактор {item['factor_id']}"
        doc = None
        path = item.get("xml")
        if path is None or not Path(path).is_file():
            warnings.append(context + ": отсутствует исходный XML; строка сохранена")
        else:
            try:
                original = parse_xml(Path(path))
                doc = original if original.tag == "Document" else original.find(".//Document")
                if doc is None:
                    warnings.append(context + ": нет Document; строка сохранена")
                else:
                    factor = doc.find("./factor")
                    if factor is None or attr(factor, "facid") != str(item["factor_id"]):
                        warnings.append(context + ": фактор в XML не совпадает с MDB")
            except (FsaSourceError, OSError, ValueError) as exc:
                warnings.append(context + ": XML не прочитан: " + str(exc))
        measurements = _measurements(doc) if doc is not None else []
        if not measurements:
            warnings.append(context + ": показатели из исходного XML не установлены")
            measurements = [(EMPTY,) * 5]
        else:
            indicators += sum(value != EMPTY for _, value, _, _, _ in measurements)
        shared = _shared(doc, item, customer)
        extra = _additional(doc, customer, catalog)
        if len(shared) != 10 or len(extra) != 11:
            raise FsaSourceError("Нарушена структура 26 столбцов Excel")
        for i, measurement in enumerate(measurements):
            result.append((shared if i == 0 else ("",) * 10) + measurement
                          + (extra if i == 0 else ("",) * 11))
    if len(result) > 65535:
        raise FsaSourceError("В формате XLS не более 65 535 строк данных")
    return ExcelSourceBatch(len(items), tuple(result), indicators,
                            tuple(dict.fromkeys(warnings)))
