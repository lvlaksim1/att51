"""Persist user-selected source file paths in the application's own data folder.

No registry, roaming profile, external cache, or original ATT51 files are written.
The settings document contains paths only; never database contents.
"""
from __future__ import annotations

import json
import os
import re
from pathlib import Path
import sys
import tempfile

SOURCE_KEYS = ("mdb", "resources", "xml", "ini", "xml_dir", "docx_dir", "protocols_dir", "output_dir")
FORMAT_VERSION = 1
FILE_NAME = "source-paths.json"


def application_data_dir() -> Path:
    base = (Path(sys.executable).resolve().parent if getattr(sys, "frozen", False)
            else Path(__file__).resolve().parent)
    return base / "data"


class SourceSettings:
    def __init__(self, directory: Path | None = None):
        self.directory = (Path(directory) if directory is not None
                          else application_data_dir())
        self.path = self.directory / FILE_NAME

    def load(self) -> dict[str, str]:
        try:
            payload = json.loads(self.path.read_text(encoding="utf-8"))
        except FileNotFoundError:
            return {}
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            raise ValueError(f"Не удалось прочитать сохранённые пути: {exc}") from exc
        if not isinstance(payload, dict) or payload.get("version") != FORMAT_VERSION:
            raise ValueError("Неизвестный формат сохранённых путей.")
        sources = payload.get("sources")
        if not isinstance(sources, dict):
            raise ValueError("Неверная структура сохранённых путей.")
        return {key: value for key in SOURCE_KEYS
                if isinstance((value := sources.get(key)), str)
                and len(value) <= 4096 and "\x00" not in value}

    def save(self, paths: dict[str, str]) -> None:
        content = {
            "version": FORMAT_VERSION,
            "sources": {
                key: value for key in SOURCE_KEYS
                if isinstance((value := paths.get(key)), str)
                and value and len(value) <= 4096 and "\x00" not in value
            },
        }
        self.directory.mkdir(parents=True, exist_ok=True)
        temporary: Path | None = None
        try:
            with tempfile.NamedTemporaryFile(
                mode="w", encoding="utf-8", dir=self.directory,
                prefix=".source-paths-", suffix=".tmp", delete=False
            ) as stream:
                temporary = Path(stream.name)
                json.dump(content, stream, ensure_ascii=False, indent=2)
                stream.write("\n")
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, self.path)
        finally:
            if temporary is not None:
                temporary.unlink(missing_ok=True)

WINDOW_SIZES_FILE = "window-sizes.json"
WINDOW_KEYS = ("main", "objects")
_SIZE_PATTERN = re.compile(r"^[1-9][0-9]{1,3}x[1-9][0-9]{1,3}$")


class WindowSettings:
    """Persist window dimensions only; never window coordinates or transient state."""

    def __init__(self, directory: Path | None = None):
        self.directory = Path(directory) if directory is not None else application_data_dir()
        self.path = self.directory / WINDOW_SIZES_FILE

    def load(self) -> dict[str, str]:
        try:
            values = json.loads(self.path.read_text(encoding="utf-8"))
        except FileNotFoundError:
            return {}
        except (OSError, UnicodeError, json.JSONDecodeError, TypeError, ValueError):
            return {}
        if not isinstance(values, dict):
            return {}
        return {
            key: value for key in WINDOW_KEYS
            if isinstance((value := values.get(key)), str)
            and _SIZE_PATTERN.fullmatch(value)
            and int(value.split("x")[0]) >= 250
            and int(value.split("x")[1]) >= 150
        }

    def save(self, values: dict[str, str]) -> None:
        clean = {
            key: value for key in WINDOW_KEYS
            if isinstance((value := values.get(key)), str)
            and _SIZE_PATTERN.fullmatch(value)
            and int(value.split("x")[0]) >= 250
            and int(value.split("x")[1]) >= 150
        }
        self.directory.mkdir(parents=True, exist_ok=True)
        temporary: Path | None = None
        try:
            with tempfile.NamedTemporaryFile(
                mode="w", encoding="utf-8", dir=self.directory,
                prefix=".window-sizes-", suffix=".tmp", delete=False,
            ) as output:
                temporary = Path(output.name)
                json.dump(clean, output, ensure_ascii=False, indent=2)
                output.write("\n")
                output.flush()
                os.fsync(output.fileno())
            os.replace(temporary, self.path)
        finally:
            if temporary is not None:
                temporary.unlink(missing_ok=True)
