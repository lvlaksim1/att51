#!/usr/bin/env python3
"""Verify and materialize the exact ATT 5.1.1739 research installation tree.

Uses only Python's standard library. Never executes any content from the archive.
The local input is a 34-part ZIP payload checked against a pinned SHA-256.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import io
import shutil
import tempfile
import zipfile
from pathlib import Path, PurePosixPath

ARCHIVE_SHA256 = '6ea5f8db55883b39c8620bb2858fb09beff4ce325879c43eeb88295f20d8caed'
ARCHIVE_BYTES = 93_533_908
PART_BYTES = 2_764_800
PART_COUNT = 34
EXPECTED_FILES = 3614
EXPECTED_BYTES = 645_359_024
EXCLUDED = {'app/dop_info.ini', 'win/att_reg/att.reg'}


def sha256sum(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def restore_zip(parts_dir: Path, archive: Path) -> None:
    total = 0
    h = hashlib.sha256()
    with archive.open('wb') as out:
        for i in range(PART_COUNT):
            p = parts_dir / f'part_{i:03d}.bin'
            size = p.stat().st_size
            expected = PART_BYTES if i < PART_COUNT - 1 else ARCHIVE_BYTES - PART_BYTES * (PART_COUNT - 1)
            if size != expected:
                raise RuntimeError(f'Bad part size: {p}: {size} != {expected}')
            with p.open('rb') as f:
                while data := f.read(1024 * 1024):
                    out.write(data)
                    h.update(data)
                    total += len(data)
            print(f'Joined {i + 1}/{PART_COUNT}: {p.name}', flush=True)
    if total != ARCHIVE_BYTES or h.hexdigest() != ARCHIVE_SHA256:
        raise RuntimeError('ZIP transfer integrity check failed')
    print(f'ZIP verified: {total} bytes, SHA-256={h.hexdigest()}', flush=True)


def validate_path(name: str) -> PurePosixPath:
    p = PurePosixPath(name)
    if '\\' in name or p.is_absolute() or any(s in {'..', '.', ''} for s in p.parts):
        raise RuntimeError(f'Unsafe ZIP path: {name!r}')
    if p.parts[0] not in {'app', 'sys', 'win'} or len(p.parts) < 2:
        raise RuntimeError(f'Unrecognized installation path: {name!r}')
    return p


def verify_and_extract(archive: Path, root: Path, verify_only: bool) -> None:
    with zipfile.ZipFile(archive) as z:
        names = z.namelist()
        if len(names) != len(set(names)):
            raise RuntimeError('Duplicate ZIP paths')
        metadata_names = {'inventory.csv', 'extraction_report.json'}
        files = [name for name in names if name not in metadata_names]
        if len(files) != EXPECTED_FILES:
            raise RuntimeError(f'Unexpected file count: {len(files)} != {EXPECTED_FILES}')
        if not metadata_names.issubset(names):
            raise RuntimeError('Missing inventory or extraction report')
        rows = list(csv.DictReader(io.TextIOWrapper(z.open('inventory.csv'), encoding='utf-8-sig')))
        lookup = {row['output_path']: row for row in rows}
        if len(rows) != EXPECTED_FILES or len(lookup) != EXPECTED_FILES or set(lookup) != set(files):
            raise RuntimeError('ZIP contents differ from authoritative inventory')
        combined = 0
        written = 0
        excluded = 0
        for i, name in enumerate(files, 1):
            rel = validate_path(name)
            info = z.getinfo(name)
            row = lookup[name]
            if info.is_dir() or info.file_size != int(row['size']):
                raise RuntimeError(f'Size mismatch: {name}')
            publish = name not in EXCLUDED
            target = root / Path(*rel.parts)
            if publish and not verify_only:
                target.parent.mkdir(parents=True, exist_ok=True)
            digest = hashlib.sha256()
            with z.open(info, 'r') as inp:
                output = (target.open('wb') if publish and not verify_only else None)
                try:
                    while data := inp.read(1024 * 1024):
                        digest.update(data)
                        if output is not None:
                            output.write(data)
                finally:
                    if output is not None:
                        output.close()
            if digest.hexdigest() != row['sha256']:
                raise RuntimeError(f'SHA-256 mismatch: {name}')
            combined += info.file_size
            written += int(publish)
            excluded += int(not publish)
            if i % 250 == 0 or i == EXPECTED_FILES:
                print(f'Files verified: {i}/{EXPECTED_FILES}', flush=True)
        if combined != EXPECTED_BYTES or written != 3612 or excluded != 2:
            raise RuntimeError('Unexpected extraction totals')
        print(f'PASS: {EXPECTED_FILES} source files, {combined} bytes, {written} published, {excluded} omitted', flush=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--parts', type=Path, default=Path('extracted/.transfer'))
    parser.add_argument('--output', type=Path, default=Path('extracted'))
    parser.add_argument('--verify-only', action='store_true')
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='att51-transfer-') as d:
        archive = Path(d) / 'verified.zip'
        restore_zip(args.parts, archive)
        verify_and_extract(archive, args.output, args.verify_only)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())