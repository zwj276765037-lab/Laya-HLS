#!/usr/bin/env python3
"""Capture enc0 LN_FFN input/output from the unmodified independent graph."""

from __future__ import annotations

import hashlib
import json
import pathlib
import platform
import struct
import sys
import time
import traceback

import numpy as np

from full_fixture_test import Evidence, file_sha
from full_forward_oracle import configure_libm, request_inputs, single_request
import full_reference as ref


REFERENCE_SHA = "fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784"
CAPTURE_SHA = "6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863"
SOURCE4_SHA = "658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883"
Q4_SHA = "839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34"
SCALE4_SHA = "4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f"


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def identity(path: pathlib.Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": file_sha(path)}


def compare(actual: bytes, expected: bytes, word_bytes: int) -> dict:
    require(len(actual) == len(expected), "comparison byte length")
    require(len(actual) % word_bytes == 0, "comparison word length")
    a = np.frombuffer(actual, dtype=f"<u{word_bytes}")
    b = np.frombuffer(expected, dtype=f"<u{word_bytes}")
    difference = np.flatnonzero(a != b)
    first = int(difference[0]) if difference.size else None
    return {"word_bytes": word_bytes, "elements": len(a),
            "bit_diff_count": int(difference.size), "first_bit_diff_index": first,
            "first_actual_bits": (f"{int(a[first]):0{word_bytes * 2}x}" if first is not None else None),
            "first_expected_bits": (f"{int(b[first]):0{word_bytes * 2}x}" if first is not None else None),
            "bitwise_equal": first is None}


class PrefixComplete(Exception):
    """Expected early exit immediately after enc0 LN_FFN is evaluated."""


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: ln_ffn_reference_prefix.py E002_EXPERIMENT_ROOT OUTPUT", file=sys.stderr)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    output = pathlib.Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "RUNNING", "scope": "request3_generation1_B1_from_b0_S128_enc0_LN_FFN",
                    "numeric_source": "five original ABI inputs and GGUF weights only",
                    "python": platform.python_version(), "numpy": np.__version__,
                    "runner": identity(pathlib.Path(__file__)),
                    "reference": identity(root / "tests/full_reference.py"),
                    "imported_reference": identity(pathlib.Path(ref.__file__)),
                    "imported_evidence": identity(pathlib.Path(sys.modules[Evidence.__module__].__file__)),
                    "imported_oracle": identity(pathlib.Path(sys.modules[request_inputs.__module__].__file__))}
    evidence = None
    original_ln = ref.layernorm_many
    started = time.monotonic()
    try:
        require(report["reference"]["sha256"] == REFERENCE_SHA and
                report["imported_reference"]["sha256"] == REFERENCE_SHA,
                "reference identity")
        frozen_root = pathlib.Path(__file__).resolve().parents[1]
        library = configure_libm(frozen_root, output)
        report["libm"] = {"source": identity(frozen_root / "tests/full_libm_batch.c"),
                           "library": identity(library),
                           "compile_and_scalar_batch_check": "PASS_IN_CONFIGURE_LIBM"}
        evidence = Evidence(root, output)
        inputs = single_request(request_inputs(evidence), 0)
        frame_path = root / "build/cpu-embedding-requests-v4-20261010/B1_from_b0_S128.request.bin"
        frame = frame_path.read_bytes()
        require(len(frame) == 1152 and frame[:4] == b"LYRQ", "original ABI frame")
        require(struct.unpack_from("<HHQQ", frame, 20) == (1, 128, 3, 1),
                "request3/generation1/B1/S128")
        require(frame[40:72] == bytes.fromhex(evidence.manifest["model"]["sha256"]),
                "frame model tag")
        serialized = [inputs[0].astype("<i4").tobytes(), inputs[1].tobytes(),
                      inputs[2].astype("<i4").tobytes(), inputs[3].tobytes(),
                      inputs[4].astype("<i4").tobytes()]
        input_files = []
        for index, data in enumerate(serialized):
            directory = 128 + index * 32
            offset, length = struct.unpack_from("<II", frame, directory + 4)
            require(length == len(data) and frame[offset:offset + length] == data,
                    f"original ABI input {index + 1} bytes")
            path = output / f"abi_input_{index + 1}.bin"
            path.write_bytes(data)
            input_files.append(identity(path))
        report["abi_request"] = identity(frame_path)
        report["abi_inputs"] = input_files
        report["gguf_model"] = identity(evidence.model_path)

        calls = 0
        captured: dict[str, np.ndarray] = {}

        def observe_ln(values: object, gamma: object | None = None) -> np.ndarray:
            nonlocal calls
            calls += 1
            if calls == 2:
                require(gamma is None and np.asarray(values).shape == (128, 1024),
                        "enc0 LN_FFN invocation shape and gamma")
                captured["residual"] = np.asarray(values, dtype="<f4").copy()
                captured["ln_ffn"] = original_ln(values, gamma).copy()
                raise PrefixComplete
            require(calls == 1, "unexpected LayerNorm call before prefix stop")
            return original_ln(values, gamma)

        cache: dict[str, bytes] = {}

        def weight(name: str) -> bytes:
            if name not in cache:
                cache[name] = evidence.weight(name)
            return cache[name]

        ref.layernorm_many = observe_ln
        try:
            ref.full_forward_graph(*inputs, weight)
        except PrefixComplete:
            pass
        else:
            raise AssertionError("enc0 LN_FFN prefix stop not reached")
        finally:
            ref.layernorm_many = original_ln
        require(calls == 2 and set(captured) == {"residual", "ln_ffn"},
                "exactly embedding LN and enc0 LN_FFN")
        outputs = {}
        for name, array in captured.items():
            require(array.shape == (128, 1024) and np.isfinite(array).all(),
                    f"{name} shape/finite")
            outputs[name] = {}
            for suffix, view in (("full128", array), ("rows4", array[:4])):
                path = output / f"enc0_{name}_{suffix}.f32.bin"
                path.write_bytes(np.asarray(view, dtype="<f4").tobytes(order="C"))
                outputs[name][suffix] = identity(path)
        report["outputs"] = outputs

        old_capture = (root / "results/compute_throughput_optimization_20261010/attempts/"
                       "t2_widown_av_capture_run_01/work/capture/t2_enc0_ln_ffn_source.f32.bin")
        old_source4 = (root / "results/compute_throughput_optimization_20261010/attempts/"
                       "t2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin")
        require(file_sha(old_capture) == CAPTURE_SHA and file_sha(old_source4) == SOURCE4_SHA,
                "old observational source identities")
        report["comparisons"] = {
            "full_ln_vs_old_observation": compare((output / "enc0_ln_ffn_full128.f32.bin").read_bytes(),
                                                  old_capture.read_bytes(), 4),
            "rows4_ln_vs_AT035_source": compare((output / "enc0_ln_ffn_rows4.f32.bin").read_bytes(),
                                                 old_source4.read_bytes(), 4)}
        report["observations"] = {"old_full_capture": identity(old_capture),
                                   "AT035_external_source": identity(old_source4)}

        packed = np.frombuffer(ref.quantize_many(captured["ln_ffn"][:4]),
                               dtype=ref.Q8_DTYPE)
        q = packed["q"].astype(np.int8, copy=False).tobytes()
        scale = packed["scale"].astype("<f2", copy=False).tobytes()
        report["quantized_rows4"] = {"q_bytes": len(q), "q_sha256": sha(q),
                                      "scale_bytes": len(scale), "scale_sha256": sha(scale),
                                      "q_matches_prior": sha(q) == Q4_SHA,
                                      "scale_matches_prior": sha(scale) == SCALE4_SHA}
        require(report["quantized_rows4"]["q_bytes"] == 4096 and
                report["quantized_rows4"]["scale_bytes"] == 256,
                "four-row Q8 shape")
        report["weights"] = {k: evidence.checked[k] for k in evidence.checked
                             if "::" in k}
        report["weight_names"] = sorted(cache)
        report["checked_reference_files"] = {k: v for k, v in evidence.checked.items()
                                             if "::" not in k}
        report["status"] = ("PASS_EXACT_INDEPENDENT_REFERENCE" if
                            all(v["bitwise_equal"] for v in report["comparisons"].values())
                            and report["quantized_rows4"]["q_matches_prior"]
                            and report["quantized_rows4"]["scale_matches_prior"]
                            else "MISMATCH_PRESERVED")
        print("LNREF0_RESULT", report["status"],
              "full_diff", report["comparisons"]["full_ln_vs_old_observation"]["bit_diff_count"],
              "rows4_diff", report["comparisons"]["rows4_ln_vs_AT035_source"]["bit_diff_count"],
              flush=True)
        return 0 if report["status"].startswith("PASS") else 1
    except Exception as exc:
        report["status"] = "FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print("LNREF0_FAIL", report["error"], file=sys.stderr, flush=True)
        return 1
    finally:
        ref.layernorm_many = original_ln
        report["elapsed_seconds"] = time.monotonic() - started
        if evidence is not None:
            evidence.model.close()
        (output / "ln_ffn_reference_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
