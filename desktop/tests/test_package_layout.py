"""Static regression tests for Windows install contract (no real user files)."""
from pathlib import Path
import ast
import re
import sys
import tempfile
import unittest

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))


class InstallationContractTests(unittest.TestCase):
    def script(self, name):
        return (DESKTOP / "installer" / name).read_text(encoding="utf-8")

    def test_both_installers_target_programdata(self):
        for name in ("full.iss", "update.iss"):
            with self.subTest(installer=name):
                code = self.script(name)
                self.assertIn(r"DefaultDirName={commonappdata}\Att51_export", code)
                self.assertNotIn("{autopf}", code)
                self.assertNotIn("{localappdata}", code)
                self.assertIn("PrivilegesRequired=admin", code)
                self.assertIn("UninstallDisplayIcon={app}", code)

    def test_full_installer_offers_optional_desktop_icon(self):
        code = self.script("full.iss")
        self.assertIn('Name: "desktopicon"', code)
        self.assertIn("Flags: unchecked", code)
        self.assertIn("{autodesktop}", code)
        self.assertIn('Tasks: desktopicon', code)

    def test_update_refuses_uninstalled_machine(self):
        code = self.script("update.iss")
        self.assertIn("InitializeSetup()", code)
        self.assertIn("FileExists(InstalledExe)", code)
        self.assertIn(r"{commonappdata}\Att51_export\Att51_export.exe", code)

    def test_uninstaller_cleans_own_directories(self):
        for name in ("full.iss", "update.iss"):
            code = self.script(name)
            self.assertIn("[UninstallDelete]", code)
            self.assertIn(r'Name: "{app}\updates"', code)
            self.assertIn(r'Name: "{app}\data"', code)
            self.assertIn(r'Name: "{app}\reports"', code)

    def test_generator_renders_export_not_xml_word(self):
        source = (DESKTOP / "build_icon.py").read_text(encoding="utf-8")
        self.assertIn('"EXPORT"', source)
        self.assertNotIn('d.text((230, 694), "XML"', source)

    def test_app_never_persists_settings_or_logs_elsewhere(self):
        source = (DESKTOP / "app.py").read_text(encoding="utf-8")
        self.assertNotIn("LocalApplicationData", source)
        self.assertNotIn("AppData", source)
        self.assertNotIn("tempfile", source)
        self.assertIn("not_exportable", source)

    def test_build_uses_onedir_not_volatile_singlefile_extract(self):
        build = (DESKTOP / "build.ps1").read_text(encoding="utf-8")
        self.assertIn("'--onedir'", build)
        self.assertNotIn("'--onefile'", build)
        self.assertIn("desktop\\build", build)

    def test_install_contract_has_no_programfiles_target(self):
        full = self.script("full.iss")
        update = self.script("update.iss")
        self.assertNotIn("Program Files", full)
        self.assertNotIn("Program Files", update)


if __name__ == "__main__":
    unittest.main()
