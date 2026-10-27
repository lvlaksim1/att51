"""Verify v5_org_options source paths on synthetic local-only data."""
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch
import unittest

from organization_sources import load_organizations, unique_organization, customer_for_excel
from att51_fsa.sources import FsaSourceError


class FakeReader:
    def __init__(self, rows):
        self.rows = rows
    def __enter__(self):
        return self
    def __exit__(self, *_):
        return None
    def table_names(self):
        return ("STRUCT_ORG",)
    def select(self, sql):
        assert sql.lower() == "select * from struct_org"
        return self.rows


class OrganizationSourcesTests(unittest.TestCase):
    def test_reads_original_adv_data_path_and_customer_fields(self):
        with TemporaryDirectory() as folder:
            base = Path(folder)
            org = base / "Work_files" / "000_org_data" / "ABC-GUID"
            org.mkdir(parents=True)
            (org / "adv_data.xml").write_text(
                '<Document><dop_info query_date="08.10.2026"/>'
                '<org_reserve ogrn="1234567890123"/></Document>',
                encoding="utf-8")
            row = {"id": 9, "mguid": "ABC-GUID", "org": "Example",
                   "inn": "1234567890", "short_caption": "Краткое наименование",
                   "fio": "Person"}
            with patch("organization_sources.AccessReader", return_value=FakeReader([row])):
                result = unique_organization(base/"Work.mdb")
            self.assertEqual(result.query_date, "08.10.2026")
            self.assertEqual(result.inn, "1234567890")
            self.assertEqual(result.ogrn, "1234567890123")


    def test_ogrn_does_not_use_short_caption_as_registry_number(self):
        with TemporaryDirectory() as folder:
            root = Path(folder)
            row = {"id": 1, "mguid": "G", "short_caption": "ООО", "inn": "123"}
            with patch("organization_sources.AccessReader", return_value=FakeReader([row])):
                obj = unique_organization(root / "sample.mdb")
            self.assertEqual(obj.ogrn, "")


    def test_excel_customer_uses_unique_original_data_without_gui(self):
        with TemporaryDirectory() as folder:
            base = Path(folder)
            org = base / "Work_files" / "000_org_data" / "ABC-GUID"
            org.mkdir(parents=True)
            (org / "adv_data.xml").write_text(
                '<Document><dop_info query_date="19.03.2026"/>'
                '<org_reserve ogrn="1237700530715"/></Document>',
                encoding="utf-8")
            original = {"id": 9, "mguid": "ABC-GUID", "org": "ООО Пример",
                        "inn": "9722052050", "fio": "Иванов И.И.",
                        "adr": "Юридический адрес", "adr2": "Адрес деятельности",
                        "contact": "example@example.org"}
            with patch("organization_sources.AccessReader",
                       return_value=FakeReader([original])):
                result = customer_for_excel(base / "Work.mdb")
            self.assertEqual(result.application_date, "19.03.2026")
            self.assertEqual(result.full_name, "ООО Пример")
            self.assertEqual(result.ogrn, "1237700530715")
            self.assertEqual(result.customer_kind, 0)  # not fabricated from ООО
            self.assertEqual(result.source_address1, "Юридический адрес")
            self.assertEqual(result.source_address2, "Адрес деятельности")
            self.assertEqual(result.contacts, "example@example.org")

    def test_explicit_source_type_four_is_preserved(self):
        with TemporaryDirectory() as folder:
            original = {"id": 1, "mguid": "X", "org": "Физическое лицо",
                        "customer_kind": 4, "adr": "Адрес проживания"}
            with patch("organization_sources.AccessReader",
                       return_value=FakeReader([original])):
                result = customer_for_excel(Path(folder) / "Work.mdb")
            self.assertEqual(result.customer_kind, 4)
            from excel_source_batch import _address
            self.assertEqual(_address(result),
                             ("Адрес проживания", "Адрес места жительства"))

    def test_excel_refuses_ambiguous_customer_without_guessing(self):
        with TemporaryDirectory() as folder:
            rows = [
                {"id": 1, "mguid": "A", "org": "Первая"},
                {"id": 2, "mguid": "B", "org": "Вторая"},
            ]
            with patch("organization_sources.AccessReader",
                       return_value=FakeReader(rows)):
                with self.assertRaisesRegex(FsaSourceError, "несколько организаций"):
                    customer_for_excel(Path(folder) / "Work.mdb")

    def test_excel_refuses_absent_organization_without_guessing(self):
        with TemporaryDirectory() as folder:
            with patch("organization_sources.AccessReader",
                       return_value=FakeReader([])):
                with self.assertRaisesRegex(FsaSourceError, "отсутствует запись STRUCT_ORG"):
                    customer_for_excel(Path(folder) / "Work.mdb")

    def test_multiple_organizations_are_not_guessed(self):
        with TemporaryDirectory() as folder:
            rows=[{"id":1,"mguid":"A"},{"id":2,"mguid":"B"}]
            with patch("organization_sources.AccessReader",return_value=FakeReader(rows)):
                self.assertIsNone(unique_organization(Path(folder)/"Work.mdb"))

    def test_unsafe_guid_cannot_escape_source_tree(self):
        with TemporaryDirectory() as folder:
            with patch("organization_sources.AccessReader",
                       return_value=FakeReader([{"id":1,"mguid":"../private"}])):
                result=load_organizations(Path(folder)/"Work.mdb")
            self.assertIsNone(result[0].xml_file)
            self.assertEqual(result[0].query_date,"")


if __name__=="__main__":
    unittest.main()
