"""Regression tests for the original res_orgs.mdb FGIS resource lookup.

No working personal data or actual FSA IDs are used; values are synthetic.
"""
from dataclasses import asdict
from tempfile import TemporaryDirectory
from pathlib import Path
from pathlib import Path
import unittest

from att51_fsa.resources import ResourceCatalog, nd_hash, ResourceResolution, resource_mdb_path
from att51_fsa.sources import FsaSourceError


def build(*, with_fgis=True):
    return ResourceCatalog.from_rows(
        devices=[
            {"id": 1, "mguid": "DEVICE_A", "factory_num": "AB-120", "name": "Device A"},
            {"id": 2, "mguid": "DEVICE_B", "factory_num": "X", "name": "Device B"},
        ],
        people=[
            {"mguid": "PERSON_A", "snils": "123-456-789 00", "fio": "Tester A", "dolg": "Lab", "no_dop_fld2": "FGIS approved position"},
            {"mguid": "PERSON_B", "snils": "not assigned", "fio": "Tester B"},
        ],
        normative=[
            {"id": 7, "mguid": "ND_A", "name": "ГОСТ 12.1.003-83", "factor_id": 4, "typ": 0},
            {"id": 8, "mguid": "ND_B", "name": "ГОСТ 12.1.003-83", "factor_id": 5, "typ": 0},
            {"id": 9, "mguid": "ND_C", "name": "Методика 77", "factor_id": 12, "typ": 1},
            {"id": 10, "mguid": "ND_D", "name": "НД пусто", "factor_id": 12, "typ": 1},
        ],
        nd_info=[
            {"nd_id": 7, "key_ctxt": "ГОСТ 12.1.003-83", "dop2": 111, "dop4": "shum_izm", "dop5": "IM-11"},
            {"nd_id": 8, "key_ctxt": "ГОСТ 12.1.003-83", "dop2": 222, "dop4": "infr_izm", "dop5": "IM-22"},
            {"nd_id": 9, "key_ctxt": "Методика", "dop2": 0, "dop4": "", "dop5": ""},
        ],
        synonyms=[
            {"mguid": "ND_C", "name": "Метод измерения 77"}
        ],
        links=(
            [{"rec_type": 0, "rec_guid": "DEVICE_A", "IntValue": 999, "Descr": "instrument"},
             {"rec_type": 1, "rec_guid": "PERSON_A", "IntValue": 555, "Descr": "employee"}]
            if with_fgis else []
        ),
        present_tables={"ATT_DEVICE", "ATT_PERSON", "DIC_ND", "FGIS_RA",
                        "DIC_ND_INFO", "DIC_ND_SYN"} if with_fgis else {
                            "ATT_DEVICE", "ATT_PERSON", "DIC_ND"
                        }
    )


