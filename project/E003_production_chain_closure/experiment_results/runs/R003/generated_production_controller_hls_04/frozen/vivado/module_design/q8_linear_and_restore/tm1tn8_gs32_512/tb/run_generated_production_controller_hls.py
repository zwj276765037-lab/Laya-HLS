#!/usr/bin/env python3
"""Freeze and synthesize the current production controller HLS top.

This is a bounded static-generation check.  It does not run a model request
and does not claim that the generated AXI adapters have been integrated with
the persistent provenance hub.
"""

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
OLD_ROOT_MARKER = "/Workspace/Laya/LLAMA-HLS/Laya-baseline/"


def record(path: Path) -> dict:
    path = path.resolve()
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def launcher_state() -> dict:
    available_kib = None
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            available_kib = int(line.split()[1])
            break
    state = {
        "pid": os.getpid(),
        "cpu_affinity": sorted(os.sched_getaffinity(0)),
        "nice": os.getpriority(os.PRIO_PROCESS, 0),
        "ionice": subprocess.run(
            ["ionice", "-p", str(os.getpid())], check=True, text=True,
            capture_output=True).stdout.strip(),
        "mem_available_kib": available_kib,
        "required_mem_available_kib": 192 * 1024 * 1024,
    }
    state["pass"] = (
        state["cpu_affinity"] == [0, 1, 2, 3] and
        state["nice"] == 19 and state["ionice"].startswith("idle") and
        available_kib is not None and
        available_kib > state["required_mem_available_kib"])
    return state


def source_list(path: Path) -> list[Path]:
    result = []
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if stripped.startswith("hls/"):
            result.append(Path(stripped))
    if len(result) < 30:
        raise RuntimeError(f"incomplete full source list: {len(result)}")
    return result


def copy_one(rel: Path, frozen: Path, records: list[dict]) -> Path:
    src = ROOT / rel
    if not src.is_file():
        raise RuntimeError(f"missing input: {rel}")
    dst = frozen / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dst)
    records.append({"relative": str(rel), "original": record(src),
                    "frozen": record(dst)})
    return dst


def freeze_quoted_include_closure(frozen: Path,
                                  records: list[dict]) -> None:
    """Freeze every project-local quoted include reachable from C/C++ inputs."""
    source_suffixes = {".c", ".cc", ".cpp", ".cxx", ".h", ".hpp"}
    queue = [Path(item["relative"]) for item in records
             if item.get("relative") and
             Path(item["relative"]).suffix in source_suffixes]
    seen: set[Path] = set()
    while queue:
        rel = queue.pop(0)
        if rel in seen:
            continue
        seen.add(rel)
        source = (ROOT / rel).resolve()
        if not source.is_file():
            continue
        text = source.read_text(errors="replace")
        for local_name in re.findall(
                r'^\s*#include\s+"([^"]+)"', text,
                flags=re.MULTILINE):
            candidates = [source.parent / local_name,
                          ROOT / "include" / local_name,
                          ROOT / "hls" / local_name,
                          ROOT / "hls/platform" / local_name,
                          ROOT / MODEL / local_name]
            target_rel = None
            for candidate in candidates:
                candidate = candidate.resolve()
                try:
                    candidate_rel = candidate.relative_to(ROOT.resolve())
                except ValueError:
                    continue
                if candidate.is_file():
                    target_rel = candidate_rel
                    break
            if target_rel is None:
                continue
            if not (frozen / target_rel).exists():
                copy_one(target_rel, frozen, records)
            if target_rel.suffix in source_suffixes and target_rel not in seen:
                queue.append(target_rel)


def current_relative(old_path: str) -> Path:
    marker = old_path.find(OLD_ROOT_MARKER)
    if marker < 0:
        raise RuntimeError(f"blackbox path is outside historical root: {old_path}")
    return Path(old_path[marker + len(OLD_ROOT_MARKER):])


