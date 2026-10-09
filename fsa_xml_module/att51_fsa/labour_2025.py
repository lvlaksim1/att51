"""Verified original ATT51 v52_exp_fgis_ra2025 factor 13/14 measurements.

Mapping copied from read_tyag_params_direct, read_tyag_params_itog,
read_napr_params of original Attestation51.dot. The catalogue is a source
translation, not a guarantee that a full FGIS protocol can be exported.
Original VBA checkbox state must be supplied by caller when used operationally.
"""
from __future__ import annotations

from dataclasses import dataclass
import json
import re
from xml.etree import ElementTree as ET

from .measurements import ResearchObjectDraft, original_get_num
from .sources import FsaSourceError


# Snapshot of original Case branches; source_line refers to extracted VBA module.
# Published by the read-only research workflow, not inferred from real user values.
_HEAVY_SUMMARY = json.loads("[{\"source_line\":892,\"bmid\":[\"bm_1_1_m\",\"bm_1_1_w\",\"m01\",\"w01\"],\"bm\":[],\"indicator\":\"131455\",\"directory\":\"2\",\"unit\":\"985\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":902,\"bmid\":[\"bm_1_2_1_m\",\"bm_1_2_1_w\",\"m02\",\"w02\"],\"bm\":[],\"indicator\":\"131456\",\"directory\":\"2\",\"unit\":\"985\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":912,\"bmid\":[\"bm_1_2_2_m\",\"bm_1_2_2_w\",\"m03\",\"w03\"],\"bm\":[],\"indicator\":\"131457\",\"directory\":\"2\",\"unit\":\"985\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":923,\"bmid\":[\"bm_1_3_m\",\"bm_1_3_w\"],\"bm\":[],\"indicator\":\"163795\",\"directory\":\"2\",\"unit\":\"985\",\"requires_total\":true,\"requires_nd\":false},{\"source_line\":936,\"bmid\":[\"bm_2_1_m\",\"bm_2_1_w\",\"m04\",\"w04\"],\"bm\":[],\"indicator\":\"131458\",\"directory\":\"2\",\"unit\":\"35\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":947,\"bmid\":[\"bm_2_2_m\",\"bm_2_2_w\",\"m05\",\"w05\"],\"bm\":[],\"indicator\":\"131459\",\"directory\":\"2\",\"unit\":\"35\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":958,\"bmid\":[\"bm_2_3_1_m\",\"bm_2_3_1_w\",\"m06\",\"w06\"],\"bm\":[],\"indicator\":\"131460\",\"directory\":\"2\",\"unit\":\"35\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":969,\"bmid\":[\"bm_2_3_2_m\",\"bm_2_3_2_w\",\"m07\",\"w07\"],\"bm\":[],\"indicator\":\"131461\",\"directory\":\"2\",\"unit\":\"35\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":980,\"bmid\":[\"bm_2_3\"],\"bm\":[],\"indicator\":\"3961\",\"directory\":\"2\",\"unit\":\"35\",\"requires_total\":true,\"requires_nd\":false},{\"source_line\":993,\"bmid\":[\"bm_3_1\",\"a08\"],\"bm\":[],\"indicator\":\"131462\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1004,\"bmid\":[\"bm_3_2\",\"a09\"],\"bm\":[],\"indicator\":\"131463\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1015,\"bmid\":[\"bm_4_1_m\",\"bm_4_1_w\",\"m10\",\"w10\"],\"bm\":[],\"indicator\":\"166546\",\"directory\":\"2\",\"unit\":\"987\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1026,\"bmid\":[\"bm_4_2_m\",\"bm_4_2_w\",\"m11\",\"w11\"],\"bm\":[],\"indicator\":\"166547\",\"directory\":\"2\",\"unit\":\"987\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1037,\"bmid\":[\"bm_4_3_m\",\"bm_4_3_w\",\"m12\",\"w12\"],\"bm\":[],\"indicator\":\"172845\",\"directory\":\"2\",\"unit\":\"987\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1048,\"bmid\":[\"bm_4_4_m\",\"bm_4_4_w\"],\"bm\":[],\"indicator\":\"163796\",\"directory\":\"2\",\"unit\":\"987\",\"requires_total\":true,\"requires_nd\":false},{\"source_line\":1061,\"bmid\":[\"bm_5_1\"],\"bm\":[],\"indicator\":\"131467\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1072,\"bmid\":[\"bm_5_2\"],\"bm\":[],\"indicator\":\"131468\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1083,\"bmid\":[\"bm_5_3\"],\"bm\":[],\"indicator\":\"131469\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1094,\"bmid\":[\"bm_5_4\"],\"bm\":[],\"indicator\":\"131470\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1105,\"bmid\":[\"bm_5_5\"],\"bm\":[],\"indicator\":\"131471\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1116,\"bmid\":[\"bm_5_6\"],\"bm\":[],\"indicator\":\"131472\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1127,\"bmid\":[\"bm_6\",\"a14\"],\"bm\":[],\"indicator\":\"131473\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1138,\"bmid\":[\"bm_7_1\",\"a15\"],\"bm\":[],\"indicator\":\"131474\",\"directory\":\"2\",\"unit\":\"5\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1149,\"bmid\":[\"bm_7_2\"],\"bm\":[],\"indicator\":\"131475\",\"directory\":\"2\",\"unit\":\"5\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":1160,\"bmid\":[\"bm_7_3\"],\"bm\":[],\"indicator\":\"163797\",\"directory\":\"2\",\"unit\":\"5\",\"requires_total\":true,\"requires_nd\":false}]")
_STRAIN = json.loads("[{\"source_line\":736,\"bmid\":[\"n_bm1_3\"],\"bm\":[\"s09\"],\"indicator\":\"123118\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":744,\"bmid\":[\"n_bm1_4\"],\"bm\":[\"s13\"],\"indicator\":\"123119\",\"directory\":\"2\",\"unit\":\"98\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":752,\"bmid\":[\"n_bm1_5\"],\"bm\":[\"s12\"],\"indicator\":\"3947\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":760,\"bmid\":[\"n_bm1_6\"],\"bm\":[\"s05\"],\"indicator\":\"44\",\"directory\":\"1\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":768,\"bmid\":[\"n_bm2_3\"],\"bm\":[\"s20\"],\"indicator\":\"48\",\"directory\":\"1\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":776,\"bmid\":[\"n_bm2_3_2\"],\"bm\":[\"s20\"],\"indicator\":\"48\",\"directory\":\"1\",\"unit\":\"98\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":785,\"bmid\":[\"n_bm1_1\"],\"bm\":[\"s06\"],\"indicator\":\"123116\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":794,\"bmid\":[\"n_bm1_2\"],\"bm\":[\"s07\"],\"indicator\":\"123117\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":803,\"bmid\":[\"n_bm2_1\"],\"bm\":[\"s18\"],\"indicator\":\"147961\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":812,\"bmid\":[\"n_bm2_2\"],\"bm\":[\"s21\"],\"indicator\":\"123122\",\"directory\":\"2\",\"unit\":\"292\",\"requires_total\":false,\"requires_nd\":false},{\"source_line\":823,\"bmid\":[],\"bm\":[\"s51\"],\"indicator\":\"131374\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":true},{\"source_line\":834,\"bmid\":[],\"bm\":[\"s52\"],\"indicator\":\"131375\",\"directory\":\"2\",\"unit\":\"282\",\"requires_total\":false,\"requires_nd\":true}]")


