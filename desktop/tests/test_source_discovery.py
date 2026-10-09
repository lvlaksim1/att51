"""Issue #8: synthetic path discovery, with no access to user data."""
from __future__ import annotations

import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
sys.path.insert(0, str(DESKTOP.parents[0] / "fsa_xml_module"))

from source_discovery import (
    ORIGINAL_DIR, discover_installations, discover_protocols,
)


class SourceDiscoveryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.install = self.base / ORIGINAL_DIR
        self.install.mkdir()
        (self.install / "Attestation51.dot").touch()
        self.data = self.base / "work"
        self.data.mkdir()
        self.mdb = self.data / "Lab.mdb"
        self.mdb.touch()
        (self.install / "res_orgs.mdb").touch()
        self.ini = self.install / "options.ini"
        self.ini.write_text(f"[DB]\nsout_path={self.mdb}\n[DB_res]\nres_flag=0\n",
                            encoding="utf-8")

    def detect(self):
        return discover_installations((self.install,))

    def test_single_configured_db_without_guesswork(self):
        found = self.detect()
        self.assertEqual(len(found), 1)
        self.assertEqual(found[0].databases, (self.mdb,))
        self.assertEqual(found[0].resources, (self.install / "res_orgs.mdb",))
        self.assertEqual(found[0].settings, ())

    def test_external_resource_is_authoritative(self):
        external = self.base / "shared"
        external.mkdir()
        (external / "res_orgs.mdb").touch()
        self.ini.write_text(
            f"[DB]\nsout_path={self.mdb}\n[DB_res]\nres_flag=1\nres_path={external}\n",
            encoding="utf-8")
        result = self.detect()[0]
        self.assertEqual(result.resources, (external / "res_orgs.mdb",))

    def test_missing_shared_resource_never_falls_back(self):
        self.ini.write_text(
            f"[DB]\nsout_path={self.mdb}\n[DB_res]\nres_flag=1\n"
            f"res_path={self.base / 'missing.mdb'}\n", encoding="utf-8")
        result = self.detect()[0]
        self.assertFalse(result.resources)
        self.assertTrue(any("не подставлен" in t for t in result.warnings))

    def test_missing_database_is_not_replaced_by_install_sample(self):
        self.ini.write_text(
            f"[DB]\nsout_path={self.base / 'lost.mdb'}\n", encoding="utf-8")
        (self.install / "ARMv51.MDB").touch()
        self.assertFalse(self.detect()[0].databases)

    def test_folder_with_multiple_databases_requires_selection(self):
        (self.data / "Another.MDB").touch()
        self.ini.write_text(f"[DB]\nsout_path={self.data}\n", encoding="utf-8")
        result = self.detect()[0]
        self.assertEqual(len(result.databases), 2)
        self.assertTrue(any("несколько MDB" in t for t in result.warnings))

    def test_unverified_directory_does_not_count_as_original(self):
        stranger = self.base / "other"
        stranger.mkdir()
        (stranger / "options.ini").write_text("[DB]\nsout_path=fake.mdb\n")
        self.assertEqual(discover_installations((stranger,)), ())

    def test_fgis_ini_from_original_root_only(self):
        fgis = self.install / "fgis_ra.ini"
        fgis.touch()
        self.assertEqual(self.detect()[0].settings, (fgis,))

    def test_cp1251_options_supported(self):
        self.ini.write_bytes(f"[DB]\nsout_path={self.mdb}\n[main]\ncaption=Тест\n".encode("cp1251"))
        self.assertEqual(self.detect()[0].databases, (self.mdb,))

    def test_duplicate_root_is_deduplicated(self):
        self.assertEqual(len(discover_installations((self.install, self.install))), 1)


class ProtocolSelectionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.db = self.base / "test.mdb"
        self.db.touch()
        self.folder = self.base / "test_files" / "rm-guid"
        (self.folder / "xml").mkdir(parents=True)
        (self.folder / "a.docx").touch()
        (self.folder / "b.doc").touch()
        (self.folder / "xml" / "a.xml").write_text("<Document/>")
        (self.folder / "xml" / "b.xml").write_text("<Document/>")

    def run_with_rows(self, rows, rm_id=None):
        class FakeAccess:
            def __init__(self, path):
                self.path = path
            def __enter__(self):
                return self
            def __exit__(self, *args):
                pass
            def table_names(self):
                return frozenset({"SOUT_FACTORS"})
            def select(self, sql):
                if rm_id is not None:
                    assert f"rm_id={rm_id}" in sql
                return rows
        with patch("source_discovery.AccessReader", FakeAccess):
            return discover_protocols(self.db, rm_id=rm_id)

    def test_xml_list_comes_from_database_paths(self):
        rows = [
            {"rm_id": 1, "factor_id": 4, "file": r"rm-guid\a.docx"},
            {"rm_id": 1, "factor_id": 5, "file": r"rm-guid\b.doc"},
        ]
        result = self.run_with_rows(rows, rm_id=1)
        self.assertEqual(len(result), 2)
        self.assertEqual({x.xml.name for x in result}, {"a.xml", "b.xml"})

    def test_unsafe_or_missing_document_xml_not_suggested(self):
        rows = [
            {"rm_id": 1, "factor_id": 4, "file": r"..\foreign.docx"},
            {"rm_id": 1, "factor_id": 4, "file": r"rm-guid\missing.docx"},
        ]
        self.assertEqual(self.run_with_rows(rows), ())

    def test_missing_linked_files_directory_fails_explicitly(self):
        with self.assertRaises(FileNotFoundError):
            discover_protocols(self.base / "other.mdb")

    def test_invalid_workplace_identifier_fails(self):
        with self.assertRaises(ValueError):
            discover_protocols(self.db, rm_id=0)


if __name__ == "__main__":
    unittest.main()
