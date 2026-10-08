#!/usr/bin/env python3
"""Static signature inventory for a local ATT 5.1 unpacked payload stream.

Input is NOT executed and is never uploaded by this script. Magic hit counts
are not counts of actual files; formats can be nested and duplicated.
"""
import argparse
import hashlib
import json
import mmap
import struct
from pathlib import Path

SIGNATURES = {
    "ole_compound": bytes.fromhex("d0cf11e0a1b11ae1"),
    "zip_local_header": b"PK\x03\x04",
    "png": bytes.fromhex("89504e470d0a1a0a"),
    "gif89a": b"GIF89a",
    "jpeg_jfif": bytes.fromhex("ffd8ffe0"),
    "xml_decl": b"<?xml",
}


def positions(data, needle):
    start = 0
    while (pos := data.find(needle, start)) != -1:
        yield pos
        start = pos + 1


def inspect_pe(data, pos):
    """Validate PE32 at offset and return its section-backed disk extent."""
    end = len(data)
    try:
        if pos + 0x40 > end or data[pos:pos + 2] != b"MZ":
            return None
        pe_offset = struct.unpack_from("<I", data, pos + 0x3c)[0]
        if not 0x40 <= pe_offset <= 0x1000:
            return None
        header = pos + pe_offset
        if header + 24 > end or data[header:header + 4] != b"PE\0\0":
            return None
        machine, num_sections = struct.unpack_from("<HH", data, header + 4)
        optional_size = struct.unpack_from("<H", data, header + 20)[0]
        optional = header + 24
        magic = struct.unpack_from("<H", data, optional)[0]
        if machine != 0x14c or magic != 0x10b or not 1 <= num_sections <= 32:
            return None
        section_table = optional + optional_size
        if section_table + 40 * num_sections > end:
            return None
        extent = section_table + 40 * num_sections - pos
        for n in range(num_sections):
            section = section_table + 40 * n
            raw_size, raw_offset = struct.unpack_from("<II", data, section + 16)
            extent = max(extent, raw_offset + raw_size)
        if extent > 128 * 1024 * 1024 or pos + extent > end:
            return None
        return {"offset": pos, "machine": "i386", "format": "PE32", "disk_extent": extent}
    except (IndexError, ValueError, struct.error):
        return None


def scan(path, limit):
    with path.open("rb") as f:
        with mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ) as data:
            signatures = {}
            for name, needle in SIGNATURES.items():
                hits = list(positions(data, needle))
                signatures[name] = {"count": len(hits), "first_offsets": hits[:limit]}
            pe = []
            for p in positions(data, b"MZ\x90\x00"):
                entry = inspect_pe(data, p)
                if entry:
                    pe.append(entry)
            return {"file_size": path.stat().st_size,
                    "signature_counts_are_not_file_counts": True,
                    "signatures": signatures, "valid_pe32": pe}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("payload", type=Path, help="Path to local unpacked solid data")
    p.add_argument("--first-offsets", type=int, default=12)
    p.add_argument("--carve-pe", type=Path, help="Optional local output folder for PE component copies")
    args = p.parse_args()
    report = scan(args.payload, max(0, args.first_offsets))
    if args.carve_pe:
        args.carve_pe.mkdir(parents=True, exist_ok=True)
        with args.payload.open("rb") as f:
            for pe in report["valid_pe32"]:
                f.seek(pe["offset"])
                content = f.read(pe["disk_extent"])
                dst = args.carve_pe / ("pe_at_%012d.exe" % pe["offset"])
                dst.write_bytes(content)
                pe["local_carved_file"] = str(dst)
                pe["sha256"] = hashlib.sha256(content).hexdigest()
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
