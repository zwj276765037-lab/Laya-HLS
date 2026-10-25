"""Persistent production CPU contract. Numerical work stays in the native library.

The frozen Python full_reference is never imported or called by this module's
prepare/finish paths. Existing metadata helpers only verify immutable assets.
"""
from __future__ import annotations
from dataclasses import dataclass
import ctypes as C
import hashlib
import json
import math
import os
from pathlib import Path
import threading
import time

import numpy as np

from .contract import (ContractError, Identity, Request, encode_request,
                       validate_tail_ready, SCHEMA_SHA256)
from .frontend import (FrontendError, load_json_strict, read_bound_metadata)
from .cpu_contract import (EXPERIMENT, MODEL_SHA, GRAPH_SHA, REFERENCE_SHA,
                           INVENTORY, INVENTORY_SHA, file_sha)


@dataclass(frozen=True)
class Prepared:
    request: Request
    h0: np.ndarray
    token_ids: np.ndarray
    question_id: str
    question_json: str
    source_sha256: str
    session_token: object


@dataclass(frozen=True)
class NativeResult:
    logits18: np.ndarray
    answer: dict
    raw_answer: dict
    backend: str = "native_cpu_contract"
    device: str = "NOT_RUN"


def canonical(value):
    # Original serialize_state and criteria rendering preserve object order.
    # Compact serialization must keep that order throughout the real wrapper.
    return json.dumps(value, ensure_ascii=False, sort_keys=False, separators=(",", ":"),
                      allow_nan=False)


