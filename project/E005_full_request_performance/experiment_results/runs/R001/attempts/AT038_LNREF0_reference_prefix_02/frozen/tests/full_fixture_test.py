#!/usr/bin/env python3
"""P2 A-batch real Typed-Q8 leaf replay against an independent candidate oracle.

Usage: full_fixture_test.py PROJECT_ROOT FULL_CLI OUTPUT_DIRECTORY
All reference/runs data are read only. Captured native outputs are diagnostic
measurements; exact expected bytes come only from full_reference.py.
"""

from __future__ import annotations

import hashlib
import json
import pathlib
import platform
import shutil
import subprocess
import sys
import traceback

import numpy as np

import full_reference as ref


MANIFEST_SHA = "8588b69436e50c7500c22c677e174e77001e1e92e656bee2f46e1a88f4abb29a"
INVENTORY_SHA = "40983ab871903db1281eb82901521fae5f5e1b862d8c2d4f22deba7cbe44c5c6"
MODEL_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def file_sha(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while block := stream.read(8 << 20):
            digest.update(block)
    return digest.hexdigest()


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def f32_bytes(x: object) -> bytes:
    return np.asarray(x, dtype="<f4").tobytes(order="C")


def native_metrics(candidate: np.ndarray, native: np.ndarray) -> dict:
    a = np.asarray(candidate, dtype="<f4")
    b = np.asarray(native, dtype="<f4")
    require(a.shape == b.shape, "native diagnostic shape")
    require(np.isfinite(a).all() and np.isfinite(b).all(), "native diagnostic finite")
    difference = a.astype(np.float64) - b.astype(np.float64)
    mismatch = a.view("<u4") != b.view("<u4")
    where = np.flatnonzero(mismatch)
    return {"elements": int(a.size), "bit_diff_count": int(mismatch.sum()),
            "first_bit_diff_flat_index": int(where[0]) if where.size else None,
            "max_abs": float(np.max(np.abs(difference))),
            "max_rel_floor_1e-6": float(np.max(np.abs(difference) /
                                              np.maximum(np.abs(b), 1e-6))),
            "rmse": float(np.sqrt(np.mean(difference * difference)))}


class Evidence:
    def __init__(self, root: pathlib.Path, output: pathlib.Path) -> None:
        self.root, self.output = root, output
        self.reference = root / "reference/runs/typed_q8_ref_20261005/abi_replay"
        manifest_file = self.reference / "manifest.json"
        inventory_file = root / "reference/runs/typed_q8_ref_20261005/gguf_inventory.json"
        require(file_sha(manifest_file) == MANIFEST_SHA, "frozen manifest SHA")
        require(file_sha(inventory_file) == INVENTORY_SHA, "frozen inventory SHA")
        self.manifest = json.loads(manifest_file.read_text())
        self.inventory = json.loads(inventory_file.read_text())
        self.model_path = pathlib.Path(self.manifest["model"]["path"])
        require(self.model_path.stat().st_size == 455179648 and
                file_sha(self.model_path) == MODEL_SHA, "frozen GGUF size/SHA")
        self.model = self.model_path.open("rb")
        self.aliases = self.manifest["semantic_aliases"]
        self.nodes = {t.get("id"): t for t in self.manifest["tensors"]}
        self.weights = {w["name"]: w for w in self.inventory["tensors"]}
        self.checked: dict[str, dict] = {}
        self.checked[str(manifest_file)] = {"sha256": MANIFEST_SHA,
                                            "bytes": manifest_file.stat().st_size,
                                            "role": "capture_manifest"}
        self.checked[str(inventory_file)] = {"sha256": INVENTORY_SHA,
                                             "bytes": inventory_file.stat().st_size,
                                             "role": "gguf_inventory"}
        self.checked[str(self.model_path)] = {"sha256": MODEL_SHA,
                                              "bytes": self.model_path.stat().st_size,
                                              "role": "model"}

    def captured(self, entry: dict) -> np.ndarray:
        path = self.reference / entry["path"]
        raw = path.read_bytes()
        require(sha(raw) == entry["sha256"], f"captured SHA {entry['path']}")
        require(len(raw) == entry["storage_span_bytes"], "captured storage span")
        self.checked[str(path)] = {"sha256": entry["sha256"], "bytes": len(raw),
                                   "role": "captured_source_or_native_diagnostic",
                                   "ggml_ne": entry["ggml_ne"],
                                   "ggml_nb_bytes": entry["ggml_nb_bytes"]}
        dtype = {"f32": "<f4", "i32": "<i4"}[entry["dtype"]]
        ne = tuple(entry["ggml_ne"])
        nb = tuple(entry["ggml_nb_bytes"])
        last = sum((ne[i] - 1) * nb[i] for i in range(4)) + np.dtype(dtype).itemsize
        require(last <= len(raw), "captured stride bounds")
        return np.ndarray(ne, dtype=dtype, buffer=raw, strides=nb)

    def alias(self, name: str) -> np.ndarray:
        return self.captured(self.aliases[name])

    def node(self, node_id: str) -> np.ndarray:
        return self.captured(self.nodes[node_id])

    def token_row(self, name: str, batch: int, row: int,
                  width: int, col0: int = 0) -> np.ndarray:
        view = self.alias(name)
        require(col0 + width <= view.shape[0] and row < view.shape[1] and
                batch < view.shape[2], "token row shape")
        return view[col0 : col0 + width, row, batch, 0].copy()

    def weight(self, name: str) -> bytes:
        entry = self.weights[name]
        count = int(np.prod(entry["ggml_ne"]))
        kind = entry["ggml_type_id"]
        if kind == 0:
            length = count * 4
        elif kind == 1:
            length = count * 2
        elif kind == 8:
            require(entry["ggml_ne"][0] % 32 == 0, "GGUF Q8 groups")
            length = count // 32 * 34
        else:
            raise ValueError(f"unsupported GGUF tensor type {kind}")
        offset = int(entry["absolute_file_offset"])
        require(offset + length <= self.model_path.stat().st_size,
                "GGUF weight bounds")
        self.model.seek(offset)
        raw = self.model.read(length)
        require(len(raw) == length, "GGUF weight read")
        key = f"{self.model_path}::{name}"
        self.checked[key] = {"sha256": sha(raw), "bytes": len(raw),
                             "role": "gguf_weight", "absolute_file_offset": offset,
                             "ggml_ne": entry["ggml_ne"], "ggml_type_id": kind}
        return raw

    def q8_row(self, name: str, row: int) -> bytes:
        entry = self.weights[name]
        require(entry["ggml_type_id"] == 8 and entry["ggml_ne"][0] == 1024 and
                0 <= row < entry["ggml_ne"][1], "Q8 embedding row")
        offset = int(entry["absolute_file_offset"]) + row * 1088
        self.model.seek(offset)
        raw = self.model.read(1088)
        require(len(raw) == 1088, "Q8 row read")
        self.checked[f"{self.model_path}::{name}[{row}]"] = {
            "sha256": sha(raw), "bytes": len(raw), "role": "gguf_q8_row",
            "absolute_file_offset": offset}
        return raw


class Driver:
    def __init__(self, evidence: Evidence, cli: pathlib.Path) -> None:
        self.e = evidence
        self.cli = cli
        self.cases: list[dict] = []
        self.diagnostics: dict[str, dict] = {}

    def run(self, name: str, op: str, data: bytes, expected: object,
            *parameters: object) -> np.ndarray:
        path = self.e.output
        input_path = path / f"{name}.input.bin"
        expected_path = path / f"{name}.expected.bin"
        actual_path = path / f"{name}.actual.bin"
        output = np.asarray(expected, dtype="<f4")
        expected_bytes = output.tobytes(order="C")
        input_path.write_bytes(data)
        expected_path.write_bytes(expected_bytes)
        cmd = [str(self.cli), op, str(input_path), str(actual_path),
               *(str(p) for p in parameters)]
        run = subprocess.run(cmd, text=True, capture_output=True, check=False)
        record = {"name": name, "op": op, "parameters": list(parameters),
                  "command": cmd, "exit_code": run.returncode,
                  "stdout": run.stdout, "stderr": run.stderr,
                  "input_sha256": sha(data), "input_bytes": len(data),
                  "expected_sha256": sha(expected_bytes),
                  "expected_bytes": len(expected_bytes)}
        self.cases.append(record)
        require(run.returncode == 0 and actual_path.exists(),
                f"{name}: CLI failed: {run.stderr}")
        actual_bytes = actual_path.read_bytes()
        record["actual_sha256"] = sha(actual_bytes)
        record["actual_bytes"] = len(actual_bytes)
        require(len(actual_bytes) == len(expected_bytes), f"{name}: output length")
        if actual_bytes != expected_bytes:
            expected_bits = np.frombuffer(expected_bytes, dtype="<u4")
            actual_bits = np.frombuffer(actual_bytes, dtype="<u4")
            first = int(np.flatnonzero(expected_bits != actual_bits)[0])
            record["first_bit_mismatch"] = first
            raise AssertionError(f"{name}: F32 bit mismatch at {first}: "
                                 f"DUT={int(actual_bits[first]):08x} "
                                 f"oracle={int(expected_bits[first]):08x}")
        record["status"] = "exact_pass"
        return output

    def diagnostic(self, name: str, candidate: np.ndarray,
                   native: np.ndarray) -> None:
        self.diagnostics[name] = native_metrics(candidate, native)

    def reject(self, name: str, op: str, data: bytes,
               status_code: int, *parameters: object) -> None:
        input_path = self.e.output / f"{name}.input.bin"
        output_path = self.e.output / f"{name}.actual.bin"
        input_path.write_bytes(data)
        output_path.unlink(missing_ok=True)
        command = [str(self.cli), op, str(input_path), str(output_path),
                   *(str(p) for p in parameters)]
        run = subprocess.run(command, text=True, capture_output=True, check=False)
        record = {"name": name, "op": op, "parameters": list(parameters),
                  "command": command, "exit_code": run.returncode,
                  "stdout": run.stdout, "stderr": run.stderr,
                  "input_sha256": sha(data), "input_bytes": len(data)}
        self.cases.append(record)
        require(run.returncode == 2 and
                f"FULL_CLI_CHECK code={status_code} " in run.stderr and
                not output_path.exists(), f"{name}: expected status {status_code}")
        record["status"] = "expected_rejection"


def snapshot_contract(root: pathlib.Path, output: pathlib.Path) -> dict:
    sources = [root / "hardware_agent/task.md",
               root / "source/laya_baseline_design.md"]
    sources.extend(root / "vivado/design_source" / name for name in (
        "04_model_package_and_memory_map.md", "06_embedding_engine.md",
        "10_rope_and_mask.md", "11_attention_and_fp_engine.md",
        "12_vector_and_ffn.md", "13_decision_scorer_act.md",
        "15_integration_interfaces_and_pipeline.md"))
    destination = output / "contract_snapshot"
    destination.mkdir(parents=True, exist_ok=True)
    report = {}
    for source in sources:
        relative = source.relative_to(root)
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        require(file_sha(source) == file_sha(target), "contract copy differs")
        report[str(relative)] = {"sha256": file_sha(target),
                                 "bytes": target.stat().st_size,
                                 "snapshot": str(target)}
    return report


def exercise(driver: Driver) -> None:
    e = driver.e
    ids = e.node("ir_211")[:, :, 0, 0]
    attention_mask = e.node("ir_212")[:, :, 0, 0]
    marker_mask = e.node("ir_214")[:, :, 0, 0]
    qtype = e.node("ir_215")[:, 0, 0, 0]
    require(set(np.unique(attention_mask)) <= {0.0, 1.0}, "real mask F32 0/1")
    require(set(np.unique(marker_mask)) <= {0.0, 1.0}, "real marker mask F32 0/1")
    require(ids.shape == (128, 2) and qtype.tolist() == [2, 0],
            "ABI replay input identity")

    # Real Q8 rows include first/last vocabulary entries, CLS/PAD, repeated
    # PAD and all three type rows. Row position is independently checked.
    for label, name, row in (
        ("token_first", "tok_emb.weight", 0),
        ("token_last", "tok_emb.weight", 50367),
        ("token_cls", "tok_emb.weight", 50281),
        ("token_pad", "tok_emb.weight", 50283),
        ("token_b0_s1", "tok_emb.weight", int(ids[1, 0])),
        ("token_b1_s1", "tok_emb.weight", int(ids[1, 1])),
        ("type0", "type_emb.weight", 0),
        ("type1", "type_emb.weight", 1),
        ("type2", "type_emb.weight", 2),
    ):
        raw = e.q8_row(name, row)
        candidate = ref.embedding_row(raw)
        driver.run(f"embedding_{label}", "embedding", raw, candidate)
        if label == "token_cls":
            driver.diagnostic("native_embedding_b0_s0", candidate,
                              e.token_row("embedding_raw", 0, 0, 1024))

    # Real stride-aware Q/K/V rows are inputs. Both GGUF table families are
    # used; the sliding case applies the frozen alternate table to the same
    # real source row and is explicitly a candidate slice.
    rope_tables = {}
    for name in ("cos_full", "sin_full", "cos_slide", "sin_slide"):
        raw = e.weight(name)
        rope_tables[name] = np.frombuffer(raw, dtype="<f4").reshape(1025, 64)
    for batch, position, head, family in (
        (0, 0, 0, "full"), (0, 127, 15, "full"),
        (1, 0, 15, "slide"), (1, 127, 0, "slide"),
    ):
        cos = rope_tables[f"cos_{family}"][position]
        sin = rope_tables[f"sin_{family}"][position]
        for field in ("q", "k"):
            x = e.token_row(f"enc0_{field}", batch, position, 64, head * 64)
            expected = ref.rope_head(x, cos, sin)
            driver.run(f"rope_{field}_b{batch}_s{position}_h{head}_{family}",
                       "rope", f32_bytes(x) + f32_bytes(cos) + f32_bytes(sin),
                       expected)
            if field == "q" and family == "full":
                native = e.alias("enc0_rope_q")[:, position, head, batch].copy()
                driver.diagnostic(f"native_rope_q_b{batch}_s{position}_h{head}",
                                  expected, native)

    # Candidate Q/K are rotated with this oracle from the same captured raw
    # inputs that feed the DUT. The fused native attention lacks score/prob.
    for batch, query, head, family in ((0, 0, 0, "full"),
                                       (1, 100, 15, "slide")):
        S = 128
        cos = rope_tables[f"cos_{family}"]
        sin = rope_tables[f"sin_{family}"]
        q_raw = e.token_row("enc0_q", batch, query, 64, head * 64)
        q = ref.rope_head(q_raw, cos[query], sin[query])
        keys = np.stack([
            ref.rope_head(e.token_row("enc0_k", batch, key, 64, head * 64),
                          cos[key], sin[key]) for key in range(S)
        ]).astype("<f4")
        v = np.stack([e.token_row("enc0_v", batch, key, 64, head * 64)
                      for key in range(S)]).astype("<f4")
        mask = np.asarray(attention_mask[:, batch], dtype=np.uint8)
        stem = f"attention_b{batch}_q{query}_h{head}_{family}"
        score = ref.qk_row(q, keys, mask, S, query, family == "slide")
        driver.run(stem + "_qk", "qk", f32_bytes(q) + f32_bytes(keys) +
                   mask.tobytes(), score, S, query, int(family == "slide"))
        probability = ref.softmax_row(score, S)
        driver.run(stem + "_softmax", "softmax", f32_bytes(score),
                   probability, S)
        av = ref.av_row(probability, v, S)
        driver.run(stem + "_av", "av", f32_bytes(probability) + f32_bytes(v),
                   av, S)
        native = e.alias("enc0_attention_fused")[:, head, query, batch].copy()
        driver.diagnostic("native_" + stem + "_av", av, native)

    # Finite masks remain finite even when no key in a local window is real.
    synthetic_q = np.zeros(64, dtype="<f4")
    for S, query in ((64, 0), (1024, 1023)):
        synthetic_k = np.zeros((S, 64), dtype="<f4")
        synthetic_mask = np.zeros(S, dtype=np.uint8)
        score = ref.qk_row(synthetic_q, synthetic_k, synthetic_mask,
                           S, query, True)
        stem = f"finite_all_padding_s{S}"
        driver.run(stem + "_qk", "qk", f32_bytes(synthetic_q) +
                   f32_bytes(synthetic_k) + synthetic_mask.tobytes(),
                   score, S, query, 1)
        probability = ref.softmax_row(score, S)
        driver.run(stem + "_softmax", "softmax", f32_bytes(score),
                   probability, S)

    # The native Wi capture is used only as the GEGLU input. The candidate
    # GEGLU value feeds the DUT and the independent expected comparison.
    for batch, row in ((0, 0), (1, 127)):
        wi = e.node("ir_269")[:, row, batch, 0].copy()
        gated = ref.geglu_row(wi)
        driver.run(f"geglu_b{batch}_s{row}", "geglu", f32_bytes(wi), gated)
        native = e.token_row("enc0_gated_product", batch, row, 2624)
        driver.diagnostic(f"native_geglu_b{batch}_s{row}", gated, native)
        for index in (0, 2623):
            value = wi[index:index + 1]
            driver.run(f"gelu_b{batch}_s{row}_i{index}", "gelu",
                       f32_bytes(value), np.asarray((ref.gelu_scalar(value[0]),)))

    for batch in (0, 1):
        relu_input = e.node("ir_1431")[:, 0, batch, 0].copy()
        relu = ref.relu_row(relu_input)
        driver.run(f"decision_relu_b{batch}", "relu", f32_bytes(relu_input), relu)
        driver.diagnostic(f"native_decision_relu_b{batch}", relu,
                          e.node("ir_1432")[:, 0, batch, 0].copy())
        old = e.token_row("embedding_norm", batch, 0, 1024)
        projected = e.token_row("enc0_attention_project", batch, 0, 1024)
        added = ref.add_row(old, projected)
        driver.run(f"residual_b{batch}", "add", f32_bytes(old) +
                   f32_bytes(projected), added)
        driver.diagnostic(f"native_residual_b{batch}", added,
                          e.token_row("enc0_attention_residual", batch, 0, 1024))
        typed = ref.embedding_row(e.q8_row("type_emb.weight", int(qtype[batch])))
        final = e.token_row("encoder_final_norm", batch, 0, 1024)
        type_added = ref.add_row(final, typed)
        driver.run(f"type_add_b{batch}", "add", f32_bytes(final) +
                   f32_bytes(typed), type_added)
        driver.diagnostic(f"native_type_add_b{batch}", type_added,
                          e.token_row("type_add", batch, 0, 1024))

    scorer_post_bias = np.frombuffer(e.weight("scorer_fc1.bias"), dtype="<f4")
    scorer_fc2_w = np.frombuffer(e.weight("scorer_fc2.weight"), dtype="<f4")
    scorer_fc2_bias = np.frombuffer(e.weight("scorer_fc2.bias"), dtype="<f4")[0]
    act_weight = np.frombuffer(e.weight("act_fc1.weight"), dtype="<u2").reshape(256, 1028)
    act_bias = np.frombuffer(e.weight("act_fc1.bias"), dtype="<f4")
    for batch in (0, 1):
        for column in (0, 15):
            # ir_1461 includes linear_120_baked_bias. Original scorer bias
            # is a separate post-Q8 add inside native gelu_28.
            x = e.alias("scorer_fc1_with_bias")[:, column, batch, 0].copy()
            hidden = ref.bias_gelu_row(x, scorer_post_bias, 1024)
            driver.run(f"scorer_bias_gelu_b{batch}_c{column}", "bias_gelu",
                       f32_bytes(x) + f32_bytes(scorer_post_bias), hidden, 1024)
            driver.diagnostic(f"native_scorer_gelu_b{batch}_c{column}", hidden,
                              e.alias("scorer_gelu")[:, column, batch, 0].copy())
            logit = ref.fp_scorer_row(hidden, scorer_fc2_w, scorer_fc2_bias)
            driver.run(f"scorer_fc2_b{batch}_c{column}", "fp_scorer",
                       f32_bytes(hidden) + f32_bytes(scorer_fc2_w) +
                       f32_bytes(np.asarray((scorer_fc2_bias,))),
                       np.asarray((logit,)))
            driver.diagnostic(f"native_scorer_fc2_b{batch}_c{column}",
                              np.asarray((logit,)),
                              e.alias("scorer_fc2_with_bias")[:, column, batch, 0].copy())

        raw = e.alias("candidate_before_mask")[:, batch, 0, 0].copy()
        mask = marker_mask[:, batch].astype(np.uint8)
        masked = ref.candidate_mask(raw, mask)
        driver.run(f"candidate_mask_b{batch}", "candidate_mask",
                   f32_bytes(raw) + mask.tobytes(), masked)
        driver.diagnostic(f"native_candidate_mask_b{batch}", masked,
                          e.alias("candidate_raw_logits")[:, batch, 0, 0].copy())
        probability = ref.softmax_row(masked, 16)
        driver.run(f"candidate_softmax_b{batch}", "softmax",
                   f32_bytes(masked), probability, 16)
        driver.diagnostic(f"native_candidate_p_b{batch}", probability,
                          e.alias("act_probability_vector")[:, batch, 0, 0].copy())
        valid_options = int(np.sum(mask))
        stats = ref.candidate_stats(probability, valid_options)
        driver.run(f"candidate_stats_b{batch}", "candidate_stats",
                   f32_bytes(probability), stats, valid_options)
        driver.diagnostic(f"native_stats_b{batch}", stats,
                          e.alias("act_stats4")[:, batch, 0, 0].copy())
        cls = e.token_row("decision1_layer_out", batch, 0, 1024)
        native_cls = e.alias("act_cls")[:, batch, 0, 0].copy()
        driver.diagnostic(f"native_act_cls_b{batch}", cls, native_cls)
        if batch == 1:
            # Capture fact only: native act_cls selects flattened position 1,
            # which is batch0/position1 for S128. The candidate contract uses
            # each batch's own position0 and never adopts this as expected.
            source_b0_s1 = e.token_row("decision1_layer_out", 0, 1, 1024)
            driver.diagnostics["native_act_cls_b1_source_observation"] = {
                "equals_batch0_position1_bitwise": bool(np.array_equal(
                    native_cls.view("<u4"), source_b0_s1.view("<u4"))),
                "candidate_uses_batch1_position0": True,
            }
        act_input = ref.concat_act_row(cls, stats)
        driver.run(f"act_concat_b{batch}", "concat",
                   f32_bytes(cls) + f32_bytes(stats), act_input)
        driver.diagnostic(f"native_act_input_b{batch}", act_input,
                          e.alias("act_input1028")[:, batch, 0, 0].copy())
        act_dot = ref.fp_act_row(act_input, act_weight)
        driver.run(f"act_fp16_dot_b{batch}", "fp_act",
                   f32_bytes(act_input) + act_weight.astype("<u2").tobytes(),
                   act_dot)
        act_hidden = ref.bias_gelu_row(act_dot, act_bias, 256)
        driver.run(f"act_bias_gelu_b{batch}", "bias_gelu",
                   f32_bytes(act_dot) + f32_bytes(act_bias), act_hidden, 256)
        driver.diagnostic(f"native_act_gelu_b{batch}", act_hidden,
                          e.alias("act_gelu")[:, batch, 0, 0].copy())

    # Supplemental exact edge vectors exercise 1/2/3/16 option counts, ties,
    # near ties, entropy floor and full 16-element reduction without native
    # checkpoints being mistaken for expected values.
    for valid in (1, 2, 3, 16):
        for pattern in ("tie", "near_tie", "uniform", "one_hot"):
            if pattern == "tie":
                p = np.zeros(16, dtype="<f4"); p[:2] = ref.F32(0.5)
            elif pattern == "near_tie":
                p = np.zeros(16, dtype="<f4")
                p[0] = ref.F32(0.50000006); p[1] = ref.F32(0.49999994)
            elif pattern == "uniform":
                p = np.full(16, ref.F32(1 / 16), dtype="<f4")
            else:
                p = np.zeros(16, dtype="<f4"); p[15] = ref.F32(1)
            expected = ref.candidate_stats(p, valid)
            driver.run(f"stats_{pattern}_valid{valid}", "candidate_stats",
                       f32_bytes(p), expected, valid)
    try:
        ref.candidate_stats(np.full(16, ref.F32(1 / 16), dtype="<f4"), 0)
    except ValueError:
        pass
    else:
        raise AssertionError("independent candidate_stats accepted zero valid options")
    driver.reject("stats_invalid_zero_options", "candidate_stats",
                  f32_bytes(np.full(16, ref.F32(1 / 16), dtype="<f4")), 3, 0)


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: full_fixture_test.py PROJECT_ROOT FULL_CLI OUTPUT_DIRECTORY",
              file=sys.stderr)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    cli = pathlib.Path(sys.argv[2]).resolve()
    output = pathlib.Path(sys.argv[3]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "running", "phase": "P2_A_leaf_numeric",
                    "oracle": "independent NumPy/struct/ctypes libm",
                    "native_role": "diagnostic_only",
                    "python": platform.python_version(),
                    "numpy": np.__version__, "glibc": platform.libc_ver(),
                    "cli": str(cli), "cli_sha256": file_sha(cli),
                    "contract_snapshot": snapshot_contract(root, output)}
    driver = None
    try:
        evidence = Evidence(root, output)
        driver = Driver(evidence, cli)
        exercise(driver)
        report["libm_accuracy_audit"] = ref.libm_accuracy_audit([
            ("expf", -1.0), ("expf", -100.0), ("expf", 0.0),
            ("tanhf", -2.5), ("tanhf", 0.0), ("tanhf", 3.0),
            ("logf", ref.F32(1e-9)), ("logf", ref.F32(1/16)),
            ("logf", ref.F32(2.0)), ("logf", ref.F32(16.0)),
        ])
        report["status"] = "PASS"
        return 0
    except Exception as exc:
        report["status"] = "FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
        return 1
    finally:
        if driver is not None:
            report["cases"] = driver.cases
            report["case_count"] = len(driver.cases)
            report["native_diagnostics"] = driver.diagnostics
            report["checked_reference_files"] = driver.e.checked
            driver.e.model.close()
        (output / "full_fixture_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
