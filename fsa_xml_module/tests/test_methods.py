"""Regression checks for original 2025 three-pass method selection.

Source: v52_exp_fgis_ra2025.get_DocNameId in original Attestation51.dot.
"""
import unittest

from att51_fsa.methods import (MethodCandidate, ResearchForMethod, resolve_method,
                                bind_methods_from_catalog)
from att51_fsa.resources import ResourceCatalog


def candidate(nd_id, doc_id, doc_name, **attrs):
    return MethodCandidate(nd_id, doc_id, doc_name, **attrs)


class MethodResolutionTests(unittest.TestCase):
    def _catalog_without_method_id(self, *, factor=4, duplicates=False):
        rows = [{"id": 7, "mguid": "ND-7", "name": "Method Delta",
                 "factor_id": factor, "typ": 1}]
        if duplicates:
            rows.append({"id": 9, "mguid": "ND-9", "name": "Method Delta",
                         "factor_id": factor, "typ": 1})
        return ResourceCatalog.from_rows(
            [], [], rows, [],
            nd_info=[{"nd_id": 7, "dop2": "", "dop4": "", "dop5": "OA {14}"}],
        )

    def test_real_nd_without_numeric_method_id_has_verified_unique_method(self):
        catalog = self._catalog_without_method_id()
        result = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="3472", nd_izm1="7"),
            [candidate("7", "", "Method Delta")], catalog, factor_id="4",
        )
        self.assertEqual(result.selected.doc_name_id, "")
        self.assertEqual(result.selected.doc_name, "Method Delta")
        self.assertFalse(result.selected.requires_review)
        self.assertNotIn("method_fgis_id_missing", result.source_errors)
        self.assertIn("verified_original_unique_method_fallback", result.matching_rules)

    def test_does_not_guess_unique_method_for_different_factor(self):
        catalog = self._catalog_without_method_id(factor=5)
        result = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="3472", nd_izm1="7"),
            [candidate("7", "", "Method Delta")], catalog, factor_id="4",
        )
        self.assertIn("method_fgis_id_missing", result.source_errors)

    def test_does_not_guess_unique_method_for_duplicate_nd(self):
        catalog = self._catalog_without_method_id(duplicates=True)
        result = bind_methods_from_catalog(
            ResearchForMethod(indicator_id="3472", nd_izm1="7"),
            [candidate("7", "", "Method Delta")], catalog, factor_id="4",
        )
        self.assertIn("method_fgis_id_missing", result.source_errors)

    def test_first_pass_single_explicit_id(self):
        methods = [
            candidate("22", "444", "Method A"),
            candidate("3", "555", "Method B"),
        ]
        result = resolve_method(ResearchForMethod(
            indicator_id="9", nd_izm1="3"
        ), methods, {})
        self.assertEqual((result.source_rule, result.doc_name_id),
                         ("first_pass_nd_id", "555"))

    def test_first_pass_semicolon_list(self):
        methods = [
            candidate("24", "222", "Other"),
            candidate("2", "777", "Exact"),
        ]
        result = resolve_method(ResearchForMethod(
            indicator_id="9", nd_izm1="12;2;34"
        ), methods, {})
        self.assertEqual(result.doc_name_id, "777")
        self.assertEqual(result.source_rule, "first_pass_nd_id")

    def test_first_pass_refuses_partial_token(self):
        methods = [
            candidate("2", "777", "Partial"),
            candidate("12", "888", "Full"),
        ]
        result = resolve_method(ResearchForMethod(
            indicator_id="9", nd_izm1="12"
        ), methods, {})
        self.assertEqual(result.doc_name_id, "888")

    def test_first_pass_stops_on_real_document_id(self):
        methods = [
            candidate("2", "-1", "Unlinked"),
            candidate("3", "987", "Linked"),
        ]
        result = resolve_method(ResearchForMethod(
            indicator_id="9", nd_izm1="2;3"
        ), methods, {})
        self.assertEqual(result.doc_name_id, "987")
        self.assertFalse(result.requires_review)

    def test_second_pass_tag(self):
        methods = [
            candidate("0", "100", "Default"),
            candidate("0", "200", "Correct"),
        ]
        result = resolve_method(
            ResearchForMethod(indicator_id="9"),
            methods,
            {"Default": "", "Correct": "shum_izm"},
        )
        self.assertEqual((result.doc_name_id, result.source_rule),
                         ("200", "second_pass_priority_tag"))

    def test_second_pass_default_method(self):
        result = resolve_method(
            ResearchForMethod(indicator_id="16"),
            [candidate("0", "123", "Default light method")],
            {"Default light method": ""},
        )
        self.assertEqual((result.doc_name_id, result.source_rule),
                         ("123", "second_pass_default_nd"))

    def test_explicit_method_list_takes_precedence(self):
        shared = [candidate("4", "100", "Shared")]
        own = (candidate("4", "200", "Per-param"),)
        result = resolve_method(
            ResearchForMethod(indicator_id="9", nd_izm1="4", own_methods=own),
            shared, {},
        )
        self.assertEqual(result.doc_name_id, "200")

    def test_indicator_3472_is_not_automatically_replaced_by_281(self):
        # Source uses IndicatorId4 if available, else IndicatorId.
        # IndicatorId2 is *not* used for comparison, except the 66 case.
        result = resolve_method(
            ResearchForMethod(indicator_id="3472", indicator_id_2="281"),
            [candidate("0", "321", "Method")],
            {"Method": "shum_ekv"},
        )
        self.assertEqual(result.source_rule, "third_pass_first_doc_name_id")

    def test_third_pass_first_numerical_method_id(self):
        methods = [
            candidate("0", "", "No id"),
            candidate("0", "789", "Valid"),
            candidate("0", "999", "Later"),
        ]
        result = resolve_method(ResearchForMethod(indicator_id="999"),
                                methods, {})
        self.assertEqual((result.doc_name_id, result.source_rule),
                         ("789", "third_pass_first_doc_name_id"))

    def test_last_unique_and_empty_are_reported_as_incomplete(self):
        result = resolve_method(
            ResearchForMethod(indicator_id="99"),
            [candidate("0", "", "Some method")], {})
        self.assertTrue(result.requires_review)
        self.assertEqual(result.source_rule, "third_pass_unique_nd")
        missing = resolve_method(ResearchForMethod(indicator_id="99"), [], {})
        self.assertTrue(missing.requires_review)
        self.assertEqual(missing.doc_name_id, "-1")
        self.assertEqual(missing.source_rule, "third_pass_no_methods")


if __name__ == "__main__":
    unittest.main()
