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
ROUTE_CODES = {"D_ZERO": 0, "X_ZERO": 1, "SMALL_Q_ZERO": 1,
               "NORMAL_FP": 2, "SCALED_FP": 3}


def expected_contract(table: dict) -> tuple[Counter, dict[tuple[str, str], str]]:
    """Derive every table-authoritative raw bit, leaving only stability dynamic."""
    keys: Counter = Counter()
    gold: dict[tuple[str, str], str] = {}

    def add(case: str, field: str, value: str | None) -> None:
        key = (case, field)
        if key in keys:
            raise RuntimeError(f"duplicate expected raw field: {key}")
        keys[key] = 1
        if value is not None:
            gold[key] = value

    def add32(case: str, field: str, value: int) -> None:
        add(case, field, f"{value & 0xFFFFFFFF:08x}")

    def add16(case: str, field: str, value: int) -> None:
        add(case, field, f"{value & 0xFFFF:04x}")

    def add2(case: str, field: str, value: int) -> None:
        add(case, field, f"{value & 3:02b}")

    def add1(case: str, field: str, value: bool | int) -> None:
        add(case, field, str(int(value)))

    def service(case: str, name: str) -> None:
        add(case, f"{name}_stable_0", None)
        add(case, f"{name}_stable_1", None)
        add1(case, f"{name}_valid", 1)

    smoke = table["normal_wrapper_smoke"]
    for field in ("div", "mul2", "mul3", "add", "sitofp"):
        add32("normal_wrapper_smoke", field, smoke[field])
    add1("normal_wrapper_smoke", "cmp1_eq", smoke["cmp1_eq"])
    add1("normal_wrapper_smoke", "cmp2_eq", smoke["cmp2_eq"])
    for row in table["groups"]:
        case = row["id"]
        expected = row["expected"]
        if expected["d_bits"] is None:
            add32(case, "first_nonfinite_input", expected["bad_element"])
        else:
            add32(case, "amax_bits", expected["amax_bits"])
            add32(case, "d_full_bits", expected["d_bits"])
            if expected["amax_bits"] > 0x03FE0000:
                service(case, "group_div127")
            add1(case, "d_is_zero_at_reciprocal", expected["d_zero_reciprocal"])
            add1(case, "d_is_zero_at_quantization", expected["d_zero_quantization"])
            if expected["d_bits"] & 0x7FFFFFFF:
                service(case, "reciprocal_div")
            add32(case, "reciprocal_bits", expected["reciprocal_bits"])
            add16(case, "saved_half", expected["saved_half"])
            for lane in expected["lane_records"]:
                lane_case = f"{case}_lane_{lane['index']}"
                add2(lane_case, "quant_route", ROUTE_CODES[lane["route"]])
                if lane["route"] in FP_ROUTES:
                    if lane["product_bits"] is None:
                        raise RuntimeError(f"missing FP-route product gold: {lane_case}")
                    service(lane_case, "mul2")
                    service(lane_case, "mul3")
                    add1(lane_case, "product_expected", 1)
                    add32(lane_case, "product_mul2", lane["product_bits"])
                    add32(lane_case, "product_mul3", lane["product_bits"])
                else:
                    add1(lane_case, "product_bypassed", 0)
        add32(case, "status", expected["status"])
        add32(case, "bad_element", -1 if expected["bad_element"] is None
              else expected["bad_element"])
        add1(case, "group_committed", expected["commit"])
        if expected["commit"]:
            for lane in range(32):
                add32(f"{case}_lane_{lane}", "q_byte", expected["q"][lane] & 0xFF)
    for row in table["scalar_reciprocal"]:
        case = f"recip_{row['d_bits']:08x}"
        add1(case, "d_is_zero_at_reciprocal", row["d_zero_reciprocal"])
        add1(case, "d_is_zero_at_quantization", row["d_zero_quantization"])
        add1(case, "normalize", row["normalized"])
        if not row["d_zero_reciprocal"]:
            service(case, "reciprocal_div")
        add32(case, "divider_input", row["divider_input_bits"])
        add32(case, "normalized_divider_result", row["normalized_divider_result_bits"])
        add32(case, "reciprocal", row["reciprocal_bits"])
    for row in table["scalar_half"]:
        add16(f"half_{row['d_bits']:08x}", "saved_half", row["saved_half"])
    for row in table["restore"]:
        case = row["id"]
        add2(case, "bias_route", row["route"])
        if row["route"] == 3:
            add32(case, "outside_domain_ps", row["ps_bits"])
        else:
            if row["route"] == 2:
                service(case, "adder")
            add32(case, "restore_result", row["expected_bits"])
    if set(keys) - set(gold) != {key for key in keys if "_stable_" in key[1]}:
        raise RuntimeError("non-stability field lacks independent gold")
    return keys, gold


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
    expected, gold = expected_contract(table)
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
            key = (case, field)
            observed[key] += 1
            issues = []
            if actual.lower() != reference.lower():
                issues.append("raw_actual_vs_logged_expected")
            if any(char in actual.lower() + reference.lower() for char in "xz"):
                issues.append("unknown_bit")
            if key in gold:
                if actual.lower() != gold[key]:
                    issues.append("actual_vs_independent_table")
                if reference.lower() != gold[key]:
                    issues.append("logged_expected_vs_independent_table")
            elif key in expected and "_stable_" not in field:
                issues.append("missing_independent_table_gold")
            if cycle < last_cycle or cycle > 500000:
                issues.append("cycle_order_or_watchdog")
            if issues:
                mismatches.append({"line": number, "case": case, "field": field,
                                   "actual": actual, "logged_expected": reference,
                                   "independent_gold": gold.get(key),
                                   "cycle": cycle, "issues": issues})
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
              "table_authoritative_fields": len(gold),
              "dynamic_stability_fields": len(expected) - len(gold),
              "mismatches": mismatches, "malformed": malformed,
              "missing": missing, "extra": extra}
    args.out.write_text(json.dumps(report, indent=2) + "\n")
    print(f"R0_RAW_AUDIT_{report['status']} observed={sum(observed.values())} "
          f"expected={sum(expected.values())} mismatches={len(mismatches)}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
