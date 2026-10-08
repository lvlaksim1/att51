#!/usr/bin/env python3
"""Exact ATT51 Inno Setup 5.3.10 extraction without executing Windows code.

Reads Inno Setup metadata blocks and the solid LZMA1 payload; reverses
Inno's 5.3.9+ x86 call-address filter; validates original SHA-1 per file.
The output never leaves the local filesystem. No third-party Python packages.

Scope: *this* installer format, not a generic replacement for innoextract.
"""
import argparse
import collections
import csv
import datetime as dt
import hashlib
import json
import lzma
import re
import struct
import tempfile
import zlib
from pathlib import Path

MAGIC = b"Inno Setup Setup Data (5.3.10)"
CHUNK_MAGIC = b"zlb\x1a"
RECORD_LENGTH = 74


def read_block(f):
    header = f.read(9)
    assert len(header) == 9, "Setup block header truncated"
    crc, total = struct.unpack_from("<II", header)
    assert crc == zlib.crc32(header[4:]), "Setup block header CRC mismatch"
    assert header[8] == 1, "Unsupported non-LZMA setup header"
    packed = bytearray()
    left = total
    while left:
        n = min(4096, left - 4)
        recorded = struct.unpack("<I", f.read(4))[0]
        chunk = f.read(n)
        assert len(chunk) == n and zlib.crc32(chunk) == recorded, "Setup block CRC mismatch"
        packed.extend(chunk)
        left -= 4 + n
    return decompress_raw_lzma(bytes(packed))


