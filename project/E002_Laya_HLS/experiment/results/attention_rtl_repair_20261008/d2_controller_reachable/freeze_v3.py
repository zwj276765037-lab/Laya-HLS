#!/usr/bin/env python3
"""Freeze the one-line I-V physical read fix without rewriting v2 evidence."""

import difflib
import hashlib
import json
from pathlib import Path
import shutil


MODULE = Path(__file__).resolve().parent
ROOT = MODULE.parents[2]
V2 = MODULE / "draft_snapshots/v2_after_review_fixes"
V3 = MODULE / "draft_snapshots/v3_vector_physical_read"
PACKET_V2 = MODULE / "draft_v2_pre_review_packet.json"
REVIEW_V2 = MODULE.parent / "reviewer_d2_i_draft_v2_gate.json"
TB = MODULE / "tb/test_vector_controller_slice.cpp"
LISTING = MODULE / "source_list_manifest.json"
MAPPING = ROOT / "hls/common/laya_memory_map.cpp"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def info(path):
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": sha(path)}


def main():
    old = json.loads(PACKET_V2.read_text())
    review = json.loads(REVIEW_V2.read_text())
    listing = json.loads(LISTING.read_text())
    if sha(PACKET_V2) != review["packet_sha256"]:
        raise RuntimeError("v2 reviewer packet mismatch")
    if review["decision"] != "ACCEPT_D2_I_V2_FOR_ORDERED_CPU_CSIM_THEN_LOCAL_CSYNTH_IR":
        raise RuntimeError("v2 technical gate mismatch")
    previous = (V2 / "tb/test_vector_controller_slice.cpp").read_text()
    current = TB.read_text()
    old_line = "  if (mode == 3) output += 16777216u + 141504u;"
    new_line = "  if (mode == 3) output += 16777216u + 141376u;"
    if previous.count(old_line) != 1 or current != previous.replace(old_line, new_line):
        raise RuntimeError("the TB change is not exactly the physical read offset")
    if "141376" not in MAPPING.read_text():
        raise RuntimeError("production CAND_MASKED mapping not found")
    if listing["isolated_tops"]["vector"]["tb"]["sha256"] != sha(TB):
        raise RuntimeError("source list does not bind corrected vector TB")
    if listing["included_controller"]["sha256"] != sha(Path(listing["included_controller"]["path"])):
        raise RuntimeError("controller source changed")
    changed = {str(TB.resolve()), str(LISTING.resolve())}
    artifacts = {}
    for name, previous_info in old["artifacts"].items():
        path = Path(name)
        if name not in changed and sha(path) != previous_info["sha256"]:
            raise RuntimeError(f"frozen v2 artifact changed: {path}")
        artifacts[name] = info(path)
    for name in changed:
        if artifacts[name]["sha256"] == old["artifacts"][name]["sha256"]:
            raise RuntimeError("expected modified artifact did not change")
    V3.mkdir(parents=True, exist_ok=True)
    snapshot_tb = V3 / "test_vector_controller_slice.cpp"
    snapshot_listing = V3 / "source_list_manifest.json"
    shutil.copyfile(TB, snapshot_tb)
    shutil.copyfile(LISTING, snapshot_listing)
    diff = V3 / "v2_to_v3.diff"
    diff.write_text("".join(difflib.unified_diff(
        previous.splitlines(keepends=True), current.splitlines(keepends=True),
        fromfile="v2/tb/test_vector_controller_slice.cpp",
        tofile="v3/tb/test_vector_controller_slice.cpp")))
    evidence = [
        MODULE / "runs/cpu_linear_execute_guard/guard_result.json",
        MODULE / "runs/cpu_linear_execute_guard/driver.log",
        MODULE / "runs/cpu_vector_execute_guard/guard_result.json",
        MODULE / "runs/cpu_vector_execute_guard/driver.log",
        MODULE / "runs/debug_vector_execute_guard/guard_result.json",
        MODULE / "runs/debug_vector_execute_guard/driver.log",
        MODULE / "runs/debug_vector_correct_execute_guard/guard_result.json",
        MODULE / "runs/debug_vector_correct_execute_guard/driver.log",
        MODULE / "runs/debug_vector_command.json",
        MODULE / "runs/debug_vector_correct_command.json",
        MODULE / "runs/debug_vector_first_mismatch.cpp",
        MODULE / "runs/debug_vector_correct_offset.cpp",
        MODULE / "runs/vector_first_mismatch.actual.bin",
    ]
    for path in [PACKET_V2, REVIEW_V2, MAPPING, Path(__file__), snapshot_tb,
                 snapshot_listing, diff, *evidence]:
        artifacts[str(path.resolve())] = info(path)
    packet = {
        "status": "V3_VECTOR_TB_PHYSICAL_READ_FIX_PRE_CPU",
        "previous_v2_packet": info(PACKET_V2),
        "previous_v2_gate": info(REVIEW_V2),
        "source_list_sha256": sha(LISTING),
        "controller_sha256": listing["included_controller"]["sha256"],
        "changed_current_artifacts": sorted(changed),
        "change_diff": info(diff),
        "physical_address": {
            "buffer": "HEAD_WORK", "region": "CAND_MASKED", "bank": "STATE1",
            "state1_region_base": 16777216, "region_offset": 141376,
            "previous_wrong_region": "ACT_LOGITS", "previous_wrong_offset": 141504,
            "production_mapping": info(MAPPING)},
        "prior_cpu": {
            "linear": "PASS", "vector_v2": "FAIL_LAST_UNARY_PHYSICAL_READ",
            "isolated_debug_corrected_read": "PASS_ALL_FIVE_CASES"},
        "artifacts": artifacts,
        "not_run_v3": ["CPU gate", "Vitis CSim", "local csynth", "IR audit", "RTL simulation"],
    }
    output = MODULE / "draft_v3_pre_cpu_packet.json"
    output.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    shutil.copyfile(output, V3 / output.name)
    print(output, sha(output), "artifacts", len(artifacts))


if __name__ == "__main__":
    main()
