#!/usr/bin/env python3
"""Audit every raw seven-wrapper FP record against the frozen R0 bit table."""

import datetime as dt
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent
TABLE = ROOT / "frozen_case_table.json"
HEX = re.compile(r"^[0-9a-fA-F]{8}$")


def fields(line: str) -> dict[str, str]:
    return dict(part.split("=", 1) for part in line.split("|")[1:] if "=" in part)


def audit(runtime: Path) -> dict:
    table = json.loads(TABLE.read_text())
    expected = {(r["wrapper"], r["case_id"]): r for r in table["rows"]}
    raw_path = runtime / "fp_raw.log"
    problems: list[dict] = []
    first_failure = None
    seen: dict[tuple[str, str], dict] = {}
    complete = []
    if not raw_path.is_file():
        problems.append({"kind": "missing_raw_log", "path": str(raw_path)})
        lines = []
    else:
        lines = raw_path.read_text(errors="replace").splitlines()
    for line_number, line in enumerate(lines, 1):
        if line.startswith("FP_CHARACTERIZATION_COMPLETE|"):
            complete.append(fields(line))
            continue
        if not line.startswith("FP_RAW|"):
            problems.append({"kind": "unrecognized_raw_line", "line": line_number, "text": line})
            continue
        record = fields(line)
        key = (record.get("wrapper", ""), record.get("case", ""))
        if key in seen:
            problems.append({"kind": "duplicate_case", "line": line_number, "key": key})
            continue
        seen[key] = record
        row = expected.get(key)
        if row is None:
            problems.append({"kind": "unexpected_case", "line": line_number, "key": key})
            continue
        identity = {"a": row["a_bits"], "b": row["b_bits"],
                    "expected": row["expected_bits"], "opcode": str(row["opcode"])}
        for field, value in identity.items():
            if record.get(field, "").lower() != value.lower():
                problems.append({"kind": "case_identity_mismatch", "line": line_number,
                                 "key": key, "field": field, "recorded": record.get(field), "frozen": value})
        samples = [record.get(f"actual{i}", "") for i in range(3)]
        cycles = [record.get(f"cycle{i}", "") for i in range(3)]
        if not all(HEX.fullmatch(value) for value in samples):
            issue = {"kind": "unknown_or_malformed_output", "line": line_number,
                     "key": key, "samples": samples}
            problems.append(issue)
            if first_failure is None:
                first_failure = issue
        elif len(set(value.lower() for value in samples)) != 1:
            issue = {"kind": "unstable_output", "line": line_number,
                     "key": key, "samples": samples}
            problems.append(issue)
            if first_failure is None:
                first_failure = issue
        elif samples[-1].lower() != row["expected_bits"].lower():
            issue = {"kind": "R0_bit_mismatch", "line": line_number, "key": key,
                     "a": row["a_bits"], "b": row["b_bits"], "opcode": row["opcode"],
                     "expected": row["expected_bits"], "actual": samples[-1]}
            problems.append(issue)
            if first_failure is None:
                first_failure = issue
        try:
            ticks = [int(x) for x in cycles]
            if not (ticks[0] + 1 == ticks[1] and ticks[1] + 1 == ticks[2]):
                raise ValueError("nonconsecutive")
        except ValueError:
            problems.append({"kind": "sample_cycle_error", "line": line_number, "key": key, "cycles": cycles})
        if any(record.get(f"valid{i}") not in ("0", "1", "x", "X", "z", "Z") for i in range(3)):
            problems.append({"kind": "valid_record_malformed", "line": line_number, "key": key})
    missing = sorted(set(expected) - set(seen))
    if missing:
        problems.append({"kind": "missing_cases", "count": len(missing), "keys": missing})
    if len(complete) != 1:
        problems.append({"kind": "completion_marker_count", "count": len(complete)})
    else:
        marker = complete[0]
        if marker.get("planned") != "119" or marker.get("observed") != str(len(seen)):
            problems.append({"kind": "completion_count_mismatch", "marker": marker, "seen": len(seen)})
        raw_numeric_mismatches = sum(p["kind"] in ("R0_bit_mismatch", "unknown_or_malformed_output", "unstable_output") for p in problems)
        if marker.get("mismatches") != str(raw_numeric_mismatches):
            problems.append({"kind": "completion_mismatch_count", "marker": marker,
                             "independent_count": raw_numeric_mismatches})
    xsim_log = runtime / "xsim.log"
    text = xsim_log.read_text(errors="replace") if xsim_log.is_file() else ""
    if not problems and "FP_CONFORMANCE_PASS cases=119 wrappers=7" not in text:
        problems.append({"kind": "missing_xsim_pass_marker"})
    return {"schema": "q8_actual_fp_boundary_independent_raw_audit_v1",
            "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
            "runtime": str(runtime), "planned": 119, "seen": len(seen),
            "first_failure": first_failure, "problems": problems,
            "status": "PASS" if not problems else "FAIL"}


def main() -> int:
    if len(sys.argv) != 3:
        raise SystemExit("usage: independent_check.py RUNTIME_DIR REPORT_JSON")
    runtime = Path(sys.argv[1]).resolve()
    report = Path(sys.argv[2]).resolve()
    if report.exists():
        raise SystemExit(f"report already exists: {report}")
    result = audit(runtime)
    report.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(f"FP_BOUNDARY_AUDIT_{result['status']} seen={result['seen']} problems={len(result['problems'])}")
    return 0 if result["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