class ResourceLookupTests(unittest.TestCase):
    def test_nd_hash_original_digits_and_vowels(self):
        self.assertEqual(nd_hash("ГОСТ 12.1.003-83"), "о12100383")
        self.assertEqual(nd_hash("Гост 12.1.003-83"), "о12100383")

    def test_device_prefers_guid_over_serial(self):
        data = build().device("DEVICE_A", "X")
        self.assertEqual((data.local_id, data.fgis_id, data.source_rule),
                         ("1", "999", "guid"))
        self.assertFalse(data.requires_review)

    def test_device_can_fallback_to_factory_number_only_with_digit(self):
        data = build().device("UNAVAILABLE", "AB-120")
        self.assertEqual(data.source_rule, "factory_num")
        self.assertEqual(data.local_guid, "DEVICE_A")
        self.assertFalse(build().device("UNAVAILABLE", "X").found)

    def test_position_uses_original_att_person_no_dop_fld2(self):
        catalog = build()
        item = next(p for p in catalog.people if p.guid == "PERSON_A")
        self.assertEqual(item.fgis_position, "FGIS approved position")
        self.assertEqual(item.job, "Lab")
        self.assertNotEqual(item.fgis_position, item.job)

    def test_person_prefers_guid_then_snils(self):
        d = build()
        self.assertEqual(d.person("PERSON_A", "wrong").source_rule, "guid")
        p = d.person("WRONG", "123-456-789 00")
        self.assertEqual((p.source_rule, p.fgis_id), ("snils", "555"))
        self.assertFalse(d.person("WRONG", "not assigned").found)

    def test_missing_links_are_reported_never_invented(self):
        d = build(with_fgis=False)
        result = d.device("DEVICE_A")
        self.assertTrue(result.found)
        self.assertEqual(result.fgis_id, "")
        self.assertTrue(result.requires_review)
        self.assertIn("equipment_fgis_id_missing", result.warnings)
        self.assertIn("FGIS_RA", d.diagnostics.tables_absent)

    def test_factor_specific_nd_match_wins(self):
        d = build()
        h = nd_hash("ГОСТ 12.1.003-83")
        four = d.nd(h, "ГОСТ 12.1.003-83", "4")
        five = d.nd(h, "ГОСТ 12.1.003-83", "5")
        self.assertEqual(four.normative.method_doc_id, "111")
        self.assertEqual(five.normative.method_doc_id, "222")
        self.assertEqual(four.source_rule, "hash_with_factor")

    def test_duplicate_nonfactor_nd_is_reported(self):
        res = build().nd(nd_hash("ГОСТ 12.1.003-83"), "ГОСТ 12.1.003-83")
        self.assertEqual(res.alternatives, 2)
        self.assertIn("duplicate_normative_matches", res.warnings)
        self.assertEqual(res.normative.local_id, "7")

    def test_nd_synonym_lookup(self):
        res = build().nd(nd_hash("Метод измерения 77"), "Метод измерения 77", "12")
        self.assertTrue(res.found)
        self.assertEqual(res.normative.guid, "ND_C")

    def test_nd_short_name_pass_marks_uncertainty(self):
        res = build().nd("zz", "Проведено по Методика номеру", "12")
        self.assertEqual(res.source_rule, "short_name_like")
        self.assertTrue(res.requires_review)

    def test_nd_absent_blocks_export_instead_of_fabrication(self):
        d = build()
        res = d.nd("none", "Absent", "4")
        self.assertFalse(res.found)
        self.assertEqual(d.nd_diagnostics(res), ("fatal_nd_absent",))

    def test_nd_missing_short_name_is_fatal_for_assessment(self):
        d = build()
        res = d.nd(nd_hash("НД пусто"), "НД пусто", "12")
        self.assertTrue(res.found)
        self.assertIn("fatal_nd_short_name_missing", d.nd_diagnostics(res, "0"))
        self.assertNotIn("fatal_nd_short_name_missing", d.nd_diagnostics(res, "1"))

    def test_oa_method_by_nd_guid_and_indicator_param(self):
        c = ResourceCatalog.from_rows(
            devices=[], people=[], normative=[], links=[],
            oa_methods=[
                {"nd_guid": "ND1", "method": "OA method {111}", "params": "temp;shum_izm"},
                {"nd_guid": "ND1", "method": "Later OA method {222}", "params": "shum_izm"},
                {"nd_guid": "ND2", "method": "Other ND {333}", "params": "shum_izm"},
            ],
            present_tables={"ATT_DEVICE", "ATT_PERSON", "DIC_ND",
                            "DIC_ND_OA_METHODS"},
        )
        self.assertEqual(c.oa_method_for("ND1", "shum_izm"), "OA method {111}")
        self.assertEqual(c.oa_method_for("ND2", "shum_izm"), "Other ND {333}")
        self.assertEqual(c.oa_method_for("ND1", "svet_Kp"), "")
        self.assertEqual(c.diagnostics.oa_method_count, 3)

    def test_nd_priority_comes_from_original_dop4(self):
        self.assertEqual(build().nd_preference("ГОСТ 12.1.003-83"), "shum_izm")
        self.assertIsNone(build().nd_preference("Unrelated"))

    def test_original_ini_defaults_to_application_resources(self):
        with TemporaryDirectory() as d:
            base = Path(d)
            (base / "options.ini").write_text("[update]\nversion=5.1\n", encoding="utf-8")
            default = base / "res_orgs.mdb"
            default.touch()
            self.assertEqual(resource_mdb_path(base), default)

    def test_original_ini_shared_database_mode(self):
        with TemporaryDirectory() as d:
            base = Path(d)
            other = base / "shared_resources.mdb"
            other.touch()
            (base / "options.ini").write_text(
                "[DB_res]\nres_flag=1\nres_path=" + str(other) + "\n",
                encoding="utf-8",
            )
            self.assertEqual(resource_mdb_path(base), other)

    def test_missing_original_shared_resource_blocks(self):
        with TemporaryDirectory() as d:
            base = Path(d)
            (base / "options.ini").write_text(
                "[DB_res]\nres_flag=1\nres_path=\n", encoding="utf-8")
            with self.assertRaisesRegex(FsaSourceError, "res_path"):
                resource_mdb_path(base)

    def test_reader_only_selects_present_tables(self):
        class FakeReader:
            def __init__(self):
                self.calls = []
            def table_names(self):
                return frozenset({"ATT_DEVICE", "ATT_PERSON", "DIC_ND"})
            def select(self, sql):
                self.calls.append(sql)
                return []
        reader = FakeReader()
        d = ResourceCatalog.from_reader(reader)
        self.assertEqual(d.diagnostics.device_count, 0)
        self.assertEqual(len(reader.calls), 3)
        self.assertEqual(d.diagnostics.fgis_link_count, 0)

    def test_reader_rejects_missing_mandatory_table(self):
        class FakeReader:
            def table_names(self):
                return frozenset({"ATT_DEVICE", "DIC_ND"})
        with self.assertRaises(FsaSourceError):
            ResourceCatalog.from_reader(FakeReader())


if __name__ == "__main__":
    unittest.main()
