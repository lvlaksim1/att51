"""Verify v5_org_options source paths on synthetic local-only data."""
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch
import unittest

from organization_sources import load_organizations, unique_organization


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
                '<Document><dop_info query_date="08.10.2026"/></Document>',
                encoding="utf-8")
            row = {"id": 9, "mguid": "ABC-GUID", "org": "Example",
                   "inn": "1234567890", "short_caption": "1234567890123",
                   "fio": "Person"}
            with patch("organization_sources.AccessReader", return_value=FakeReader([row])):
                result = unique_organization(base/"Work.mdb")
            self.assertEqual(result.query_date, "08.10.2026")
            self.assertEqual(result.inn, "1234567890")
            self.assertEqual(result.ogrn, "1234567890123")

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
