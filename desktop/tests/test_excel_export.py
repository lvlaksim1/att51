"""Excel raw protocol rows and independent COM background worker regressions."""
from __future__ import annotations

from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import patch
from xml.etree import ElementTree as ET

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
sys.path.insert(0, str(DESKTOP.parent / "fsa_xml_module"))

from excel_export import (HEADERS, MISSING, build_excel_rows,
                          create_excel_export, extract_protocol_rows)
from com_workers import run_with_com
from att51_fsa.sources import FsaSourceError


def original():
    return ET.fromstring('''<Document num_doc="ABC-001"
          fill_date="01.10.2026" customer_name="ООО Компания"
          inn="1234567890" address="Исходный адрес" query_date="09.09.2026">
          <factor facid="3" izm_date="30.09.2026" factor_name="АПФД">
            <si_guids><si_guid guid="DO-NOT-EXPORT-ID" num="1234"/></si_guids>
          </factor>
          <nd_data>
            <nd id="501" name="Методика А" action="1"/>
            <nd id="777" name="Методика Б" action="1"/>
            <nd id="78" name="СанПиН № 1" action="0"/>
          </nd_data>
          <izm_data><zone>
            <param name="Пыль в рабочей зоне" bm="ko1_65" nd_izm1="501;777"
                   unit="мг/м³" fact="0,50" method="Гравиметрический"/>
            <param name="Пыль, средняя" bm="kcss65" nd_izm1="777"
                   unit="мг/м³" fact="0,23"/>
          </zone></izm_data>
          <persons><pers name="Петров П. П." role="Провёл измерения"/>
                   <pers name="Иванов И. И." role="Подписал протокол"/></persons>
        </Document>''')


class OriginalExcelTests(unittest.TestCase):
    def test_template_has_exact_26_fields(self):
        self.assertEqual(len(HEADERS), 26)
        self.assertEqual(HEADERS[10:15], (
            "Наименование показателя", "Измеренное значение",
            "Единица измерения", "Наименование методики",
            "Наименование метода"))
        self.assertEqual(HEADERS[0], "Номер протокола")
        self.assertEqual(HEADERS[-1], "Утвердил протокол")

    def test_first_measurement_gets_every_shared_field(self):
        rows = extract_protocol_rows(original())
        self.assertEqual(len(rows), 2)
        self.assertEqual(len(rows[0]), 26)
        self.assertEqual(rows[0][0], "ABC-001")
        self.assertEqual(rows[0][1:4], ["30.09.2026","30.09.2026","01.10.2026"])
        self.assertEqual(rows[0][4], "ООО Компания")
        self.assertEqual(rows[0][7], "1234567890")
        self.assertEqual(rows[0][10:15],
                         ["Пыль в рабочей зоне","0,50","мг/м³",
                          "Методика А; Методика Б","Гравиметрический"])
        self.assertEqual(rows[0][17], "Методика А; Методика Б; СанПиН № 1")
        self.assertEqual(rows[0][23], "Петров П. П.")
        self.assertEqual(rows[0][24], "Иванов И. И.")

    def test_secondary_row_has_only_five_measurement_columns(self):
        rows = extract_protocol_rows(original())
        self.assertEqual(rows[1][:10], [""]*10)
        self.assertEqual(rows[1][10:15],
                         ["Пыль, средняя","0,23","мг/м³",
                          "Методика Б",MISSING])
        self.assertEqual(rows[1][15:], [""]*11)

    def test_absent_values_are_explicit_not_guessed(self):
        rows = extract_protocol_rows(ET.fromstring(
            '<Document num_doc="N"><factor facid="101"/></Document>'))
        self.assertEqual(len(rows),1)
        self.assertEqual(rows[0][0], "N")
        self.assertTrue(all(v == MISSING for v in rows[0][1:]))
        self.assertNotIn("101", repr(rows))  # no FGIS/internal factor IDs

    def test_fgis_decorations_removed_not_ids_added(self):
        root = original()
        root.set("object_name", "Тест ||id 1234||")
        root.find("./izm_data/zone/param").set("method",
                                             "Метод ||id 496||")
        rows = extract_protocol_rows(root)
        self.assertEqual(rows[0][9], "Тест")
        self.assertEqual(rows[0][14], "Метод")
        self.assertNotIn("||id", repr(rows))
        self.assertNotIn("DO-NOT-EXPORT-ID",repr(rows))

    def test_all_protocols_loaded_without_resource_db(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            xml = root/"internal.xml"
            ET.ElementTree(original()).write(xml,encoding="unicode")
            items = [{"xml":xml},{"xml":xml}]
            with patch("excel_export.read_inventory",return_value=([],items,root)):
                values,count,indicators=build_excel_rows(root/"test.mdb")
            self.assertEqual((count,indicators), (2,4))
            self.assertEqual(len(values),4)

    def test_missing_xml_is_error_not_partial_export(self):
        with tempfile.TemporaryDirectory() as temp:
            base=Path(temp)
            with patch("excel_export.read_inventory",return_value=(
                [],[{"xml":base/"missing.xml"}],base)):
                with self.assertRaisesRegex(FsaSourceError,"не найден"):
                    build_excel_rows(base/"test.mdb")

    def test_output_path_and_writer_without_excel_or_resources(self):
        with tempfile.TemporaryDirectory() as temp:
            base=Path(temp)
            xml=base/"raw.xml"
            xml.write_text(ET.tostring(original(),encoding="unicode"),encoding="utf-8")
            seen=[]
            def writer(path, rows):
                seen.append((path,rows))
                path.write_text("TEST",encoding="utf-8")
            with patch("excel_export.read_inventory",return_value=(
                [],[{"xml":xml}],base)):
                result=create_excel_export(base/"test.mdb",directory=base,writer=writer)
            self.assertEqual(result.protocol_count,1)
            self.assertEqual(result.indicator_count,2)
            self.assertTrue(result.file.exists())
            self.assertEqual(result.file.suffix.lower(),".xls")
            self.assertEqual(seen[0][1][1][0], "")


class ComThreadTests(unittest.TestCase):
    def test_com_initialized_and_released_on_background_task(self):
        calls=[]
        fake=types.SimpleNamespace(CoInitialize=lambda:calls.append("init"),
                                   CoUninitialize=lambda:calls.append("uninit"))
        with patch.object(sys, "platform", "win32"), patch.dict(
                sys.modules, {"pythoncom":fake}):
            def task():
                calls.append("task")
                return 5
            self.assertEqual(run_with_com(task),5)
        self.assertEqual(calls,["init","task","uninit"])

    def test_com_released_when_export_raises(self):
        calls=[]
        fake=types.SimpleNamespace(CoInitialize=lambda:calls.append("init"),
                                   CoUninitialize=lambda:calls.append("uninit"))
        with patch.object(sys, "platform", "win32"), patch.dict(
                sys.modules, {"pythoncom":fake}):
            with self.assertRaisesRegex(RuntimeError,"boom"):
                run_with_com(lambda: (_ for _ in ()).throw(RuntimeError("boom")))
        self.assertEqual(calls,["init","uninit"])

    def test_only_two_export_buttons_offered(self):
        source=(DESKTOP/"app.py").read_text(encoding="utf-8")
        fragment=source.split("for label, command in (",1)[1].split("):",1)[0]
        self.assertEqual(fragment.count('("Выгрузить'),2)
        self.assertNotIn("Перечень рабочих мест",fragment)
        self.assertNotIn("Подробные сведения",fragment)
        self.assertIn('kind="excel_result"',source)
        self.assertIn("run_with_com(task)",source)


if __name__=="__main__":
    unittest.main()
