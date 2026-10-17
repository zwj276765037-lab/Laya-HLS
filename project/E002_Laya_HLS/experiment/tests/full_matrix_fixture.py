#!/usr/bin/env python3
"""Generate independent real full-N Q8-F R0 candidates for P2 B testing.

This file only derives expected values from the immutable GGUF and captured
*inputs*. Its JSON says GENERATED, never DUT PASS. A separate B runtime test
must feed these same inputs to the real loader/task path and compare outputs.
"""

from __future__ import annotations

import json
import pathlib
import sys
import traceback

import numpy as np

from full_fixture_test import Evidence, f32_bytes, native_metrics, sha
import full_reference as ref


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def source_rows(e: Evidence, source: str, batch: int, row0: int,
                rows: int, K: int) -> np.ndarray:
    if source == "enc0_attention_fused":
        tensor = e.alias(source)
        require(K == 1024 and tensor.shape[:3] == (64, 16, 128),
                "native attention source shape")
        return np.stack([np.concatenate([tensor[:, head, row, batch]
                                         for head in range(16)])
                         for row in range(row0, row0 + rows)]).astype("<f4")
    if source == "scorer_norm":
        tensor = e.alias(source)
        require(K == 1024, "scorer source K")
        return np.stack([tensor[:, row, batch, 0] for row in
                         range(row0, row0 + rows)]).astype("<f4")
    if source == "act_gelu":
        tensor = e.alias(source)
        require(K == 256 and row0 == 0 and rows == 1, "act source shape")
        return tensor[:, batch, 0, 0][None, :].astype("<f4")
    if source.startswith("ir_"):
        tensor = e.node(source)
        require(K <= tensor.shape[0], "node source K")
        return np.stack([tensor[:K, row, batch, 0] for row in
                         range(row0, row0 + rows)]).astype("<f4")
    return np.stack([e.token_row(source, batch, row, K)
                     for row in range(row0, row0 + rows)]).astype("<f4")


def native_rows(e: Evidence, name: str, batch: int, row0: int,
                rows: int, N: int) -> np.ndarray:
    if name.startswith("ir_"):
        tensor = e.node(name)
    else:
        tensor = e.alias(name)
    require(tensor.shape[0] >= N and row0 + rows <= tensor.shape[1],
            "native output diagnostic shape")
    return np.stack([tensor[:N, row, batch, 0] for row in
                     range(row0, row0 + rows)]).astype("<f4")


def cases() -> list[dict]:
    return [
        {"name": "qkv_full_b0", "source": "embedding_norm", "batch": 0,
         "row0": 0, "rows": 16, "K": 1024, "N": 3072,
         "weight": "qkv.0.weight", "family": 1, "layer": 0,
         "native": "enc0_qkv"},
        {"name": "wo_full_b1", "source": "enc0_attention_fused", "batch": 1,
         "row0": 112, "rows": 16, "K": 1024, "N": 1024,
         "weight": "wo.0.weight", "family": 2, "layer": 0,
         "native": "enc0_attention_project"},
        {"name": "wi_full_b0", "source": "enc0_mlp_norm", "batch": 0,
         "row0": 0, "rows": 16, "K": 1024, "N": 5248,
         "weight": "mlp_wi.0.weight", "family": 3, "layer": 0,
         "native": "ir_269"},
        {"name": "down_full_b1", "source": "enc0_gated_product", "batch": 1,
         "row0": 112, "rows": 16, "K": 2624, "N": 1024,
         "weight": "mlp_wo.0.weight", "family": 4, "layer": 0,
         "native": "ir_274"},
        {"name": "decision_qkv_full_b0", "source": "ir_1414", "batch": 0,
         "row0": 0, "rows": 16, "K": 1024, "N": 3072,
         "weight": "head_qkv.0.weight", "bias": "head_qkv.0.bias",
         "family": 5, "layer": 0, "native": "ir_1415"},
        {"name": "decision_wo_full_b1", "source": "ir_1427", "batch": 1,
         "row0": 112, "rows": 16, "K": 1024, "N": 1024,
         "weight": "head_wo.0.weight", "bias": "head_wo.0.bias",
         "family": 6, "layer": 0, "native": "ir_1428"},
        {"name": "decision_fc1_full_b0", "source": "ir_1430", "batch": 0,
         "row0": 0, "rows": 16, "K": 1024, "N": 4096,
         "weight": "head_fc1.0.weight", "bias": "head_fc1.0.bias",
         "family": 7, "layer": 0, "native": "ir_1431"},
        {"name": "decision_fc2_full_b1", "source": "ir_1432", "batch": 1,
         "row0": 112, "rows": 16, "K": 4096, "N": 1024,
         "weight": "head_fc2.0.weight", "bias": "head_fc2.0.bias",
         "family": 8, "layer": 0, "native": "ir_1433"},
        {"name": "scorer_fc1_full_b1", "source": "scorer_norm", "batch": 1,
         "row0": 0, "rows": 16, "K": 1024, "N": 1024,
         "weight": "scorer_fc1.weight", "bias": "linear_120_baked_bias",
         "family": 9, "layer": 255, "native": "scorer_fc1_with_bias"},
        {"name": "act_fc2_n2_b0", "source": "act_gelu", "batch": 0,
         "row0": 0, "rows": 1, "K": 256, "N": 2,
         "weight": "act_fc2.weight", "bias": "act_fc2.bias",
         "family": 12, "layer": 255, "native": "act_raw_logits"},
    ]


