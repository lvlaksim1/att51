"""Original Attestation51 VBA MeasurementId logic for Excel source results.

Only factor/indicator branches already verified against original
v52_exp_fgis_ra2025 are used. XML value extraction remains independent.
An ID is attached only if its textual label has corroboration in VBA.
"""
from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree as ET
import re

from att51_fsa.labour_2025 import LabourOptions, map_labour_2025
from att51_fsa.measurements import (
    LightingOptions, MicroclimateOptions, NoiseOptions,
    map_noise_equivalent, map_infrasound_equivalent,
    map_lighting_2025, map_microclimate_2025,
    map_aeroions_2025, map_ultrasound_2025,
)
from att51_fsa.sources import read_ini


# Text checked against the original VBA's literal MeasurementId comments.
# Deliberately exclude 559 (conflicting comments), 985 and 987 (no verified
# unit caption). This is NOT an inferred all-FGIS reference dictionary.
ORIGINAL_UNIT_LABELS = {
    "4": "Метр", "5": "Километр", "35": "Килограмм",
    "50": "Ватт-час", "61": "Градус Цельсия", "64": "Люкс",
    "90": "Метр в секунду", "96": "Секунда", "98": "Час",
    "282": "ед.", "292": "Процент", "429": "дБ",
    "532": "Вт/м²", "533": "Миллиграмм на кубический метр",
    "548": "Дж/м²", "650": "дБА",
    "684": "мкЗв/ч", "1091": "ион/см³",
    "1107": "Вт/см²",
}


def source_units(doc: ET.Element) -> dict[int, tuple[str, str, str]]:
    """Map a specific XML element to original (MeasurementId, Directory, IndicatorId).

    Never infer a unit merely from a factor number: within a factor, units
    may differ by bm/bm_id and even by measurement sub-result.
    """
    factor = doc.find("./factor")
    facid = factor.get("facid", "") if factor is not None else ""
    nodes = list(doc.findall("./izm_data/zone/param"))
    drafts = []
    acoustic = NoiseOptions(False, False, False, False)
    if facid == "4":
        drafts = map_noise_equivalent(doc, acoustic)
    elif facid == "5":
        drafts = map_infrasound_equivalent(doc, acoustic)
    elif facid == "6":
        drafts = map_ultrasound_2025(doc, acoustic)
    elif facid == "11":
        drafts = map_microclimate_2025(doc, MicroclimateOptions(False, False, True))
    elif facid == "12":
        drafts = map_lighting_2025(doc, LightingOptions(False))
    elif facid == "10099":
        drafts = map_aeroions_2025(doc)
    elif facid in ("13", "14"):
        # Original summary branch; never add calculated summary rows to XLS.
        drafts = map_labour_2025(doc, LabourOptions())

    matched: dict[int, tuple[str, str, str]] = {}
    ambiguous: set[int] = set()
    for d in drafts:
        index_match = re.fullmatch(
            r"Document/izm_data/zone/param\[(\d+)\]", d.source_xpath)
        if index_match:
            index = int(index_match.group(1)) - 1
            if index >= len(nodes):
                continue
            node = nodes[index]
        elif d.source_xpath == "Document/izm_data/Level[@bm='Lekv']":
            node = doc.find("./izm_data/Level[@bm='Lekv']")
        else:
            continue
        if node is None:
            continue
        value = (d.measurement_id, d.directory, d.indicator_id)
        key = id(node)
        if key in matched and matched[key] != value:
            ambiguous.add(key)
        else:
            matched[key] = value
    for key in ambiguous:
        matched.pop(key, None)

    # Additional exact original read_him_params and read_ufi_params branches.
    # "ko#*" = VBA Like 'ko#*', not every chemical result.
    for node in nodes:
        key = id(node)
        if key in matched or key in ambiguous:
            continue
        bm = node.get("bm", "")
        if facid in ("1", "3") and re.match(r"(?i)^ko[0-9]", bm):
            matched[key] = ("533", "", "")  # indicator may be remapped by original
        if facid == "26":
            if bm.startswith("ufinewA"):
                matched[key] = ("532", "1", "59")
            elif bm.startswith("ufinewB"):
                matched[key] = ("532", "1", "60")
            elif bm.startswith("ufinewC"):
                matched[key] = ("532", "1", "61")
            elif bm.startswith("ufinew_B_C"):
                matched[key] = ("532", "2", "150860")
    return matched


class OriginalUnits:
    """Per-export resolver; read each explicit INI override at most once."""

    def __init__(self, doc: ET.Element, ini: Path | None):
        self._units = source_units(doc)
        self._ini = Path(ini) if ini and Path(ini).is_file() else None
        self._overrides: dict[tuple[str, str], str] = {}

    def display(self, node: ET.Element, original_text: str = "",
                *, vibration_confirmed: bool = False, facid: str = "") -> str:
        info = self._units.get(id(node))
        if info is None and facid in ("7", "8") and vibration_confirmed:
            # Original vibr_loc/gen calls AddParam assigning 429; apply
            # only for measured levels independently verified as dB.
            info = ("429", "", "")
        if info is None:
            return original_text
        code, directory, indicator = info
        if self._ini is not None and directory and indicator:
            key = (directory, indicator)
            if key not in self._overrides:
                self._overrides[key] = read_ini(
                    self._ini, "Measurements", f"id{directory}_{indicator}")
            if self._overrides[key]:
                code = self._overrides[key]
        label = ORIGINAL_UNIT_LABELS.get(code)
        if not label:
            # An unknown overridden/special ID does not establish its label.
            return original_text
        if original_text.strip() == "% смены" and code == "292":
            label = "% смены"  # Explicitly written in this source group heading.
        return f"{label} (id {code})"
