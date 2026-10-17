#!/usr/bin/env python3
"""Compare generated IP synthesis products with the frozen original closure."""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import json
from pathlib import Path

from make_source_packet import construct


ROOT = Path(__file__).resolve().parents[1]
PACKET = ROOT / "source/source_packet.json"
MANIFEST = ROOT / "source/input_manifest.json"


def record(path: Path) -> dict:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": h.hexdigest()}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run_dir", type=Path)
    parser.add_argument("report_dir", type=Path)
    args = parser.parse_args()
    run_dir = args.run_dir.resolve()
    report_dir = args.report_dir.resolve()
    out = report_dir / "product_identity.json"
    if not report_dir.is_dir() or out.exists():
        raise RuntimeError("existing report directory without product identity required")
    packet = json.loads(PACKET.read_text())
    if packet != construct(packet["created_utc"]):
        raise RuntimeError("OOC source packet binding drift")
    manifest = json.loads(MANIFEST.read_text())
    compile_report = report_dir / "compile_order_libraries.tsv"
    with compile_report.open(newline="") as stream:
        compiled = list(csv.DictReader(stream, delimiter="\t"))
    if not compiled or set(compiled[0]) != {"library", "file_type", "path"}:
        raise RuntimeError("unexpected actual Vivado compile-order report")
    compiled_by_path = {str(Path(row["path"]).resolve()): row for row in compiled}
    compiled_by_name: dict[str, list[dict]] = {}
    for row in compiled:
        compiled_by_name.setdefault(Path(row["path"]).name, []).append(row)
    generated = []
    failures = []
    for original in (row for row in manifest["files"] if row["kind"] == "ip_synth_vhdl"):
        name = Path(original["path"]).stem
        base = run_dir / "vivado/q8_same_source_ooc.gen/sources_1/ip" / name
        synth = base / "synth" / f"{name}.vhd"
        sim = base / "sim" / f"{name}.vhd"
        actual = record(synth) if synth.is_file() else None
        compile_row = compiled_by_path.get(str(synth.resolve()))
        match = actual is not None and actual["bytes"] == original["bytes"] and actual["sha256"] == original["sha256"]
        status = "MATCH" if match and sim.is_file() and compile_row else (
            "MISSING_SYNTH" if actual is None else "MISSING_SIM" if not sim.is_file() else
            "NOT_IN_COMPILE_ORDER" if compile_row is None else "CONTENT_DIFFERENCE")
        if status != "MATCH":
            failures.append({"product": name, "reason": status})
        generated.append({"ip": name, "original": original, "actual_synthesis": actual,
                          "generated_simulation": record(sim) if sim.is_file() else None,
                          "compile_order": compile_row, "status": status})
    shared = []
    for original in (row for row in manifest["files"] if row["kind"] == "shared_synth_vhdl"):
        candidates = [record(Path(row["path"])) | {"library": row["library"]}
                      for row in compiled_by_name.get(Path(original["path"]).name, [])
                      if Path(row["path"]).is_file()]
        matches = [row for row in candidates if row["bytes"] == original["bytes"]
                   and row["sha256"] == original["sha256"]]
        status = "MATCH" if matches else "ABSENT_FROM_COMPILE_ORDER" if not candidates else "CONTENT_DIFFERENCE"
        # A shared synthesis unit absent from the actual compile order has no
        # bound replacement here.  Preserve the missing-unit result and stop
        # the project/IP gate instead of presenting a misleading PASS.
        if status != "MATCH":
            failures.append({"shared_file": Path(original["path"]).name, "reason": status})
        shared.append({"original": original, "compiled_candidates": candidates, "status": status})
    if len(generated) != 7 or len(shared) != 6:
        raise RuntimeError("frozen IP/shared product counts drift")
    evidence = {
        "schema": "q8_same_source_ooc_project_products_identity_v1",
        "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "status": "PASS" if not failures else "REVIEW_REQUIRED",
        "source_packet": record(PACKET),
        "original_input_manifest": record(MANIFEST),
        "actual_compile_order": record(compile_report),
        "actual_compile_file_count": len(compiled),
        "generated_ip_products": generated,
        "shared_library_candidates": shared,
        "failures": failures,
    }
    out.write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"Q8_OOC_PRODUCTS_{evidence['status']} ip={len(generated)} shared={len(shared)} failures={len(failures)} report={out}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
