"""Independent, read-only stage: original ATT51 sidecar -> FGIS intermediate values.

Combines source XPaths, resource MDB method matching and ResearchObjectInfo
field preparation. DOES NOT construct a complete FSA XML for submission.
"""
from __future__ import annotations
from dataclasses import asdict, dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

from .measurements import (
    MicroclimateOptions, NoiseOptions, ResearchObjectDraft,
    map_aeroions_2025, map_infrasound_equivalent, map_lighting_2025,
    map_microclimate_2025, map_noise_equivalent, map_ultrasound_2025,
    LightingOptions,
)
from .methods import (
    MethodCandidate, ResearchForMethod, bind_methods_from_catalog,
)
from .research_objects import (
    PreparedResearchObject, ResearchOverrides,
    load_working_overrides, prepare_research_object,
)
from .resource_xml import inspect_protocol_resources
from .resources import ResourceCatalog
from .sources import FsaSourceError, parse_xml


@dataclass(frozen=True)
class Original2025Options:
    """Explicit options from the original v52_exp_fgis_ra form."""
    acoustic_measurements: bool = False
    both_measurements_and_equivalent: bool = False
    acoustic_level_per_operation: bool = False
    include_uncertainty: bool = False
    micro_use_result_values: bool = False
    micro_include_exposure_dose: bool = False


@dataclass(frozen=True)
class FieldTrace:
    source_xpath: str
    indicator_id: str
    result_status: str
    method_rule: str
    method_id: str
    prepared: PreparedResearchObject | None
    warnings: tuple[str, ...]
    errors: tuple[str, ...]


@dataclass(frozen=True)
class Protocol2025Diagnostic:
    number: str
    factor_id: str
    supported: bool
    mode: str
    status: str
    resource_warnings: tuple[str, ...]
    resource_errors: tuple[str, ...]
    measurement_traces: tuple[FieldTrace, ...]
    errors: tuple[str, ...]
    not_exportable: bool = True


SUPPORTED_FACTORS = frozenset(("4", "5", "6", "11", "12", "10099"))


def _doc(root: ET.Element) -> ET.Element:
    if root.tag == "Document":
        return root
    node = root.find(".//Document")
    if node is None:
        raise FsaSourceError("Missing original Document element")
    return node


def _original_methods(doc: ET.Element) -> tuple[MethodCandidate, ...]:
    """Original v52_exp_fgis_ra2025.AddNDData: method NDs only.

    nd_action == '1' OR action containing 'изм' except action == '0'.
    Values here are unresolved; FGIS metadata come from ResourceCatalog.
    """
    result: list[MethodCandidate] = []
    for node in doc.findall("./nd_data/nd"):
        action = node.get("action", "")
        is_izm = "изм" in action.lower()
        if action == "1" or (is_izm and action != "0"):
            result.append(MethodCandidate(
                nd_izm1=node.get("id", ""), doc_name_id="",
                doc_name=node.get("name", ""),
            ))
    return tuple(result)


def map_supported_2025(doc: ET.Element, options: Original2025Options) -> list[ResearchObjectDraft]:
    factor = doc.find("factor")
    if factor is None:
        raise FsaSourceError("Missing original factor data")
    facid = factor.get("facid", "")
    acoustic = NoiseOptions(
        options.acoustic_measurements,
        options.both_measurements_and_equivalent,
        options.acoustic_level_per_operation,
        options.include_uncertainty,
    )
    if facid == "4":
        return map_noise_equivalent(doc, acoustic)
    if facid == "5":
        return map_infrasound_equivalent(doc, acoustic)
    if facid == "6":
        return map_ultrasound_2025(doc, acoustic)
    if facid == "11":
        return map_microclimate_2025(doc, MicroclimateOptions(
            options.micro_use_result_values,
            options.include_uncertainty,
            options.micro_include_exposure_dose,
        ))
    if facid == "12":
        return map_lighting_2025(doc, LightingOptions(options.include_uncertainty))
    if facid == "10099":
        return map_aeroions_2025(doc)
    raise FsaSourceError("Factor has no verified 2025 measurement mapping: " + facid)


def analyze_2025(
    root: ET.Element,
    catalog: ResourceCatalog,
    options: Original2025Options,
    *,
    working_fgis_ini: Path | None = None,
) -> Protocol2025Diagnostic:
    """Compose confirmed source stages without enabling working file output."""
    document = _doc(root)
    fac_node = document.find("factor")
    factor = fac_node.get("facid", "") if fac_node is not None else ""
    number = document.get("num_doc", "")
    if factor not in SUPPORTED_FACTORS:
        return Protocol2025Diagnostic(
            number, factor, False, "individual", "unsupported_factor",
            (), (), (), ("factor_not_yet_implemented",),
        )

    original_resources = inspect_protocol_resources(document, catalog)
    if original_resources.status == "excluded_by_fgis_state":
        return Protocol2025Diagnostic(
            number, factor, True, "individual", "excluded_by_fgis_state",
            (), (), (), (),
        )
    methods = _original_methods(document)
    drafts = map_supported_2025(document, options)
    all_errors: list[str] = list(original_resources.errors)
    traces: list[FieldTrace] = []
    for draft in drafts:
        value = ResearchForMethod(
            indicator_id=draft.indicator_id,
            indicator_id_2=draft.indicator_id_2,
            nd_izm1=draft.nd_izm1,
        )
        selected = bind_methods_from_catalog(value, methods, catalog, factor_id=factor)
        warnings = list(selected.source_errors)
        if working_fgis_ini is None:
            # Caller explicitly has not supplied possible original indicator
            # overrides. A successful-looking mapping must not conceal it.
            warnings.append("working_fgis_ra_ini_not_supplied")
            overrides = ResearchOverrides()
        else:
            overrides = load_working_overrides(
                draft, selected.selected, Path(working_fgis_ini)
            )
        prepared = prepare_research_object(draft, selected.selected, overrides)
        errors = list(prepared.errors)
        errors.extend(selected.source_errors)
        traces.append(FieldTrace(
            draft.source_xpath, draft.indicator_id, prepared.status,
            selected.selected.source_rule, selected.selected.doc_name_id,
            prepared.value, tuple(dict.fromkeys(warnings + list(prepared.warnings))),
            tuple(dict.fromkeys(errors)),
        ))
        all_errors.extend(errors)
    if not drafts:
        all_errors.append("no_supported_measurements_in_protocol")
    if not methods:
        all_errors.append("no_original_measurement_methods")
    return Protocol2025Diagnostic(
        number=number, factor_id=factor, supported=True, mode="individual",
        status=("requires_correction" if all_errors else
                "intermediate_mapping_complete_not_working_xml"),
        resource_warnings=original_resources.warnings,
        resource_errors=original_resources.errors,
        measurement_traces=tuple(traces),
        errors=tuple(dict.fromkeys(all_errors)),
    )


def analyze_2025_file(path: Path, resources_mdb: Path,
                      options: Original2025Options, *,
                      working_fgis_ini: Path | None = None) -> Protocol2025Diagnostic:
    """Read working sources without changing Word/Access or creating any output."""
    root = parse_xml(path)
    catalog = ResourceCatalog.from_mdb(resources_mdb)
    return analyze_2025(root, catalog, options, working_fgis_ini=working_fgis_ini)


def diagnostic_dict(result: Protocol2025Diagnostic) -> dict:
    return asdict(result)
