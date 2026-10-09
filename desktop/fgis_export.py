"""Whole-base independent FGIS XML generation with a fail-closed readiness report.

All original MDB/XML/INI files are read only. A publication-grade output is
NOT claimed: XSD compatibility is checked but portal acceptance and exact
output equivalence to Word VBA remain subject to field verification.
No incomplete protocol is silently dropped.
"""
from __future__ import annotations

from dataclasses import dataclass
import os
from pathlib import Path
import tempfile

from att51_fsa.export_2025 import CustomerSettings, prepare_protocol
from att51_fsa.labour_2025 import LabourOptions
from att51_fsa.pipeline_2025 import Original2025Options
from att51_fsa.resources import ResourceCatalog
from att51_fsa.sources import FsaSourceError, parse_xml
from att51_fsa.writer import serialize_protocols, validate_xml

from source_settings import application_data_dir
from whole_base_reports import read_inventory


RESULT_FILE = "Проверка_и_формирование_XML_ФГИС.txt"


@dataclass(frozen=True)
class ExportResult:
    report: Path
    files: tuple[Path, ...]
    total: int
    eligible: int

    @property
    def ready(self) -> bool:
        return bool(self.files)


def _save_bytes(data: bytes, target: Path) -> None:
    """No partial XML on interruption; never touch any original source."""
    transient = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="wb", dir=target.parent, prefix=".fsa-export-",
            suffix=".tmp", delete=False
        ) as stream:
            transient = Path(stream.name)
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(transient, target)
    finally:
        if transient:
            transient.unlink(missing_ok=True)


def _save_text(content: str, target: Path) -> Path:
    # Consistent with diagnostic reports, UTF-8 BOM for Windows Notepad.
    _save_bytes(b"\\xef\\xbb\\xbf".decode("unicode_escape").encode("latin1") +
                content.encode("utf-8"), target)
    return target


def create_fgis_export(
    database: Path, resources: Path, ini: Path | None, customer: CustomerSettings,
    original_schema: Path, *,
    labour: LabourOptions | None = None,
    directory: Path | None = None,
) -> ExportResult:
    target = Path(directory) if directory else application_data_dir().parent / "reports"
    target.mkdir(parents=True, exist_ok=True)
    lines = [
        "ATT51_EXPORT — ПРОВЕРКА ИТОГОВОЙ ВЫГРУЗКИ ФГИС ФСА",
        "Проверка по оригинальной fileProtocolLoad_v4.xsd; это не подтверждение приёма порталом.",
        "Оригинальные MDB/XML/INI не изменяются. Несопоставленные ID не подменяются.",
    ]
    issues: list[str] = list(customer.validate())
    prepared = []
    try:
        places, items, _ = read_inventory(Path(database))
    except (FsaSourceError, OSError, ValueError) as exc:
        items = []
        issues.append("База рабочих мест: " + str(exc))
    try:
        catalog = ResourceCatalog.from_mdb(Path(resources))
    except (FsaSourceError, OSError, ValueError) as exc:
        catalog = None
        issues.append("База ресурсов: " + str(exc))
    if not items:
        issues.append("Нет протоколов для выгрузки")
    opts = Original2025Options(labour=labour or LabourOptions())
    seen = set()
    for ix, item in enumerate(items, 1):
        number = f"Протокол {ix}, РМ {item['rm_id']}, фактор {item['factor_id']}"
        xml = item["xml"]
        if xml is None or not xml.is_file():
            issues.append(number + ": отсутствует связанный внутренний XML")
            continue
        try:
            original = parse_xml(xml)
            doc = original if original.tag=="Document" else original.find(".//Document")
            fac = doc.find("./factor") if doc is not None else None
            if fac is None or fac.get("facid", "") != item["factor_id"]:
                issues.append(number+": фактор XML и основной MDB не совпадают")
                continue
            if catalog is None:
                continue
            proposed = prepare_protocol(original,catalog,customer,options=opts,
                                        working_ini=Path(ini) if ini else None)
            if proposed.blockers:
                issues.extend(number + ": " + s for s in proposed.blockers)
            if proposed.protocol:
                key = (proposed.protocol.doc_id, proposed.protocol.creation_date)
                if key in seen:
                    issues.append(number+": повторение номера и даты протокола")
                seen.add(key)
                prepared.append(proposed.protocol)
        except (FsaSourceError, OSError, ValueError) as exc:
            issues.append(number + ": ошибка исходных данных: " + str(exc))
    issues = list(dict.fromkeys(issues))
    lines += [f"Протоколов в рабочей MDB: {len(items)}",
              f"Полностью подготовлено для проверки: {len(prepared)}"]
    if issues:
        lines += ["", "ВЫГРУЗКА ЗАБЛОКИРОВАНА: недостаточно подтверждённых данных."]
        lines += ["- " + item for item in issues]
        report = _save_text("\n".join(lines)+"\n",target / RESULT_FILE)
        return ExportResult(report,(),len(items),len(prepared))
    output = serialize_protocols(prepared, verified_mapping=True)
    failures=[]
    for ix, blob in enumerate(output,1):
        valid, problem=validate_xml(blob,Path(original_schema))
        if not valid:
            failures.append("Файл "+str(ix)+": "+problem)
    if failures:
        lines+=["","ВЫГРУЗКА ЗАБЛОКИРОВАНА: XSD не пройдена."]
        lines+=["- "+x for x in failures]
        report=_save_text("\n".join(lines)+"\n",target / RESULT_FILE)
        return ExportResult(report,(),len(items),len(prepared))
    files=[]
    for ix, blob in enumerate(output,1):
        dest=target / ("fsa_prot.xml" if len(output)==1 else f"fsa_prot{ix}.xml")
        _save_bytes(blob,dest)
        files.append(dest)
    lines+=["","XSD: успешно для всех файлов.",
            "Итоговый XML создан из подтверждённых данных; ФГИС его приём не проверен.",
            "Файлы:"]
    lines+=["- "+str(path) for path in files]
    report=_save_text("\n".join(lines)+"\n",target / RESULT_FILE)
    return ExportResult(report,tuple(files),len(items),len(prepared))
