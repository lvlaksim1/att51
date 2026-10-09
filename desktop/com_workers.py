"""Dedicated Windows COM apartment for background Access/Excel tasks."""
from __future__ import annotations


def run_with_com(task):
    """Each worker must initialise and release COM in the SAME thread."""
    if __import__("sys").platform != "win32":
        return task()
    import pythoncom
    pythoncom.CoInitialize()
    try:
        return task()
    finally:
        pythoncom.CoUninitialize()
