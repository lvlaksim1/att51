"""Original ATT51 2025 ResearchObjectInfo transformation (isolated XML subset).

Evidence: v52_exp_fgis_ra.save_XML, get_dic_name, get_method_oa_id,
v52_exp_fgis_ra_dic.get_user_izm_param, v5_options_dic.GetOAMethod.

Every result retains the original measurement and the selected ND rule.
No working XML is issued by this module: the whole protocol still requires
unimplemented factor variants, personnel, addresses, settings and validation.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from xml.etree import ElementTree as ET

from .measurements import ResearchObjectDraft
from .methods import MethodResolution
from .sources import FsaSourceError, read_ini


_DIRECTORY = {"1": "DM-53535", "2": "DM-55254"}


def original_directory_name(directory: str) -> str:
    """get_dic_name: 'Unknown' is original fallback, but cannot be trusted."""
    return _DIRECTORY.get(directory, "Unknown")


# Verified subset of v52_exp_fgis_ra.get_param_from_indicator.
# The original contains many additional factor-specific IDs; unknown IDs
# do not receive fabricated method tags.
_OA_PARAMETER_TAGS = {
    "3": "temp", "4": "vlag", "5": "skor", "122114": "tns",
    "122794": "tepl", "131478": "doza",
    "9": "shum_izm", "281": "shum_ekv",
    "10": "infr_izm", "131616": "infr_ekv",
    "16": "svet_osv", "3520": "svet_Kp",
    "13": "vibr_gen_izm", "2367": "vibr_gen_izm",
    "144614": "vibr_gen_ekv", "14": "vibr_loc_izm",
    "156886": "vibr_loc_ekv",
}


def original_oa_parameter_tag(draft: ResearchObjectDraft, *,
                              indicator_id_4: str = "",
                              him_id: str = "") -> str:
    """OA per-indicator tag as in get_param_from_indicator."""
    indicator = indicator_id_4 or draft.indicator_id
    result = _OA_PARAMETER_TAGS.get(indicator, "")
    if not result and draft.indicator_id_2 == "66" and him_id:
        return "him_id" + him_id
    return result


def original_oa_method_id(value: str) -> str:
    """get_method_oa_id reads first pair of braces and tests VB Val > 0."""
    left, right = value.find("{"), value.find("}")
    if left < 0 or right < 0 or left >= right:
        return ""
    between = value[left + 1:right].strip()
    match = re.match(r"^\s*\+?([0-9]+(?:\.[0-9]*)?)", between)
    return between if match and float(match.group(1)) > 0 else ""


@dataclass(frozen=True)
class ResearchOverrides:
    """Exact original UI and FGIS settings, given explicitly by caller.

    user_indicator_mapping is get_user_izm_param(original_directory~id);
    the latter is stored in program dictionaries and may be -1 to exclude.
    The method-specific overrides are read separately from working fgis_ra.ini.
    """
    force_unique_indicator: bool = False
    unique_indicator_name: str = ""
    user_indicator_mapping: str = ""
    no_change_indicator_id: bool = False
    measurement_override: str = ""
    method_indicator_override: str = ""
    measurement_comment: str = ""
    preferred_oa_method: str = ""


@dataclass(frozen=True)
class PreparedResearchObject:
    indicator_id: str
    unique_indicator: str
    directory: str
    fact_value: str
    measurement_id: str
    doc_name_id: str
    unique_method: str
    oa_method_id: str
    unique_methodik: str
    unique_measurement: str
    source_xpath: str
    method_source_rule: str
    warnings: tuple[str, ...] = ()


@dataclass(frozen=True)
class ResearchPreparation:
    value: PreparedResearchObject | None
    status: str
    warnings: tuple[str, ...] = ()
    errors: tuple[str, ...] = ()
    not_exportable: bool = True


def _mapped_code(source: str, *, label: str) -> tuple[str, str]:
    """Parse directory~indicator; original checks Like '*#~#*' for overrides.

    The strict parser prevents false-looking IDs; the UI may allow extra
    symbols, but such scenarios are not confirmed safe for independent use.
    """
    if not re.fullmatch(r"[12]~[0-9]+", source):
        raise FsaSourceError(f"Invalid {label}: {source!r} (expected 1~ID or 2~ID)")
    return tuple(source.split("~", 1))  # type: ignore[return-value]


def load_working_overrides(
    draft: ResearchObjectDraft, method: MethodResolution, ini_path: Path,
    *,
    chemical_id: str = "", force_unique_indicator: bool = False,
    unique_indicator_name: str = "", user_indicator_mapping: str = "",
    no_change_indicator_id: bool = False,
    measurement_comment: str = "",
    preferred_oa_method: str = "",
) -> ResearchOverrides:
    """Load exact fgis_ra.ini keys for this measurement/method.

    Original: Measurements/id<Directory>_<IndicatorId>,
      vars_fiz<Directory>~<IndicatorId>/<DocNameId>,
      vars<chemical_id>/<DocNameId> when IndicatorId2=66.
    No global or imaginary defaults; absent INI means no local overrides.
    """
    p = Path(ini_path)
    if not p.is_file():
        raise FsaSourceError(f"Working FGIS settings file missing: {p}")
    measurement_id = read_ini(p, "Measurements", f"id{draft.directory}_{draft.indicator_id}")
    original_key = f"{draft.directory}~{draft.indicator_id}"
    if draft.indicator_id_2 == "66":
        if not chemical_id:
            raise FsaSourceError("Chemical-specific override requires original him_id")
        section = "vars" + chemical_id
    else:
        section = "vars_fiz" + original_key
    mapped = read_ini(p, section, method.doc_name_id) if method.doc_name_id else ""
    # Original applies method override only if Like '*#~#*'; unsupported data
    # will be ignored as in the VBA. Reject malformed patterns containing ~.
    if "~" in mapped and not re.fullmatch(r"[12]~[0-9]+", mapped):
        raise FsaSourceError(f"Malformed method-specific FGIS mapping: {section}")
    if mapped and "~" not in mapped:
        mapped = ""
    return ResearchOverrides(
        force_unique_indicator=force_unique_indicator,
        unique_indicator_name=unique_indicator_name,
        user_indicator_mapping=user_indicator_mapping,
        no_change_indicator_id=no_change_indicator_id,
        measurement_override=measurement_id,
        method_indicator_override=mapped,
        measurement_comment=measurement_comment,
        preferred_oa_method=preferred_oa_method,
    )


def prepare_research_object(
    draft: ResearchObjectDraft,
    method: MethodResolution,
    overrides: ResearchOverrides,
    *,
    allow_unmapped_oa: bool = False,
) -> ResearchPreparation:
    """Prepare exactly ordered schema fields; preserve original source values.

    If an input is impossible to corroborate (unknown directory, missing OA
    method, unmapped ND) return explicit diagnostics, not a fabricated ID.
    """
    if method.doc_name_id == "-1" or overrides.user_indicator_mapping == "-1":
        return ResearchPreparation(None, "excluded_by_original_rule",
                                   warnings=("original_exclusion_marker",))
    if not draft.fact_value:
        return ResearchPreparation(None, "no_measurement",
                                   warnings=("empty_fact_value",))
    errors: list[str] = []
    warnings: list[str] = []
    if method.requires_review:
        warnings.append("method_requires_review")
    if overrides.force_unique_indicator:
        indicator = ""
        unique_indicator = (overrides.unique_indicator_name or
                            (draft.chemical_name if draft.indicator_id_2 == "66" else ""))
        directory = ""
        if not unique_indicator:
            errors.append("unique_indicator_name_missing")
    else:
        indicator = draft.indicator_id
        orig_directory = draft.directory
        if overrides.user_indicator_mapping and not overrides.no_change_indicator_id:
            try:
                orig_directory, indicator = _mapped_code(
                    overrides.user_indicator_mapping, label="user indicator mapping"
                )
            except FsaSourceError:
                errors.append("invalid_user_indicator_mapping")
        if overrides.method_indicator_override:
            try:
                orig_directory, indicator = _mapped_code(
                    overrides.method_indicator_override, label="method mapping"
                )
            except FsaSourceError:
                errors.append("invalid_method_indicator_mapping")
        directory = original_directory_name(orig_directory)
        # In original save_XML lines 1909-1938 the chemical substance name
        # is used ONLY if chk_UniqueIndicator=True. With a numeric code,
        # the original explicitly serializes UniqueIndicator as empty.
        unique_indicator = ""
        if directory == "Unknown":
            errors.append("unknown_original_directory")
    if method.doc_name_id and method.doc_name_id not in ("0", "-1"):
        doc_name_id = method.doc_name_id
        unique_method = ""
    else:
        doc_name_id = ""
        unique_method = method.doc_name
        if not unique_method:
            errors.append("missing_measurement_method")
    oa = overrides.preferred_oa_method or method.oa_method
    oa_method_id = original_oa_method_id(oa)
    unique_methodik = "" if oa_method_id else oa
    if not oa:
        errors.append("accreditation_method_missing")
    if not overrides.measurement_override and not draft.measurement_id:
        errors.append("measurement_id_missing")
    if errors:
        return ResearchPreparation(None, "requires_correction",
                                   tuple(dict.fromkeys(warnings)),
                                   tuple(dict.fromkeys(errors)))
    if unique_indicator == "Неизвестный показатель" and not allow_unmapped_oa:
        # No inventing parameter names for production-like diagnostics.
        return ResearchPreparation(None, "requires_correction",
                                   tuple(dict.fromkeys(warnings)),
                                   ("unique_indicator_name_unavailable",))
    prepared = PreparedResearchObject(
        indicator_id=indicator, unique_indicator=unique_indicator,
        directory=directory, fact_value=draft.fact_value,
        measurement_id=overrides.measurement_override or draft.measurement_id,
        doc_name_id=doc_name_id, unique_method=unique_method,
        oa_method_id=oa_method_id, unique_methodik=unique_methodik,
        unique_measurement=overrides.measurement_comment,
        source_xpath=draft.source_xpath,
        method_source_rule=method.source_rule,
        warnings=tuple(dict.fromkeys(warnings)),
    )
    return ResearchPreparation(prepared, "prepared_for_synthetic_protocol_only",
                               tuple(dict.fromkeys(warnings)))


def append_research_objects(object_info: ET.Element,
                            values: tuple[PreparedResearchObject, ...]) -> None:
    """Emit XSD sequence identical to original save_XML 2025 branch."""
    if not values:
        return
    group = ET.SubElement(object_info, "ResearchObject")
    for value in values:
        node = ET.SubElement(group, "ResearchObjectInfo")
        pairs = [
            ("IndicatorId", value.indicator_id),
            ("UniqueIndicator", value.unique_indicator),
            ("Directory", value.directory),
            ("FactValue", value.fact_value),
            ("MeasurementId", value.measurement_id),
        ]
        if value.unique_measurement:
            pairs.append(("UniqueMeasurement", value.unique_measurement))
        pairs.append(("DocNameId", value.doc_name_id))
        if value.unique_method:
            pairs.append(("UniqueMethod", value.unique_method))
        if value.oa_method_id:
            pairs.append(("DocNameMethodikId", value.oa_method_id))
        else:
            pairs.append(("UniqueMethodik", value.unique_methodik))
        for key, data in pairs:
            element = ET.SubElement(node, key)
            element.text = data
