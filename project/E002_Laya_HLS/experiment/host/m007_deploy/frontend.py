"""Real model/native-tokenizer frontend and original business decode adapter.

The native helper has no ModelExecutor and cannot execute Attention. Full model
bytes, bounded metadata, native sources and binary are verified before use.
"""
from __future__ import annotations
from dataclasses import asdict
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import struct
import subprocess
import time

import numpy as np

from .contract import (Identity, Request, ContractError, SCHEMA_SHA256,
                       decode_request, encode_request)
from .cpu_contract import (EXPERIMENT, MODEL_SHA, GRAPH_SHA, REFERENCE_SHA,
                           GGUFWeights, file_sha, prepare_h0)

TOOLS_READER_SHA = "1d2a1cf9dc4760a83a174a4d9946b9d0050bc1b817dd101fa838cfe6e1925033"


class FrontendError(ContractError):
    def __init__(self, code, message):
        self.code = code
        super().__init__(message)


def load_json_strict(path: Path):
    def pairs(items):
        result = {}
        for key, value in items:
            if key in result:
                raise FrontendError("JSON_ERROR", "duplicate object key: " + key)
            result[key] = value
        return result
    def nonfinite(value):
        raise FrontendError("JSON_ERROR", "nonfinite JSON number: " + value)
    def finite_float(value):
        result = float(value)
        if not math.isfinite(result):
            nonfinite(value)
        return result
    return json.loads(Path(path).read_text(), object_pairs_hook=pairs,
                      parse_constant=nonfinite, parse_float=finite_float)


def read_bound_metadata(model: Path, assets: Path):
    evidence = load_json_strict(assets)
    if (evidence["status"] != "ASSETS_VERIFIED" or
            model.stat().st_size != 455179648 or file_sha(model) != MODEL_SHA):
        raise FrontendError("IDENTITY_ERROR", "real model SHA/size mismatch")
    source = EXPERIMENT / "tools/m007_deploy_identity.py"
    if file_sha(source) != TOOLS_READER_SHA:
        raise FrontendError("IDENTITY_ERROR", "bounded metadata reader source changed")
    spec = importlib.util.spec_from_file_location("m007_bound_metadata_reader", source)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    with model.open("rb") as stream:
        reader = module.Metadata(stream.read(4 << 20))
    if reader.take(4) != b"GGUF" or reader.number("I") != 3 or reader.number("Q") != 153:
        raise FrontendError("IDENTITY_ERROR", "GGUF header")
    count = reader.number("Q")
    if count > 10000:
        raise FrontendError("IDENTITY_ERROR", "GGUF metadata count")
    metadata, records = {}, {}
    for _ in range(count):
        key = reader.string()
        if key in metadata:
            raise FrontendError("IDENTITY_ERROR", "duplicate GGUF metadata key")
        begin = reader.pos
        kind = reader.number("I")
        value = reader.value(kind)
        digest = hashlib.sha256(reader.data[begin:reader.pos]).hexdigest()
        if evidence["gguf"]["metadata"].get(key, {}).get("raw_value_sha256") != digest:
            raise FrontendError("IDENTITY_ERROR", "GGUF metadata identity: " + key)
        metadata[key] = value
        records[key] = digest
    if (hashlib.sha256(metadata["ggmlc.graph_spec"].encode()).hexdigest() != GRAPH_SHA or
            "ggmlc.decision" in metadata or metadata.get("tokenizer.ggml.pre") != "gpt2"):
        raise FrontendError("IDENTITY_ERROR", "expected graph/explicit Laya compatibility recipe")
    for key in ("laya.temperature", "laya.temperature_by_options", "laya.cls_token_id",
                "laya.sep_token_id", "laya.pad_token_id", "laya.mask_token_id"):
        if key not in metadata:
            raise FrontendError("IDENTITY_ERROR", "missing decisive model metadata: " + key)
    return metadata, records


