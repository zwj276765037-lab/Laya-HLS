#!/usr/bin/env python3
"""Replay H0 and compact CPU tail against existing independently frozen gold.

No full-model oracle is run. Frozen decision hidden is an input, while all tail
checkpoints/final18 are read-only expected values from an earlier whole graph.
"""
from __future__ import annotations
import argparse
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
import platform
import sys
import time
import traceback

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "host"))
from m007_deploy.contract import (Identity, Request, SCHEMA_SHA256, encode_request,
                                  decode_request)
from m007_deploy.cpu_contract import (GGUFWeights, MODEL_SHA, REFERENCE_SHA,
    file_sha, prepare_h0, gather_tail_cpu_contract, finish_tail_cpu_contract)

ABI = ROOT / "reference/runs/typed_q8_ref_20261005/abi_replay"
GOLD = ROOT / "results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle"
LEGACY_ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")
MANIFEST_SHA = "8588b69436e50c7500c22c677e174e77001e1e92e656bee2f46e1a88f4abb29a"


def require(condition, text):
    if not condition:
        raise AssertionError(text)


class Fixtures:
    def __init__(self, asset_report: Path):
        assets = json.loads(asset_report.read_text())
        require(assets["status"] == "ASSETS_VERIFIED", "verified external assets required")
        report_path = GOLD / "full_forward_oracle_report.json"
        expected = assets["files"][str(report_path.relative_to(ROOT))]
        require(file_sha(report_path) == expected["sha256"], "gold report SHA")
        self.report = json.loads(report_path.read_text())
        require(self.report["reference_sha256"] == REFERENCE_SHA, "gold strict reference SHA")
        require(self.report["status"] == "ORACLE_GENERATED_B1_B2_CONSISTENT_NO_DUT_COMPARISON",
                "original gold generation status")
        manifest_path = ABI / "manifest.json"
        require(file_sha(manifest_path) == MANIFEST_SHA, "original ABI source manifest SHA")
        manifest = json.loads(manifest_path.read_text())
        self.nodes = {node["id"]: node for node in manifest["tensors"]}
        self.model = Path(assets["model"]["path"])
        self.checked = {str(report_path): expected, str(manifest_path):
                        {"sha256": MANIFEST_SHA, "bytes": manifest_path.stat().st_size}}

    def input(self, name):
        item = self.nodes[name]
        path = (ABI / item["path"]).resolve()
        require(path.is_relative_to(ABI.resolve()), "captured input path escape")
        data = path.read_bytes()
        require(hashlib.sha256(data).hexdigest() == item["sha256"], "source input SHA " + name)
        require(len(data) == item["storage_span_bytes"], "source input span")
        self.checked[str(path)] = {"sha256": item["sha256"], "bytes": len(data)}
        return np.ndarray(tuple(item["ggml_ne"]),
                          dtype={"f32": "<f4", "i32": "<i4"}[item["dtype"]],
                          buffer=data, strides=tuple(item["ggml_nb_bytes"])).copy()

    def checkpoint(self, scenario, name):
        items = {item["name"]: item for item in self.report["runs"][scenario]["checkpoints"]}
        item = items[name]
        old = Path(item["path"])
        # Explicit path rebinding preserves original identity and never writes legacy.
        path = ROOT / old.relative_to(LEGACY_ROOT)
        require(path.parent == GOLD / scenario, "frozen checkpoint path outside scenario")
        data = path.read_bytes()
        require(len(data) == item["bytes"] and hashlib.sha256(data).hexdigest() == item["sha256"],
                "checkpoint SHA/length " + scenario + "/" + name)
        self.checked[str(path)] = {"sha256": item["sha256"], "bytes": len(data),
                                   "original_path": str(old)}
        return np.frombuffer(data, dtype="<f4").reshape(item["shape"]).copy()


