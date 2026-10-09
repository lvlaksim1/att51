"""Source XML -> ATT51 resource catalog checks using synthetic fixtures."""
import unittest
from xml.etree import ElementTree as ET

from att51_fsa.resource_xml import inspect_protocol_resources, inspection_dict
from att51_fsa.resources import ResourceCatalog, nd_hash


def catalog():
    return ResourceCatalog.from_rows(
        devices=[{"id": 3, "mguid": "DEV", "factory_num": "123", "name": "Test device"}],
        people=[
            {"mguid": "P1", "snils": "111-111-111 11", "fio": "Test Person"},
            {"mguid": "P2", "snils": "222-222-222 22", "fio": "Another Person"},
        ],
        normative=[
            {"id": 7, "mguid": "ND-A", "name": "ГОСТ 12.1.003-83",
             "factor_id": 4, "typ": 0}
        ],
        links=[
            {"rec_type": 0, "rec_guid": "DEV", "IntValue": 400},
            {"rec_type": 1, "rec_guid": "P1", "IntValue": 500},
            {"rec_type": 1, "rec_guid": "P2", "IntValue": 501},
        ],
        nd_info=[
            {"nd_id": 7, "key_ctxt": "ГОСТ", "dop2": 999, "dop4": "shum_izm"}
        ],
        present_tables={"ATT_DEVICE", "ATT_PERSON", "DIC_ND",
                        "DIC_ND_INFO", "FGIS_RA"},
    )


class XmlResourceResolutionTests(unittest.TestCase):
    def test_individual_devices_roles_and_nd(self):
        root = ET.fromstring(
            '<Document num_doc="TEST-1" type="protocol2019">'
            '<factor facid="4">'
            '<si_guids><si_guid guid="DEV" num="123"/></si_guids>'
            '<si_guids_os><si_guid guid="DEV" num="123"/></si_guids_os>'
            '<persons><pers guid="P1"/></persons>'
            '<exp_persons><pers snils="222-222-222 22"/></exp_persons>'
            '<boss><pers guid="P1"/></boss>'
            '</factor>'
            '<nd_data>'
            '<nd id="1" name="ГОСТ 12.1.003-83" action="0"/>'
            '<nd id="2" name="Some unique method" action="1"/>'
            '</nd_data></Document>'
        )
        output = inspect_protocol_resources(root, catalog(), include_secondary=True)
        self.assertEqual(output.status, "read_only_inspection_complete")
        self.assertEqual([e.fgis_id for e in output.equipment], ["400", "400"])
        self.assertEqual([role for role, _ in output.people], ["izm", "exp", "boss"])
        self.assertEqual([person.fgis_id for _, person in output.people], ["500", "501", "500"])
        self.assertEqual(len(output.normative), 1)
        self.assertEqual(output.normative[0].method_doc_id, "999")
        self.assertEqual(output.normative[0].match_rule, "hash_with_factor")

    def test_missing_normative_is_fatal(self):
        root = ET.fromstring(
            '<Document><factor facid="4"/>'
            '<nd_data><nd name="Unknown" action="0"/></nd_data></Document>'
        )
        output = inspect_protocol_resources(root, catalog())
        self.assertEqual(output.status, "requires_correction")
        self.assertIn("fatal_nd_absent", output.errors)

    def test_single_method_nd_is_fallback_assessment(self):
        root = ET.fromstring(
            '<Document><factor facid="4"/>'
            '<nd_data><nd name="ГОСТ 12.1.003-83" action="1"/></nd_data>'
            '</Document>'
        )
        output = inspect_protocol_resources(root, catalog())
        self.assertEqual(len(output.normative), 1)
        self.assertEqual(output.normative[0].source_action, "1")

    def test_excluded_state_returns_no_resources(self):
        root = ET.fromstring(
            '<Document fgis_state="1"><factor facid="4">'
            '<si_guids><si_guid guid="DEV"/></si_guids>'
            '</factor></Document>'
        )
        output = inspect_protocol_resources(root, catalog())
        self.assertEqual(output.status, "excluded_by_fgis_state")
        self.assertEqual(len(output.equipment), 0)
        self.assertEqual(len(output.normative), 0)

    def test_state_two_skips_device_only(self):
        root = ET.fromstring(
            '<Document fgis_state="2"><factor facid="4">'
            '<si_guids><si_guid guid="DEV"/></si_guids>'
            '<persons><pers guid="P1"/></persons>'
            '</factor></Document>'
        )
        output = inspect_protocol_resources(root, catalog())
        self.assertEqual(len(output.equipment), 0)
        self.assertEqual(output.people[0][1].fgis_id, "500")

    def test_consolidated_uses_info_and_emf_950(self):
        root = ET.fromstring(
            '<Document fac_id="950" num_doc="SUMMARY">'
            '<info>'
            '<si_guids><si_guid guid="DEV"/></si_guids>'
            '<persons><pers guid="P1"/></persons>'
            '<boss guid="P2"/>'
            '<nd_data><nd name="Unknown" action="0"/></nd_data>'
            '</info></Document>'
        )
        output = inspect_protocol_resources(root, catalog(), summary=True)
        self.assertEqual((output.kind, output.factor_id), ("summary", "9"))
        self.assertEqual(len(output.equipment), 1)
        self.assertEqual([x[0] for x in output.people], ["izm", "boss"])
        self.assertIn("fatal_nd_absent", output.errors)

    def test_empty_optional_resource_tables_are_reported(self):
        c = ResourceCatalog.from_rows(
            devices=[], people=[], normative=[], links=[],
            present_tables={"ATT_DEVICE", "ATT_PERSON", "DIC_ND"},
        )
        root = ET.fromstring("<Document><factor facid='4'/></Document>")
        out = inspect_protocol_resources(root, c)
        self.assertIn("fgis_link_table_missing_in_resource_mdb", out.warnings)
        self.assertIn("normative_extension_table_missing_in_resource_mdb", out.warnings)
        self.assertTrue(inspection_dict(out)["not_exportable"])


if __name__ == "__main__":
    unittest.main()
