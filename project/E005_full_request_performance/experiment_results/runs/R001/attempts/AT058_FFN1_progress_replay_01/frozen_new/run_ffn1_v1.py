#!/usr/bin/env python3
"""Freeze and run the bounded FFN1 observer replay without changing AT057 DUT."""
import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS")
E002 = ROOT / "project/E002_Laya_HLS/experiment"
TB = E002 / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb"
RUNS = ROOT / "project/E005_full_request_performance/experiment_results/runs/R001/attempts"
PARENT = RUNS / "AT057_FFN0_single_runtime_03"
ATTEMPT = RUNS / "AT058_FFN1_progress_replay_01"
DOWN = RUNS / "AT035_QAR0_shared_admission_01/frozen"
LN = RUNS / "AT040_LNF0_ffn4_02/frozen"
LEAF = (E002 / "results/compute_throughput_optimization_20261010/attempts/"
        "tanh_libm_round1_02/hls_project/solution1/syn/verilog/"
        "tanh_libm_leaf_fp_add_bits.v")
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")
OLD_NEW = ("laya_ffn0_source_stage_v1.sv",
           "geglu_gate_quant_bridge_v1.sv",
           "laya_lnq0_bound_identity_generated_v1.sv",
           "laya_lnq0_external_quant_admission_v1.sv",
           "laya_lnq0_w_binding_v1.sv",
           "stage_ln_roms_v1.tcl", "hls_guard_helpers.py")
CURRENT = ("ffn0_chain_tb_v1.sv", "ffn1_progress_observer_v1.sv",
           "ffn1_progress_observer_micro_tb_v1.sv",
           "ffn1_admission_negative_tb_v1.sv",
           "ffn1_residual_destination_tb_v1.sv",
           "run_ffn1_chain_v1.tcl", "run_ffn1_observer_micro_v1.tcl",
           "run_ffn1_admission_negative_v1.tcl",
           "run_ffn1_residual_destination_v1.tcl",
           "ffn0_guard.py", "ffn1_guard_host_test.py",
           "verify_ffn1_runtime_v1.py", "run_ffn1_v1.py")
FFN = ("laya_ffn_fadd_slot_v1.sv",
       "laya_ffn0_residual_four_row_v1.sv",
       "laya_ffn0_down_residual_admission_v1.sv")
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
    PARENT / "fixture",
)
ROOT_KEYS = ("GFIXTURE", "AFIXTURE", "WFIXTURE", "STREAMS",
             "WI_AFIXTURE", "WI_WFIXTURE", "WI_STREAMS", "LN_FIXTURE",
             "BOUND_FIXTURE", "FFN_FIXTURE")


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
    manifest_path = ATTEMPT / "source_manifest.json"
    if manifest_path.exists() or ATTEMPT.exists():
        raise RuntimeError("AT058 already exists; never overwrite a frozen attempt")
    parent_path = PARENT / "source_manifest.json"
    parent = json.loads(parent_path.read_text())
    new, ffn = ATTEMPT / "frozen_new", ATTEMPT / "frozen_ffn"
    new.mkdir(parents=True)
    ffn.mkdir()
    entries = list(parent["files"])
    for name in OLD_NEW:
        src = PARENT / "frozen_new" / name
        shutil.copy2(src, new / name)
        entries.append(identity(new / name, "ffn1_inherited"))
    for name in FFN:
        src = PARENT / "frozen_ffn" / name
        shutil.copy2(src, ffn / name)
        entries.append(identity(ffn / name, "ffn1_unchanged_DUT"))
    for name in CURRENT:
        shutil.copy2(TB / name, new / name)
        entries.append(identity(new / name, "ffn1_observer_or_runner"))
    entries.append(identity(parent_path, "parent_manifest"))
    entries.append(identity(LEAF, "fadd_leaf"))
    write(manifest_path, {
        "schema": 1, "stage": "D-M004-FFN-PROGRESS-REPLAY-01",
        "at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "parent_source_manifest": str(parent_path), "files": entries,
        "limits": {"static_seconds": 1800, "static_rss_gib": 24,
                   "rtl_seconds": 3600, "rtl_rss_gib": 8,
                   "short_seconds": 120, "pilot_seconds": 120,
                   "stall_seconds": 120, "cycles": 40000000}})
    old_sha = {name: identity(PARENT / "frozen_ffn" / name, "old")["sha256"]
               for name in FFN}
    if any(identity(ffn / name, "new")["sha256"] != old_sha[name]
           for name in FFN):
        raise RuntimeError("AT057 functional residual RTL changed")
    write(ATTEMPT / "functional_DUT_identity.json", {
        "at057_ffn_rtl_sha256": old_sha,
        "at057_other_DUT": {name: identity(new / name, "inherited")["sha256"]
                             for name in OLD_NEW if name.endswith(".sv")},
        "unchanged": True})
    print(f"FFN1_FROZEN entries={len(entries)}")


