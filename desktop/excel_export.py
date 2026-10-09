"""XLS output of exactly the same approved source measurements as FGIS XML.

All measurement selection and FGIS mapping happen in prepare_protocol. This
module only renders the accepted pre-ID labels in the original A-Z layout.
"""
from __future__ import annotations

from dataclasses import dataclass
import os
from pathlib import Path
import tempfile

from att51_fsa.sources import FsaSourceError

from excel_shared_source import prepared_batch_rows
from source_settings import application_data_dir


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


@dataclass(frozen=True)
class ExcelResult:
    file: Path
    protocol_count: int
    indicator_count: int


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


def create_excel_export(batch, *, directory: Path | None = None, writer=None) -> ExcelResult:
    """Format an already-prepared common batch, no original-file reads."""
    rows, count, indicators = prepared_batch_rows(batch)
    target = (Path(directory) if directory is not None else
              application_data_dir().parent / "reports") / FILENAME
    (writer or _save_excel97)(target, rows)
    return ExcelResult(target, count, indicators)
