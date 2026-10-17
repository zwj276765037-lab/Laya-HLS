#!/usr/bin/env python3
"""Freeze and run one bounded FFR1 diagnostic attempt."""

import argparse
import datetime as dt
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS")
E002 = ROOT / "project/E002_Laya_HLS/experiment"
TB = E002 / "vivado/module_design/vector_and_ffn/tb"
RTL = E002 / "vivado/module_design/vector_and_ffn/rtl"
OLD = E002 / "results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02"
REF = ROOT / "project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT050_FFREF0_reference_01/output"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
FILES = {
    "laya_ffn_fadd_slot_v1.sv": RTL / "laya_ffn_fadd_slot_v1.sv",
    "laya_ffn_residual_four_row_v1.sv": RTL / "laya_ffn_residual_four_row_v1.sv",
    "laya_ffn_fadd_slot_v1_tb.sv": TB / "laya_ffn_fadd_slot_v1_tb.sv",
    "laya_ffn_residual_four_row_ffr1_tb.sv": TB / "laya_ffn_residual_four_row_ffr1_tb.sv",
    "run_ffr1_v1.tcl": TB / "run_ffr1_v1.tcl",
    "run_ffr1_v1.py": TB / "run_ffr1_v1.py",
    "ffr1_guard.py": TB / "ffr1_guard.py",
    "ffr1_guard_host_test.py": TB / "ffr1_guard_host_test.py",
    "hls_guard_helpers.py": E002 / "tools/hls_guard_helpers.py",
}
EXTERNAL = {
    "leaf": OLD / "hls_project/solution1/syn/verilog/tanh_libm_leaf_fp_add_bits.v",
    "skip": REF / "enc0_skip_rows4.f32.bin",
    "down": REF / "enc0_down_rows4.f32.bin",
    "gold": REF / "enc0_enc0_out_rows4.f32.bin",
    "add": OLD / "cpu/add_directed.mem",
    "vivado": VIVADO,
    "status_header": E002 / "include/laya_types.h",
}
EXPECTED = {
    "leaf": "d1370d290aac70f8ceed10b04c6451381f34d4cc23b088eebdaf1fd0f4e3b474",
    "skip": "5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9",
    "down": "4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0",
    "gold": "c5b1310dbfb8c392974b033d9a229807df92745f22ae97470fa8eb4d84bc3a0a",
    "add": "b3d36f14bd9884b48c1856ff97cd0c4f9ec1fdc69cbd0a7d3b8f6d287942fe3e",
    "status_header": "eae5761a76816daa33231a8aac35f2c7d373f67a2ad58ff75b662b8ff7366c61",
}


def identity(path):
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def freeze(attempt):
    if attempt.exists():
        raise RuntimeError(f"attempt already exists: {attempt}")
    for name, path in EXTERNAL.items():
        if name in EXPECTED and identity(path)["sha256"] != EXPECTED[name]:
            raise RuntimeError(f"external identity changed: {name}")
    frozen = attempt / "frozen"
    frozen.mkdir(parents=True)
    for name, path in FILES.items():
        shutil.copy2(path, frozen / name)
    manifest = {
        "schema": 1,
        "stage": "D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01",
        "at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "frozen": {name: identity(frozen / name) for name in FILES},
        "external": {name: identity(path) for name, path in EXTERNAL.items()},
    }
    write_json(attempt / "source_manifest.json", manifest)
    print(json.dumps({"attempt": str(attempt), "files": len(FILES) + len(EXTERNAL)}))


def verify(attempt):
    manifest = json.loads((attempt / "source_manifest.json").read_text())
    for group in ("frozen", "external"):
        for name, recorded in manifest[group].items():
            got = identity(Path(recorded["path"]))
            if got != recorded:
                raise RuntimeError(f"frozen {group}/{name} changed")
    return manifest


