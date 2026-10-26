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
                             '<count_params2><param name="Исходный показатель"'
                             ' param1="до 40" param2="1.5" nd_izm1="7"/>'
                             '</count_params2></Document>', encoding="utf-8")
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
            self.assertEqual((output.total, output.indicator_count), (3, 3))
            self.assertEqual(len(output.excel_rows), 4)
            self.assertEqual(output.excel_rows[0][0], "P8")
            self.assertEqual(output.excel_rows[0][10:13], ("Поле", "2.5", "В"))
            self.assertEqual(output.excel_rows[1][11], "до 40")
            self.assertEqual(output.excel_rows[1][13], "Исходная методика")
            self.assertEqual(output.excel_rows[2][:10], ("",) * 10)
            self.assertEqual(output.excel_rows[3][9], "Фактор 26")
            self.assertEqual(output.excel_rows[3][10:15], (EMPTY,) * 5)
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

    def test_gui_uses_raw_path_and_xml_keeps_strict_path(self):
        source = (ROOT / "app.py").read_text(encoding="utf-8")
        self.assertIn("prepare_excel_sources(files[", source)
        self.assertIn("create_fgis_export(", source)
        self.assertNotIn('prepare_batch(files["mdb"]', source)


if __name__ == "__main__":
    unittest.main()
