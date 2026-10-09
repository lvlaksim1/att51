"""Regression tests against original ATT51 VBA branch predicates and IDs.

Derived from extracted VBA:
v52_exp_fgis_ra.bas: read_sv_prots, fill_fgis_ra_data, GetSQLFacFilter2
v52_exp_fgis_ra2025.bas: read_ekv_shum_param, get_num, get_ekv_shum_unc
"""
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch
from xml.etree import ElementTree as ET
import unittest

from att51_fsa.measurements import NoiseOptions, map_noise_equivalent, original_get_num
from att51_fsa.selection import select_individual, select_consolidated
from att51_fsa.sources import FsaSourceError


class NoiseMappingTests(unittest.TestCase):
    def fixture(self):
        return ET.fromstring(
            '<Document U8h="1,4">'
            '<factor facid="4" fac_name="Шум"/>'
            '<izm_res_data>'
            '<izm level="80,2" levels="75,5" unc="1,5" nd_izm1="ND-1"/>'
            '<izm level="81,1" levels="" unc="0,3" nd_izm1="ND-2"/>'
            '</izm_res_data>'
            '<izm_data>'
            '<Level bm="Lekv" fact="85,0" nd_izm1="ND-total"/>'
            '</izm_data>'
            '</Document>'
        )

    def test_basic_equivalent_only(self):
        result = map_noise_equivalent(self.fixture(), NoiseOptions(False, False, False, False))
        self.assertEqual(len(result), 1)
        self.assertEqual((result[0].indicator_id, result[0].indicator_id_2,
                          result[0].directory, result[0].measurement_id,
                          result[0].fact_value, result[0].nd_izm1),
                         ("3472", "281", "1", "650", "85,0", "ND-total"))

    def test_acoustic_and_equivalent_can_be_returned_together(self):
        result = map_noise_equivalent(self.fixture(), NoiseOptions(True, False, False, False))
        self.assertEqual([r.indicator_id for r in result], ["9", "9", "3472"])
        self.assertEqual([r.fact_value for r in result], ["75,5", "81,1", "85,0"])

    def test_original_equivalent_disabled_by_two_flags(self):
        result = map_noise_equivalent(self.fixture(), NoiseOptions(True, True, True, False))
        self.assertEqual([r.indicator_id for r in result], ["9", "9"])
        self.assertEqual([r.fact_value for r in result], ["80,2", "81,1"])

    def test_uncertainty_differs_between_acoustic_and_summary(self):
        result = map_noise_equivalent(self.fixture(), NoiseOptions(True, False, True, True))
        self.assertEqual([r.fact_value for r in result],
                         ["80,2±1,5", "81,1±0,3", "85,0±1,4"])

    def test_unchanged_vba_get_num(self):
        for value in ("<0,3", "1±0,1", "-2", "a1b"):
            self.assertEqual(original_get_num(value), value)
        self.assertEqual(original_get_num("—"), "")
        self.assertEqual(original_get_num("нет"), "")

    def test_no_digit_rejected(self):
        document = self.fixture()
        document.find("./izm_data/Level").set("fact", "-")
        document.find("./izm_res_data/izm").set("levels", "-")
        document.findall("./izm_res_data/izm")[1].set("level", "")
        self.assertEqual(map_noise_equivalent(document, NoiseOptions(True, False, False, False)), [])

    def test_wrong_factor_rejected(self):
        doc = self.fixture()
        doc.find("factor").set("facid", "5")
        with self.assertRaises(FsaSourceError):
            map_noise_equivalent(doc, NoiseOptions(False, False, False, False))


