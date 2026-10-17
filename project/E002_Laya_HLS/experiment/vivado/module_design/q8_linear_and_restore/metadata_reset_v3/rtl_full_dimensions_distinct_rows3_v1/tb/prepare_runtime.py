#!/usr/bin/env python3
"""Turn an approved, sealed Scorer fixture into XSim byte-array inputs.

Execution is downstream of the source-only review. This script verifies every
fixture file before it creates a fresh runtime directory.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import request_binding as binding

PORTS = ("descriptor", "w_q0", "w_q1", "w_scale", "aux",
         "activation", "out0", "out1", "observed")
COUNTS = (1, 128, 128, 16, 3, 16, 16, 1, 32)
PAGE = 4096


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def verified(root: Path, entry: dict) -> bytes:
    path = root / entry["relative_path"]
    raw = path.read_bytes()
    if len(raw) != entry["bytes"] or sha(raw) != entry["sha256"]:
        raise ValueError(f"fixture mismatch: {path}")
    return raw


def memh(path: Path, data: bytes) -> dict:
    with path.open("w") as stream:
        for value in data:
            stream.write(f"{value:02x}\n")
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": sha(path.read_bytes())}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("fixture", type=Path)
    ap.add_argument("snapshot", type=Path)
    ap.add_argument("fresh_output", type=Path)
    args = ap.parse_args()
    fixture = args.fixture.resolve()
    snapshot = args.snapshot.resolve()
    output = args.fresh_output.resolve()
    if output.exists() or not snapshot.is_dir() or not (snapshot / "xsim.dir").is_dir():
        raise ValueError("fresh output and completed static snapshot required")
    report_raw = (fixture / "fixture_report.json").read_bytes()
    report = json.loads(report_raw)
    if (report["schema"] != "q8_full_scorer_distinct_rows3_fixture_v1" or
        report["status"] != "INDEPENDENT_FULL_K_N_R0_AND_FROZEN_NODE_BIT_EXACT" or
        report["page_count"] != 341 or
        report["shape"] != {"B": 2, "S": 128, "batch": 1, "row0": 0,
                            "rows": 3, "K": 1024, "N": 1024, "G": 32,
                            "T": 128} or
        report["trace_row_local"] != 2 or report["trace_column"] != 8 or
        report["logical_work_per_run"] !=
        {"quant_groups": 96, "quant_inputs": 3072, "issued": 4096,
         "retired": 4096, "integer_macs": 3145728, "output_f32": 3072} or
        [c["name"] for c in report["commands"]] !=
        ["load_w", "run_trace_on", "run_trace_off"]):
        raise ValueError("fixture contract")
    gate = binding.load_gate()
    request = binding.request_identity(gate)
    selected = report["checkpoint_slices"]
    expected_slices = {row["name"]: row for row in gate["checkpoint_slices"]}
    if (report["frozen_request"] != request or
        selected["offset"] != 65536 or selected["bytes"] != 12288 or
        selected["input_row_sha256"] !=
            expected_slices["marker_norm.f32.bin"]["row_sha256"] or
        selected["frozen_output_row_sha256"] !=
            expected_slices["scorer_fc1_baked.f32.bin"]["row_sha256"] or
        selected["independent_output_row_sha256"] !=
            selected["frozen_output_row_sha256"] or
        len(set(selected["input_row_sha256"])) != 3 or
        len(set(selected["frozen_output_row_sha256"])) != 3):
        raise ValueError("frozen distinct valid-row binding")
    data = {}
    for port, count in zip(PORTS, COUNTS):
        entry = report["pages"][port]
        raw = verified(fixture, entry["image"])
        if len(raw) != count * PAGE or len(entry["offsets"]) != count:
            raise ValueError(f"page map size: {port}")
        for slot in range(count):
            if sha(raw[slot * PAGE:(slot + 1) * PAGE]) != entry["page_sha256"][slot]:
                raise ValueError(f"page mismatch: {port}/{slot}")
        data["init_" + port] = raw
    data["descriptor"] = b"".join(verified(fixture, c["descriptor"])
                                    for c in report["commands"])
    for key in ("observed", "out0", "out1"):
        data["expected_" + key] = b"".join(
            verified(fixture, c[key]) for c in report["commands"])
    if (len(data["descriptor"]) != 3 * PAGE or
        len(data["expected_observed"]) != 3 * 32 * PAGE or
        len(data["expected_out0"]) != 3 * 16 * PAGE or
        len(data["expected_out1"]) != 3 * PAGE):
        raise ValueError("command image sizes")
    output.mkdir(parents=True)
    files = {}
    for name, raw in data.items():
        files[name] = memh(output / f"{name}.memh", raw)
    (output / "xsim.dir").symlink_to(snapshot / "xsim.dir", target_is_directory=True)
    runtime = {"schema": "q8_full_scorer_distinct_rows3_runtime_input_v1",
               "fixture_report_sha256": sha(report_raw),
               "fixture_root": str(fixture),
               "snapshot": str(snapshot), "source_file_count": len(files),
               "files": files, "commands": [c["name"] for c in report["commands"]]}
    (output / "runtime_input.json").write_text(json.dumps(runtime, indent=2,
                                                           sort_keys=True) + "\n")
    print("Q8_SCORER_DISTINCT_ROWS3_RUNTIME_PREPARED commands=3 rows=3 pages=341")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
