#!/usr/bin/env python3
"""Render the reviewed UNISIM parameter contract as literal Tcl source."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "source/semantic_property_contract.json"
OUTPUT = ROOT / "source/required_properties.tcl"
REFS = (
    "RAMB36E2", "RAMB18E2", "URAM288", "LUT1", "LUT2", "LUT3", "LUT4",
    "LUT5", "LUT6", "MUXF7", "MUXF8", "MUXF9", "FDRE", "FDCE", "FDSE",
    "FDPE", "VCC", "GND", "CARRY8", "RAM128X1D", "RAM32X1D", "RAM64X1D",
)


def render() -> str:
    contract = json.loads(CONTRACT.read_text())
    entries = contract["primitive_contracts"]
    if [entry["reference"] for entry in entries] != list(REFS):
        raise ValueError("primitive reference order or set changed")
    lines = [
        "# Generated from semantic_property_contract.json; do not edit by hand.",
        "# Missing/empty DCP values remain gaps; declaration defaults are not values.",
        "set required_by_ref [dict create]",
        "set vector_width_by_ref [dict create]",
    ]
    total = 0
    for entry in entries:
        ref = entry["reference"]
        required = entry["required_property_names"]
        selected = [p for p in entry["parameters"]
                    if p["classification"] == "required_semantic_property"]
        if sorted(required) != required or sorted(p["name"] for p in selected) != required:
            raise ValueError(f"required property list mismatch: {ref}")
        if len(selected) != len(set(required)):
            raise ValueError(f"duplicate parameter: {ref}")
        total += len(required)
        lines.append(f"dict set required_by_ref {ref} {{{' '.join(required)}}}")
        for parameter in selected:
            match = re.search(r"\[(\d+)\s*:\s*(\d+)\]", parameter["declaration"])
            if match:
                high, low = map(int, match.groups())
                if high < low:
                    raise ValueError(f"invalid vector declaration: {ref}/{parameter['name']}")
                lines.append(f"dict set vector_width_by_ref {ref} {parameter['name']} {high - low + 1}")
    if len(entries) != 22 or total != 348:
        raise ValueError("reviewed contract cardinality changed")
    lines += ["set required_contract_count 348", "set required_ref_count 22", ""]
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="verify existing output")
    args = parser.parse_args()
    expected = render()
    if args.check:
        if OUTPUT.read_text() != expected:
            raise SystemExit("generated Tcl differs from reviewed contract")
        print("Q8_WS_V4_CONTRACT_TCL_PASS")
    else:
        if OUTPUT.exists():
            raise SystemExit("refuse to overwrite existing contract Tcl")
        OUTPUT.write_text(expected)
        print("Q8_WS_V4_CONTRACT_TCL_CREATED")


if __name__ == "__main__":
    main()
