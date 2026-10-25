#!/usr/bin/env python3
"""Bounded, read-only discovery of the real M007 model/reference/tokenizer/recipe.

Reads two known small manifests and at most 4 MiB of GGUF metadata. The optional
single complete model hash reads the 455 MB model once, never a run-tree scan.
Run under the common M007 heavy guard when hashing or computing identities.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import platform
import struct

ROOT = Path(__file__).resolve().parents[1]
MODEL_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"
GRAPH_SHA = "f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9"
DEFAULT_MODEL = (ROOT.parents[3] / "model/quantized/gguf/mys/"
                 "laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf")


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for data in iter(lambda: stream.read(8 << 20), b""):
            value.update(data)
    return value.hexdigest()


class Metadata:
    def __init__(self, data: bytes):
        self.data, self.pos = data, 0

    def take(self, count):
        if count < 0 or self.pos + count > len(self.data):
            raise ValueError("GGUF metadata exceeds bounded 4 MiB read")
        result = self.data[self.pos:self.pos + count]
        self.pos += count
        return result

    def number(self, fmt):
        return struct.unpack("<" + fmt, self.take(struct.calcsize(fmt)))[0]

    def string(self):
        return self.take(self.number("Q")).decode("utf-8")

    def value(self, kind, depth=0):
        if depth > 2:
            raise ValueError("GGUF nested metadata depth")
        if kind == 8:
            return self.string()
        if kind == 9:
            element, count = self.number("I"), self.number("Q")
            if count > 100000:
                raise ValueError("GGUF metadata array count")
            return [self.value(element, depth + 1) for _ in range(count)]
        formats = {0: "B", 1: "b", 2: "H", 3: "h", 4: "I", 5: "i", 6: "f",
                   7: "?", 10: "Q", 11: "q", 12: "d"}
        if kind not in formats:
            raise ValueError("unsupported GGUF metadata kind")
        return self.number(formats[kind])

    def inspect(self):
        if self.take(4) != b"GGUF" or self.number("I") != 3:
            raise ValueError("GGUF magic/version")
        tensors, count = self.number("Q"), self.number("Q")
        if tensors != 153 or count > 10000:
            raise ValueError("GGUF tensor/metadata count")
        records = {}
        for _ in range(count):
            key = self.string()
            if key in records:
                raise ValueError("duplicate GGUF metadata key")
            begin = self.pos
            kind = self.number("I")
            value = self.value(kind)
            item = {"type": kind, "raw_value_sha256": hashlib.sha256(
                self.data[begin:self.pos]).hexdigest()}
            if isinstance(value, list):
                item["count"] = len(value)
            elif isinstance(value, str):
                item["utf8_bytes"] = len(value.encode())
                item["utf8_sha256"] = hashlib.sha256(value.encode()).hexdigest()
                if len(value) <= 16384:
                    item["value"] = value
            else:
                item["value"] = value
            records[key] = item
        return {"tensor_count": tensors, "metadata_count": count,
                "metadata_end": self.pos, "metadata": records}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gguf", type=Path, default=DEFAULT_MODEL)
    parser.add_argument("--hash-model", action="store_true")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    report = {"schema": "laya-m007-asset-evidence-v1", "host": platform.node(),
              "python": platform.python_version(), "files": {}, "board": "NOT_RUN"}
    paths = [ROOT / "tests/full_reference.py", ROOT / "tests/full_forward_oracle.py",
             ROOT / "tests/full_fixture_test.py", ROOT / "host/cpu_embedding_raw.cpp",
             ROOT / "host/laya_host.cpp", ROOT / "hardware_agent/task.md",
             ROOT / "reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json",
             ROOT / "reference/runs/typed_q8_ref_20261005/gguf_inventory.json",
             ROOT / "results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/full_forward_oracle_report.json"]
    for path in paths:
        item = {"path": str(path), "exists": path.is_file()}
        if path.is_file():
            item.update(bytes=path.stat().st_size, sha256=digest(path))
        report["files"][str(path.relative_to(ROOT))] = item
    path = args.gguf.resolve()
    model = {"path": str(path), "exists": path.is_file(), "expected_sha256": MODEL_SHA,
             "whole_file_sha256": None, "whole_file_verified": False}
    if path.is_file():
        model.update(bytes=path.stat().st_size, mtime_ns=path.stat().st_mtime_ns)
        if args.hash_model:
            model["whole_file_sha256"] = digest(path)
            model["whole_file_verified"] = (model["whole_file_sha256"] == MODEL_SHA and
                                            model["bytes"] == 455179648)
        with path.open("rb") as stream:
            report["gguf"] = Metadata(stream.read(4 << 20)).inspect()
        graph = report["gguf"]["metadata"].get("ggmlc.graph_spec", {})
        report["graph_verified"] = graph.get("utf8_sha256") == GRAPH_SHA
        report["tokenizer_keys"] = [key for key in report["gguf"]["metadata"]
                                    if key.startswith("tokenizer.")]
        report["recipe_keys"] = [key for key in report["gguf"]["metadata"] if
                                 any(word in key.lower() for word in
                                     ("recipe", "temperature", "confidence", "formatter", "special"))]
    report["model"] = model
    report["status"] = ("ASSETS_VERIFIED" if model["whole_file_verified"] and
                         report.get("graph_verified") else "ASSETS_PARTIAL")
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False, allow_nan=False) + "\n")
    print(json.dumps({"status": report["status"], "model": model,
                      "graph_verified": report.get("graph_verified"),
                      "recipe_keys": report.get("recipe_keys"),
                      "output": str(args.output)}))
    return 0 if report["status"] == "ASSETS_VERIFIED" else 1


if __name__ == "__main__":
    raise SystemExit(main())
