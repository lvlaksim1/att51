"""Two complete read-only text reports across all ATT51 workplaces and factors.

No factor whitelist, individual XML selection or mandatory resource mapping.
Every unrecognized source attribute/text value is written as-is to the local
report; an FGIS identifier is shown only when genuinely present in resources.
Reports are overwritten atomically inside the application's own reports folder.
"""
from __future__ import annotations

from collections import defaultdict
from datetime import date, datetime
import json
import os
from pathlib import Path
import tempfile
from typing import Any
from xml.etree import ElementTree as ET

from att51_fsa.sources import (
    AccessReader, FsaSourceError, files_directory, parse_xml, resolve_relative_file,
)
from att51_fsa.resources import ResourceCatalog
from source_settings import application_data_dir


INDEX_FILE = "Рабочие_места_и_протоколы.txt"
DETAIL_FILE = "Подробные_сведения_протоколов.txt"


def _value(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    if isinstance(value, bytes):
        return value.hex()
    return str(value)


def _field(record: dict[str, Any], *candidates: str) -> str:
    lowered = {str(key).casefold(): value for key, value in record.items()}
    for key in candidates:
        value = lowered.get(key.casefold())
        if value is not None and _value(value).strip():
            return _value(value).strip()
    return ""


def _workplace_number(row: dict[str, Any]) -> str:
    return _field(row, "rm_num", "num_rm", "number_rm", "rm_number",
                  "workplace_number", "rm_n", "num", "number", "n_rm", "nomer",
                  "nomer_rm", "code", "shifr", "rm_code")


def _workplace_name(row: dict[str, Any]) -> str:
    return _field(row, "rm_name", "name_rm", "workplace_name", "name",
                  "rm_title", "title", "nazvanie", "naimenovanie", "prof",
                  "profession", "dolgnost", "post", "job", "work_name")


def _xml_path(root: Path, record: dict[str, Any]) -> tuple[str, Path | None, str]:
    relative = _field(record, "file")
    if not relative:
        return "", None, "Ссылка на документ отсутствует в sout_factors.file"
    try:
        word = resolve_relative_file(root, relative)
        if word.suffix.casefold() not in (".doc", ".docx"):
            return str(word), None, "Указанный документ не имеет расширения DOC/DOCX"
        return str(word), word.parent / "xml" / (word.stem + ".xml"), ""
    except (FsaSourceError, ValueError, OSError) as exc:
        return relative, None, "Небезопасная или неверная ссылка: " + str(exc)


def read_inventory(database: Path) -> tuple[list[dict], list[dict], Path]:
    """Read raw MDB rows without the legacy supported-factor filter."""
    database = Path(database)
    root = files_directory(database)
    with AccessReader(database) as connection:
        tables = connection.table_names()
        if "STRUCT_RM" not in tables or "SOUT_FACTORS" not in tables:
            raise FsaSourceError(
                "В рабочей MDB не найдены STRUCT_RM и/или SOUT_FACTORS.")
        workplace_rows = connection.select("SELECT * FROM struct_rm")
        factor_rows = connection.select("SELECT * FROM sout_factors")

    places: list[dict] = []
    for row in workplace_rows:
        key = _field(row, "id")
        if not key:
            # Retain the raw record even if its ID is missing/corrupt.
            key = "[без ID]"
        places.append({
            "id": key,
            "number": _workplace_number(row),
            "name": _workplace_name(row),
            "fields": row,
        })
    places.sort(key=lambda w: (int(w["id"]) if w["id"].isdigit() else 10**12,
                               w["id"]))
    protocols: list[dict] = []
    for row in factor_rows:
        word, xml, problem = _xml_path(root, row)
        protocols.append({
            "rm_id": _field(row, "rm_id"),
            "factor_id": _field(row, "factor_id"),
            "factor_name": _field(row, "factor_name", "name"),
            "word": word,
            "xml": xml,
            "problem": problem,
            "fields": row,
        })
    protocols.sort(key=lambda p: (int(p["rm_id"]) if p["rm_id"].isdigit() else 10**12,
                                  p["rm_id"], p["factor_id"], p["word"]))
    return places, protocols, root


def _header(title: str, database: Path, resources: Path, ini: Path | None) -> list[str]:
    return [
        "ATT51_EXPORT — " + title,
        "Это локальный диагностический текстовый отчёт, НЕ XML ФГИС ФСА.",
        "Источники открыты только для чтения. Значения и ссылки не подменяются.",
        "База организации: " + str(database),
        "База ресурсов: " + str(resources),
        "fgis_ra.ini: " + (str(ini) if ini else "не найден / не задан"),
        "",
    ]


def _dump_fields(data: dict) -> list[str]:
    return ["    " + str(key) + " = " + json.dumps(
        _value(value), ensure_ascii=False) for key, value in data.items()]


def report_index(database: Path, resources: Path, ini: Path | None = None) -> str:
    places, protocols, _ = read_inventory(database)
    grouped: dict[str, list[dict]] = defaultdict(list)
    for item in protocols:
        grouped[item["rm_id"]].append(item)
    out = _header("ПЕРЕЧЕНЬ РАБОЧИХ МЕСТ И ПРОТОКОЛОВ",
                  database, resources, ini)
    out.extend([
        "Рабочих мест (записей STRUCT_RM): " + str(len(places)),
        "Протоколов (записей SOUT_FACTORS): " + str(len(protocols)),
        "Учитываются ВСЕ записи и ВСЕ факторы, в том числе без XML.",
        "",
    ])
    seen: set[str] = set()
    for order, place in enumerate(places, 1):
        key = place["id"]
        seen.add(key)
        out += ["=" * 72,
                f"РАБОЧЕЕ МЕСТО {order} | ID: {key}",
                "Номер: " + (place["number"] or "не определён из именованных полей"),
                "Наименование: " + (place["name"] or "не определено из именованных полей"),
                "Исходные поля записи рабочего места:"]
        out.extend(_dump_fields(place["fields"]))
        subset = grouped.get(key, [])
        out.append("Протоколов: " + str(len(subset)))
        for seq, p in enumerate(subset, 1):
            out.extend([
                f"  {seq}. Фактор: {p['factor_name'] or '[название отсутствует]'} "
                f"(ID {p['factor_id'] or 'не указан'})",
                "     Word: " + (p["word"] or "не указан"),
                "     XML: " + (str(p["xml"]) if p["xml"] else "не определён"),
                "     Наличие XML: " + (
                    "да" if p["xml"] is not None and p["xml"].is_file()
                    else "нет"),
            ])
            if p["problem"]:
                out.append("     Примечание: " + p["problem"])
    orphaned = [p for p in protocols if p["rm_id"] not in seen]
    if orphaned:
        out.extend(["=" * 72, "ПРОТОКОЛЫ БЕЗ СООТВЕТСТВУЮЩЕЙ ЗАПИСИ РАБОЧЕГО МЕСТА"])
        for p in orphaned:
            out.append(f"РМ ID {p['rm_id']} | фактор {p['factor_id']} | "
                       f"XML: {p['xml'] or '[не определён]'}")
    out.extend(["=" * 72, "Конец отчёта."])
    return "\n".join(out) + "\n"


def _xml_values(root: ET.Element):
    """Traverse every element, attribute and textual value for ANY factor."""
    stack = [(root, "/" + str(root.tag) + "[1]")]
    while stack:
        element, path = stack.pop()
        yield path + "  [элемент]"
        for key, value in element.attrib.items():
            yield path + "/@" + key + " = " + json.dumps(value, ensure_ascii=False)
        if element.text and element.text.strip():
            yield path + "/#text = " + json.dumps(element.text, ensure_ascii=False)
        if element.tail and element.tail.strip():
            yield path + "/#tail = " + json.dumps(element.tail, ensure_ascii=False)
        counts: dict[str, int] = defaultdict(int)
        children = []
        for child in list(element):
            counts[child.tag] += 1
            children.append((child, path + "/" + str(child.tag) +
                             "[" + str(counts[child.tag]) + "]"))
        stack.extend(reversed(children))


def _resource_cross_refs(root: ET.Element, catalog: ResourceCatalog | None) -> list[str]:
    """Never replace the raw XML references, even when an FGIS id is absent."""
    lines = ["СОПОСТАВЛЕНИЕ (исходные значения выше сохранены без изменений):"]
    for i, element in enumerate(root.iter(), 1):
        tag = str(element.tag).casefold()
        if tag == "si_guid":
            guid, number = element.get("guid", ""), element.get("num", "")
            hit = catalog.device(guid, number) if catalog else None
            label = f"  Прибор {i}: guid={json.dumps(guid, ensure_ascii=False)}, " + (
                "номер=" + json.dumps(number, ensure_ascii=False))
        elif tag == "pers":
            guid, number = element.get("guid", ""), element.get("snils", "")
            hit = catalog.person(guid, number) if catalog else None
            label = f"  Сотрудник {i}: guid={json.dumps(guid, ensure_ascii=False)}, " + (
                "СНИЛС=" + json.dumps(number, ensure_ascii=False))
        else:
            continue
        if hit and hit.found:
            label += "; справочник: " + hit.display_name
            label += "; ID ФГИС: " + (
                hit.fgis_id if hit.fgis_id and hit.fgis_id != "0" else "не сопоставлен")
        else:
            label += "; ID ФГИС: не сопоставлен (исходные значения сохранены)"
        lines.append(label)
    if len(lines) == 1:
        lines.append("  Ссылки на приборы/сотрудников не обнаружены по известным тегам.")
    return lines


def report_details(database: Path, resources: Path, ini: Path | None = None) -> str:
    places, protocols, _ = read_inventory(database)
    out = _header("ПОДРОБНЫЕ СВЕДЕНИЯ ВСЕХ ПРОТОКОЛОВ",
                  database, resources, ini)
    out.append("Всего записей протоколов: " + str(len(protocols)))
    out.append("Ограничения по factor_id НЕТ. Обработка не требует ID ФГИС.")
    place_index = {p["id"]: p for p in places}
    try:
        catalog = ResourceCatalog.from_mdb(resources)
        catalog_error = ""
    except (FsaSourceError, OSError, ValueError) as exc:
        catalog = None
        catalog_error = str(exc)
    if catalog_error:
        out.append("Внимание: ресурсные соответствия недоступны: " + catalog_error)
        out.append("Все исходные поля протоколов всё равно будут приведены без замены.")
    out.append("")
    successes = 0
    for seq, p in enumerate(protocols, 1):
        place = place_index.get(p["rm_id"])
        out.extend([
            "=" * 72,
            "ПРОТОКОЛ " + str(seq) + " ИЗ " + str(len(protocols)),
            "РМ ID: " + p["rm_id"],
            "Номер РМ: " + (place["number"] if place and place["number"] else "не определён"),
            "Наименование РМ: " + (place["name"] if place and place["name"] else "не определено"),
            "Фактор ID: " + (p["factor_id"] or "не указан"),
            "Название фактора: " + (p["factor_name"] or "не указано"),
            "Word: " + (p["word"] or "не указан"),
            "XML: " + (str(p["xml"]) if p["xml"] else "не определён"),
            "Исходные поля записи SOUT_FACTORS:",
        ])
        out.extend(_dump_fields(p["fields"]))
        xml = p["xml"]
        if xml is None or not xml.is_file():
            out.append("Содержимое: недоступно (XML отсутствует или путь не определён).")
            if p["problem"]:
                out.append("Причина: " + p["problem"])
            continue
        try:
            parsed = parse_xml(xml)
            successes += 1
            out.append("Все элементы, атрибуты и текстовые значения исходного XML:")
            out.extend("  " + line for line in _xml_values(parsed))
            out.extend(_resource_cross_refs(parsed, catalog))
        except (FsaSourceError, OSError, ValueError) as exc:
            out.append("Ошибка чтения XML (остальные протоколы продолжают обрабатываться): "
                       + str(exc))
    out.extend([
        "=" * 72,
        "Успешно прочитано внутренних XML: " + str(successes),
        "Всего записей протоколов: " + str(len(protocols)),
        "Отсутствующие / нечитаемые XML не были подменены другими файлами.",
        "Ни один несопоставленный ID ФГИС не был придуман.",
        "Это ТЕКСТОВЫЙ диагностический отчёт, не готовый XML ФГИС ФСА.",
    ])
    return "\n".join(out) + "\n"


def write_report(content: str, filename: str, directory: Path | None = None) -> Path:
    if filename not in (INDEX_FILE, DETAIL_FILE):
        raise ValueError("Неизвестный тип отчёта.")
    folder = Path(directory) if directory is not None else application_data_dir().parent / "reports"
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / filename
    temp: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8-sig", newline="\n",
            prefix=".att51-report-", suffix=".tmp", dir=folder, delete=False
        ) as stream:
            temp = Path(stream.name)
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp, target)
    finally:
        if temp is not None:
            temp.unlink(missing_ok=True)
    return target


def create_index(database: Path, resources: Path, ini: Path | None = None,
                 *, directory: Path | None = None) -> Path:
    return write_report(report_index(database, resources, ini), INDEX_FILE, directory)


def create_details(database: Path, resources: Path, ini: Path | None = None,
                   *, directory: Path | None = None) -> Path:
    return write_report(report_details(database, resources, ini), DETAIL_FILE, directory)
