"""Independent, read-only extraction of original protocol values for Excel.

Never calls FGIS XML preparation; every SOUT_FACTORS record gets a row.
Unverified ID-to-label mappings are not inferred.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET
import re
from zipfile import ZipFile, BadZipFile

from att51_fsa.export_2025 import CustomerSettings
from att51_fsa.resources import ResourceCatalog
from att51_fsa.source_snapshot import (
    EMPTY, attr, first, joined, literal, value_or_missing, word_or_missing,
)
from att51_fsa.sources import FsaSourceError, parse_xml
from whole_base_reports import read_inventory
from original_excel_units import OriginalUnits


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
    return joined(names)


def _equipment(
    factor: ET.Element | None, catalog: ResourceCatalog | None,
    warnings: list[str] | None = None, context: str = "",
) -> str:
    """Original exporter: si_guid GUID, then factory number -> ATT_DEVICE.

    The serial/factory number is mandatory in our Excel equipment caption.
    An inventory number is added only from an explicitly named source field.
    Registration (reg_num), batch, and ambiguous custom fields are NOT inventory.
    """
    if factor is None:
        return ""
    names = []
    seen: set[tuple[str, str]] = set()
    for section in ("si_guids", "si_guids_os", "si_guids_dop"):
        for node in factor.findall("./" + section + "/si_guid"):
            guid = attr(node, "guid")
            original_factory = attr(node, "num")
            key = (guid, original_factory)
            if key in seen:
                continue
            seen.add(key)
            name = attr(node, "name", "device_name")
            record = None
            if catalog is not None:
                match = catalog.device(guid, original_factory)
                if match.found:
                    record = next((device for device in catalog.devices
                                   if device.guid == match.local_guid), None)
                    if not name:
                        name = record.name if record is not None else match.display_name
            factory = original_factory or (record.factory_number if record is not None else "")
            xml_inventory = attr(node, "inventory_num", "inventory_number",
                                 "inv_num", "inv_number", "inventory_no")
            inventory = xml_inventory or (
                record.inventory_number if record is not None else ""
            )
            if record is not None and original_factory and record.factory_number and (
                    original_factory != record.factory_number):
                if warnings is not None:
                    warnings.append(context + ": заводской номер из XML (" + original_factory +
                                    ") не совпадает с карточкой прибора (" +
                                    record.factory_number + ")")
            if record is not None and xml_inventory and record.inventory_number and (
                    xml_inventory != record.inventory_number):
                if warnings is not None:
                    warnings.append(context + ": инвентарный номер из XML не совпадает "
                                    "с карточкой прибора")
            if not factory and warnings is not None:
                warnings.append(context + ": отсутствует заводской номер средства "
                                "измерений (GUID=" + (guid or EMPTY) + ")")
            if not name and warnings is not None:
                warnings.append(context + ": не определено название средства "
                                "измерений (GUID=" + (guid or EMPTY) + ")")
            result = (name or "") + " (зав. № " + factory
            if inventory:
                result += "; инв. № " + inventory
            names.append(result + ")")
    return joined(names)



# Extract only literal textual units from the original measurement caption,
# never an assumed mapping from FGIS IDs, factor numbers or measurement codes.
_UNIT_SUFFIX = re.compile(
    r"(?:,\s*|\(\s*)(дБА|дБ|лк|мг/м[³3]|Вт/м[²2]|мкг/м[³3]|"
    r"м/с[²2]|кг|мм|см|м\.?|г|с|мин|ч|раз|ед\.?|%)(?:\s*\)|\s*)$",
    re.IGNORECASE,
)


def _unit_from_caption(name: str) -> str:
    found = _UNIT_SUFFIX.search(name)
    return found.group(1) if found else ""


def _word_contains_vibration_unit(word: Path | None) -> bool:
    """Verify the paired Word protocol's original table heading, not a guess."""
    if word is None or not word.is_file() or word.suffix.casefold() != ".docx":
        return False
    try:
        with ZipFile(word) as archive:
            xml = archive.read("word/document.xml")
        root = ET.fromstring(xml)
        ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
        for paragraph in root.findall(".//w:p", ns):
            text = "".join(node.text or "" for node in paragraph.findall(".//w:t", ns))
            if re.search(r"Уровень\s+виброускорения\s*,\s*дБ\b", text, re.IGNORECASE):
                return True
    except (BadZipFile, KeyError, OSError, ET.ParseError, ValueError):
        pass
    return False


