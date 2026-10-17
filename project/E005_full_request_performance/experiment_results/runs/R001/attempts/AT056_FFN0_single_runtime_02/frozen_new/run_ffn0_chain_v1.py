#!/usr/bin/env python3
"""Freeze and execute one bounded FFN0 same-runtime diagnostic."""
import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS")
E002 = ROOT / "project/E002_Laya_HLS/experiment"
TB = E002 / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb"
RTL = E002 / "vivado/module_design/vector_and_ffn/rtl"
RUNS = ROOT / "project/E005_full_request_performance/experiment_results/runs/R001/attempts"
ATTEMPT = RUNS / "AT056_FFN0_single_runtime_02"
DOWN = RUNS / "AT035_QAR0_shared_admission_01/frozen"
LN = RUNS / "AT040_LNF0_ffn4_02/frozen"
PARENT = RUNS / "AT049_LNQ2_runtime_01"
FFR = RUNS / "AT054_FFR1_status_measurement_01/frozen"
LEAF = (E002 / "results/compute_throughput_optimization_20261010/attempts/"
        "tanh_libm_round1_02/hls_project/solution1/syn/verilog/"
        "tanh_libm_leaf_fp_add_bits.v")
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
NEW_NAMES = ("laya_ffn0_source_stage_v1.sv", "ffn0_chain_tb_v1.sv",
             "ffn0_admission_short_tb_v1.sv", "run_ffn0_admission_short_v1.tcl",
             "run_ffn0_chain_v1.tcl", "run_ffn0_chain_v1.py",
             "ffn0_guard.py", "ffn0_guard_host_test.py",
             "verify_ffn0_runtime_v1.py", "stage_ln_roms_v1.tcl",
             "hls_guard_helpers.py")
FFN_NAMES = ("laya_ffn_fadd_slot_v1.sv",
             "laya_ffn0_residual_four_row_v1.sv",
             "laya_ffn0_down_residual_admission_v1.sv")
PARENT_NAMES = ("geglu_gate_quant_bridge_v1.sv",
                "laya_lnq0_bound_identity_generated_v1.sv",
                "laya_lnq0_external_quant_admission_v1.sv",
                "laya_lnq0_w_binding_v1.sv")
FIXTURES = (
    RUNS / "AT035_QAR0_shared_admission_01/work/fixtures/g",
    RUNS / "AT035_QAR0_shared_admission_01/work/fixtures/a",
    RUNS / "AT035_QAR0_shared_admission_01/work/fixtures/w",
    RUNS / "AT035_QAR0_shared_admission_01/work/fixtures/streams",
    RUNS / "AT035_QAR0_shared_admission_01/work/fixtures/wi_a",
    RUNS / "AT035_QAR0_shared_admission_01/work/fixtures/wi_w",
    RUNS / "AT035_QAR0_shared_admission_01/work/fixtures/wi_streams",
    RUNS / "AT040_LNF0_ffn4_02/fixture",
    RUNS / "AT043_LNQ0_chain_02/bound_identity",
    ATTEMPT / "fixture",
)
EXPECTED_FFN = {
    "final.mem": "09b3529aca2d23f32e1cb16f04925f6744547714e5018c8b6d84fe3c0f2c9195",
    "skip.mem": "0cee3ba41a0990d8a8888d1bf0d22c50154a2d5757a4a36d6012653df21a8763",
}


def identity(path, role):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return {"role": role, "path": str(path.resolve()),
            "bytes": path.stat().st_size, "sha256": digest.hexdigest()}


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def freeze():
    if (ATTEMPT / "source_manifest.json").exists():
        raise RuntimeError("AT055 source manifest already exists")
    parent_path = PARENT / "source_manifest.json"
    parent = json.loads(parent_path.read_text())
    new = ATTEMPT / "frozen_new"
    ffn = ATTEMPT / "frozen_ffn"
    new.mkdir(parents=True, exist_ok=False)
    ffn.mkdir(parents=True, exist_ok=False)
    entries = list(parent["files"])
    for name in NEW_NAMES:
        shutil.copy2(TB / name, new / name)
        entries.append(identity(new / name, "ffn0_frozen"))
    for name in PARENT_NAMES:
        shutil.copy2(PARENT / "frozen_new" / name, new / name)
        entries.append(identity(new / name, "ffn0_frozen"))
    for name in FFN_NAMES:
        shutil.copy2(RTL / name, ffn / name)
        entries.append(identity(ffn / name, "ffn0_frozen"))
    for name in EXPECTED_FFN:
        item = identity(ATTEMPT / "fixture" / name, "ffn_fixture")
        if item["sha256"] != EXPECTED_FFN[name]:
            raise RuntimeError(f"FFN fixture identity changed: {name}")
        entries.append(item)
    entries.append(identity(LEAF, "fadd_leaf"))
    entries.append(identity(parent_path, "parent_manifest"))
    if identity(LEAF, "fadd_leaf")["sha256"] != \
            "d1370d290aac70f8ceed10b04c6451381f34d4cc23b088eebdaf1fd0f4e3b474":
        raise RuntimeError("FADD leaf identity changed")
    write(ATTEMPT / "source_manifest.json", {
        "schema": 1, "stage": "D-M004-FFN-SINGLE-RUNTIME-01",
        "at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "parent_source_manifest": str(parent_path), "files": entries,
        "limits": {"static_seconds": 1800, "static_rss_gib": 24,
                   "rtl_seconds": 3600, "rtl_rss_gib": 8,
                   "pilot_seconds": 120, "stall_seconds": 120,
                   "cycles": 40000000}})
    print(f"FFN0_FROZEN entries={len(entries)}")


