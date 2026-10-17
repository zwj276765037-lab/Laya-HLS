#!/usr/bin/env python3
"""Derive a short descriptor-rejection adapter check from the v4 front TB."""

from pathlib import Path
import sys


if len(sys.argv) != 3:
    raise SystemExit("usage: make_cpu_front_reject_top.py FULL_TOP_SV OUTPUT_SV")

source = Path(sys.argv[1]).read_text()
replacements = (
    ("function int thin_mem_check();", "function int thin_mem_check_reject();"),
    ("first_done_numeric_ok = thin_mem_check();",
     "first_done_numeric_ok = thin_mem_check_reject();"),
    # Descriptor rejection exits before LN and STATE1 traffic, so the full
    # cold case's final-R/final-B hold coverage is inapplicable here.  Keep
    # the first-done debt and adapter checks unchanged in this derived TB.
    ('if (!first_done_r_hold || !first_done_b_hold) $fatal(1, "required holds not exercised");',
     '$display("CPU_FRONT_REJECT_HOLD_COVERAGE r=%b b=%b", first_done_r_hold, first_done_b_hold);'),
    ('CPU_FRONT_RTL_PASS cycles=%0d',
     'CPU_FRONT_REJECT_ADAPTER_PASS cycles=%0d'),
)
for old, new in replacements:
    if source.count(old) != 1:
        raise RuntimeError(f"expected exactly one {old!r}")
    source = source.replace(old, new)
Path(sys.argv[2]).write_text(source)
