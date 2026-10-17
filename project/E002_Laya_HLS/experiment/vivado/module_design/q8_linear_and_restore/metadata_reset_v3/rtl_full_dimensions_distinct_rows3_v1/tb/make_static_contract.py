#!/usr/bin/env python3
"""Read-only identity/address arithmetic for three real valid Scorer rows.

This never imports the numerical reference, builds a fixture, or runs a DUT.
The only output is a static JSON record at the caller's fresh path.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys
import request_binding as binding

ROOT = Path(__file__).resolve().parents[6]
MODULE = ROOT / "vivado/module_design/q8_linear_and_restore/metadata_reset_v3"
MODEL = ROOT / "build/model-attention-rtl-repair-20261008"
CPU = ROOT / "results/engineering_p2/full_cpu_final_20261007"
CONTRACT = binding.GATE
V6 = MODULE / "rtl_full_dimensions_v1/source_binding_v6/source_packet.json"
PRIOR_STATIC = MODULE / "rtl_full_dimensions_rows3_v1/source/static_contract.json"
PAGE = 4096
ROWS, ROW0, BATCH, K, N, G, T = 3, 0, 1, 1024, 1024, 32, 128
TRACE_ROW, TRACE_COLUMN = 2, 8
CHECKPOINT_SHA = {
    "marker_norm.f32.bin": "969cf212034ccf7a5d6bb785e59ccbfce84cbd2fa9233591f506176076f7c10a",
    "scorer_fc1_baked.f32.bin": "d28bd65f45910d32ff3de4cea1fcdc583b2cff8635b95bd03677e855b5d9f14f",
}
BASE = {name: (0x10 + i) << 32 for i, name in enumerate(
    ("descriptor", "w_q0", "w_q1", "w_scale", "aux", "activation",
     "out0", "out1", "observed"))}


def need(ok: bool, why: str) -> None:
    if not ok:
        raise ValueError(why)


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def rec(path: Path, raw: bytes | None = None) -> dict:
    if raw is None:
        raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw), "sha256": sha(raw)}


def exact(path: Path, size: int, digest: str) -> bytes:
    raw = path.read_bytes()
    need(len(raw) == size and sha(raw) == digest, f"identity: {path}")
    return raw


def bo_span(model: dict, name: str, offset: int, size: int) -> dict:
    entry = model["bo"][name]
    path = MODEL / entry["file"]
    need(path.stat().st_size == entry["size"], f"BO size: {name}")
    with path.open("rb") as stream:
        stream.seek(offset)
        raw = stream.read(size)
    need(len(raw) == size, f"BO span: {name}")
    return {"source_path": str(path), "full_file_bytes": entry["size"],
            "full_file_sha256_from_manifest": entry["sha256"],
            "offset": offset, "bytes": size, "sha256": sha(raw)}


def main() -> int:
    need(len(sys.argv) == 2, "usage: make_static_contract.py FRESH_JSON")
    out = Path(sys.argv[1]).resolve()
    need(not out.exists(), "static JSON output must be fresh")
    prior = exact(V6, 327450,
                  "872b13e1efa71cff1aee87873b918d4e595d8046caf6ec4da9cc9917a3a91611")
    need(json.loads(prior)["counts"]["physical_pages"] == 341, "V6 page map")
    contract_raw = CONTRACT.read_bytes()
    gate = binding.load_gate()
    prior_static = exact(PRIOR_STATIC, 23056,
                         "7270c08d4a2c360b708ed1fe08bf164099f8be94ae382d3f1f9023247d1cee4c")
    need(gate["shape"] == {"B": 2, "S": 128, "batch": BATCH,
                          "row0": ROW0, "rows": ROWS, "K": K, "N": N,
                          "G": G, "T": T, "family": 9, "layer": 255} and
         gate["trace"] == {"row_local": TRACE_ROW, "column": TRACE_COLUMN} and
         gate["tm4"] == {"tiles": 1, "active_lanes": [0, 1, 2],
                          "inactive_tail_lane": 3} and
         gate["physical_page_count"] == 341,
         "reviewed distinct valid-row window")
    work = {"quant_groups": ROWS * G, "activation_bytes": ROWS * K * 4,
            "logical_MAC": ROWS * K * N,
            "issued_and_retired_groups": ((ROWS + 3) // 4) * G * T,
            "valid_final_f32": ROWS * N, "output_bytes": ROWS * N * 4,
            "trace_payload_bytes_when_enabled": ROWS * K + ROWS * G * 2 + G * 32}
    need(work == json.loads(prior_static)["work_per_run"],
         "inherited work arithmetic")
    off = (BATCH * 16 + ROW0) * K * 4
    need(off == 65536 and off + work["activation_bytes"] == 77824,
         "checkpoint source bounds")
    manifest_raw = exact(MODEL / "manifest.json", 147765,
                         "128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa")
    model = json.loads(manifest_raw)
    request = binding.request_identity(gate, model["tags"])
    checkpoints = []
    for name, digest in CHECKPOINT_SHA.items():
        pair = []
        for family, directory in (("oracle", CPU / "oracle/B2_S128"),
                                  ("dut", CPU / "dut/dut/B2_S128")):
            path = directory / name
            raw = exact(path, 131072, digest)
            chunk = raw[off:off + ROWS * PAGE]
            pair.append(raw)
            checkpoints.append({"family": family, "name": name,
                                "source": rec(path, raw), "offset": off,
                                "bytes": len(chunk), "sha256": sha(chunk),
                                "row_sha256": [sha(chunk[i*PAGE:(i+1)*PAGE])
                                               for i in range(ROWS)]})
        need(pair[0] == pair[1], f"frozen oracle/DUT slice: {name}")
        selected, selection = binding.checkpoint_slice(gate, name, pair[0], pair[1])
        need(selected == chunk and selection["row_sha256"] ==
             checkpoints[-1]["row_sha256"], f"frozen selected row identity: {name}")
    weight = next(w for w in model["weights"] if w["family"] == 9 and w["layer"] == 255)
    need((weight["name"], weight["K"], weight["N"], weight["q_span"],
          weight["scale_span"], weight["bias_span"]) ==
         ("scorer_fc1.weight", K, N, [524288, 524288], 65536, PAGE),
         "real complete scorer matrix")
    bo_slices = [bo_span(model, "w_q0", weight["q_base"][0], 524288),
                 bo_span(model, "w_q1", weight["q_base"][1], 524288),
                 bo_span(model, "w_scale", weight["scale_base"], 65536),
                 bo_span(model, "aux", 0, 128),
                 bo_span(model, "aux", weight["bias_base"], PAGE)]
    pages = {
        "descriptor": [0],
        "w_q0": [weight["q_base"][0] + i*PAGE for i in range(128)],
        "w_q1": [weight["q_base"][1] + i*PAGE for i in range(128)],
        "w_scale": [weight["scale_base"] + i*PAGE for i in range(16)],
        "aux": [0, (weight["bias_base"] // PAGE)*PAGE,
                ((weight["bias_base"] // PAGE)+1)*PAGE],
        "activation": [i*PAGE for i in range(16)],
        "out0": [i*PAGE for i in range(16)],
        "out1": [0], "observed": [i*PAGE for i in range(32)]}
    need(sum(map(len, pages.values())) == 341, "physical page count")
    need(weight["bias_base"] == 1667776 and model["bo"]["aux"]["size"] == 1671872,
         "AUX straddles final physical page")
    need(pages == {name: item["logical_offsets"] for name, item in
                   json.loads(prior_static)["physical_pages"].items()},
         "inherited 341-page physical map")
    output = {"schema": "q8_full_scorer_distinct_rows3_static_contract_v1",
              "status": "READ_ONLY_ADDRESS_COUNT_AND_CHECKPOINT_IDENTITY_NO_NUMERICAL_ORACLE",
              "authority": rec(CONTRACT, contract_raw), "inherited_v6": rec(V6, prior),
              "inherited_rows3_static": rec(PRIOR_STATIC, prior_static),
              "frozen_request": request,
              "model_manifest": rec(MODEL / "manifest.json", manifest_raw),
              "weight": weight, "shape": {"B": 2, "S": 128, "batch": BATCH,
                  "row0": ROW0, "rows": ROWS, "K": K, "N": N, "G": G, "T": T},
              "trace": {"row_local": TRACE_ROW, "column": TRACE_COLUMN,
                        "q_offset": 1024, "q_bytes": ROWS*K,
                        "scale_offset": 66560, "scale_bytes": ROWS*G*2,
                        "group_offset": 70656, "group_bytes": G*32,
                        "observed_valid_bytes": 1024 + work["trace_payload_bytes_when_enabled"]},
              "work_per_run": work, "tm4": {"tiles": 1, "valid_lanes": 3,
                                             "inactive_tail_lanes": 1},
              "checkpoint_source_interval": [off, off + ROWS*PAGE],
              "checkpoints": checkpoints, "bo_slices": bo_slices,
              "physical_pages": {name: {"count": len(offsets),
                                         "base": BASE[name],
                                         "logical_offsets": offsets,
                                         "physical_addresses": [BASE[name]+x for x in offsets]}
                                 for name, offsets in pages.items()},
              "page_count": 341, "page_bytes": 341*PAGE,
              "run_touched_ranges": {
                  "activation": [[0, ROWS*PAGE]], "out0": [[0, ROWS*PAGE]],
                  "observed_trace_on": [[0, 1024+ROWS*K],
                                        [66560, 66560+ROWS*G*2],
                                        [70656, 70656+G*32]],
                  "observed_trace_off": [[0, 1024]]},
              "selected_row_sha256": {
                  item["name"]: item["row_sha256"] for item in checkpoints
                  if item["family"] == "oracle"}}
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(output, indent=2, sort_keys=True) + "\n")
    print(f"Q8_SCORER_DISTINCT_ROWS3_STATIC_CONTRACT_PASS pages=341 offset={off} work={work['logical_MAC']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