def _protocol_methods(doc: ET.Element) -> tuple[str, ...]:
    return tuple(dict.fromkeys(
        attr(node, "name")
        for node in doc.findall("./nd_data/nd")
        if attr(node, "action") == "1" and attr(node, "name")
    ))



def _confirmed_oa_method(catalog: ResourceCatalog | None,
                         method_name: str, factor_id: str) -> str:
    """Exact original ND/factor -> DIC_ND_INFO.dop5, never fuzzy matching."""
    if catalog is None or not method_name or not factor_id:
        return ""
    candidates = [
        nd for nd in catalog.normative
        if nd.factor_id == factor_id and
        nd.name.strip().casefold() == method_name.strip().casefold()
    ]
    if len(candidates) != 1:
        return ""
    # The original source_snapshot also strips the numeric FGIS component.
    return re.sub(r"\{\s*\d+\s*\}", "", candidates[0].oa_method).strip()


def _measurements(
    doc: ET.Element, *, word: Path | None = None,
    catalog: ResourceCatalog | None = None,
    ini: Path | None = None,
) -> tuple[list[tuple[str, str, str, str, str]], list[str]]:
    """Selected original results only: no calculator inputs or empty headings."""
    factor = doc.find("./factor")
    facid = attr(factor, "facid")
    original_methods = _protocol_methods(doc)
    notes = []
    word_unit = facid in ("7", "8") and _word_contains_vibration_unit(word)
    unit_resolver = OriginalUnits(doc, ini)
    if facid == "4":
        nodes = doc.findall("./izm_data/Level")
    elif facid == "8":
        # Both actual corrected levels and equivalent axis results are
        # present in the original protocol. Zone and param headings are skipped.
        nodes = doc.findall("./izm_data/zone") + doc.findall("./izm_data/zone/param")
    else:
        nodes = doc.findall("./izm_data/zone/param")
        if not nodes:
            nodes = doc.findall("./izm_data/Level")
        if not nodes:
            nodes = doc.findall("./measurements/measurement")
    if len(original_methods) > 1:
        notes.append("несколько методик: привязка каждой к показателю не подтверждена")
    rows = []
    group = ""
    position_unit = ""
    for node in nodes:
        fact = attr(node, "fact", "value", "result")
        if not fact and not list(node):
            fact = literal(node.text)
        name = attr(node, "name", "indicator_name", "param_name",
                    "caption", "title", "label", "izm_name")
        if not fact:
            if facid == "8" and node.tag == "param" and name:
                group = name.rstrip(":").strip()
            if facid == "13" and attr(node, "bm") == "bm_5" and re.search(
                    r",\s*%\s*смены\s*$", name, re.IGNORECASE):
                position_unit = "% смены"
            # Known but empty measurement slots are blank, while headings are not results.
            if (facid in ("8", "13") or not name or
                    not any(key in node.attrib for key in ("fact", "value", "result"))):
                continue
        if not name:
            notes.append("есть значение без оригинального наименования")
        if facid == "8" and node.tag == "param" and group and name.upper().startswith("ОСЬ "):
            # Both pieces are explicitly present in this same XML section.
            name = group + " — " + name
        unit = attr(node, "unit", "unit_name", "ed_izm",
                    "edizm", "units", "measurement_unit", "unit_text")
        if not unit:
            unit = _unit_from_caption(name)
        if not unit and word_unit and facid == "8":
            unit = "дБ"  # Directly verified in this record's paired Word DOCX.
        if not unit and facid == "13" and position_unit and attr(node, "bm").startswith("bm_5_"):
            unit = position_unit  # Literally written in this XML group's heading.
        unit = unit_resolver.display(node, unit, facid=facid,
                                     vibration_confirmed=bool(word_unit and (fact or name)))
        method = attr(node, "method_name", "method")
        if not method:
            nd_ref = attr(node, "nd_izm1")
            if nd_ref:
                matched = tuple(dict.fromkeys(
                    attr(nd, "name") for nd in doc.findall("./nd_data/nd")
                    if attr(nd, "id") == nd_ref and attr(nd, "action") == "1"
                    and attr(nd, "name")
                ))
                if len(matched) == 1:
                    method = matched[0]
            if not method and len(original_methods) == 1:
                method = original_methods[0]
        technique = attr(node, "oa_method", "method_oa")
        if not technique:
            technique = _confirmed_oa_method(catalog, method, facid)
        rows.append((
            name,
            fact,
            unit,
            method,
            technique,
        ))
    return rows, notes