def generate(e: Evidence, output: pathlib.Path) -> list[dict]:
    generated = []
    for case in cases():
        name, K, N, rows = case["name"], case["K"], case["N"], case["rows"]
        input_rows = source_rows(e, case["source"], case["batch"],
                                 case["row0"], rows, K)
        activation = ref.quantize_rows(input_rows)
        weight_entry = e.weights[case["weight"]]
        require(weight_entry["ggml_type_id"] == 8 and
                weight_entry["ggml_ne"][:2] == [K, N],
                f"{name} GGUF matrix identity")
        weights = e.weight(case["weight"])
        bias = None
        if case.get("bias"):
            raw_bias = e.weight(case["bias"])
            bias = np.frombuffer(raw_bias, dtype="<f4")
            require(bias.size == N, "Q8 Linear bias length")
        expected, trace = ref.q8_linear_full(activation, weights,
                                              rows, K, N, bias, trace=(0, 0))
        native = native_rows(e, case["native"], case["batch"],
                             case["row0"], rows, N)
        files = {
            "source_f32": f32_bytes(input_rows),
            "activation_q8": activation,
            "weight_source_q8": weights,
            "bias_f32": b"" if bias is None else f32_bytes(bias),
            "expected_f32": f32_bytes(expected),
        }
        identities = {}
        for role, data in files.items():
            path = output / f"{name}.{role}.bin"
            path.write_bytes(data)
            identities[role] = {"path": str(path), "bytes": len(data),
                                "sha256": sha(data)}
        generated.append({**case, "files": identities,
                          "trace_row0_col0": [{"group": group, "dot": dot,
                                               "term_bits": term,
                                               "partial_bits": partial}
                                              for group, (dot, term, partial)
                                              in enumerate(trace)],
                          "native_diagnostic_only": native_metrics(expected, native),
                          "oracle_status": "GENERATED_NO_DUT_COMPARISON"})
    return generated


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: full_matrix_fixture.py PROJECT_ROOT OUTPUT_DIRECTORY",
              file=sys.stderr)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    output = pathlib.Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "GENERATING", "role": "independent_B_oracle_fixture",
                    "native_role": "diagnostic_only"}
    evidence = None
    try:
        evidence = Evidence(root, output)
        report["cases"] = generate(evidence, output)
        report["case_count"] = len(report["cases"])
        report["status"] = "GENERATED_NO_DUT_COMPARISON"
        return 0
    except Exception as exc:
        report["status"] = "FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
        return 1
    finally:
        if evidence is not None:
            report["checked_reference_files"] = evidence.checked
            evidence.model.close()
        (output / "full_matrix_fixture_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