class NativeSession:
    """One verified model and native worker pool; <=64 pending native requests."""
    def __init__(self, library: Path, model: Path, assets: Path, *, cache_mode="full"):
        began = time.perf_counter_ns()
        self._handle = None
        self._lock = threading.RLock()
        self._token = object()
        self._bindings = {}
        if cache_mode not in ("full", "lazy"):
            raise FrontendError("IDENTITY_ERROR", "cache_mode must be full/lazy")
        self.cache_mode = cache_mode
        self.library_path, self.model_path = Path(library).resolve(), Path(model).resolve()
        identity_path = self.library_path.with_suffix(".identity.json")
        build = load_json_strict(identity_path)
        if build["schema"] != "m007-native-session-build-v1" or file_sha(self.library_path) != build["binary_sha256"]:
            raise FrontendError("IDENTITY_ERROR", "native Session binary identity")
        for name, expected in build["source_sha256"].items():
            path = (EXPERIMENT / name).resolve()
            if not path.is_relative_to(EXPERIMENT) or file_sha(path) != expected:
                raise FrontendError("IDENTITY_ERROR", "native Session source identity: " + name)
        checked_libs = {}
        for record in build["libm"]["symbols"].values():
            path = Path(record["path"])
            if str(path) not in checked_libs:
                checked_libs[str(path)] = file_sha(path)
            if checked_libs[str(path)] != record["sha256"]:
                raise FrontendError("IDENTITY_ERROR", "actual frozen-reference libm identity")
        before = self.model_path.stat()
        metadata, self.metadata_sha256 = read_bound_metadata(self.model_path, Path(assets))
        if file_sha(INVENTORY) != INVENTORY_SHA:
            raise FrontendError("IDENTITY_ERROR", "native Session inventory identity")
        inventory = {item["name"]: item for item in load_json_strict(INVENTORY)["tensors"]}
        names = ("tok_emb.weight", "emb_norm_w", "scorer_fc1.weight", "linear_120_baked_bias",
                 "scorer_fc1.bias", "scorer_fc2.weight", "scorer_fc2.bias", "act_fc1.weight",
                 "act_fc1.bias", "act_fc2.weight", "act_fc2.bias")
        spans = {}
        for name in names:
            item = inventory[name]
            elements = math.prod(item["ggml_ne"])
            kind = item["ggml_type_id"]
            length = elements // 32 * 34 if kind == 8 else elements * {0: 4, 1: 2}[kind]
            offset = item["absolute_file_offset"]
            if offset < 0 or offset + length > before.st_size:
                raise FrontendError("IDENTITY_ERROR", "CPU tensor span: " + name)
            spans[name] = {"offset": offset, "bytes": length, "ggml_type_id": kind,
                           "shape": item["ggml_ne"]}
        bundle = {"metadata_int": {key: value for key, value in metadata.items()
                                   if key.startswith("laya.") and type(value) is int},
                  "metadata_str": {key: value for key, value in metadata.items()
                                   if key.startswith("laya.") and isinstance(value, str)},
                  "tokenizer": {key: value for key, value in metadata.items()
                                if key.startswith("tokenizer.")},
                  "model_path": str(self.model_path), "model_sha256": MODEL_SHA}
        self.build_identity = build
        self.identity = Identity(MODEL_SHA, GRAPH_SHA, REFERENCE_SHA, SCHEMA_SHA256,
            hashlib.sha256(canonical({"build": build, "metadata": self.metadata_sha256,
                                      "cache_mode":cache_mode}).encode()).hexdigest())
        self.identity.validate()
        self._lib = lib = C.CDLL(str(self.library_path))
        lib.m007_create.argtypes = [C.c_char_p, C.c_int, C.c_void_p]
        lib.m007_create.restype = C.c_void_p
        lib.m007_destroy.argtypes = [C.c_void_p]
        lib.m007_error.argtypes = [C.c_void_p]
        lib.m007_error.restype = C.c_char_p
        lib.m007_json.argtypes = [C.c_void_p, C.c_char_p, C.POINTER(C.c_char_p)]
        lib.m007_json.restype = C.c_int
        lib.m007_prepare.argtypes = [C.c_void_p, C.c_void_p, C.c_void_p, C.c_void_p]
        lib.m007_finish.argtypes = [C.c_void_p, C.c_void_p, C.c_void_p, C.c_void_p, C.c_int]
        lib.m007_cancel.argtypes = [C.c_void_p, C.c_void_p]
        lib.m007_checkpoint.argtypes = [C.c_void_p, C.c_char_p, C.c_void_p, C.c_size_t]
        lib.m007_checkpoint.restype = C.c_size_t
        lib.m007_metrics.argtypes = [C.c_void_p, C.POINTER(C.c_uint64)]
        lib.m007_cache_info.argtypes = [C.c_void_p, C.POINTER(C.c_uint64)]
        lib.m007_fenv.argtypes = [C.POINTER(C.c_uint)]
        id_bytes = b"".join(bytes.fromhex(getattr(self.identity, name)) for name in
                           ("model", "graph", "numeric", "layout", "build"))
        # Materialize NumPy's ctypes adapter during initialization.
        np.empty(1,dtype="<f4").ctypes.data
        config = canonical({"frontend": bundle, "tensors": spans,"cache_mode":cache_mode}).encode()
        with self.model_path.open("rb") as stream:
            stat = os.fstat(stream.fileno())
            if (stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns) != (
                    before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns):
                raise FrontendError("IDENTITY_ERROR", "model changed during verification")
            handle = lib.m007_create(config, stream.fileno(), C.c_char_p(id_bytes))
            after = os.fstat(stream.fileno())
        if not handle:
            raise FrontendError("NATIVE_ERROR", lib.m007_error(None).decode())
        self._handle = handle
        if (after.st_size, after.st_mtime_ns) != (before.st_size, before.st_mtime_ns):
            self.close()
            raise FrontendError("IDENTITY_ERROR", "model changed during native weight load")
        self.initialization_ns = time.perf_counter_ns() - began
        self.weight_spans = spans

    def __enter__(self):
        return self

    def __exit__(self, *unused):
        self.close()

    def close(self):
        with self._lock:
            if self._handle:
                self._lib.m007_destroy(self._handle)
                self._handle = None
                self._token = object()
                self._bindings.clear()

    def _check(self, status):
        if status:
            text = self._lib.m007_error(self._handle).decode()
            code, _, message = text.partition(": ")
            raise FrontendError(code, message or text)

    def _open(self):
        if not self._handle:
            raise FrontendError("SESSION_ERROR", "Session is closed; old prepared requests are invalid")

    def call(self, value):
        with self._lock:
            self._open()
            raw = C.c_char_p()
            self._check(self._lib.m007_json(self._handle, canonical(value).encode(), C.byref(raw)))
            return json.loads(raw.value)

    def encode(self, data):
        if not isinstance(data, dict) or "state" not in data or "questions" not in data:
            raise FrontendError("JSON_ERROR", "state and questions required")
        return self.call({"op": "encode", "state": data["state"], "questions": data["questions"]})

    def prepare_tokens(self, token_ids, request: Request, *, question_id="", question=None,
                       source_sha256=""):
        with self._lock:
            self._open()
            if request.identity != self.identity:
                raise FrontendError("IDENTITY_ERROR", "request is bound to another model/build Session")
            ids = np.asarray(token_ids)
            if ids.shape != (128,) or ids.dtype != np.dtype("<i4"):
                raise FrontendError("TOKEN_ERROR", "exact128 I32 token IDs required")
            ids = np.ascontiguousarray(ids)
            question_json = canonical(question)
            wire = encode_request(request)
            h0 = np.empty((128, 1024), dtype="<f4")
            self._check(self._lib.m007_prepare(self._handle, ids.ctypes.data,
                                              C.c_char_p(wire), h0.ctypes.data))
            self._bindings[(request.request_id, request.generation)] = (
                request, question_id, question_json, source_sha256)
            return Prepared(request, h0, ids.copy(), question_id, question_json,
                            source_sha256, self._token)

    def prepare(self, data, request_id: int, generation: int = 1):
        with self._lock:
            source = canonical(data)
            frozen_data = json.loads(source)
            encoded = self.encode(frozen_data)
            output = []
            try:
                for index, item in enumerate(encoded["questions"]):
                    req = Request(request_id + index, generation, self.identity, item["qtype"],
                        tuple(item["attention_mask"]), tuple(item["markers"]), tuple(item["marker_mask"]),
                        item["candidate_count"], 0x100000000, 0x200000000)
                    output.append(self.prepare_tokens(np.asarray(item["token_ids"], dtype="<i4"), req,
                        question_id=item["question_id"], question=frozen_data["questions"][item["question_id"]],
                        source_sha256=hashlib.sha256(source.encode()).hexdigest()))
            except Exception:
                for prepared in output:
                    self._lib.m007_cancel(self._handle, C.c_char_p(encode_request(prepared.request)))
                    self._bindings.pop((prepared.request.request_id, prepared.request.generation), None)
                raise
            return output

    def finish(self, prepared: Prepared, tail, *, completion=None, trace=False, decode=True):
        with self._lock:
            self._open()
            if prepared.session_token is not self._token or prepared.request.identity != self.identity:
                raise FrontendError("IDENTITY_ERROR", "prepared request from another/reloaded Session")
            request = prepared.request
            wire = encode_request(request)
            key = (request.request_id, request.generation)
            if self._bindings.get(key) != (request, prepared.question_id,
                                          prepared.question_json, prepared.source_sha256):
                raise FrontendError("IDENTITY_ERROR", "prepared source/question/request association changed or retired")
            if isinstance(tail, bytes):
                if len(tail) != 69632:
                    raise FrontendError("FRAME_ERROR", "exact69632B compact tail required")
                values = np.frombuffer(tail, dtype="<f4").reshape(17, 1024)
            else:
                values = np.asarray(tail)
                if values.dtype != np.dtype("<f4") or values.shape != (17, 1024):
                    raise FrontendError("FRAME_ERROR", "exact17x1024 F32 compact tail required")
            values = np.ascontiguousarray(values)
            if completion is not None:
                validate_tail_ready(completion, values.tobytes(), request)
            logits = np.empty(18, dtype="<f4")
            self._check(self._lib.m007_finish(self._handle, C.c_char_p(wire), values.ctypes.data,
                                             logits.ctypes.data, int(trace)))
            del self._bindings[key]
            answer = self.decode(prepared.question_id, json.loads(prepared.question_json), logits,
                                 request.marker_mask, request.qtype) if decode else {"answer": {}, "raw": {}}
            return NativeResult(logits, answer["answer"], answer["raw"])

    def decode(self, question_id, question, logits18, marker_mask, qtype):
        logits = np.asarray(logits18)
        if logits.dtype != np.dtype("<f4") or logits.shape != (18,) or not np.isfinite(logits).all():
            raise FrontendError("NUMERIC_ERROR", "exact18 finite F32 logits required")
        return self.call({"op": "decode", "question_id": question_id, "question": question,
            "logits_u32": logits.view("<u4").tolist(), "marker_mask": list(marker_mask), "qtype": qtype})

    def checkpoint(self, name, shape):
        with self._lock:
            self._open()
            output = np.empty(shape, dtype="<f4")
            count = self._lib.m007_checkpoint(self._handle, name.encode(), output.ctypes.data, output.size)
            if count != output.size:
                raise FrontendError("CHECKPOINT_ERROR", "checkpoint missing/shape: " + name)
            return output

    def metrics(self):
        with self._lock:
            self._open()
            values = (C.c_uint64 * 8)()
            self._lib.m007_metrics(self._handle, values)
            info = (C.c_uint64 * 2)()
            self._lib.m007_cache_info(self._handle, info)
            return dict(zip(("cache_hits", "cache_misses", "native_prepare_ns", "marker_ln_ns",
                             "scorer_ns", "act_ns", "native_finish_ns", "pending"), values),
                        cache_initialized_rows=info[0],cache_fill_ns=info[1])

    def fenv(self):
        values = (C.c_uint * 2)()
        self._lib.m007_fenv(values)
        return {"fe_round": values[0], "mxcsr": values[1]}