def freeze_blackbox(rel: Path, frozen: Path,
                    records: list[dict]) -> Path:
    source = ROOT / rel
    description = json.loads(source.read_text())
    dependencies = []
    for item in description.get("c_files", []):
        dependencies.append((item, "c_file"))
    for index, value in enumerate(description.get("rtl_files", [])):
        dependencies.append((description["rtl_files"], index))
    for container, key in dependencies:
        old = container[key]
        dep_rel = current_relative(old)
        target = copy_one(dep_rel, frozen, records)
        if key == "c_file":
            # Blackbox wrappers include private declarations beside the C++
            # source.  Freeze those quoted local includes as part of the same
            # compilation identity instead of relying on the live tree.
            source_text = (ROOT / dep_rel).read_text()
            for local_name in re.findall(
                    r'^\s*#include\s+"([^"]+)"', source_text,
                    flags=re.MULTILINE):
                local_rel = dep_rel.parent / local_name
                if ((ROOT / local_rel).is_file() and
                        not (frozen / local_rel).exists()):
                    copy_one(local_rel, frozen, records)
        container[key] = str(target.resolve())
        if key == "c_file":
            container["cflag"] = (f"-I{(frozen / 'include').resolve()} "
                                    "-std=c++17 -fno-fast-math "
                                    "-fno-associative-math -ffp-contract=off")
    target = frozen / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(description, indent=2) + "\n")
    records.append({"relative": str(rel), "original": record(source),
                    "frozen_rewritten": record(target),
                    "rewrite": "historical absolute blackbox paths rebound to frozen current inputs"})
    return target


def tree_records(root: Path) -> list[dict]:
    result = []
    if not root.exists():
        return result
    for path in sorted(p for p in root.rglob("*") if p.is_file()):
        result.append(record(path))
    return result


