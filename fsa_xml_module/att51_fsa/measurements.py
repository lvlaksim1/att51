"""Original ATT51 2025 measured-value mapping: bounded, verifiable subset.

Read directly from v52_exp_fgis_ra2025.bas:
  get_ResearchObjects2025, read_ekv_shum_param, get_ekv_shum_unc,
  get_num, get_digits.
These classes are intermediate values ONLY. They are not complete FSA protocols,
and never trigger real submission/export.
"""
from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Iterable
from xml.etree import ElementTree as ET

from .sources import FsaSourceError, parse_xml


@dataclass(frozen=True)
class NoiseOptions:
    """Original v52_exp_fgis_ra form checkbox meanings, supplied explicitly.

    acoustic_measurements -> chk_akkust_izm
    both_measurements_and_equivalent -> chk_akkust_izm2
    acoustic_level_per_operation -> chk_akkust_ekv_oper
    include_uncertainty -> chk_izm_u095
    """
    acoustic_measurements: bool
    both_measurements_and_equivalent: bool
    acoustic_level_per_operation: bool
    include_uncertainty: bool


@dataclass(frozen=True)
class ResearchObjectDraft:
    indicator_id: str
    directory: str
    fact_value: str
    measurement_id: str
    source_xpath: str
    nd_izm1: str = ""
    indicator_id_2: str = ""
    chemical_id: str = ""
    chemical_name: str = ""

    def as_dict(self) -> dict[str, str]:
        return asdict(self)


def original_get_num(value: str) -> str:
    """get_num in v52_exp_fgis_ra2025: preserve any string with ASCII digit.

    Deliberately DOES NOT convert comma decimal separators, normalize ranges
    or discard a '<' sign. The original returns the whole input unchanged.
    """
    return value if any(char in "1234567890" for char in value) else ""


def _first_document(root: ET.Element) -> ET.Element:
    if root.tag == "Document":
        return root
    document = root.find(".//Document")
    if document is None:
        raise FsaSourceError("Internal protocol XML does not contain Document")
    return document


def map_noise_equivalent(root: ET.Element, options: NoiseOptions) -> list[ResearchObjectDraft]:
    """Exact branch and ID selection of original read_ekv_shum_param (2025).

    This mapper only extracts intermediate research objects. It does NOT
    implement subsequent get_DocNameId, get_param, method/ND matching or the
    final ResearchObjectInfo serializer.
    """
    document = _first_document(root)
    factor = document.find("factor")
    if factor is None or factor.get("facid") != "4":
        raise FsaSourceError("Noise mapper only accepts factor facid='4'")
    results: list[ResearchObjectDraft] = []

    if options.acoustic_measurements:
        # Original: //Document/izm_res_data/izm, level vs levels with fallback.
        for index, item in enumerate(document.findall("./izm_res_data/izm"), 1):
            if options.acoustic_level_per_operation:
                fact = item.get("level", "")
            else:
                fact = item.get("levels", "")
            if fact == "":
                fact = item.get("level", "")
            fact = original_get_num(fact)
            if fact == "":
                continue
            if options.acoustic_level_per_operation and options.include_uncertainty:
                uncertainty = item.get("unc", "")
                if uncertainty != "":
                    fact += "\u00b1" + uncertainty
            results.append(ResearchObjectDraft(
                indicator_id="9", directory="1", fact_value=fact,
                measurement_id="650", nd_izm1=item.get("nd_izm1", ""),
                source_xpath=f"Document/izm_res_data/izm[{index}]",
            ))

    # Original: include Lekv unless BOTH chk_akkust_izm and chk_akkust_izm2.
    if not (options.acoustic_measurements and options.both_measurements_and_equivalent):
        lekv = document.find("./izm_data/Level[@bm='Lekv']")
        if lekv is not None:
            fact = original_get_num(lekv.get("fact", ""))
            if fact:
                if options.include_uncertainty:
                    unc = document.get("U8h", "")
                    if original_get_num(unc):
                        fact += "\u00b1" + unc
                results.append(ResearchObjectDraft(
                    indicator_id="3472", directory="1", indicator_id_2="281",
                    fact_value=fact, measurement_id="650",
                    nd_izm1=lekv.get("nd_izm1", ""),
                    source_xpath="Document/izm_data/Level[@bm='Lekv']",
                ))
    return results


def extract_noise_from_file(path, options: NoiseOptions) -> list[ResearchObjectDraft]:
    return map_noise_equivalent(parse_xml(path), options)


