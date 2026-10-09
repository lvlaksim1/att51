"""Verified GitHub Releases updater; stores downloaded updates only under ProgramData/Att51_export."""
from __future__ import annotations
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import urllib.parse
import urllib.request

REPOSITORY = "lvlaksim1/att51"
LATEST_API = f"https://api.github.com/repos/{REPOSITORY}/releases/latest"
LATEST_WEB = f"https://github.com/{REPOSITORY}/releases/latest"
_TAG = re.compile(r"^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
_HASH = re.compile(r"^[0-9a-fA-F]{64}$")
_HOSTS = {"github.com", "release-assets.githubusercontent.com", "objects.githubusercontent.com"}


class UpdateError(RuntimeError):
    pass


@dataclass(frozen=True)
class Release:
    tag: str
    version: tuple[int, int, int]
    download_url: str
    sha256: str
    size: int
    verified: bool = True


def parse_version(tag: str) -> tuple[int, int, int]:
    m = _TAG.fullmatch(tag or "")
    if not m:
        raise UpdateError("Неверный номер выпуска GitHub.")
    return tuple(int(p) for p in m.groups())


def asset_name(tag: str) -> str:
    parse_version(tag)
    return f"Att51_export_Update_{tag}.exe"


def asset_url(tag: str) -> str:
    return f"https://github.com/{REPOSITORY}/releases/download/{tag}/{asset_name(tag)}"


def parse_release(data: dict) -> Release:
    tag = data.get("tag_name", "")
    version = parse_version(tag)
    found = [a for a in data.get("assets", []) if a.get("name") == asset_name(tag)]
    if len(found) != 1:
        raise UpdateError("Установщик обновления не найден в последнем выпуске.")
    item = found[0]
    url, size = item.get("browser_download_url", ""), item.get("size", 0)
    if url != asset_url(tag) or not isinstance(size, int) or size < 100_000:
        raise UpdateError("Некорректный адрес или размер установщика.")
    checksum = item.get("digest") or ""
    valid = checksum.startswith("sha256:") and bool(_HASH.fullmatch(checksum[7:]))
    return Release(tag, version, url, checksum[7:].lower() if valid else "", size, valid)


def _req(url: str) -> urllib.request.Request:
    return urllib.request.Request(url, headers={
        "User-Agent": "Att51_export/1.0",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    })


def fetch_latest(*, opener=urllib.request.urlopen) -> Release:
    try:
        with opener(_req(LATEST_API), timeout=12) as res:
            if res.status != 200:
                raise UpdateError(f"GitHub API: HTTP {res.status}")
            return parse_release(json.load(res))
    except (OSError, ValueError, KeyError, TypeError, UpdateError):
        # Same fallback strategy as MailRu Desktop; without an asset digest
        # it allows only opening the release page, NOT silent installation.
        try:
            with opener(_req(LATEST_WEB), timeout=12) as res:
                url = urllib.parse.urlsplit(res.geturl())
                prefix = f"/{REPOSITORY}/releases/tag/"
                if (url.scheme != "https" or url.hostname != "github.com"
                        or not url.path.startswith(prefix) or url.query or url.fragment):
                    raise UpdateError("Неверное перенаправление GitHub.")
                tag = url.path[len(prefix):]
                return Release(tag, parse_version(tag), asset_url(tag), "", 0, False)
        except (OSError, ValueError, UpdateError) as exc:
            raise UpdateError("Не удалось проверить выпуски через api.github.com и github.com.") from exc


def newer(info: Release, installed: str) -> bool:
    return info.version > parse_version("v" + installed)


def download_update(info: Release, install_dir: Path, *, opener=urllib.request.urlopen) -> Path:
    if not info.verified or not _HASH.fullmatch(info.sha256):
        raise UpdateError("Нет SHA-256 для автоматического обновления.")
    if info.download_url != asset_url(info.tag) or info.size < 100_000:
        raise UpdateError("Недопустимое обновление.")
    directory = Path(install_dir).resolve(strict=True)
    if directory.name.casefold() != "att51_export":
        raise UpdateError("Недопустимая папка установки.")
    updates = directory / "updates"
    updates.mkdir(parents=True, exist_ok=True)
    destination = updates / asset_name(info.tag)
    temporary = updates / (destination.name + ".download")
    sha = hashlib.sha256()
    received = 0
    try:
        with opener(_req(info.download_url), timeout=90) as response:
            final = urllib.parse.urlsplit(response.geturl())
            if final.scheme != "https" or final.hostname not in _HOSTS:
                raise UpdateError("Обновление получено не с доверенного адреса.")
            with temporary.open("wb") as output:
                while data := response.read(131072):
                    received += len(data)
                    if received > info.size:
                        raise UpdateError("Неверный размер обновления.")
                    sha.update(data)
                    output.write(data)
        if received != info.size or sha.hexdigest() != info.sha256:
            raise UpdateError("Не совпали размер или SHA-256 установщика.")
        with temporary.open("rb") as stream:
            if stream.read(2) != b"MZ":
                raise UpdateError("Загруженный файл не является приложением Windows.")
        os.replace(temporary, destination)
        return destination
    finally:
        temporary.unlink(missing_ok=True)



# The update process must exit before Inno Setup replaces Att51_export.exe.
# The detached Windows helper owns no installed application files.
SILENT_INSTALL_ARGS = (
    "/SILENT", "/SUPPRESSMSGBOXES", "/NORESTART",
    "/NOCANCEL", "/CLOSEAPPLICATIONS", "/RUNAFTERUPDATE=1",
)


def _ps_quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def build_install_launcher(installer: Path, updater_pid: int, app_pid: int = 0) -> str:
    """Wait for old app/updater to exit; show installer progress, no wizard."""
    if updater_pid <= 0 or app_pid < 0:
        raise UpdateError("Некорректный идентификатор процесса обновления.")
    if Path(installer).suffix.lower() != ".exe":
        raise UpdateError("Некорректный путь к установщику.")
    args = ", ".join(_ps_quote(x) for x in SILENT_INSTALL_ARGS)
    waiting = (app_pid, updater_pid) if app_pid else (updater_pid,)
    waits = "\n".join(
        f"Wait-Process -Id {pid} -ErrorAction SilentlyContinue" for pid in waiting
    )
    return (
        "$ErrorActionPreference = 'Stop'\n" + waits + "\n"
        + "try {\n"
        + f"  $installer = Start-Process -FilePath {_ps_quote(str(installer))} "
          f"-ArgumentList @({args}) -Wait -PassThru\n"
        + "  if ($installer.ExitCode -ne 0) { "
          "throw ('Установка не завершена. Код: ' + $installer.ExitCode) }\n"
        + "} catch {\n"
        + "  Add-Type -AssemblyName System.Windows.Forms\n"
        + "  [void][System.Windows.Forms.MessageBox]::Show("
          "('Не удалось обновить Att51_export: ' + $_.Exception.Message), "
          "'Att51_export', 'OK', 'Error')\n"
        + "  exit 1\n"
        + "}\n"
    )


def launch_install_after_exit(installer: Path, app_pid: int = 0, *,
                              popen=subprocess.Popen) -> None:
    """System PowerShell waits outside the installed EXE; no extra application."""
    import base64
    import sys
    if sys.platform != "win32":
        raise UpdateError("Автоматическая установка доступна только в Windows.")
    script = build_install_launcher(installer, os.getpid(), app_pid)
    encoded = base64.b64encode(script.encode("utf-16-le")).decode("ascii")
    flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
    popen(["powershell.exe", "-NoLogo", "-NoProfile", "-NonInteractive",
           "-WindowStyle", "Hidden", "-EncodedCommand", encoded],
          cwd=str(Path(installer).parent), close_fds=True, creationflags=flags)


def apply_update(tag: str, checksum: str, length: str,
                 app_pid: str = "0") -> None:
    import sys
    if not getattr(sys, "frozen", False):
        raise UpdateError("Обновление запускается только в установленной программе.")
    install_dir = Path(sys.executable).resolve().parent
    parse_version(tag)
    if not _HASH.fullmatch(checksum):
        raise UpdateError("Некорректная контрольная сумма.")
    try:
        size = int(length)
        original_pid = int(app_pid)
    except ValueError as exc:
        raise UpdateError("Некорректные параметры обновления.") from exc
    if original_pid < 0:
        raise UpdateError("Некорректный идентификатор приложения.")
    current = fetch_latest()
    if (not current.verified or current.tag != tag
            or current.sha256 != checksum.lower() or current.size != size):
        raise UpdateError("Выпуск GitHub изменился; проверьте обновления заново.")
    path = download_update(current, install_dir)
    launch_install_after_exit(path, original_pid)
