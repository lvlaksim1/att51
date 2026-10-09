"""Bounded, source-only inspection of the original ATT51 Word/VBA exporter.

Only emits selected procedure excerpts; never executes VBA, opens live MDB,
or publishes user data. Original file: extracted/app/Attestation51.dot.
"""
from __future__ import annotations

import re
from pathlib import Path

from oletools.olevba import VBA_Parser

ORIGINAL = Path("extracted/app/Attestation51.dot")
TARGETS = {"v52_exp_fgis_ra", "v52_exp_fgis_ra2025", "v5_org_options", "v5_res_main", "v5_options_dic"}
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
                target_procs = ("read_tyag_params_direct", "read_tyag_params_itog", "read_napr_params", "read_fact_coll")
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
                    limit = min(found_start + 500, len(lines))
                    for i in range(found_start, limit):
                        line = lines[i].rstrip()
                        print(f"PROC {proc} {i+1:5d} {line[:300]}")
                        if i>found_start and re.match(r"(?i)^\s*End Function\s*$", line):
                            break
                    print(f"END_PROCEDURE {proc}")
            if name == "v52_exp_fgis_ra":
                # These are the original field provenance and date functions.
                for start, stop in ((4273, 4347), (3520, 3542), (2430, 2514)):
                    print(f"BEGIN_ORIGINAL_RANGE {start}-{stop}")
                    for i in range(start-1, min(stop, len(lines))):
                        print(f"RANGE {i+1:5d} {lines[i][:290]}")
                    print("END_ORIGINAL_RANGE")
            if name == "v52_exp_fgis_ra":
                for proc in ("get_PERS_data", "get_ApprovedUser", "get_PERS_info"):
                    start = next((i for i, line in enumerate(lines)
                        if re.match(r"(?i)^\s*(?:(?:public|private)\s+)?Function\s+"
                                    + proc + r"\b", line)), None)
                    if start is None:
                        continue
                    print(f"BEGIN_ROLE_FUNCTION {proc}")
                    for i in range(start, min(start + 250, len(lines))):
                        print(f"ROLE {proc} {i+1:5d} {lines[i][:290]}")
                        if i > start and re.match(r"(?i)^\s*End Function\s*$", lines[i]):
                            break
                    print(f"END_ROLE_FUNCTION {proc}")
                for start, stop in ((3770, 3832), (1740, 1830)):
                    print(f"BEGIN_ROLE_RANGE {start}-{stop}")
                    for i in range(start-1, min(stop,len(lines))):
                        print(f"ROLE_RANGE {i+1:5d} {lines[i][:290]}")
                    print("END_ROLE_RANGE")
            if name in ("v5_res_main", "v5_options_dic", "v5_org_options"):
                # Investigate the provenance of person FGIS positions,
                # normative matching and application date without exposing
                # unrelated original VBA procedures.
                specific = ("fgis_state", "fil_pers_data", "read_fgis_ra_data",
                            "get_nd_by_name", "query_date", "ATT_PERSON",
                            "get_DocNameId", "DIC_ND")
                chosen = set()
                for i, line in enumerate(lines):
                    if any(term.casefold() in line.casefold() for term in specific):
                        chosen.update(range(max(i-4,0),min(i+8,len(lines))))
                for i in sorted(chosen)[:900]:
                    line = lines[i].rstrip()
                    if re.search(r"(?i)(password|passwd|token|secret|authorization|Bearer)\\s*=", line):
                        line = "[redacted]"
                    print(f"PROVENANCE {name} {i+1:5d} {line[:290]}")
            if name == "v5_res_main":
                for start, stop in ((1857, 1895), (2336, 2390)):
                    for i in range(start-1, min(stop,len(lines))):
                        print(f"PROBE {name} {i+1:5d} {lines[i][:300]}")
            if name == "v5_org_options":
                for start, stop in ((1995, 2075), (2500, 2570)):
                    for i in range(start-1, min(stop,len(lines))):
                        print(f"PROBE {name} {i+1:5d} {lines[i][:300]}")
            if name == "v52_exp_fgis_ra":
                keys = ("fgis_state", "pers_info", "is_boss_exp", "get_fgis_pers_id")
                for i, line in enumerate(lines):
                    if any(key in line.casefold() for key in keys):
                        print(f"PERSON_SRC {i+1:5d} " +
                              " | ".join(lines[max(0,i-2):min(len(lines),i+3)])[:700])
            # One-time follow-up: exact legacy factor3 chemical/aerosol path,
            # original factor labels, and methodology selection. Source code
            # only, no user MDB / personal information.
            if name == "v52_exp_fgis_ra2025":
                for proc in ("read_him_params", "read_him_params_SS", "read_him_params_MAX", "get_him_id_by_bm", "format_him_ra", "get_DocNameId", "get_DocNameId_Helper"):
                    start = next((i for i, line in enumerate(lines)
                        if re.match(r"(?i)^\s*(?:(?:public|private)\s+)?Function\s+"
                                    + proc + r"\b", line)), None)
                    if start is not None:
                        print(f"FACTOR_METHOD_BEGIN {proc} {start+1}")
                        for i in range(start, min(start+700, len(lines))):
                            print(f"FACTOR_METHOD {proc} {i+1:5d} {lines[i][:310]}")
                            if i>start and re.match(r"(?i)^\s*End Function\s*$",lines[i]):
                                break
                        print(f"FACTOR_METHOD_END {proc}")
            if name == "v52_exp_fgis_ra":
                for start,stop in ((4451,4499),(3830,3863)):
                    for i in range(start-1,min(stop,len(lines))):
                        print(f"FACTOR_NAME {i+1:5d} {lines[i][:310]}")
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
