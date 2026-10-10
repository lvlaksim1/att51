"""Original protocol labels retained by the common FGIS preparation step.

This module is used by prepare_protocol BEFORE either output serializer. It
reads original ATT51 Document and original ResourceCatalog, not a generated
FGIS XML. The output modules are not allowed to rediscover data themselves.
"""
from __future__ import annotations

from dataclasses import dataclass
import re
from typing import TYPE_CHECKING
from xml.etree import ElementTree as ET

if TYPE_CHECKING:
    from .export_2025 import CustomerSettings
    from .pipeline_2025 import FieldTrace
    from .resource_xml import ProtocolResourceAudit
    from .resources import ResourceCatalog
    from .writer import Protocol


EMPTY = "НЕТ ДАННЫХ"
_ID_TOKEN = re.compile(r"\s*\|\|\s*id\s+\d+\s*\|\|", re.IGNORECASE)
_BRACKET_ID = re.compile(r"\{\s*\d+\s*\}")


@dataclass(frozen=True)
class SourceSnapshot:
    """Original text, ordered independently of either serialization format.

    shared: general values A-J; measurements: one five-value tuple per
    accepted FGIS ResearchObjectInfo; additional: common values P-Z.
    """
    shared: tuple[str, ...]
    measurements: tuple[tuple[str, str, str, str, str], ...]
    additional: tuple[str, ...]


def literal(value: object) -> str:
    if value is None:
        return ""
    return _ID_TOKEN.sub("", str(value)).strip()


def value_or_missing(value: object) -> str:
    return literal(value) or EMPTY


def word_or_missing(value: object) -> str:
    text = literal(value)
    # Numeric codes do not prove a human-readable category.
    return text if text and not text.isdecimal() else EMPTY


def joined(values) -> str:
    result: list[str] = []
    for value in values:
        text = literal(value)
        if text and text not in result:
            result.append(text)
    return "; ".join(result)


def attr(node: ET.Element | None, *names: str) -> str:
    if node is None:
        return ""
    attrs = {str(k).casefold(): v for k, v in node.attrib.items()}
    return next((literal(attrs[name.casefold()]) for name in names
                 if literal(attrs.get(name.casefold()))), "")


def first(nodes, *names: str) -> str:
    return next((found for node in nodes if (found := attr(node, *names))), "")


def source_element(doc: ET.Element, xpath: str) -> ET.Element | None:
    if not xpath.startswith("Document/"):
        return None
    relative = xpath[len("Document/"):]
    # Some original mappings use composite descriptions instead of a real XPath.
    if ".." in relative or "/@" in relative or "+" in relative:
        return None
    try:
        return doc.find("./" + relative)
    except SyntaxError:
        return None


def _people(audit: ProtocolResourceAudit, catalog: ResourceCatalog) -> dict[str, str]:
    grouped = {"izm": [], "exp": [], "boss": []}
    for role, resolved in audit.people:
        person = next((p for p in catalog.people if p.guid == resolved.local_guid), None)
        if not person:
            continue
        name = person.fio or " ".join(p for p in (person.surname, person.given_name,
                                                person.patronymic) if p)
        if name:
            grouped.setdefault(role, []).append(name)
    return {role: joined(names) for role, names in grouped.items()}


def _devices(audit: ProtocolResourceAudit, catalog: ResourceCatalog) -> str:
    names = []
    for resolved in audit.equipment:
        item = next((d for d in catalog.devices if d.guid == resolved.local_guid), None)
        if item is None or not item.name:
            continue
        text = item.name
        if item.factory_number:
            text += " № " + item.factory_number
        names.append(text)
    return joined(names)


def _unit(node: ET.Element | None, trace: FieldTrace, facid: str) -> str:
    """Use only original explicit textual units; never infer from FGIS IDs.

    No guesses from factor, measurement code or indicator captions.
    """
    original = attr(node, "unit", "unit_name", "ed_izm", "edizm",
                    "units", "measurement_unit", "unit_text")
    return original if original and not original.isdecimal() else ""


def snapshot_for_protocol(
    doc: ET.Element, protocol: Protocol, traces: tuple[FieldTrace, ...],
    audit: ProtocolResourceAudit, catalog: ResourceCatalog,
    customer: CustomerSettings,
) -> SourceSnapshot:
    """Gather original labels at the shared preparation boundary."""
    if len(traces) != len(protocol.research_objects):
        raise ValueError("Количество исходных показателей не соответствует XML")
    factor = doc.find("./factor")
    facid = factor.get("facid", "") if factor is not None else ""
    additional = doc.find("./dop_info")
    customer_node = doc.find("./customer")
    object_node = doc.find("./object")
    role = _people(audit, catalog)
    norms = joined(n.get("name", "") for n in doc.findall("./nd_data/nd"))
    contacts = [customer.contacts]
    contacts.append(first((customer_node, additional, doc),
                          "contact", "contacts", "phone", "telephone", "email"))
    contacts.extend(attr(node, "value", "phone", "email", "address") or literal(node.text)
                    for node in doc.findall(".//contact"))

    # Address is chosen from verified STRUCT_ORG fields by the user BEFORE
    # this function. It is never inferred from unrelated internal XML.
    shared = (
        value_or_missing(protocol.doc_id),
        value_or_missing(protocol.start_date),
        value_or_missing(protocol.validity_date),
        value_or_missing(protocol.creation_date),
        value_or_missing(customer.full_name or customer.fio),
        word_or_missing(customer.address_type),
        value_or_missing(customer.address),
        value_or_missing(customer.inn),
        word_or_missing(first((object_node, doc),
                              "object_type_name", "object_type")),
        value_or_missing(first((object_node, doc, factor),
                               "object_name", "full_name_object", "factor_name")
                         or protocol.object_name),
    )
    fields = []
    for trace in traces:
        draft = trace.source_draft
        if draft is None or trace.prepared is None:
            raise ValueError("Исходное измерение отсутствует в трассе XML")
        node = source_element(doc, trace.source_xpath)
        indicator_name = (
            literal(draft.chemical_name)
            or attr(node, "name", "indicator_name", "param_name",
                    "caption", "title", "label", "izm_name")
            or literal(trace.prepared.unique_indicator)
        )
        oa = literal(_BRACKET_ID.sub("", trace.original_oa_method))
        fields.append((
            word_or_missing(indicator_name),
            value_or_missing(trace.prepared.fact_value),
            word_or_missing(_unit(node, trace, facid)),
            word_or_missing(trace.original_method_name or trace.prepared.unique_method),
            word_or_missing(oa),
        ))
    extra = (
        value_or_missing(joined(contacts)),
        value_or_missing(protocol.application_date),
        value_or_missing(norms),
        value_or_missing(first((additional, doc),
                               "sample_receive_date", "received_date")),
        value_or_missing(first((additional, doc),
                               "sample_count", "samples_count")),
        value_or_missing(first((additional, doc),
                               "sample_date", "sampling_date")),
        value_or_missing(first((additional, doc),
                               "sample_place", "sampling_place", "sampling_address")),
        value_or_missing(_devices(audit, catalog)),
        value_or_missing(role.get("izm")),
        value_or_missing(role.get("exp")),
        value_or_missing(role.get("boss")),
    )
    if len(shared) != 10 or len(extra) != 11:
        raise AssertionError("Нарушено количество подготовленных общих полей")
    return SourceSnapshot(shared, tuple(fields), extra)
