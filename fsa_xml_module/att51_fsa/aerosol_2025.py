"""ATT51 original 2025 aerosol/chemical factor measurement extraction.

Port of v52_exp_fgis_ra2025.read_him_params and optional SS/MAX helpers.
Both factor 1 and factor 3 call the same original routine; production mapping
is enabled for factor 3 only until factor 1 is separately assessed.
All values and substance names are from source XML / explicit original INI.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from xml.etree import ElementTree as ET

from .measurements import ResearchObjectDraft
from .sources import FsaSourceError, read_ini


@dataclass(frozen=True)
class ChemicalOptions:
    include_uncertainty: bool = False          # chk_izm_u095
    use_detailed_results: bool = False         # chk_izm_him_ed_izm
    include_shift_average: bool = False        # chk_izm_him_kss
    include_maximum: bool = False              # chk_izm_him_kmax
    omit_point_measurements: bool = False      # chk_izm_him_no_points


def original_him_id(bm: str) -> str:
    """get_him_id_by_bm, VBA 621-635."""
    if "_" in bm:
        return bm.split("_", 1)[1]
    if bm.startswith(("kcss", "kmax")):
        return bm[4:]
    return bm


def original_him_name(value: str) -> str:
    """format_him_ra, VBA 3069-3079."""
    if "мг/м" not in value:
        return value
    value = value.split("мг/м", 1)[0].strip()
    return value[:-1] if value.endswith((".", ",")) else value


def _indicator(him_id: str, ini: Path | None) -> tuple[str, str]:
    if ini is not None:
        mapped = read_ini(Path(ini), "dic_soot1025", him_id)
        if re.fullmatch(r"[12]~[1-9]\d*", mapped):
            directory, indicator = mapped.split("~", 1)
            return indicator, directory
        if mapped:
            # Invalid original mapping is not silently replaced by generic 66.
            raise FsaSourceError("Неверное сопоставление химического вещества: "
                                 + repr(him_id))
    return "66", "1"


def _doc(root: ET.Element) -> ET.Element:
    doc = root if root.tag == "Document" else root.find(".//Document")
    if doc is None:
        raise FsaSourceError("Нет Document во внутреннем XML")
    factor = doc.find("factor")
    if factor is None or factor.get("facid") != "3":
        raise FsaSourceError("Алгоритм АПФД допускает только facid=3")
    return doc


def map_aerosol_2025(root: ET.Element, options: ChemicalOptions,
                     *, working_ini: Path | None = None) -> list[ResearchObjectDraft]:
    """Preserve original base->shift-average->maximum merge order."""
    doc = _doc(root)
    direct: list[ResearchObjectDraft] = []
    direct_by_substance: dict[str, str] = {}

    def add(fact: str, bm: str, name: str, nd: str, unc: str,
            source: str, *, alternate: str = "",
            base: bool = False) -> ResearchObjectDraft | None:
        if fact in ("", "-"):
            return None
        if options.include_uncertainty and any(ch.isdigit() for ch in unc):
            fact += "\u00b1" + unc
        # In original VBA the detailed "results" overwrites the U95 fact,
        # including any appended uncertainty.
        if base and options.use_detailed_results and alternate:
            fact = alternate
        him = original_him_id(bm)
        code, directory = _indicator(him, working_ini)
        return ResearchObjectDraft(
            indicator_id=code, directory=directory, fact_value=fact,
            measurement_id="533", source_xpath=source, nd_izm1=nd,
            indicator_id_2="66", chemical_id=him,
            chemical_name=original_him_name(name),
        )

    for i, node in enumerate(doc.findall("./izm_data/zone/param"), 1):
        bm = node.get("bm", "")
        if not re.match(r"^ko[0-9]", bm):
            continue
        alt = node.get("results", "") or node.get("result", "")
        item = add(node.get("fact", ""), bm, node.get("name", ""),
                   node.get("nd_izm1", ""), node.get("U095", ""),
                   f"Document/izm_data/zone/param[{i}]", alternate=alt, base=True)
        if item is not None:
            direct.append(item)
            direct_by_substance.setdefault(item.chemical_id, item.nd_izm1)
    result = [] if options.omit_point_measurements else list(direct)
    if options.include_shift_average:
        for i, node in enumerate(doc.findall("./izm_data/itog/param"), 1):
            bm = node.get("bm", "")
            if not re.match(r"^kcss[0-9]", bm):
                continue
            him = original_him_id(bm)
            item = add(node.get("fact", ""), bm, node.get("name", ""),
                       direct_by_substance.get(him, ""), node.get("U095", ""),
                       f"Document/izm_data/itog/param[{i}]")
            if item is not None:
                result.append(item)
    if options.include_maximum and doc.get("type", "") == "protocol2019":
        for i, node in enumerate(doc.findall("./izm_data2/kut_results/param"), 1):
            bm = node.get("bm_id", "")
            if not re.match(r"^him_kut_id[0-9]", bm):
                continue
            him = bm[len("him_kut_id"):]
            # MAX uses the identifier from bm_id, not read_him_params' bm.
            item = add(node.get("Cmax", ""), "ko1_"+him,
                       node.get("name", ""), direct_by_substance.get(him, ""),
                       node.get("CmaxUNC", ""),
                       f"Document/izm_data2/kut_results/param[{i}]")
            if item is not None:
                result.append(item)
    return result
