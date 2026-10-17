#!/usr/bin/env python3
"""Build a distinct Q8S2 package from checked immutable GGUF payloads.

An unchanged payload may be copied from a previously independently verified
package. Every output BO and the complete preimage/source inventory are hashed
again. The AUX header and generated table are new candidate artifacts.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil

from export_gguf import (BO_NAMES, MODEL_SHA, ROOT, canonical_json, file_sha,
                         sha256, tool_manifest,
                         write_generated_header, write_model_header)

MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
T3 = Path("results/compute_throughput_optimization_20261010")
SOFTWARE_SOURCES = (
    Path("tools/export_gguf.py"), Path("tools/export_q8_session_v2.py"),
    Path("host/q8_session_encoder_v2.h"),
    Path("host/q8_session_encoder_v2.cpp"),
    Path("tests/full_model_package_test.py"),
    Path("tests/q8_session_encoder_v2_test.cpp"),
    T3 / "tools/t3_static_model.py",
    T3 / "tools/t3_offline_session.py",
    T3 / "tools/t3_real_session.py",
    T3 / "tools/t3_static_model_test.py",
    T3 / "tools/t3_offline_session_test.py",
)


def contract_protocol_sha() -> str:
    contract = (ROOT / T3 / "source/design.md").read_bytes()
    start = contract.index(b"### 4.3 ")
    end = contract.index(b"### 4.5 ", start)
    return sha256(contract[start:end])


def verify_source(package: Path) -> dict:
    manifest = json.loads((package / "manifest.json").read_bytes())
    if manifest["schema"] != "laya-model-p2-v1" or len(manifest["tensors"]) != 153:
        raise ValueError("source package inventory/schema")
    if len(manifest["weights"]) != 124 or sum(
            x["dtype"] == 8 for x in manifest["weights"]) != 122:
        raise ValueError("source package weight inventory")
    if manifest["source_model"]["sha256"] != MODEL_SHA:
        raise ValueError("source package GGUF identity")
    for key in BO_NAMES:
        record = manifest["bo"][key]
        path = package / record["file"]
        if path.stat().st_size != record["size"] or file_sha(path) != record["sha256"]:
            raise ValueError(f"source package BO mismatch: {key}")
    return manifest


def build(payload_package: Path, out: Path, hardware_inputs: Path) -> dict:
    if out.exists():
        raise ValueError("output must be a new directory")
    source = verify_source(payload_package)
    protocol_sha = contract_protocol_sha()
    hardware_raw = hardware_inputs.read_bytes()
    hardware = json.loads(hardware_raw)
    if hardware["schema"] != "q8_session_v2_hardware_source_inputs_v1" or \
            hardware["top"] != "q8_tm1tn8_session_dma_v2" or \
            len(hardware["files"]) != 20:
        raise ValueError("hardware source input inventory/schema")
    for item in hardware["files"]:
        path = ROOT / item["relative_path"]
        if path.stat().st_size != item["bytes"] or file_sha(path) != item["sha256"]:
            raise ValueError("hardware source checkpoint drift: " + item["relative_path"])
    source_paths = sorted(set(SOFTWARE_SOURCES) |
                          {Path(x["relative_path"]) for x in hardware["files"]})
    snapshots = [{"path": p.as_posix(), "sha256": file_sha(ROOT / p)}
                 for p in source_paths]
    if len({x["path"] for x in snapshots}) != len(snapshots):
        raise ValueError("duplicate source inventory path")
    out.mkdir(parents=True)
    try:
        (out / "hardware_source_inputs.json").write_bytes(hardware_raw)
        for name in BO_NAMES:
            shutil.copyfile(payload_package / source["bo"][name]["file"],
                            out / f"{name}.bin")
        numeric = (payload_package / source["tag_preimages"]["numeric"]["file"]).read_bytes()
        (out / "numeric_preimage.txt").write_bytes(numeric)
        numeric_sha = sha256(numeric)
        if numeric_sha != source["tag_preimages"]["numeric"]["sha256"]:
            raise ValueError("numeric preimage drift")
        sizes = {name: (out / f"{name}.bin").stat().st_size for name in BO_NAMES}
        layout = {
            "schema": "laya-layout-q8-session-v2",
            "source_model_sha256": MODEL_SHA,
            "bo_sizes": sizes,
            "tensors": source["tensors"], "weights": source["weights"],
            "q8s2_protocol": {
                "contract_sections": "4.3-4.4",
                "contract_sha256": protocol_sha,
                "descriptor_magic": "Q8S2", "descriptor_bytes": 1024,
                "observed_magic": "Q8O2", "observed_bytes": 131072,
                "binding_context_beats_u64": 18,
                "bo_roles": [0, 2, 3, 4, 5],
                "commands": ["LOAD_W", "RUN_TILE", "REGISTER_MODEL", "REVOKE_MODEL"],
                "profiles": ["STRICT", "VALIDATED_STATIC_MODEL_V1"],
            },
        }
        layout_raw = canonical_json(layout)
        (out / "layout_preimage.json").write_bytes(layout_raw)
        layout_sha = sha256(layout_raw)
        build_preimage = {
            "schema": "laya-build-q8-session-v2",
            "model_sha256": MODEL_SHA,
            "numeric_sha256": numeric_sha,
            "layout_sha256": layout_sha,
            "sources": snapshots,
            "hardware_source_inputs_sha256": sha256(hardware_raw),
            "tool_config": {**tool_manifest(), "q8s2_hardware": {
                key: value for key, value in hardware.items() if key != "files"}},
        }
        build_raw = canonical_json(build_preimage)
        (out / "build_preimage.json").write_bytes(build_raw)
        build_sha = sha256(build_raw)
        tags = {"model": MODEL_SHA[:32], "numeric": numeric_sha[:32],
                "layout": layout_sha[:32], "build": build_sha[:32]}
        write_model_header(out / "aux.bin", tags)
        bo = {name: {"file": f"{name}.bin", "size": sizes[name],
                     "sha256": file_sha(out / f"{name}.bin")}
              for name in BO_NAMES}
        if any(bo[name]["sha256"] != source["bo"][name]["sha256"]
               for name in BO_NAMES if name != "aux"):
            raise ValueError("unchanged payload BO drift")
        with (out / "aux.bin").open("rb") as f:
            header = f.read(128)
        with (payload_package / source["bo"]["aux"]["file"]).open("rb") as f:
            old_header = f.read(128)
            if f.read() != (out / "aux.bin").read_bytes()[128:]:
                raise ValueError("AUX payload drift")
        if header == old_header:
            raise ValueError("new candidate has no new AUX identity")
        manifest = {
            "schema": "laya-model-p2-v1",
            "candidate_schema": "laya-q8-session-v2-package",
            "source_model": source["source_model"],
            "tags": tags,
            "tag_preimages": {
                "numeric": {"file": "numeric_preimage.txt", "sha256": numeric_sha},
                "layout": {"file": "layout_preimage.json", "sha256": layout_sha},
                "build": {"file": "build_preimage.json", "sha256": build_sha},
            },
            "bo": bo, "tensors": source["tensors"],
            "weights": source["weights"],
            "slide_bias_verification": source["slide_bias_verification"],
            "generated_header": "laya_model_layout_generated.h",
            "hardware_source_inputs": {"file": "hardware_source_inputs.json",
                                       "sha256": sha256(hardware_raw)},
        }
        write_generated_header(out / manifest["generated_header"],
                               source["tensors"], source["weights"], tags,
                               sizes, full_build_sha=build_sha)
        (out / "manifest.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8")
        for item in snapshots:
            if file_sha(ROOT / item["path"]) != item["sha256"]:
                raise ValueError("source changed during package build: " + item["path"])
        if contract_protocol_sha() != protocol_sha:
            raise ValueError("protocol contract changed during package build")
        return {"directory": str(out), "build_sha256": build_sha,
                "layout_sha256": layout_sha, "tags": tags,
                "manifest_sha256": file_sha(out / "manifest.json"), "bo": bo}
    except BaseException:
        shutil.rmtree(out)
        raise


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--payload-package", type=Path,
                    default=ROOT / "build/model-cpu-embedding-ln-v4-20261010")
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--hardware-inputs", type=Path, required=True)
    args = ap.parse_args()
    print(json.dumps(build(args.payload_package.resolve(), args.out.resolve(),
                           args.hardware_inputs.resolve()),
                     sort_keys=True))


if __name__ == "__main__":
    main()