@dataclass(frozen=True)
class LabourOptions:
    # These are explicit algorithmic selectors; defaults are NOT evidence of
    # the user's checkbox settings in original "Аттестация-5.1".
    heavy_direct: bool = False
    include_heavy_totals: bool = False
    include_uncertainty: bool = False
    heavy_fdn: bool = True
    heavy_mass: bool = True
    heavy_static: bool = True
    strain_optic: bool = True
    strain_voice: bool = True
    strain_monitor: bool = True
    strain_active_monitor: bool = True
    strain_signal_count: bool = True
    strain_multi_object: bool = True
    strain_element_count: bool = True
    strain_passive_monitor: bool = True


_POSES = {
    "1": ("131467", "100"), "2": ("131468", "до 40"),
    "3": ("131469", "до 25"), "4": ("131468", "до 60"),
    "5": ("131469", "до 50"), "6": ("131471", "до 25"),
    "7": ("131468", "до 80"), "8": ("131472", "от 60 до 80"),
    "9": ("131469", "более 50"), "10": ("131471", "более 25"),
    "11": ("131468", "более 80"), "12": ("131472", "более 80"),
}


def _doc(element: ET.Element) -> ET.Element:
    doc = element if element.tag == "Document" else element.find(".//Document")
    if doc is None:
        raise FsaSourceError("Нет Document во внутреннем XML")
    return doc


def _draft(indicator: str, directory: str, value: str, unit: str,
           nd: str, source: str) -> ResearchObjectDraft:
    return ResearchObjectDraft(indicator, directory, value, unit, source, nd_izm1=nd)


def _with_uncertainty(value: str, uncertainty: str, include: bool) -> str:
    if include and any(ch in "0123456789" for ch in uncertainty):
        return value + "\u00b1" + uncertainty
    return value


def _facts(value: str) -> list[str]:
    # Original read_fact_coll: semicolon-delimited, preserving a single value
    # verbatim when there is no semicolon.
    if ";" not in value:
        return [value]
    return [part.strip() for part in value.split(";") if part.strip()]