def run_host(attempt):
    verify(attempt)
    frozen = attempt / "frozen"
    output = attempt / "guard_host_test.json"
    command = [sys.executable, str(frozen / "ffr1_guard_host_test.py"),
               "--out", str(output)]
    guard_command = [sys.executable, str(frozen / "ffr1_guard.py"),
                     "--out", str(attempt / "guard_host"),
                     "--cwd", str(E002), "--rss-gib", "8",
                     "--timeout-seconds", "120", "--phase", "static",
                     "--semantic-stall-seconds", "120", "--", *command]
    result = subprocess.run(guard_command, cwd=E002, check=False)
    passed = (result.returncode == 0 and output.exists() and
              json.loads(output.read_text())["verdict"] == "PASS")
    write_json(attempt / "result_host.json", {
        "command": guard_command, "verdict": "PASS" if passed else "FAIL",
        "output": str(output), "spawned_dut": False})
    print(json.dumps({"phase": "host", "verdict": "PASS" if passed else "FAIL"}))
    return 0 if passed else 1


def run(attempt, phase):
    manifest = verify(attempt)
    max_seconds = {"static": 1800, "error": 120, "pilot": 120, "full": 3600}[phase]
    rss_gib = 24 if phase == "static" else 8
    work = attempt / f"work_{phase}"
    work.mkdir(exist_ok=False)
    frozen = attempt / "frozen"
    external = manifest["external"]
    command = [str(VIVADO), "-mode", "batch", "-notrace",
               "-log", str((attempt / f"{phase}.log").resolve()),
               "-journal", str((attempt / f"{phase}.jou").resolve()),
               "-source", str((frozen / "run_ffr1_v1.tcl").resolve()),
               "-tclargs", phase, str(work.resolve()), str(frozen.resolve()),
               external["leaf"]["path"], external["skip"]["path"],
               external["down"]["path"], external["gold"]["path"],
               external["add"]["path"]]
    preflight = {
        "schema": 1, "phase": phase, "at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "cwd": str(E002), "work": str(work.resolve()), "command": command,
        "files_verified": len(manifest["frozen"]) + len(external),
        "plusargs": {"SKIP_FILE": external["skip"]["path"],
                     "DOWN_FILE": external["down"]["path"],
                     "GOLD_FILE": external["gold"]["path"],
                     "ADD_FILE": external["add"]["path"],
                     "PILOT": phase == "pilot",
                     "ERROR_ONLY": phase == "error"},
        "manifest_sha256": identity(attempt / "source_manifest.json")["sha256"],
    }
    write_json(attempt / f"preflight_{phase}.json", preflight)
    guard_command = [sys.executable, str((frozen / "ffr1_guard.py").resolve()),
                     "--out", str((attempt / f"guard_{phase}").resolve()),
                     "--cwd", str(E002), "--rss-gib", str(rss_gib),
                     "--timeout-seconds", str(max_seconds),
                     "--semantic-stall-seconds", "120", "--phase", phase,
                     "--", *command]
    result = subprocess.run(guard_command, cwd=E002, check=False)
    guard_result = json.loads((attempt / f"guard_{phase}/guard_result.json").read_text())
    log = (attempt / f"guard_{phase}/driver.log").read_text(errors="replace")
    required = {"static": "FFR1_STATIC_PASS", "error": "FFR1_ERROR_PASS",
                "pilot": "FFR1_FOUR_ROW_PASS rows=1",
                "full": "FFR1_FOUR_ROW_PASS rows=4"}[phase]
    passed = (result.returncode == 0 and guard_result.get("trigger") is None and
              required in log and "Fatal:" not in log and "ERROR:" not in log and
              (phase == "static" or guard_result.get("simulation_started")))
    write_json(attempt / f"result_{phase}.json", {
        "phase": phase, "guard_exit": result.returncode,
        "guard_trigger": guard_result.get("trigger"),
        "required_marker": required, "marker_present": required in log,
        "fatal_present": "Fatal:" in log or "ERROR:" in log,
        "verdict": "PASS" if passed else "FAIL_OR_COST_STOP",
    })
    print(json.dumps({"phase": phase, "verdict": "PASS" if passed else "FAIL_OR_COST_STOP"}))
    return 0 if passed else 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("phase", choices=("prepare", "host", "static", "error", "pilot", "full"))
    parser.add_argument("--attempt", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    if args.phase == "prepare":
        freeze(attempt)
        return 0
    if args.phase == "host":
        return run_host(attempt)
    return run(attempt, args.phase)


if __name__ == "__main__":
    raise SystemExit(main())
