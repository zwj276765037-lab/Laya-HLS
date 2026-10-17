#!/usr/bin/env python3
"""Freeze the actual Vitis CSim input/configuration closure for four requests."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil

ROOT = Path(__file__).resolve().parents[5]


def rec(p):
    p = p.resolve()
    return {"path": str(p), "bytes": p.stat().st_size,
            "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--package", type=Path, required=True)
parser.add_argument("--build-manifest", type=Path, required=True)
parser.add_argument("--requests", type=Path, required=True)
parser.add_argument("--attempt", type=Path, required=True)
args = parser.parse_args()
package, attempt = args.package.resolve(), args.attempt.resolve()
assert not attempt.exists(), str(attempt)
build = json.loads(args.build_manifest.read_text())
assert rec(package / "manifest.json") == build["package_manifest"]
for item in build["compiled_dependencies"]:
    assert rec(Path(item["path"])) == item, item["path"]
source_list = re.findall(r"^\s*(hls/[^\s]+\.cpp)\s*$",
                        (ROOT / "config/full_sources.cmake").read_text(), re.M)
assert len(source_list) == 27
cpu_services = re.findall(r"^\s*(vivado/module_design/[^\s]+\.cpp)\s*$",
                         (ROOT / "config/full_sources.cmake").read_text(), re.M)
compiled = {item["path"] for item in build["compiled_dependencies"]}
source_list += [name for name in cpu_services if str(ROOT / name) in compiled]
attempt.mkdir(parents=True)
work = attempt / "work"
work.mkdir()
source_root = work / "source_root"
frozen = []
for item in build["compiled_dependencies"]:
    original = Path(item["path"])
    target = source_root / original.relative_to(ROOT)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(original, target)
    assert rec(target)["sha256"] == item["sha256"]
    frozen.append({"original": item, "frozen": rec(target)})
flags = " ".join(["-I" + str(source_root / "include"), "-I" + str(source_root / "hls"),
                  "-I" + str(source_root / "hls/platform"), "-I" + str(package),
                  "-std=c++17", "-O2", "-fno-fast-math",
                  "-fno-associative-math", "-ffp-contract=off"])
config = work / "current_full_csim.cfg"
lines = ["part=xcu55c-fsvh2892-2L-e", "freqhz=150000000", "[hls]",
         "flow_target=vivado", "syn.top=laya_typed_q8_forward",
         "syn.compile.pipeline_loops=0", "syn.array_partition.throughput_driven=off",
         "syn.array_partition.complete_threshold=0"]
lines += ["syn.file=" + str(source_root / name) for name in source_list]
lines += ["syn.cflags=" + flags, "csim.stdmath=true",
          "tb.file=" + str(source_root / "tests/current_production_full_csim_tb.cpp"),
          "tb.cflags=" + flags]
config.write_text("\n".join(lines) + "\n")
report = {"schema": "laya-current-production-vitis-csim-v1",
          "configuration": rec(config), "package": rec(package / "manifest.json"),
          "build_manifest": rec(args.build_manifest),
          "compiled_dependency_closure": build["compiled_dependencies"],
          "frozen_compiled_dependencies": frozen,
          "configuration_generator": rec(Path(__file__)),
          "request_identity": rec(args.requests / "identity_manifest.json"),
          "raw_identity": rec(args.requests / "raw_identity_manifest.json"),
          "testbench": rec(ROOT / "tests/current_production_full_csim_tb.cpp"),
          "scope": "Vitis CSim of the production full_execute_cpu_request dispatcher used beneath the 13-BO wrapper; four persistent requests and independent full graph checkpoints. No RTL run or hardware performance."}
(attempt / "input_manifest.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
print(f"FULL_CURRENT_VITIS_CONFIG_PASS sources={len(source_list)} persistent_requests=4 stdmath=1", flush=True)
