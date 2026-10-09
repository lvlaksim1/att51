"""XSD-oriented final serializer, isolated from the original Word runtime.

The serializer accepts fully mapped protocol values. Supplying such values from
real ATT51 sources is a separate, not-yet-complete transformation stage.
"""
from __future__ import annotations

import base64
from dataclasses import dataclass, field
from pathlib import Path
from xml.etree import ElementTree as ET


@dataclass(frozen=True)
class Protocol:
    doc_id: str
    creation_date: str
    start_date: str
    validity_date: str
    application_date: str
    customer_kind: int
    object_type: int
    object_name: str
    data_status: str = "20"
    protocol_status: str = "6"
    inn: str = ""
    ogrn: str = ""
    equipment_ids: tuple[str, ...] = ()
    no_equipment: bool = False
    method_doc_ids: tuple[str, ...] = ()
    attachment: Path | None = None


def _node(parent: ET.Element, name: str, value: object) -> ET.Element:
    return ET.SubElement(parent, name, text=None) if False else _text(parent, name, value)


def _text(parent: ET.Element, name: str, value: object) -> ET.Element:
    element = ET.SubElement(parent, name)
    element.text = str(value)
    return element


def _validate_required(item: Protocol) -> None:
    for label, value in (
        ("DocId", item.doc_id),
        ("DocCreationDate", item.creation_date),
        ("DocStartDate", item.start_date),
        ("DocValidityDate", item.validity_date),
        ("ApplicationDate", item.application_date),
        ("FullNameObject", item.object_name),
    ):
        if not value:
            raise ValueError(f"Missing mandatory field: {label}")
    for key, value in (("DataStatusId", item.data_status),
                       ("ProtocolStatusId", item.protocol_status)):
        if not str(value).isdigit():
            raise ValueError(f"{key} must be an integer for the original XSD; got {value!r}")


def serialize_protocols(protocols: list[Protocol], *, limit: int = 100) -> list[bytes]:
    """Build original root/protocol structure, split like save_btn_Click.

    This is only the supported field subset: do not call it a complete FSA
    export until per-factor ResearchObject and address/person maps are ported.
    """
    if not 1 <= limit <= 100:
        raise ValueError("Original fileProtocolLoad_v4.xsd allows 1..100 protocols per file")
    if not protocols:
        raise ValueError("No protocols")
    outputs: list[bytes] = []
    for index in range(0, len(protocols), limit):
        root = ET.Element("root")
        for p in protocols[index:index + limit]:
            _validate_required(p)
            entry = ET.SubElement(root, "protocol")
            _text(entry, "DocId", p.doc_id)
            _text(entry, "DocCreationDate", p.creation_date)
            _text(entry, "DocStartDate", p.start_date)
            _text(entry, "DocValidityDate", p.validity_date)
            _text(entry, "DataStatusId", p.data_status)
            _text(entry, "ProtocolStatusId", p.protocol_status)
            if p.attachment:
                attached = Path(p.attachment)
                if attached.suffix.lower() not in (".docx", ".pdf"):
                    raise ValueError(f"Unsupported original document attachment: {attached}")
                scan = ET.SubElement(entry, "ProtocolScan")
                _text(scan, "Extension", attached.suffix.lower().lstrip("."))
                _text(scan, "FileName", attached.stem)
                _text(scan, "Content", base64.b64encode(attached.read_bytes()).decode("ascii"))
            _text(entry, "TerritoryFeature", "true")
            _text(entry, "ApplicationDate", p.application_date)
            customer = ET.SubElement(entry, "Customer")
            _text(customer, "CustomerKindId", p.customer_kind)
            if p.inn:
                _text(customer, "InnId", p.inn)
            if p.ogrn:
                _text(customer, "OgrnId", p.ogrn)
            _text(entry, "AccredScope353", "false")
            _text(entry, "NoEquipmentInfo", str(p.no_equipment).lower())
            if p.equipment_ids:
                eq = ET.SubElement(entry, "Equipment")
                for equipment_id in p.equipment_ids:
                    _text(ET.SubElement(eq, "EquipmentDetails"), "EquipmentId", equipment_id)
            obj = ET.SubElement(entry, "ObjectInfo")
            _text(obj, "TypeObjectId", p.object_type)
            for nd_id in p.method_doc_ids:
                _text(obj, "MethodDocId", nd_id)
            _text(obj, "FullNameObject", p.object_name)
            _text(obj, "IsLab", "false")
            _text(obj, "IsAnotherDoc", "false")
        outputs.append(ET.tostring(root, encoding="utf-8", xml_declaration=True))
    return outputs


def validate_xml(xml: bytes, schema: Path) -> tuple[bool, str]:
    """Validate against unchanged ATT51 fileProtocolLoad_v4.xsd.

    On Windows, MSXML 6.0 is used, matching the original VBA mechanism.
    On development Linux, lxml can provide schema validation for tests.
    """
    if not Path(schema).is_file():
        raise FileNotFoundError(schema)
    import os
    if os.name == "nt":
        try:
            import win32com.client
        except ImportError as exc:
            raise RuntimeError("pywin32 is required for original MSXML validation") from exc
        cache = win32com.client.Dispatch("MSXML2.XMLSchemaCache.6.0")
        cache.add("", str(Path(schema).resolve()))
        document = win32com.client.Dispatch("MSXML2.DOMDocument.6.0")
        document.async = False
        document.validateOnParse = False
        if not document.loadXML(xml.decode("utf-8")):
            return False, str(document.parseError.reason)
        document.schemas = cache
        error = document.validate()
        return error.errorCode == 0, str(error.reason) if error.errorCode else ""
    try:
        from lxml import etree
    except ImportError as exc:
        raise RuntimeError("lxml is required for development-time XSD validation on non-Windows") from exc
    validator = etree.XMLSchema(etree.parse(str(schema)))
    root = etree.fromstring(xml)
    valid = validator.validate(root)
    return valid, "" if valid else str(validator.error_log.last_error)