def verify():
    manifest = json.loads((ATTEMPT / "source_manifest.json").read_text())
    for item in manifest["files"]:
        if identity(Path(item["path"]), item["role"]) != item:
            raise RuntimeError(f"frozen identity changed: {item['path']}")
    return manifest


def guard_run(phase, tcl, tclargs, marker, seconds, rss, guard_phase):
    verify()
    work = ATTEMPT / f"work_{phase}"
    work.mkdir(exist_ok=False)
    new = ATTEMPT / "frozen_new"
    command = [str(VIVADO), "-mode", "batch", "-notrace",
               "-log", str(ATTEMPT / f"{phase}.log"),
               "-journal", str(ATTEMPT / f"{phase}.jou"),
               "-source", str(new / tcl), "-tclargs", *map(str, tclargs)]
    write(ATTEMPT / f"launch_{phase}.json", {
        "command": command, "cwd": str(E002),
        "manifest_sha256": identity(ATTEMPT / "source_manifest.json", "manifest")["sha256"],
        "at": dt.datetime.now(dt.timezone.utc).isoformat()})
    guarded = [sys.executable, str(new / "ffn0_guard.py"), "--out",
               str(ATTEMPT / f"guard_{phase}"), "--cwd", str(E002),
               "--rss-gib", str(rss), "--timeout-seconds", str(seconds),
               "--semantic-stall-seconds", "120", "--phase", guard_phase,
               "--", *command]
    result = subprocess.run(guarded, cwd=E002, check=False)
    guard = json.loads((ATTEMPT / f"guard_{phase}/guard_result.json").read_text())
    log = (ATTEMPT / f"guard_{phase}/driver.log").read_text(errors="replace")
    passed = (result.returncode == 0 and guard.get("trigger") is None and
              marker in log and "Fatal:" not in log and "ERROR:" not in log)
    write(ATTEMPT / f"result_{phase}.json", {
        "verdict": "PASS" if passed else "FAIL", "marker": marker,
        "guard_exit": result.returncode, "guard": guard,
        "runtime_preflight": str(work / "runtime_preflight.json")
        if phase in ("static", "pilot", "full") else None})
    print(f"FFN1_{phase.upper()}_{'PASS' if passed else 'FAIL'}")
    return 0 if passed else 1


def run_phase(phase):
    new, ffn = ATTEMPT / "frozen_new", ATTEMPT / "frozen_ffn"
    work = ATTEMPT / f"work_{phase}"
    if phase == "micro":
        return guard_run(phase, "run_ffn1_observer_micro_v1.tcl",
                         (work, new), "FFN1_OBSERVER_MICRO_PASS", 120, 8, "error")
    if phase == "negative":
        return guard_run(phase, "run_ffn1_admission_negative_v1.tcl",
                         (work, LN, new, ffn, FIXTURES[7], FIXTURES[8]),
                         "FFN1_ADMISSION_NEGATIVE_PASS", 120, 8, "error")
    if phase == "wrapper":
        return guard_run(phase, "run_ffn1_residual_destination_v1.tcl",
                         (work, LN, new, ffn, LEAF),
                         "FFN1_WRAPPER_DST_PASS", 120, 8, "error")
    if phase == "full":
        decision = json.loads((ATTEMPT / "full_cost_decision.json").read_text())
        prerequisites = ("static", "micro", "negative", "wrapper", "pilot")
        if (decision.get("admit") is not True or
            any(json.loads((ATTEMPT / f"result_{name}.json").read_text()).get(
                "verdict") != "PASS" for name in prerequisites) or
            json.loads((ATTEMPT / "guard_host_test.json").read_text()).get(
                "verdict") != "PASS" or
            not (ATTEMPT / "runtime_negative_test.json").exists()):
            raise RuntimeError("FFN1 full lacks current complete admission")
        if (ATTEMPT / "launch_full.json").exists():
            raise RuntimeError("FFN1 full already launched; no second full")
    return guard_run(phase, "run_ffn1_chain_v1.tcl",
                     (phase, work, DOWN, LN, new, ffn, LEAF, *FIXTURES),
                     {"static": "FFN0_STATIC_PASS",
                      "pilot": "FFN0_PREFIX_PILOT_PASS",
                      "full": "FFN0_CHAIN_PASS"}[phase],
                     1800 if phase == "static" else 120 if phase == "pilot" else 3600,
                     24 if phase == "static" else 8,
                     phase)


