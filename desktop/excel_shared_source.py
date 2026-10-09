"""Pure Excel layout of the source snapshot prepared before FGIS ID mapping.

NO filesystem operations, XML parsing, MDB reads, catalog lookups or separate
measurement selection are permitted in this presentation module.
"""
from __future__ import annotations

from att51_fsa.export_2025 import PreparedProtocol
from att51_fsa.sources import FsaSourceError


def prepared_protocol_rows(proposal: PreparedProtocol) -> list[list[str]]:
    """One row per XML-approved measurement, source text in five columns."""
    source = proposal.source
    protocol = proposal.protocol
    if source is None or protocol is None:
        raise FsaSourceError("Единый подготовленный набор сведений отсутствует")
    if len(source.shared) != 10 or len(source.additional) != 11:
        raise FsaSourceError("Нарушена структура 26 столбцов протокола")
    if len(source.measurements) != len(protocol.research_objects):
        raise FsaSourceError("Количество показателей XML и Excel различается")
    rows = []
    for number, five in enumerate(source.measurements):
        if len(five) != 5:
            raise FsaSourceError("Измеренный показатель содержит не пять значений")
        rows.append(
            list(source.shared if number == 0 else ("",) * 10)
            + list(five)
            + list(source.additional if number == 0 else ("",) * 11)
        )
    return rows


def prepared_batch_rows(batch) -> tuple[list[list[str]], int, int]:
    if batch.issues or not batch.ready:
        raise FsaSourceError(
            "Excel не сформирован — исходные протоколы не подготовлены:\n"
            + "\n".join("- " + issue for issue in batch.issues)
        )
    rows = []
    for proposal in batch.protocols:
        rows.extend(prepared_protocol_rows(proposal))
    if len(rows) != batch.measurement_count:
        raise FsaSourceError("Excel/XML: количество показателей не совпадает")
    if len(rows) > 65535:
        raise FsaSourceError("В формате XLS не более 65 535 строк данных")
    return rows, batch.total, len(rows)
