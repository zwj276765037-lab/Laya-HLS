#!/usr/bin/env python3
"""Verify final strict-CPU evidence and bind reviewable preloaded inputs."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
from pathlib import Path


MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[2]
RUNS = MODULE / "runs"
OUT = MODULE / "source/final_cpu_binding_packet.json"
APPROVED_DESIGN = "1fedf1bc559f3abfbc1840824956ad5cb32a648e41d521cfa645b0924c695a8c"


def sha256(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            value.update(block)
    return value.hexdigest()


def artifact(path: Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": sha256(path)}


def guard(name: str) -> dict:
    directory = RUNS / name
    result = json.loads((directory / "guard_result.json").read_text())
    plan = json.loads((directory / "guard_plan.json").read_text())
    if (result["child_exit_code"] != 0 or result["trigger"] is not None or
        result["peak_owned_rss_kb"] > 8 * 1024 * 1024 or
        result["elapsed_seconds"] > 120 or
        result["minimum_mem_available_kb"] <= 192 * 1024 * 1024 or
        plan["maximum_owned_rss_kb"] != 8 * 1024 * 1024 or
        plan["maximum_seconds"] != 120 or
        plan["sample_seconds"] != 0.2 or
        len(plan["selected_cpu_ids"]) != 4):
        raise RuntimeError(f"strict guard failed: {name}")
    argv = plan["command"]
    if not (argv[0:4] == ["/usr/bin/nice", "-n", "19", "/usr/bin/ionice"] and
            argv[4:6] == ["-c", "3"] and
            argv[6:8] == ["/usr/bin/taskset", "-c"]):
        raise RuntimeError(f"CPU/I/O policy mismatch: {name}")
    return {"result": result,
            "files": {entry.name: artifact(entry) for entry in sorted(directory.iterdir())
                      if entry.is_file()}}


def main() -> None:
    build = json.loads((RUNS / "cpu_build/result.json").read_text())
    execute = json.loads((RUNS / "cpu_execute/result.json").read_text())
    if build["exit_code"] != 0 or execute["exit_code"] != 0:
        raise RuntimeError("native CPU build or execution failed")
    if build["inputs"] != execute["inputs"]:
        raise RuntimeError("build and execution source/input identity differs")
    if (build["linked_production_translation_units"] != 24 or
        execute["linked_production_translation_units"] != 24 or
        build["binary_after_sha256"] != execute["binary_before_sha256"] or
        execute["binary_after_sha256"] != execute["binary_before_sha256"]):
        raise RuntimeError("production closure or CPU binary identity differs")
    for name, metadata in execute["inputs"].items():
        path = Path(name)
        if path.stat().st_size != metadata["bytes"] or sha256(path) != metadata["sha256"]:
            raise RuntimeError(f"frozen CPU input changed: {name}")
    binary = RUNS / "attention_preloaded_cpu"
    if sha256(binary) != execute["binary_after_sha256"]:
        raise RuntimeError("compiled binary changed")
    current_design = (MODULE / "source/design.md").read_text()
    approved_text = current_design.split("## Implemented mapping, 2026-10-08")[0][:-1]
    if hashlib.sha256(approved_text.encode()).hexdigest() != APPROVED_DESIGN:
        raise RuntimeError("released Astra design preimage changed")
    fixture_log = (RUNS / "fixture_guard_v2/driver.log").read_text()
    cpu_log = (RUNS / "cpu_execute_guard_v5/driver.log").read_text()
    if "D2_PRELOADED_FIXTURE_PASS" not in fixture_log or (
        cpu_log.count("D2_PRELOADED_CASE_PASS") != 3 or
        cpu_log.count("D2_PRELOADED_NEGATIVE_PASS") != 17 or
        cpu_log.count("D2_ATTENTION_PRELOADED_CPU_PASS legal=3 negative=17") != 1):
        raise RuntimeError("strict fixture/CPU PASS markers missing")
    fixture_dir = MODULE / "tb/fixture_preloaded"
    fixture = json.loads((fixture_dir / "fixture_manifest.json").read_text())
    expected = (fixture_dir / "expected_hashes.txt").read_text()
    if len(fixture["cases"]) != 4 or len(fixture["gold"]) != 3 or (
        expected.count("CASE ") != 4 or expected.count("GOLD ") != 3):
        raise RuntimeError("independent fixture case count changed")
    extras = [MODULE / "source/results.md", MODULE / "source/freeze_preloaded_cpu.py",
              MODULE / "source/design_implementation_mapping.diff",
              ROOT / "results/attention_rtl_repair_20261008/repair_contract.md",
              ROOT / "results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_design_release.json",
              ROOT / "results/attention_rtl_repair_20261008/reviewer_d2_next_design_links_addendum.json"]
    packet = {
        "schema": "d2_attention_preloaded_source_cpu_binding_v1",
        "created_at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "scope": "implementation and strict CPU verification only",
        "approved_design_preimage_sha256": APPROVED_DESIGN,
        "current_design": artifact(MODULE / "source/design.md"),
        "production_build_tag": "fe067c8aa0627ad770096f9721394645",
        "production_translation_units_linked": 24,
        "controller_included_once": True,
        "compiled_binary": artifact(binary),
        "cpu_inputs": execute["inputs"],
        "extra_review_artifacts": {str(path): artifact(path) for path in extras},
        "generated_fixture_artifacts": {
            item.name: artifact(item) for item in sorted(fixture_dir.iterdir())
            if item.is_file()},
        "runner_records": {
            "build_input": artifact(RUNS / "cpu_build/input_manifest.json"),
            "build_result": artifact(RUNS / "cpu_build/result.json"),
            "execute_input": artifact(RUNS / "cpu_execute/input_manifest.json"),
            "execute_result": artifact(RUNS / "cpu_execute/result.json")},
        "guards": {
            "fixture": guard("fixture_guard_v2"),
            "build": guard("cpu_build_guard_v5"),
            "execute": guard("cpu_execute_guard_v5")},
        "verified_counts": {"legal": 3, "negative": 17,
                             "host_qkv_bytes_checked_per_image": 25165824},
        "gated_unexecuted": ["CSim", "local csynth", "generated RTL binding",
                             "numerical RTL runtime"],
    }
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print("D2_ATTENTION_PRELOADED_CPU_BINDING_PASS", sha256(OUT),
          len(packet["cpu_inputs"]), len(packet["generated_fixture_artifacts"]))


if __name__ == "__main__":
    main()
