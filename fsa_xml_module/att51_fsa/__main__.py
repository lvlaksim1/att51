"""Read-only diagnostics for the original ATT51 sources, without Word."""
import argparse
import json
from pathlib import Path
import sys

from .sources import AppSources, FsaSourceError
from .selection import select_individual, select_consolidated, selections_to_dict
from .measurements import NoiseOptions, extract_noise_from_file
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
    individual = subs.add_parser("select-individual", help="Read-only selection of individual RM protocols")
    individual.add_argument("--mdb", type=Path, required=True)
    individual.add_argument("--files", type=Path, required=True)
    individual.add_argument("--rm-id", type=int, action="append", required=True)
    individual.add_argument("--factor", type=int, action="append", required=True)
    individual.add_argument("--output", type=Path)

    summary = subs.add_parser("select-summary", help="Inspect original organization docs_list.xml")
    summary.add_argument("--files", type=Path, required=True)
    summary.add_argument("--organization-guid", required=True)
    summary.add_argument("--visible-division", action="append", default=[])
    summary.add_argument("--region-division", action="append")
    summary.add_argument("--factor", type=int, action="append")
    summary.add_argument("--output", type=Path)

    noise = subs.add_parser("inspect-noise", help="Extract original 2025 noise values")
    noise.add_argument("--xml", type=Path, required=True)
    noise.add_argument("--acoustic", action="store_true")
    noise.add_argument("--acoustic-only", action="store_true")
    noise.add_argument("--per-operation", action="store_true")
    noise.add_argument("--uncertainty", action="store_true")
    noise.add_argument("--output", type=Path)

    args = p.parse_args(argv)

    def show(data):
        result = json.dumps(data, ensure_ascii=False, indent=2)
        if getattr(args, "output", None):
            args.output.write_text(result + "\n", encoding="utf-8")
            print(f"Read-only research report: {args.output}")
        else:
            print(result)
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
        if args.operation == "select-individual":
            show({
                "mode": "individual",
                "status": "inventory_only_not_a_validated_FSA_export",
                "protocols": selections_to_dict(select_individual(
                    args.mdb, args.files,
                    selected_workplace_ids=args.rm_id,
                    enabled_factors=args.factor)),
            })
            return 0
        if args.operation == "select-summary":
            show({
                "mode": "consolidated",
                "status": "inventory_only_not_a_validated_FSA_export",
                "protocols": selections_to_dict(select_consolidated(
                    args.files, args.organization_guid,
                    visible_divisions=args.visible_division,
                    region_divisions=args.region_division,
                    enabled_factors=args.factor)),
            })
            return 0
        if args.operation == "inspect-noise":
            if args.acoustic_only and not args.acoustic:
                raise FsaSourceError("--acoustic-only requires --acoustic")
            if args.per_operation and not args.acoustic:
                raise FsaSourceError("--per-operation requires --acoustic")
            options = NoiseOptions(
                acoustic_measurements=args.acoustic,
                both_measurements_and_equivalent=args.acoustic_only,
                acoustic_level_per_operation=args.per_operation,
                include_uncertainty=args.uncertainty,
            )
            show({
                "source_xml": str(args.xml),
                "factor": 4,
                "status": "intermediate_values_only_no_FSA_export",
                "measurements": [m.as_dict() for m in extract_noise_from_file(args.xml, options)],
            })
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
