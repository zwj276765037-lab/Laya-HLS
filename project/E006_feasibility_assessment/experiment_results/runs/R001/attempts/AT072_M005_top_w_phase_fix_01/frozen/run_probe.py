#!/usr/bin/env python3
"""Verify AT070 closure plus AT071 probe snapshot, then run one bounded W probe."""
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
    out = AT / "preflight_probe.json"
    result = {"status": "REJECT", "spawned": False}
    try:
        local = json.loads((AT / "input_manifest.json").read_text())
        if sha(PARENT / "input_manifest.json") != local["parent_manifest_sha256"]:
            raise RuntimeError("parent manifest changed")
        result["parent_files"] = verify(PARENT / "input_manifest.json")
        result["probe_files"] = verify(AT / "input_manifest.json")
        original = json.loads((PARENT / "guard_pilot/guard_plan.json").read_text())["command"]
        raw = original[9:]
        if raw[0].endswith("/xsim") is False:
            raise RuntimeError("unexpected original tool")
        raw[1] = "m005_ffn_top_w_probe2_behav"
        i = raw.index("-testplusarg")
        while i < len(raw):
            if raw[i] == "-testplusarg" and raw[i+1] == "PREFIX=1":
                del raw[i:i+2]
                break
            i += 1
        raw[raw.index("-tclbatch") + 1] = str(AT / "frozen/probe_run.tcl")
        raw[raw.index("-tclbatch"):raw.index("-tclbatch")] = ["-testplusarg", "W_PROBE=1"]
        result["status"] = "ACCEPT"
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        cmd = [sys.executable, str(GUARD), "--out", str(AT / "guard_probe"),
               "--cwd", str(AT / "work"), "--rss-gib", "8",
               "--timeout-seconds", "120", "--semantic-stall-seconds", "120",
               "--phase", "pilot", "--", *raw]
        result["spawned"] = True
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        return subprocess.call(cmd)
    except Exception as exc:
        result["reason"] = str(exc)
        out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        print(f"M005_W_PROBE_PREFLIGHT_REJECT {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
