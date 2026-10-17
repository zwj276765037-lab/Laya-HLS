#!/usr/bin/env python3
"""Build the first real ACT K256/N2 joint fixture and independent R0 oracle.

Usage: generate_joint_fixture.py PROJECT_ROOT OUTPUT_DIR
The frozen GGUF and accepted full-CPU checkpoints are read-only inputs.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import struct
import sys

import numpy as np


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def source(path: Path) -> dict:
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data), "sha256": sha(data)}


def fbits(value: object) -> int:
    return struct.unpack("<I", struct.pack("<f", float(value)))[0]


def save(output: Path, name: str, data: bytes) -> dict:
    path = output / name
    path.write_bytes(data)
    return source(path)


def bo_window(path: Path, base: int, length: int) -> bytes:
    require(base >= 0 and length >= 0 and base + length <= path.stat().st_size,
            f"{path.name} slice bounds")
    with path.open("rb") as stream:
        stream.seek(base)
        data = stream.read(length)
    require(len(data) == length, f"{path.name} short read")
    return data


def oracle_trace(reference, activation: bytes, weight: bytes,
                 bias: bytes) -> tuple[bytes, list[dict]]:
    groups = 8
    aq = np.frombuffer(activation, dtype=reference.Q8_DTYPE).reshape(groups)
    wq = np.frombuffer(weight, dtype=reference.Q8_DTYPE).reshape(2, groups)
    bias_f32 = np.frombuffer(bias, dtype="<f4")
    require(bias_f32.shape == (2,), "ACT bias shape")
    outputs = np.empty(2, dtype="<f4")
    traces = []
    for column in range(2):
        acc = reference.F32(0)
        groups_out = []
        for group in range(groups):
            dot = 0
            for k in range(32):
                dot += int(aq["q"][group, k]) * int(wq["q"][column, group, k])
            sa = reference.F32(aq["scale"][group])
            sw = reference.F32(wq["scale"][column, group])
            require(np.isfinite(sa) and np.isfinite(sw) and sa >= 0 and sw >= 0,
                    "ACT scale domain")
            product = reference.mul(sa, sw)
            term = reference.mul(reference.F32(dot), product)
            acc = reference.add(acc, term)
            require(np.isfinite(product) and np.isfinite(term) and np.isfinite(acc),
                    "ACT group finite")
            groups_out.append({"group": group, "dot_i32": dot,
                               "sa_f32_bits": fbits(sa),
                               "sw_f32_bits": fbits(sw),
                               "product_f32_bits": fbits(product),
                               "term_f32_bits": fbits(term),
                               "ps_f32_bits": fbits(acc)})
        acc = reference.add(acc, bias_f32[column])
        require(np.isfinite(acc), "ACT final finite")
        outputs[column] = acc
        traces.append({"column": column, "bias_f32_bits": fbits(bias_f32[column]),
                       "final_f32_bits": fbits(acc), "groups": groups_out})
    return outputs.tobytes(), traces


def main() -> int:
    require(len(sys.argv) == 3, "usage: generate_joint_fixture.py ROOT OUTPUT_DIR")
    root = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    sys.path.insert(0, str(root / "tests"))
    from full_fixture_test import Evidence  # frozen GGUF inventory and SHA checks
    import full_reference as reference  # independent R0 numeric implementation

    accepted = root / "results/engineering_p2/full_cpu_final_20261007"
    oracle_dir = accepted / "oracle/B2_S128"
    dut_dir = accepted / "dut/dut/B2_S128"
    model_dir = root / "build/model-attention-rtl-repair-20261008"
    report_dir = output / "gguf_access_evidence"
    report_dir.mkdir(exist_ok=True)
    evidence = Evidence(root, report_dir)
    gguf_q8 = evidence.weight("act_fc2.weight")
    gguf_bias = evidence.weight("act_fc2.bias")
    require(len(gguf_q8) == 2 * 8 * 34 and len(gguf_bias) == 8,
            "frozen GGUF ACT K/N/weight span")

    # These offsets and byte counts are the frozen full_lookup_weight record
    # for WeightKey {family=12, layer=255}; no model BO is re-packed here.
    q0_base, q0_span = 184680448, 2048
    scale_base, scale_span = 23085056, 128
    bias_base, bias_span = 617664, 8
    q0 = bo_window(model_dir / "w_q0.bin", q0_base, q0_span)
    scales = bo_window(model_dir / "w_scale.bin", scale_base, scale_span)
    bias = bo_window(model_dir / "aux.bin", bias_base, bias_span)
    require(bias == gguf_bias, "ACT BO/GGUF bias byte identity")
    for column in range(2):
        for group in range(8):
            gguf_block = gguf_q8[(column * 8 + group) * 34:
                                 (column * 8 + group + 1) * 34]
            q_offset = (group * 8 + column) * 32
            s_offset = (group * 8 + column) * 2
            require(q0[q_offset:q_offset + 32] == gguf_block[2:],
                    f"ACT BO/GGUF q column={column} group={group}")
            require(scales[s_offset:s_offset + 2] == gguf_block[:2],
                    f"ACT BO/GGUF scale column={column} group={group}")

    act_hidden_path = oracle_dir / "act_hidden.f32.bin"
    act_logits_path = oracle_dir / "act_logits.f32.bin"
    hidden = act_hidden_path.read_bytes()
    logits = act_logits_path.read_bytes()
    require(hidden == (dut_dir / act_hidden_path.name).read_bytes(),
            "accepted CPU act_hidden/oracle identity")
    require(logits == (dut_dir / act_logits_path.name).read_bytes(),
            "accepted CPU act_logits/oracle identity")
    require(len(hidden) == 2 * 256 * 4 and len(logits) == 2 * 2 * 4,
            "ACT checkpoint shapes")

    products = {"q0": save(output, "act_w_q0_2048.bin", q0),
                "scale": save(output, "act_w_scale_128.bin", scales),
                "bias": save(output, "act_bias_8.bin", bias),
                "gguf_q8": save(output, "act_gguf_q8_544.bin", gguf_q8)}
    runs = []
    for batch in range(2):
        input_bytes = hidden[batch * 1024:(batch + 1) * 1024]
        values = np.frombuffer(input_bytes, dtype="<f4").reshape(1, 256)
        require(np.isfinite(values).all(), f"ACT batch {batch} input finite")
        packed = reference.quantize_rows(values)
        require(len(packed) == 8 * 34, "ACT 8 Q8 groups")
        row_q = b"".join(packed[group * 34 + 2:(group + 1) * 34]
                         for group in range(8))
        row_scales = b"".join(packed[group * 34:group * 34 + 2]
                              for group in range(8))
        expected, traces = oracle_trace(reference, packed, gguf_q8, gguf_bias)
        normal, normal_trace = reference.q8_linear_full(
            packed, gguf_q8, 1, 256, 2,
            np.frombuffer(gguf_bias, dtype="<f4"), trace=(0, batch))
        require(expected == normal.tobytes(), f"ACT batch {batch} oracle cross-check")
        selected = traces[batch]
        require([(g["dot_i32"], g["term_f32_bits"], g["ps_f32_bits"])
                 for g in selected["groups"]] == normal_trace,
                f"ACT batch {batch} selected trace cross-check")
        require(expected == logits[batch * 8:(batch + 1) * 8],
                f"ACT batch {batch} accepted full CPU output")
        runs.append({"batch": batch, "input": save(output, f"act_b{batch}_input_1024.bin", input_bytes),
                     "q": save(output, f"act_b{batch}_a8_q_256.bin", row_q),
                     "scale": save(output, f"act_b{batch}_a8_scale_16.bin", row_scales),
                     "expected": save(output, f"act_b{batch}_expected_8.bin", expected),
                     "trace_column": batch, "traces": traces,
                     "groups": 8, "valid_dot_lanes_per_issue": 2,
                     "group_issue_slots": 8})

    header = model_dir / "laya_model_layout_generated.h"
    header_text = header.read_text()
    require('"act_fc2.weight", {12, 255}, 256, 2, 8, 1, '
            '{184680448, 0}, {2048, 0}, 23085056, 128, '
            '0, 0, 617664, 8' in header_text,
            "frozen generated ACT descriptor")
    report = {"schema": "q8_joint_act_k256_n2_fixture_v1",
              "status": "INDEPENDENT_R0_AND_ACCEPTED_CPU_BIT_EXACT",
              "weight_key": {"family": 12, "layer": 255},
              "shape": {"K": 256, "N": 2, "rows_per_run": 1, "B": 2, "S": 128},
              "bo_offsets": {"q0": q0_base, "q1": 0, "scale": scale_base,
                             "bias": bias_base},
              "bo_spans": {"q0": q0_span, "q1": 0, "scale": scale_span,
                           "bias": bias_span},
              "inputs": [source(act_hidden_path), source(act_logits_path),
                         source(dut_dir / act_hidden_path.name),
                         source(dut_dir / act_logits_path.name),
                         source(header), source(model_dir / "w_q0.bin"),
                         source(model_dir / "w_scale.bin"),
                         source(model_dir / "aux.bin")],
              "gguf_source": evidence.checked,
              "products": products, "runs": runs,
              "logical_work": {"q0_bytes": 2048, "q1_bytes": 0,
                               "scale_bytes": 128, "bias_bytes": 8,
                               "activation_bytes_per_run": 1024,
                               "output_bytes_per_run": 8, "macs_per_run": 512,
                               "physical_dot_lanes_per_issue": 32}}
    (output / "fixture_report.json").write_text(json.dumps(report, indent=2,
                                                           sort_keys=True) + "\n")
    print("Q8_JOINT_ACT_FIXTURE_PASS batches=2 K=256 N=2 groups=8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
