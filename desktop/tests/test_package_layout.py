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
                self.assertIn("PrivilegesRequired=lowest", code)
                self.assertNotIn("PrivilegesRequired=admin", code)
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

    def test_snapshot_directory_writable_for_unprivileged_user(self):
        for name in ("full.iss", "update.iss"):
            with self.subTest(installer=name):
                code = self.script(name)
                self.assertIn('[Dirs]', code)
                self.assertIn('Name: "{app}\\data"', code)
                self.assertNotIn('Permissions: users-modify', code)

    def test_inno_installer_detects_running_application_via_mutex(self):
        from install_guard import MUTEX_NAME
        for name in ("full.iss", "update.iss"):
            with self.subTest(name=name):
                setup = self.script(name)
                self.assertIn("AppMutex=" + MUTEX_NAME, setup)
                self.assertIn("CloseApplications=yes", setup)
                self.assertIn("RestartApplications=no", setup)

    def test_old_versions_detected_before_file_replacement(self):
        for name in ("full.iss", "update.iss"):
            with self.subTest(name=name):
                code = self.script(name)
                self.assertIn('function PrepareToInstall(var NeedsRestart: Boolean)', code)
                self.assertIn('tasklist /FI "IMAGENAME eq Att51_export.exe"', code)
                self.assertIn("LegacyAtt51ProcessRunning: Boolean;", code)
                self.assertNotIn("taskkill", code)

    def test_gui_holds_mutex_until_exiting(self):
        source = (DESKTOP / "app.py").read_text(encoding="utf-8")
        self.assertIn("with InstallationMutex():\n        root = tk.Tk()", source)
        self.assertIn("with InstallationMutex():\n            time.sleep(", source)

    def test_finish_page_has_checked_launch_in_both_installers(self):
        for name in ("full.iss", "update.iss"):
            code = self.script(name)
            self.assertIn("[Run]", code)
            post = code.split("[Run]", 1)[1]
            self.assertIn('Description: "Открыть Att51_export после завершения"', post)
            if name == "update.iss":
                self.assertIn("postinstall nowait; Check: LaunchAfterUpdate", post)
            else:
                self.assertIn("postinstall nowait skipifsilent", post)
            self.assertNotIn("unchecked", post)

    def test_unprivileged_setup_uses_current_user_shortcuts(self):
        code = self.script("full.iss")
        self.assertIn("{autoprograms}", code)
        self.assertIn("{autodesktop}", code)
        self.assertNotIn("runasoriginaluser", code)

    def test_automatic_update_does_not_elevate(self):
        source = (DESKTOP / "app.py").read_text(encoding="utf-8")
        update = source.split("    def _install_update(self):", 1)[1].split(
            "    def _pump(self):", 1)[0]
        self.assertIn("start_update_overlay(", update)
        self.assertIn("ready.is_file()", update)
        self.assertIn("self._save_sources()", update)
        self.assertNotIn("messagebox.askyesno(", update)
        self.assertIn("os.getpid()", update)
        self.assertIn('text="Обновить"', source)
        worker = (DESKTOP / "update_worker.cs").read_text(encoding="utf-8")
        updater = (DESKTOP / "updater.py").read_text(encoding="utf-8")
        self.assertIn("FormStartPosition.CenterScreen", worker)
        self.assertIn("install.progress", worker)
        self.assertIn("newapp.ready", worker)
        self.assertIn("SHA256.Create()", worker)
        self.assertIn("/VERYSILENT", worker)
        self.assertIn("Att51_updater_runner.exe", updater)
        self.assertNotIn("powershell.exe", updater.lower())
        self.assertNotIn("update_overlay.ps1", source)
        self.assertNotIn("powershell", update.lower())

    def test_update_preserves_existing_shortcuts(self):
        update = self.script("update.iss")
        full = self.script("full.iss")
        self.assertNotIn("[Icons]", update)
        self.assertNotIn("{autodesktop}", update)
        self.assertNotIn("desktopicon", update)
        self.assertIn('Name: "{autodesktop}\\Att51_export"', full)
        self.assertIn("LaunchAfterUpdate", update)
        self.assertIn("{param:RUNAFTERUPDATE|0}", update)
        self.assertIn("Flags: postinstall nowait; Check: LaunchAfterUpdate", update)

    def test_settings_are_restored_before_automatic_path_discovery(self):
        source = (DESKTOP / "app.py").read_text(encoding="utf-8")
        self.assertIn("self.source_settings.load()", source)
        self.assertIn("self.fields[key].set(path)", source)
        self.assertIn("self.fields[key].trace_add", source)
        self.assertIn("self.source_settings.save(", source)
        self.assertIn('root.protocol("WM_DELETE_WINDOW", self._close)', source)

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
        self.assertIn("Выгрузить XML", source)
        self.assertIn("Выгрузить Excel", source)
        self.assertIn("run_with_com(task)", source)

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
