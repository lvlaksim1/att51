"""Regressions for independent read-only original Excel export."""
from pathlib import Path
from tempfile import TemporaryDirectory
import sys
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT.parent / "fsa_xml_module"))
from att51_fsa.export_2025 import CustomerSettings
from att51_fsa.source_snapshot import EMPTY
from excel_source_batch import ExcelSourceBatch, prepare_excel_sources
from excel_export import create_excel_export


class RawExcelTests(unittest.TestCase):
    def setUp(self):
        self.customer = CustomerSettings(
            "", 1, full_name="Заказчик", address="Подтверждённый адрес")

    def test_unimplemented_factors_and_unmatched_nd_are_not_blocking(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            xml8 = root / "eight.xml"
            xml13 = root / "thirteen.xml"
            xml8.write_text('<Document num_doc="P8" fill_date="2026-10-20">'
                            '<factor facid="8" izm_date="2026-10-19"/>'
                            '<izm_data><zone><param name="Поле" fact="2.5"'
                            ' unit="В"/></zone></izm_data></Document>', encoding="utf-8")
            xml13.write_text('<Document num_doc="P13">'
                             '<factor facid="13"/>'
                             '<nd_data><nd id="7" name="Исходная методика" action="1"/></nd_data>'
                             '<count_params2><param id="calc" param1="до 40" param2="1.5"/></count_params2>'
                             '<izm_data><zone><param name="Исходный показатель"'
                             ' fact="1.5" unit="кг"/></zone></izm_data></Document>', encoding="utf-8")
            items = [
                {"xml": xml8, "rm_id": "1", "factor_id": "8", "factor_name": "Фактор 8"},
                {"xml": xml13, "rm_id": "2", "factor_id": "13", "factor_name": "Тяжесть"},
                {"xml": None, "rm_id": "3", "factor_id": "26", "factor_name": "Фактор 26"},
            ]
            with patch("excel_source_batch.read_inventory",
                       return_value=([], items, root)), \
                 patch("excel_source_batch.ResourceCatalog.from_mdb",
                       return_value=None):
                output = prepare_excel_sources(root / "db.mdb", root / "res.mdb",
                                               None, self.customer)
            self.assertEqual((output.total, output.indicator_count), (3, 2))
            self.assertEqual(len(output.excel_rows), 3)
            self.assertEqual(output.excel_rows[0][0], "P8")
            self.assertEqual(output.excel_rows[0][10:13], ("Поле", "2.5", "В"))
            self.assertEqual(output.excel_rows[1][11], "1.5")
            self.assertEqual(output.excel_rows[1][13], "Исходная методика")
            self.assertEqual(output.excel_rows[1][12], "кг")
            self.assertEqual(output.excel_rows[2][9], "Фактор 26")
            self.assertEqual(output.excel_rows[2][10:15], (EMPTY,) * 5)
            self.assertTrue(any("отсутствует исходный XML" in s for s in output.issues))

    def test_missing_original_text_is_never_guessed(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            xml = root / "p.xml"
            xml.write_text('<Document><factor facid="1"/>'
                           '<izm_data><zone><param bm="29" fact="17"/></zone>'
                           '</izm_data></Document>', encoding="utf-8")
            items = [{"xml": xml, "rm_id": "4", "factor_id": "1",
                      "factor_name": "Первый фактор"}]
            with patch("excel_source_batch.read_inventory",
                       return_value=([], items, root)), \
                 patch("excel_source_batch.ResourceCatalog.from_mdb",
                       return_value=None):
                data = prepare_excel_sources(root / "db.mdb", root / "r.mdb",
                                             None, self.customer)
            self.assertEqual(data.excel_rows[0][10:15],
                             (EMPTY, "17", EMPTY, EMPTY, EMPTY))
            self.assertEqual(data.excel_rows[0][9], "Первый фактор")

    def test_issues_are_written_after_xls(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            rows = ((EMPTY,) * 26,)
            batch = ExcelSourceBatch(1, rows, 0, ("Протокол 1: нет XML",))
            outcome = create_excel_export(
                batch, directory=root,
                writer=lambda file, values: file.write_bytes(b"TEST XLS"))
            self.assertEqual(outcome.protocol_count, 1)
            self.assertEqual(outcome.indicator_count, 0)
            self.assertTrue(outcome.warning_file.is_file())
            self.assertIn("нет XML", outcome.warning_file.read_text(encoding="utf-8-sig"))
            self.assertTrue(outcome.file.exists())


    def test_noise_level_and_date_end_from_verified_source(self):
        import xml.etree.ElementTree as ET
        from excel_source_batch import _measurements, _shared
        doc = ET.fromstring(
            '<Document num_doc="P1" sign_date="2026-10-21">'
            '<factor facid="4" izm_date="2026-10-20"/>'
            '<nd_data><nd action="1" name="Исходная методика"/></nd_data>'
            '<izm_data><Level bm="Lekv" name="Эквивалентный уровень звука, дБА" fact="75"/></izm_data>'
            '</Document>'
        )
        measures, warnings = _measurements(doc)
        self.assertEqual(measures, [("Эквивалентный уровень звука, дБА",
                                    "75", "дБА", "Исходная методика", EMPTY)])
        self.assertEqual(_shared(doc, {"factor_name": "Шум"}, self.customer)[1:3],
                         ("2026-10-20", "2026-10-20"))
        self.assertFalse(warnings)

    def test_heaviness_excludes_calculator_data_and_empty_heading(self):
        import xml.etree.ElementTree as ET
        from excel_source_batch import _measurements
        doc = ET.fromstring(
            '<Document><factor facid="13"/>'
            '<count_params2><param id="bm_1" param1="40" param2="99"/></count_params2>'
            '<izm_data><zone>'
            '<param bm="bm_5" name="Рабочая поза, % смены" fact=""/>'
            '<param bm="bm_5_1" name="Свободная" fact="90"/>'
            '<param bm="bm_2" name="Перенос груза (кг)" fact="12"/>'
            '</zone></izm_data></Document>'
        )
        measures, warnings = _measurements(doc)
        self.assertEqual(len(measures), 2)
        self.assertEqual(measures[0][:3], ("Свободная", "90", "% смены"))
        self.assertEqual(measures[1][:3], ("Перенос груза (кг)", "12", "кг"))
        self.assertNotIn("99", str(measures))

    def test_vibration_both_axis_groups_use_verified_paired_word(self):
        from excel_source_batch import _measurements
        import xml.etree.ElementTree as ET
        from zipfile import ZipFile
        with TemporaryDirectory() as temp:
            word = Path(temp) / "p.docx"
            with ZipFile(word, "w") as archive:
                archive.writestr("word/document.xml",
                    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
                    '<w:body><w:p><w:r><w:t>Уровень виброускорения, дБ</w:t></w:r></w:p>'
                    '</w:body></w:document>')
            doc = ET.fromstring(
                '<Document><factor facid="8"/>'
                '<izm_data><zone name="Оборудование"/>'
                '<zone name="Корректированный уровень (ось X)" fact="127"/>'
                '<zone name="Корректированный уровень (ось Y)" fact="128"/>'
                '<zone name="Корректированный уровень (ось Z)" fact="129"/>'
                '<zone><param name="Эквивалентный корректированный уровень:"/>'
                '<param name="ОСЬ X" fact="118"/>'
                '<param name="ОСЬ Y" fact="119"/>'
                '<param name="ОСЬ Z" fact="120"/></zone>'
                '</izm_data></Document>'
            )
            measures, warnings = _measurements(doc, word=word)
            self.assertEqual(len(measures), 6)
            self.assertTrue(all(row[2] == "дБ" for row in measures))
            self.assertEqual(measures[3][0], "Эквивалентный корректированный уровень — ОСЬ X")
            self.assertFalse(warnings)
            without_word, _ = _measurements(doc)
            self.assertTrue(all(row[2] == EMPTY for row in without_word))

    def test_multiple_methods_do_not_create_unverified_parameter_link(self):
        from excel_source_batch import _measurements
        import xml.etree.ElementTree as ET
        doc = ET.fromstring(
            '<Document><factor facid="13"/>'
            '<nd_data><nd name="М1" action="1"/><nd name="М2" action="1"/></nd_data>'
            '<izm_data><zone><param name="Показатель" fact="4"/></zone></izm_data>'
            '</Document>'
        )
        measures, warnings = _measurements(doc)
        self.assertEqual(measures[0][3], EMPTY)
        self.assertTrue(any("несколько методик" in item for item in warnings))

    def test_source_path_not_duplicate_number_drives_protocol_selection(self):
        from excel_source_batch import prepare_excel_sources
        with TemporaryDirectory() as temp:
            root = Path(temp)
            old, current = root / "old.xml", root / "current.xml"
            old.write_text('<Document num_doc="3- ТМ" rm_id="1">'
                           '<factor facid="4" izm_date="2026-01-01"/>'
                           '<izm_data><Level name="Старое" fact="11"/></izm_data>'
                           '</Document>', encoding="utf-8")
            current.write_text('<Document num_doc="3- ТМ" rm_id="1">'
                               '<factor facid="4" izm_date="2026-01-02"/>'
                               '<izm_data><Level name="Актуальное" fact="12"/></izm_data>'
                               '</Document>', encoding="utf-8")
            items = [{"rm_id": "1", "factor_id": "4", "factor_name": "Шум",
                      "xml": current, "word": None}]
            with patch("excel_source_batch.read_inventory",
                       return_value=([], items, root)), \
                 patch("excel_source_batch.ResourceCatalog.from_mdb",
                       return_value=None):
                output = prepare_excel_sources(root / "a.mdb", root / "r.mdb", None, self.customer)
            self.assertEqual(output.total, 1)
            self.assertEqual(len(output.excel_rows), 1)
            self.assertEqual(output.excel_rows[0][11], "12")
            self.assertEqual(output.excel_rows[0][2], "2026-01-02")

    def test_equipment_includes_mandatory_factory_and_optional_inventory(self):
        import xml.etree.ElementTree as ET
        from excel_source_batch import _equipment
        from att51_fsa.resources import ResourceCatalog
        resources = ResourceCatalog.from_rows(
            devices=[
                {"id": "1", "mguid": "G1", "name": "Шумомер",
                 "factory_num": "ABC-001", "inventory_num": "INV-91",
                 "reg_num": "РЕГ-41"},
                {"id": "2", "mguid": "G2", "name": "Виброметр",
                 "factory_num": "2204", "reg_num": "РЕГ-52"},
            ], people=[], normative=[], links=[])
        factor = ET.fromstring('<factor>'
            '<si_guids><si_guid guid="G1" num="ABC-001"/>'
            '<si_guid guid="G2" num="2204"/></si_guids>'
            '<si_guids_dop><si_guid guid="G1" num="ABC-001"/></si_guids_dop>'
            '</factor>')
        result = _equipment(factor, resources)
        self.assertEqual(
            result, "Шумомер (зав. № ABC-001; инв. № INV-91); "
                    "Виброметр (зав. № 2204)")
        self.assertNotIn("РЕГ-", result)
        self.assertEqual(result.count("Шумомер"), 1)

    def test_equipment_keeps_xml_factory_without_resource_mapping(self):
        import xml.etree.ElementTree as ET
        from excel_source_batch import _equipment
        factor = ET.fromstring('<factor><si_guids>'
            '<si_guid guid="notfound" num="S-342" name="Измеритель"/>'
            '</si_guids></factor>')
        self.assertEqual(_equipment(factor, None), "Измеритель (зав. № S-342)")

    def test_missing_factory_is_visible_and_reported_not_invented(self):
        import xml.etree.ElementTree as ET
        from excel_source_batch import _equipment
        factor = ET.fromstring('<factor><si_guids>'
            '<si_guid guid="notfound" name="Измеритель"/>'
            '</si_guids></factor>')
        warnings = []
        result = _equipment(factor, None, warnings, "Протокол 1")
        self.assertEqual(result, "Измеритель (зав. № НЕТ ДАННЫХ)")
        self.assertTrue(any("заводской номер" in item for item in warnings))

    def test_factory_discrepancy_preserves_protocol_number_and_warns(self):
        import xml.etree.ElementTree as ET
        from excel_source_batch import _equipment
        from att51_fsa.resources import ResourceCatalog
        resources = ResourceCatalog.from_rows(
            devices=[{"id": "1", "mguid": "G1", "name": "Прибор",
                      "factory_num": "SOURCE-2"}],
            people=[], normative=[], links=[])
        factor = ET.fromstring('<factor><si_guids>'
            '<si_guid guid="G1" num="PROTOCOL-1"/>'
            '</si_guids></factor>')
        warnings = []
        result = _equipment(factor, resources, warnings, "РМ 1")
        self.assertEqual(result, "Прибор (зав. № PROTOCOL-1)")
        self.assertTrue(any("не совпадает" in item for item in warnings))

    def test_gui_uses_raw_path_and_xml_keeps_strict_path(self):
        source = (ROOT / "app.py").read_text(encoding="utf-8")
        self.assertIn("prepare_excel_sources(files[", source)
        self.assertIn("create_fgis_export(", source)
        self.assertNotIn('prepare_batch(files["mdb"]', source)


if __name__ == "__main__":
    unittest.main()
