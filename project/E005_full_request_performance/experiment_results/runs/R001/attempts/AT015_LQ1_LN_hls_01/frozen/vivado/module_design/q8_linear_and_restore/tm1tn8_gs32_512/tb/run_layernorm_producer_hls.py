#!/usr/bin/env python3
"""Freeze, test, and synthesize the first partitioned LayerNorm producer."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[5]
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
MODEL = Path("build/model-current-production-v2-20261011")
VITIS = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/v++")
VITIS_INCLUDE = VITIS.parents[1] / "include"
CHECKPOINT = Path("results/engineering_p2/full_cpu_final_20261007/oracle/B1_from_b0_S128/encoder_00_out.f32.bin")

SOURCES = [
    Path("hls/operators/layernorm_producer_engine.cpp"),
    Path("hls/operators/layernorm_compute.cpp"),
    Path("hls/platform/producer_engine_codec.cpp"),
    Path("hls/platform/producer_engine_hls.cpp"),
    Path("hls/common/laya_numeric.cpp"),
    Path("hls/common/laya_tasks.cpp"),
]
TB = MODULE / "tb/layernorm_producer_csim_tb.cpp"
CODEC_TB = MODULE / "tb/producer_engine_codec_tb.cpp"
FIXTURE_TOOL = MODULE / "tb/make_layernorm_producer_fixture.py"
GUARD = MODULE / "tb/production_guard.py"


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


def run_capture(command: list[str], cwd: Path, log: Path) -> dict:
    started = time.monotonic()
    with log.open("w") as stream:
        result = subprocess.run(command, cwd=cwd, stdout=stream,
                                stderr=subprocess.STDOUT)
    return {"command": command, "exit_code": result.returncode,
            "elapsed_seconds": time.monotonic() - started, "log": record(log)}


def tree_records(root: Path) -> list[dict]:
    if not root.exists():
        return []
    return [record(path) for path in sorted(root.rglob("*")) if path.is_file()]


def port_evidence(path: Path) -> dict:
    text = path.read_text(errors="replace")
    patterns = {
        "request_dout": r"input\s+(?:wire\s+)?\[511:0\]\s+request_stream_dout",
        "request_empty_n": r"input\s+(?:wire\s+)?request_stream_empty_n",
        "request_read": r"output\s+(?:wire\s+)?request_stream_read",
        "completion_din": r"output\s+(?:wire\s+)?\[511:0\]\s+completion_stream_din",
        "completion_full_n": r"input\s+(?:wire\s+)?completion_stream_full_n",
        "completion_write": r"output\s+(?:wire\s+)?completion_stream_write",
    }
    fifo = {name: bool(re.search(pattern, text))
            for name, pattern in patterns.items()}
    axi = {}
    for bundle, signals in {
            "source": ("ARADDR", "ARVALID", "ARREADY", "RDATA", "RRESP",
                       "RVALID", "RREADY"),
            "destination": ("AWADDR", "AWVALID", "AWREADY", "WDATA",
                            "WSTRB", "WVALID", "WREADY", "BRESP", "BVALID",
                            "BREADY")}.items():
        axi[bundle] = {signal: bool(re.search(
            rf"\b(?:m_axi_)?{bundle}_{signal}\b", text)) for signal in signals}
    return {"generated": record(path), "fifo": fifo,
            "fifo_signal_count": sum(fifo.values()), "axi": axi,
            "axi_complete": {name: all(values.values())
                             for name, values in axi.items()}}


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

    frozen = attempt / "frozen"
    records: list[dict] = []
    for rel in SOURCES + [TB, CODEC_TB, FIXTURE_TOOL, GUARD,
                          Path("tools/hls_guard_helpers.py"),
                          Path("config/production_hls_partitions.json"),
                          Path("config/full_module_registry.json"),
                          Path(__file__).resolve().relative_to(ROOT)]:
        copy_one(rel, frozen, records)
    copy_one(MODEL / "laya_model_layout_generated.h", frozen, records)
    copy_one(MODEL / "manifest.json", frozen, records)
    frozen_checkpoint = copy_one(CHECKPOINT, frozen, records)
    freeze_include_closure(frozen, records)

    fixture_dir = attempt / "fixture"
    fixture_command = [sys.executable, str(frozen / FIXTURE_TOOL),
                       "--input", str(frozen_checkpoint),
                       "--out", str(fixture_dir)]
    fixture = run_capture(fixture_command, ROOT, attempt / "fixture.log")
    if fixture["exit_code"]:
        raise RuntimeError("fixture generation failed")

    include_flags = [f"-I{(frozen / 'include').resolve()}",
                     f"-I{(frozen / 'hls').resolve()}",
                     f"-I{(frozen / 'hls/platform').resolve()}",
                     f"-I{(frozen / MODEL).resolve()}"]
    codec_exe = attempt / "producer_engine_codec_tb"
    codec_command = ["g++", "-std=c++17", "-O2", "-Wall", "-Wextra",
                     "-Werror", *include_flags, str(frozen / CODEC_TB),
                     str(frozen / "hls/platform/producer_engine_codec.cpp"),
                     str(frozen / "hls/common/laya_numeric.cpp"),
                     str(frozen / "hls/common/laya_tasks.cpp"),
                     "-o", str(codec_exe)]
    codec_build = run_capture(codec_command, ROOT, attempt / "codec_build.log")
    codec_run = ({"exit_code": None} if codec_build["exit_code"] else
                 run_capture([str(codec_exe)], ROOT, attempt / "codec_run.log"))

    csim_exe = attempt / "layernorm_producer_csim"
    csim_flags = [*include_flags, f"-I{VITIS_INCLUDE.resolve()}"]
    csim_command = ["g++", "-std=c++17", "-O2", "-Wno-comment",
                    "-Wno-deprecated-copy", "-Wno-unknown-pragmas",
                    *csim_flags, str(frozen / TB),
                    *[str(frozen / source) for source in SOURCES],
                    "-lm", "-o", str(csim_exe)]
    csim_build = run_capture(csim_command, ROOT, attempt / "csim_build.log")
    csim_run = ({"exit_code": None} if csim_build["exit_code"] else
                run_capture([str(csim_exe),
                             str(fixture_dir / "source_rows16.f32.bin"),
                             str(fixture_dir / "gold_rows16.f32.bin")],
                            ROOT, attempt / "csim_run.log"))

    cfg = attempt / "layernorm_producer.cfg"
    cflags = " ".join([*include_flags, "-std=c++17", "-fno-fast-math",
                       "-fno-associative-math", "-ffp-contract=off"])
    lines = ["part=xcu55c-fsvh2892-2L-e", "freqhz=150000000", "[hls]",
             "flow_target=vivado", "syn.top=laya_layernorm_producer_engine",
             "syn.compile.pipeline_loops=0",
             "syn.array_partition.throughput_driven=off",
             "syn.array_partition.complete_threshold=0"]
    lines += [f"syn.file={(frozen / source).resolve()}" for source in SOURCES]
    lines.append("syn.cflags=" + cflags)
    cfg.write_text("\n".join(lines) + "\n")

    guard = frozen / GUARD
    command = [sys.executable, str(guard), "--out", str(attempt / "guard"),
               "--cwd", str(attempt), "--rss-gib", "24",
               "--timeout-seconds", "1800", "--semantic-stall-seconds", "120",
               "--artifact-progress-root", str(attempt / "work"), "--",
               str(VITIS), "--compile", "--mode", "hls", "--config", str(cfg),
               "--work_dir", str(attempt / "work")]
    manifest = {
        "schema": "laya-layernorm-producer-hls-input-v1",
        "scope": "partitioned gamma0 LN_ATTN/LN_FFN producer codec, host HLS-call CSim, and bounded static HLS generation; no caller, shell, hub, RTL runtime, full request, resource or performance claim",
        "top": "laya_layernorm_producer_engine",
        "files": records,
        "fixture": record(fixture_dir / "manifest.json"),
        "fixture_run": fixture,
        "codec_build": codec_build, "codec_run": codec_run,
        "csim_build": csim_build, "csim_run": csim_run,
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
        "**/syn/verilog/laya_layernorm_producer_engine.v"))
    ports = None
    if len(candidates) == 1:
        generated = attempt / candidates[0].name
        shutil.copyfile(candidates[0], generated)
        ports = port_evidence(generated)
    status = "FAIL"
    if (codec_build["exit_code"] == 0 and codec_run["exit_code"] == 0 and
            csim_build["exit_code"] == 0 and csim_run["exit_code"] == 0 and
            tool.returncode == 0 and guard_result.get("child_exit_code") == 0 and
            guard_result.get("trigger") is None and ports and
            ports["fifo_signal_count"] == 6 and
            all(ports["axi_complete"].values())):
        status = "PASS_SCOPED_GENERATION"
    receipt = {
        "schema": "laya-layernorm-producer-hls-receipt-v1",
        "status": status, "scope": manifest["scope"],
        "exit_code": tool.returncode, "guard_result": guard_result,
        "launcher": record(attempt / "launcher.json"),
        "input_manifest": record(attempt / "input_manifest.json"),
        "derived_config": record(cfg), "fixture": tree_records(fixture_dir),
        "codec_build": codec_build, "codec_run": codec_run,
        "csim_build": csim_build, "csim_run": csim_run,
        "port_evidence": ports,
        "generated_candidates": [str(path) for path in candidates],
        "partial_work_files": tree_records(attempt / "work"),
        "guard_files": tree_records(attempt / "guard"),
    }
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_LAYERNORM_PRODUCER_HLS_" + status, flush=True)
    return 0 if status == "PASS_SCOPED_GENERATION" else 1


if __name__ == "__main__":
    raise SystemExit(main())