def compare(actual, expected, name):
    a, b = np.asarray(actual, dtype="<f4"), np.asarray(expected, dtype="<f4")
    require(a.shape == b.shape, "shape " + name)
    diff = a.view("<u4") != b.view("<u4")
    require(not diff.any(), f"bit mismatch {name}: {int(diff.sum())}/{a.size}")
    return {"name": name, "elements": int(a.size), "bit_mismatches": int(diff.sum()),
            "sha256": hashlib.sha256(a.tobytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assets", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"status": "RUNNING", "backend": "cpu_contract", "board": "NOT_RUN",
              "full_graph_recomputed": False, "python": platform.python_version(),
              "numpy": np.__version__, "libc": platform.libc_ver(), "scenarios": []}
    started = time.monotonic()
    try:
        fixtures = Fixtures(args.assets)
        ids = fixtures.input("ir_211")[:, :, 0, 0].T
        mask = fixtures.input("ir_212")[:, :, 0, 0].T
        markers = fixtures.input("ir_213")[:, :, 0, 0].T
        marker_mask = fixtures.input("ir_214")[:, :, 0, 0].T
        qtypes = fixtures.input("ir_215")[:, 0, 0, 0]
        require(ids.shape == (2, 128), "B2 captured request shape")
        require(np.isin(mask, (0, 1)).all() and np.isin(marker_mask, (0, 1)).all(),
                "frozen binary masks before integer conversion")
        source_identity = {str(path.relative_to(ROOT)): file_sha(path)
                           for path in sorted((ROOT / "host/m007_deploy").glob("*.py"))}
        identity = Identity(MODEL_SHA,
            "f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9",
            REFERENCE_SHA, SCHEMA_SHA256,
            hashlib.sha256(json.dumps(source_identity, sort_keys=True).encode()).hexdigest())
        report["identity"] = asdict(identity)
        report["identity_scope"] = "CPU_CONTRACT_ONLY; numeric=reference_source, layout=Host schema; not device build tags"
        report["sources"] = source_identity
        with GGUFWeights(fixtures.model) as weights:
            for batch in (0, 1):
                scenario = f"B1_from_b{batch}_S128"
                output = args.output / scenario
                output.mkdir(exist_ok=True)
                req = Request(100 + batch, 1, identity, int(qtypes[batch]),
                    tuple(int(v) for v in mask[batch]),
                    tuple(int(v) - batch * 128 for v in markers[batch]),
                    tuple(int(v) for v in marker_mask[batch]),
                    int(marker_mask[batch].sum()), 0x100000000, 0x200000000)
                req.validate()
                source = fixtures.checkpoint(scenario, "decision_01_out")[0]
                h0 = prepare_h0(ids[batch].astype("<i4"), weights)
                checks = [compare(h0, fixtures.checkpoint(scenario, "embedding_norm")[0], "H0")]
                payload = gather_tail_cpu_contract(source, req)
                require(len(payload) == 69632, "68KiB payload")
                (output / "request.bin").write_bytes(encode_request(req))
                require(decode_request((output / "request.bin").read_bytes(), identity) == req,
                        "serialized request identity")
                (output / "tail.bin").write_bytes(payload)
                (output / "H0.bin").write_bytes(h0.tobytes())
                (output / "identity.json").write_text(json.dumps(asdict(identity), indent=2) + "\n")

                def checkpoint(name, value):
                    expected = fixtures.checkpoint(scenario, name)[0]
                    checks.append(compare(value, expected, name))

                result = finish_tail_cpu_contract(payload, req, weights, checkpoint)
                checks.append(compare(result.raw_cls, source[0], "raw_CLS_preserved"))
                checks.append(compare(result.logits18, fixtures.checkpoint(scenario, "final18")[0],
                                      "returned_final18"))
                (output / "actual_logits18.bin").write_bytes(result.logits18.tobytes())
                require(np.frombuffer(payload, dtype="<f4")[16 * 1024:].tobytes() == source[0].tobytes(),
                        "raw CLS payload unchanged after CPU tail")
                report["scenarios"].append({"name": scenario, "qtype": req.qtype,
                    "candidates": req.candidate_count, "checks": checks,
                    "frame_sha256": hashlib.sha256(payload).hexdigest(),
                    "logits18_u32": result.logits18.view("<u4").tolist()})
                print(f"M007_FROZEN_SCENARIO_PASS {scenario} checkpoints={len(checks)} logits=18", flush=True)
            report["weight_spans"] = weights.checked
        report["checked_fixtures"] = fixtures.checked
        report["status"] = "PASS_CPU_CONTRACT"
        print("M007_FROZEN_REPLAY_PASS scenarios=2 final18_bits=36 full_graph_recomputed=0 board=NOT_RUN", flush=True)
        return 0
    except Exception as error:
        report.update(status="FAIL", error=f"{type(error).__name__}: {error}",
                      traceback=traceback.format_exc())
        print(report["error"], file=sys.stderr, flush=True)
        return 1
    finally:
        report["elapsed_s"] = time.monotonic() - started
        (args.output / "report.json").write_text(json.dumps(report, indent=2, allow_nan=False) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
