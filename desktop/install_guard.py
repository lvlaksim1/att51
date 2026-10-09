"""Make the Windows installer detect an open Att51_export before file replacement.

The mutex name must match both Inno Setup AppMutex directives. Its handle is
held for the whole GUI lifetime, and is not held by background update helpers.
"""
from __future__ import annotations

import ctypes
import os

MUTEX_NAME = "Att51_export_4C39F0DF_C81F_48A7_AC82_6B29E916E7C1"


class InstallationMutex:
    def __init__(self):
        self._handle = None
        self._kernel = None

    def __enter__(self):
        if os.name == "nt":
            import ctypes.wintypes
            kernel = ctypes.WinDLL("kernel32", use_last_error=True)
            create = kernel.CreateMutexW
            create.argtypes = (ctypes.c_void_p, ctypes.wintypes.BOOL,
                               ctypes.c_wchar_p)
            create.restype = ctypes.wintypes.HANDLE
            handle = create(None, False, MUTEX_NAME)
            if not handle:
                raise OSError(ctypes.get_last_error(), "Cannot create installer mutex")
            self._kernel, self._handle = kernel, handle
        return self

    def __exit__(self, *_args):
        if self._handle is not None:
            close = self._kernel.CloseHandle
            close.argtypes = (ctypes.wintypes.HANDLE,)
            close.restype = ctypes.wintypes.BOOL
            close(self._handle)
            self._handle = None
            self._kernel = None