def lzma_params(prop, dictionary):
    assert prop <= 224 and dictionary > 0
    return [{"id": lzma.FILTER_LZMA1, "dict_size": dictionary,
             "lc": prop % 9, "lp": (prop // 9) % 5, "pb": prop // 45}]


def decompress_raw_lzma(raw):
    assert len(raw) >= 5
    dictionary = struct.unpack_from("<I", raw, 1)[0]
    d = lzma.LZMADecompressor(format=lzma.FORMAT_RAW,
                              filters=lzma_params(raw[0], dictionary))
    result = d.decompress(raw[5:])
    assert d.eof, "LZMA stream incomplete"
    return result


def encoded_string(data, pos):
    assert pos + 4 <= len(data)
    n = struct.unpack_from("<I", data, pos)[0]
    assert n < 1_000_000 and pos + 4 + n <= len(data)
    return data[pos+4:pos+4+n].decode("cp1251"), pos + 4 + n


def parse_directories(b, first, count):
    out = []
    for _ in range(count):
        name, p = encoded_string(b, first)
        conditions = []
        for _ in range(6):
            v, p = encoded_string(b, p)
            conditions.append(v)
        attributes = struct.unpack_from("<I", b, p)[0]
        p += 4 + 20
        permission = struct.unpack_from("<h", b, p)[0]
        p += 2
        flags = b[p]
        p += 1
        out.append({"path": name, "attributes": attributes,
                    "permission": permission, "flags": flags,
                    "conditions": conditions})
        first = p
    return out, p


def parse_files(b, first, count):
    out = []
    p = first
    for index in range(count):
        source, p = encoded_string(b, p)
        destination, p = encoded_string(b, p)
        font, p = encoded_string(b, p)
        strong_assembly, p = encoded_string(b, p)
        conditions = []
        for _ in range(6):
            s, p = encoded_string(b, p)
            conditions.append(s)
        p += 20   # Windows version range
        location, attributes, external_size = struct.unpack_from("<IIQ", b, p)
        p += 16
        permission = struct.unpack_from("<h", b, p)[0]
        p += 2
        flags = struct.unpack_from("<I", b, p)[0]
        p += 4
        file_type = b[p]
        p += 1
        assert destination.startswith("{") and file_type == 0
        out.append({"index": index, "destination": destination,
                    "source": source, "font": font,
                    "strong_assembly": strong_assembly,
                    "conditions": conditions, "location": location,
                    "attributes": attributes, "external_size": external_size,
                    "permission": permission, "flags": flags,
                    "type": file_type})
    return out, p


def parse_data_entries(b):
    assert len(b) % RECORD_LENGTH == 0
    entries = []
    for i in range(len(b) // RECORD_LENGTH):
        d = b[i * RECORD_LENGTH:(i + 1) * RECORD_LENGTH]
        first_slice, last_slice, chunk_offset = struct.unpack_from("<III", d)
        file_offset, size, chunk_size = struct.unpack_from("<QQQ", d, 12)
        time = struct.unpack_from("<q", d, 56)[0]
        flags = struct.unpack_from("<H", d, 72)[0]
        assert first_slice == last_slice == chunk_offset == 0
        entries.append({"index": i, "offset": file_offset, "size": size,
                        "chunk_size": chunk_size, "sha1": d[36:56].hex(),
                        "filetime": time, "flags": flags})
    return entries


def undo_inno_x86_filter(source):
    out = bytearray(source)
    pos = 0
    length = len(out)
    while pos < length:
        if (out[pos] in (0xe8, 0xe9)
                and 65536 - pos % 65536 >= 5 and pos + 5 <= length):
            a = pos + 1
            if out[a+3] in (0x00, 0xff):
                target = out[a] | out[a+1] << 8 | out[a+2] << 16
                relative = (target - (pos + 5)) & 0xffffff
                out[a] = relative & 255
                out[a+1] = (relative >> 8) & 255
                out[a+2] = (relative >> 16) & 255
                if relative & 0x800000:
                    out[a+3] ^= 0xff
            pos += 5
        else:
            pos += 1
    return bytes(out)


def safe_target(destination):
    m = re.fullmatch(r"\{(app|sys|win)\}\\(.+)", destination, re.I)
    if not m:
        raise ValueError("Unexpected Inno destination: " + destination)
    parts = m[2].split("\\")
    if any(p in ("", ".", "..") or "/" in p or ":" in p for p in parts):
        raise ValueError("Unsafe relative path: " + destination)
    return Path(m[1].lower(), *parts)


def extract_solid(exe, position, end, destination):
    with exe.open("rb") as f, destination.open("wb") as out:
        f.seek(position)
        assert f.read(4) == CHUNK_MAGIC
        props = f.read(5)
        dec = lzma.LZMADecompressor(
            format=lzma.FORMAT_RAW,
            filters=lzma_params(props[0], struct.unpack("<I", props[1:])[0]))
        total = 0
        while not dec.eof and f.tell() < end:
            block = f.read(min(1024 * 1024, end - f.tell()))
            if not block:
                break
            decoded = dec.decompress(block)
            total += len(decoded)
            out.write(decoded)
        assert dec.eof, "Solid LZMA payload was not fully decompressed"
        return total


def run(exe, target, metadata_only=False):
    exe = Path(exe)
    b = exe.read_bytes()
    setup_header_pos = b.rfind(MAGIC)
    assert setup_header_pos >= 0 and setup_header_pos > 100000
    chunk_pos = b.find(CHUNK_MAGIC, 40000)
    assert chunk_pos >= 0 and chunk_pos < setup_header_pos
    del b
    with exe.open("rb") as f:
        f.seek(setup_header_pos + 64)
        h0 = read_block(f)
        h1 = read_block(f)
    data = parse_data_entries(h1)
    assert len(data) == 3614, "This script expects the verified ATT51 5.1.1739 layout"
    # The first file destination is preceded by a 4-byte empty source field
    # and a 4-byte destination length field.
    first_name = b"{app}\\aeroion_prg_sout.dot"
    first_file = h0.index(first_name) - 8
    files, last = parse_files(h0, first_file, len(data))
    assert last < len(h0)
    assert [f["location"] for f in files] == list(range(len(data)))
    dirs_first = h0.index(b"{commonappdata}\\attest5\\5.1") - 4
    directories, _ = parse_directories(h0, dirs_first, 2)
    expected_length = max(x["offset"] + x["size"] for x in data)
    assert expected_length == sum(x["size"] for x in data)
    target = Path(target)
    target.mkdir(parents=True, exist_ok=True)
    rows = []
    seen = set()
    with tempfile.TemporaryDirectory(prefix="att51_solid_") as temp:
        solid = Path(temp) / "solid.bin"
        total = extract_solid(exe, chunk_pos, setup_header_pos, solid)
        assert total == expected_length
        with solid.open("rb") as inp:
            for index, entry in enumerate(files):
                info = data[entry["location"]]
                rel = safe_target(entry["destination"])
                normalized = str(rel).casefold()
                assert normalized not in seen, "Duplicate file destination"
                seen.add(normalized)
                inp.seek(info["offset"])
                content = inp.read(info["size"])
                if info["flags"] & 16:
                    content = undo_inno_x86_filter(content)
                sha1 = hashlib.sha1(content).hexdigest()
                assert sha1 == info["sha1"], f"SHA1 mismatch: {entry['destination']}"
                sha256 = hashlib.sha256(content).hexdigest()
                if not metadata_only:
                    dest = target / rel
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    dest.write_bytes(content)
                filetime = dt.datetime(1601, 1, 1, tzinfo=dt.timezone.utc) + dt.timedelta(microseconds=info["filetime"] // 10)
                rows.append({"index": index, "inno_destination": entry["destination"],
                             "output_path": rel.as_posix(), "size": info["size"],
                             "solid_offset": info["offset"], "sha1": sha1, "sha256": sha256,
                             "modified_utc": filetime.isoformat(),
                             "file_flags": entry["flags"], "storage_flags": info["flags"]})
    report = {"installer": exe.name, "source_sha256": hashlib.sha256(exe.read_bytes()).hexdigest(),
              "inno_version": "5.3.10", "files": len(rows), "total_bytes": expected_length,
              "sha1_verified": len(rows), "reversed_instruction_filters": sum(x["storage_flags"] & 16 != 0 for x in rows),
              "registered_directories": [x["path"] for x in directories],
              "layout": "app/ maps to {app}; sys/ to {sys}; win/ to {win}",
              "metadata_only": metadata_only}
    with (target / "inventory.csv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    (target / "extraction_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("installer", type=Path)
    ap.add_argument("destination", type=Path)
    ap.add_argument("--metadata-only", action="store_true")
    args = ap.parse_args()
    run(args.installer, args.destination, args.metadata_only)


if __name__ == "__main__":
    main()
