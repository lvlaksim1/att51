"""Regression translated directly from the 2025 VBA AПФД branches."""
import unittest
from xml.etree import ElementTree as ET

from att51_fsa.aerosol_2025 import (
    ChemicalOptions, map_aerosol_2025, original_him_id,
    original_him_name,
)
from att51_fsa.sources import FsaSourceError


class AerosolTests(unittest.TestCase):
    def test_original_him_id_and_name(self):
        self.assertEqual(original_him_id("ko1_405"), "405")
        self.assertEqual(original_him_id("kcss405"), "405")
        self.assertEqual(original_him_id("kmax405"), "405")
        self.assertEqual(original_him_name("Пыль каменная, мг/м3"), "Пыль каменная")
        self.assertEqual(original_him_name("Пыль"), "Пыль")

    def fixture(self):
        return ET.fromstring('''<Document type="protocol2019">
           <factor facid="3"/>
           <izm_data>
             <zone>
               <param bm="ko1_405" fact="0,55" results="0,50"
                 nd_izm1="7" name="Пыль условная. мг/м³" U095="0,03"/>
               <param bm="invalid" fact="200" name="Other"/>
             </zone>
             <itog><param bm="kcss405" fact="0,45"
                         U095="0,01" name="Пыль условная"/></itog>
           </izm_data>
           <izm_data2><kut_results>
             <param bm_id="him_kut_id405" Cmax="0,73" CmaxUNC="0,02"
                    name="Пыль условная"/>
           </kut_results></izm_data2>
         </Document>''')

    def test_direct_original_code_66_and_unit_533(self):
        d = map_aerosol_2025(self.fixture(), ChemicalOptions())
        self.assertEqual(len(d), 1)
        p = d[0]
        self.assertEqual((p.indicator_id, p.directory, p.measurement_id),
                         ("66", "1", "533"))
        self.assertEqual((p.chemical_id, p.chemical_name),
                         ("405", "Пыль условная"))
        self.assertEqual((p.fact_value, p.nd_izm1), ("0,55", "7"))

    def test_original_optional_results_override_uncertainty(self):
        d = map_aerosol_2025(self.fixture(), ChemicalOptions(
            include_uncertainty=True, use_detailed_results=True))
        self.assertEqual(d[0].fact_value, "0,50")

    def test_shift_and_max_original_order_nd_inheritance(self):
        options = ChemicalOptions(include_shift_average=True, include_maximum=True,
                                  omit_point_measurements=True)
        d = map_aerosol_2025(self.fixture(), options)
        self.assertEqual([x.fact_value for x in d], ["0,45", "0,73"])
        self.assertTrue(all(x.nd_izm1 == "7" for x in d))
        self.assertTrue(all(x.chemical_id == "405" for x in d))

    def test_do_not_generate_max_in_legacy_protocol(self):
        root = self.fixture()
        root.set("type", "legacy")
        d = map_aerosol_2025(root, ChemicalOptions(include_maximum=True))
        self.assertEqual(len(d),1)

    def test_missing_result_is_not_fabricated(self):
        root = ET.fromstring("""<Document><factor facid="3"/>
        <izm_data><zone><param bm="ko1_405" fact="-"/></zone></izm_data>
        </Document>""")
        self.assertEqual(map_aerosol_2025(root, ChemicalOptions()), [])

    def test_other_factor_rejected(self):
        with self.assertRaises(FsaSourceError):
            map_aerosol_2025(ET.fromstring('<Document><factor facid="4"/></Document>'),
                             ChemicalOptions())


if __name__ == "__main__":
    unittest.main()
