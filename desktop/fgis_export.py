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
from att51_fsa.aerosol_2025 import ChemicalOptions
from att51_fsa.pipeline_2025 import Original2025Options
from att51_fsa.resources import ResourceCatalog
from att51_fsa.sources import FsaSourceError, parse_xml
from att51_fsa.writer import serialize_protocols, validate_xml

from source_settings import application_data_dir
from protocol_batch import prepare_batch


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
    chemical: ChemicalOptions | None = None,
    directory: Path | None = None,
) -> ExportResult:
    target = Path(directory) if directory else application_data_dir().parent / "reports"
    target.mkdir(parents=True, exist_ok=True)
    lines = [
        "ATT51_EXPORT — ПРОВЕРКА ИТОГОВОЙ ВЫГРУЗКИ ФГИС ФСА",
        "Проверка по оригинальной fileProtocolLoad_v4.xsd; это не подтверждение приёма порталом.",
        "Оригинальные MDB/XML/INI не изменяются. Несопоставленные ID не подменяются.",
        "Выбранная база ресурсов: " + str(resources),
    ]
    batch = prepare_batch(
        Path(database), Path(resources), ini, customer,
        labour=labour, chemical=chemical)
    issues = list(batch.issues)
    prepared = [item.protocol for item in batch.protocols]
    lines.extend(batch.resource_lines)
    issues = list(dict.fromkeys(issues))
    lines += [f"Протоколов в рабочей MDB: {batch.total}",
              f"Полностью подготовлено для проверки: {len(prepared)}"]
    if issues:
        lines += ["", "ВЫГРУЗКА ЗАБЛОКИРОВАНА: недостаточно подтверждённых данных."]
        lines += ["- " + item for item in issues]
        report = _save_text("\n".join(lines)+"\n",target / RESULT_FILE)
        return ExportResult(report,(),batch.total,len(prepared))
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
        return ExportResult(report,(),batch.total,len(prepared))
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
    return ExportResult(report,tuple(files),batch.total,len(prepared))
