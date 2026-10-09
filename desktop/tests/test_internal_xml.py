"""Regression: internal Document XML is not a FGIS fileProtocolLoad_v4 XML."""
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
sys.path.insert(0, str(DESKTOP.parent / "fsa_xml_module"))

from internal_xml import inspect_internal_xml
from att51_fsa.sources import FsaSourceError


class InternalProtocolTests(unittest.TestCase):
    def setUp(self):
        self.folder = TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.file = Path(self.folder.name) / "Тяжесть.xml"

    def test_heaviness_is_a_valid_internal_xml_without_fgis_xsd(self):
        self.file.write_text(
            '<Document num_doc="129- ТМ"><factor facid="13" izm_date="2026-10-09">'
            '<si_guids><si_guid guid="A" num="17"/></si_guids>'
            '</factor><persons/><nd_data/></Document>', encoding="utf-8")
        result = inspect_internal_xml(self.file)
        self.assertTrue(result["well_formed"])
        self.assertEqual(result["xml_kind"], "original_att51_internal_protocol")
        self.assertEqual(result["protocol_number"], "129- ТМ")
        self.assertEqual(result["factor_id"], "13")
        self.assertEqual(result["equipment_count"], 1)
        self.assertFalse(result["fgis_schema_applicable"])
        self.assertTrue(result["not_exportable"])
        self.assertIn("пока не реализован", result["warnings"][0])

    def test_intensity_factor_14_is_valid_internal_xml(self):
        self.file.write_text(
            '<Document num_doc="131- Н"><factor facid="14"/></Document>',
            encoding="utf-8")
        result = inspect_internal_xml(self.file)
        self.assertEqual(result["factor_id"], "14")
        self.assertTrue(result["well_formed"])

    def test_malformed_xml_is_rejected(self):
        self.file.write_text('<Document><factor facid="13"></Document>', encoding="utf-8")
        with self.assertRaises(FsaSourceError):
            inspect_internal_xml(self.file)

    def test_missing_document_or_factor_is_rejected(self):
        for invalid in ("<wrong/>", "<Document/>", '<Document><factor/></Document>'):
            with self.subTest(invalid=invalid):
                self.file.write_text(invalid, encoding="utf-8")
                with self.assertRaises(FsaSourceError):
                    inspect_internal_xml(self.file)

    def test_xml_with_doctype_does_not_process_external_entities(self):
        self.file.write_text(
            '<!DOCTYPE Document [<!ENTITY x SYSTEM "file:///c:/secret.txt">]>'
            '<Document><factor facid="13"/></Document>', encoding="utf-8")
        with self.assertRaises(FsaSourceError):
            inspect_internal_xml(self.file)


class BuiltExecutableTests(unittest.TestCase):
    def test_frozen_executable_requires_win32timezone(self):
        build = (DESKTOP / "build.ps1").read_text(encoding="utf-8")
        app = (DESKTOP / "app.py").read_text(encoding="utf-8")
        self.assertIn("'--hidden-import', 'win32timezone'", build)
        self.assertIn("import win32timezone", app)
        self.assertIn('win32com.client.Dispatch("ADODB.Connection")', app)
        self.assertIn('"--self-test-mdb"', app)

    def test_individual_xml_checks_are_not_offered_in_new_gui(self):
        app = (DESKTOP / "app.py").read_text(encoding="utf-8")
        self.assertNotIn("Проверить один XML по XSD", app)
        self.assertNotIn("Сопоставить один XML", app)
        self.assertNotIn("Параметры диагностики", app)
        self.assertIn("create_details(", app)
        # The legacy low-level XML inspector remains available to library tests.
        inspector = (DESKTOP / "internal_xml.py").read_text(encoding="utf-8")
        self.assertIn("inspect_internal_xml(", inspector)


if __name__ == "__main__":
    unittest.main()