def top_port_evidence(generated: Path) -> dict:
    text = generated.read_text(errors="replace")
    required = {}
    for name in ("compute_cmd", "provenance_cmd"):
        required[name + "_din"] = rf"output\s+(?:wire\s+)?\[511:0\]\s+{name}_din"
        required[name + "_full_n"] = rf"input\s+(?:wire\s+)?{name}_full_n"
        required[name + "_write"] = rf"output\s+(?:wire\s+)?{name}_write"
    for name in ("compute_rsp", "provenance_rsp"):
        required[name + "_dout"] = rf"input\s+(?:wire\s+)?\[511:0\]\s+{name}_dout"
        required[name + "_empty_n"] = rf"input\s+(?:wire\s+)?{name}_empty_n"
        required[name + "_read"] = rf"output\s+(?:wire\s+)?{name}_read"
    matches = {name: bool(re.search(pattern, text))
               for name, pattern in required.items()}
    writable = {}
    for bundle in ("io", "state0", "state1", "qkv0", "qkv1",
                   "ff0", "ff1", "att_out"):
        writable[bundle] = {
            signal: bool(re.search(
                rf"\b(?:m_axi_)?{bundle}_{signal}\b", text))
            for signal in ("AWADDR", "AWVALID", "AWREADY", "WDATA",
                           "WSTRB", "WVALID", "WREADY", "BRESP",
                           "BVALID", "BREADY")
        }
    return {"generated": record(generated), "fifo_matches": matches,
            "fifo_signal_count": sum(matches.values()),
            "writable_axi_matches": writable,
            "writable_axi_complete": {
                name: all(signals.values()) for name, signals in writable.items()
            }}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--attempt", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(parents=True, exist_ok=False)
    launcher = launcher_state()
    (attempt / "launcher.json").write_text(
        json.dumps(launcher, indent=2) + "\n")
    if not launcher["pass"]:
        raise RuntimeError("launcher/resource preflight failed")
    frozen = attempt / "frozen"
    records: list[dict] = []

    sources_file = Path("config/full_sources.cmake")
    inputs = source_list(ROOT / sources_file)
    copy_one(sources_file, frozen, records)
    copy_one(Path("config/full_module_registry.json"), frozen, records)
    copy_one(Path("config/production_rtl_blackboxes.json"), frozen, records)
    copy_one(Path(__file__).resolve().relative_to(ROOT), frozen, records)
    guard_rel = MODULE / "tb/production_guard.py"
    copy_one(guard_rel, frozen, records)
    # production_guard resolves this import from frozen/tools.
    copy_one(Path("tools/hls_guard_helpers.py"), frozen, records)
    for rel in inputs:
        copy_one(rel, frozen, records)
    for base in (Path("include"), Path("hls")):
        for path in sorted((ROOT / base).rglob("*")):
            if path.is_file() and path.suffix in (".h", ".hpp"):
                rel = path.relative_to(ROOT)
                if not (frozen / rel).exists():
                    copy_one(rel, frozen, records)
    model_header = copy_one(MODEL / "laya_model_layout_generated.h",
                            frozen, records)
    copy_one(MODEL / "manifest.json", frozen, records)

    blackboxes = []
    for name in ("laya_quant_group_service.json",
                 "laya_tm4_group_service.json"):
        blackboxes.append(freeze_blackbox(
            MODULE / "source/blackbox" / name, frozen, records))
    freeze_quoted_include_closure(frozen, records)

    cfg = attempt / "production_controller.cfg"
    cflags = (f"-DLAYA_EXTERNAL_RTL_MODELS -I{(frozen / 'include').resolve()} "
              f"-I{(frozen / 'hls').resolve()} "
              f"-I{(frozen / 'hls/platform').resolve()} "
              f"-I{model_header.parent.resolve()} -std=c++17 "
              "-fno-fast-math -fno-associative-math -ffp-contract=off")
    lines = ["part=xcu55c-fsvh2892-2L-e", "freqhz=150000000", "[hls]",
             "flow_target=vivado",
             "syn.top=laya_typed_q8_forward_controller",
             "syn.compile.pipeline_loops=0",
             "syn.array_partition.throughput_driven=off",
             "syn.array_partition.complete_threshold=0"]
    lines.extend(f"syn.file={(frozen / rel).resolve()}" for rel in inputs)
    lines.append(f"syn.cflags={cflags}")
    lines.extend(f"syn.blackbox.file={path.resolve()}" for path in blackboxes)
    cfg.write_text("\n".join(lines) + "\n")

    guard = frozen / guard_rel
    command = [sys.executable, str(guard), "--out", str(attempt / "guard"),
               "--cwd", str(attempt), "--rss-gib", "24",
               "--timeout-seconds", "1800", "--semantic-stall-seconds", "120",
               "--", str(VITIS), "--compile", "--mode", "hls",
               "--config", str(cfg), "--work_dir", str(attempt / "work")]
    manifest = {
        "schema": "laya-generated-production-controller-hls-input-v1",
        "scope": ("current production controller HLS static generation, four private FIFO "
                  "ports, writable m_axi structure, and generated artifacts; no model request"),
        "top": "laya_typed_q8_forward_controller",
        "model_package": str(MODEL),
        "files": records,
        "derived_config": record(cfg),
        "launcher": record(attempt / "launcher.json"),
        "tool": {"path": str(VITIS),
                 "version": subprocess.check_output(
                     [str(VITIS), "--version"], text=True,
                     stderr=subprocess.STDOUT)},
        "command": command,
        "profile": {"kind": "static_hls_generation",
                    "maximum_seconds": 1800, "maximum_rss_gib": 24,
                    "semantic_stall_seconds": 120,
                    "cpu_count": 4, "nice": 19, "io_class": "idle",
                    "minimum_mem_available_gib": 192},
    }
    (attempt / "input_manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n")

    result = subprocess.run(command, cwd=ROOT)
    guard_result_path = attempt / "guard/guard_result.json"
    if guard_result_path.is_file():
        guard_state = json.loads(guard_result_path.read_text())
    else:
        guard_state = {
            "child_exit_code": None,
            "trigger": "guard_result_missing",
            "runner_exit_code": result.returncode,
        }
    candidates = sorted((attempt / "work").glob(
        "**/syn/verilog/laya_typed_q8_forward_controller.v"))
    port_evidence = None
    status = "FAIL"
    if (result.returncode == 0 and guard_state["child_exit_code"] == 0 and
            guard_state["trigger"] is None and len(candidates) == 1):
        frozen_generated = attempt / candidates[0].name
        shutil.copyfile(candidates[0], frozen_generated)
        port_evidence = top_port_evidence(frozen_generated)
        if (port_evidence["fifo_signal_count"] == 12 and
                all(port_evidence["writable_axi_complete"].values())):
            status = "PASS_SCOPED_GENERATION"

    receipt = {
        "schema": "laya-generated-production-controller-hls-receipt-v1",
        "status": status, "scope": manifest["scope"],
        "exit_code": result.returncode, "guard_result": guard_state,
        "launcher": record(attempt / "launcher.json"),
        "input_manifest": record(attempt / "input_manifest.json"),
        "derived_config": record(cfg), "port_evidence": port_evidence,
        "generated_candidates": [str(path) for path in candidates],
        "partial_work_files": tree_records(attempt / "work"),
        "guard_files": tree_records(attempt / "guard"),
    }
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print("FULL_CURRENT_GENERATED_PRODUCTION_CONTROLLER_HLS_" + status)
    return 0 if status == "PASS_SCOPED_GENERATION" else 1


if __name__ == "__main__":
    raise SystemExit(main())
