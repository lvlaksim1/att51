"""Raw ATT51 protocol -> import-shaped Excel 97-2003 (.xls).

This is deliberately independent of FGIS numeric catalog mapping. Only
source Document values, never external FGIS IDs, are written to the workbook.
One protocol uses one row per measured indicator; shared fields appear once.
"""
from __future__ import annotations

from dataclasses import dataclass
import os
from pathlib import Path
import re
import tempfile
from typing import Iterable
from xml.etree import ElementTree as ET

from att51_fsa.sources import FsaSourceError, parse_xml
from source_settings import application_data_dir
from whole_base_reports import read_inventory


HEADERS = (
    "Номер протокола",
    "Дата начала измерения",
    "Дата окончания измерения",
    "Дата протокола",
    "Название организации заказчика",
    "Тип адреса",
    "Адрес проведния испытаний (измерений)",
    "ИНН заказчика",
    "Тип объекта испытания (измерения)",
    "Полное наименование объекта",
    "Наименование показателя",
    "Измеренное значение",
    "Единица измерения",
    "Наименование методики",
    "Наименование метода",
    "Контактные данные заказчика",
    "Дата подачи заявления",
    "Наименование нормативного документа",
    "Дата получения проб (образцов)",
    "Количество проб (образов)",
    "Дата отбора проб (образцов)",
    "Место отбора образца",
    "Наименование оборудования",
    "Провёл измерения",
    "Подписал протокол",
    "Утвердил протокол",
)
FILENAME = "Сведения_из_протоколов.xls"
MISSING = "НЕТ ДАННЫХ"
_ID_SUFFIX = re.compile(r"\s*\|\|\s*id\s+\d+\s*\|\|", flags=re.IGNORECASE)
VALUES = ("fact", "fact_value", "factvalue", "level", "levels", "result",
          "results", "cmax", "value", "measured_value")
MEASUREMENTS = ("izm_data", "izm_res_data", "izm_data2", "research_objects",
                "measurements", "results_data")


@dataclass(frozen=True)
class ExcelResult:
    file: Path
    protocol_count: int
    indicator_count: int


def _clean(value: object) -> str:
    """Keep literal protocol data, not FGIS importer annotation tokens."""
    if value is None:
        return ""
    return _ID_SUFFIX.sub("", str(value)).strip()


def _one(*values: object) -> str:
    return next((s for value in values if (s := _clean(value))), "")


def _join(values: Iterable[object]) -> str:
    """Multiple values from one field: preserve order, separate with '; '."""
    result = []
    for value in values:
        word = _clean(value)
        if word and word not in result:
            result.append(word)
    return "; ".join(result)


def _attr(node: ET.Element | None, *names: str) -> str:
    if node is None:
        return ""
    fields = {str(k).casefold(): v for k, v in node.attrib.items()}
    return _one(*(fields.get(name.casefold()) for name in names))


def _child_text(node: ET.Element | None, *names: str) -> str:
    if node is None:
        return ""
    desired = {name.casefold() for name in names}
    return _join(child.text for child in node
                 if str(child.tag).casefold() in desired)


def _from(nodes: Iterable[ET.Element | None], *names: str) -> str:
    return _one(*(_attr(node, *names) or _child_text(node, *names)
                  for node in nodes))


def _all_from(nodes: Iterable[ET.Element], *names: str) -> str:
    return _join(_attr(node, *names) or _child_text(node, *names)
                 or (_clean(node.text) if not node.attrib and not list(node) else "")
                 for node in nodes)


def _doc(root: ET.Element) -> ET.Element:
    doc = root if root.tag == "Document" else root.find(".//Document")
    if doc is None:
        raise FsaSourceError("Исходный XML не содержит Document")
    return doc


def _nd_names(doc: ET.Element) -> tuple[dict[str, str], list[str], list[str]]:
    mapping: dict[str, str] = {}
    all_names: list[str] = []
    methods: list[str] = []
    for node in doc.findall("./nd_data/nd"):
        label = _attr(node, "name", "doc_name", "title")
        if not label:
            continue
        identifier = _attr(node, "id")
        if identifier:
            mapping[identifier] = label  # only internal lookup; never exported
        all_names.append(label)
        action = _attr(node, "action")
        if action == "1" or "изм" in action.lower():
            methods.append(label)
    return mapping, all_names, methods


def _method_names(node: ET.Element, mapping: dict[str, str],
                  protocol_methods: list[str]) -> str:
    explicit = _attr(node, "methodika_name", "methodika", "methodology",
                     "nd_name", "nd_izm_name", "standard_name")
    if explicit:
        return explicit
    ids = _attr(node, "nd_izm1", "nd_izm", "normative_id")
    matched = [mapping[token.strip()] for token in re.split(r"[;,]", ids)
               if token.strip() in mapping]
    return _join(matched or protocol_methods)


