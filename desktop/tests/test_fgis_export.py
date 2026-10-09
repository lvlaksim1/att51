"""The public workflow must never create an invalid real-looking FGIS XML."""
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from xml.etree import ElementTree as ET

from att51_fsa.export_2025 import CustomerSettings
from fgis_export import create_fgis_export


class SafetyExportTests(unittest.TestCase):
    def test_block_missing_resource_before_writing_xml(self):
        with tempfile.TemporaryDirectory() as d:
            directory=Path(d)
            with patch("fgis_export.read_inventory",return_value=([],[],directory)), \
                 patch("fgis_export.ResourceCatalog.from_mdb",side_effect=ValueError("empty")):
                result=create_fgis_export(directory/"arm.mdb",directory/"resources.mdb",None,
                                          CustomerSettings("01.02.2026",1,inn="1234567890"),
                                          directory/"missing.xsd",directory=directory)
            self.assertFalse(result.ready)
            self.assertTrue(result.report.is_file())
            self.assertEqual(list(directory.glob("fsa_prot*.xml")),[])

    def test_resource_table_diagnostics_and_no_fabricated_xml(self):
        from att51_fsa.resources import ResourceCatalog
        with tempfile.TemporaryDirectory() as d:
            directory = Path(d)
            cat = ResourceCatalog.from_rows(
                devices=[], people=[], normative=[], links=[],
                present_tables=ResourceCatalog.REQUIRED
            )
            with patch("fgis_export.read_inventory", return_value=([], [], directory)), \
                 patch("fgis_export.ResourceCatalog.from_mdb", return_value=cat):
                result = create_fgis_export(
                    directory/"org.mdb", directory/"res_orgs.mdb", None,
                    CustomerSettings("01.02.2026", 1, inn="1234567890"),
                    directory/"absent.xsd", directory=directory)
            content = result.report.read_text(encoding="utf-8-sig")
            self.assertIn("FGIS_RA", content)
            self.assertIn("связей ID ФГИС 0", content)
            self.assertFalse(result.files)

    def test_block_nonmatching_factor_without_loading_resources(self):
        with tempfile.TemporaryDirectory() as d:
            directory=Path(d)
            xml=directory/"internal.xml"
            xml.write_text('<Document num_doc="A"><factor facid="14"/></Document>',
                           encoding="utf-8")
            rows=[{"rm_id":"1","factor_id":"13","xml":xml}]
            with patch("fgis_export.read_inventory",return_value=([],rows,directory)), \
                 patch("fgis_export.ResourceCatalog.from_mdb",return_value=object()):
                result=create_fgis_export(directory/"arm.mdb",directory/"res.mdb",None,
                                          CustomerSettings("01.02.2026",1,inn="1234567890"),
                                          directory/"missing.xsd",directory=directory)
            self.assertFalse(result.ready)
            self.assertIn("не совпадают",result.report.read_text(encoding="utf-8-sig"))

if __name__=="__main__":
    unittest.main()
