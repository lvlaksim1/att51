"""Access lock recovery: source MDB is never altered or copied back."""
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
from types import ModuleType
import unittest
from unittest.mock import patch

from att51_fsa.sources import AccessReader, FsaSourceError


class Connection:
    def __init__(self, source, fail_local=False):
        self.source = source
        self.Mode = None
        self.closed = False
        self.fail_local = fail_local

    def Open(self, connection_string):
        # Jet/ACE direct open is blocked by a simulated SMB lock restriction.
        if str(self.source) in connection_string:
            raise OSError("Microsoft Access Database Engine: Блокировка файла невозможна")
        if self.fail_local:
            raise OSError("Снимок повреждён")

    def Close(self):
        self.closed = True


class FakeClient:
    def __init__(self, source, fail_local=False):
        self.source = source
        self.fail_local = fail_local
        self.paths = []
        self.connections = []

    def Dispatch(self, name):
        self.paths.append(name)
        c = Connection(self.source, self.fail_local)
        self.connections.append(c)
        return c


class AccessLockRecoveryTests(unittest.TestCase):
    def setUp(self):
        self.folder = TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        self.original = self.root / "work.mdb"
        self.original.write_bytes(b"MDB SYNTHETIC UNIT TEST")
        self.snapshot_root = self.root / "Att51_export" / "data"

    def _com_modules(self, client):
        parent = ModuleType("win32com")
        sub = ModuleType("win32com.client")
        sub.Dispatch = client.Dispatch
        parent.client = sub
        return {"win32com": parent, "win32com.client": sub}

    def test_locked_original_uses_app_local_copy_and_cleans_it(self):
        client = FakeClient(self.original)
        saved = self.original.read_bytes()
        with patch.dict(sys.modules, self._com_modules(client)):
            with AccessReader(self.original, snapshot_root=self.snapshot_root) as reader:
                self.assertTrue(reader.used_snapshot)
                self.assertIn(reader.provider, AccessReader.PROVIDERS)
                self.assertEqual(reader._connection.Mode, 17)
                copies = list(self.snapshot_root.rglob("*.mdb"))
                self.assertEqual(len(copies), 1)
                self.assertEqual(copies[0].read_bytes(), saved)
        self.assertEqual(self.original.read_bytes(), saved)
        self.assertFalse(list(self.snapshot_root.rglob("*.mdb")))

    def test_network_path_never_tries_to_open_live_database(self):
        client = FakeClient(self.original)
        attempts = []
        original_open = AccessReader._open

        def trace_open(reader, path, dispatcher):
            attempts.append(path)
            return original_open(reader, path, dispatcher)

        with (patch.dict(sys.modules, self._com_modules(client)),
            patch.object(AccessReader, "_is_network_path", return_value=True),
            patch.object(AccessReader, "_open", trace_open)
        ):
            with AccessReader(self.original, snapshot_root=self.snapshot_root) as reader:
                self.assertTrue(reader.used_snapshot)
        self.assertEqual(len(attempts), 1)
        self.assertNotEqual(attempts[0], self.original)
        self.assertEqual(self.original.read_bytes(), b"MDB SYNTHETIC UNIT TEST")

    def test_failed_snapshot_leaves_source_intact_and_removes_copy(self):
        client = FakeClient(self.original, fail_local=True)
        with patch.dict(sys.modules, self._com_modules(client)):
            with self.assertRaisesRegex(FsaSourceError, "временную копию"):
                with AccessReader(self.original, snapshot_root=self.snapshot_root):
                    pass
        self.assertFalse(list(self.snapshot_root.rglob("*.mdb")))
        self.assertEqual(self.original.read_bytes(), b"MDB SYNTHETIC UNIT TEST")

    def test_source_change_during_copy_is_not_trusted(self):
        import shutil
        client = FakeClient(self.original)
        copy = shutil.copyfile

        def changed_during_copy(src, dst):
            result = copy(src, dst)
            Path(src).write_bytes(b"CHANGED WHILE COPYING")
            return result

        with (patch.dict(sys.modules, self._com_modules(client)),
            patch("att51_fsa.sources.shutil.copyfile", changed_during_copy)
        ):
            with self.assertRaisesRegex(FsaSourceError, "изменялась"):
                with AccessReader(self.original, snapshot_root=self.snapshot_root):
                    pass
        self.assertFalse(list(self.snapshot_root.rglob("*.mdb")))


if __name__ == "__main__":
    unittest.main()
