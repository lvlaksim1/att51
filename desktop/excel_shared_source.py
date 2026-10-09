"""The Excel view of the SAME accepted, source-preserving XML preparation.

No independent indicator discovery. All rows correspond one-to-one, in order,
with PreparedProtocol.protocol.research_objects selected by the XML pipeline.
FGIS reference numbers NEVER become Excel labels.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from xml.etree import ElementTree as ET

from att51_fsa.export_2025 import CustomerSettings, PreparedProtocol, prepare_protocol
from att51_fsa.labour_2025 import LabourOptions
from att51_fsa.aerosol_2025 import ChemicalOptions
from att51_fsa.pipeline_2025 import FieldTrace, Original2025Options
from att51_fsa.resources import ResourceCatalog
from att51_fsa.sources import FsaSourceError, parse_xml

from whole_base_reports import read_inventory


MISSING = "НЕТ ДАННЫХ"
_ID = re.compile(r"\|\|\s*id\s+\d+\s*\|\|", re.IGNORECASE)
_OA_CODE = re.compile(r"\{\s*\d+\s*\}")


def _raw(value: object) -> str:
    return _ID.sub("", str(value)).strip() if value is not None else ""


def _cell(value: object) -> str:
    return _raw(value) or MISSING


def _label(value: object) -> str:
    # Categorical labels must not silently turn into numeric source/FGIS IDs.
    text = _raw(value)
    return text if text and not text.isdecimal() else MISSING


def _all(values) -> str:
    seen = []
    for value in values:
        text = _raw(value)
        if text and text not in seen:
            seen.append(text)
    return "; ".join(seen)


def _attr(node: ET.Element | None, *keys: str) -> str:
    if node is None:
        return ""
    attributes = {str(k).casefold(): v for k, v in node.attrib.items()}
    return next((_raw(attributes[k.casefold()]) for k in keys
                 if _raw(attributes.get(k.casefold()))), "")


def _first(nodes, *keys: str) -> str:
    return next((val for node in nodes if (val := _attr(node, *keys))), "")


def _source_node(doc: ET.Element, trace: FieldTrace) -> ET.Element | None:
    if not trace.source_xpath:
        return None
    path = trace.source_xpath.removeprefix("Document/")
    if not path or path.startswith("/") or ".." in path:
        return None
    try:
        return doc.find("./" + path)
    except SyntaxError:
        return None


def _names_by_role(doc: ET.Element, catalog: ResourceCatalog) -> dict[str, str]:
    """Use persons in source protocol, resolved to original ATT_PERSON.FIO."""
    factor = doc.find("./factor")
    found: dict[str, list[str]] = {"izm": [], "exp": [], "boss": []}
    if factor is None:
        return {}
    sources = (
        ("izm", factor.findall("./persons/pers")),
        ("exp", factor.findall("./exp_persons/pers")),
        ("boss", factor.findall("./boss/pers") or
         ([factor.find("./boss")] if factor.find("./boss") is not None else [])),
    )
    for role, nodes in sources:
        for node in nodes:
            if node is None:
                continue
            original = _attr(node, "fio", "name")
            if not original:
                match = catalog.person(_attr(node, "guid"), _attr(node, "snils"))
                if match.found:
                    profile = next((p for p in catalog.people if p.guid == match.local_guid),
                                   None)
                    original = (profile.fio or " ".join(filter(None,
                                (profile.surname, profile.given_name,
                                 profile.patronymic)))) if profile else ""
            if original:
                found[role].append(original)
    return {role: _all(names) for role, names in found.items()}


def _equipment_names(doc: ET.Element, catalog: ResourceCatalog) -> str:
    factor = doc.find("./factor")
    if factor is None:
        return ""
    result = []
    for node in factor.findall("./si_guids/si_guid"):
        # In source XML guid and num are lookup keys, not displayed FGIS IDs.
        item = catalog.device(_attr(node, "guid"), _attr(node, "num"))
        if item.found:
            device = next((p for p in catalog.devices if p.guid == item.local_guid),
                          None)
            if device is not None:
                name = _raw(device.name)
                factory = _raw(device.factory_number)
                if name:
                    result.append(name + (" № " + factory if factory else ""))
    return _all(result)


def _textual_oa(value: str) -> str:
    """OA method ID is encoded in braces; strip the ID, keep source wording."""
    value = _raw(_OA_CODE.sub("", value))
    return value if not value.isdecimal() else ""


def _indicator(doc: ET.Element, trace: FieldTrace) -> list[str]:
    assert trace.prepared is not None and trace.source_draft is not None
    raw_node = _source_node(doc, trace)
    name = (
        _raw(trace.source_draft.chemical_name)
        or _attr(raw_node, "name", "indicator_name", "param_name",
                 "caption", "title", "label", "izm_name")
        or _raw(trace.prepared.unique_indicator)
    )
    unit = _attr(raw_node, "unit", "unit_name", "ed_izm",
                 "edizm", "units", "measurement_unit", "unit_text")
    method = _textual_oa(trace.original_oa_method)
    # The FGIS code field is NEVER used as a textual fallback.
    return [
        _label(name),
        _cell(trace.prepared.fact_value),
        _label(unit),
        _label(trace.original_method_name or trace.prepared.unique_method),
        _label(method),
    ]


def prepared_protocol_rows(root: ET.Element, result: PreparedProtocol,
                           catalog: ResourceCatalog, customer: CustomerSettings) -> list[list[str]]:
    protocol = result.protocol
    if protocol is None:
        raise FsaSourceError("Невозможно выгрузить неподготовленный протокол")
    doc = root if root.tag == "Document" else root.find(".//Document")
    if doc is None:
        raise FsaSourceError("Отсутствует исходный Document")
    traces = result.source_traces
    if len(traces) != len(protocol.research_objects):
        raise FsaSourceError("Несовпадение количества подготовленных показателей XML/Excel")
    factor = doc.find("./factor")
    additional = doc.find("./dop_info")
    org = doc.find("./customer")
    object_node = doc.find("./object")
    roles = _names_by_role(doc, catalog)
    nds = doc.findall("./nd_data/nd")
    nd_names = _all(node.get("name", "") for node in nds)
    shared = [
        _cell(protocol.doc_id),
        _cell(protocol.start_date),
        _cell(protocol.validity_date),
        _cell(protocol.creation_date),
        _cell(customer.full_name or customer.fio),
        _label(_first((org, object_node, additional, doc),
                      "address_type", "addr_type")),
        _cell(_first((object_node, additional, doc),
                     "address", "measurement_address", "addr", "address_text")),
        _cell(customer.inn),
        _label(_first((object_node, doc), "object_type_name", "object_type")),
        _cell(_first((object_node, doc, factor),
                     "object_name", "full_name_object", "factor_name")
              or protocol.object_name),
    ]
    source_contacts = [
        _first((org, additional, doc), "contacts", "phone", "telephone", "email")
    ]
    for contact in doc.findall(".//contact"):
        source_contacts.append(_attr(contact, "value", "phone", "email", "address")
                               or _raw(contact.text))
    trailing = [
        _cell(_all(source_contacts)),
        _cell(customer.application_date),
        _cell(nd_names),
        _cell(_first((additional, doc),
                     "sample_receive_date", "received_date")),
        _cell(_first((additional, doc), "sample_count", "samples_count")),
        _cell(_first((additional, doc), "sample_date", "sampling_date")),
        _cell(_first((additional, doc),
                     "sample_place", "sampling_place", "sampling_address")),
        _cell(_equipment_names(doc, catalog)),
        _cell(roles.get("izm")),
        _cell(roles.get("exp")),
        _cell(roles.get("boss")),
    ]
    if len(shared) != 10 or len(trailing) != 11:
        raise AssertionError("Неверная структура шаблона Excel A–Z")
    return [
        (shared if pos == 0 else [""] * 10)
        + _indicator(doc, trace)
        + (trailing if pos == 0 else [""] * 11)
        for pos, trace in enumerate(traces)
    ]


def build_shared_excel_rows(
    database: Path, resources: Path, ini: Path | None, customer: CustomerSettings,
    *, labour: LabourOptions | None = None,
    chemical: ChemicalOptions | None = None,
) -> tuple[list[list[str]], int, int]:
    """Execute XML's own preparation; Excel has no second indicator selector."""
    if customer.validate():
        raise FsaSourceError("; ".join(customer.validate()))
    _workplaces, items, _root = read_inventory(Path(database))
    if not items:
        raise FsaSourceError("Нет протоколов в рабочей MDB")
    catalog = ResourceCatalog.from_mdb(Path(resources))
    options = Original2025Options(
        labour=labour or LabourOptions(),
        chemical=chemical or ChemicalOptions(),
    )
    rows: list[list[str]] = []
    errors: list[str] = []
    seen = set()
    for index, item in enumerate(items, 1):
        linked = item["xml"]
        label = f"Протокол {index}"
        if linked is None or not linked.is_file():
            errors.append(label + ": отсутствует связанный исходный XML")
            continue
        try:
            original = parse_xml(linked)
            doc = original if original.tag == "Document" else original.find(".//Document")
            factor = doc.find("./factor") if doc is not None else None
            if factor is None or factor.get("facid", "") != item["factor_id"]:
                errors.append(label + ": фактор исходного XML и MDB не совпадает")
                continue
            proposal = prepare_protocol(original, catalog, customer, options=options,
                                        working_ini=Path(ini) if ini else None)
            if proposal.blockers or proposal.protocol is None:
                errors.append(label + ": " + "; ".join(proposal.blockers))
                continue
            key = (proposal.protocol.doc_id, proposal.protocol.creation_date)
            if key in seen:
                errors.append(label + ": повторение номера и даты протокола")
            seen.add(key)
            rows.extend(prepared_protocol_rows(original, proposal, catalog, customer))
        except (FsaSourceError, ValueError, OSError) as exc:
            errors.append(label + ": " + str(exc))
    if errors:
        raise FsaSourceError(
            "Excel не сформирован: неподготовленные протоколы:\n" +
            "\n".join("- " + error for error in errors)
        )
    if len(rows) > 65535:
        raise FsaSourceError("В формате XLS не более 65 535 строк данных.")
    return rows, len(items), len(rows)
