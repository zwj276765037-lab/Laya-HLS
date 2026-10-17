#!/usr/bin/env python3
"""Freeze the copied Attention v10 closure for a passive ATN0 measurement."""

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path


PROJECT = Path(__file__).resolve().parents[4]
OLD_ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")
BASE = PROJECT / "results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01"
FIXTURE = PROJECT / "results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture"
OBSERVATION_TB = Path(__file__).with_name("attention_tile_measure_tb.sv")
OBSERVATION_RUNNER = Path(__file__).with_name("attention_tile_measure_run.py")


def record(path):
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def mapped(old_path):
    old_path = Path(old_path)
    return PROJECT / old_path.relative_to(OLD_ROOT)


def match(path, historical):
    actual = record(path)
    if (actual["bytes"], actual["sha256"]) != (historical["bytes"], historical["sha256"]):
        raise RuntimeError(f"Copied project input differs from v10 freeze: {path}")
    return actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("attempt", type=Path)
    parser.add_argument("--dut", type=Path, help="one same-resource ATN1 DUT candidate")
    parser.add_argument("--state-generator", type=Path, help="CE/reset snapshot generator for the candidate")
    args = parser.parse_args()
    if bool(args.dut) != bool(args.state_generator):
        parser.error("--dut and --state-generator must be supplied together")
    attempt = args.attempt.resolve()
    original = BASE / "source_manifest_v10.json"
    frozen = json.loads(original.read_text())
    if record(original)["sha256"] != "34145bda45ba482150a8be37876288771e01b3952bbb5de6ba892340d5f8b0b2":
        raise RuntimeError("The selected v10 manifest changed")
    if len(frozen["sources"]) != 93:
        raise RuntimeError("Expected the complete 93-file v10 closure")

    sources = []
    for item in frozen["sources"]:
        project_copy = mapped(item["frozen"]["path"])
        match(project_copy, item["frozen"])
        sources.append((item, project_copy, project_copy.relative_to(BASE)))

    fixture_manifest = json.loads((FIXTURE / "manifest.json").read_text())
    match(FIXTURE / "manifest.json", frozen["fixture_manifest"])
    for product in fixture_manifest["products"].values():
        match(mapped(product["path"]), product)
    for name, prior in frozen["trace"].items():
        match(BASE / "trace" / name, prior)

    attempt.mkdir(parents=True, exist_ok=False)
    adapted = []
    for item, project_copy, relative in sources:
        destination = attempt / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(project_copy, destination)
        adapted.append({"source": record(project_copy), "frozen": record(destination),
                        "historical_frozen": item["frozen"]})
    tb_destination = attempt / "frozen_source/attention_tile_tb.sv"
    runner_destination = attempt / "frozen_source/attention_tile_run.py"
    shutil.copy2(OBSERVATION_TB, tb_destination)
    shutil.copy2(OBSERVATION_RUNNER, runner_destination)
    changes = ["frozen_source/attention_tile_tb.sv: passive counters",
               "frozen_source/attention_tile_run.py: require measurement terminal marker"]
    if args.dut:
        candidate = args.dut.resolve()
        state_generator = args.state_generator.resolve()
        if not candidate.is_relative_to(PROJECT) or not state_generator.is_relative_to(PROJECT):
            raise RuntimeError("Candidate implementation must remain in E002/experiment")
        shutil.copy2(candidate, attempt / "frozen_source/attention_tile_service_v1.sv")
        shutil.copy2(state_generator, attempt / "frozen_source/attention_tile_state.py")
        subprocess.run([sys.executable, str(attempt / "frozen_source/attention_tile_state.py"), str(attempt)], check=True)
        changes += ["frozen_source/attention_tile_service_v1.sv: one ASUB prefetch batch",
                    "frozen_source/attention_tile_state.py and .svh: capture added private state"]
    for item in adapted:
        destination = Path(item["frozen"]["path"])
        if destination in (tb_destination, runner_destination) or args.dut and destination in (
                attempt / "frozen_source/attention_tile_service_v1.sv",
                attempt / "frozen_source/attention_tile_state.py",
                attempt / "frozen_source/attention_tile_state.svh"):
            item["frozen"] = record(destination)
            item["observation_only"] = destination in (tb_destination, runner_destination)
    shutil.copytree(BASE / "trace", attempt / "trace")
    for name, prior in frozen["trace"].items():
        match(attempt / "trace" / name, prior)
    manifest = {
        "schema": "attention-tile-atn0-measurement-v1",
        "historical_v10_manifest": record(original),
        "fixture": str(FIXTURE),
        "fixture_manifest": record(FIXTURE / "manifest.json"),
        "sources": adapted,
        "trace": {name: record(attempt / "trace" / name) for name in frozen["trace"]},
        "changes": changes,
    }
    if args.dut:
        manifest["candidate_dut"] = record(candidate)
        manifest["candidate_state_generator"] = record(state_generator)
        manifest["candidate_state_manifest"] = record(attempt / "state_manifest.json")
    (attempt / "source_manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print("ATTENTION_ATN0_PREPARE_PASS", attempt, flush=True)


if __name__ == "__main__":
    main()