def _address(customer: CustomerSettings) -> tuple[str, str]:
    """Excel address selection from original STRUCT_ORG, not XML/FГИС guesses."""
    first_address, second_address = customer.source_address1, customer.source_address2
    if first_address is None and second_address is None:
        address = customer.address
        kind = customer.address_type
    else:
        first_address = (first_address or "").strip()
        second_address = (second_address or "").strip()
        if first_address and second_address:
            address, kind = second_address, "Адрес места осуществления деятельности"
        elif first_address:
            address, kind = first_address, "Адрес места нахождения"
        else:
            address, kind = second_address, ""
    if customer.customer_kind == 4:
        kind = "Адрес места жительства"
    return address, kind


def _source_attr(node: ET.Element | None, *names: str) -> str:
    """Known element but empty attribute is an empty cell, not 'НЕТ ДАННЫХ'."""
    return attr(node, *names) if node is not None else ""


def _object_name(doc: ET.Element | None, item: dict) -> str:
    """Same exact full name in chooser and Excel."""
    factor = doc.find("./factor") if doc is not None else None
    obj = doc.find("./object") if doc is not None else None
    nodes = tuple(n for n in (obj, doc, factor) if n is not None)
    return (first(nodes, "object_name", "full_name_object", "factor_name") or
            str(item.get("factor_name") or "")).strip()


def list_excel_object_names(database: Path, *, xml_root: Path | None = None,
                            docx_root: Path | None = None) -> tuple[str, ...]:
    """List unique object names actually present in project source records."""
    _, items, _ = read_inventory(Path(database), xml_root=xml_root, docx_root=docx_root)
    names: set[str] = set()
    for item in items:
        doc = None
        path = item.get("xml")
        if path is not None and Path(path).is_file():
            try:
                original = parse_xml(Path(path))
                candidate = original if original.tag == "Document" else original.find(".//Document")
                factor = candidate.find("./factor") if candidate is not None else None
                if (factor is not None and attr(factor, "facid") == str(item["factor_id"])
                    and (not attr(candidate, "rm_id")
                         or attr(candidate, "rm_id") == str(item["rm_id"]))):
                    doc = candidate
            except (FsaSourceError, OSError, ValueError):
                pass
        names.add(_object_name(doc, item))
    return tuple(sorted(names, key=lambda name: (not bool(name), name.casefold(), name)))


def _shared(doc: ET.Element | None, item: dict,
            customer: CustomerSettings) -> tuple[str, ...]:
    factor = doc.find("./factor") if doc is not None else None
    object_node = doc.find("./object") if doc is not None else None
    nodes = tuple(node for node in (object_node, doc, factor) if node is not None)
    address, address_type = _address(customer)
    object_name = _object_name(doc, item)
    return (
        _source_attr(doc, "num_doc"),
        _source_attr(factor, "start_date", "date_begin", "izm_date"),
        _source_attr(factor, "end_date", "date_end", "izm_date"),
        _source_attr(doc, "fill_date", "sign_date"),
        customer.full_name or customer.fio,
        address_type,
        address,
        customer.inn,
        customer.ogrn,
        "Производственная среда",  # original VBA TypeObjectId=10
        object_name,
    )


