"""Batch protocol GUI helper uses MDB links rather than an individual XML input."""
from __future__ import annotations

from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
sys.path.insert(0, str(DESKTOP.parent / "fsa_xml_module"))

from protocol_batch import inspect_all_2025
from source_discovery import Protocol
from att51_fsa.pipeline_2025 import Original2025Options


class BatchProtocolTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.folder = Path(self.tmp.name)
        self.db = self.folder / "ARMv51.MDB"
        self.resource = self.folder / "res_orgs.mdb"
        self.db.touch()
        self.resource.touch()
        self.protocols = [
            Protocol(11, 4, self.folder / "a.docx", self.folder / "a.xml"),
            Protocol(12, 12, self.folder / "b.docx", self.folder / "b.xml"),
        ]

    def run_with(self, parse_side_effect=None, ini=None, rm_id=None):
        def mapped(document, catalog, options, **kwargs):
            self.assertIsNone(kwargs["working_fgis_ini"])
            return SimpleNamespace(
                number="TEST", factor_id="4", status="requires_correction",
                supported=True, measurement_traces=(1,),
                errors=("missing_method",), resource_errors=(),
                resource_warnings=())
        parser = parse_side_effect or (lambda _: object())
        with (patch("protocol_batch.discover_protocols", return_value=self.protocols) as found,
              patch("protocol_batch.ResourceCatalog.from_mdb", return_value=object()) as resource,
              patch("protocol_batch.parse_xml", side_effect=parser),
              patch("protocol_batch.analyze_2025", side_effect=mapped)):
            report = inspect_all_2025(
                self.db, self.resource, Original2025Options(),
                rm_id=rm_id, working_fgis_ini=ini)
            found.assert_called_once_with(self.db, rm_id=rm_id)
            resource.assert_called_once_with(self.resource)
        return report

    def test_all_protocols_without_xml_selection_and_without_fgis_ini(self):
        report = self.run_with()
        self.assertEqual(report["found_linked_xml"], 2)
        self.assertEqual(len(report["protocols"]), 2)
        self.assertIn("Пользовательский fgis_ra.ini отсутствует", report["warnings"][0])
        self.assertTrue(report["not_exportable"])
        self.assertEqual(report["statuses"], {"requires_correction": 2})
        self.assertTrue(report["protocols"][1]["factor_mismatch"])

    def test_invalid_one_xml_does_not_stop_batch(self):
        from att51_fsa.sources import FsaSourceError

        def parse(path):
            if path.name == "a.xml":
                raise FsaSourceError("Synthetic invalid XML")
            return object()

        report = self.run_with(parse_side_effect=parse)
        self.assertEqual(report["statuses"], {
            "requires_correction": 1, "source_read_error": 1,
        })

    def test_explicit_missing_ini_fails_instead_of_silent_substitution(self):
        missing = self.folder / "fgis_ra.ini"
        with self.assertRaises(FileNotFoundError):
            inspect_all_2025(self.db, self.resource, Original2025Options(),
                             working_fgis_ini=missing)

    def test_filter_is_forwarded_to_database_discovery(self):
        report = self.run_with(rm_id=11)
        self.assertEqual(report["rm_filter"], 11)


class SourcePanelLayoutTests(unittest.TestCase):
    def test_main_source_panel_contains_only_mdbs_and_optional_ini(self):
        source = (DESKTOP / "app.py").read_text(encoding="utf-8")
        main = source.split('pane = ttk.LabelFrame(', 1)[1].split(
            'detail = ttk.LabelFrame(', 1)[0]
        self.assertIn('("mdb", "База рабочих мест', main)
        self.assertIn('("resources", "Справочник res_orgs.mdb', main)
        self.assertNotIn('("xml",', main)
        self.assertIn("fgis_ra.ini (необязательно)", main)
        self.assertIn("Файл используется только для пользовательских подмен", main)

    def test_batch_action_does_not_request_one_xml(self):
        source = (DESKTOP / "app.py").read_text(encoding="utf-8")
        method = source.split("    def _inspect_all_2025(self):", 1)[1].split(
            "    def _inspect_2025(self):", 1)[0]
        self.assertIn('self._required("mdb", "resources")', method)
        self.assertNotIn('self._required("xml"', method)
        self.assertIn("inspect_all_2025(", method)


if __name__ == "__main__":
    unittest.main()