def verify():
    manifest = json.loads((ATTEMPT / "source_manifest.json").read_text())
    for item in manifest["files"]:
        if identity(Path(item["path"]), item["role"]) != item:
            raise RuntimeError(f"frozen identity changed: {item['path']}")
    return manifest


def run_host():
    verify()
    out = ATTEMPT / "guard_host_test.json"
    command = [sys.executable, str(ATTEMPT / "frozen_new/ffn0_guard_host_test.py"),
               "--out", str(out)]
    result = subprocess.run(command, cwd=E002, check=False)
    return 0 if result.returncode == 0 and json.loads(out.read_text())["verdict"] == "PASS" else 1


def run_phase(phase):
    verify()
    if phase == "full":
        decision = json.loads((ATTEMPT / "full_cost_decision.json").read_text())
        if decision.get("admit") is not True or \
                (ATTEMPT / "result_pilot.json").exists() is False:
            raise RuntimeError("full lacks current cost/pilot admission")
    work = ATTEMPT / f"work_{phase}"
    work.mkdir(exist_ok=False)
    new, ffn = ATTEMPT / "frozen_new", ATTEMPT / "frozen_ffn"
    command = [str(VIVADO), "-mode", "batch", "-notrace",
               "-log", str(ATTEMPT / f"{phase}.log"),
               "-journal", str(ATTEMPT / f"{phase}.jou"),
               "-source", str(new / ("run_ffn0_admission_short_v1.tcl"
                                      if phase == "short" else
                                      "run_ffn0_chain_v1.tcl")),
               "-tclargs"]
    if phase == "short":
        command += [str(work), str(LN), str(new), str(ffn),
                    str(FIXTURES[7]), str(FIXTURES[8])]
    else:
        command += [phase, str(work), str(DOWN), str(LN), str(new),
                    str(ffn), str(LEAF), *map(str, FIXTURES)]
    write(ATTEMPT / f"launch_{phase}.json", {"command": command,
          "cwd": str(E002), "manifest_sha256":
          identity(ATTEMPT / "source_manifest.json", "manifest")["sha256"],
          "at": dt.datetime.now(dt.timezone.utc).isoformat()})
    seconds = 1800 if phase == "static" else 120 if phase in ("short", "pilot") else 3600
    rss = 24 if phase == "static" else 8
    guarded = [sys.executable, str(new / "ffn0_guard.py"), "--out",
               str(ATTEMPT / f"guard_{phase}"), "--cwd", str(E002),
               "--rss-gib", str(rss), "--timeout-seconds", str(seconds),
               "--semantic-stall-seconds", "120", "--phase",
               "error" if phase == "short" else phase,
               "--", *command]
    result = subprocess.run(guarded, cwd=E002, check=False)
    guard = json.loads((ATTEMPT / f"guard_{phase}/guard_result.json").read_text())
    log = (ATTEMPT / f"guard_{phase}/driver.log").read_text(errors="replace")
    marker = {"static": "FFN0_STATIC_PASS",
              "short": "FFN0_ADMISSION_SHORT_PASS",
              "pilot": "FFN0_PREFIX_PILOT_PASS",
              "full": "FFN0_CHAIN_PASS"}[phase]
    passed = (result.returncode == 0 and guard.get("trigger") is None and
              marker in log and "Fatal:" not in log and "ERROR:" not in log and
              (phase == "static" or guard.get("simulation_started")))
    write(ATTEMPT / f"result_{phase}.json", {
        "verdict": "PASS" if passed else "FAIL", "marker": marker,
        "guard_exit": result.returncode, "guard": guard,
        "runtime_preflight": str(work / "runtime_preflight.json")})
    print(f"FFN0_{phase.upper()}_{'PASS' if passed else 'FAIL'}")
    return 0 if passed else 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("phase", choices=("freeze", "verify", "host",
                                          "static", "short", "pilot", "full"))
    phase = parser.parse_args().phase
    if phase == "freeze":
        freeze()
        return 0
    if phase == "verify":
        print(f"FFN0_VERIFY_PASS entries={len(verify()['files'])}")
        return 0
    if phase == "host":
        return run_host()
    return run_phase(phase)


if __name__ == "__main__":
    raise SystemExit(main())
