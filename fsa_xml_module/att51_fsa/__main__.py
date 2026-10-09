"""Read-only diagnostics for the original ATT51 sources, without Word."""
import argparse
import json
from pathlib import Path
import sys

from .sources import AppSources, FsaSourceError
from .writer import validate_xml


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="ATT51 FGIS FSA research module")
    subs = p.add_subparsers(dest="operation", required=True)
    check = subs.add_parser("inspect", help="Inspect original MDB and sidecar XML, read-only")
    check.add_argument("--mdb", type=Path, required=True, help="Original workplace MDB file")
    check.add_argument("--resources", type=Path, required=True, help="Working res_orgs.mdb")
    check.add_argument("--files", type=Path, help="Working <database>_files directory")
    check.add_argument("--rm-id", type=int, action="append", help="Select one RM; repeat to select many")
    check.add_argument("--output", type=Path, help="Save JSON inspection report here")
    valid = subs.add_parser("validate", help="Check existing FSA XML against original XSD")
    valid.add_argument("--xml", type=Path, required=True)
    valid.add_argument("--xsd", type=Path, required=True)
    args = p.parse_args(argv)
    try:
        if args.operation == "inspect":
            result = AppSources(args.mdb, args.resources, documents_root=args.files).inspect(args.rm_id)
            content = json.dumps(result, ensure_ascii=False, indent=2)
            if args.output:
                args.output.write_text(content + "\n", encoding="utf-8")
                print(f"Inspection report: {args.output}")
            else:
                print(content)
            return 0
        if args.operation == "validate":
            ok, error = validate_xml(args.xml.read_bytes(), args.xsd)
            print("XML conforms to original XSD" if ok else f"XSD error: {error}")
            return 0 if ok else 2
    except (FsaSourceError, OSError, ValueError, RuntimeError) as exc:
        print(f"Source inspection error: {exc}", file=sys.stderr)
        return 2
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