class SourceSelectionTests(unittest.TestCase):
    @staticmethod
    def make_root(directory):
        root = Path(directory) / "ARMv51_files"
        root.mkdir()
        return root

    def test_individual_factor_and_10009_checkbox_rules(self):
        with TemporaryDirectory() as temp:
            root = self.make_root(temp)
            p = root / "rm1/xml"
            p.mkdir(parents=True)
            (p / "emp.xml").write_text("<Document/>")
            class Reader:
                def __init__(self, _db): pass
                def __enter__(self): return self
                def __exit__(self, *args): pass
                def select(self, sql):
                    assert "rm_id=7" in sql
                    return [
                        {"factor_id": 4, "file": r"rm1\noise.docx"},
                        {"factor_id": 16, "file": r"rm1\ignored.docx"},
                        {"factor_id": 10009, "file": r"rm1\emp.docx"},
                        {"factor_id": 10099, "file": r"rm1\aeroion.docx"},
                        {"factor_id": 10001, "file": r"rm1\excluded.docx"},
                    ]
            with patch("att51_fsa.selection.AccessReader", Reader):
                selected = select_individual(Path(temp) / "test.mdb", root,
                                             selected_workplace_ids=[7],
                                             enabled_factors=[4, 9, 10099])
            self.assertEqual([p.factor_id for p in selected], [4, 10009, 10099])
            self.assertEqual([p.status for p in selected],
                             ["missing_xml", "available", "missing_xml"])

    def test_individual_requires_explicit_selected_ids(self):
        with TemporaryDirectory() as tmp:
            root = self.make_root(tmp)
            with self.assertRaises(FsaSourceError):
                select_individual(Path(tmp) / "test.mdb", root,
                                  selected_workplace_ids=[1, 1],
                                  enabled_factors=[4])

    def test_summary_selection_and_legacy_mode(self):
        with TemporaryDirectory() as tmp:
            root = self.make_root(tmp)
            folder = root / "000_org_data" / "ORG-ID"
            docs = folder / "sv_docs"
            docs.mkdir(parents=True)
            (folder / "docs_list.xml").write_text(
                '<Document>'
                '<doc name="Noise protocol" file="noise.docx" doc_type="3" '
                'nd_mode="1" podr_id="ceh_5" num_doc="1"/>'
                '<doc name="Old radio" file="radio.docx" doc_type="3" '
                'nd_mode="0" podr_id="" num_doc="2"/>'
                '<doc name="Ignore" file="not_sout.docx" doc_type="2"/>'
                '<doc name="Missing" file="missing.docx" doc_type="3"/>'
                '</Document>', encoding="utf-8"
            )
            for name, fac in (("noise", 4), ("radio", 950)):
                (docs / (name + ".docx")).write_bytes(b"FAKE_WORD_TEST")
                (docs / (name + ".xml")).write_text(
                    '<Document fac_id="' + str(fac) + '"/>', encoding="utf-8"
                )
            entries = select_consolidated(root, "ORG-ID",
                                          visible_divisions=["ceh_5"],
                                          enabled_factors=[4, 9])
            self.assertEqual([e.protocol_number for e in entries], ["1", "2"])
            self.assertEqual([e.status for e in entries], ["available", "legacy_nd_mode"])
            self.assertEqual([e.factor_id for e in entries], [4, 9])
            self.assertEqual(entries[0].xml_file, str(docs / "noise.xml"))

            with_region = select_consolidated(
                root, "ORG-ID", visible_divisions=["ceh_5"],
                region_divisions=["other"], enabled_factors=[4, 9])
            # Original condition allows no-podr_id summary prot regardless region.
            self.assertEqual([e.protocol_number for e in with_region], ["2"])

    def test_summary_hidden_division_and_invalid_path(self):
        with TemporaryDirectory() as tmp:
            root = self.make_root(tmp)
            folder = root / "000_org_data" / "GUID"
            (folder / "sv_docs").mkdir(parents=True)
            (folder / "docs_list.xml").write_text(
                '<root><Document><doc name="A" file="file.docx" '
                'podr_id="uch_1" doc_type="3"/></Document></root>'
            )
            (folder / "sv_docs" / "file.docx").touch()
            self.assertEqual(select_consolidated(root, "GUID",
                             visible_divisions=[]), [])
            with self.assertRaises(FsaSourceError):
                select_consolidated(root, "../bad", visible_divisions=[])


if __name__ == "__main__":
    unittest.main()
