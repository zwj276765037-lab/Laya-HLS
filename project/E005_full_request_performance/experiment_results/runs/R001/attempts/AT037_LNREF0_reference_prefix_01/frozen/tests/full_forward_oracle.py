#!/usr/bin/env python3
"""Run the independent P2 F0 full graph on the frozen real ABI inputs.

Only the five captured request inputs and GGUF source weights enter the graph.
Captured native intermediates are never read by this runner.
"""

from __future__ import annotations

import json
import pathlib
import platform
import subprocess
import sys
import time
import traceback

import numpy as np

from full_fixture_test import Evidence, file_sha, sha
import full_reference as ref


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


class Checkpoints:
    def __init__(self, directory: pathlib.Path) -> None:
        self.directory = directory
        self.directory.mkdir(parents=True, exist_ok=True)
        self.values: dict[str, np.ndarray] = {}
        self.records: list[dict] = []
        self.started = time.monotonic()

    def __call__(self, name: str, value: np.ndarray) -> None:
        require(name not in self.values, "duplicate checkpoint " + name)
        array = np.asarray(value, dtype="<f4").copy()
        data = array.tobytes(order="C")
        path = self.directory / (name + ".f32.bin")
        path.write_bytes(data)
        self.values[name] = array
        self.records.append({"name": name, "shape": list(array.shape),
                             "bytes": len(data), "sha256": sha(data),
                             "path": str(path),
                             "elapsed_s": round(time.monotonic() - self.started, 3)})
        if name.startswith(("encoder_", "decision_")) or name == "final18":
            print(f"{self.directory.name} {name} "
                  f"elapsed={self.records[-1]['elapsed_s']:.1f}s", flush=True)


def request_inputs(evidence: Evidence) -> tuple[np.ndarray, ...]:
    ids = evidence.node("ir_211")[:, :, 0, 0].T.copy()
    attention = evidence.node("ir_212")[:, :, 0, 0].T.copy()
    marker = evidence.node("ir_213")[:, :, 0, 0].T.copy()
    marker_mask = evidence.node("ir_214")[:, :, 0, 0].T.copy()
    qtype = evidence.node("ir_215")[:, 0, 0, 0].copy()
    require(ids.shape == (2, 128) and marker.shape == (2, 16) and
            qtype.tolist() == [2, 0], "frozen B2/S128 source input shape")
    require(np.isin(attention, [0.0, 1.0]).all() and
            np.isin(marker_mask, [0.0, 1.0]).all(),
            "real F32 masks exactly U8 0/1")
    return (ids.astype("<i4"), attention.astype(np.uint8),
            marker.astype("<i4"), marker_mask.astype(np.uint8),
            qtype.astype(np.uint8))


def single_request(inputs: tuple[np.ndarray, ...], batch: int
                   ) -> tuple[np.ndarray, ...]:
    ids, attention, marker, marker_mask, qtype = inputs
    S = ids.shape[1]
    local_marker = marker[batch:batch + 1].copy()
    local_marker -= batch * S
    require(np.all(local_marker >= 0) and np.all(local_marker < S),
            "B1 marker rebase")
    return (ids[batch:batch + 1].copy(),
            attention[batch:batch + 1].copy(), local_marker,
            marker_mask[batch:batch + 1].copy(),
            qtype[batch:batch + 1].copy())


def configure_libm(root: pathlib.Path, output: pathlib.Path) -> pathlib.Path:
    source = root / "tests/full_libm_batch.c"
    library = output / "full_libm_batch.so"
    command = ["cc", "-std=c11", "-O2", "-fPIC", "-shared",
               "-fno-fast-math", "-ffp-contract=off",
               "-fno-builtin-expf", "-fno-builtin-tanhf",
               "-fno-builtin-logf", str(source), "-lm", "-o", str(library)]
    subprocess.run(command, check=True, capture_output=True, text=True)
    ref.configure_batch_libm(library)
    sample = np.asarray([-12.5, -1, -0.0, 0, 0.125, 1, 7.5], dtype="<f4")
    for name, scalar in (("expf", ref.libm_exp),
                         ("tanhf", ref.libm_tanh)):
        actual = ref.libm_array(name, sample)
        expected = np.asarray([scalar(x) for x in sample], dtype="<f4")
        require(np.array_equal(actual.view("<u4"), expected.view("<u4")),
                "batch libm scalar bit identity " + name)
    positive = np.abs(sample) + ref.F32(0.01)
    actual = ref.libm_array("logf", positive)
    expected = np.asarray([ref.libm_log(x) for x in positive], dtype="<f4")
    require(np.array_equal(actual.view("<u4"), expected.view("<u4")),
            "batch libm scalar bit identity logf")
    return library


