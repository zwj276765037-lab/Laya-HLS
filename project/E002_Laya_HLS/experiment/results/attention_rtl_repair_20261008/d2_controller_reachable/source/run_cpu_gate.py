#!/usr/bin/env python3
"""Build or execute one frozen D2-I native CPU slice under an outer guard."""

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import subprocess
import sys


MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[2]
RUNS = MODULE / "runs"
PACKET = MODULE / "draft_v2_pre_review_packet.json"
SOURCE_LIST = MODULE / "source_list_manifest.json"
PACKAGE = ROOT / "build/model-attention-rtl-repair-20261008"
FIXTURE = MODULE / "tb/fixture_v2"


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", choices=("build", "execute"))
    parser.add_argument("slice", choices=("linear", "vector"))
    args = parser.parse_args()
    stage = RUNS / f"cpu_{args.slice}_{args.phase}"
    stage.mkdir(parents=True, exist_ok=True)
    packet = json.loads(PACKET.read_text())
    source_list = json.loads(SOURCE_LIST.read_text())
    if sha256(PACKET) != "a464fce0a41b2620884586574cceb371dc165f8eca149ec7b6bb6cae8861d0da":
        raise RuntimeError("reviewed v2 packet changed")
    if sha256(SOURCE_LIST) != packet["source_list_sha256"]:
        raise RuntimeError("production source closure changed")
    checked = {}
    for name, info in packet["artifacts"].items():
        path = Path(name)
        actual = sha256(path)
        expected = info["sha256"]
        if actual != expected:
            raise RuntimeError(f"frozen artifact changed: {path}")
        checked[name] = actual
    top = source_list["isolated_tops"][args.slice]
    for item in [source_list["included_controller"], *source_list["linked_production_sources"],
                 top["wrapper"], top["tb"], top["config"]]:
        path = Path(item["path"])
        if sha256(path) != item["sha256"]:
            raise RuntimeError(f"source list changed: {path}")
    binary = RUNS / f"cpu_{args.slice}"
    if args.phase == "build":
        command = ["/usr/bin/g++", "-std=c++17", "-O2", "-fno-fast-math",
                   "-ffp-contract=off", "-I" + str(ROOT / "include"),
                   "-I" + str(ROOT / "hls"),
                   "-I" + str(ROOT / "hls/platform"),
                   "-I" + str(PACKAGE), str(Path(top["wrapper"]["path"])),
                   *(item["path"] for item in source_list["linked_production_sources"]),
                   str(Path(top["tb"]["path"])), "-lm", "-o", str(binary)]
    else:
        if not binary.is_file():
            raise RuntimeError("native binary has not been built")
        command = [str(binary), str(PACKAGE), str(FIXTURE)]
    manifest = {
        "at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "phase": args.phase, "slice": args.slice,
        "cwd": str(ROOT), "argv": command,
        "review_packet": {"path": str(PACKET), "sha256": sha256(PACKET)},
        "source_list": {"path": str(SOURCE_LIST), "sha256": sha256(SOURCE_LIST)},
        "frozen_artifact_hashes_verified": checked,
    }
    if binary.is_file():
        manifest["binary_before_sha256"] = sha256(binary)
    save(stage / "input_manifest.json", manifest)
    print("CPU_GATE", args.phase, args.slice, "artifacts", len(checked), flush=True)
    result = subprocess.run(command, cwd=ROOT, check=False)
    manifest["exit_code"] = result.returncode
    if binary.is_file():
        manifest["binary_after_sha256"] = sha256(binary)
    save(stage / "result.json", manifest)
    print("CPU_GATE_RESULT", args.phase, args.slice, result.returncode, flush=True)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
