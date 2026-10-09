"""Verified common FGIS header rules from original ATT51 VBA (v52_exp_fgis_ra).

This does not invent organization data or missing dates. Exact values must
come from the original fields or an explicit verified source.
"""
from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
import re

from .sources import FsaSourceError


DATA_STATUS_NAMES = {"13": "Отправлен", "20": "Черновик"}
PROTOCOL_STATUS_NAMES = {"6": "Действует"}
FACTOR_OBJECT_NAMES = {
    "13": "Тяжесть трудового процесса",
    "14": "Напряженность трудового процесса",
}


def fgis_status(value: str | int, *, protocol: bool = False) -> str:
    """Original form uses 13/20 and 6; XSD requires numeric xs:int.

    The original save_XML erroneously adds a human label to the XML value
    for these statuses. This serializer keeps only an explicitly known ID.
    """
    token = str(value).strip()
    mapping = PROTOCOL_STATUS_NAMES if protocol else DATA_STATUS_NAMES
    match = re.fullmatch(r"([0-9]+)(?:\s+-\s+(.+))?", token)
    if not match:
        raise FsaSourceError("Неподдерживаемое значение статуса: " + token)
    number, label = match.groups()
    if number not in mapping:
        raise FsaSourceError("Неизвестный ID статуса ФГИС: " + number)
    if label is not None and label.strip() != mapping[number]:
        raise FsaSourceError("ID статуса не соответствует описанию: " + token)
    return number


def fgis_date(value: str | date | datetime, *, source: str) -> str:
    """Strict output for XSD xs:date, without silent current-date fallback."""
    if isinstance(value, datetime):
        return value.date().isoformat()
    if isinstance(value, date):
        return value.isoformat()
    raw = str(value).strip()
    for fmt in ("%d.%m.%Y", "%Y-%m-%d"):
        try:
            return datetime.strptime(raw, fmt).date().isoformat()
        except ValueError:
            continue
    raise FsaSourceError(f"Нет достоверной даты для {source}: {raw!r}")


def original_protocol_date(fill_date: str, sign_date: str,
                           *, explicit_date: str = "") -> str:
    """Original FillPrototcolData 3520-3526: explicit override, then
    valid fill_date, then fallback sign_date. Never use current date.
    """
    sources = (explicit_date, sign_date) if explicit_date else (fill_date, sign_date)
    for raw in sources:
        try:
            return fgis_date(raw, source="fill_date/sign_date")
        except FsaSourceError:
            continue
    raise FsaSourceError("Нет действительной fill_date или sign_date")


@dataclass(frozen=True)
class OriginalHeader:
    doc_id: str
    creation_date: str
    start_date: str
    validity_date: str
    application_date: str
    data_status_id: str
    protocol_status_id: str
    object_type_id: int
    object_name: str


def build_header(
    *, number: str, protocol_date: str | date | datetime,
    measurement_dates: tuple[str | date | datetime, ...],
    application_date: str | date | datetime, factor_id: int | str,
    data_status: str | int, object_name_override: str = "",
    protocol_status: str | int = "6",
) -> OriginalHeader:
    """VBA FillPrototcolData: dates min/max; 10=production environment.

    `protocol_date` is original `fill_date` (not unverified sign_date).
    `application_date` is `v5_org_options.query_date`; never manufacture it.
    """
    if not str(number).strip():
        raise FsaSourceError("Отсутствует номер протокола")
    measured = [fgis_date(item, source="factor/@izm_date") for item in measurement_dates]
    if not measured:
        raise FsaSourceError("Не найдены даты измерений")
    factor = str(factor_id).strip()
    object_name = object_name_override.strip() or FACTOR_OBJECT_NAMES.get(factor, "")
    if not object_name:
        raise FsaSourceError("Не установлен FullNameObject для фактора: " + factor)
    creation = fgis_date(protocol_date, source="fill_date")
    requested = fgis_date(application_date, source="v5_org_options.query_date")
    if requested > creation:
        raise FsaSourceError("Дата заявки позднее даты протокола")
    if min(measured) > creation:
        raise FsaSourceError("Дата измерений позднее даты протокола")
    return OriginalHeader(
        str(number).strip(), creation, min(measured), max(measured),
        requested, fgis_status(data_status),
        fgis_status(protocol_status, protocol=True), 10, object_name
    )
