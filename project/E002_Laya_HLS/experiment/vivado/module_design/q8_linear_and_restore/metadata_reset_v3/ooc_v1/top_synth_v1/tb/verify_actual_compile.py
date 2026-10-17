#!/usr/bin/env python3
"""Compare Vivado's relocated prelaunch compile order to accepted a2 bits."""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
from pathlib import Path

from project_identity import (COMPILE_COUNT, SOURCE, accepted_evidence,
                              record)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("clone", type=Path)
    parser.add_argument("actual_compile_tsv", type=Path)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise RuntimeError(f"fresh report path required: {args.out}")
    clone = args.clone.resolve()
    if clone == SOURCE or clone.is_relative_to(SOURCE):
        raise RuntimeError("accepted a2 project cannot be used for synthesis")
    _, evidence = accepted_evidence()
    with args.actual_compile_tsv.open(newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != ["library", "file_type", "path"]:
            raise RuntimeError("unexpected actual compile-order columns")
        actual = list(reader)
    expected = evidence["actual_compile_closure"]
    if len(expected) != COMPILE_COUNT or len(actual) != COMPILE_COUNT:
        raise RuntimeError("actual compile-order count differs from accepted a2")
    checked = []
    for index, (before, after) in enumerate(zip(expected, actual)):
        relative = Path(before["path"]).relative_to(SOURCE)
        expected_path = clone / relative
        if (after["library"], after["file_type"], Path(after["path"]).resolve()) != \
                (before["library"], before["file_type"], expected_path.resolve()):
            raise RuntimeError(f"actual compile-order path/library drift at row {index}")
        if "/sim/" in str(expected_path):
            raise RuntimeError("simulation VHDL entered synthesis closure")
        item = record(expected_path)
        if (item["bytes"], item["sha256"]) != (before["bytes"], before["sha256"]):
            raise RuntimeError(f"actual compile input content drift: {expected_path}")
        checked.append({"library": after["library"],
                        "file_type": after["file_type"], **item})
    report = {"schema": "q8_top_ooc_prelaunch_actual_compile_identity_v1",
              "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
              "status": "EXACT_243_COMPILE_INPUTS_PASS_NO_SYNTHESIS",
              "clone_root": str(clone),
              "actual_compile_tsv": record(args.actual_compile_tsv),
              "compiled_breakdown": {"verilog": 230, "fp_synth_vhdl": 7,
                                     "shared_synth_vhdl": 6},
              "rows": checked}
    args.out.write_text(json.dumps(report, indent=2) + "\n")
    print("Q8_TOP_OOC_COMPILE_PREFLIGHT_PASS files=243 verilog=230 fp=7 shared=6")


if __name__ == "__main__":
    main()
