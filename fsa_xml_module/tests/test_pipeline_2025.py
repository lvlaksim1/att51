"""End-to-end intermediate mapping from ATT51 sidecar and synthetic resources.

No real customers or credentials; full FSA export remains disabled.
"""
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from xml.etree import ElementTree as ET

from att51_fsa.pipeline_2025 import (
    Original2025Options, analyze_2025, diagnostic_dict, SUPPORTED_FACTORS
)
from att51_fsa.resources import ResourceCatalog


def catalog(contains_method=True):
    return ResourceCatalog.from_rows(
        devices=[{"id": 1, "mguid": "DEVICE1", "factory_num": "D-11",
                  "name": "Synthetic measurement device"}],
        people=[],
        normative=(
            [{"id": 1, "mguid": "ND-1", "name": "ГОСТ 12.1.003-83",
              "factor_id": 4, "typ": 1}] if contains_method else []
        ),
        nd_info=(
            [{"nd_id": 1, "key_ctxt": "ГОСТ 12.1.003-83",
              "dop2": 123, "dop4": "shum_izm",
              "dop5": "Approved laboratory method {350}"}]
            if contains_method else []
        ),
        links=[{"rec_type": 0, "rec_guid": "DEVICE1", "IntValue": 555}],
        present_tables={"ATT_DEVICE", "ATT_PERSON", "DIC_ND", "FGIS_RA",
                        "DIC_ND_INFO"},
    )


def prot(*, state="0", method=True, factor="4"):
    nd = ('<nd id="2" name="ГОСТ 12.1.003-83" action="1"/>'
          if method else '')
    return ET.fromstring(
        '<Document num_doc="SYNTH-001" fgis_state="' + state + '">'
        '<factor facid="' + factor + '">'
        '<si_guids><si_guid guid="DEVICE1" num="D-11"/></si_guids>'
        '</factor>'
        '<nd_data>' + nd + '</nd_data>'
        '<izm_data><Level bm="Lekv" fact="86,3" nd_izm1="2"/></izm_data>'
        '</Document>'
    )


class PipelineTests(unittest.TestCase):
    def test_original_sources_to_prepared_research_value(self):
        r = analyze_2025(prot(), catalog(), Original2025Options())
        self.assertEqual(r.status, "intermediate_mapping_complete_not_working_xml")
        self.assertTrue(r.not_exportable)
        self.assertEqual(len(r.measurement_traces), 1)
        v = r.measurement_traces[0]
        self.assertEqual((v.method_rule, v.method_id),
                         ("first_pass_nd_id", "123"))
        self.assertEqual(v.prepared.oa_method_id, "350")
        self.assertEqual(v.prepared.directory, "DM-53535")
        self.assertEqual(v.prepared.fact_value, "86,3")
        self.assertEqual(v.prepared.source_xpath,
                         "Document/izm_data/Level[@bm='Lekv']")
        self.assertIn("working_fgis_ra_ini_not_supplied", v.warnings)

    def test_uses_working_original_ini_overrides(self):
        with TemporaryDirectory() as folder:
            config = Path(folder) / "fgis_ra.ini"
            config.write_text(
                "[Measurements]\nid1_3472=994\n"
                "[vars_fiz1~3472]\n123=2~199\n",
                encoding="utf-8"
            )
            r = analyze_2025(
                prot(), catalog(), Original2025Options(),
                working_fgis_ini=config
            )
            item = r.measurement_traces[0].prepared
            self.assertEqual((item.indicator_id, item.directory, item.measurement_id),
                             ("199", "DM-55254", "994"))

    def test_specific_oa_method_overrides_default_for_acoustic_indicator(self):
        c = ResourceCatalog.from_rows(
            devices=[], people=[],
            normative=[{"id": 1, "mguid": "ND-1",
                        "name": "ГОСТ 12.1.003-83",
                        "factor_id": 4, "typ": 1}],
            links=[],
            nd_info=[{"nd_id": 1, "key_ctxt": "ГОСТ",
                      "dop2": 123, "dop4": "shum_izm",
                      "dop5": "Default {350}"}],
            oa_methods=[{"nd_guid": "ND-1", "method": "Special OA {777}",
                         "params": "temp;shum_izm"}],
            present_tables={"ATT_DEVICE", "ATT_PERSON", "DIC_ND",
                            "DIC_ND_INFO", "DIC_ND_OA_METHODS"},
        )
        root = prot()
        izm = ET.SubElement(root, "izm_res_data")
        ET.SubElement(izm, "izm", level="85", nd_izm1="2")
        result = analyze_2025(
            root, c, Original2025Options(
                acoustic_measurements=True,
                both_measurements_and_equivalent=True,
                acoustic_level_per_operation=True,
            )
        )
        self.assertEqual(len(result.measurement_traces), 1)
        value = result.measurement_traces[0]
        self.assertEqual(value.prepared.indicator_id, "9")
        self.assertEqual(value.prepared.oa_method_id, "777")
        self.assertIn("oa_method_selected_from_indicator_specific_resource",
                      value.warnings)

    def test_missing_method_is_not_fabricated(self):
        r = analyze_2025(prot(method=False), catalog(), Original2025Options())
        self.assertEqual(r.status, "requires_correction")
        self.assertIn("no_original_measurement_methods", r.errors)
        self.assertEqual(r.measurement_traces[0].result_status,
                         "excluded_by_original_rule")

    def test_method_missing_in_original_resource_db(self):
        r = analyze_2025(prot(), catalog(contains_method=False),
                         Original2025Options())
        self.assertEqual(r.status, "requires_correction")
        self.assertIn("normative_missing_from_resource_mdb", r.errors)

    def test_unsupported_factor_explicit(self):
        r = analyze_2025(prot(factor="7"), catalog(), Original2025Options())
        self.assertFalse(r.supported)
        self.assertEqual(r.status, "unsupported_factor")
        self.assertIn("factor_not_yet_implemented", r.errors)

    def test_excluded_protocol_never_reads_sources(self):
        r = analyze_2025(prot(state="1"), catalog(), Original2025Options())
        self.assertEqual(r.status, "excluded_by_fgis_state")
        self.assertEqual(len(r.measurement_traces), 0)

    def test_supported_factors_have_distinct_ids(self):
        self.assertEqual(SUPPORTED_FACTORS,
                         frozenset(("4", "5", "6", "11", "12", "13", "14", "10099")))

    def test_diagnostic_json_has_no_export_status(self):
        r = analyze_2025(prot(), catalog(), Original2025Options())
        d = diagnostic_dict(r)
        self.assertTrue(d["not_exportable"])
        self.assertIn("measurement_traces", d)


if __name__ == "__main__":
    unittest.main()
