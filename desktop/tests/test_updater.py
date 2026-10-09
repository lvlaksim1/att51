"""Offline tests of the independent Att51_export GitHub update mechanism."""
from __future__ import annotations
import hashlib
from io import BytesIO
import json
from pathlib import Path
import sys
from unittest.mock import patch
from tempfile import TemporaryDirectory
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from updater import (Release, UpdateError, asset_name, asset_url,
                     download_update, fetch_latest, newer, parse_release,
                     parse_version, build_install_launcher,
                     launch_install_after_exit, SILENT_INSTALL_ARGS)


class FakeReply(BytesIO):
    status = 200
    def __init__(self, content, url):
        super().__init__(content)
        self.url = url
    def geturl(self):
        return self.url


class UpdaterTests(unittest.TestCase):

    def test_updater_shows_progress_without_install_wizard(self):
        self.assertIn("/SILENT", SILENT_INSTALL_ARGS)
        self.assertNotIn("/VERYSILENT", SILENT_INSTALL_ARGS)
        self.assertIn("/SUPPRESSMSGBOXES", SILENT_INSTALL_ARGS)
        self.assertIn("/RUNAFTERUPDATE=1", SILENT_INSTALL_ARGS)
        script = build_install_launcher(
            Path("C:/ProgramData/Att51_export/updates/New O'Hara.exe"),
            updater_pid=4104, app_pid=4103)
        self.assertLess(script.index("Wait-Process -Id 4103"),
                        script.index("Wait-Process -Id 4104"))
        self.assertLess(script.index("Wait-Process -Id 4104"),
                        script.index("Start-Process"))
        self.assertIn("New O''Hara.exe", script)
        self.assertIn("$installer.WaitForExit()", script)
        self.assertNotIn("-Wait -PassThru", script)
        self.assertIn("ExitCode -ne 0", script)
        for invalid in (-1, 0):
            with self.assertRaises(UpdateError):
                build_install_launcher(Path("good.exe"), invalid)

    def test_power_shell_helper_waits_outside_running_att51(self):
        import base64
        seen = []
        def pretend(*args, **kwargs):
            seen.append((args, kwargs))
        with patch.object(sys, "platform", "win32"):
            launch_install_after_exit(Path("C:/Att51_export/updates/update.exe"),
                                      4103, popen=pretend)
        self.assertEqual(len(seen), 1)
        command = seen[0][0][0]
        self.assertEqual(command[0], "powershell.exe")
        self.assertIn("-EncodedCommand", command)
        self.assertIn("-WindowStyle", command)
        self.assertTrue(seen[0][1]["close_fds"])
        script = base64.b64decode(command[-1]).decode("utf-16-le")
        self.assertIn("Wait-Process -Id 4103", script)
        self.assertIn("RUNAFTERUPDATE=1", script)

    def test_independent_updater_is_visible_before_old_app_exits(self):
        from updater import start_update_overlay
        from unittest.mock import patch
        import types
        class Process:
            def poll(self): return None
        calls = []
        with TemporaryDirectory() as tmp:
            app = Path(tmp) / "Att51_export"
            app.mkdir()
            ps = app / "update_overlay.ps1"
            ps.write_text("# Test", encoding="utf-8")
            info = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"),
                           "f"*64, 200000, True)
            with patch.object(sys, "platform", "win32"), \
                 patch.object(sys, "frozen", True, create=True):
                process, marker_path = start_update_overlay(
                    info, app, ps, 1234,
                    popen=lambda *args, **kwargs: (
                        calls.append((args, kwargs)) or Process()))
            self.assertIsInstance(process, Process)
            self.assertEqual(marker_path.resolve(), (app / "updates" / "overlay.ready").resolve())
            self.assertEqual(calls[0][0][0][0], "powershell.exe")
            args = calls[0][0][0]
            self.assertIn("-STA", args)
            self.assertIn("-File", args)
            self.assertIn(str(ps.resolve()), args)
            self.assertIn("-ApplicationPid", args)
            self.assertNotIn("Att51_export.exe", args)

    def test_untrusted_metadata_cannot_start_overlay(self):
        from updater import start_update_overlay
        with TemporaryDirectory() as tmp:
            app = Path(tmp) / "Att51_export"
            app.mkdir()
            file = app / "test.ps1"
            file.write_text("test", encoding="utf-8")
            unverified = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"),
                                 "", 200000, False)
            with patch.object(sys, "platform", "win32"), \
                 patch.object(sys, "frozen", True, create=True):
                with self.assertRaises(UpdateError):
                    start_update_overlay(unverified, app, file, 123)

    def test_tag_numbers_and_comparison(self):
        self.assertTrue(newer(Release("v0.2.1", (0, 2, 1), "", "", 0),
                              "0.2.0"))
        self.assertFalse(newer(Release("v0.2.1", (0, 2, 1), "", "", 0),
                               "0.2.1"))
        for bad in ("0.1.0", "v0.1", "v0.1.0.0", "v0.01.0", "v1.2.3/evil"):
            with self.assertRaises(UpdateError):
                parse_version(bad)

    def test_exact_repo_and_asset_name(self):
        self.assertEqual(asset_name("v0.1.0"), "Att51_export_Update_v0.1.0.exe")
        self.assertEqual(asset_url("v0.1.0"),
                         "https://github.com/lvlaksim1/att51/releases/download/"
                         "v0.1.0/Att51_export_Update_v0.1.0.exe")

    def payload(self, digest="sha256:" + "a" * 64):
        return {
            "tag_name": "v0.2.0",
            "assets": [{
                "name": asset_name("v0.2.0"),
                "browser_download_url": asset_url("v0.2.0"),
                "digest": digest,
                "size": 130000,
            }],
        }

    def test_api_requires_exact_asset(self):
        with self.assertRaises(UpdateError):
            parse_release({"tag_name": "v0.2.0", "assets": []})
        forged = self.payload()
        forged["assets"][0]["browser_download_url"] = "https://example.com/evil.exe"
        with self.assertRaises(UpdateError):
            parse_release(forged)

    def test_missing_checksum_never_enables_automatic_install(self):
        item = parse_release(self.payload(""))
        self.assertFalse(item.verified)
        self.assertEqual(item.sha256, "")

    def test_verified_api(self):
        data = json.dumps(self.payload()).encode()
        def opener(req, timeout):
            self.assertIn("api.github.com", req.full_url)
            return FakeReply(data, req.full_url)
        latest = fetch_latest(opener=opener)
        self.assertEqual(latest.version, (0, 2, 0))
        self.assertTrue(latest.verified)

    def test_api_fallback_to_github_without_checksum(self):
        calls = []
        def opener(req, timeout):
            calls.append(req.full_url)
            if "api.github.com" in req.full_url:
                raise OSError("test API down")
            return FakeReply(b"", "https://github.com/lvlaksim1/att51/releases/tag/v0.9.0")
        latest = fetch_latest(opener=opener)
        self.assertEqual(latest.version, (0, 9, 0))
        self.assertFalse(latest.verified)
        self.assertEqual(len(calls), 2)

    def test_untrusted_fallback_redirect_rejected(self):
        def opener(req, timeout):
            if "api.github.com" in req.full_url:
                raise OSError("API blocked")
            return FakeReply(b"", "https://example.org/lvlaksim1/att51/releases/tag/v5.0.0")
        with self.assertRaises(UpdateError):
            fetch_latest(opener=opener)

    def test_verified_download_stays_in_att51_export(self):
        payload = b"MZ" + bytes(range(256)) * 450
        expected = hashlib.sha256(payload).hexdigest()
        release = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"),
                          expected, len(payload))
        def opener(req, timeout):
            return FakeReply(payload, req.full_url)
        with TemporaryDirectory() as tmp:
            folder = Path(tmp) / "Att51_export"
            folder.mkdir()
            final = download_update(release, folder, opener=opener)
            self.assertEqual(final.parent.resolve(), (folder / "updates").resolve())
            self.assertEqual(final.read_bytes(), payload)
            self.assertFalse(Path(str(final) + ".download").exists())

    def test_download_reports_actual_verified_byte_progress(self):
        payload = b"MZ" + b"x" * 140000
        digest = hashlib.sha256(payload).hexdigest()
        info = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"),
                       digest, len(payload))
        amounts = []
        with TemporaryDirectory() as tmp:
            base = Path(tmp) / "Att51_export"
            base.mkdir()
            result = download_update(
                info, base,
                opener=lambda req, timeout: FakeReply(payload, req.full_url),
                progress=lambda current, total: amounts.append((current, total)))
            self.assertEqual(result.read_bytes(), payload)
        self.assertTrue(amounts)
        self.assertEqual(amounts[-1], (len(payload), len(payload)))
        self.assertTrue(all(0 < pos <= total == len(payload)
                            for pos, total in amounts))

    def test_wrong_hash_fails_and_deletes_partial(self):
        payload = b"MZ" + b"x" * 140000
        release = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"),
                          "f" * 64, len(payload))
        with TemporaryDirectory() as tmp:
            folder = Path(tmp) / "Att51_export"
            folder.mkdir()
            with self.assertRaises(UpdateError):
                download_update(
                    release, folder,
                    opener=lambda req, timeout: FakeReply(payload, req.full_url))
            self.assertEqual(list((folder / "updates").iterdir()), [])

    def test_unverified_download_forbidden(self):
        info = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"), "", 130000, False)
        with self.assertRaises(UpdateError):
            download_update(info, Path("/irrelevant"))

    def test_wrong_install_directory_forbidden(self):
        info = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"), "b" * 64, 130000)
        with TemporaryDirectory() as folder:
            with self.assertRaises(UpdateError):
                download_update(info, Path(folder))

    def test_missing_mz_executable_rejected(self):
        data = b"Bad" + b"x" * 120000
        info = Release("v0.2.0", (0, 2, 0), asset_url("v0.2.0"),
                       hashlib.sha256(data).hexdigest(), len(data))
        with TemporaryDirectory() as tmp:
            folder = Path(tmp) / "Att51_export"
            folder.mkdir()
            with self.assertRaisesRegex(UpdateError, "Windows"):
                download_update(
                    info, folder, opener=lambda req, timeout: FakeReply(data, req.full_url))


if __name__ == "__main__":
    unittest.main()
