#!/usr/bin/env python3
"""Bind a completed real Vitis full-graph CSim to its frozen input closure."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def rec(path):
    path = Path(path).resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument("--attempt", type=Path, required=True)
ap.add_argument("--cpu-receipt", type=Path, required=True)
args = ap.parse_args()
attempt = args.attempt.resolve()
inputs = json.loads((attempt / "input_manifest.json").read_text())
guard = json.loads((attempt / "guard/guard_result.json").read_text())
log = (attempt / "guard/driver.log").read_text()
terminal = ("PERSISTENT_CPU_FULL_CSIM_PASS requests=4 normal=3 "
            "checkpoints=141 values=18094384 recovered_fault=1")
assert guard["child_exit_code"] == 0 and guard["trigger"] is None
assert terminal in log and "CSim done with 0 errors" in log
frozen = {item["frozen"]["path"]: item["frozen"]
          for item in inputs["frozen_compiled_dependencies"]}
for name, item in frozen.items():
    assert rec(name) == item, name
assert rec(inputs["package"]["path"]) == inputs["package"]
assert rec(inputs["configuration"]["path"]) == inputs["configuration"]
build = json.loads(Path(inputs["build_manifest"]["path"]).read_text())
package_root = Path(inputs["package"]["path"]).parent
original_package = {item["path"]: item for item in build["compiled_dependencies"]
                    if Path(item["path"]).is_relative_to(package_root)}
for name, item in original_package.items():
    assert rec(name) == item
executables = list((attempt / "work/hls").rglob("csim.exe"))
assert len(executables) == 1
executable = executables[0]
makefile = executable.parent / "csim.mk"
make = makefile.read_text()
for flag in ("-O2", "-fno-fast-math", "-fno-associative-math", "-ffp-contract=off"):
    assert flag in make, flag
assert "__SIM_MATHSTD__ = 1" in make
libraries = subprocess.run(["ldd", str(executable)], capture_output=True,
                           text=True, check=True).stdout
assert "libm.so.6" in libraries and "libhlsm" not in libraries
(attempt / "dynamic_libraries.txt").write_text(libraries)
actual = set()
dependency_files = sorted(executable.parent.rglob("*.d"))
assert dependency_files
source_root = attempt / "work/source_root"
for dep in dependency_files:
    for name in dep.read_text().replace("\\\n", " ").split(":", 1)[1].split():
        path = (executable.parent / name).resolve()
        if path.is_relative_to(source_root):
            assert str(path) in frozen, str(path)
            actual.add(path)
        elif path.is_relative_to(package_root):
            assert str(path) in original_package, str(path)
            actual.add(path)
assert sum(p.suffix == ".cpp" for p in actual) >= 28
receipt = {"schema": "laya-current-production-full-vitis-csim-v1",
           "status": "PASS_SCOPED", "terminal": terminal,
           "scope": inputs["scope"], "guard": guard,
           "input_manifest": rec(attempt / "input_manifest.json"),
           "cpu_receipt": rec(args.cpu_receipt), "executable": rec(executable),
           "makefile": rec(makefile), "dynamic_libraries": rec(attempt / "dynamic_libraries.txt"),
           "actual_compiled_dependencies": [rec(p) for p in sorted(actual)],
           "compiler_dependency_files": [rec(p) for p in dependency_files],
           "driver_log": rec(attempt / "guard/driver.log"),
           "generated_rtl": "NOT_RUN", "full_hardware_graph": "NOT_RUN_COST"}
(attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
print("FULL_CURRENT_VITIS_RECEIPT_PASS", rec(attempt / "receipt.json")["sha256"],
      "compiled_dependencies=" + str(len(actual)))
