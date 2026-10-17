#!/usr/bin/env python3
"""Build or run the externally preloaded Attention CPU diagnostic."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import re
import subprocess


MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[3]
PACKAGE = ROOT / "build/model-attention-rtl-repair-20261008"
OLD = ROOT / "results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision"
NEW = MODULE / "tb/fixture_preloaded"
RUNS = MODULE / "runs"
BIN = RUNS / "attention_preloaded_cpu"


def sha256(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1 << 20), b""):
            value.update(block)
    return value.hexdigest()


def save(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")


def official_sources() -> list[Path]:
    config = ROOT / "config/full_sources.cmake"
    source = re.findall(r"^  (hls/\S+\.cpp)$", config.read_text(), re.MULTILINE)
    if len(source) != 25 or len(set(source)) != 25:
        raise RuntimeError("official 25-source closure changed")
    if source.count("hls/control/full_forward_controller.cpp") != 1:
        raise RuntimeError("production controller must occur exactly once")
    return [ROOT / entry for entry in source
            if entry != "hls/control/full_forward_controller.cpp"]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("build", "execute"))
    args = parser.parse_args()
    stage = RUNS / f"cpu_{args.phase}"
    stage.mkdir(parents=True, exist_ok=True)
    production = official_sources()
    controller = ROOT / "hls/control/full_forward_controller.cpp"
    if sha256(controller) != "23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623":
        raise RuntimeError("reviewed production controller changed")
    sources = [*production, controller, ROOT / "config/full_sources.cmake",
               MODULE.parent / "source/design.md", MODULE / "source/attention_preloaded_abi.h",
               MODULE / "source/attention_preloaded_slice.cpp",
               MODULE / "tb/sha256_test_only.h",
               MODULE / "tb/test_attention_preloaded.cpp",
               MODULE / "tb/generate_preloaded_fixture.py",
               MODULE / "source/run_preloaded_cpu.py",
               ROOT / "tests/full_reference.py",
               OLD / "request.bin", OLD / "qkv_final.f32.bin",
               OLD / "attention_mask.u8.bin", OLD / "score.f32.bin",
               OLD / "probability.f32.bin", OLD / "av.f32.bin",
               OLD / "fixture_report.json", PACKAGE / "manifest.json",
               PACKAGE / "aux.bin", PACKAGE / "laya_model_layout_generated.h",
               NEW / "expected_hashes.txt", NEW / "fixture_manifest.json",
               NEW / "qkv_changed.f32.bin"]
    sources.extend(sorted(NEW.glob("*_*.f32.bin")))
    sources.extend(sorted(NEW.glob("*.u32le.bin")))
    sources.extend(sorted((ROOT / "include").glob("*.h")))
    sources.extend(sorted((ROOT / "hls").rglob("*.h")))
    inputs = {str(path): {"sha256": sha256(path), "bytes": path.stat().st_size}
              for path in sources}
    command = (["/usr/bin/g++", "-std=c++17", "-O2", "-fno-fast-math",
                "-ffp-contract=off", "-I" + str(ROOT / "include"),
                "-I" + str(ROOT / "hls"), "-I" + str(ROOT / "hls/platform"),
                "-I" + str(PACKAGE), "-I" + str(MODULE / "source"),
                str(MODULE / "source/attention_preloaded_slice.cpp"),
                *(str(path) for path in production),
                str(MODULE / "tb/test_attention_preloaded.cpp"),
                "-lm", "-o", str(BIN)]
               if args.phase == "build" else
               [str(BIN), str(PACKAGE), str(OLD), str(NEW)])
    if args.phase == "execute" and not BIN.is_file():
        raise RuntimeError("CPU binary not built")
    record = {
        "schema": "d2_preloaded_cpu_run_v1",
        "at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "phase": args.phase,
        "argv": command,
        "inputs": inputs,
        "binary_before_sha256": sha256(BIN) if BIN.is_file() else None,
        "included_controller": str(controller),
        "linked_production_translation_units": len(production),
        "production_build_tag": "fe067c8aa0627ad770096f9721394645",
    }
    save(stage / "input_manifest.json", record)
    result = subprocess.run(command, cwd=ROOT, check=False)
    record["exit_code"] = result.returncode
    record["binary_after_sha256"] = sha256(BIN) if BIN.is_file() else None
    save(stage / "result.json", record)
    print("D2_PRELOADED_CPU_GATE", args.phase, "exit", result.returncode,
          "sources", len(production), flush=True)
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
