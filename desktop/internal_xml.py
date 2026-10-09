"""Read-only inspection of ATT51's internal XML, not FGIS submission XML.

fileProtocolLoad_v4.xsd describes final FGIS documents and deliberately is NOT
applied to the source Document/factor sidecar XML.
"""
from __future__ import annotations

from pathlib import Path

from att51_fsa.sources import FsaSourceError, parse_xml, read_sidecar
from factor_structure import inspect_factor_structure


FACTOR_NAMES = {
    "13": "Тяжесть трудового процесса",
    "14": "Напряжённость трудового процесса",
}


def inspect_internal_xml(path: Path) -> dict:
    """Check parseability, original root/required factor, and selected metadata."""
    path = Path(path)
    root = parse_xml(path)
    document = root if root.tag == "Document" else root.find(".//Document")
    if document is None:
        raise FsaSourceError("Внутренний XML не содержит элемента Document.")
    factor = document.find("factor")
    if factor is None:
        raise FsaSourceError("Внутренний XML не содержит элемента Document/factor.")
    facid = factor.get("facid", "").strip()
    if not facid:
        raise FsaSourceError("У элемента Document/factor отсутствует facid.")
    sidecar = read_sidecar(path)
    warnings = []
    if not sidecar.protocol_number:
        warnings.append("Не заполнен номер протокола (num_doc).")
    if facid in FACTOR_NAMES:
        warnings.append(
            f"Фактор {facid} ({FACTOR_NAMES[facid]}) пока не реализован "
            "в преобразовании для ФГИС. Это не ошибка исходного XML."
        )
    return {
        "xml": str(path),
        "xml_kind": "original_att51_internal_protocol",
        "well_formed": True,
        "document_present": True,
        "factor_present": True,
        "protocol_number": sidecar.protocol_number,
        "factor_id": facid,
        "factor_name": FACTOR_NAMES.get(facid, ""),
        "measurement_dates": sidecar.measurement_dates,
        "equipment_count": len(sidecar.equipment),
        "personnel_count": sidecar.personnel_count,
        "normative_documents_count": sidecar.normative_documents_count,
        "measurement_structure_evidence": (
            inspect_factor_structure(root) if facid in FACTOR_NAMES else None
        ),
        "warnings": warnings,
        "fgis_schema_applicable": False,
        "schema_explanation": (
            "fileProtocolLoad_v4.xsd применяется к итоговому XML для ФГИС, "
            "а не к внутреннему XML с корнем Document."
        ),
        "not_exportable": True,
    }
