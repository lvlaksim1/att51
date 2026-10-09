"""Original FGIS RA protocol selection (individual and consolidated protocols).

Strictly read-only. This code reflects v52_exp_fgis_ra.fill_fgis_ra_data,
read_sv_prots, doc_to_xml and get_sv_prot_factor_id. UI selection of
workplaces, visible subdivisions, regions and factor checkbox values is
deliberately provided by the caller rather than fabricated.
"""
from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Iterable

from .sources import AccessReader, FsaSourceError, parse_xml, resolve_relative_file


@dataclass(frozen=True)
class ProtocolSelection:
    mode: str
    word_file: str
    xml_file: str
    status: str
    workplace_id: int | None = None
    factor_id: int | None = None
    document_name: str = ""
    protocol_number: str = ""
    division_id: str = ""
    nd_mode: str = ""


def _as_factor_set(factors: Iterable[int]) -> set[int]:
    factor_set = {int(value) for value in factors}
    if any(v <= 0 for v in factor_set):
        raise FsaSourceError("Enabled factors must be positive integer IDs")
    return factor_set


def _factor_enabled(factor_id: int, enabled: set[int]) -> bool:
    """GetSQLFacFilter2: fac9 checkbox controls 9 and 10009."""
    if factor_id == 10009:
        return 9 in enabled
    return factor_id in enabled


def select_individual(
    workplace_db: Path,
    documents_root: Path,
    *,
    selected_workplace_ids: Iterable[int],
    enabled_factors: Iterable[int],
) -> list[ProtocolSelection]:
    """Enumerate exactly selected RMs, analogous to the original selected UI tree.

    DO NOT infer the tree from all struct_rm entries: that would silently
    change region, hierarchy and archived workplace filter semantics.
    """
    root = Path(documents_root)
    enabled = _as_factor_set(enabled_factors)
    selected = [int(v) for v in selected_workplace_ids]
    if len(selected) != len(set(selected)) or any(v <= 0 for v in selected):
        raise FsaSourceError("Workplace selection requires unique positive IDs")
    if not root.is_dir():
        raise FsaSourceError(f"Missing linked document directory: {root}")
    choices: list[ProtocolSelection] = []
    with AccessReader(Path(workplace_db)) as db:
        for workplace_id in selected:
            query = (
                "SELECT factor_id, file FROM sout_factors "
                f"WHERE rm_id={workplace_id} AND factor_id<>16 "
                "AND factor_id<>101 AND factor_id<>105 "
                "AND (factor_id<10000 OR factor_id=10009 OR factor_id=10099) "
                "ORDER BY factor_id"
            )
            for row in db.select(query):
                factor_id = int(row["factor_id"])
                # Original tests accepted factor IDs inside its second guard.
                allowed = (0 < factor_id <= 26) or factor_id in (35, 37, 41, 10009, 10099)
                if not allowed or not _factor_enabled(factor_id, enabled):
                    continue
                file = str(row.get("file") or "")
                if not file:
                    choices.append(ProtocolSelection(
                        "individual", "", "", "missing_document_path",
                        workplace_id, factor_id,
                    ))
                    continue
                doc = resolve_relative_file(root, file)
                sidecar = doc.parent / "xml" / (doc.stem + ".xml")
                state = "available" if sidecar.is_file() else "missing_xml"
                choices.append(ProtocolSelection(
                    "individual", str(doc), str(sidecar), state,
                    workplace_id, factor_id,
                ))
    return choices


def select_consolidated(
    documents_root: Path,
    organization_guid: str,
    *,
    visible_divisions: Iterable[str],
    region_divisions: Iterable[str] | None = None,
    enabled_factors: Iterable[int] | None = None,
) -> list[ProtocolSelection]:
    """Read original docs_list.xml and find summary protocol Word/XML pairs.

    Visible subdivisions mirror get_filter_str on the selected UI tree.
    None for region_divisions means original region_info.tag is '~'/empty.
    Passing an empty set means active region selection with no matches.
    """
    root = Path(documents_root)
    guid = str(organization_guid).strip()
    if not guid or "/" in guid or "\\" in guid or guid in {".", ".."}:
        raise FsaSourceError("An exact organization GUID is required")
    org = root / "000_org_data" / guid
    catalog = org / "docs_list.xml"
    sv_docs = org / "sv_docs"
    if not catalog.is_file():
        raise FsaSourceError(f"Missing original summary list: {catalog}")
    if not sv_docs.is_dir():
        raise FsaSourceError(f"Missing original summary documents: {sv_docs}")
    visible = set(visible_divisions)
    regional = set(region_divisions) if region_divisions is not None else None
    enabled = _as_factor_set(enabled_factors) if enabled_factors is not None else None
    # The original curxmldoc.SelectNodes("//Document/doc")
    document = parse_xml(catalog)
    results: list[ProtocolSelection] = []
    for node in document.findall(".//Document/doc"):
        file, name = node.get("file", ""), node.get("name", "")
        dtype = node.get("doc_type", "")
        if not file or not name or dtype != "3":
            continue
        division = node.get("podr_id", "")
        if division.startswith(("uch_", "ceh_")) and division not in visible:
            continue
        if regional is not None and division and division not in regional:
            continue
        doc = resolve_relative_file(sv_docs, file)
        # Original checks Word exists BEFORE populating factor_list.
        if not doc.is_file():
            continue
        if doc.suffix.lower() not in {".doc", ".docx"}:
            raise FsaSourceError(f"Unexpected summary Word extension: {file}")
        xml_path = doc.with_suffix(".xml")
        # Get fac_id from summary XML, remap 950 to 9 in get_xml_data_sv.
        factor_id = None
        status = "available" if xml_path.is_file() else "missing_xml"
        if xml_path.is_file():
            try:
                xml_root = parse_xml(xml_path)
                xml_doc = xml_root if xml_root.tag == "Document" else xml_root.find(".//Document")
                if xml_doc is None:
                    status = "malformed_xml"
                else:
                    fac = xml_doc.get("fac_id", "")
                    if fac:
                        factor_id = 9 if fac == "950" else int(fac)
                        if enabled is not None and not _factor_enabled(factor_id, enabled):
                            continue
            except (ValueError, FsaSourceError):
                status = "malformed_xml"
        nd_mode = node.get("nd_mode", "")
        if status == "available" and nd_mode != "1":
            status = "legacy_nd_mode"
        results.append(ProtocolSelection(
            mode="consolidated", word_file=str(doc),
            xml_file=str(xml_path), status=status,
            factor_id=factor_id, document_name=name,
            protocol_number=node.get("num_doc", ""),
            division_id=division, nd_mode=nd_mode,
        ))
    return results


def selections_to_dict(items: Iterable[ProtocolSelection]) -> list[dict[str, Any]]:
    return [asdict(item) for item in items]