def run_host():
    verify()
    micro = ATTEMPT / "guard_micro/driver.log"
    if not micro.is_file():
        raise RuntimeError("micro RTL output required for parser/logic-time test")
    command = [sys.executable, str(ATTEMPT / "frozen_new/ffn1_guard_host_test.py"),
               "--out", str(ATTEMPT / "guard_host_test.json"),
               "--micro-log", str(micro),
               "--old-w-log", str(PARENT / "guard_full/driver.log")]
    result = subprocess.run(command, cwd=E002, check=False)
    return 0 if result.returncode == 0 and json.loads(
        (ATTEMPT / "guard_host_test.json").read_text())["verdict"] == "PASS" else 1


def runtime_negatives():
    verify()
    manifest = ATTEMPT / "source_manifest.json"
    new = ATTEMPT / "frozen_new"
    entries = json.loads(manifest.read_text())["files"]
    roms = {Path(item["path"]).name: Path(item["path"])
            for item in entries if item["role"] == "LN_frozen" and
            Path(item["path"]).name.endswith("ROM_AUTO_1R.dat")}
    if len(roms) != 7:
        raise RuntimeError("missing seven frozen LN ROM inputs")
    with tempfile.TemporaryDirectory(prefix="ffn1_preflight_", dir=ATTEMPT) as tmp:
        cwd = Path(tmp)
        (cwd / "xsim.dir").mkdir()
        for name, source in roms.items():
            shutil.copy2(source, cwd / name)
        results = []
        for case in ("intact", "missing_rom", "corrupt_rom"):
            if case == "missing_rom":
                (cwd / sorted(roms)[0]).unlink()
            if case == "corrupt_rom":
                shutil.copy2(roms[sorted(roms)[0]], cwd / sorted(roms)[0])
                target = cwd / sorted(roms)[1]
                target.write_bytes(target.read_bytes() + b"bad")
            output = ATTEMPT / f"preflight_{case}.json"
            cmd = [sys.executable, str(new / "verify_ffn1_runtime_v1.py"),
                   "--manifest", str(manifest), "--cwd", str(cwd),
                   "--out", str(output)]
            for key, value in zip(ROOT_KEYS, FIXTURES):
                cmd += ["--root", key, str(value)]
            cmd += ["--root", "FIXTURE", str(FIXTURES[7])]
            process = subprocess.run(cmd, cwd=E002, capture_output=True,
                                     text=True, check=False)
            record = json.loads(output.read_text())
            expected = "ACCEPT" if case == "intact" else "REJECT"
            if record["status"] != expected or (process.returncode == 0) != (
                case == "intact") or record.get("spawned") is not False:
                raise RuntimeError(f"runtime preflight {case} did not {expected}")
            results.append({"case": case, "status": record["status"],
                            "exit": process.returncode, "spawned": False,
                            "record": str(output)})
    write(ATTEMPT / "runtime_negative_test.json", {
        "verdict": "PASS", "cases": results,
        "fixture_alias": "FIXTURE=LN_FIXTURE", "xsim_spawned": False})
    print("FFN1_RUNTIME_NEGATIVE_PASS cases=3")
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("freeze", "verify", "static", "micro",
                                          "host", "negative", "wrapper", "pilot",
                                          "runtime-negative", "full"))
    phase = parser.parse_args().phase
    if phase == "freeze":
        freeze(); return 0
    if phase == "verify":
        print(f"FFN1_VERIFY_PASS entries={len(verify()['files'])}"); return 0
    if phase == "host":
        return run_host()
    if phase == "runtime-negative":
        return runtime_negatives()
    return run_phase(phase)


if __name__ == "__main__":
    raise SystemExit(main())
