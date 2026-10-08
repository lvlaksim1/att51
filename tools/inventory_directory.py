#!/usr/bin/env python3
"""Create a deterministic file manifest from a LOCAL unpacked installation directory."""
import argparse
import hashlib
import json
from pathlib import Path

BLOCKED = {'.exe', '.msi', '.zip', '.7z', '.rar', '.dll', '.pdb'}
LIMIT = 5 * 1024 * 1024


def file_hash(path):
    digest = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def create_manifest(root):
    if not root.is_dir():
        raise SystemExit(f'No such directory: {root}')
    rows = []
    for path in sorted(root.rglob('*')):
        if not path.is_file() or path.is_symlink():
            continue
        n = path.stat().st_size
        rows.append({
            'path': path.relative_to(root).as_posix(),
            'bytes': n,
            'sha256': file_hash(path),
            'git_storage_policy_allows': n <= LIMIT and path.suffix.lower() not in BLOCKED,
        })
    return {'directory': str(root), 'files': rows, 'file_count': len(rows),
            'total_bytes': sum(row['bytes'] for row in rows)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    args = parser.parse_args()
    print(json.dumps(create_manifest(args.directory), ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
