#!/usr/bin/env python3
"""P1 real Typed-Q8 slices, independent oracle, and immutable input evidence."""

from __future__ import annotations

import hashlib
import json
import math
import pathlib
import struct
import subprocess
import sys
from dataclasses import dataclass

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "tests"))
import numeric_reference as oracle  # noqa: E402

MANIFEST_SHA = "8588b69436e50c7500c22c677e174e77001e1e92e656bee2f46e1a88f4abb29a"
INVENTORY_SHA = "40983ab871903db1281eb82901521fae5f5e1b862d8c2d4f22deba7cbe44c5c6"
MODEL_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"
SEED = 20261007


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def file_sha(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as file:
        while chunk := file.read(8 << 20):
            h.update(chunk)
    return h.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


@dataclass(frozen=True)
class Case:
    name: str
    mode: str
    source: str
    batch: int
    row0: int
    rows: int
    n0: int = 0


def cases() -> list[Case]:
    result: list[Case] = []
    for batch, row0 in ((0, 0), (1, 112)):
        for n0 in (0, 2616, 2624, 5240):
            result.append(Case(f"wi_ln_b{batch}_r{row0}_n{n0}", "ln_wi",
                               "enc0_attention_residual", batch, row0, 16, n0))
        for n0 in (0, 1024, 2048, 3064):
            result.append(Case(f"qkv_ln_b{batch}_r{row0}_n{n0}", "ln_qkv",
                               "embedding_raw", batch, row0, 16, n0))
        for n0 in (0, 1016):
            result.append(Case(f"down_b{batch}_r{row0}_n{n0}", "down",
                               "enc0_gated_product", batch, row0, 16, n0))
    result.extend((
        Case("wi_native_first", "wi", "enc0_mlp_norm", 0, 0, 16, 0),
        Case("wi_native_last", "wi", "enc0_mlp_norm", 1, 112, 16, 5240),
        Case("qkv_native_first", "qkv", "embedding_norm", 0, 0, 16, 0),
        Case("qkv_native_last", "qkv", "embedding_norm", 1, 112, 16, 3064),
        Case("wi_ln_rows1", "ln_wi", "enc0_attention_residual", 0, 0, 1, 0),
        Case("wi_ln_rows15", "ln_wi", "enc0_attention_residual", 1, 113, 15, 5240),
        Case("qkv_ln_rows1", "ln_qkv", "embedding_raw", 0, 0, 1, 0),
        Case("qkv_ln_rows15", "ln_qkv", "embedding_raw", 1, 113, 15, 3064),
        Case("act_b0", "act", "act_gelu", 0, 0, 1, 0),
        Case("act_b1", "act", "act_gelu", 1, 0, 1, 0),
        Case("quant4096_seed", "quant4096", "supplemental_seed", 0, 0, 16, 0),
    ))
    return result


class Evidence:
    def __init__(self, root: pathlib.Path, output: pathlib.Path) -> None:
        self.root, self.output = root, output
        self.ref = root / "reference/runs/typed_q8_ref_20261005/abi_replay"
        manifest_path = self.ref / "manifest.json"
        inventory_path = root / "reference/runs/typed_q8_ref_20261005/gguf_inventory.json"
        require(file_sha(manifest_path) == MANIFEST_SHA, "manifest frozen SHA256")
        require(file_sha(inventory_path) == INVENTORY_SHA, "GGUF inventory frozen SHA256")
        self.manifest = json.loads(manifest_path.read_text())
        self.inventory = json.loads(inventory_path.read_text())
        self.model_path = pathlib.Path(self.manifest["model"]["path"])
        require(self.model_path.stat().st_size == 455179648 and
                file_sha(self.model_path) == MODEL_SHA, "model frozen SHA256")
        self.aliases = self.manifest["semantic_aliases"]
        self.tensor_id = {t["id"]: t for t in self.manifest["tensors"] if "id" in t}
        self.weights = {t["name"]: t for t in self.inventory["tensors"]}
        self.checked: dict[str, dict] = {}
        self.cache: dict[str, bytes] = {}
        self.model = self.model_path.open("rb")

    def checked_file(self, entry: dict) -> bytes:
        relative = entry["path"]
        if relative not in self.cache:
            path = self.ref / relative
            data = path.read_bytes()
            require(sha(data) == entry["sha256"], f"source SHA256 {relative}")
            span = entry.get("storage_span_bytes", entry.get("storage_bytes"))
            require(len(data) == int(span), f"source storage span {relative}")
            self.cache[relative] = data
            self.checked[relative] = {
                "path": str(path), "sha256": entry["sha256"],
                "bytes": len(data), "ggml_ne": entry.get("ggml_ne"),
                "ggml_nb_bytes": entry.get("ggml_nb_bytes"),
            }
        return self.cache[relative]

    def tensor(self, entry: dict) -> np.ndarray:
        raw = self.checked_file(entry)
        ne, nb = tuple(entry["ggml_ne"]), tuple(entry["ggml_nb_bytes"])
        require(entry["dtype"] == "f32" and len(ne) == len(nb) == 4,
                f"F32 tensor metadata {entry['path']}")
        last = sum((int(ne[i]) - 1) * int(nb[i]) for i in range(4)) + 4
        require(last <= len(raw), f"strided tensor bounds {entry['path']}")
        return np.ndarray(ne, dtype="<f4", buffer=raw, strides=nb)

    def slice(self, entry: dict, case: Case, width: int,
              col0: int = 0) -> np.ndarray:
        view = self.tensor(entry)
        require(col0 + width <= view.shape[0], "tensor feature range")
        if case.mode == "act":
            require(view.shape[1] >= case.batch + 1 and case.rows == 1,
                    "act batch axis")
            return view[col0 : col0 + width, case.batch, 0, 0].reshape(1, width).copy()
        require(case.row0 + case.rows <= view.shape[1] and case.batch < view.shape[2],
                "TOKEN ne/nb bounds")
        return view[col0 : col0 + width,
                    case.row0 : case.row0 + case.rows,
                    case.batch, 0].T.copy()

    def weight(self, name: str, K: int, N: int, n0: int) -> tuple[bytes, dict]:
        entry = self.weights[name]
        require(entry["ggml_type_id"] == 8 and entry["ggml_ne"][:2] == [K, N],
                f"GGUF Q8 tensor identity {name}")
        groups = K // 32
        full_bytes = N * groups * 34
        offset = int(entry["absolute_file_offset"])
        require(offset + full_bytes <= self.model_path.stat().st_size,
                f"GGUF Q8 bounds {name}")
        self.model.seek(offset)
        full = self.model.read(full_bytes)
        require(len(full) == full_bytes, f"GGUF Q8 read {name}")
        cols = min(8, N - n0)
        window = full[n0 * groups * 34 : (n0 + cols) * groups * 34]
        require(len(window) == cols * groups * 34, "full K W window")
        repacked = bytearray()
        for block in range(cols * groups):
            raw = window[block * 34 : (block + 1) * 34]
            half = struct.unpack("<H", raw[:2])[0]
            q = struct.unpack("<32b", raw[2:])
            repacked += struct.pack("<H32b", half, *q)
        require(bytes(repacked) == window, "GGUF Q8 inverse block mapping")
        return window, {"tensor_name": name, "full_sha256": sha(full),
                        "window_sha256": sha(window), "absolute_file_offset": offset,
                        "full_bytes": full_bytes, "n0": n0, "cols": cols,
                        "groups": groups, "dtype": "Q8_0", "source_ne": entry["ggml_ne"]}

    def f32_weight(self, name: str, count: int) -> tuple[bytes, dict]:
        entry = self.weights[name]
        require(entry["ggml_type_id"] == 0 and entry["ggml_ne"][0] == count,
                f"GGUF F32 tensor identity {name}")
        offset = int(entry["absolute_file_offset"])
        require(offset + count * 4 <= self.model_path.stat().st_size, "F32 weight bounds")
        self.model.seek(offset)
        data = self.model.read(count * 4)
        require(len(data) == count * 4, "F32 weight read")
        return data, {"tensor_name": name, "sha256": sha(data),
                      "absolute_file_offset": offset, "bytes": len(data),
                      "source_ne": entry["ggml_ne"]}


def compare_exact(label: str, actual: bytes, expected: bytes) -> int:
    require(len(actual) == len(expected), f"{label} byte length")
    if actual == expected:
        return len(actual)
    first = next(i for i, (a, b) in enumerate(zip(actual, expected)) if a != b)
    raise AssertionError(f"{label} first byte mismatch at {first}: "
                         f"DUT={actual[first]:02x} oracle={expected[first]:02x}")


def native_f32_metrics(candidate: bytes, native: np.ndarray) -> dict:
    c = np.frombuffer(candidate, dtype="<f4").reshape(native.shape)
    n = np.asarray(native, dtype="<f4")
    require(np.isfinite(c).all() and np.isfinite(n).all(), "native metrics finite")
    mismatch = c.view("<u4") != n.view("<u4")
    delta = c.astype(np.float64) - n.astype(np.float64)
    denom = np.maximum(np.abs(n.astype(np.float64)), 1e-6)
    flat = np.flatnonzero(mismatch)
    return {"elements": int(c.size), "bit_diff_count": int(mismatch.sum()),
            "first_bit_diff_flat_index": int(flat[0]) if flat.size else None,
            "max_abs": float(np.max(np.abs(delta))),
            "max_rel_floor_1e-6": float(np.max(np.abs(delta) / denom)),
            "rmse": float(np.sqrt(np.mean(delta * delta)))}


def native_q8_metrics(candidate: bytes, native: bytes) -> dict:
    require(len(candidate) == len(native) and len(candidate) % 34 == 0,
            "native Q8 scratch length")
    blocks = len(candidate) // 34
    scale_diff = sum(candidate[i * 34 : i * 34 + 2] !=
                     native[i * 34 : i * 34 + 2] for i in range(blocks))
    q_diff = sum(a != b for i in range(blocks)
                 for a, b in zip(candidate[i * 34 + 2 : (i + 1) * 34],
                                 native[i * 34 + 2 : (i + 1) * 34]))
    return {"groups": blocks, "scale_bit_diff_groups": scale_diff,
            "q_diff_elements": q_diff}


def native_scratch_slice(evidence: Evidence, node: str, case: Case, K: int) -> bytes:
    entry = next(s for s in evidence.manifest["native_quantized_activation_scratch"]
                 if s["node"] == node)
    raw = evidence.checked_file(entry)
    groups = K // 32
    start_row = case.batch if case.mode == "act" else case.batch * 128 + case.row0
    start = start_row * groups * 34
    end = start + case.rows * groups * 34
    require(end <= len(raw), "native scratch row range")
    return raw[start:end]


def selected_metadata(mode: str) -> tuple[int, int, str, str, str]:
    if mode in ("ln_wi", "wi"):
        return 1024, 5248, "mlp_wi.0.weight", "ir_269", "linear_2"
    if mode in ("ln_qkv", "qkv"):
        return 1024, 3072, "qkv.0.weight", "ir_237", "linear"
    if mode == "down":
        return 2624, 1024, "mlp_wo.0.weight", "ir_274", "linear_3"
    if mode == "act":
        return 256, 2, "act_fc2.weight", "ir_1616", "node_1808"
    return 4096, 0, "", "", ""


def main() -> None:
    require(len(sys.argv) == 4, "usage: numeric_fixture_test.py ROOT NUMERIC_CLI OUT")
    root, cli, output = map(pathlib.Path, sys.argv[1:])
    require(root.resolve() == ROOT.resolve() and cli.is_file(), "project/CLI path")
    output.mkdir(parents=True, exist_ok=True)
    oracle.half_boundary_selftest()
    e = Evidence(root, output)
    task_section = (root / "hardware_agent/task.md").read_text().split("## 11. ", 1)[1]
    numeric_contract_sha = sha(("P1 Q8-F R0\n" + task_section).encode())
    source_files = [root / p for p in (
        "include/laya_numeric.h", "include/laya_numeric_tasks.h",
        "hls/common/laya_numeric.cpp", "hls/operators/layernorm_compute.cpp",
        "hls/operators/activation_quantizer_compute.cpp", "hls/operators/q8_linear_compute.cpp",
        "tests/numeric_reference.py", "tests/numeric_cli.cpp",
        "vivado/module_design/top/tb/numeric_fixture_test.py")]
    source_hashes = {str(p.relative_to(root)): file_sha(p) for p in source_files}
    build_identity = sha(json.dumps(source_hashes, sort_keys=True).encode())
    tags = (MODEL_SHA[:32], numeric_contract_sha[:32], INVENTORY_SHA[:32],
            build_identity[:32])
    report = {"status": "RUNNING", "profile": "abi_replay S128 B2",
              "numeric_version": "P1 Q8-F R0 IEEE F32 RNE",
              "experimental_tags_hex": {"model": tags[0], "numeric": tags[1],
                                        "layout": tags[2], "build": tags[3]},
              "model_sha256": MODEL_SHA, "manifest_sha256": MANIFEST_SHA,
              "gguf_inventory_sha256": INVENTORY_SHA,
              "numeric_contract_sha256": numeric_contract_sha,
              "source_hashes": source_hashes, "numpy_version": np.__version__,
              "python_version": sys.version.split()[0], "seed": SEED,
              "cases": [], "checked_reference_files": e.checked}
    try:
        for case in cases():
            K, N, weight_name, native_id, scratch_node = selected_metadata(case.mode)
            folder = output / "cases" / case.name
            folder.mkdir(parents=True, exist_ok=True)
            if case.source == "supplemental_seed":
                rng = np.random.default_rng(SEED)
                source = rng.uniform(-8, 8, size=(case.rows, K)).astype("<f4")
                source_desc = {"origin": "supplemental fixed seed", "seed": SEED}
            else:
                entry = e.aliases[case.source]
                source = e.slice(entry, case, K)
                source_desc = {"origin": case.source, "path": entry["path"],
                               "sha256": entry["sha256"], "ggml_ne": entry["ggml_ne"],
                               "ggml_nb_bytes": entry["ggml_nb_bytes"]}
            input_bytes = source.tobytes(order="C")
            input_path = folder / "input_f32.bin"
            input_path.write_bytes(input_bytes)
            record = {"name": case.name, "mode": case.mode, "batch": case.batch,
                      "row0": case.row0, "rows": case.rows, "K": K, "N": N,
                      "n0": case.n0, "source": source_desc,
                      "derived_input_sha256": sha(input_bytes),
                      "derived_input_bytes": len(input_bytes),
                      "oracle_exact": {}, "native_comparison": {}}
            gamma_path = "-"
            if case.mode == "ln_qkv":
                gamma_bytes, gamma_desc = e.f32_weight("emb_norm_w", 1024)
                gamma_file = folder / "gamma_f32.bin"; gamma_file.write_bytes(gamma_bytes)
                gamma_path = str(gamma_file); record["gamma"] = gamma_desc
            weight_path, bias_path = "-", "-"
            weight_sha, weight_offset, weight_bytes = "0" * 64, 0, 0
            bias_sha, bias_offset, bias_bytes = "-", 0, 0
            cols = 0
            if N:
                window, weight_desc = e.weight(weight_name, K, N, case.n0)
                cols = weight_desc["cols"]
                weight_file = folder / "weight_q8_window.bin"
                weight_file.write_bytes(window)
                weight_path = str(weight_file)
                weight_sha = weight_desc["full_sha256"]
                weight_offset = weight_desc["absolute_file_offset"]
                weight_bytes = weight_desc["full_bytes"]
                record["weight"] = weight_desc
                if case.mode == "act":
                    bias_data, bias_desc = e.f32_weight("act_fc2.bias", 2)
                    bias_file = folder / "bias_f32.bin"
                    bias_file.write_bytes(bias_data)
                    bias_path = str(bias_file)
                    bias_sha = bias_desc["sha256"]
                    bias_offset = bias_desc["absolute_file_offset"]
                    bias_bytes = bias_desc["bytes"]
                    record["bias"] = bias_desc
            prefix = folder / "dut"
            command = [str(cli), case.mode, str(input_path), weight_path,
                       bias_path, gamma_path, str(prefix), str(case.batch),
                       str(case.row0), str(case.rows), str(case.n0), "37", "5",
                       *tags, weight_sha, str(weight_offset), str(weight_bytes),
                       bias_sha, str(bias_offset), str(bias_bytes)]
            completed = subprocess.run(command, capture_output=True, text=True)
            (folder / "command.json").write_text(json.dumps(command, indent=2) + "\n")
            (folder / "stdout.log").write_text(completed.stdout)
            (folder / "stderr.log").write_text(completed.stderr)
            require(completed.returncode == 0 and "NUMERIC_CLI_PASS" in completed.stdout,
                    f"DUT {case.name}: rc={completed.returncode} {completed.stderr}")
            record["dut_stdout"] = completed.stdout.strip()
            if case.mode.startswith("ln_"):
                gamma_values = None
                if case.mode == "ln_qkv":
                    gamma_values = np.frombuffer(gamma_bytes, dtype="<f4")
                expected_ln, expected_stats = oracle.layernorm(source, gamma_values)
                actual_ln = pathlib.Path(str(prefix) + ".ln.bin").read_bytes()
                actual_stats = pathlib.Path(str(prefix) + ".ln_stats.bin").read_bytes()
                record["oracle_exact"]["ln_bytes"] = compare_exact(case.name + " LN",
                                                                     actual_ln, expected_ln)
                record["oracle_exact"]["ln_stats_bytes"] = compare_exact(
                    case.name + " LN stats", actual_stats, expected_stats)
                quant_input = np.frombuffer(expected_ln, dtype="<f4").reshape(case.rows, 1024)
                native_ln = e.aliases["embedding_norm" if case.mode == "ln_qkv" else "enc0_mlp_norm"]
                record["native_comparison"]["layernorm"] = native_f32_metrics(
                    actual_ln, e.slice(native_ln, case, 1024))
            else:
                quant_input = source
            expected_q8, quant_diag = oracle.quantize(quant_input)
            actual_q8 = pathlib.Path(str(prefix) + ".q8.bin").read_bytes()
            record["oracle_exact"]["quant_bytes"] = compare_exact(case.name + " quant",
                                                                    actual_q8, expected_q8)
            record["quant_diagnostics"] = {"groups": len(quant_diag),
                                           "first_amax_d_inverse": quant_diag[0],
                                           "last_amax_d_inverse": quant_diag[-1]}
            if N:
                native_q8 = native_scratch_slice(e, scratch_node, case, K)
                record["native_comparison"]["q8_scratch"] = native_q8_metrics(actual_q8, native_q8)
                bias_values = None
                if case.mode == "act":
                    bias_values = np.frombuffer(bias_data, dtype="<f4")
                expected_y, expected_trace = oracle.linear(expected_q8, window,
                                                            case.rows, K, cols, bias_values)
                actual_y = pathlib.Path(str(prefix) + ".linear.bin").read_bytes()
                actual_trace = pathlib.Path(str(prefix) + ".trace.bin").read_bytes()
                record["oracle_exact"]["linear_bytes"] = compare_exact(case.name + " linear",
                                                                         actual_y, expected_y)
                record["oracle_exact"]["trace_bytes"] = compare_exact(case.name + " trace",
                                                                        actual_trace, expected_trace)
                record["oracle_exact"]["trace_groups"] = case.rows * cols * (K // 32)
                native_entry = e.tensor_id[native_id]
                native_y = e.slice(native_entry, case, cols, case.n0)
                record["native_comparison"]["linear"] = native_f32_metrics(actual_y, native_y)
                if case.mode == "act":
                    prebias_entry = e.tensor_id["node_1808"]
                    prebias = e.slice(prebias_entry, case, cols)
                    trace_array = np.frombuffer(actual_trace, dtype="<u4").reshape(case.rows, cols, K // 32, 3)
                    partial_bits = trace_array[:, :, -1, 2].copy()
                    prebias_candidate = partial_bits.view("<f4").tobytes(order="C")
                    record["native_comparison"]["prebias_node_1808"] = native_f32_metrics(
                        prebias_candidate, prebias)
            record["outputs"] = {str(p.relative_to(output)): {"bytes": p.stat().st_size,
                                                                "sha256": file_sha(p)}
                                 for p in folder.glob("dut.*.bin")}
            report["cases"].append(record)
            print(f"NUMERIC_FIXTURE_CASE_PASS {case.name} rows={case.rows} "
                  f"K={K} cols={cols}", flush=True)
        report["status"] = "PASS"
    except Exception as exc:
        report["status"] = "FAIL"
        report["failure"] = {"type": type(exc).__name__, "message": str(exc)}
        raise
    finally:
        report["checked_reference_files"] = e.checked
        (output / "numeric_fixture_report.json").write_text(
            json.dumps(report, indent=2, ensure_ascii=False) + "\n")
        e.model.close()
    print(f"NUMERIC_REAL_FIXTURE_PASS cases={len(report['cases'])} "
          f"trace_groups={sum(c['oracle_exact'].get('trace_groups', 0) for c in report['cases'])}")


if __name__ == "__main__":
    main()