def _heavy_direct(doc: ET.Element, options: LabourOptions) -> list[ResearchObjectDraft]:
    result: list[ResearchObjectDraft] = []
    for i, node in enumerate(doc.findall("./count_params2/param"), 1):
        key = node.get("id", "")
        nd = node.get("nd_izm1", "")
        p1, p2 = node.get("param1", ""), node.get("param2", "")
        candidates: list[tuple[str, str, str, str]] = []
        if key in ("bm_1", "bm_1_2", "bm_1_3") and options.heavy_fdn:
            candidates = (
                [("37", "1", val, "35") for val in _facts(p1)] +
                [("42", "1", val, "4") for val in _facts(p2)]
            )
        elif key in ("bm_2_1", "bm_2_2") and options.heavy_mass:
            candidates = [("37", "1", p1, "35")]
        elif key in ("bm_4_1", "bm_4_2", "bm_4_3") and options.heavy_static:
            candidates = (
                [("37", "1", val, "35") for val in _facts(p1)] +
                [("39", "1", val, "96") for val in _facts(p2)]
            )
        for indicator, directory, value, unit in candidates:
            fact = original_get_num(value)
            if fact:
                result.append(_draft(indicator, directory, fact, unit, nd,
                                     f"Document/count_params2/param[{i}]"))
    return result


def _strain_allowed(key: str, bm: str, opt: LabourOptions) -> bool:
    # Filters in read_napr_params lines 683-730; OR conditions intentionally
    # follow original VBA, including the legacy short bm forms.
    gates = (
        (("n_bm1_3",), ("s09",), opt.strain_optic),
        (("n_bm1_4",), ("s13",), opt.strain_voice),
        (("n_bm1_6",), ("s05",), opt.strain_monitor),
        (("n_bm2_3", "n_bm2_3_2"), ("s20",), opt.strain_active_monitor),
        (("n_bm1_1",), ("s06",), opt.strain_signal_count),
        (("n_bm1_2",), ("s07",), opt.strain_multi_object),
        (("n_bm2_1",), ("s18",), opt.strain_element_count),
        (("n_bm2_2",), ("s21",), opt.strain_passive_monitor),
    )
    return all(allowed for keys, codes, allowed in gates
               if key in keys or bm in codes)


def _match(rules: list[dict], key: str, bm: str) -> dict | None:
    # Original Select Case True: first match wins (not the most specific).
    return next((rule for rule in rules
                 if key in rule["bmid"] or (rule["bm"] and bm in rule["bm"])), None)


def map_labour_2025(
    root: ET.Element, options: LabourOptions
) -> list[ResearchObjectDraft]:
    doc = _doc(root)
    factor = doc.find("./factor")
    if factor is None:
        raise FsaSourceError("Внутренний XML не содержит factor")
    facid = factor.get("facid")
    if facid not in ("13", "14"):
        raise FsaSourceError("Поддерживаются только facid 13 и 14")
    if facid == "13" and options.heavy_direct:
        return _heavy_direct(doc, options)
    rules = _HEAVY_SUMMARY if facid == "13" else _STRAIN
    result: list[ResearchObjectDraft] = []
    nd_sum = " ".join(item.get("name", "") for item in doc.findall("./nd_data/nd")).upper()
    pose_id = factor.get("poza_id", "")
    for i, node in enumerate(doc.findall("./izm_data/zone/param"), 1):
        key = node.get("bm", "") if facid == "13" else node.get("bm_id", "")
        bm = "" if facid == "13" else node.get("bm", "")
        fact = original_get_num(node.get("fact", ""))
        nd = node.get("nd_izm1", "")
        uncertainty = node.get("U095", "")
        if facid == "14" and not _strain_allowed(key, bm, options):
            continue
        rule = _match(rules, key, bm)
        if rule is not None and fact:
            if rule["requires_total"] and not options.include_heavy_totals:
                continue
            if rule["requires_nd"] and not re.search(
                r"МИ.*НТП.*ИНТ.*17.*01.*2018", nd_sum
            ):
                continue
            result.append(_draft(
                rule["indicator"], rule["directory"],
                _with_uncertainty(fact, uncertainty, options.include_uncertainty),
                rule["unit"], nd, f"Document/izm_data/zone/param[{i}]",
            ))
        # Original classic-form pose special case, a13, can have nonnumeric
        # literal descriptions such as "до 40" (do not discard as nonnumeric).
        if facid == "13" and key == "a13" and pose_id in _POSES:
            indicator, pose_fact = _POSES[pose_id]
            result.append(_draft(
                indicator, "2", pose_fact, "292", nd,
                f"Document/factor/@poza_id+izm_data/zone/param[{i}]",
            ))
    return result
