#!/usr/bin/env python3
"""Freeze and synthesize the arithmetic-free partitioned Controller caller."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[5]
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
MODEL = Path("build/model-current-production-v2-20261011")
VITIS = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++")
TOP = "laya_typed_q8_forward_controller_partitioned"


def record(path: Path) -> dict:
    path = path.resolve()
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def launcher_state() -> dict:
    available = None
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            available = int(line.split()[1])
            break
    state = {
        "pid": os.getpid(),
        "cpu_affinity": sorted(os.sched_getaffinity(0)),
        "nice": os.getpriority(os.PRIO_PROCESS, 0),
        "ionice": subprocess.run(
            ["ionice", "-p", str(os.getpid())], check=True, text=True,
            capture_output=True).stdout.strip(),
        "mem_available_kib": available,
        "required_mem_available_kib": 192 * 1024 * 1024,
    }
    state["pass"] = (
        state["cpu_affinity"] == [0, 1, 2, 3] and
        state["nice"] == 19 and state["ionice"].startswith("idle") and
        available is not None and available > state["required_mem_available_kib"])
    return state


def source_list(path: Path) -> list[Path]:
    result = [Path(value) for value in re.findall(
        r"^\s*(hls/[^\s]+\.cpp)\s*$", path.read_text(), re.M)]
    if len(result) < 20 or len(result) != len(set(result)):
        raise RuntimeError("invalid partitioned Controller source list")
    forbidden = ("full_tasks.cpp", "full_tasks_front.cpp",
                 "full_tasks_attention.cpp", "full_tasks_tail.cpp",
                 "full_tasks_vector.cpp", "layernorm_compute.cpp",
                 "q8_linear_compute.cpp", "attention_full_compute.cpp",
                 "vector_full_compute.cpp")
    if any(any(str(path).endswith(name) for name in forbidden)
           for path in result):
        raise RuntimeError("arithmetic fallback source entered caller closure")
    return result


def copy_one(rel: Path, frozen: Path, records: list[dict]) -> Path:
    source = ROOT / rel
    if not source.is_file():
        raise RuntimeError(f"missing input: {rel}")
    target = frozen / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    records.append({"relative": str(rel), "original": record(source),
                    "frozen": record(target)})
    return target


def freeze_include_closure(frozen: Path, records: list[dict]) -> None:
    suffixes = {".c", ".cc", ".cpp", ".cxx", ".h", ".hpp"}
    queue = [Path(item["relative"]) for item in records
             if Path(item["relative"]).suffix in suffixes]
    seen = set()
    while queue:
        rel = queue.pop(0)
        if rel in seen:
            continue
        seen.add(rel)
        source = ROOT / rel
        if not source.is_file():
            continue
        for name in re.findall(r'^\s*#include\s+"([^"]+)"',
                               source.read_text(errors="replace"), re.M):
            choices = [source.parent / name, ROOT / "include" / name,
                       ROOT / "hls" / name, ROOT / "hls/platform" / name,
                       ROOT / MODEL / name]
            found = None
            for candidate in choices:
                if candidate.is_file():
                    try:
                        found = candidate.resolve().relative_to(ROOT.resolve())
                    except ValueError:
                        found = None
                    if found is not None:
                        break
            if found is None:
                continue
            if not (frozen / found).exists():
                copy_one(found, frozen, records)
            if found.suffix in suffixes and found not in seen:
                queue.append(found)


def tree_records(root: Path) -> list[dict]:
    if not root.exists():
        return []
    return [record(path) for path in sorted(root.rglob("*")) if path.is_file()]


def top_port_evidence(generated: Path) -> dict:
    text = generated.read_text(errors="replace")
    required = {}
    for name in ("compute_cmd", "provenance_cmd", "producer_request"):
        required[name + "_din"] = (
            rf"output\s+(?:wire\s+)?\[511:0\]\s+{name}_din")
        required[name + "_full_n"] = (
            rf"input\s+(?:wire\s+)?{name}_full_n")
        required[name + "_write"] = (
            rf"output\s+(?:wire\s+)?{name}_write")
    for name in ("compute_rsp", "provenance_rsp", "producer_completion"):
        required[name + "_dout"] = (
            rf"input\s+(?:wire\s+)?\[511:0\]\s+{name}_dout")
        required[name + "_empty_n"] = (
            rf"input\s+(?:wire\s+)?{name}_empty_n")
        required[name + "_read"] = (
            rf"output\s+(?:wire\s+)?{name}_read")
    matches = {name: bool(re.search(pattern, text))
               for name, pattern in required.items()}
    bundles = {}
    for bundle in ("embedding", "io", "w_q0", "w_q1", "w_scale", "aux",
                   "state0", "state1", "qkv0", "qkv1", "ff0", "ff1",
                   "att_out"):
        names = sorted(set(re.findall(
            rf"\b(?:m_axi_)?{bundle}_[A-Z0-9_]+\b", text)))
        bundles[bundle] = names
    control = {name: bool(re.search(rf"\b{name}\b", text))
               for name in ("ap_start", "ap_done", "ap_idle", "ap_ready")}
    return {"generated": record(generated), "fifo_matches": matches,
            "fifo_signal_count": sum(matches.values()),
            "axi_bundle_signal_names": bundles,
            "axi_bundle_present": {name: bool(values)
                                   for name, values in bundles.items()},
            "control": control, "control_complete": all(control.values())}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--attempt", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = launcher_state()
    (attempt / "launcher.json").write_text(json.dumps(launcher, indent=2) + "\n")
    if not launcher["pass"]:
        raise RuntimeError("launcher/resource preflight failed")

    source_rel = Path("config/partitioned_controller_sources.cmake")
    sources = source_list(ROOT / source_rel)
    frozen = attempt / "frozen"
    records = []
    for rel in sources + [source_rel,
                          Path("config/full_module_registry.json"),
                          Path("config/production_hls_partitions.json"),
                          MODULE / "tb/production_guard.py",
                          Path("tools/hls_guard_helpers.py"),
                          Path(__file__).resolve().relative_to(ROOT)]:
        copy_one(rel, frozen, records)
    copy_one(MODEL / "laya_model_layout_generated.h", frozen, records)
    copy_one(MODEL / "manifest.json", frozen, records)
    freeze_include_closure(frozen, records)

    cfg = attempt / "partitioned_controller.cfg"
    include_flags = [f"-I{(frozen / 'include').resolve()}",
                     f"-I{(frozen / 'hls').resolve()}",
                     f"-I{(frozen / 'hls/platform').resolve()}",
                     f"-I{(frozen / MODEL).resolve()}"]
    cflags = " ".join([
        "-DLAYA_PARTITIONED_PRODUCTION_CALLER", *include_flags,
        "-std=c++17", "-fno-fast-math", "-fno-associative-math",
        "-ffp-contract=off"])
    lines = ["part=xcu55c-fsvh2892-2L-e", "freqhz=150000000", "[hls]",
             "flow_target=vivado", f"syn.top={TOP}",
             "syn.compile.pipeline_loops=0",
             "syn.array_partition.throughput_driven=off",
             "syn.array_partition.complete_threshold=0"]
    lines += [f"syn.file={(frozen / source).resolve()}" for source in sources]
    lines.append("syn.cflags=" + cflags)
    cfg.write_text("\n".join(lines) + "\n")

    guard = frozen / MODULE / "tb/production_guard.py"
    command = [sys.executable, str(guard), "--out", str(attempt / "guard"),
               "--cwd", str(attempt), "--rss-gib", "24",
               "--timeout-seconds", "1800", "--semantic-stall-seconds", "120",
               "--artifact-progress-root", str(attempt / "work"), "--",
               str(VITIS), "--compile", "--mode", "hls", "--config", str(cfg),
               "--work_dir", str(attempt / "work")]
    manifest = {
        "schema": "laya-partitioned-controller-hls-input-v1",
        "scope": ("arithmetic-free partitioned production Controller static HLS "
                  "generation; original compute/provenance FIFO signals plus one "
                  "internal producer request/completion pair and generated caller "
                  "artifacts; no shell connection, engine AXI causality, full model "
                  "request, joint resources, timing, or performance claim"),
        "top": TOP, "files": records,
        "arithmetic_fallback_sources": [],
        "derived_config": record(cfg),
        "launcher": record(attempt / "launcher.json"),
        "tool": {"path": str(VITIS), "version": subprocess.check_output(
            [str(VITIS), "--version"], text=True, stderr=subprocess.STDOUT)},
        "command": command,
        "profile": {"kind": "static_hls_generation", "maximum_seconds": 1800,
                    "maximum_rss_gib": 24, "semantic_stall_seconds": 120,
                    "cpu_count": 4, "nice": 19, "io_class": "idle",
                    "minimum_mem_available_gib": 192},
    }
    (attempt / "input_manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n")

    tool = subprocess.run(command, cwd=ROOT)
    guard_path = attempt / "guard/guard_result.json"
    guard_result = (json.loads(guard_path.read_text()) if guard_path.is_file()
                    else {"child_exit_code": None,
                          "trigger": "guard_result_missing",
                          "runner_exit_code": tool.returncode})
    candidates = sorted((attempt / "work").glob(
        f"**/syn/verilog/{TOP}.v"))
    ports = None
    if len(candidates) == 1:
        generated = attempt / candidates[0].name
        shutil.copyfile(candidates[0], generated)
        ports = top_port_evidence(generated)
    status = "FAIL"
    if (tool.returncode == 0 and guard_result.get("child_exit_code") == 0 and
            guard_result.get("trigger") is None and ports and
            ports["fifo_signal_count"] == 18 and ports["control_complete"]):
        status = "PASS_SCOPED_GENERATION"
    receipt = {
        "schema": "laya-partitioned-controller-hls-receipt-v1",
        "status": status, "scope": manifest["scope"],
        "exit_code": tool.returncode, "guard_result": guard_result,
        "launcher": record(attempt / "launcher.json"),
        "input_manifest": record(attempt / "input_manifest.json"),
        "derived_config": record(cfg), "port_evidence": ports,
        "generated_candidates": [str(path) for path in candidates],
        "partial_work_files": tree_records(attempt / "work"),
        "guard_files": tree_records(attempt / "guard"),
    }
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_PARTITIONED_CONTROLLER_HLS_" + status, flush=True)
    return 0 if status == "PASS_SCOPED_GENERATION" else 1


if __name__ == "__main__":
    raise SystemExit(main())
