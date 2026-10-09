"""Tests for resource-backed get_DocNameId integration (synthetic IDs only)."""
import unittest
from att51_fsa.methods import (
    MethodCandidate, ResearchForMethod, bind_methods_from_catalog
)
from att51_fsa.resources import ResourceCatalog


def catalog():
    return ResourceCatalog.from_rows(
        devices=[], people=[],
        normative=[
            {"id": 1, "mguid": "ND1", "name": "Noise test method",
             "factor_id": 4, "typ": 1},
            {"id": 2, "mguid": "ND2", "name": "Noise default method",
             "factor_id": 4, "typ": 1},
        ],
        links=[],
        nd_info=[
            {"nd_id": 1, "key_ctxt": "Method 1", "dop2": 345,
             "dop4": "shum_izm", "dop5": "Approval-1"},
            {"nd_id": 2, "key_ctxt": "Method 2", "dop2": 456,
             "dop4": "", "dop5": "Approval-2"},
        ],
        present_tables={"ATT_DEVICE", "ATT_PERSON", "DIC_ND", "DIC_ND_INFO"},
    )


class ResourceBoundMethodTests(unittest.TestCase):
    def test_populates_method_id_and_guid_from_resource(self):
        source = [MethodCandidate("5", "", "Noise test method")]
        output = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="9", nd_izm1="5"), source,
            catalog(), factor_id="4",
        )
        self.assertEqual(output.selected.doc_name_id, "345")
        self.assertEqual(output.selected.nd_guid, "ND1")
        self.assertEqual(output.selected.oa_method, "Approval-1")
        self.assertEqual(output.selected.source_rule, "first_pass_nd_id")
        self.assertFalse(output.selected.requires_review)
        # This synthetic English ND contains no characters retained by the
        # original Russian ND hash, so get_nd_by_name uses the last exact-name pass.
        self.assertEqual(output.matching_rules, ("exact_name_when_hash_empty",))
        self.assertTrue(output.not_exportable)

    def test_priority_from_dop4_resource(self):
        items = [
            MethodCandidate("0", "", "Noise default method"),
            MethodCandidate("0", "", "Noise test method"),
        ]
        output = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="9"), items, catalog(), factor_id="4"
        )
        self.assertEqual(output.selected.source_rule, "second_pass_priority_tag")
        self.assertEqual(output.selected.doc_name_id, "345")

    def test_missing_resource_is_explicit_error(self):
        source = [MethodCandidate("5", "", "Unknown")]
        out = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="9", nd_izm1="5"),
            source, catalog(), factor_id="4",
        )
        self.assertIn("normative_missing_from_resource_mdb", out.source_errors)
        self.assertTrue(out.selected.requires_review)

    def test_per_parameter_methods_override_protocol_level(self):
        shared = [MethodCandidate("7", "", "Noise test method")]
        own = (MethodCandidate("7", "", "Noise default method"),)
        out = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="9", nd_izm1="7",
                              own_methods=own),
            shared, catalog(), factor_id="4",
        )
        self.assertEqual(out.selected.doc_name_id, "456")
        self.assertEqual(out.selected.nd_guid, "ND2")

    def test_no_candidates_is_not_valid_export(self):
        out = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="9"), [], catalog(), factor_id="4",
        )
        self.assertEqual(out.selected.doc_name_id, "-1")
        self.assertIn("method_fgis_id_missing", out.source_errors)
        self.assertTrue(out.selected.requires_review)


if __name__ == "__main__":
    unittest.main()
