"""Three-pass original ATT51 2025 method-of-measurement resolver.

Implements core selection rules of
v52_exp_fgis_ra2025.get_DocNameId/get_DocNameId_Helper.
The normative/document lookup itself (v5_options_dic) remains separate.
There is NO fallback to invented FGIS identifiers.
"""
from __future__ import annotations
from dataclasses import dataclass
import re
from typing import Iterable, Mapping


@dataclass(frozen=True)
class MethodCandidate:
    nd_izm1: str
    doc_name_id: str
    doc_name: str
    oa_method: str = ""
    nd_guid: str = ""


@dataclass(frozen=True)
class ResearchForMethod:
    indicator_id: str
    indicator_id_2: str = ""
    indicator_id_4: str = ""
    him_id: str = ""
    nd_izm1: str = ""
    own_methods: tuple[MethodCandidate, ...] = ()


@dataclass(frozen=True)
class MethodResolution:
    doc_name_id: str
    doc_name: str
    oa_method: str
    nd_guid: str
    source_rule: str
    requires_review: bool


_TAGS = {
    "3": "temp", "4": "vlag", "5": "skor", "6": "tepl",
    "122794": "tepl", "122114": "tns", "3645": "tns",
    "131478": "doza",
    "21": "emp50_ep", "51": "emp50_mp",
    "22": "emp_rd_ep1", "52": "emp_rd_ep2",
    "56": "emp_rd_mp2", "53": "emp_rd_ep3",
    "54": "emp_rd_ep4", "57": "emp_rd_mp4",
    "55": "emp_rd_ep5", "58": "emp_rd_pp",
    "9": "shum_izm", "281": "shum_ekv",
    "13": "vibr_gen_izm", "2367": "vibr_gen_izm",
    "144614": "vibr_gen_ekv", "14": "vibr_loc_izm",
    "156886": "vibr_loc_ekv",
    "10": "infr_izm", "131616": "infr_ekv",
    "16": "svet_osv",
}


def _vba_positive_val(value: str) -> bool:
    """Subset of VB6 Val for positive decimal ASCII-prefix numbers."""
    m = re.match(r"\s*\+?(\d+(?:\.\d+)?)", value or "")
    return bool(m and float(m.group(1)) > 0)


def _matches_semicolon_list(source: str, nd_id: str) -> bool:
    """Exact equality or token at beginning/middle/end of ';' list."""
    if not source or not nd_id:
        return False
    return nd_id in source.split(";")


def _method(m: MethodCandidate, rule: str) -> MethodResolution:
    return MethodResolution(
        doc_name_id=m.doc_name_id,
        doc_name=m.doc_name,
        oa_method=m.oa_method,
        nd_guid=m.nd_guid,
        source_rule=rule,
        requires_review=not (m.doc_name and m.doc_name_id and m.doc_name_id != "-1"),
    )


def _preference_tag(value: ResearchForMethod) -> str:
    indicator = value.indicator_id_4 or value.indicator_id
    if indicator == "66":
        return "him_id" + value.him_id
    tag = _TAGS.get(indicator, "")
    if not tag and value.indicator_id_2 == "66":
        return "him_id" + value.him_id
    return tag


def resolve_method(
    measure: ResearchForMethod,
    protocol_methods: Iterable[MethodCandidate],
    nd_preferences: Mapping[str, str],
) -> MethodResolution:
    """Return original chosen method plus independent diagnostic source rule.

    nd_preferences maps exact DocName -> resource DIC_ND dop4 value.
    A missing mapping means that the original source's resource query has not
    been reproduced: no method is assumed in the second pass.
    """
    methods = list(measure.own_methods or tuple(protocol_methods))

    # FIRST PASS: explicit ND references, retaining original preference order.
    last_match = None
    for method in methods:
        if _vba_positive_val(method.nd_izm1) and _matches_semicolon_list(
            measure.nd_izm1, method.nd_izm1
        ):
            last_match = _method(method, "first_pass_nd_id")
            if method.doc_name_id not in ("", "-1"):
                return last_match
    if last_match is not None:
        return last_match

    # SECOND PASS: priority tags in DIC_ND.dop4, then first default ND.
    tag = _preference_tag(measure)
    if tag:
        first_default = None
        for method in methods:
            dop4 = nd_preferences.get(method.doc_name)
            if dop4 is None:
                continue  # original GetNDFromDistDic returned Nothing
            if tag in dop4:
                return _method(method, "second_pass_priority_tag")
            if first_default is None and dop4 == "":
                first_default = method
        if first_default is not None:
            return _method(first_default, "second_pass_default_nd")

    # THIRD PASS: original get_DocNameId_Helper. If no numeric DocNameId is
    # present, the last eligible "unique" ND is retained.
    last_unique = None
    for method in methods:
        if method.nd_izm1 != "-1":
            last_unique = method
            if method.doc_name_id != "":
                return _method(method, "third_pass_first_doc_name_id")
    if last_unique is not None:
        return _method(last_unique, "third_pass_unique_nd")

    # Original initializes helper.id = "-1". This result MUST be reviewed and
    # MUST NOT silently be serialized into a real FSA export.
    return MethodResolution(
        doc_name_id="-1", doc_name="", oa_method="", nd_guid="",
        source_rule="third_pass_no_methods", requires_review=True,
    )
