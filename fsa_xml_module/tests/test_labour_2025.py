"""Regression based on exact factor branches from original ATT51 VBA."""
import unittest
from xml.etree import ElementTree as ET

from att51_fsa.labour_2025 import LabourOptions, map_labour_2025


class LabourMappings(unittest.TestCase):
    def test_heavy_summary_known_fgis_ids(self):
        doc = ET.fromstring("""<Document><factor facid="13"/><izm_data><zone>
          <param bm="bm_1_1_m" fact="12,5" nd_izm1="nd"/>
          <param bm="bm_2_2_m" fact="11" nd_izm1="nd"/>
          <param bm="bm_7_1" fact="1,2" nd_izm1="nd"/>
        </zone></izm_data></Document>""")
        result = map_labour_2025(doc, LabourOptions())
        self.assertEqual([(r.indicator_id, r.directory, r.measurement_id)
                          for r in result],
                         [("131455", "2", "985"),
                          ("131459", "2", "35"),
                          ("131474", "2", "5")])
        self.assertEqual(result[0].fact_value, "12,5")

    def test_heavy_totals_must_be_selected(self):
        doc = ET.fromstring("""<Document><factor facid="13"/><izm_data><zone>
          <param bm="bm_1_3_m" fact="2000"/></zone></izm_data></Document>""")
        self.assertEqual(map_labour_2025(doc, LabourOptions()), [])
        out = map_labour_2025(doc, LabourOptions(include_heavy_totals=True))
        self.assertEqual(out[0].indicator_id, "163795")

    def test_direct_uses_semicolon_and_two_different_units(self):
        doc = ET.fromstring("""<Document><factor facid="13"/><count_params2>
          <param id="bm_1" param1="2; 3" param2="4; 5" nd_izm1="ND"/>
          <param id="bm_4_1" param1="9" param2="15"/>
        </count_params2></Document>""")
        out = map_labour_2025(doc, LabourOptions(heavy_direct=True))
        self.assertEqual([(r.indicator_id,r.measurement_id,r.fact_value)
                          for r in out],
                         [("37","35","2"),("37","35","3"),
                          ("42","4","4"),("42","4","5"),
                          ("37","35","9"),("39","96","15")])

    def test_original_classic_pose_texts(self):
        doc=ET.fromstring("""<Document><factor facid="13" poza_id="8"/>
          <izm_data><zone><param bm="a13" fact=""/></zone></izm_data>
          </Document>""")
        out=map_labour_2025(doc,LabourOptions())
        self.assertEqual([(v.indicator_id,v.fact_value,v.measurement_id) for v in out],
                         [("131472","от 60 до 80","292")])

    def test_strain_filters_and_original_bm_precedence(self):
        doc=ET.fromstring("""<Document><factor facid="14"/><izm_data><zone>
          <param bm_id="n_bm1_3" bm="s09" fact="60" nd_izm1="N"/>
          <param bm_id="n_bm2_3_2" bm="s20" fact="5"/>
          <param bm_id="n_bm1_2" bm="s07" fact="4"/>
        </zone></izm_data></Document>""")
        out=map_labour_2025(doc,LabourOptions(strain_optic=False))
        self.assertEqual([(v.indicator_id,v.measurement_id) for v in out],
                         [("48","292"),("123117","282")])

    def test_uncertainty_and_absent_values(self):
        doc=ET.fromstring("""<Document><factor facid="14"/><izm_data><zone>
          <param bm="s12" fact="10" U095="1,2"/>
          <param bm="s13" fact="Не измерено"/>
        </zone></izm_data></Document>""")
        out=map_labour_2025(doc,LabourOptions(include_uncertainty=True))
        self.assertEqual(len(out),1)
        self.assertEqual(out[0].fact_value,"10±1,2")

    def test_special_nd_condition(self):
        doc=ET.fromstring("""<Document><factor facid="14"/><nd_data>
          <nd name="МИ НТП.ИНТ-17.01-2018"/></nd_data>
          <izm_data><zone><param bm="s51" fact="7"/></zone></izm_data>
          </Document>""")
        out=map_labour_2025(doc,LabourOptions())
        self.assertEqual([x.indicator_id for x in out],["131374"])


if __name__ == "__main__":
    unittest.main()