def map_infrasound_equivalent(root: ET.Element, options: NoiseOptions) -> list[ResearchObjectDraft]:
    """Original read_ekv_infr_param: acoustic vs equivalent (facid 5).

    Shares the original UI switches with noise but uses different FGIS codes.
    """
    document = _first_document(root)
    factor = document.find("factor")
    if factor is None or factor.get("facid") != "5":
        raise FsaSourceError("Infrasound mapper only accepts factor facid='5'")
    result: list[ResearchObjectDraft] = []
    if options.acoustic_measurements:
        for index, item in enumerate(document.findall("./izm_res_data/izm"), 1):
            fact = item.get("level", "") if options.acoustic_level_per_operation else item.get("levels", "")
            if fact == "":
                fact = item.get("level", "")
            fact = original_get_num(fact)
            if fact:
                if options.acoustic_level_per_operation and options.include_uncertainty:
                    unc = item.get("unc", "")
                    if unc:
                        fact += "\u00b1" + unc
                result.append(ResearchObjectDraft(
                    indicator_id="10", directory="1", measurement_id="429",
                    fact_value=fact, nd_izm1=item.get("nd_izm1", ""),
                    source_xpath=f"Document/izm_res_data/izm[{index}]",
                ))
    if not (options.acoustic_measurements and options.both_measurements_and_equivalent):
        lekv = document.find("./izm_data/Level[@bm='Lekv']")
        if lekv is not None:
            fact = original_get_num(lekv.get("fact", ""))
            if fact:
                if options.include_uncertainty:
                    unc = document.get("U8h", "")
                    if original_get_num(unc):
                        fact += "\u00b1" + unc
                result.append(ResearchObjectDraft(
                    indicator_id="131616", directory="2", measurement_id="429",
                    fact_value=fact, nd_izm1=lekv.get("nd_izm1", ""),
                    source_xpath="Document/izm_data/Level[@bm='Lekv']",
                ))
    return result


@dataclass(frozen=True)
class LightingOptions:
    include_uncertainty: bool


def map_lighting_2025(root: ET.Element, options: LightingOptions) -> list[ResearchObjectDraft]:
    """Original read_osv_params: light (osv) and light pulsation (puls).

    Unlike conventional numeric parsing, the original preserves fact strings
    containing digits, and appends U095 only when checkbox is enabled.
    """
    document = _first_document(root)
    factor = document.find("factor")
    if factor is None or factor.get("facid") != "12":
        raise FsaSourceError("Lighting mapper only accepts factor facid='12'")
    result: list[ResearchObjectDraft] = []
    for index, item in enumerate(document.findall("./izm_data/zone/param"), 1):
        bm = item.get("bm", "")
        fact = original_get_num(item.get("fact", ""))
        if not fact:
            continue
        unc = item.get("U095", "")
        if options.include_uncertainty and original_get_num(unc):
            fact_with_unc = fact + "\u00b1" + unc
        else:
            fact_with_unc = fact
        if "osv" in bm:
            result.append(ResearchObjectDraft(
                indicator_id="16", directory="1", measurement_id="64",
                fact_value=fact_with_unc,
                nd_izm1=item.get("nd_izm1", ""),
                source_xpath=f"Document/izm_data/zone/param[{index}]",
            ))
        if "puls" in bm:
            # Original code uses two consecutive If blocks; the second may
            # append U095 a second time if bm matches BOTH substrings.
            pulse_value = fact_with_unc
            if "osv" in bm and options.include_uncertainty and original_get_num(unc):
                pulse_value += "\u00b1" + unc
            result.append(ResearchObjectDraft(
                indicator_id="3520", directory="1", measurement_id="292",
                fact_value=pulse_value, nd_izm1=item.get("nd_izm1", ""),
                source_xpath=f"Document/izm_data/zone/param[{index}]",
            ))
    return result


@dataclass(frozen=True)
class MicroclimateOptions:
    """Original form flags: chk_izm_micro_results, chk_izm_u095, chk_micro_exp_doze."""
    use_result_values: bool
    include_uncertainty: bool
    include_exposure_dose: bool


