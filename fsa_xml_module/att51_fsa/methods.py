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


@dataclass(frozen=True)
class BoundMethodResult:
    """Inspect-only result: specific ND paths and why a method was chosen."""
    selected: MethodResolution
    protocol_methods: tuple[MethodCandidate, ...]
    source_errors: tuple[str, ...]
    matching_rules: tuple[str, ...]
    not_exportable: bool = True


def bind_methods_from_catalog(
    measure: ResearchForMethod,
    protocol_methods: Iterable[MethodCandidate],
    catalog: "ResourceCatalog",
    *,
    factor_id: str,
) -> BoundMethodResult:
    """Connect get_DocNameId with resource MDB lookups (v5_options_dic).

    The original FSA form first passes every ND through get_nd_by_name,
    fills DocNameId from DIC_ND_INFO.dop2 when Val is nonzero, and applies
    get_DocNameId in the original 3-pass order.
    Missing documents are NOT silently substituted.
    """
    from dataclasses import replace
    from .resources import nd_hash

    preferences: dict[str, str] = {}
    errors: list[str] = []
    traces: list[str] = []
    verified_unique_methods: set[str] = set()

    def map_method(item: MethodCandidate) -> MethodCandidate:
        matched = catalog.nd(nd_hash(item.doc_name), item.doc_name, str(factor_id))
        traces.append(matched.source_rule)
        if not matched.found or matched.normative is None:
            errors.append("normative_missing_from_resource_mdb")
            return item
        issues = catalog.nd_diagnostics(matched, "1")
        errors.extend(x for x in issues if x.startswith("fatal_"))
        if matched.requires_review and "original_vba_like_requires_verification" in matched.warnings:
            errors.append("normative_short_name_match_requires_verification")
        resource = matched.normative
        # Original get_DocNameId_Helper (VBA lines 259-280) explicitly
        # selects a textual UniqueMethod when DocNameId is empty. Accept
        # this only for an unambiguous exact-factor match to a real ND;
        # fuzzy and cross-factor matches remain review-only.
        if (resource.method_doc_id in ("", "0", "-1")
                and matched.source_rule == "hash_with_factor"
                and matched.alternatives == 1
                and nd_hash(resource.name) == nd_hash(item.doc_name)
                and bool(item.doc_name.strip())
                and not matched.warnings):
            verified_unique_methods.add(item.doc_name)
        preferences[item.doc_name] = resource.preference
        return replace(
            item,
            doc_name_id=(
                resource.method_doc_id
                if resource.method_doc_id not in ("", "0") else item.doc_name_id
            ),
            oa_method=resource.oa_method,
            nd_guid=resource.guid,
        )

    common = tuple(map_method(m) for m in protocol_methods)
    if measure.own_methods:
        own = tuple(map_method(m) for m in measure.own_methods)
        annotated = replace(measure, own_methods=own)
    else:
        annotated = measure
    chosen = resolve_method(annotated, common, preferences)
    if not chosen.doc_name_id or chosen.doc_name_id in ("0", "-1"):
        if chosen.doc_name in verified_unique_methods and not errors:
            traces.append("verified_original_unique_method_fallback")
            chosen = replace(chosen, requires_review=False)
        else:
            errors.append("method_fgis_id_missing")
    if errors and not chosen.requires_review:
        chosen = replace(chosen, requires_review=True)
    return BoundMethodResult(
        selected=chosen, protocol_methods=common,
        source_errors=tuple(dict.fromkeys(errors)),
        matching_rules=tuple(traces),
    )
