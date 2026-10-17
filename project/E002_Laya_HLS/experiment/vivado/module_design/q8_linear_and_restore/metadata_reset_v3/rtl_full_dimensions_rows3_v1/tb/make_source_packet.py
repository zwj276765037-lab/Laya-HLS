#!/usr/bin/env python3
"""Bind the dormant three-row Scorer source and immutable inputs read-only."""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ISOLATED = HERE.parent
MODULE = ISOLATED.parent
BASE = HERE.parents[5]
MODEL = BASE / "build/model-attention-rtl-repair-20261008"
ACCEPTED = BASE / "results/engineering_p2/full_cpu_final_20261007"
REVIEW = BASE / "results/attention_rtl_repair_20261008"
RTL = MODULE / "runs/csynth_local_v1/work/hls/syn/verilog"
IP = MODULE / "runs/csynth_local_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
ACT_TB = MODULE / "rtl_act_static_v1/tb"
V6 = MODULE / "rtl_full_dimensions_v1/source_binding_v6/source_packet.json"
STATIC = ISOLATED / "source/static_contract.json"
GATE = REVIEW / "reviewer_q8_full_dimensions_tail_performance_source_preparation_release.json"
OUT = ISOLATED / "source/source_packet.json"
V6_SHA256 = "872b13e1efa71cff1aee87873b918d4e595d8046caf6ec4da9cc9917a3a91611"
STATIC_SHA256 = "7270c08d4a2c360b708ed1fe08bf164099f8be94ae382d3f1f9023247d1cee4c"
GATE_SHA256 = "68299aeb92ac6c5672f616538664f7e7cff617df3809b4a28fb7711c5d044d61"


def record(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(path)
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "mode": oct(path.stat().st_mode & 0o777), "sha256": h.hexdigest()}


def exact(path: Path, digest: str) -> dict:
    item = record(path)
    if item["sha256"] != digest:
        raise ValueError(f"frozen identity drift: {path}")
    return item


