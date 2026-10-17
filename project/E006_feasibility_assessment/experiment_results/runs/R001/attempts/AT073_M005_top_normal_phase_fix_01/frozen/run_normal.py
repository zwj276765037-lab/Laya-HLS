#!/usr/bin/env python3
"""Preflight immutable top/fixture/snapshot identities before one guarded xsim."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

AT = Path(__file__).resolve().parent.parent
ROOT = AT.parents[6]
PARENT = Path(json.loads((AT / "input_manifest.json").read_text())["parent_attempt"])
GUARD = ROOT / "project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/ffn0_guard.py"


def sha(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def verify(path):
    obj = json.loads(path.read_text())
    for entry in obj["files"]:
        file = Path(entry["path"])
        if not file.is_file() or file.stat().st_size != entry["bytes"] or sha(file) != entry["sha256"]:
            raise RuntimeError(f"input mismatch: {file}")
    return len(obj["files"])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("phase", choices=("pilot", "full"))
    args = parser.parse_args()
    out = AT / f"preflight_{args.phase}.json"
    result = {"status": "REJECT", "spawned": False, "phase": args.phase}
    try:
        if (AT / f"guard_{args.phase}").exists():
            raise RuntimeError("guard directory already exists; no rerun")
        local = json.loads((AT / "input_manifest.json").read_text())
        if sha(PARENT / "input_manifest.json") != local["parent_manifest_sha256"]:
            raise RuntimeError("parent manifest changed")
        result["parent_files"] = verify(PARENT / "input_manifest.json")
        result["candidate_files"] = verify(AT / "input_manifest.json")
        original = json.loads((PARENT / f"guard_{args.phase}/guard_plan.json").read_text())["command"]
        raw = original[9:]
        if not raw[0].endswith("/xsim"):
            raise RuntimeError("unexpected original tool")
        raw[1] = "m005_ffn_top_normal3_behav"
        raw[raw.index("-tclbatch") + 1] = str(AT / f"frozen/{args.phase}_run.tcl")
        result["status"] = "ACCEPT"
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        cmd = [sys.executable, str(GUARD), "--out", str(AT / f"guard_{args.phase}"),
               "--cwd", str(AT / "work"), "--rss-gib", "8",
               "--timeout-seconds", "120" if args.phase == "pilot" else "3600",
               "--semantic-stall-seconds", "120", "--phase", args.phase, "--", *raw]
        result["spawned"] = True
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        return subprocess.call(cmd)
    except Exception as exc:
        result["reason"] = str(exc)
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        print(f"M005_TOP_PREFLIGHT_REJECT {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
