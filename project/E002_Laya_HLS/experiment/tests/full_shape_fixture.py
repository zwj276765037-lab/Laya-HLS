#!/usr/bin/env python3
"""Independent task-level S64/256/512/1024 fixtures, never full-network runs.

The real native enc0 QKV is an input only. For S>128 its final source row is
repeated into masked PAD positions; no native attention output is used.
"""

from __future__ import annotations

import json
import pathlib
import struct
import sys
import traceback

import numpy as np

from full_fixture_test import Evidence, sha
from full_forward_oracle import request_inputs
import full_reference as ref


SHAPES = (64, 256, 512, 1024)


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def save(directory: pathlib.Path, name: str, data: bytes,
         shape: list[int], role: str) -> dict:
    path = directory / name
    path.write_bytes(data)
    return {"path": str(path), "sha256": sha(data), "bytes": len(data),
            "shape": shape, "role": role}


def adapted_inputs(original: tuple[np.ndarray, ...], S: int
                   ) -> tuple[np.ndarray, ...]:
    source_ids, source_mask, source_marker, source_marker_mask, qtype = original
    ids = np.zeros((2, S), dtype="<i4")
    mask = np.zeros((2, S), dtype=np.uint8)
    copy = min(S, 128)
    ids[:, :copy] = source_ids[:, :copy]
    mask[:, :copy] = source_mask[:, :copy]
    markers = np.empty((2, 16), dtype="<i4")
    marker_mask = source_marker_mask.copy()
    for b in range(2):
        for col in range(16):
            local = int(source_marker[b, col]) - b * 128
            if not marker_mask[b, col]:
                markers[b, col] = b * S
            elif 0 <= local < S and mask[b, local]:
                markers[b, col] = b * S + local
            else:
                # S64 truncation: a valid candidate outside the short slice
                # resolves to that question's attended CLS position.
                require(mask[b, 0] == 1, "attended CLS for short marker")
                markers[b, col] = b * S
        require(mask[b].sum() > 0 and marker_mask[b].sum() > 0,
                "each adapted question remains valid")
    return ids, mask, markers, marker_mask, qtype


def abi_frame(frozen: bytes, tags: bytes, inputs: tuple[np.ndarray, ...],
              S: int) -> bytes:
    ids, mask, markers, marker_mask, qtype = inputs
    payloads = (ids.astype("<i4").tobytes(), mask.tobytes(),
                markers.astype("<i4").tobytes(), marker_mask.tobytes(),
                qtype.astype("<i4").tobytes())
    frame = bytearray(frozen[:320])
    frame[40:104] = tags
    struct.pack_into("<H", frame, 20, 2)
    struct.pack_into("<H", frame, 22, S)
    struct.pack_into("<Q", frame, 24, 1)
    offset = 320
    for index, payload in enumerate(payloads):
        dtype = 2 if index in (1, 3) else 1
        rank = 1 if index == 4 else 2
        dim1 = S if index < 2 else 1 if index == 4 else 16
        stride0 = (4 * S, S, 64, 16, 4)[index]
        stride1 = (4, 1, 4, 1, 0)[index]
        elements = 2 if index == 4 else 2 * (S if index < 2 else 16)
        struct.pack_into("<HBBIIHHIIII", frame, 128 + index * 32,
                         index + 1, dtype, rank, offset, len(payload),
                         2, dim1, stride0, stride1, elements, 0)
        require(len(frame) <= offset, "monotonic ABI directory")
        frame.extend(b"\0" * (offset - len(frame)))
        frame.extend(payload)
        frame.extend(b"\0" * ((-len(frame)) & 63))
        offset = len(frame)
    struct.pack_into("<I", frame, 16, len(frame))
    require(len(frame) <= 16384, "bounded adapted request")
    return bytes(frame)


