from __future__ import annotations

import subprocess
import sys
from pathlib import Path

# Repository-specific owner override, 2026-10-09:
# The research collection extracted/ may track application resources of any
# extension and size. This does not supersede the hard 100 MiB GitHub blob
# upload limit, or restrictions on publishing personal/secret information.
# The canonical repo-factory rules remain unchanged for all other files.

MAX_TRACKED_FILE_BYTES = 5 * 1024 * 1024
FORBIDDEN_SUFFIXES = {".exe", ".msi", ".zip", ".7z", ".rar", ".dll", ".pdb"}
EXCEPTION_PREFIX = "extracted/"
KNOWN_SENSITIVE_PATHS = {
    "extracted/win/att_reg/att.reg",
}


def tracked_files(repository_root: Path) -> list[Path]:
    completed = subprocess.run(
        ["git", "ls-files", "-z"], cwd=repository_root, check=True, capture_output=True
    )
    return [
        repository_root / raw.decode("utf-8")
        for raw in completed.stdout.split(b"\0")
        if raw
    ]


def violations(repository_root: Path) -> list[str]:
    result: list[str] = []
    for path in tracked_files(repository_root):
        if not path.is_file():
            continue
        relative = path.relative_to(repository_root).as_posix()
        if relative in KNOWN_SENSITIVE_PATHS:
            result.append(f"{relative}: known potentially sensitive configuration")
            continue
        if relative.startswith(EXCEPTION_PREFIX):
            # Owner-authorized att51 investigation materials only.
            continue
        size = path.stat().st_size
        suffix = path.suffix.lower()
        if suffix in FORBIDDEN_SUFFIXES:
            result.append(f"{relative}: forbidden tracked binary/archive type {suffix}")
        if size > MAX_TRACKED_FILE_BYTES:
            result.append(
                f"{relative}: {size:,} bytes exceeds "
                f"{MAX_TRACKED_FILE_BYTES:,}-byte tracked-file limit"
            )
    return result


def main() -> int:
    repository_root = Path(__file__).resolve().parents[1]
    found = violations(repository_root)
    if found:
        print("Repository storage policy violations:", file=sys.stderr)
        for item in found:
            print(f" - {item}", file=sys.stderr)
        print("\nOutside extracted/, use current GitHub Releases for large files.", file=sys.stderr)
        return 1
    print("Repository storage policy OK (att51 extracted/ owner exception).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
