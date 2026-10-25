"""Explicit reference CPU backend for M007 Embedding/LN and compact tail.

All arithmetic calls the existing hash-pinned strict full_reference functions.
This backend does not execute Attention, talk to a device, or meet CPU timing
acceptance. The original complete graph remains an independent read-only oracle.
"""
from __future__ import annotations

from dataclasses import dataclass
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import sys

import numpy as np

from .contract import CONSTANTS, SCHEMA_SHA256, ContractError, Request

EXPERIMENT = Path(__file__).resolve().parents[2]
REFERENCE = EXPERIMENT / "tests/full_reference.py"
REFERENCE_SHA = "fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784"
INVENTORY = EXPERIMENT / "reference/runs/typed_q8_ref_20261005/gguf_inventory.json"
INVENTORY_SHA = "40983ab871903db1281eb82901521fae5f5e1b862d8c2d4f22deba7cbe44c5c6"
MODEL_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"
GRAPH_SHA = "f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9"


def file_sha(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for data in iter(lambda: stream.read(8 << 20), b""):
            digest.update(data)
    return digest.hexdigest()


def strict_reference():
    name = "laya_m007_frozen_reference"
    if name not in sys.modules:
        if file_sha(REFERENCE) != REFERENCE_SHA:
            raise ContractError("frozen independent reference source SHA mismatch")
        spec = importlib.util.spec_from_file_location(name, REFERENCE)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        sys.modules[name] = module
    return sys.modules[name]


class GGUFWeights:
    """One verified read-only model handle; only requested tensor spans are read."""
    def __init__(self, path: Path):
        self.path = Path(path).resolve()
        if (self.path.stat().st_size != 455179648 or file_sha(self.path) != MODEL_SHA or
                file_sha(INVENTORY) != INVENTORY_SHA):
            raise ContractError("GGUF/inventory source identity mismatch")
        self.inventory = {item["name"]: item for item in json.loads(
            INVENTORY.read_text())["tensors"]}
        self.stream = self.path.open("rb")
        self.checked: dict[str, dict] = {}
        self.cache: dict[str, bytes] = {}
        self.model_sha256 = MODEL_SHA

    def __enter__(self):
        return self

    def __exit__(self, *unused):
        self.stream.close()

    def __call__(self, name: str) -> bytes:
        if name not in self.cache:
            item = self.inventory[name]
            elements = math.prod(item["ggml_ne"])
            kind = item["ggml_type_id"]
            if kind not in (0, 1, 8) or kind == 8 and elements % 32:
                raise ContractError("GGUF tensor kind/shape")
            length = (elements * {0: 4, 1: 2}.get(kind, 0) if kind != 8 else
                      elements // 32 * 34)
            offset = item["absolute_file_offset"]
            if offset < 0 or offset + length > self.path.stat().st_size:
                raise ContractError("GGUF tensor span")
            self.stream.seek(offset)
            data = self.stream.read(length)
            if len(data) != length:
                raise ContractError("short GGUF tensor read")
            self.cache[name] = data
            self.checked[name] = {"offset": offset, "bytes": length,
                                  "sha256": hashlib.sha256(data).hexdigest()}
        return self.cache[name]


def _f32(value, shape, name):
    array = np.asarray(value)
    if array.dtype != np.dtype("<f4") or array.shape != shape:
        raise ContractError(name + ": expected exact F32 shape")
    if not np.isfinite(array).all():
        raise ArithmeticError(name + ": nonfinite")
    return array


def prepare_h0(token_ids, read_weight) -> np.ndarray:
    """Strict CPU embedding and original gamma LN; never truncates tokens."""
    ids = np.asarray(token_ids)
    if (ids.shape != (128,) or ids.dtype.kind not in "iu" or
            np.any(ids < 0) or np.any(ids >= 50368)):
        raise ContractError("token_ids: exactly 128 vocabulary IDs required")
    ref = strict_reference()
    table = read_weight("tok_emb.weight")
    if len(table) != 50368 * 1088:
        raise ContractError("token embedding span")
    gamma = _weight_f32(read_weight, "emb_norm_w", 1024)
    cache = {}
    raw = np.empty((128, 1024), dtype="<f4")
    for row, token in enumerate(ids):
        number = int(token)
        if number not in cache:
            cache[number] = ref.embedding_row(table[number * 1088:(number + 1) * 1088])
        raw[row] = cache[number]
    return ref.layernorm_many(raw, gamma)


def gather_tail_cpu_contract(hidden, request: Request) -> bytes:
    """Explicit diagnostic gather, not a device implementation or fallback."""
    request.validate()
    source = _f32(hidden, (128, 1024), "hidden")
    tail = np.empty((17, 1024), dtype="<f4")
    for slot, position in enumerate(request.markers):
        tail[slot] = source[position]
    tail[16] = source[0]
    return tail.tobytes()


def parse_tail(payload: bytes) -> np.ndarray:
    if len(payload) != CONSTANTS["TAIL_BYTES"]:
        raise ContractError("compact tail: exact 69632 bytes required")
    # Own a copy. Marker LN can never mutate the raw CLS in the input frame.
    return _f32(np.frombuffer(payload, dtype="<f4").reshape(17, 1024),
                (17, 1024), "tail").copy()


def _weight_f32(read_weight, name: str, count: int):
    raw = read_weight(name)
    if len(raw) != count * 4:
        raise ContractError("F32 weight span: " + name)
    return _f32(np.frombuffer(raw, dtype="<f4"), (count,), name)


@dataclass(frozen=True)
class TailResult:
    logits18: np.ndarray
    probability: np.ndarray
    stats: np.ndarray
    raw_cls: np.ndarray
    backend: str = "cpu_contract"


def finish_tail_cpu_contract(payload: bytes, request: Request, read_weight,
                             checkpoint=lambda name, value: None) -> TailResult:
    """Original strict tail order, with no independent arithmetic implementation."""
    request.validate()
    if (request.identity.model != getattr(read_weight, "model_sha256", None) or
            request.identity.model != MODEL_SHA or request.identity.graph != GRAPH_SHA or
            request.identity.numeric != REFERENCE_SHA or request.identity.layout != SCHEMA_SHA256):
        raise ContractError("CPU contract model/graph/reference/schema identity mismatch")
    ref = strict_reference()
    tail = parse_tail(payload)
    raw_cls = tail[16].copy()

    def keep(name, value):
        if not np.isfinite(value).all():
            raise ArithmeticError(name + ": nonfinite")
        checkpoint(name, np.asarray(value, dtype="<f4").copy())
        return value

    gathered = keep("marker_gather", tail[:16].copy())
    norm = keep("marker_norm", ref.layernorm_many(gathered))
    baked = keep("scorer_fc1_baked", ref.q8_linear_many(
        norm, read_weight("scorer_fc1.weight"), 1024,
        _weight_f32(read_weight, "linear_120_baked_bias", 1024)))
    scorer_hidden = keep("scorer_post_bias_gelu", ref.gelu_array(ref.add(
        baked, _weight_f32(read_weight, "scorer_fc1.bias", 1024)[None, :])))
    candidate = keep("candidate_raw", ref.fp_scorer_many(
        scorer_hidden, _weight_f32(read_weight, "scorer_fc2.weight", 1024),
        _weight_f32(read_weight, "scorer_fc2.bias", 1)[0]))
    masked = keep("candidate_masked", ref.candidate_mask(candidate, request.marker_mask))
    probability = keep("candidate_prob", ref.softmax_many(masked[None, :])[0])
    stats = keep("stats", ref.candidate_stats(probability, request.candidate_count))
    act_input = keep("act_input", ref.concat_act_row(raw_cls, stats))
    weights = read_weight("act_fc1.weight")
    if len(weights) != 256 * 1028 * 2:
        raise ContractError("ACT FC1 weight span")
    act_dot = keep("act_dot", ref.fp_act_many(act_input[None, :],
        np.frombuffer(weights, dtype="<u2").reshape(256, 1028))[0])
    act_hidden = keep("act_hidden", ref.gelu_array(ref.add(
        act_dot, _weight_f32(read_weight, "act_fc1.bias", 256))))
    act = keep("act_logits", ref.q8_linear_many(act_hidden[None, :],
        read_weight("act_fc2.weight"), 2, _weight_f32(read_weight, "act_fc2.bias", 2))[0])
    logits = keep("final18", np.concatenate((masked, act)).astype("<f4"))
    if not np.array_equal(raw_cls.view("<u4"), tail[16].view("<u4")):
        raise RuntimeError("raw CLS overwritten")
    return TailResult(logits.copy(), probability.copy(), stats.copy(), raw_cls)
