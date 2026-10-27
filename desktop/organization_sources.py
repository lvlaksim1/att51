"""Original v5_org_options customer data, read without Word or MDB changes.

Verified original:
  fill_org_info(): SELECT * FROM struct_org WHERE id=org_id
  fill_org_info_XML(): main_fs_path/000_org_data/{mguid}/adv_data.xml
  Document/dop_info/@query_date
Only single-organization sources are automatically selected; multiple
organizations must never be guessed.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from att51_fsa.sources import AccessReader, FsaSourceError, files_directory, parse_xml
from att51_fsa.export_2025 import CustomerSettings


@dataclass(frozen=True)
class OrganizationSource:
    org_id: str
    guid: str
    name: str
    inn: str
    ogrn: str
    fio: str
    query_date: str
    xml_file: Path | None
    address1: str = ""
    address2: str = ""
    contacts: str = ""
    # Only an explicitly recorded value is allowed; no guessing from name/INN.
    customer_kind: int = 0


def _field(record: dict, key: str) -> str:
    return str(next((v for k, v in record.items()
                     if str(k).lower() == key.lower() and v is not None), "")).strip()


def _advanced_xml(base: Path, guid: str) -> Path | None:
    # Original "org_guid" comes from STRUCT_ORG.mguid. Reject paths that
    # could read files outside the original source directory.
    if not guid or guid in (".", "..") or "/" in guid or "\\" in guid or ":" in guid:
        return None
    root = base / "000_org_data"
    path = root / guid / "adv_data.xml"
    if not path.is_relative_to(root):
        return None
    return path


def load_organizations(database: Path) -> tuple[OrganizationSource, ...]:
    database = Path(database)
    with AccessReader(database) as db:
        tables = set(db.table_names())
        if "STRUCT_ORG" not in {str(t).upper() for t in tables}:
            return ()
        rows = db.select("SELECT * FROM struct_org")
    base = files_directory(database)
    output: list[OrganizationSource] = []
    for row in rows:
        guid = _field(row, "mguid")
        xml = _advanced_xml(base, guid)
        request = ""
        ogrn = _field(row, "ogrn")
        if xml is not None and xml.is_file():
            parsed = parse_xml(xml)
            document = parsed if parsed.tag == "Document" else parsed.find(".//Document")
            details = document.find("./dop_info") if document is not None else None
            if details is not None:
                request = details.get("query_date", "").strip()
            reserve = document.find("./org_reserve") if document is not None else None
            if reserve is not None and reserve.get("ogrn", "").strip():
                ogrn = reserve.get("ogrn", "").strip()
        # Source kind is optional. An absent/unknown type stays unknown (0).
        kind_value = _field(row, "customer_kind")
        if xml is not None and xml.is_file() and document is not None:
            reserve_kind = reserve.get("customer_kind", "").strip() if reserve is not None else ""
            if reserve_kind:
                kind_value = reserve_kind
        kind = int(kind_value) if kind_value in ("1", "2", "4") else 0
        output.append(OrganizationSource(
            org_id=_field(row, "id"), guid=guid,
            name=_field(row, "org"), inn=_field(row, "inn"),
            ogrn=ogrn, fio=_field(row, "fio"),
            query_date=request, xml_file=xml if xml is not None and xml.is_file() else None,
            address1=_field(row, "adr"), address2=_field(row, "adr2"),
            contacts=_field(row, "contact"),
            customer_kind=kind,
        ))
    return tuple(output)


def unique_organization(database: Path) -> OrganizationSource | None:
    rows = load_organizations(database)
    return rows[0] if len(rows) == 1 else None


def customer_for_excel(database: Path) -> CustomerSettings:
    """Build Excel inputs without any UI from the single original organization.

    Multiple organizations are ambiguous: never silently attach a random
    customer's identifiers or addresses to unrelated protocols.
    """
    sources = load_organizations(Path(database))
    if len(sources) != 1:
        if not sources:
            raise FsaSourceError(
                "Excel не сформирован: в исходной MDB отсутствует запись STRUCT_ORG "
                "с реквизитами заказчика."
            )
        raise FsaSourceError(
            "Excel не сформирован: в STRUCT_ORG несколько организаций ("
            + str(len(sources)) + "). Нельзя автоматически выбрать заказчика."
        )
    source = sources[0]
    return CustomerSettings(
        application_date=source.query_date,
        customer_kind=source.customer_kind,
        inn=source.inn,
        ogrn=source.ogrn,
        full_name=source.name,
        fio=source.fio,
        address=source.address2 or source.address1,
        contacts=source.contacts,
        source_address1=source.address1,
        source_address2=source.address2,
    )