def load_b2_checkpoints(output: pathlib.Path,
                        previous: dict) -> Checkpoints:
    require(previous["status"] == "ORACLE_B2_GENERATED_NO_DUT_COMPARISON",
            "resumed B2 oracle report status")
    recorder = Checkpoints(output / "B2_S128")
    for item in previous["runs"]["B2_S128"]["checkpoints"]:
        path = pathlib.Path(item["path"])
        require(path.parent == recorder.directory and path.is_file(),
                "resumed B2 checkpoint path")
        data = path.read_bytes()
        require(len(data) == item["bytes"] and sha(data) == item["sha256"],
                "resumed B2 checkpoint byte identity")
        array = np.frombuffer(data, dtype="<f4").reshape(item["shape"]).copy()
        recorder.values[item["name"]] = array
        recorder.records.append(item)
    require("final18" in recorder.values and
            sha(recorder.values["final18"].tobytes()) ==
            previous["runs"]["B2_S128"]["result18_sha256"],
            "resumed B2 final18 identity")
    return recorder


def main() -> int:
    if len(sys.argv) not in (3, 4) or (len(sys.argv) == 4 and
                                    sys.argv[3] not in
                                    ("--b2-only", "--resume-b2")):
        print("usage: full_forward_oracle.py ROOT OUTPUT_DIR "
              "[--b2-only|--resume-b2]",
              file=sys.stderr)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    output = pathlib.Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "GENERATING_NO_DUT_COMPARISON",
                    "scope": "real_abi_B2_S128_28_encoder_2_decision_scorer_act",
                    "source_role": "five captured inputs and GGUF weights only",
                    "native_intermediate_role": "none",
                    "python": platform.python_version(), "numpy": np.__version__,
                    "glibc": platform.libc_ver(), "runs": {},
                    "script_sha256": file_sha(pathlib.Path(__file__)),
                    "reference_sha256": file_sha(root / "tests/full_reference.py")}
    evidence = None
    try:
        library = configure_libm(root, output)
        report["libm_adapter"] = {"path": str(library),
                                   "sha256": file_sha(library),
                                   "source_sha256": file_sha(root /
                                                              "tests/full_libm_batch.c")}
        evidence = Evidence(root, output)
        inputs = request_inputs(evidence)
        cache: dict[str, bytes] = {}

        def weight(name: str) -> bytes:
            if name not in cache:
                cache[name] = evidence.weight(name)
            return cache[name]

        if len(sys.argv) == 4 and sys.argv[3] == "--resume-b2":
            prior_file = output / "full_forward_oracle_report.json"
            prior = json.loads(prior_file.read_text())
            require(prior["reference_sha256"] == report["reference_sha256"] and
                    prior["libm_adapter"]["source_sha256"] ==
                    report["libm_adapter"]["source_sha256"],
                    "resumed B2 oracle implementation identity")
            report["resumed_B2_source_report_sha256"] = file_sha(prior_file)
            b2 = load_b2_checkpoints(output, prior)
            result = b2.values["final18"]
        else:
            b2 = Checkpoints(output / "B2_S128")
            result = ref.full_forward_graph(*inputs, weight, b2)
        report["runs"]["B2_S128"] = {"checkpoints": b2.records,
                                      "result18_shape": list(result.shape),
                                      "result18_sha256": sha(result.tobytes())}
        if len(sys.argv) == 3 or sys.argv[3] == "--resume-b2":
            for batch in range(2):
                name = f"B1_from_b{batch}_S128"
                single = Checkpoints(output / name)
                result_one = ref.full_forward_graph(
                    *single_request(inputs, batch), weight, single)
                comparisons = []
                for key, expected in b2.values.items():
                    actual = single.values[key]
                    require(actual.shape == expected[batch:batch + 1].shape,
                            f"B1/B2 checkpoint shape {name}:{key}")
                    equal = np.array_equal(actual.view("<u4"),
                                           expected[batch:batch + 1].view("<u4"))
                    comparisons.append({"checkpoint": key, "bitwise_equal": bool(equal)})
                    require(equal, f"B1/B2 checkpoint bit mismatch {name}:{key}")
                require(np.array_equal(result_one.view("<u4"),
                                       result[batch:batch + 1].view("<u4")),
                        "B1/B2 final18 bit identity")
                report["runs"][name] = {"checkpoints": single.records,
                                        "comparison_to_B2": comparisons,
                                        "result18_sha256": sha(result_one.tobytes())}
            report["status"] = "ORACLE_GENERATED_B1_B2_CONSISTENT_NO_DUT_COMPARISON"
        else:
            report["status"] = "ORACLE_B2_GENERATED_NO_DUT_COMPARISON"
        report["checked_reference_files"] = evidence.checked
        report["cached_gguf_tensors"] = len(cache)
        return 0
    except Exception as error:
        report["status"] = "FAIL"
        report["error"] = f"{type(error).__name__}: {error}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr, flush=True)
        return 1
    finally:
        if evidence is not None:
            evidence.model.close()
            report["checked_reference_files"] = evidence.checked
        (output / "full_forward_oracle_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
