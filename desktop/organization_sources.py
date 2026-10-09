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
        if xml is not None and xml.is_file():
            parsed = parse_xml(xml)
            document = parsed if parsed.tag == "Document" else parsed.find(".//Document")
            details = document.find("./dop_info") if document is not None else None
            if details is not None:
                request = details.get("query_date", "").strip()
        output.append(OrganizationSource(
            org_id=_field(row, "id"), guid=guid,
            name=_field(row, "org"), inn=_field(row, "inn"),
            ogrn=_field(row, "short_caption"), fio=_field(row, "fio"),
            query_date=request, xml_file=xml if xml is not None and xml.is_file() else None,
            address1=_field(row, "adr"), address2=_field(row, "adr2"),
            contacts=_field(row, "contact"),
        ))
    return tuple(output)


def unique_organization(database: Path) -> OrganizationSource | None:
    rows = load_organizations(database)
    return rows[0] if len(rows) == 1 else None