def _additional(doc: ET.Element | None, customer: CustomerSettings,
                catalog: ResourceCatalog | None,
                warnings: list[str] | None = None, context: str = "") -> tuple[str, ...]:
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
        joined(contacts),
        customer.application_date,
        normative,
        first(nodes, "sample_receive_date", "received_date"),
        first(nodes, "sample_count", "samples_count"),
        first(nodes, "sample_date", "sampling_date"),
        first(nodes, "sample_place", "sampling_place", "sampling_address"),
        _equipment(factor, catalog, warnings, context),
        _people(factor, catalog, "./persons/pers"),
        _people(factor, catalog, "./exp_persons/pers"),
        (_people(factor, catalog, "./boss/pers")
         if factor is not None and factor.findall("./boss/pers")
         else _people(factor, catalog, "./boss")),
    )


def prepare_excel_sources(database: Path, resources: Path, ini: Path | None,
                          customer: CustomerSettings,
                          selected_objects: frozenset[str] | None = None,
                          *, xml_root: Path | None = None,
                          docx_root: Path | None = None) -> ExcelSourceBatch:
    """Keep every protocol, even if its factor/ND/resource has no FGIS mapping."""
    # The optional INI affects FGIS ID transformations, not raw Excel.
    _, items, _ = read_inventory(Path(database), xml_root=xml_root, docx_root=docx_root)
    if not items:
        raise FsaSourceError("В рабочей MDB нет протоколов для Excel")
    warnings = []
    if customer.customer_kind not in (1, 2, 4):
        warnings.append(
            "Тип заказчика не указан в исходных данных. "
            "Тип адреса физического лица без подтверждения не определяется."
        )
    try:
        catalog = ResourceCatalog.from_mdb(Path(resources))
    except (FsaSourceError, OSError, ValueError) as exc:
        catalog = None
        warnings.append("Справочник оборудования и сотрудников: " + str(exc))
    result = []
    indicators = 0
    accepted = 0
    for index, item in enumerate(items, 1):
        context = f"Протокол {index}, РМ {item['rm_id']}, фактор {item['factor_id']}"
        doc = None
        protocol_warnings = []
        path = item.get("xml")
        if path is None or not Path(path).is_file():
            protocol_warnings.append(context + ": отсутствует исходный XML; строка сохранена")
        else:
            try:
                original = parse_xml(Path(path))
                doc = original if original.tag == "Document" else original.find(".//Document")
                if doc is None:
                    protocol_warnings.append(context + ": нет Document; строка сохранена")
                else:
                    factor = doc.find("./factor")
                    if factor is None or attr(factor, "facid") != str(item["factor_id"]):
                        protocol_warnings.append(context + ": фактор в XML не совпадает с MDB")
                        doc = None
                    elif attr(doc, "rm_id") and attr(doc, "rm_id") != str(item["rm_id"]):
                        protocol_warnings.append(context + ": идентификатор рабочего места не совпадает")
                        doc = None
            except (FsaSourceError, OSError, ValueError) as exc:
                protocol_warnings.append(context + ": XML не прочитан: " + str(exc))
        if selected_objects is not None and _object_name(doc, item) not in selected_objects:
            continue
        warnings.extend(protocol_warnings)
        accepted += 1
        measurements, notes = (
            _measurements(doc, word=Path(item["word"]) if item.get("word") else None,
                          catalog=catalog, ini=ini)
            if doc is not None else ([], [])
        )
        warnings.extend(context + ": " + note for note in notes)
        if not measurements:
            warnings.append(context + ": измеренные значения в исходном XML не установлены")
            measurements = [("",) * 5]
        else:
            indicators += len(measurements)
        shared = _shared(doc, item, customer)
        extra = _additional(doc, customer, catalog, warnings, context)
        if len(shared) != 11 or len(extra) != 11:
            raise FsaSourceError("Нарушена структура 27 столбцов Excel")
        for i, measurement in enumerate(measurements):
            result.append((shared if i == 0 else ("",) * 11) + measurement
                          + (extra if i == 0 else ("",) * 11))
    if len(result) > 65535:
        raise FsaSourceError("В формате XLS не более 65 535 строк данных")
    if not accepted:
        raise FsaSourceError("Для выбранных наименований объекта нет протоколов")
    return ExcelSourceBatch(accepted, tuple(result), indicators,
                            tuple(dict.fromkeys(warnings)))