class NativeFrontend:
    def __init__(self, binary: Path, model: Path, assets: Path, work: Path):
        began = time.perf_counter_ns()
        self.call_events = []
        self.binary, self.model = Path(binary).resolve(), Path(model).resolve()
        work = Path(work)
        work.mkdir(parents=True, exist_ok=True)
        identity_path = self.binary.with_suffix(".identity.json")
        identity = load_json_strict(identity_path)
        if file_sha(self.binary) != identity["binary_sha256"]:
            raise FrontendError("IDENTITY_ERROR", "native binary identity")
        for name, expected in identity["source_sha256"].items():
            if file_sha(EXPERIMENT / name) != expected:
                raise FrontendError("IDENTITY_ERROR", "native source identity: " + name)
        metadata, self.metadata_sha256 = read_bound_metadata(self.model, Path(assets))
        bundle = {"metadata_int": {key: value for key, value in metadata.items()
                                   if key.startswith("laya.") and type(value) is int},
                  "metadata_str": {key: value for key, value in metadata.items()
                                   if key.startswith("laya.") and isinstance(value, str)},
                  "tokenizer": {key: value for key, value in metadata.items()
                                if key.startswith("tokenizer.")},
                  "model_path": str(self.model), "model_sha256": MODEL_SHA}
        self.bundle_path = work / "native_metadata_bundle.json"
        self.bundle_path.write_text(json.dumps(bundle, ensure_ascii=False, allow_nan=False))
        self.stderr = (work / "native_stderr.log").open("w")
        self.process = subprocess.Popen([str(self.binary), str(self.bundle_path)],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=self.stderr,
            text=True, encoding="utf-8", bufsize=1)
        line = self.process.stdout.readline()
        if not line or json.loads(line).get("status") != "NATIVE_FRONTEND_READY":
            self.close()
            raise FrontendError("NATIVE_ERROR", "native helper did not become ready")
        self.binary_sha256 = identity["binary_sha256"]
        self.initialization_ns = time.perf_counter_ns() - began

    def __enter__(self):
        return self

    def __exit__(self, *unused):
        self.close()

    def close(self):
        if hasattr(self, "process"):
            if self.process.poll() is None:
                self.process.stdin.close()
                self.process.wait(timeout=5)
            self.process.stdout.close()
        if hasattr(self, "stderr"):
            self.stderr.close()

    def call(self, value):
        began = time.perf_counter_ns()
        self.process.stdin.write(json.dumps(value, ensure_ascii=False, allow_nan=False) + "\n")
        self.process.stdin.flush()
        line = self.process.stdout.readline()
        if not line:
            raise FrontendError("NATIVE_ERROR", "native helper ended without a response")
        result = json.loads(line)
        self.call_events.append({"op": value.get("op"), "elapsed_ns": time.perf_counter_ns() - began,
                                 "status": result.get("status")})
        if result.get("status") != "OK":
            raise FrontendError(result.get("code", "NATIVE_ERROR"), result.get("message", "failed"))
        return result

    def encode(self, request):
        if not isinstance(request, dict) or "state" not in request or "questions" not in request:
            raise FrontendError("JSON_ERROR", "state and questions are required")
        return self.call({"op": "encode", "state": request["state"],
                          "questions": request["questions"]})

    def decode(self, question_id, question, logits18, marker_mask, qtype):
        logits = np.asarray(logits18)
        if logits.dtype != np.dtype("<f4") or logits.shape != (18,):
            raise FrontendError("FRAME_ERROR", "exact 18 F32 logits required")
        if not np.isfinite(logits).all():
            raise FrontendError("NUMERIC_ERROR", "nonfinite logit; no uniform fallback")
        return self.call({"op": "decode", "question_id": question_id, "question": question,
            "logits_u32": logits.view("<u4").tolist(), "marker_mask": list(marker_mask),
            "qtype": qtype})


def cpu_frontend_identity(native: NativeFrontend) -> Identity:
    sources = {str(path.relative_to(EXPERIMENT)): file_sha(path)
               for path in sorted(Path(__file__).parent.iterdir())
               if path.suffix in (".py", ".cpp", ".json")}
    build = hashlib.sha256(json.dumps({"sources": sources,
        "native_binary": native.binary_sha256, "metadata": native.metadata_sha256},
        sort_keys=True).encode()).hexdigest()
    return Identity(MODEL_SHA, GRAPH_SHA, REFERENCE_SHA, SCHEMA_SHA256, build)


