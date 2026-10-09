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