def _measurement_nodes(doc: ET.Element) -> Iterable[ET.Element]:
    """Avoid misinterpreting arbitrary metadata as a measured indicator."""
    for parent_name in MEASUREMENTS:
        for parent in doc.findall("./" + parent_name):
            for item in parent.iter():
                if item is parent:
                    continue
                if any(_attr(item, name) for name in VALUES):
                    # A result-bearing leaf represents one source indicator.
                    if not any(any(_attr(child, name) for name in VALUES)
                               for child in item):
                        yield item


def _measures(doc: ET.Element, mapping: dict[str, str],
              protocol_methods: list[str]) -> list[tuple[str, str, str, str, str]]:
    result = []
    for node in _measurement_nodes(doc):
        name = _attr(node, "name", "indicator_name", "param_name",
                     "parameter_name", "caption", "title", "label", "izm_name")
        fact = _attr(node, *VALUES)
        unit = _attr(node, "unit", "unit_name", "ed_izm", "edizm",
                     "ed_izm_name", "measurement_unit", "units")
        methodology = _method_names(node, mapping, protocol_methods)
        method = _attr(node, "method_name", "method", "metod_name", "metod",
                       "method_izm", "research_method")
        result.append(tuple(_one(part) or MISSING for part in
                            (name, fact, unit, methodology, method)))
    if not result:
        return [(MISSING,) * 5]
    return result


def extract_protocol_rows(root: ET.Element) -> list[list[str]]:
    """26 template columns, only evidence from original internal Document."""
    doc = _doc(root)
    factor = doc.find("./factor")
    dop = doc.find("./dop_info")
    customer = doc.find("./customer")
    organization = doc.find("./organization")
    order = doc.find("./order")
    obj = doc.find("./object")
    main = (doc, factor, dop)
    client = (customer, organization, dop, doc)
    mapping, normatives, methods = _nd_names(doc)
    measured = _measures(doc, mapping, methods)
    start = _from(main, "izm_date_start", "start_date", "date_start",
                  "measurement_start_date", "izm_date")
    end = _from(main, "izm_date_end", "end_date", "date_end",
                "measurement_end_date", "izm_date")
    contacts = list(doc.findall(".//contact"))
    devices = list(doc.findall("./factor/si_guids/si_guid"))
    devices += doc.findall("./equipment/device") + doc.findall("./devices/device")
    device_names = [
        _one(_attr(n, "name", "device_name", "equipment_name", "si_name",
                   "full_name", "caption"))
        for n in devices
    ]
    persons = doc.findall("./persons/pers") + doc.findall("./persons/person")
    sample_nodes = doc.findall("./samples/sample") + doc.findall("./sample_data/sample")
    def role_names(*words: str) -> str:
        values = []
        for person in persons:
            role = _attr(person, "role", "role_name", "function",
                         "job", "position").casefold()
            if any(word in role for word in words):
                values.append(_attr(person, "fio", "full_name", "name",
                                    "person_name"))
        return _join(values)
    shared = [
        _from((doc,), "num_doc", "protocol_number", "number"),
        start, end,
        _from((doc,), "fill_date", "protocol_date", "sign_date", "date"),
        _from(client, "customer_name", "org", "org_name", "organization_name",
              "full_name", "client_name"),
        _from(client, "address_type", "addr_type", "type_address"),
        _from((customer, obj, dop, doc), "measurement_address", "address",
              "address_name", "address_text", "addr", "place_address"),
        _from(client, "inn", "customer_inn"),
        _from((obj, factor, doc), "object_type_name", "object_type",
              "type_object_name"),
        _from((obj, doc, factor), "object_name", "object_full_name",
              "research_object_name", "full_name_object", "factor_name"),
    ]
    trailing = [
        _join([_from(client, "contacts", "contact", "phone", "telephone", "email"),
               _all_from(contacts, "value", "phone", "email", "address")]),
        _from((dop, customer, order, doc), "query_date",
              "application_date", "request_date"),
        _join(normatives),
        _from((dop, doc), "sample_receive_date", "received_date",
              "sample_received_date"),
        _from((dop, doc), "sample_count", "samples_count",
              "quantity_samples"),
        _from((dop, doc), "sample_date", "sampling_date",
              "sample_collection_date"),
        _join([_from((dop, doc), "sample_place", "sampling_place",
                     "sampling_address"),
               _all_from(sample_nodes, "place", "address")]),
        _join(device_names),
        _one(_from((doc,), "measured_by", "performed_by", "executor"),
             role_names("измер", "исполн", "провёл", "провел")),
        _one(_from((doc,), "signed_by", "signatory", "protocol_signed_by"),
             role_names("подпис")),
        _one(_from((doc,), "approved_by", "approver", "protocol_approved_by"),
             role_names("утверд", "руковод")),
    ]
    assert len(shared) == 10 and len(trailing) == 11
    rows = []
    for number, measurement in enumerate(measured):
        prefix = shared if number == 0 else [""] * 10
        suffix = trailing if number == 0 else [""] * 11
        # Only secondary rows are permitted to have deliberately blank cells.
        rows.append([cell or MISSING for cell in prefix + list(measurement) + suffix]
                    if number == 0 else prefix + list(measurement) + suffix)
    return rows


