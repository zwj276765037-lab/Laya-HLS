#!/usr/bin/env python3
"""Check a materialized finite table without executing the R0 reference."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify(directory: Path) -> dict:
    table_path = directory / "case_table.json"
    include_path = directory / "generated_cases.svh"
    table = json.loads(table_path.read_text())
    if table.get("schema") != "q8_r0_finite_domain_generated_cases_v1":
        raise RuntimeError("unexpected case-table schema")
    if table.get("status") != "REFERENCE_EXPECTATIONS_GENERATED_NOT_RTL_VERIFIED":
        raise RuntimeError("case-table status drift")
    for field, path in (
        ("vector_source_sha256", HERE / "vector_manifest.json"),
        ("independent_reference_sha256", HERE / "original_r0_reference.py"),
        ("generated_include_sha256", include_path),
    ):
        if table[field] != sha(path):
            raise RuntimeError(f"{field} identity mismatch")
    manifest = json.loads((HERE / "vector_manifest.json").read_text())
    scorer = manifest["accepted_scorer_input"]
    scorer_path = Path(scorer["path"])
    if (scorer_path.stat().st_size != scorer["bytes"] or
            sha(scorer_path) != scorer["sha256"] or
            table["accepted_scorer_input_sha256"] != scorer["sha256"]):
        raise RuntimeError("accepted Scorer input identity mismatch")
    groups = table["groups"]
    reciprocals = table["scalar_reciprocal"]
    halves = table["scalar_half"]
    restore = table["restore"]
    if not (1 <= len(groups) <= 128 and 1 <= len(reciprocals) <= 32 and
            1 <= len(halves) <= 32 and 1 <= len(restore) <= 64):
        raise RuntimeError("finite case-count bound violated")
    group_ids = [row["id"] for row in groups]
    restore_ids = [row["id"] for row in restore]
    if len(set(group_ids)) != len(group_ids) or len(set(restore_ids)) != len(restore_ids):
        raise RuntimeError("duplicate case id")
    if len({row["d_bits"] for row in reciprocals}) != len(reciprocals):
        raise RuntimeError("duplicate reciprocal scalar")
    if len({row["d_bits"] for row in halves}) != len(halves):
        raise RuntimeError("duplicate half scalar")
    for row in groups:
        expected = row["expected"]
        if len(row["lanes_hex"]) != 32:
            raise RuntimeError(f"group lane count: {row['id']}")
        if expected["commit"] != (expected["status"] == 0):
            raise RuntimeError(f"group commit/status contradiction: {row['id']}")
        if expected["commit"] and (len(expected["q"]) != 32 or
                                   len(expected["lane_records"]) != 32):
            raise RuntimeError(f"committed group incomplete: {row['id']}")
        if [lane["index"] for lane in expected["lane_records"]] != list(
                range(len(expected["lane_records"]))):
            raise RuntimeError(f"nonsequential diagnostic lanes: {row['id']}")
    for row in restore:
        if (row["route"] == 3) != row["expect_domain_rejection"]:
            raise RuntimeError(f"restore domain contradiction: {row['id']}")
    return {"groups": len(groups), "scalar": len(reciprocals) + len(halves),
            "restore": len(restore), "table_sha256": sha(table_path),
            "include_sha256": sha(include_path)}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    args = parser.parse_args()
    counts = verify(args.directory.resolve())
    print(f"R0_VECTOR_BINDING_PASS groups={counts['groups']} "
          f"scalar={counts['scalar']} restore={counts['restore']}")


if __name__ == "__main__":
    main()
