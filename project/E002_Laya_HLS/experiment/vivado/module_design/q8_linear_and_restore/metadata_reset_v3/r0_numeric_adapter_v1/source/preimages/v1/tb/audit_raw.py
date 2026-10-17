#!/usr/bin/env python3
"""Audit complete raw probe coverage and bit comparisons after a released run."""

from __future__ import annotations

import argparse
from collections import Counter
import datetime as dt
import json
from pathlib import Path
import re

from verify_generated_vectors import verify


RAW = re.compile(r"^R0_RAW\|case=([A-Za-z0-9_]+)\|field=([A-Za-z0-9_]+)\|"
                 r"actual=([0-9a-fA-FxXzZ]+)\|expected=([0-9a-fA-FxXzZ]+)\|cycle=(\d+)$")
COMPLETE = re.compile(r"^R0_ADAPTER_PROBE_COMPLETE\|groups=(\d+)\|scalar=(\d+)\|"
                      r"restore=(\d+)\|mismatches=(\d+)$")
FP_ROUTES = {"NORMAL_FP", "SCALED_FP"}


def add_service(keys: Counter, case: str, service: str) -> None:
    for field in (f"{service}_stable_0", f"{service}_stable_1", f"{service}_valid"):
        keys[(case, field)] += 1


def expected_keys(table: dict) -> Counter:
    keys: Counter = Counter()
    for field in ("div", "mul2", "mul3", "add", "cmp1_eq", "cmp2_eq", "sitofp"):
        keys[("normal_wrapper_smoke", field)] += 1
    for row in table["groups"]:
        case = row["id"]
        expected = row["expected"]
        if expected["d_bits"] is None:
            keys[(case, "first_nonfinite_input")] += 1
        else:
            for field in ("amax_bits", "d_full_bits", "d_is_zero_at_reciprocal",
                          "d_is_zero_at_quantization", "reciprocal_bits", "saved_half"):
                keys[(case, field)] += 1
            if expected["amax_bits"] > 0x03FE0000:
                add_service(keys, case, "group_div127")
            if expected["d_bits"] & 0x7FFFFFFF:
                add_service(keys, case, "reciprocal_div")
            for lane in expected["lane_records"]:
                lane_case = f"{case}_lane_{lane['index']}"
                keys[(lane_case, "quant_route")] += 1
                if lane["route"] in FP_ROUTES:
                    for field in ("product_expected", "mul2_stable_0", "mul2_stable_1",
                                  "mul3_stable_0", "mul3_stable_1", "mul2_valid",
                                  "mul3_valid", "product_mul2", "product_mul3"):
                        keys[(lane_case, field)] += 1
                else:
                    keys[(lane_case, "product_bypassed")] += 1
        for field in ("status", "bad_element", "group_committed"):
            keys[(case, field)] += 1
        if expected["commit"]:
            for lane in range(32):
                keys[(f"{case}_lane_{lane}", "q_byte")] += 1
    for row in table["scalar_reciprocal"]:
        case = f"recip_{row['d_bits']:08x}"
        for field in ("d_is_zero_at_reciprocal", "d_is_zero_at_quantization",
                      "normalize", "divider_input", "normalized_divider_result", "reciprocal"):
            keys[(case, field)] += 1
        if not row["d_zero_reciprocal"]:
            add_service(keys, case, "reciprocal_div")
    for row in table["scalar_half"]:
        keys[(f"half_{row['d_bits']:08x}", "saved_half")] += 1
    for row in table["restore"]:
        case = row["id"]
        keys[(case, "bias_route")] += 1
        if row["route"] == 3:
            keys[(case, "outside_domain_ps")] += 1
        else:
            if row["route"] == 2:
                add_service(keys, case, "adder")
            keys[(case, "restore_result")] += 1
    return keys


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("vector_directory", type=Path)
    parser.add_argument("raw_log", type=Path)
    parser.add_argument("--xsim-log", type=Path)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise RuntimeError(f"fresh report path required: {args.out}")
    counts = verify(args.vector_directory.resolve())
    table = json.loads((args.vector_directory / "case_table.json").read_text())
    expected = expected_keys(table)
    observed: Counter = Counter()
    mismatches = []
    malformed = []
    complete = []
    last_cycle = -1
    for number, line in enumerate(args.raw_log.read_text().splitlines(), 1):
        if line.startswith("R0_RAW|"):
            match = RAW.fullmatch(line)
            if match is None:
                malformed.append({"line": number, "raw": line})
                continue
            case, field, actual, reference, cycle_text = match.groups()
            cycle = int(cycle_text)
            observed[(case, field)] += 1
            if (actual.lower() != reference.lower() or
                    any(char in actual.lower() + reference.lower() for char in "xz") or
                    cycle < last_cycle or cycle > 500000):
                mismatches.append({"line": number, "case": case, "field": field,
                                   "actual": actual, "expected": reference, "cycle": cycle})
            last_cycle = cycle
        elif line.startswith("R0_ADAPTER_PROBE_COMPLETE|"):
            match = COMPLETE.fullmatch(line)
            if match is None:
                malformed.append({"line": number, "raw": line})
            else:
                complete.append(tuple(map(int, match.groups())))
    missing = [{"case": case, "field": field, "count": count}
               for (case, field), count in (expected - observed).items()]
    extra = [{"case": case, "field": field, "count": count}
             for (case, field), count in (observed - expected).items()]
    wanted = (counts["groups"], counts["scalar"], counts["restore"], 0)
    xsim_pass = True
    if args.xsim_log is not None:
        marker = (f"R0_ADAPTER_CONFORMANCE_PASS groups={counts['groups']} "
                  f"scalar={counts['scalar']} restore={counts['restore']}")
        xsim_pass = marker in args.xsim_log.read_text(errors="replace")
    passed = (not mismatches and not malformed and not missing and not extra and
              complete == [wanted] and xsim_pass)
    report = {"schema": "q8_r0_finite_domain_raw_audit_v1",
              "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
              "status": "PASS" if passed else "FAIL", "expected_records": sum(expected.values()),
              "observed_records": sum(observed.values()), "expected_case_counts": wanted[:3],
              "raw_completion": complete, "xsim_pass_marker": xsim_pass,
              "mismatches": mismatches, "malformed": malformed,
              "missing": missing, "extra": extra}
    args.out.write_text(json.dumps(report, indent=2) + "\n")
    print(f"R0_RAW_AUDIT_{report['status']} observed={sum(observed.values())} "
          f"expected={sum(expected.values())} mismatches={len(mismatches)}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
