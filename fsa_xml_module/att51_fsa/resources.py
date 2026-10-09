"""Read-only resolver for ATT51 resource database res_orgs.mdb.

Original VBA evidence:
  v5_res_main.fill_si_errs, get_si_by_num, fil_pers_data,
  read_fgis_ra_data, get_fgis_ra_number
  v52_exp_fgis_ra.get_pers_info, get_fgis_dev_id, get_fgis_pers_id
  v5_options_dic.fill_dic, ReadSynonyms, get_nd_by_name
  prot_api.get_nd_hash

No creation of missing tables, writes, Word automation or synthetic FGIS IDs.
The actual resource MDB may be shared (DB_res.res_flag/res_path).
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable, Mapping

from .sources import AccessReader, FsaSourceError, read_ini


def resource_mdb_path(application_folder: Path, *, options_ini: Path | None = None) -> Path:
    """Select the same local/shared resource MDB as v5_res_main.read.

    [DB_res] res_flag=1 -> use res_path, otherwise app/res_orgs.mdb.
    This function reads configuration but never creates or changes files.
    """
    root = Path(application_folder)
    ini = Path(options_ini) if options_ini is not None else root / "options.ini"
    if not ini.is_file():
        raise FsaSourceError(f"Original settings file missing: {ini}")
    flag = read_ini(ini, "DB_res", "res_flag")
    if flag == "1":
        linked_path = read_ini(ini, "DB_res", "res_path")
        if not linked_path:
            raise FsaSourceError("DB_res.res_flag=1 but shared res_path is empty")
        path = Path(linked_path)
    else:
        path = root / "res_orgs.mdb"
    if not path.is_file():
        raise FsaSourceError(f"Original resource MDB not found: {path}")
    return path


def _str(value: Any) -> str:
    return "" if value is None else str(value)


def _num(value: Any) -> str:
    """VB Val/format_lng equivalent for the integer FGIS_RA.IntValue field."""
    if value is None or value == "":
        return ""
    try:
        return str(int(value))
    except (ValueError, TypeError):
        return ""


def nd_hash(name: str) -> str:
    """Literal original prot_api.get_nd_hash: digits and а/о/и/я/е only."""
    return "".join(char for char in name.lower() if char in "1234567890аоияе")


def has_digits(value: str) -> bool:
    return any(c in "0123456789" for c in value)


@dataclass(frozen=True)
class Device:
    local_id: str
    guid: str
    factory_number: str
    name: str


@dataclass(frozen=True)
class Person:
    guid: str
    snils: str
    fio: str
    surname: str
    given_name: str
    patronymic: str
    job: str
    fgis_position: str = ""


@dataclass(frozen=True)
class FgisLink:
    type_id: int
    guid: str
    fgis_id: str
    description: str = ""


@dataclass(frozen=True)
class OaMethod:
    nd_guid: str
    method: str
    params: str


@dataclass(frozen=True)
class Normative:
    local_id: str
    guid: str
    name: str
    short_name: str
    factor_id: str
    typ: str
    method_doc_id: str
    preference: str
    oa_method: str
    synonyms: tuple[str, ...] = ()


@dataclass(frozen=True)
class ResourceResolution:
    kind: str
    source_rule: str
    found: bool
    local_guid: str = ""
    local_id: str = ""
    fgis_id: str = ""
    display_name: str = ""
    requires_review: bool = True
    warnings: tuple[str, ...] = ()


@dataclass(frozen=True)
class NdResolution:
    found: bool
    source_rule: str
    normative: Normative | None
    alternatives: int = 0
    requires_review: bool = True
    warnings: tuple[str, ...] = ()


@dataclass(frozen=True)
class CatalogDiagnostics:
    tables_present: tuple[str, ...]
    tables_absent: tuple[str, ...]
    device_count: int
    person_count: int
    normative_count: int
    fgis_link_count: int
    oa_method_count: int = 0


class ResourceCatalog:
    """Snapshot of the original MDB recordsets, preserving record order.

    Important: older installation templates lack optional tables because the
    original app creates them on first open. We detect that and report it; we
    DO NOT attempt to create/upgrade tables in a real working resource MDB.
    """

    REQUIRED = ("ATT_DEVICE", "ATT_PERSON", "DIC_ND")
    OPTIONAL = ("FGIS_RA", "DIC_ND_INFO", "DIC_ND_SYN", "ATT_DOP_INFO", "DIC_ND_OA_METHODS")

    def __init__(self, devices: Iterable[Device], people: Iterable[Person],
                 normative: Iterable[Normative], links: Iterable[FgisLink],
                 diagnostics: CatalogDiagnostics,
                 oa_methods: Iterable[OaMethod] = ()):
        self.devices = tuple(devices)
        self.people = tuple(people)
        self.normative = tuple(normative)
        self.links = tuple(links)
        self.oa_methods = tuple(oa_methods)
        self.diagnostics = diagnostics

    @classmethod
    def from_rows(
        cls,
        devices: Iterable[Mapping[str, Any]],
        people: Iterable[Mapping[str, Any]],
        normative: Iterable[Mapping[str, Any]],
        links: Iterable[Mapping[str, Any]],
        nd_info: Iterable[Mapping[str, Any]] = (),
        synonyms: Iterable[Mapping[str, Any]] = (),
        oa_methods: Iterable[Mapping[str, Any]] = (),
        *,
        present_tables: Iterable[str] | None = None,
    ) -> "ResourceCatalog":
        """Pure transformation used by tests and the actual ADO reader.

        Schema uses original Jet field names and never invents FGIS identifiers.
        """
        info_index = {_str(row.get("nd_id")): row for row in nd_info}
        synonym_index: dict[str, list[str]] = {}
        for row in synonyms:
            key = _str(row.get("mguid"))
            if key:
                synonym_index.setdefault(key, []).append(_str(row.get("name")))
        devices_result = [
            Device(_str(row.get("id")), _str(row.get("mguid")),
                   _str(row.get("factory_num")), _str(row.get("name")))
            for row in devices
        ]
        people_result = [
            Person(_str(row.get("mguid")), _str(row.get("snils")),
                   _str(row.get("fio")), _str(row.get("name_f")),
                   _str(row.get("name_i")), _str(row.get("name_o")),
                   _str(row.get("dolg")), _str(row.get("no_dop_fld2")))
            for row in people
        ]
        normatives: list[Normative] = []
        for row in normative:
            local_id = _str(row.get("id"))
            info = info_index.get(local_id, {})
            guid = _str(row.get("mguid"))
            normatives.append(Normative(
                local_id=local_id, guid=guid, name=_str(row.get("name")),
                short_name=_str(info.get("key_ctxt")),
                factor_id=_str(row.get("factor_id")), typ=_str(row.get("typ")),
                method_doc_id=_num(info.get("dop2")),
                preference=_str(info.get("dop4")),
                oa_method=_str(info.get("dop5")),
                synonyms=tuple(synonym_index.get(guid, ())),
            ))
        links_result = [
            FgisLink(int(row["rec_type"]), _str(row.get("rec_guid")),
                     _num(row.get("IntValue")), _str(row.get("Descr")))
            for row in links
            if row.get("rec_type") is not None
        ]
        oa_entries = [
            OaMethod(_str(row.get("nd_guid")), _str(row.get("method")),
                     _str(row.get("params")))
            for row in oa_methods if _str(row.get("nd_guid")).strip()
        ]
        present = set(present_tables) if present_tables is not None else set(cls.REQUIRED + cls.OPTIONAL)
        absent = tuple(name for name in cls.REQUIRED + cls.OPTIONAL if name not in present)
        diag = CatalogDiagnostics(
            tables_present=tuple(sorted(present)), tables_absent=absent,
            device_count=len(devices_result), person_count=len(people_result),
            normative_count=len(normatives), fgis_link_count=len(links_result),
            oa_method_count=len(oa_entries),
        )
        return cls(devices_result, people_result, normatives, links_result, diag,
                   oa_methods=oa_entries)

    @classmethod
    def from_reader(cls, reader: AccessReader) -> "ResourceCatalog":
        names = set(reader.table_names())
        missing = set(cls.REQUIRED) - names
        if missing:
            raise FsaSourceError("Required original resource tables missing: " + ", ".join(sorted(missing)))
        def read(name: str) -> list[dict[str, Any]]:
            return reader.select(f"SELECT * FROM [{name}]") if name in names else []
        return cls.from_rows(
            read("ATT_DEVICE"), read("ATT_PERSON"), read("DIC_ND"),
            read("FGIS_RA"), read("DIC_ND_INFO"), read("DIC_ND_SYN"),
            oa_methods=read("DIC_ND_OA_METHODS"), present_tables=names,
        )

    @classmethod
    def from_mdb(cls, path: Path) -> "ResourceCatalog":
        with AccessReader(Path(path)) as reader:
            return cls.from_reader(reader)

    def _fgis(self, type_id: int, guid: str) -> str:
        # v5_res_main.get_fgis_ra_number selects the first exact match.
        for link in self.links:
            if link.type_id == type_id and link.guid == guid:
                return link.fgis_id
        return ""

    def device(self, guid: str = "", factory_number: str = "") -> ResourceResolution:
        found = None
        rule = "not_found"
        for obj in self.devices:
            if obj.guid == guid and guid:
                found, rule = obj, "guid"
                break
        if found is None and has_digits(factory_number):
            for obj in self.devices:
                if obj.factory_number == factory_number:
                    found, rule = obj, "factory_num"
                    break
        if found is None:
            return ResourceResolution("device", rule, False, warnings=("device_not_found",))
        fgis = self._fgis(0, found.guid)
        warnings = () if fgis and fgis != "0" else ("equipment_fgis_id_missing",)
        return ResourceResolution(
            "device", rule, True, found.guid, found.local_id, fgis, found.name,
            bool(warnings), warnings,
        )

    def person(self, guid: str = "", snils: str = "") -> ResourceResolution:
        # v52_exp_fgis_ra.get_pers_info: first exact GUID, then SNILS
        # only when a digit is present. The original calls get_num(snils).
        found = None
        rule = "not_found"
        for obj in self.people:
            if obj.guid == guid and guid:
                found, rule = obj, "guid"
                break
        if found is None and has_digits(snils):
            for obj in self.people:
                if obj.snils == snils:
                    found, rule = obj, "snils"
                    break
        if found is None:
            return ResourceResolution("person", rule, False, warnings=("person_not_found",))
        fgis = self._fgis(1, found.guid)
        warnings = () if fgis and fgis != "0" else ("person_fgis_id_missing",)
        return ResourceResolution(
            "person", rule, True, found.guid, "", fgis, found.fio,
            bool(warnings), warnings,
        )

    @staticmethod
    def _matches_hash(item: Normative, hash_value: str) -> bool:
        return bool(hash_value) and (
            nd_hash(item.name) == hash_value
            or any(nd_hash(value) == hash_value for value in item.synonyms)
        )

    def nd(self, hashed_name: str, full_name: str, factor_id: str = "") -> NdResolution:
        """Order from v5_options_dic.get_nd_by_name (09/2026).

        Original selection may report duplicate names but uses first match.
        Short-name pass uses VBA Like and brackets are stripped; the simple
        literal-substring subset here is conservative: mark it for review.
        """
        for rule, factor_check in (("hash_with_factor", True), ("hash_any_factor", False)):
            matches = [
                n for n in self.normative
                if self._matches_hash(n, hashed_name)
                and (not factor_check or (factor_id and n.factor_id == factor_id))
            ]
            if matches:
                chosen = matches[0]
                warnings = ("duplicate_normative_matches",) if len(matches) > 1 else ()
                return NdResolution(True, rule, chosen, len(matches),
                                    bool(warnings) or chosen.method_doc_id in ("", "0", "-1"),
                                    warnings)
        # Original VBA SpecFormat removes [ and ]; other Like wildcards may
        # carry different semantics and require explicit validation.
        clean_name = full_name.replace("[", "").replace("]", "")
        for item in self.normative:
            key = item.short_name
            if len(key) > 4 and key.replace("[", "").replace("]", "") in clean_name:
                return NdResolution(True, "short_name_like", item, 1, True,
                                    ("original_vba_like_requires_verification",))
        if hashed_name == "":
            matches = [item for item in self.normative if item.name == full_name]
            if matches:
                item = matches[0]
                warnings = ("duplicate_normative_matches",) if len(matches) > 1 else ()
                return NdResolution(
                    True, "exact_name_when_hash_empty", item, len(matches),
                    bool(warnings) or item.method_doc_id in ("", "0", "-1"),
                    warnings,
                )
        return NdResolution(False, "not_found", None, 0, True,
                            ("normative_not_found",))

    def oa_method_for(self, nd_guid: str, parameter_tag: str) -> str:
        """Original v5_options_dic.GetOAMethod: first GUID + substring hit."""
        if not nd_guid or not parameter_tag:
            return ""
        for item in self.oa_methods:
            if item.nd_guid == nd_guid and parameter_tag in item.params:
                return item.method
        return ""

    def nd_preference(self, name: str) -> str | None:
        """Exact GetNDFromDistDic-like resource lookup for method priorities."""
        for item in self.normative:
            if item.name == name:
                return item.preference
        return None

    def nd_diagnostics(self, result: NdResolution, action: str = "0") -> tuple[str, ...]:
        """Replicate the original conditions for blocking vs 'other ND' path.

        The original checks a missing ND as fatal. A found ND with no
        MethodDocId may still export under 'other ND' or 'unique method',
        but the exact final section is a later transformation.
        """
        if not result.found or result.normative is None:
            return ("fatal_nd_absent",)
        item = result.normative
        if item.method_doc_id not in ("", "0", "-1"):
            return result.warnings
        if not item.short_name and action != "1":
            return result.warnings + ("fatal_nd_short_name_missing",)
        return result.warnings + (
            "other_normative_or_unique_method_requires_export_mapping",
        )
