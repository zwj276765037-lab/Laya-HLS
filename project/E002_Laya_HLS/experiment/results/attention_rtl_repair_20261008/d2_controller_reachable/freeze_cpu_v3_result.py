#!/usr/bin/env python3
"""Bind D2-I native CPU success, the v2 failure, and its one-line correction."""

import hashlib
import json
from pathlib import Path
import subprocess


MODULE = Path(__file__).resolve().parent
RUNS = MODULE / "runs"
STATIC = MODULE / "draft_v3_pre_cpu_packet.json"


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def artifact(path):
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": sha(path)}


def job(guard, phase):
    guard_result = json.loads((guard / "guard_result.json").read_text())
    if guard_result["child_exit_code"] != 0 or guard_result["trigger"] is not None:
        raise RuntimeError(f"CPU job did not pass: {guard}")
    return {"guard_result": artifact(guard / "guard_result.json"),
            "guard_plan": artifact(guard / "guard_plan.json"),
            "launch": artifact(guard / "launch.json"),
            "policy_checks": artifact(guard / "policy_checks.json"),
            "memory_timeline": artifact(guard / "memory_timeline.csv"),
            "driver_log": artifact(guard / "driver.log"),
            "input_manifest": artifact(phase / "input_manifest.json"),
            "result": artifact(phase / "result.json"),
            "guard_observation": guard_result}


def main():
    static = json.loads(STATIC.read_text())
    if static["status"] != "V3_VECTOR_TB_PHYSICAL_READ_FIX_PRE_CPU":
        raise RuntimeError("wrong v3 static packet")
    for name, expected in static["artifacts"].items():
        if sha(Path(name)) != expected["sha256"]:
            raise RuntimeError(f"static artifact changed: {name}")
    line = RUNS / "cpu_linear_execute_guard/driver.log"
    vector = RUNS / "v3/cpu_vector_execute_guard/driver.log"
    original_failure = RUNS / "cpu_vector_execute_guard/driver.log"
    if "D2_I_LINEAR_PASS qkv_values=589824" not in line.read_text():
        raise RuntimeError("full QKV CPU comparison did not pass")
    if "D2_I_VECTOR_PASS residual=2 type=1 binary_reject=1 unary=1 values=196624" not in vector.read_text():
        raise RuntimeError("vector CPU comparison did not pass")
    if "D2_I_VECTOR_FAIL bit-exact independent F32 vector gold" not in original_failure.read_text():
        raise RuntimeError("v2 first failure unavailable")
    failed_guard = json.loads((RUNS / "cpu_vector_execute_guard/guard_result.json").read_text())
    if failed_guard["child_exit_code"] != 1 or failed_guard["trigger"] is not None:
        raise RuntimeError("v2 first failure guard classification changed")
    cpu_jobs = {
        "linear_v2_build": job(RUNS / "cpu_linear_build_guard", RUNS / "cpu_linear_build"),
        "linear_v2_execute": job(RUNS / "cpu_linear_execute_guard", RUNS / "cpu_linear_execute"),
        "vector_v3_build": job(RUNS / "v3/cpu_vector_build_guard", RUNS / "v3/cpu_vector_build"),
        "vector_v3_execute": job(RUNS / "v3/cpu_vector_execute_guard", RUNS / "v3/cpu_vector_execute"),
    }
    output = MODULE / "cpu_v3_result_packet.json"
    packet = {
        "decision": "D2_I_NATIVE_CPU_GATE_PASS_PENDING_INDEPENDENT_REVIEW",
        "scope": "I-L stage4 complete QKV and I-V residual/type/unary/rejection, native CPU only",
        "static_v3_packet": artifact(STATIC),
        "controller": artifact(Path(json.loads((MODULE / "source_list_manifest.json").read_text())["included_controller"]["path"])),
        "jobs": cpu_jobs,
        "binaries": {
            "linear_v2": artifact(RUNS / "cpu_linear"),
            "vector_v3": artifact(RUNS / "v3/cpu_vector")},
        "gate_runners": {
            "v2": artifact(MODULE / "source/run_cpu_gate.py"),
            "v3": artifact(MODULE / "source/run_cpu_gate_v3.py"),
            "guard": artifact(MODULE / "source/guard_16g.py"),
            "guard_support": artifact(MODULE / "source/hls_guard_helpers.py")},
        "compiler_version": subprocess.check_output(["/usr/bin/g++", "--version"], text=True).splitlines()[0],
        "v2_first_failure": {
            "guard": artifact(RUNS / "cpu_vector_execute_guard/guard_result.json"),
            "log": artifact(original_failure),
            "first_mismatch_log": artifact(RUNS / "debug_vector_execute_guard/driver.log"),
            "wrong_region_dump": artifact(RUNS / "vector_first_mismatch.actual.bin")},
        "comparison": {
            "qkv_f32_values": 589824,
            "qkv_success_cases": 3,
            "qkv_no_pair_cases": 1,
            "qkv_bad_scale_cases": 2,
            "qkv_bad_header_cases": 2,
            "vector_f32_values": 196624,
            "vector_residual_cases": 2,
            "vector_type_cases": 1,
            "vector_binary_rejection_cases": 1,
            "vector_unary_cases": 1,
        },
        "not_run": ["Vitis CSim", "local csynth", "IR audit", "RTL simulation", "full top HLS"]}
    output.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(output, sha(output))


if __name__ == "__main__":
    main()
