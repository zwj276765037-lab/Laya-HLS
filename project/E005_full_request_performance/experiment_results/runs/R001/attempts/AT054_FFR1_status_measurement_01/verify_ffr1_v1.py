#!/usr/bin/env python3
"""Read-only post-run identity, guard and scoped-result audit for AT054."""

import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
OLD = HERE.parent / "AT053_FFR0_four_row_02"
SLOT = HERE.parent / "AT052_FFR0_four_row_01"
PHASES = ("host", "static", "error", "pilot", "full")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text())


def main():
    manifest = read(HERE / "source_manifest.json")
    identities = []
    for group in ("frozen", "external"):
        for name, record in manifest[group].items():
            path = Path(record["path"])
            actual = {"path": str(path.resolve()), "bytes": path.stat().st_size,
                      "sha256": sha(path)}
            if actual != record:
                raise AssertionError((group, name, actual, record))
            identities.append({"group": group, "name": name,
                               "sha256": actual["sha256"]})
    inherited = {
        "slot_rtl": sha(HERE / "frozen/laya_ffn_fadd_slot_v1.sv") ==
            sha(OLD / "frozen/laya_ffn_fadd_slot_v1.sv"),
        "slot_tb": sha(HERE / "frozen/laya_ffn_fadd_slot_v1_tb.sv") ==
            sha(SLOT / "frozen/laya_ffn_fadd_slot_v1_tb.sv"),
        "leaf": manifest["external"]["leaf"]["sha256"] ==
            read(OLD / "source_manifest.json")["external"]["leaf"]["sha256"],
        "skip": manifest["external"]["skip"]["sha256"] ==
            read(OLD / "source_manifest.json")["external"]["skip"]["sha256"],
        "down": manifest["external"]["down"]["sha256"] ==
            read(OLD / "source_manifest.json")["external"]["down"]["sha256"],
        "gold": manifest["external"]["gold"]["sha256"] ==
            read(OLD / "source_manifest.json")["external"]["gold"]["sha256"],
    }
    if not all(inherited.values()):
        raise AssertionError(inherited)
    guards = {}
    previous_finish = None
    policy_total = 0
    for phase in PHASES:
        guard_dir = HERE / f"guard_{phase}"
        plan = read(guard_dir / "guard_plan.json")
        result = read(guard_dir / "guard_result.json")
        if result["child_exit_code"] != 0 or result["trigger"] is not None:
            raise AssertionError((phase, result))
        if result["elapsed_seconds"] > (1800 if phase == "static" else
                                         3600 if phase == "full" else 120):
            raise AssertionError((phase, "wall cap"))
        if phase != "host":
            if (result["peak_owned_rss_kb"] is None or
                result["peak_owned_rss_kb"] >=
                    (24 if phase == "static" else 8) * 1024 * 1024):
                raise AssertionError((phase, "rss cap"))
            policy = read(guard_dir / "policy_checks.json")
            if not policy or not all(item["matches"] for item in policy):
                raise AssertionError((phase, "policy"))
            policy_total += len(policy)
        else:
            policy = []
        if previous_finish is not None and plan["at"] < previous_finish:
            raise AssertionError((phase, "overlapping guards"))
        previous_finish = result["finished_at"]
        guards[phase] = {"elapsed_seconds": result["elapsed_seconds"],
                         "peak_owned_rss_kb": result["peak_owned_rss_kb"],
                         "rss_captured": result["rss_captured"],
                         "policy_samples": len(policy),
                         "simulation_started": result["simulation_started"],
                         "semantic_progress_accepts": result["semantic_progress_accepts"],
                         "semantic_progress_rejects": result["semantic_progress_rejects"]}
    host = read(HERE / "guard_host_test.json")
    if host["verdict"] != "PASS" or host["spawned"] or len(host["cases"]) != 4:
        raise AssertionError("host test")
    log = (HERE / "guard_full/driver.log").read_text(errors="replace")
    required = ("FFR1_STATIC_PASS", "FFR1_SIM_START", "FFR1_ERROR_PASS",
                "FFR1_NUMERICAL_REJECT_PASS status=6",
                "FFR1_AXI_REJECT_PASS kind=0 status=8",
                "FFR1_AXI_REJECT_PASS kind=1 status=8",
                "FFR1_AXI_REJECT_PASS kind=2 status=8",
                "FFR1_FOUR_ROW_PASS rows=4 words=4096 R=256+256 AW/W/B=256/256/256",
                "FFR1_ADD_LATENCY latency=22 count=4096",
                "FFR1_PHASE_SUM cfg_to_consume_inclusive=103289 sum=103289")
    if any(log.count(marker) != 1 for marker in required) or \
            "Fatal:" in log or "ERROR:" in log or "$finish called" not in log:
        raise AssertionError("required full markers or errors")
    phases = [int(x) for x in re.findall(r"FFR1_PHASE state=\d+ cycles=(\d+)", log)]
    if len(phases) != 11 or sum(phases) != 103289:
        raise AssertionError("phase sum")
    cost = read(HERE / "full_cost_decision.json")
    if cost["decision"] != "ADMIT_ONE_COLD_FULL" or \
            cost["conservative_full_wall_estimate_seconds"] >= 3600:
        raise AssertionError("cost gate")
    output = {"schema": "FFR1_AT054_verification_v1", "status": "PASS_SCOPED",
              "identity_count": len(identities), "identities": identities,
              "inherited_unchanged": inherited, "guards": guards,
              "actual_policy_samples": policy_total,
              "host_policy_observation": "UNKNOWN: task ended before RSS/policy sample",
              "full_markers_checked": list(required),
              "normal_phase_cycles": phases,
              "normal_phase_sum": sum(phases),
              "cost_decision": str(HERE / "full_cost_decision.json")}
    (HERE / "verification.json").write_text(json.dumps(output, indent=2) + "\n")
    print(json.dumps({"verdict": output["status"],
                      "identities": len(identities), "policy": policy_total}))


if __name__ == "__main__":
    main()
