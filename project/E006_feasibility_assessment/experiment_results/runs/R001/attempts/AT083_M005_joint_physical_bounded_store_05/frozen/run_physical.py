#!/usr/bin/env python3
"""Identity-gated Vivado joint synthesis/route for the exact M005 top."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

AT = Path(__file__).resolve().parent.parent
ROOT = AT.parents[6]
GUARD = ROOT / "project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/ffn0_guard.py"
VIVADO = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")


def sha(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def verify(entries):
    for entry in entries:
        file = Path(entry["path"])
        if not file.is_file() or file.stat().st_size != entry["bytes"] or sha(file) != entry["sha256"]:
            raise RuntimeError(f"input mismatch: {file}")
    return len(entries)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("phase", choices=("synth", "route"))
    args = parser.parse_args()
    out = AT / f"preflight_{args.phase}.json"
    result = {"status": "REJECT", "spawned": False, "phase": args.phase}
    try:
        if (AT / f"guard_{args.phase}").exists():
            raise RuntimeError("guard directory already exists; no rerun")
        local = json.loads((AT / "input_manifest.json").read_text())
        source_path = Path(local["source_manifest_path"])
        if sha(source_path) != local["source_manifest_sha256"]:
            raise RuntimeError("source manifest changed")
        source = json.loads(source_path.read_text())
        result["source_files"] = verify(source["files"])
        result["preparation_files"] = verify(local["files"])
        rtl = (AT / "frozen/rtl_sources.txt").read_text().splitlines()
        ips = (AT / "frozen/ip_scripts.txt").read_text().splitlines()
        if len(rtl) != 139 or len(ips) != 8 or any("tb_v1.sv" in line for line in rtl):
            raise RuntimeError("source list changed or includes testbench")
        top = [Path(line) for line in rtl if line.endswith("/laya_ffn_representative_top_v1.sv")]
        if len(top) != 1 or sha(top[0]) != local["top_sha256"]:
            raise RuntimeError("top source identity changed")
        work = (AT / "work").resolve()
        work.mkdir(parents=True, exist_ok=True)
        if args.phase == "synth":
            command = [str(VIVADO), "-mode", "batch",
                "-log", str(AT / "vivado_synth.log"), "-journal", str(AT / "vivado_synth.jou"),
                "-source", str(AT / "frozen/run_m005_joint_synth_v1.tcl"),
                "-tclargs", str(work),
                str(AT / "frozen/rtl_sources.txt"), str(AT / "frozen/ip_scripts.txt"),
                str(source_path.parent.parent / "work")]
        else:
            checkpoint = work / "representative_synth.dcp"
            if not checkpoint.is_file():
                raise RuntimeError("synthesis checkpoint absent")
            synth_receipt = json.loads((AT / "synth_receipt.json").read_text())
            if sha(checkpoint) != synth_receipt["checkpoint_sha256"]:
                raise RuntimeError("synthesis checkpoint changed")
            command = [str(VIVADO), "-mode", "batch",
                "-log", str(AT / "vivado_route.log"), "-journal", str(AT / "vivado_route.jou"),
                "-source", str(AT / "frozen/run_m005_joint_route_v1.tcl"),
                "-tclargs", str(work), str(checkpoint)]
        result["status"] = "ACCEPT"
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        result["spawned"] = True
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        cmd = [sys.executable, str(GUARD), "--out", str(AT / f"guard_{args.phase}"),
               "--cwd", str(work), "--rss-gib", "24",
               "--timeout-seconds", "3300" if args.phase == "synth" else "3600", "--semantic-stall-seconds", "120",
               "--phase", "static", "--", *command]
        return subprocess.call(cmd)
    except Exception as exc:
        result["reason"] = str(exc)
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        print(f"M005_PHYSICAL_PREFLIGHT_REJECT {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
