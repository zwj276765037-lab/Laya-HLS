#!/usr/bin/env python3
"""Independent B2 attention inputs and exact F32 expectations for typed tasks.

The frozen native QKV is an *input* only. RoPE, score, probability, and AV
expectations are computed by full_reference from GGUF tables and ABI mask.
"""

from __future__ import annotations

import json
import pathlib
import sys
import traceback

import numpy as np

from full_fixture_test import Evidence, sha
from full_forward_oracle import request_inputs
import full_reference as ref


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def save(output: pathlib.Path, name: str, values: np.ndarray,
         dtype: str = "<f4") -> dict:
    array = np.asarray(values, dtype=dtype)
    data = array.tobytes(order="C")
    path = output / f"{name}.bin"
    path.write_bytes(data)
    return {"path": str(path), "shape": list(array.shape),
            "bytes": len(data), "sha256": sha(data), "dtype": dtype}


def expected_attention(qkv: np.ndarray, mask: np.ndarray, sliding: bool
                       ) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    # Fixed case order: head 0/1, batch 0/1, query tile 0/112.
    heads, batches, tiles, rows, S = 2, 2, 2, 16, 128
    score = np.empty((heads, batches, tiles, rows, S), dtype="<f4")
    prob = np.empty_like(score)
    av = np.empty((heads, batches, tiles, rows, 64), dtype="<f4")
    for head in range(heads):
        for batch in range(batches):
            keys = qkv[batch, :, 1024 + head * 64:1024 + (head + 1) * 64]
            values = qkv[batch, :, 2048 + head * 64:2048 + (head + 1) * 64]
            for tile, row0 in enumerate((0, 112)):
                for local in range(rows):
                    row = row0 + local
                    query = qkv[batch, row, head * 64:(head + 1) * 64]
                    score[head, batch, tile, local] = ref.qk_row(
                        query, keys, mask[batch], S, row, sliding)
                    prob[head, batch, tile, local] = ref.softmax_row(
                        score[head, batch, tile, local], S)
                    av[head, batch, tile, local] = ref.av_row(
                        prob[head, batch, tile, local], values, S)
    return score, prob, av


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: full_attention_fixture.py ROOT OUTPUT_DIR", file=sys.stderr)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    output = pathlib.Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "GENERATING",
                    "role": "independent_B2_RoPE_QK_softmax_AV",
                    "qkv_input_role": "frozen_native_enc0_qkv_input_only",
                    "case_order": {"heads": [0, 1], "batches": [0, 1],
                                   "query_row0": [0, 112], "rows": 16}}
    evidence = None
    try:
        evidence = Evidence(root, output)
        raw = np.transpose(evidence.alias("enc0_qkv")[:, :, :, 0],
                           (2, 1, 0)).astype("<f4", copy=True)
        _, mask, _, _, _ = request_inputs(evidence)
        require(raw.shape == (2, 128, 3072) and
                mask.shape == (2, 128) and np.isfinite(raw).all(),
                "frozen B2 source QKV and ABI mask")
        report["raw_qkv"] = save(output, "raw_qkv.f32", raw)
        report["attention_mask"] = save(output, "attention_mask.u8",
                                        mask, "u1")
        for mode, family in (("full", "full"), ("slide", "slide")):
            cosine = np.frombuffer(evidence.weight(f"cos_{family}"),
                                   dtype="<f4").reshape(1025, 64)[:128]
            sine = np.frombuffer(evidence.weight(f"sin_{family}"),
                                 dtype="<f4").reshape(1025, 64)[:128]
            rotated = ref.rope_qkv_many(raw, cosine, sine)
            require(np.array_equal(raw[..., 2048:].view("<u4"),
                                   rotated[..., 2048:].view("<u4")),
                    "V plane is bitwise preserved")
            score, prob, av = expected_attention(rotated, mask,
                                                 mode == "slide")
            report[mode] = {
                "layer": 0 if mode == "full" else 1,
                "cosine": save(output, f"{mode}_cosine.f32", cosine),
                "sine": save(output, f"{mode}_sine.f32", sine),
                "final_qkv": save(output, f"{mode}_final_qkv.f32", rotated),
                "score": save(output, f"{mode}_score.f32", score),
                "probability": save(output, f"{mode}_probability.f32", prob),
                "av": save(output, f"{mode}_av.f32", av),
            }
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
            evidence.model.close()
            report["checked_reference_files"] = evidence.checked
        (output / "full_attention_fixture_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