def prepare_json_requests(source: Path, native: NativeFrontend, output: Path,
                          request_id: int, generation: int):
    data = load_json_strict(source)
    encoded = native.encode(data)
    if (type(request_id) is not int or type(generation) is not int or
            not 0 <= request_id < 1 << 64 or not 0 <= generation < 1 << 32 or
            request_id + len(encoded["questions"]) - 1 >= 1 << 64):
        raise FrontendError("IDENTITY_ERROR", "request_id/generation would overflow")
    identity = cpu_frontend_identity(native)
    output = Path(output)
    output.mkdir(parents=True, exist_ok=False)
    records = []
    model_open_began = time.perf_counter_ns()
    with GGUFWeights(native.model) as weights:
        model_handle_initialize_ns = time.perf_counter_ns() - model_open_began
        for index, item in enumerate(encoded["questions"]):
            request = Request(request_id + index, generation, identity, item["qtype"],
                item["attention_mask"], item["markers"], item["marker_mask"],
                item["candidate_count"], 0x100000000, 0x200000000)
            request.validate()
            ids = np.asarray(item["token_ids"], dtype="<i4")
            began = time.perf_counter_ns()
            h0 = prepare_h0(ids, weights)
            reference_h0_ns = time.perf_counter_ns() - began
            folder = output / f"q{index:04d}"
            folder.mkdir()
            files = {"request.bin": encode_request(request), "token_ids.i32.bin": ids.tobytes(),
                     "H0.bin": h0.tobytes()}
            for name, value in files.items():
                (folder / name).write_bytes(value)
            records.append({"question_id": item["question_id"], "question": data["questions"][item["question_id"]],
                "request_id": request.request_id, "generation": generation,
                "qtype": request.qtype, "candidate_count": request.candidate_count,
                "live_tokens": item["live_tokens"], "folder": folder.name,
                "reference_h0_elapsed_ns": reference_h0_ns,
                "files": {name: {"bytes": len(value), "sha256": hashlib.sha256(value).hexdigest()}
                          for name, value in files.items()}})
    manifest = {"schema": "m007-strict-s128-frontend-v1", "status": "H0_PREPARED_NO_DEVICE",
        "device": "NOT_RUN", "source_json_sha256": file_sha(source), "source_json": data,
        "source_json_canonical_sha256": hashlib.sha256(json.dumps(data, ensure_ascii=False,
            separators=(",", ":"), allow_nan=False).encode()).hexdigest(),
        "identity": asdict(identity), "native_binary_sha256": native.binary_sha256,
        "functional_stage_timing": {"native_session_initialize_ns": native.initialization_ns,
            "model_handle_initialize_ns": model_handle_initialize_ns,
            "scope": "single functional execution; cold loads included where stated; not CPU acceptance or benchmark"},
        "recipe_mode": "explicit_native_laya_compat", "questions": records}
    (output / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2,
                                                       allow_nan=False) + "\n")
    return manifest


def decode_prepared(prepared: Path, index: int, payload: bytes, native: NativeFrontend):
    prepared = Path(prepared).resolve()
    manifest = load_json_strict(prepared / "manifest.json")
    if manifest["native_binary_sha256"] != native.binary_sha256:
        raise FrontendError("IDENTITY_ERROR", "prepared native identity mismatch")
    canonical = hashlib.sha256(json.dumps(manifest["source_json"], ensure_ascii=False,
        separators=(",", ":"), allow_nan=False).encode()).hexdigest()
    if canonical != manifest["source_json_canonical_sha256"]:
        raise FrontendError("IDENTITY_ERROR", "prepared source JSON changed")
    if type(index) is not int or not 0 <= index < len(manifest["questions"]):
        raise FrontendError("FRAME_ERROR", "prepared question index")
    record = manifest["questions"][index]
    if record["question"] != manifest["source_json"]["questions"].get(record["question_id"]):
        raise FrontendError("IDENTITY_ERROR", "prepared question/source association mismatch")
    folder = (prepared / record["folder"]).resolve()
    if not folder.is_relative_to(prepared) or set(record["files"]) != {"request.bin", "token_ids.i32.bin", "H0.bin"}:
        raise FrontendError("IDENTITY_ERROR", "prepared artifact path")
    for name, identity in record["files"].items():
        path = folder / name
        if path.stat().st_size != identity["bytes"] or file_sha(path) != identity["sha256"]:
            raise FrontendError("IDENTITY_ERROR", "prepared request data changed: " + name)
    request = decode_request((folder / "request.bin").read_bytes(), Identity(**manifest["identity"]))
    if request.identity != cpu_frontend_identity(native):
        raise FrontendError("IDENTITY_ERROR", "prepared model/reference/schema/build is stale")
    if (request.request_id != record["request_id"] or request.generation != record["generation"] or
            request.qtype != record["qtype"] or request.candidate_count != record["candidate_count"]):
        raise FrontendError("IDENTITY_ERROR", "prepared question/request association mismatch")
    if len(payload) != 72:
        raise FrontendError("FRAME_ERROR", "18-logit F32 payload must be 72 bytes")
    result = native.decode(record["question_id"], record["question"],
        np.frombuffer(payload, dtype="<f4"), request.marker_mask, request.qtype)
    result.update(request_id=request.request_id, generation=request.generation,
                  qtype=request.qtype, candidate_count=request.candidate_count,
                  device="NOT_RUN", scope="business_decode_only_no_forward_execution")
    return result
