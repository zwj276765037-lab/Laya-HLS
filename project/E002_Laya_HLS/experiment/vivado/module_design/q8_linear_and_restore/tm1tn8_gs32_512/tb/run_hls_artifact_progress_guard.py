#!/usr/bin/env python3
"""Freeze and verify monotonic artifact progress used by the HLS guard."""

import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[5]
GUARD = ROOT / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py"
HELPER = ROOT / "tools/hls_guard_helpers.py"


def record(path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--attempt", type=Path, required=True)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    attempt.mkdir(exist_ok=False)
    frozen = attempt / "frozen"
    frozen_guard = frozen / GUARD.relative_to(ROOT)
    frozen_helper = frozen / HELPER.relative_to(ROOT)
    frozen_runner = frozen / Path(__file__).resolve().relative_to(ROOT)
    for source, target in ((GUARD, frozen_guard), (HELPER, frozen_helper),
                           (Path(__file__).resolve(), frozen_runner)):
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)

    launcher = {
        "pid": os.getpid(),
        "cpu_affinity": sorted(os.sched_getaffinity(0)),
        "nice": os.getpriority(os.PRIO_PROCESS, 0),
        "ionice": subprocess.run(["ionice", "-p", str(os.getpid())], check=True,
                                  capture_output=True, text=True).stdout.strip(),
    }
    (attempt / "launcher.json").write_text(json.dumps(launcher, indent=2) + "\n")
    if launcher["cpu_affinity"] != [0, 1, 2, 3] or launcher["nice"] != 19 or \
            not launcher["ionice"].startswith("idle"):
        raise RuntimeError("launcher policy mismatch")

    spec = importlib.util.spec_from_file_location("frozen_production_guard", frozen_guard)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    work = attempt / "work"
    work.mkdir()
    observations = []
    highwater = None

    def observe(label):
        nonlocal highwater
        value = module.artifact_progress_work(work)
        advanced, highwater = module.artifact_progress_advances(value, highwater)
        observations.append({"label": label, "work": list(value),
                             "advanced": advanced, "highwater": list(highwater)})
        return advanced

    if observe("empty"):
        raise AssertionError("empty tree advanced")
    artifact = work / "a.bin"
    artifact.write_bytes(b"a" * 100)
    if not observe("first_file"):
        raise AssertionError("first file did not advance")
    if observe("unchanged_1") or observe("unchanged_2"):
        raise AssertionError("unchanged work advanced")
    artifact.write_bytes(b"a" * 50)
    if observe("shrink"):
        raise AssertionError("shrinking artifact advanced")
    artifact.write_bytes(b"a" * 150)
    if not observe("growth"):
        raise AssertionError("artifact growth did not advance")
    (work / "b.bin").write_bytes(b"b" * 10)
    if not observe("new_file"):
        raise AssertionError("new file did not advance")

    files = []
    for original, copied in ((GUARD, frozen_guard), (HELPER, frozen_helper),
                             (Path(__file__).resolve(), frozen_runner)):
        files.append({"original": record(original), "frozen": record(copied)})
    manifest = {
        "schema": "laya-hls-artifact-progress-guard-input-v1",
        "scope": "Pure bounded classification of monotonic HLS work-directory progress; no HLS tool, RTL, numerical payload, or hardware claim",
        "files": files,
        "launcher": record(attempt / "launcher.json"),
    }
    (attempt / "input_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    marker = ("FULL_CURRENT_HLS_ARTIFACT_PROGRESS_GUARD_PASS "
              "unchanged_rejected=2 growth_accepted=2 new_file_accepted=1 "
              "shrink_rejected=1")
    (attempt / "driver.log").write_text(marker + "\n")
    receipt = {
        "schema": "laya-hls-artifact-progress-guard-receipt-v1",
        "status": "PASS",
        "scope": manifest["scope"],
        "observations": observations,
        "marker": [marker],
        "launcher": record(attempt / "launcher.json"),
        "input_manifest": record(attempt / "input_manifest.json"),
        "driver_log": record(attempt / "driver.log"),
    }
    (attempt / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(marker)
    return 0


if __name__ == "__main__":
    sys.exit(main())
