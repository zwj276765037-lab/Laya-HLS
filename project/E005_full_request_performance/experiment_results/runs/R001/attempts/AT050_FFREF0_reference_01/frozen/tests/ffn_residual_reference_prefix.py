#!/usr/bin/env python3
"""Observe enc0 FFN operands and result in the unchanged independent graph."""

from __future__ import annotations

import hashlib
import inspect
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
SKIP_FULL_SHA = "bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8"
SKIP4_SHA = "5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9"
LN_FULL_SHA = "6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863"
LN4_SHA = "658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883"
DOWN4_SHA = "4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0"
ENC0_FULL_SHA = "9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b"
AT049_DOWN_MEM_SHA = "000b31e139362de3b6a94778167f13544e8e713fe956d857ade6c677327f02a0"


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
    """Expected early exit immediately after the enc0 output checkpoint."""


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: ffn_residual_reference_prefix.py E002_EXPERIMENT_ROOT OUTPUT", file=sys.stderr)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    output = pathlib.Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "RUNNING", "scope": "request3_generation1_B1_from_b0_S128_enc0_FFN_residual",
                    "numeric_source": "five original ABI inputs and GGUF weights only",
                    "python": platform.python_version(), "numpy": np.__version__,
                    "runner": identity(pathlib.Path(__file__)),
                    "reference": identity(root / "tests/full_reference.py"),
                    "imported_reference": identity(pathlib.Path(ref.__file__)),
                    "imported_evidence": identity(pathlib.Path(sys.modules[Evidence.__module__].__file__)),
                    "imported_oracle": identity(pathlib.Path(sys.modules[request_inputs.__module__].__file__))}
    evidence = None
    original_ln = ref.layernorm_many
    original_add = ref.add
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
        request_manifest_path = root / "build/cpu-embedding-requests-v4-20261010/identity_manifest.json"
        request_manifest = json.loads(request_manifest_path.read_text())
        request_entry = next(entry for entry in request_manifest["requests"]
                             if entry["name"] == "B1_from_b0_S128")
        require(request_entry["target_sha256"] == sha(frame) and
                (request_entry["B"], request_entry["S"],
                 request_entry["request_id"], request_entry["generation"]) == (1, 128, 3, 1),
                "request manifest identity")
        for tag_index, tag_name in enumerate(("model", "numeric", "layout", "build")):
            require(frame[40 + 16 * tag_index:56 + 16 * tag_index] ==
                    bytes.fromhex(request_manifest["tags"][tag_name]),
                    f"frame {tag_name} package tag")
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
        report["abi_request_manifest"] = identity(request_manifest_path)
        report["abi_package_tags"] = request_manifest["tags"]
        report["abi_inputs"] = input_files
        report["gguf_model"] = identity(evidence.model_path)

        calls = 0
        graph_add_lines: list[int] = []
        captured: dict[str, np.ndarray] = {}

        def observe_ln(values: object, gamma: object | None = None) -> np.ndarray:
            nonlocal calls
            calls += 1
            if calls == 2:
                require(gamma is None and np.asarray(values).shape == (128, 1024),
                        "enc0 LN_FFN invocation shape and gamma")
                captured["ln_input"] = np.asarray(values, dtype="<f4").copy()
                result = original_ln(values, gamma)
                captured["ln_ffn"] = np.asarray(result, dtype="<f4").copy()
                return result
            require(calls == 1, "unexpected LayerNorm before enc0 checkpoint")
            return original_ln(values, gamma)

        def observe_add(lhs: object, rhs: object) -> np.float32:
            caller = inspect.currentframe().f_back
            result = original_add(lhs, rhs)
            if caller is not None and caller.f_code is ref.full_forward_graph.__code__:
                if caller.f_lineno in (770, 777):
                    require(np.asarray(lhs).shape == (1, 128, 1024) and
                            np.asarray(rhs).shape == (1, 128, 1024),
                            "enc0 add operand shape")
                    graph_add_lines.append(caller.f_lineno)
                    if caller.f_lineno == 770:
                        require("skip" not in captured, "duplicate attention residual")
                        captured["skip"] = np.asarray(result, dtype="<f4").copy()
                    else:
                        require("down" not in captured, "duplicate FFN residual")
                        captured["add_lhs"] = np.asarray(lhs, dtype="<f4").copy()
                        captured["down"] = np.asarray(rhs, dtype="<f4").copy()
                        captured["enc0_out"] = np.asarray(result, dtype="<f4").copy()
            return result

        def checkpoint(name: str, value: np.ndarray) -> None:
            if name == "encoder_00_out":
                require("enc0_out" in captured and
                        compare(np.asarray(value, dtype="<f4").tobytes(),
                                captured["enc0_out"].tobytes(), 4)["bitwise_equal"],
                        "original checkpoint equals observed add result")
                raise PrefixComplete

        cache: dict[str, bytes] = {}

        def weight(name: str) -> bytes:
            if name not in cache:
                cache[name] = evidence.weight(name)
            return cache[name]

        ref.layernorm_many = observe_ln
        ref.add = observe_add
        try:
            ref.full_forward_graph(*inputs, weight, checkpoint)
        except PrefixComplete:
            pass
        else:
            raise AssertionError("enc0 output checkpoint stop not reached")
        finally:
            ref.layernorm_many = original_ln
            ref.add = original_add
        require(calls == 2 and graph_add_lines == [770, 777] and
                set(captured) == {"skip", "ln_input", "ln_ffn", "add_lhs",
                                  "down", "enc0_out"},
                "exact enc0 graph observations")
        require(compare(captured["skip"].tobytes(),
                        captured["add_lhs"].tobytes(), 4)["bitwise_equal"] and
                compare(captured["skip"].tobytes(),
                        captured["ln_input"].reshape(1,128,1024).tobytes(), 4)["bitwise_equal"],
                "the same skip enters LN and final residual")
        report["graph_add_lines"] = graph_add_lines
        outputs = {}
        for name in ("skip", "down", "enc0_out", "ln_ffn"):
            array = captured[name].reshape(128, 1024)
            require(array.shape == (128, 1024) and np.isfinite(array).all(),
                    f"{name} shape/finite")
            outputs[name] = {}
            for suffix, view in (("full128", array), ("rows4", array[:4])):
                path = output / f"enc0_{name}_{suffix}.f32.bin"
                path.write_bytes(np.asarray(view, dtype="<f4").tobytes(order="C"))
                outputs[name][suffix] = identity(path)
        report["outputs"] = outputs

        at038 = (root.parents[1] / "E005_full_request_performance/experiment_results/"
                 "runs/R001/attempts/AT038_LNREF0_reference_prefix_02/output")
        old_skip_full = at038 / "enc0_residual_full128.f32.bin"
        old_skip_four = at038 / "enc0_residual_rows4.f32.bin"
        old_ln_full = at038 / "enc0_ln_ffn_full128.f32.bin"
        old_ln_four = at038 / "enc0_ln_ffn_rows4.f32.bin"
        require(file_sha(old_skip_full) == SKIP_FULL_SHA and
                file_sha(old_skip_four) == SKIP4_SHA and
                file_sha(old_ln_full) == LN_FULL_SHA and
                file_sha(old_ln_four) == LN4_SHA,
                "AT038 independent skip/LN identities")
        down_binary = (root / "results/compute_throughput_optimization_20261010/attempts/"
                       "t2_widown_av_fixtures_01/work/fixtures/down_rows4_output_f32.bin")
        down_mem = (root.parents[1] / "E005_full_request_performance/experiment_results/"
                    "runs/R001/attempts/AT035_QAR0_shared_admission_01/work/fixtures/a/output.mem")
        at049_manifest = (root.parents[1] / "E005_full_request_performance/experiment_results/"
                          "runs/R001/attempts/AT049_LNQ2_runtime_01/source_manifest.json")
        at049_files = json.loads(at049_manifest.read_text())["files"]
        require(any(entry["path"] == str(down_mem.resolve()) and
                    entry["sha256"] == AT049_DOWN_MEM_SHA for entry in at049_files),
                "AT049 frozen Down mem identity")
        require(file_sha(down_binary) == DOWN4_SHA and
                file_sha(down_mem) == AT049_DOWN_MEM_SHA,
                "Down independent binary and AT049 mem identities")
        words = [int(line, 16) for line in down_mem.read_text().splitlines()]
        require(len(words) == 4096 and all(0 <= word <= 0xffffffff for word in words),
                "Down mem 4096 U32 words")
        down_mem_binary = b"".join(word.to_bytes(4, "little") for word in words)

        oracle = (root / "results/attention_rtl_repair_20261008/"
                  "d2_cpu_full_official/oracle/B1_from_b0_S128/encoder_00_out.f32.bin")
        oracle_report = (root / "results/attention_rtl_repair_20261008/"
                         "d2_cpu_full_official/oracle/full_forward_oracle_report.json")
        oracle_entry = next(entry for entry in json.loads(oracle_report.read_text())
                            ["runs"]["B1_from_b0_S128"]["checkpoints"]
                            if entry["name"] == "encoder_00_out")
        require(oracle_entry["bytes"] == 524288 and
                oracle_entry["sha256"] == ENC0_FULL_SHA and
                file_sha(oracle) == ENC0_FULL_SHA,
                "original independent enc0 output checkpoint identity")
        report["observations"] = {
            "AT038_skip_full": identity(old_skip_full),
            "AT038_skip_rows4": identity(old_skip_four),
            "AT038_ln_full": identity(old_ln_full),
            "AT038_ln_rows4": identity(old_ln_four),
            "Down_independent_binary": identity(down_binary),
            "AT049_down_mem": identity(down_mem),
            "AT049_manifest": identity(at049_manifest),
            "original_encoder_00_out": identity(oracle),
            "original_oracle_report": identity(oracle_report)}
        report["comparisons"] = {
            "skip_full_vs_AT038": compare((output / "enc0_skip_full128.f32.bin").read_bytes(),
                                          old_skip_full.read_bytes(), 4),
            "skip_rows4_vs_AT038": compare((output / "enc0_skip_rows4.f32.bin").read_bytes(),
                                           old_skip_four.read_bytes(), 4),
            "ln_full_vs_AT038": compare((output / "enc0_ln_ffn_full128.f32.bin").read_bytes(),
                                        old_ln_full.read_bytes(), 4),
            "ln_rows4_vs_AT038": compare((output / "enc0_ln_ffn_rows4.f32.bin").read_bytes(),
                                         old_ln_four.read_bytes(), 4),
            "down_rows4_vs_independent_binary": compare((output / "enc0_down_rows4.f32.bin").read_bytes(),
                                                        down_binary.read_bytes(), 4),
            "down_rows4_vs_AT049_mem": compare((output / "enc0_down_rows4.f32.bin").read_bytes(),
                                               down_mem_binary, 4),
            "enc0_full_vs_independent_oracle": compare((output / "enc0_enc0_out_full128.f32.bin").read_bytes(),
                                                       oracle.read_bytes(), 4),
            "enc0_rows4_vs_oracle_prefix": compare((output / "enc0_enc0_out_rows4.f32.bin").read_bytes(),
                                                   oracle.read_bytes()[:16384], 4)}
        report["weights"] = {k: evidence.checked[k] for k in evidence.checked
                             if "::" in k}
        report["weight_names"] = sorted(cache)
        report["checked_reference_files"] = {k: v for k, v in evidence.checked.items()
                                             if "::" not in k}
        report["status"] = ("PASS_EXACT_INDEPENDENT_FFN_REFERENCE" if
                            all(v["bitwise_equal"] for v in report["comparisons"].values())
                            else "MISMATCH_PRESERVED")
        print("FFREF0_RESULT", report["status"],
              "down_diff", report["comparisons"]["down_rows4_vs_AT049_mem"]["bit_diff_count"],
              "enc0_diff", report["comparisons"]["enc0_full_vs_independent_oracle"]["bit_diff_count"],
              flush=True)
        return 0 if report["status"].startswith("PASS") else 1
    except Exception as exc:
        report["status"] = "FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print("FFREF0_FAIL", report["error"], file=sys.stderr, flush=True)
        return 1
    finally:
        ref.layernorm_many = original_ln
        ref.add = original_add
        report["elapsed_seconds"] = time.monotonic() - started
        if evidence is not None:
            evidence.model.close()
        (output / "ffn_residual_reference_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
