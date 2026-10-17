#!/usr/bin/env python3
"""Render the frozen, release-derived FP vector table as SV task calls."""

import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TABLE = ROOT / "frozen_case_table.json"
OUTPUT = ROOT / "frozen_cases.svh"
EXPECTED_RELEASE_SHA256 = "89b847de5851a6a8a836a70fba31bac78c468e8a847f3f110b19c3aa77c2830d"


def rendered() -> str:
    table = json.loads(TABLE.read_text())
    if table["source_release_sha256"] != EXPECTED_RELEASE_SHA256 or table["case_count"] != 119:
        raise RuntimeError("frozen table differs from accepted design release")
    rows = table["rows"]
    if len(rows) != 119 or len({(x["wrapper"], x["case_id"]) for x in rows}) != 119:
        raise RuntimeError("frozen table count or uniqueness mismatch")
    lines = ["// Generated solely from frozen_case_table.json; no numerical oracle is run."]
    for row in rows:
        case_id = row["case_id"]
        if not case_id.replace("_", "").isalnum():
            raise RuntimeError(f"invalid case ID: {case_id}")
        lines.append(f'    run_case({row["wrapper_id"]}, "{case_id}", '
                     f'32\'h{row["a_bits"]}, 32\'h{row["b_bits"]}, '
                     f'32\'h{row["expected_bits"]}, 5\'d{row["opcode"]});')
    return "\n".join(lines) + "\n"


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--write", action="store_true")
    p.add_argument("--check", action="store_true")
    args = p.parse_args()
    if args.write == args.check:
        p.error("choose exactly one of --write or --check")
    content = rendered()
    if args.write:
        if OUTPUT.exists():
            raise RuntimeError("case include already exists")
        OUTPUT.write_text(content)
    elif not OUTPUT.is_file() or OUTPUT.read_text() != content:
        raise RuntimeError("case include differs from frozen table")
    print(f"FP_CASE_INCLUDE_PASS rows=119 sha256={hashlib.sha256(content.encode()).hexdigest()}")


if __name__ == "__main__":
    main()
