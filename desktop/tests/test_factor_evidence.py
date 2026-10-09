"""Source provenance and redacted measurement-shape diagnostics."""
from __future__ import annotations

import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
from xml.etree import ElementTree as ET

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
sys.path.insert(0, str(DESKTOP.parent / "fsa_xml_module"))

from factor_structure import inspect_factor_structure
from source_evidence import resource_source_evidence
from source_discovery import OriginalInstallation
from att51_fsa.sources import FsaSourceError


class SourceEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.install = self.base / "Аттестация-5.1"
        self.install.mkdir()
        self.config = self.install / "options.ini"
        self.local = self.install / "res_orgs.mdb"
        self.local.write_bytes(b"EMPTY TEST RESOURCE")
        self.external = self.base / "external" / "res_orgs.mdb"
        self.external.parent.mkdir()
        self.external.write_bytes(b"TEST RESOURCE")

    def instance(self, resource):
        return OriginalInstallation(
            folder=self.install,
            databases=(),
            resources=(resource,) if resource else (),
            settings=(),
            warnings=(),
        )

    def test_local_empty_resource_can_match_original_settings(self):
        self.config.write_text("[DB_res]\nres_flag=0\n", encoding="utf-8")
        result = resource_source_evidence(
            self.local, installations=(self.instance(self.local),))
        self.assertEqual(result["status"], "matches_original_setting")
        self.assertEqual(result["checked_installations"][0]["resource_mode"], "local")
        self.assertIn("не доказывает", result["guidance"])
        self.assertTrue(result["read_only"])

    def test_shared_setting_makes_local_selection_suspect(self):
        self.config.write_text(
            "[DB_res]\nres_flag=1\nres_path=" + str(self.external) + "\n",
            encoding="utf-8")
        result = resource_source_evidence(
            self.local, installations=(self.instance(self.external),))
        self.assertEqual(result["status"], "differs_from_known_original_settings")
        self.assertEqual(result["checked_installations"][0]["resource_mode"], "shared")
        self.assertFalse(result["checked_installations"][0]["selected_matches_this_installation"])

    def test_missing_installation_produces_unknown_instead_of_guess(self):
        result = resource_source_evidence(self.local, installations=())
        self.assertEqual(result["status"], "original_configuration_not_found")

    def test_ambiguous_two_installations_is_not_called_confirmed(self):
        self.config.write_text("[DB_res]\nres_flag=0\n", encoding="utf-8")
        installations = (self.instance(self.local), self.instance(self.external))
        result = resource_source_evidence(self.local, installations=installations)
        self.assertEqual(result["status"], "matches_one_of_multiple_installations")


class FactorStructureTests(unittest.TestCase):
    def test_internal_heaviness_shape_without_values_or_guid(self):
        root = ET.fromstring(
            '<Document secret="dont_report">'
            '<factor facid="13" mguid="private-guid">'
            '<si_guids><si_guid guid="secret-id" num="secret-number"/></si_guids>'
            '</factor>'
            '<izm_data><move fact="123.456" unc="0.1"/></izm_data>'
            '<persons name="private-person"/>'
            '</Document>'
        )
        data = inspect_factor_structure(root)
        self.assertEqual(data["factor_id"], "13")
        self.assertFalse(data["fgis_export_supported"])
        self.assertEqual(data["measurement_structure"]["izm_data"]["root_count"], 1)
        items = data["measurement_structure"]["izm_data"]["structure"]
        self.assertEqual(items[1]["attribute_names"], ["fact", "unc"])
        report = repr(data)
        for forbidden in ("dont_report", "private-guid", "secret-id",
                          "secret-number", "123.456", "private-person"):
            self.assertNotIn(forbidden, report)

    def test_factor_14_without_measurement_groups_stays_unknown(self):
        root = ET.fromstring('<Document><factor facid="14"/></Document>')
        data = inspect_factor_structure(root)
        self.assertEqual(data["factor_id"], "14")
        self.assertEqual(data["measurement_structure"]["izm_data"]["root_count"], 0)

    def test_missing_document_or_factor_rejected(self):
        for xml in ('<Other/>', '<Document/>'):
            with self.subTest(xml=xml):
                with self.assertRaises(FsaSourceError):
                    inspect_factor_structure(ET.fromstring(xml))


if __name__ == "__main__":
    unittest.main()