def build_excel_rows(database: Path) -> tuple[list[list[str]], int, int]:
    """Include every protocol; never drop missing source XML or source factor."""
    _workplaces, protocols, _ = read_inventory(Path(database))
    if not protocols:
        raise FsaSourceError("В исходной MDB нет протоколов для Excel.")
    rows: list[list[str]] = []
    for index, protocol in enumerate(protocols, 1):
        xml = protocol["xml"]
        if xml is None or not xml.is_file():
            raise FsaSourceError(
                f"Протокол {index}: внутренний XML не найден. "
                "Excel не создан, чтобы не потерять сведения.")
        try:
            rows.extend(extract_protocol_rows(parse_xml(xml)))
        except (FsaSourceError, OSError, ValueError) as exc:
            raise FsaSourceError(f"Протокол {index}: {exc}") from exc
    if len(rows) > 65535:
        raise FsaSourceError("Формат XLS ограничен 65 535 строками данных.")
    return rows, len(protocols), len(rows)


def _save_excel97(path: Path, rows: list[list[str]]) -> None:
    """Save true BIFF8 XLS using locally installed Excel, with atomic replace."""
    try:
        import win32com.client
    except ImportError as exc:
        raise FsaSourceError("Для выгрузки .xls требуется Microsoft Excel для Windows.") from exc
    folder = path.parent
    folder.mkdir(parents=True, exist_ok=True)
    handle, temporary = tempfile.mkstemp(prefix=".att51-excel-", suffix=".xls",
                                        dir=str(folder))
    os.close(handle)
    os.unlink(temporary)
    application = None
    workbook = None
    try:
        application = win32com.client.DispatchEx("Excel.Application")
        application.Visible = False
        application.DisplayAlerts = False
        workbook = application.Workbooks.Add()
        sheet = workbook.Worksheets(1)
        sheet.Name = "TDSheet"
        # Workbook.Add respects an Excel user's default sheet-count setting.
        # The import format has exactly one sheet.
        while workbook.Worksheets.Count > 1:
            workbook.Worksheets(workbook.Worksheets.Count).Delete()
        data = [list(HEADERS)] + rows
        area = sheet.Range(sheet.Cells(1, 1), sheet.Cells(len(data), len(HEADERS)))
        area.NumberFormat = "@"  # No date serials, no scientific notation, no formula evaluation.
        area.Value2 = tuple(tuple(cell for cell in row) for row in data)
        header = sheet.Range("A1:Z1")
        header.Font.Bold = True
        header.Interior.Color = 0xDDEBDD
        header.WrapText = True
        header.RowHeight = 44
        sheet.Range("A:Z").ColumnWidth = 22
        sheet.Range("G:G").ColumnWidth = 35
        sheet.Range("J:K").ColumnWidth = 36
        sheet.Range("N:O").ColumnWidth = 36
        sheet.Range("R:R").ColumnWidth = 36
        sheet.Range("W:W").ColumnWidth = 36
        sheet.Range("A2:Z" + str(len(data))).WrapText = True
        sheet.Range("A1:Z1").AutoFilter()
        sheet.Activate()
        application.ActiveWindow.SplitRow = 1
        application.ActiveWindow.FreezePanes = True
        workbook.SaveAs(str(Path(temporary).resolve()), FileFormat=56)
        workbook.Close(SaveChanges=False)
        workbook = None
        os.replace(temporary, path)
    except Exception as exc:
        raise FsaSourceError("Не удалось записать Excel XLS: " + str(exc)) from exc
    finally:
        if workbook is not None:
            try:
                workbook.Close(SaveChanges=False)
            except Exception:
                pass
        if application is not None:
            try:
                application.Quit()
            except Exception:
                pass
        Path(temporary).unlink(missing_ok=True)


def create_excel_export(database: Path, *,
                        directory: Path | None = None,
                        writer=None) -> ExcelResult:
    rows, count, indicators = build_excel_rows(database)
    target = (Path(directory) if directory is not None else
              application_data_dir().parent / "reports") / FILENAME
    (writer or _save_excel97)(target, rows)
    return ExcelResult(target, count, indicators)
