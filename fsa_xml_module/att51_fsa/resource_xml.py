"""Resolve resource references from original individual/summary protocol XML.

Original VBA:
  v52_exp_fgis_ra.get_xml_data/get_xml_data_sv,
  get_PERS_data/get_ND_data and v5_res_main.get_si_by_num.

Only performs source analysis. Report results may contain personnel names;
keep local, never automatically upload the report to a public repository.
"""
from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable
from xml.etree import ElementTree as ET

from .resources import NdResolution, ResourceCatalog, ResourceResolution, nd_hash
from .sources import FsaSourceError, parse_xml


@dataclass(frozen=True)
class NormativeAudit:
    source_name: str
    source_action: str
    source_id: str
    match_rule: str
    matched_name: str
    matched_guid: str
    method_doc_id: str
    method_preference: str
    warnings: tuple[str, ...]


@dataclass(frozen=True)
class ProtocolResourceAudit:
    protocol_number: str
    factor_id: str
    kind: str
    fgis_state: str
    status: str
    equipment: tuple[ResourceResolution, ...]
    people: tuple[tuple[str, ResourceResolution], ...]
    normative: tuple[NormativeAudit, ...]
    warnings: tuple[str, ...]
    errors: tuple[str, ...]


def _document(root: ET.Element) -> ET.Element:
    if root.tag == "Document":
        return root
    doc = root.find(".//Document")
    if doc is None:
        raise FsaSourceError("Document element missing")
    return doc


def _groups(document: ET.Element, summary: bool) -> ET.Element | None:
    return document.find("./info" if summary else "./factor")


def _device_references(context: ET.Element,
                       *, extra_os: bool, extra_devices: bool) -> Iterable[ET.Element]:
    # The original VBA branches over si_guids, si_guids_os and si_guids_dop.
    yield from context.findall("./si_guids/si_guid")
    if extra_os:
        yield from context.findall("./si_guids_os/si_guid")
    if extra_devices:
        yield from context.findall("./si_guids_dop/si_guid")


def _people_references(document: ET.Element, context: ET.Element, summary: bool):
    for node in context.findall("./persons/pers"):
        yield "izm", node
    for node in context.findall("./exp_persons/pers"):
        yield "exp", node
    if summary:
        boss = context.find("./boss")
        if boss is not None:
            yield "boss", boss
    elif document.get("type") == "protocol2019":
        for node in context.findall("./boss/pers"):
            yield "boss", node
    else:
        boss = context.find("./boss")
        if boss is not None:
            yield "boss", boss


def _assessment_nds(context: ET.Element) -> list[ET.Element]:
    all_nds = context.findall("./nd_data/nd")
    eligible: list[ET.Element] = []
    for item in all_nds:
        action = item.get("action", "")
        # Source: If nd_action = "0" Or (not_izm And nd_action <> "1")
        if action == "0" or ("изм" not in action.lower() and action != "1"):
            eligible.append(item)
    if not eligible and len(all_nds) == 1:
        eligible.append(all_nds[0])
    return eligible


def inspect_protocol_resources(root: ET.Element, catalog: ResourceCatalog, *,
                               summary: bool = False, include_secondary: bool = False,
                               include_additional: bool = False) -> ProtocolResourceAudit:
    document = _document(root)
    number = document.get("num_doc", "")
    state = document.get("fgis_state", "") if not summary else ""
    factor_id = (document.get("fac_id", "") if summary
                 else (document.find("factor").get("facid", "")
                       if document.find("factor") is not None else ""))
    if summary and factor_id == "950":
        factor_id = "9"
    kind = "summary" if summary else "individual"
    if state == "1":
        return ProtocolResourceAudit(number, factor_id, kind, state,
                                     "excluded_by_fgis_state", (), (), (), (), ())
    ctx = _groups(document, summary)
    if ctx is None:
        raise FsaSourceError("Protocol missing original factor/info node")
    equipment: list[ResourceResolution] = []
    people: list[tuple[str, ResourceResolution]] = []
    normative: list[NormativeAudit] = []
    warnings: list[str] = []
    errors: list[str] = []

    if state != "2":
        for device in _device_references(
            ctx, extra_os=include_secondary, extra_devices=include_additional
        ):
            result = catalog.device(device.get("guid", ""), device.get("num", ""))
            equipment.append(result)
            if not result.found:
                warnings.append("device_not_found")
            elif not result.fgis_id or result.fgis_id == "0":
                warnings.append("equipment_fgis_id_missing")
    for role, item in _people_references(document, ctx, summary):
        result = catalog.person(item.get("guid", ""), item.get("snils", ""))
        people.append((role, result))
        if not result.found:
            warnings.append("person_not_found")
        elif not result.fgis_id or result.fgis_id == "0":
            warnings.append("person_fgis_id_missing")

    for item in _assessment_nds(ctx):
        original = item.get("name", "")
        # get_nd_hash occurs in v52_exp_fgis_ra.AddDistinctNdData.
        # del_bad_chars can alter text before hashing in original VBA; the
        # exact transformation still needs a separate verified port.
        result = catalog.nd(nd_hash(original), original, factor_id)
        details = catalog.nd_diagnostics(result, item.get("action", ""))
        if "fatal_nd_absent" in details or "fatal_nd_short_name_missing" in details:
            errors.extend(code for code in details if code.startswith("fatal_"))
        warnings.extend(code for code in details if not code.startswith("fatal_"))
        found = result.normative
        normative.append(NormativeAudit(
            source_name=original,
            source_action=item.get("action", ""),
            source_id=item.get("id", ""),
            match_rule=result.source_rule,
            matched_name=found.name if found else "",
            matched_guid=found.guid if found else "",
            method_doc_id=found.method_doc_id if found else "",
            method_preference=found.preference if found else "",
            warnings=details,
        ))
    if "FGIS_RA" in catalog.diagnostics.tables_absent:
        warnings.append("fgis_link_table_missing_in_resource_mdb")
    if "DIC_ND_INFO" in catalog.diagnostics.tables_absent:
        warnings.append("normative_extension_table_missing_in_resource_mdb")
    return ProtocolResourceAudit(
        number, factor_id, kind, state,
        "requires_correction" if errors else "read_only_inspection_complete",
        tuple(equipment), tuple(people), tuple(normative),
        tuple(dict.fromkeys(warnings)), tuple(dict.fromkeys(errors)),
    )


def inspect_protocol_resources_file(path: Path, catalog: ResourceCatalog, **options):
    return inspect_protocol_resources(parse_xml(Path(path)), catalog, **options)


def inspection_dict(audit: ProtocolResourceAudit) -> dict:
    """Diagnostic fields only, not a valid FSA XML mapping."""
    result = asdict(audit)
    result["not_exportable"] = True
    return result
