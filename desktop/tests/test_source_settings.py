"""Settings remain inside Att51_export, survive upgrade and save atomically."""
from __future__ import annotations

import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
from source_settings import SourceSettings, SOURCE_KEYS, application_data_dir


class SettingsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.install = Path(self.temporary.name) / "Att51_export"
        self.install.mkdir()
        self.directory = self.install / "data"
        self.settings = SourceSettings(self.directory)

    def test_no_config_until_path_is_chosen(self):
        self.assertEqual(self.settings.load(), {})
        self.assertFalse(self.directory.exists())

    def test_restore_unicode_unc_paths_and_clear_values(self):
        sample = {
            "mdb": r"Z:\ИЛ\Аттестация 5.1\ARMv51.MDB",
            "resources": r"C:\Program Files (x86)\Аттестация-5.1\res_orgs.mdb",
            "xml": r"\\server\lab\xml\Тяжесть.xml",
            "ini": "",
        }
        self.settings.save(sample)
        self.assertEqual(self.settings.load(), {k: v for k,v in sample.items() if v})
        self.assertEqual(json.loads(self.settings.path.read_text(encoding="utf-8"))["version"], 1)
        self.assertEqual(list(self.directory.glob("*.tmp")), [])
        self.settings.save({**sample, "mdb": ""})
        self.assertNotIn("mdb", self.settings.load())
        self.assertEqual(self.settings.load()["resources"], sample["resources"])

    def test_update_does_not_overwrite_saved_paths(self):
        self.settings.save({"mdb": r"Z:\Lab\active.MDB"})
        # Simulate updating executable files inside the same ProgramData directory.
        (self.install / "Att51_export.exe").write_bytes(b"v0.1.6")
        (self.install / "Att51_export.exe").write_bytes(b"v0.1.7")
        self.assertEqual(SourceSettings(self.directory).load()["mdb"],
                         r"Z:\Lab\active.MDB")

    def test_corrupt_config_returns_explicit_error(self):
        self.directory.mkdir()
        self.settings.path.write_text("{garbled", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "сохранённые пути"):
            self.settings.load()
        self.assertEqual(self.settings.path.read_text(encoding="utf-8"), "{garbled")

    def test_source_keys_whitelist_and_length_limit(self):
        sample = {"mdb": "Z:/database.MDB", "password": "very private",
                  "xml": "z" * 6000}
        self.settings.save(sample)
        self.assertEqual(self.settings.load(), {"mdb": "Z:/database.MDB"})
        persisted = self.settings.path.read_text(encoding="utf-8")
        self.assertNotIn("password", persisted)
        self.assertNotIn("very private", persisted)

    def test_frozen_settings_are_within_program_dir(self):
        with patch.object(sys, "frozen", True, create=True):
            with patch.object(sys, "executable", str(self.install / "Att51_export.exe")):
                self.assertEqual(application_data_dir().resolve(), self.directory.resolve())


if __name__ == "__main__":
    unittest.main()
