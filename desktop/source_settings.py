"""Persist user-selected source file paths in the application's own data folder.

No registry, roaming profile, external cache, or original ATT51 files are written.
The settings document contains paths only; never database contents.
"""
from __future__ import annotations

import json
import os
from pathlib import Path
import sys
import tempfile

SOURCE_KEYS = ("mdb", "resources", "xml", "ini")
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
