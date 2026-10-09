"""Original VBA -> strict FGIS XSD header mapping, no private user data."""
import unittest

from att51_fsa.original_header import build_header, fgis_date, fgis_status
from att51_fsa.sources import FsaSourceError


class OriginalHeaderTests(unittest.TestCase):
    def test_status_codes_are_numeric_for_xsd(self):
        self.assertEqual(fgis_status("13 - Отправлен"), "13")
        self.assertEqual(fgis_status("20 - Черновик"), "20")
        self.assertEqual(fgis_status("6 - Действует", protocol=True), "6")
        self.assertEqual(fgis_status("6", protocol=True), "6")

    def test_refuse_unknown_or_conflicting_status(self):
        for x in ("11", "13 - Черновик", "20 - Отправлен", "13-bad", ""):
            with self.subTest(x=x), self.assertRaises(FsaSourceError):
                fgis_status(x)

    def test_dates_do_not_fall_back_to_now(self):
        self.assertEqual(fgis_date("11.03.2026", source="test"), "2026-03-11")
        for x in ("", "-", "31.02.2026", "unknown", "Отсутствует"):
            with self.subTest(x=x), self.assertRaises(FsaSourceError):
                fgis_date(x, source="test")

    def test_original_13_dates_and_object(self):
        h = build_header(number="X-01", protocol_date="24.03.2026",
                         measurement_dates=("11.03.2026", "12.03.2026"),
                         application_date="10.03.2026", factor_id=13,
                         data_status="20 - Черновик")
        self.assertEqual(h.start_date, "2026-03-11")
        self.assertEqual(h.validity_date, "2026-03-12")
        self.assertEqual(h.object_type_id, 10)
        self.assertEqual(h.data_status_id, "20")
        self.assertEqual(h.object_name, "Тяжесть трудового процесса")

    def test_original_14_object_and_override(self):
        h=build_header(number="N-01",protocol_date="2026-03-24",
                       measurement_dates=("2026-03-22",),
                       application_date="2026-03-20",factor_id="14",
                       data_status=13,
                       object_name_override="Индивидуальный фактор")
        self.assertEqual(h.object_name,"Индивидуальный фактор")

    def test_missing_org_date_and_reversed_dates_block(self):
        kwargs=dict(number="P-01",protocol_date="24.03.2026",
                    measurement_dates=("12.03.2026",),factor_id=14,
                    data_status=20)
        with self.assertRaises(FsaSourceError):
            build_header(**kwargs,application_date="")
        with self.assertRaises(FsaSourceError):
            build_header(**kwargs,application_date="25.03.2026")
        with self.assertRaises(FsaSourceError):
            build_header(**{**kwargs,"measurement_dates":("26.03.2026",)},
                         application_date="20.03.2026")


if __name__ == "__main__":
    unittest.main()
