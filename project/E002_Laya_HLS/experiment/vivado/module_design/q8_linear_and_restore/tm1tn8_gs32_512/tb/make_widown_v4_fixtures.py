#!/usr/bin/env python3
"""Build four-row, full-K/N independent Wi/Down gold from v4 producer BOs.

The input activation is captured from the current CPU/CSim producer. Q8
quantization, all group dot/R0 steps and final F32 are recomputed from that
input and the GGUF, then cross-checked with tests/full_reference.py. This is
fixture generation, not a Wi/Down RTL or complete TM4 comparison.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys

import numpy as np

from make_real_fixtures import bo_weights, digest, model_record, oracle, require, write


V4_MANIFEST_SHA = "093bd662096f8c539529072d09d33f3b5a7f666125e21adaaf7ece20348c5915"
MODEL_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        while block := stream.read(8 << 20):
            h.update(block)
    return h.hexdigest()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    ap.add_argument("capture_attempt", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    root = args.root.resolve()
    capture_attempt = args.capture_attempt.resolve()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    package = root / "build/model-cpu-embedding-ln-v4-20261010"
    package_manifest = package / "manifest.json"
    require(sha(package_manifest) == V4_MANIFEST_SHA, "current v4 manifest SHA")
    package_data = json.loads(package_manifest.read_text())
    require(package_data["source_model"]["sha256"] == MODEL_SHA and
            package_data["tags"]["build"] == "147c8e8554927239ed5981bdde25861c",
            "v4 model/build identity")
    guard_dir = capture_attempt / "guard"
    if not guard_dir.is_dir():
        guard_dir = capture_attempt / "run_guard"
    guard_file = guard_dir / "guard_result.json"
    log_file = guard_dir / "driver.log"
    source_manifest = capture_attempt / "work/generated/source_manifest.json"
    guard = json.loads(guard_file.read_text())
    log = log_file.read_text()
    require(guard["child_exit_code"] == 0 and guard["trigger"] is None and
            "PERSISTENT_CPU_FULL_CSIM_PASS requests=4 normal=3" in log,
            "current producer run guard and 47-checkpoint comparison")
    for label, width in (("t2_enc0_ln_ffn_source", 1024),
                         ("t2_enc0_geglu_source", 2624)):
        require(f"T2_PRODUCER_CAPTURE name={label} request=3 generation=1 rows=128 width={width}" in log,
                f"current request3 producer capture {label}")
    require("T2_PRODUCER_CAPTURE name=t2_enc0_v_head0_source request=3 generation=1 rows=128 width=64 plane=V head=0" in log,
            "current request3 V producer capture")
    prepared = json.loads(source_manifest.read_text())
    require(prepared["schema"] == "t2_widown_av_observation_sources_v2",
            "observation source manifest")
    for path, wanted in prepared["original_sources"].items():
        require(sha(Path(path)) == wanted, "producer original source identity")
    for path, wanted in prepared["generated_sources"].items():
        require(sha(Path(path)) == wanted, "producer generated source identity")
    v_capture = capture_attempt / "work/capture/t2_enc0_v_head0_source.f32.bin"
    require(v_capture.stat().st_size == 128 * 64 * 4,
            "full current producer V head0 shape")

    sys.path.insert(0, str(root / "tests"))
    from full_fixture_test import Evidence
    import full_reference as reference
    evidence = Evidence(root, out)
    header = package / "laya_model_layout_generated.h"
    cases = (("wi_rows4", "t2_enc0_ln_ffn_source", "mlp_wi.0.weight", 1024, 5248),
             ("down_rows4", "t2_enc0_geglu_source", "mlp_wo.0.weight", 2624, 1024))
    outputs = []
    try:
        for name, source_label, weight_name, K, N in cases:
            capture = capture_attempt / "work/capture" / (source_label + ".f32.bin")
            require(capture.stat().st_size == 128 * K * 4,
                    f"full current producer source shape {name}")
            with capture.open("rb") as stream:
                source = stream.read(4 * K * 4)
            require(len(source) == 4 * K * 4 and
                    np.isfinite(np.frombuffer(source, dtype="<f4")).all(),
                    f"first four producer rows finite {name}")
            record = model_record(header, weight_name)
            require((record["K"], record["N"], record["dtype"]) == (K, N, 8),
                    f"current package matrix identity {name}")
            weight = evidence.weight(weight_name)
            q0, q1, scale, bias = bo_weights(package, record, weight)
            require(not bias, f"unexpected layer-0 Q8 bias {name}")
            aq_q, aq_scale, steps, final, aq_bytes = oracle(
                reference, source, weight, bias, 4, K, N)
            second, _ = reference.q8_linear_full(aq_bytes, weight, 4, K, N,
                                                  None)
            require(second.tobytes() == final,
                    f"independent full_reference final cross-check {name}")
            products = {role: write(out, name + "_" + role + ".bin", data)
                        for role, data in (("source_f32", source),
                                           ("a8_q", aq_q),
                                           ("a8_scale", aq_scale),
                                           ("steps_u32x6", steps),
                                           ("output_f32", final),
                                           ("w_q0", q0), ("w_q1", q1),
                                           ("w_scale", scale))}
            outputs.append({"name": name, "rows": 4, "row0": 0, "batch": 0,
                            "K": K, "N": N, "G": K // 32,
                            "T": (N + 7) // 8,
                            "valid_macs": 4 * K * N,
                            "group_records": 4 * (K // 32) * N,
                            "weight_name": weight_name,
                            "model_record": record,
                            "actual_producer_full_source": digest(capture),
                            "products": products,
                            "status": "GENERATED_NO_WIDOWN_DUT_COMPARISON"})
    finally:
        evidence.model.close()
    result = {"schema": "t2_widown_v4_b1_four_row_fixtures_v1",
              "status": "GENERATED_NO_WIDOWN_DUT_COMPARISON",
              "session": {"request_id": 3, "generation": 1, "B": 1, "S": 128},
              "capture_guard": digest(guard_file),
              "capture_log": digest(log_file),
              "capture_source_manifest": digest(source_manifest),
              "v_head0_source": digest(v_capture),
              "model_manifest": digest(package_manifest),
              "layout_header": digest(header),
              "independent_reference": digest(root / "tests/full_reference.py"),
              "generator": digest(Path(__file__)),
              "cases": outputs,
              "limitation": "Actual producer source and independent gold only; no TM4/full Wi/Down RTL execution"}
    (out / "manifest.json").write_text(json.dumps(result, indent=2,
                                                  sort_keys=True) + "\n")
    print("T2_WIDOWN_V4_FIXTURES_GENERATED cases=2 rows=4 full_K_N=1")


if __name__ == "__main__":
    main()