def map_microclimate_2025(root: ET.Element, options: MicroclimateOptions) -> list[ResearchObjectDraft]:
    """Exact read_micro_params branch dispatch (factor 11).

    The original distinguishes "result" and "results", maps the last of
    these present, and adds U095 only when no result override is requested.
    """
    document = _first_document(root)
    factor = document.find("factor")
    if factor is None or factor.get("facid") != "11":
        raise FsaSourceError("Microclimate mapper only accepts factor facid='11'")
    mappings = (
        ("t_", "3", "1", "61"),
        ("skor_", "5", "1", "90"),
        ("vl_", "4", "1", "292"),
        ("tns_", "122114", "2", "61"),
        ("tepl", "122794", "2", "532"),
        ("doza", "131478", "2", "50"),
    )
    values: list[ResearchObjectDraft] = []
    for index, node in enumerate(document.findall("./izm_data/zone/param"), 1):
        bm = node.get("bm", "")
        fact = original_get_num(node.get("fact", ""))
        if options.use_result_values:
            result = original_get_num(node.get("results", node.get("result", "")))
            if result:
                fact = result
        if not fact:
            continue
        mapping = next((v for v in mappings if bm.startswith(v[0])), None)
        if mapping is None:
            continue
        _, indicator, directory, measurement = mapping
        if bm.startswith("doza") and not options.include_exposure_dose:
            continue
        if not options.use_result_values and options.include_uncertainty:
            unc = node.get("U095", "")
            if original_get_num(unc):
                fact += "\u00b1" + unc
        values.append(ResearchObjectDraft(
            indicator_id=indicator, directory=directory, fact_value=fact,
            measurement_id=measurement, nd_izm1=node.get("nd_izm1", ""),
            source_xpath=f"Document/izm_data/zone/param[{index}]",
        ))
    return values


def map_aeroions_2025(root: ET.Element) -> list[ResearchObjectDraft]:
    """Original read_aeroion_params (factor 10099).

    The original adds the raw fact, including empty/non-numeric values;
    unlike most other factor branches there is no get_num check here.
    """
    document = _first_document(root)
    factor = document.find("factor")
    if factor is None or factor.get("facid") != "10099":
        raise FsaSourceError("Aeroion mapper only accepts facid='10099'")
    results: list[ResearchObjectDraft] = []
    for index, node in enumerate(document.findall("./izm_data/zone/param"), 1):
        bm = node.get("bm", "")
        indicator = "3650" if bm.startswith("n_plus") else (
            "129637" if bm.startswith("n_minus") else ""
        )
        if indicator:
            results.append(ResearchObjectDraft(
                indicator_id=indicator, directory="2", measurement_id="1091",
                fact_value=node.get("fact", ""),
                nd_izm1=node.get("nd_izm1", ""),
                source_xpath=f"Document/izm_data/zone/param[{index}]",
            ))
    return results


def map_ultrasound_2025(root: ET.Element, options: NoiseOptions) -> list[ResearchObjectDraft]:
    """Original read_ultr_params (factor 6): 2019 and legacy paths.

    The original protocol2019 can return separate parameters, an equivalent
    level, or both. Legacy protocol always reads zone param rows.
    """
    document = _first_document(root)
    factor = document.find("factor")
    if factor is None or factor.get("facid") != "6":
        raise FsaSourceError("Ultrasound mapper only accepts facid='6'")
    newer = document.get("type", "") == "protocol2019"
    searches: list[tuple[str, str, str, list[ET.Element]]] = []
    if not newer or options.acoustic_measurements:
        searches.append(("param", "11", "1", document.findall("./izm_data/zone/param")))
    if newer and not (options.acoustic_measurements and options.both_measurements_and_equivalent):
        searches.append(("equivalent", "152610", "2", document.findall("./itog_data/Level")))
    values: list[ResearchObjectDraft] = []
    for source_type, indicator_id, directory, nodes in searches:
        for index, node in enumerate(nodes, 1):
            fact = node.get("fact", "")
            if source_type == "param" and not options.acoustic_level_per_operation:
                if node.get("result", ""):
                    fact = node.get("result", "")
            fact = original_get_num(fact)
            if not fact or fact == "0":
                continue
            if options.include_uncertainty:
                uncertainty = node.get("unc", "")
                if original_get_num(uncertainty):
                    fact += "\u00b1" + uncertainty
            values.append(ResearchObjectDraft(
                indicator_id=indicator_id, directory=directory, measurement_id="429",
                fact_value=fact, nd_izm1=node.get("nd_izm1", ""),
                source_xpath=(
                    f"Document/izm_data/zone/param[{index}]" if source_type == "param"
                    else f"Document/itog_data/Level[{index}]"
                ),
            ))
    return values
