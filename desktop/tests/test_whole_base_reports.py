"""Regression for two complete local text files covering every factor."""
from __future__ import annotations

from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch
from types import SimpleNamespace

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
sys.path.insert(0, str(DESKTOP.parent / "fsa_xml_module"))

from whole_base_reports import (
    INDEX_FILE, DETAIL_FILE, read_inventory, report_index, report_details,
    create_index, create_details, write_report,
)
from att51_fsa.sources import FsaSourceError


class FakeAccessReader:
    workplaces = [
        {"id": 11, "num": "11А", "name": "Лаборант", "deleted": 0},
        {"id": 9, "num": "009", "name": "Техник", "deleted": 0},
        {"id": 17, "num": "17", "name": "Кассир", "deleted": 0},
    ]
    rows = [
        {"rm_id": 9, "factor_id": 13, "factor_name": "Тяжесть",
         "file": r"rm9\Тяжесть.docx"},
        {"rm_id": 11, "factor_id": 14, "factor_name": "Напряжённость",
         "file": r"rm11\Напряженность.docx"},
        {"rm_id": 11, "factor_id": 99999, "factor_name": "Неизвестный фактор",
         "file": r"rm11\Неизвестный.docx"},
        {"rm_id": 17, "factor_id": 12, "factor_name": "Освещение",
         "file": r"rm17\Нет XML.docx"},
        {"rm_id": 77, "factor_id": 18, "factor_name": "Отключённый",
         "file": ""},
    ]
    queries = []
    def __init__(self, path):
        self.path = path
    def __enter__(self):
        return self
    def __exit__(self, *args):
        return None
    def table_names(self):
        return frozenset({"STRUCT_RM", "SOUT_FACTORS"})
    def select(self, query):
        self.queries.append(query)
        if "struct_rm" in query.lower():
            return self.workplaces
        if "sout_factors" in query.lower():
            return self.rows
        raise AssertionError("Unknown SQL: " + query)


class WholeBaseReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.db = self.base / "Test.mdb"
        self.resources = self.base / "res_orgs.mdb"
        self.db.write_bytes(b"PRIVATE ORIGINAL DATABASE")
        self.resources.write_bytes(b"PRIVATE ORIGINAL RESOURCE")
        self.root = self.base / "Test_files"
        for relative in ("rm9", "rm11", "rm17"):
            (self.root / relative / "xml").mkdir(parents=True)
        (self.root / "rm9" / "xml" / "Тяжесть.xml").write_text(
            '<Document num_doc="129- ТМ"><factor facid="13">'
            '<si_guids><si_guid guid="RAW-GUID" num="777"/></si_guids>'
            '<persons><pers guid="RAW-PERSON" snils="123"/></persons>'
            '<measurements><value unit="кг">42.5</value></measurements>'
            '</factor></Document>', encoding="utf-8")
        (self.root / "rm11" / "xml" / "Напряженность.xml").write_text(
            '<Document num_doc="131- Н"><factor facid="14">'
            '<izm_data foo="original">НЕ ПОДМЕНЯТЬ</izm_data>'
            '</factor></Document>', encoding="utf-8")
        (self.root / "rm11" / "xml" / "Неизвестный.xml").write_text(
            '<Document num_doc="999"><factor facid="99999">'
            '<unrecognized source="original">Сырые данные</unrecognized>'
            '</factor></Document>', encoding="utf-8")
        FakeAccessReader.queries = []
        m1 = patch("whole_base_reports.AccessReader", FakeAccessReader)
        m2 = patch("whole_base_reports.ResourceCatalog.from_mdb",
                   return_value=SimpleNamespace(
                       device=lambda guid,number: SimpleNamespace(
                           found=False, fgis_id="", display_name=""),
                       person=lambda guid,number: SimpleNamespace(
                           found=False, fgis_id="", display_name="")))
        m1.start()
        m2.start()
        self.addCleanup(m1.stop)
        self.addCleanup(m2.stop)

    def test_index_lists_all_workplaces_all_protocols_including_missing_and_orphan(self):
        result = report_index(self.db, self.resources)
        self.assertIn("Рабочих мест (записей STRUCT_RM): 3", result)
        self.assertIn("Протоколов (записей SOUT_FACTORS): 5", result)
        self.assertIn("Номер: 009", result)
        self.assertIn("Наименование: Лаборант", result)
        self.assertIn("Фактор: Тяжесть (ID 13)", result)
        self.assertIn("Неизвестный фактор (ID 99999)", result)
        self.assertIn("Наличие XML: нет", result)
        self.assertIn("ПРОТОКОЛЫ БЕЗ СООТВЕТСТВУЮЩЕЙ", result)
        self.assertEqual(len(FakeAccessReader.queries), 2)
        self.assertEqual(FakeAccessReader.queries, [
            "SELECT * FROM struct_rm", "SELECT * FROM sout_factors"
        ])

    def test_details_include_raw_values_and_do_not_fabricate_fgis_ids(self):
        result = report_details(self.db, self.resources)
        for token in ("RAW-GUID", "777", "RAW-PERSON", "123", "42.5",
                      "НЕ ПОДМЕНЯТЬ", "Сырые данные", "facid", "99999",
                      "Номер РМ: 009", "Освещение", "XML отсутствует",
                      "Всего записей протоколов: 5"):
            self.assertIn(token, result)
        self.assertIn("ID ФГИС: не сопоставлен (исходные значения сохранены)", result)
        self.assertNotIn("ID ФГИС: 0", result)
        self.assertIn("Успешно прочитано внутренних XML: 3", result)

    def test_optional_catalog_failure_keeps_original_protocol_data(self):
        with patch("whole_base_reports.ResourceCatalog.from_mdb",
                   side_effect=FsaSourceError("Нет ресурсного справочника")):
            text = report_details(self.db, self.resources)
        self.assertIn("Сырые данные", text)
        self.assertIn("Нет ресурсного справочника", text)
        self.assertIn("ID ФГИС: не сопоставлен", text)

    def test_atomic_file_output_inside_app_and_repeat_overwrites(self):
        outdir = self.base / "Att51_export" / "reports"
        one = create_index(self.db, self.resources, directory=outdir)
        two = create_details(self.db, self.resources, directory=outdir)
        self.assertEqual(one.name, INDEX_FILE)
        self.assertEqual(two.name, DETAIL_FILE)
        self.assertIn("009", one.read_text(encoding="utf-8-sig"))
        self.assertIn("Сырые данные", two.read_text(encoding="utf-8-sig"))
        create_index(self.db, self.resources, directory=outdir)
        self.assertEqual(sorted(p.name for p in outdir.iterdir()),
                         sorted((INDEX_FILE, DETAIL_FILE)))
        self.assertEqual(self.db.read_bytes(), b"PRIVATE ORIGINAL DATABASE")
        self.assertEqual(self.resources.read_bytes(), b"PRIVATE ORIGINAL RESOURCE")
        with self.assertRaises(ValueError):
            write_report("INVALID", "unapproved.txt", outdir)

    def test_missing_xml_does_not_abort_other_protocols(self):
        (self.root / "rm9" / "xml" / "Тяжесть.xml").unlink()
        value = report_details(self.db, self.resources)
        self.assertIn("Успешно прочитано внутренних XML: 2", value)
        self.assertIn("Сырые данные", value)

    def test_xml_dtd_is_rejected_but_other_protocols_continue(self):
        (self.root / "rm9" / "xml" / "Тяжесть.xml").write_text(
            '<!DOCTYPE Document [<!ENTITY file SYSTEM "file:///secret.txt">]>'
            '<Document>&file;</Document>', encoding="utf-8")
        text = report_details(self.db, self.resources)
        self.assertIn("DTD/entities are disallowed", text)
        self.assertIn("Сырые данные", text)


class GUIContractTests(unittest.TestCase):
    def test_only_two_export_buttons_and_three_file_inputs(self):
        c = (DESKTOP / "app.py").read_text(encoding="utf-8")
        self.assertIn('("Выгрузить XML", self._create_fgis_xml)', c)
        self.assertIn('("Выгрузить Excel", self._create_excel)', c)
        self.assertNotIn("1. Перечень рабочих мест и протоколов", c)
        self.assertNotIn("2. Подробные сведения всех протоколов", c)
        # Low-level diagnostic functions still support internal CLI checks.
        self.assertIn("create_index(", c)
        self.assertIn("create_details(", c)
        self.assertIn('("mdb", "resources", "ini")', c)
        self.assertIn('text="Авто"', c)
        for gone in ("Параметры диагностики", "Сопоставить один XML",
                     "Найти по настройкам", "Указать папку Аттестации",
                     "Сопоставить все XML (6 факторов)"):
            self.assertNotIn(gone, c)

    def test_reports_stay_in_application_folder(self):
        c = (DESKTOP / "whole_base_reports.py").read_text(encoding="utf-8")
        self.assertIn('application_data_dir().parent / "reports"', c)
        self.assertIn("os.replace(temp, target)", c)


if __name__ == "__main__":
    unittest.main()