def attention_expected(qkv: np.ndarray, mask: np.ndarray,
                       S: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    score = np.empty((2, 16, S), dtype="<f4")
    prob = np.empty_like(score)
    av = np.empty((2, 16, 64), dtype="<f4")
    head = 15
    for b in range(2):
        keys = qkv[b, :, 1024 + head * 64:1024 + (head + 1) * 64]
        values = qkv[b, :, 2048 + head * 64:2048 + (head + 1) * 64]
        for local in range(16):
            row = S - 16 + local
            query = qkv[b, row, head * 64:(head + 1) * 64]
            score[b, local] = ref.qk_row(query, keys, mask[b], S,
                                         row, False)
            prob[b, local] = ref.softmax_row(score[b, local], S)
            av[b, local] = ref.av_row(prob[b, local], values, S)
    return score, prob, av


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: full_shape_fixture.py ROOT PACKAGE OUTPUT_DIR",
              file=sys.stderr)
        return 2
    root, package, output = (pathlib.Path(arg).resolve()
                             for arg in sys.argv[1:])
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "GENERATING", "role": "independent_task_shape_oracle",
                    "shapes": {}, "not_full_network": True}
    evidence = None
    try:
        evidence = Evidence(root, output)
        original = request_inputs(evidence)
        raw = np.transpose(evidence.alias("enc0_qkv")[:, :, :, 0],
                           (2, 1, 0)).astype("<f4", copy=True)
        require(raw.shape == (2, 128, 3072) and np.isfinite(raw).all(),
                "frozen native QKV input shape and finite values")
        report["qkv_native_input"] = save(
            output, "raw_qkv_128.f32.bin", raw.tobytes(),
            [2, 128, 3072], "frozen_native_input_only")
        token_table = evidence.weight("tok_emb.weight")
        gamma = np.frombuffer(evidence.weight("emb_norm_w"), dtype="<f4")
        require(len(token_table) == 50368 * 1088 and gamma.size == 1024,
                "GGUF embedding and gamma source spans")
        frozen = (root / "reference/runs/typed_q8_ref_20261005/"
                  "abi_replay/request_v1.bin").read_bytes()
        tags = (package / "aux.bin").read_bytes()[32:96]
        require(len(tags) == 64, "model package identity tags")
        for S in SHAPES:
            directory = output / f"S{S}"
            directory.mkdir(parents=True, exist_ok=True)
            inputs = adapted_inputs(original, S)
            ids, mask, _, _, _ = inputs
            files = {}
            frame = abi_frame(frozen, tags, inputs, S)
            files["request"] = save(directory, "request.bin", frame,
                                     [len(frame)], "adapted_legal_B2_ABI_input")
            last_ids = ids[1, S - 16:S]
            front = np.stack([ref.embedding_row(
                token_table[int(token) * 1088:(int(token) + 1) * 1088])
                for token in last_ids]).astype("<f4")
            norm = ref.layernorm_many(front, gamma)
            activation = ref.quantize_rows(norm)
            files["front_raw"] = save(directory, "front_raw.f32.bin",
                                       front.tobytes(), [16, 1024],
                                       "independent_GGUF_embedding")
            files["front_norm"] = save(directory, "front_norm.f32.bin",
                                        norm.tobytes(), [16, 1024],
                                        "independent_GGUF_layernorm")
            files["front_quant"] = save(directory, "front_quant.q8.bin",
                                         activation, [16, 32, 34],
                                         "independent_GGUF_activation_Q8")
            qkv = (raw[:, :S].copy() if S <= 128 else
                   np.concatenate((raw, np.repeat(raw[:, -1:],
                                                  S - 128, axis=1)), axis=1))
            score, prob, av = attention_expected(qkv, mask, S)
            for key, value in (("score", score), ("prob", prob), ("av", av)):
                files[key] = save(directory, f"{key}.f32.bin",
                                  value.tobytes(), list(value.shape),
                                  "independent_head15_last16_oracle")
            report["shapes"][f"S{S}"] = {
                "B": 2, "S": S, "scope": "typed_tasks_and_addresses_only",
                "QKV_pad_rule": "repeat native row127 into masked PAD rows"
                                if S > 128 else "truncate native rows",
                "front_batch": 1, "front_rows": [S - 16, S - 1],
                "attention_head": 15, "attention_rows": [S - 16, S - 1],
                "files": files,
            }
            print(f"S{S}: independent task fixture generated", flush=True)
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
        (output / "full_shape_fixture_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
