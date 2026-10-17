#!/usr/bin/env python3
"""Replay the ATN0 snapshot and require numeric and measurement terminals."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys


def rec(path):
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("attempt", type=Path)
    parser.add_argument("name")
    parser.add_argument("rows", type=int, choices=(1, 4, 16, 128))
    parser.add_argument("--manifest", default="source_manifest.json")
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    manifest_path = attempt / args.manifest
    manifest = json.loads(manifest_path.read_text())
    for source in manifest["sources"]:
        if rec(Path(source["frozen"]["path"])) != source["frozen"]:
            raise RuntimeError("ATN0 frozen input changed")
    work = attempt / args.name
    work.mkdir(exist_ok=False)
    build = attempt / "build/vivado/attention_tile.sim/sim_1/behav/xsim"
    shutil.copytree(build / "xsim.dir", work / "xsim.dir")
    for path in [*build.glob("*.dat"), *build.glob("*.ini")]:
        shutil.copy2(path, work / path.name)
    (work / "run.tcl").write_text("run all\nquit\n")
    command = ["/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim",
               "attention_tile_tb_behav", "-tclbatch", str(work / "run.tcl"),
               "-log", str(work / "simulate.log"), "-wdb", str(work / "tile.wdb"),
               "-testplusarg", f"FIXTURE={manifest['fixture']}",
               "-testplusarg", f"TRACE={attempt / 'trace'}",
               "-testplusarg", f"ROWS={args.rows}", "-testplusarg", "PROTOCOL=0"]
    (work / "input_manifest.json").write_text(json.dumps({
        "source_manifest": rec(manifest_path), "command": command, "rows": args.rows,
        "compiled_snapshot": {str(path.relative_to(work)): rec(path)
                              for path in (work / "xsim.dir").rglob("*") if path.is_file()},
    }, indent=2, sort_keys=True) + "\n")
    environment = os.environ.copy()
    environment["SIM_VER_XSIM"] = "2025.2"
    environment["GCC_VER_XSIM"] = "9.3.0"
    print(f"ATTENTION_ATN0_RTL_BEGIN rows={args.rows}", flush=True)
    result = subprocess.run(command, cwd=work, env=environment, check=False)
    log = (work / "simulate.log").read_text(errors="replace") if (work / "simulate.log").exists() else ""
    required = [f"ATTENTION_SERVICE_TILE_RTL_PASS rows={args.rows} keys128 D64",
                "ATTENTION_SERVICE_TILE_SM_MEASURE commands=",
                "ATTENTION_SERVICE_TILE_CMD_MEASURE cmd=20",
                "ATTENTION_SERVICE_TILE_EXP_MEASURE worker=3"]
    if result.returncode or any(marker not in log for marker in required) or re.search(r"(^|\n)(Fatal:|ERROR:)", log):
        sys.exit(result.returncode or 1)
    print(f"ATTENTION_ATN0_RTL_END rows={args.rows} numeric_and_measurement=1", flush=True)


if __name__ == "__main__":
    main()
