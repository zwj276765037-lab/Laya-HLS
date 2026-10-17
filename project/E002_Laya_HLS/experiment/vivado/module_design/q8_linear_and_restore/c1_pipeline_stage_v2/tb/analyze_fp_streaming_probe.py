#!/usr/bin/env python3
"""Dormant raw-log audit for the actual v3 wrapper streaming probe.

This script never runs during source preparation. It finds a common observed
enabled-edge latency across burst, bubble, and reverse-order/reset phases.
Wrapper r_tvalid is recorded but not interpreted as semantic acceptance.
"""
import argparse
import json
from pathlib import Path

NAMES = ("fdiv", "fmul2", "fmul3", "fadd", "sitofp", "fcmp1", "fcmp2")


def fields(line):
    parts = line.rstrip().split("|")
    if not parts or parts[0] != "FP_STREAM":
        return None
    return dict(part.split("=", 1) for part in parts[1:])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("raw_log", type=Path)
    parser.add_argument("output_json", type=Path)
    args = parser.parse_args()
    if args.output_json.exists():
        parser.error("fresh output_json required")
    lines = args.raw_log.read_text().splitlines()
    if not lines or lines[-1] != "FP_STREAM_SOURCE_COMPLETE":
        raise SystemExit("raw log incomplete")
    groups = {(w, phase): [] for w in range(7) for phase in range(3)}
    for line in lines[:-1]:
        record = fields(line)
        if record is None:
            raise SystemExit("unexpected raw record")
        w, phase = int(record["wrapper"]), int(record["phase"])
        if (w, phase) not in groups:
            raise SystemExit("unknown wrapper or phase")
        groups[w, phase].append(record)
    result = {"schema": "c1_fp_streaming_observation_v1", "wrappers": {},
              "fixed_latency_acceptance": False}
    valid = True
    for w, name in enumerate(NAMES):
        candidate_sets = []
        run_details = []
        for phase in range(3):
            rows = groups[w, phase]
            if not rows:
                raise SystemExit(f"{name}/{phase}: no samples")
            accepts = [r for r in rows if r["accept"] == "1"]
            if not accepts:
                raise SystemExit(f"{name}/{phase}: no accepts")
            expected_ordinals = [int(r["enabled"]) for r in accepts]
            if any(b != a + 1 for a, b in
                   zip(expected_ordinals, expected_ordinals[1:])):
                raise SystemExit(f"{name}/{phase}: nonconsecutive enabled accepts")
            sampled = {int(r["enabled"]): r["actual"].lower()
                       for r in rows if r["ce"] == "1"}
            candidates = []
            for latency in range(33):
                if all(sampled.get(int(token["enabled"]) + latency) ==
                       token["expected"].lower() for token in accepts):
                    candidates.append(latency)
            candidate_sets.append(set(candidates))
            holds = []
            previous = None
            for row in rows:
                if row["ce"] == "0" and previous is not None:
                    holds.append(row["actual"].lower() == previous)
                previous = row["actual"].lower()
            run_details.append({
                "phase": phase, "accepts": len(accepts),
                "candidate_enabled_edge_latencies": candidates,
                "ce_zero_samples": len(holds),
                "ce_zero_output_holds": sum(holds),
                "first_accept_clock": int(accepts[0]["clock"]),
                "last_accept_clock": int(accepts[-1]["clock"]),
                "last_sample_clock": int(rows[-1]["clock"]),
                "r_tvalid_levels": sorted({r["r_tvalid"] for r in rows}),
            })
        common = sorted(set.intersection(*candidate_sets))
        # The combinational comparator has no CE pin, so its bubble phase
        # drives CE high throughout. All other phases exercise genuine CE.
        accepted = len(common) == 1
        valid &= accepted
        result["wrappers"][name] = {
            "common_observed_latency_enabled_edges": common,
            "back_to_back_ii1_observed": accepted,
            "runs": run_details,
            "status": "UNIQUE_OBSERVED" if accepted else "UNRESOLVED",
        }
    result["fixed_latency_acceptance"] = bool(valid)
    args.output_json.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    if not valid:
        raise SystemExit("streaming latency/II unresolved; preserve raw log")
    print("C1_FP_STREAMING_OBSERVATION_COMPLETE")


if __name__ == "__main__":
    main()
