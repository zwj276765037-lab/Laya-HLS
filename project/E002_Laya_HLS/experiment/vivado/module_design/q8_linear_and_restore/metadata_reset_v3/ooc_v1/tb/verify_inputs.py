#!/usr/bin/env python3
"""Verify and, only when requested, stage the frozen same-source Q8 OOC inputs."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "source/input_manifest.json"
COUNTS = {"verilog": 230, "data": 108, "ip_tcl": 7, "ip_xci": 7,
          "ip_synth_vhdl": 7, "shared_synth_vhdl": 6, "ooc_xdc": 1}


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def verify() -> tuple[dict, list[dict]]:
    manifest = json.loads(MANIFEST.read_text())
    if manifest.get("schema") != "q8_same_source_ooc_input_manifest_v1":
        raise RuntimeError("unexpected input manifest schema")
    rows = manifest["files"]
    counts = {kind: 0 for kind in COUNTS}
    stage_names: set[tuple[str, str]] = set()
    for row in rows:
        kind = row["kind"]
        if kind not in counts:
            raise RuntimeError(f"unexpected source kind: {kind}")
        counts[kind] += 1
        path = Path(row["path"])
        if not path.is_file() or path.stat().st_size != row["bytes"] or digest(path) != row["sha256"]:
            raise RuntimeError(f"source identity mismatch: {path}")
        if kind in ("verilog", "data", "ip_tcl", "ip_xci", "ooc_xdc"):
            subdir = "rtl" if kind in ("verilog", "data", "ip_tcl") else "ip" if kind == "ip_xci" else "constraints"
            key = (subdir, path.name)
            if key in stage_names:
                raise RuntimeError(f"duplicate staged basename: {key}")
            stage_names.add(key)
    if counts != COUNTS:
        raise RuntimeError(f"source counts differ: {counts}")
    if len(rows) != sum(COUNTS.values()):
        raise RuntimeError("input row count differs")
    return manifest, rows


def stage(run_dir: Path, rows: list[dict]) -> None:
    if run_dir.exists():
        raise RuntimeError(f"fresh run directory required: {run_dir}")
    run_dir.mkdir(parents=True)
    for row in rows:
        kind = row["kind"]
        if kind not in ("verilog", "data", "ip_tcl", "ip_xci", "ooc_xdc"):
            continue  # IP synthesis products are bound comparands, not duplicate project inputs.
        subdir = "rtl" if kind in ("verilog", "data", "ip_tcl") else "ip" if kind == "ip_xci" else "constraints"
        source = Path(row["path"])
        target = run_dir / "stage" / subdir / source.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        if target.stat().st_size != row["bytes"] or digest(target) != row["sha256"]:
            raise RuntimeError(f"staging mismatch: {target}")
    scripts = sorted((ROOT / "tb").glob("*.tcl"))
    if len(scripts) != 5:
        raise RuntimeError(f"expected five maintained Tcl scripts, found {len(scripts)}")
    for source in scripts:
        target = run_dir / "stage/scripts" / source.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        if digest(target) != digest(source):
            raise RuntimeError(f"script staging mismatch: {source.name}")
    shutil.copy2(MANIFEST, run_dir / "stage/input_manifest.json")
    print(f"Q8_OOC_STAGED run={run_dir} rtl=345 xci=7 scripts=5 xdc=1")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="read-only source hash check")
    parser.add_argument("--stage", type=Path, metavar="FRESH_RUN_DIR", help="copy verified inputs into a fresh isolated run")
    args = parser.parse_args()
    if args.check == bool(args.stage):
        parser.error("select exactly one of --check or --stage")
    manifest, rows = verify()
    print(f"Q8_OOC_INPUTS_PASS files={len(rows)} manifest={digest(MANIFEST)} precheck={manifest['reviewed_precheck_sha256']}")
    if args.stage:
        stage(args.stage.resolve(), rows)


if __name__ == "__main__":
    main()
