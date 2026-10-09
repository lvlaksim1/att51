"""Bounded, source-only inspection of the original ATT51 Word/VBA exporter.

Only emits selected procedure excerpts; never executes VBA, opens live MDB,
or publishes user data. Original file: extracted/app/Attestation51.dot.
"""
from __future__ import annotations

import re
from pathlib import Path

from oletools.olevba import VBA_Parser

ORIGINAL = Path("extracted/app/Attestation51.dot")
TARGETS = {"v52_exp_fgis_ra", "v52_exp_fgis_ra2025", "v5_org_options"}
TERMS = (
    "DataStatusId", "ProtocolStatusId", "DocCreationDate",
    "DocStartDate", "DocValidityDate", "ApplicationDate", "CustomerKindId",
    "FullNameObject", "TypeObjectId", "ResearchObject", "get_ResearchObjects2025",
    "fact_id = 13", "factor_id = 13", "facid = 13", "Case 13",
    "Case 14", "kut", "IsLab", "IsAnotherDoc",
)
def main() -> None:
    parser = VBA_Parser(str(ORIGINAL))
    found: set[str] = set()
    try:
        if not parser.detect_vba_macros():
            raise RuntimeError("No Word VBA macros detected")
        for _fn, _stream, fname, content in parser.extract_macros():
            name = Path(fname).stem.lower()
            if name not in TARGETS:
                continue
            found.add(name)
            lines = content.splitlines()
            print(f"MODULE {name} lines={len(lines)}")
            selected = set()
            for i, line in enumerate(lines):
                if any(term.casefold() in line.casefold() for term in TERMS):
                    selected.update(range(max(0, i-5), min(len(lines),i+9)))
            if name == "v52_exp_fgis_ra2025":
                target_procs = ("read_tyag_params_direct", "read_tyag_params_itog", "read_napr_params")
                for proc in target_procs:
                    found_start = None
                    for i, line in enumerate(lines):
                        if re.match(r"(?i)^\s*(?:(?:public|private)\s+)?Function\s+" + proc + r"\b", line):
                            found_start = i
                            break
                    if found_start is None:
                        print(f"PROCEDURE_NOT_FOUND {proc}")
                        continue
                    print(f"BEGIN_PROCEDURE {proc} line={found_start+1}")
                    limit = min(found_start + 280, len(lines))
                    for i in range(found_start, limit):
                        line = lines[i].rstrip()
                        print(f"PROC {proc} {i+1:5d} {line[:300]}")
                        if i>found_start and re.match(r"(?i)^\s*End Function\s*$", line):
                            break
                    print(f"END_PROCEDURE {proc}")
            # Avoid uncontrolled log size, and restrict to known module/terms.
            for i in sorted(selected)[:1300]:
                line = lines[i].rstrip()
                # Avoid dumping any literal paths, access tokens or personal values.
                if re.search(r"(?i)(password|passwd|token|secret|authorization|Bearer)\s*=", line):
                    line = "[redacted]"
                print(f"{i+1:5d} {line[:280]}")
        missing = TARGETS - found
        print(f"MODULES_FOUND={','.join(sorted(found))}; MISSING={','.join(sorted(missing))}")
        if "v52_exp_fgis_ra" not in found or "v52_exp_fgis_ra2025" not in found:
            raise RuntimeError("Required original exporter modules not found")
    finally:
        parser.close()

if __name__ == "__main__":
    main()