def construct(created_utc: str) -> dict:
    v6_record = exact(V6, V6_SHA256)
    static_record = exact(STATIC, STATIC_SHA256)
    gate_record = exact(GATE, GATE_SHA256)
    inherited = json.loads(V6.read_text())
    static = json.loads(STATIC.read_text())
    model = json.loads((MODEL / "manifest.json").read_text())
    old = {item["path"]: item for item in inherited["immutable_files"]}
    if (inherited["counts"]["physical_pages"] != 341 or
        static["schema"] != "q8_full_scorer_rows3_static_contract_v1" or
        static["authority"]["sha256"] != GATE_SHA256 or
        static["inherited_v6"]["sha256"] != V6_SHA256 or
        static["shape"] != {"B": 2, "S": 128, "batch": 1, "row0": 13,
                            "rows": 3, "K": 1024, "N": 1024, "G": 32,
                            "T": 128} or
        static["work_per_run"]["logical_MAC"] != 3145728 or
        static["work_per_run"]["issued_and_retired_groups"] != 4096 or
        static["trace"]["observed_valid_bytes"] != 5312):
        raise ValueError("three-row static contract drift")

    verilog = sorted(RTL.glob("*.v"))
    dat = sorted(RTL.glob("*.dat"))
    wrappers = sorted(IP.glob("*/sim/*_ip.vhd"))
    if (len(verilog), len(dat), len(wrappers)) != (230, 108, 7):
        raise ValueError("inherited generated closure counts")
    generated = [record(path) for path in verilog + dat + wrappers]
    for item in generated:
        prior = old.get(item["path"])
        if prior is None or any(item[key] != prior[key] for key in
                                ("bytes", "mode", "sha256")):
            raise ValueError(f"generated closure differs from V6: {item['path']}")

    local = [ISOLATED / "source" / name for name in
             ("design.md", "results.md", "static_contract.json", "observer_binding.json")]
    local.append(ISOLATED / "rtl/README.md")
    local += sorted(path for path in HERE.iterdir() if
                    path.is_file() and path.suffix in
                    {".py", ".sh", ".sv", ".svh", ".cpp"})
    if len(local) != 18:
        raise ValueError(f"local source set drift: {len(local)}")
    local_records = [record(path) for path in local]

    bo = [MODEL / model["bo"][name]["file"] for name in
          ("w_q0", "w_q1", "w_scale", "aux")]
    gguf = Path(model["source_model"]["path"])
    checkpoints = [ACCEPTED / family / name for family in
                   ("oracle/B2_S128", "dut/dut/B2_S128") for name in
                   ("marker_norm.f32.bin", "scorer_fc1_baked.f32.bin")]
    imported = [MODULE / "source" / name for name in
                ("q8_joint_tm4tn8.cpp", "q8_joint_tm4tn8.h", "q8_joint_abi.h")]
    imported += [ACT_TB / name for name in
                 ("q8_static_axi_stall.sv", "q8_axi_monitor.sv",
                  "q8_axi_port.sv", "q8_axi_lite_master.sv")]
    imported += [REVIEW / "d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv",
                 BASE / "tests/full_reference.py", MODEL / "manifest.json",
                 MODEL / "laya_model_layout_generated.h", *bo, gguf, *checkpoints]
    imported_records = [record(path) for path in imported]
    for item in imported_records:
        prior = old.get(item["path"])
        if prior is None or any(item[key] != prior[key] for key in
                                ("bytes", "mode", "sha256")):
            raise ValueError(f"imported source differs from V6: {item['path']}")
    for name in ("w_q0", "w_q1", "w_scale", "aux"):
        entry = model["bo"][name]
        current = next(item for item in imported_records if
                       item["path"] == str((MODEL / entry["file"]).resolve()))
        if (current["bytes"], current["sha256"]) != (entry["size"], entry["sha256"]):
            raise ValueError(f"model BO manifest drift: {name}")
    current_gguf = next(item for item in imported_records if item["path"] == str(gguf.resolve()))
    if (current_gguf["bytes"], current_gguf["sha256"]) != (
            model["source_model"]["size"], model["source_model"]["sha256"]):
        raise ValueError("original GGUF identity drift")
    for item in static["checkpoints"]:
        current = next(row for row in imported_records if row["path"] == item["source"]["path"])
        if (current["bytes"], current["sha256"]) != (
                item["source"]["bytes"], item["source"]["sha256"]):
            raise ValueError("checkpoint source drift")

    return {"schema": "q8_full_scorer_rows3_source_packet_v1",
            "created_utc": created_utc,
            "status": "SOURCE_ONLY_NO_NUMERICAL_OR_EDA_EXECUTION_RELEASE",
            "source_preparation_authority": gate_record,
            "inherited_single_row_packet": v6_record,
            "static_contract": static_record,
            "counts": {"generated_verilog": 230, "generated_dat": 108,
                       "fp_sim_vhdl": 7, "local_source": len(local_records),
                       "imported_inputs": len(imported_records),
                       "physical_pages": 341},
            "generated_closure": generated,
            "local_source": local_records,
            "imported_inputs": imported_records,
            "checkpoint_source_interval": [118784, 131072],
            "shape": static["shape"], "trace": static["trace"],
            "work_per_run": static["work_per_run"],
            "planned_sequence": ["load_w", "run_trace_on", "run_trace_off"],
            "execution_limit": "Source review only: no fixture numerical derivation, CPU compile/run, xvlog/xvhdl/xelab/xsim or synthesis."}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--create", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.create:
        if OUT.exists():
            raise FileExistsError("source packet already exists")
        packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
        OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    else:
        packet = json.loads(OUT.read_text())
        if packet != construct(packet["created_utc"]):
            raise ValueError("three-row source packet binding drift")
    item = record(OUT)
    print(f"Q8_SCORER_ROWS3_SOURCE_PACKET_PASS files={sum(packet['counts'][k] for k in ('generated_verilog','generated_dat','fp_sim_vhdl','local_source','imported_inputs'))} sha256={item['sha256']}")


if __name__ == "__main__":
    main()
