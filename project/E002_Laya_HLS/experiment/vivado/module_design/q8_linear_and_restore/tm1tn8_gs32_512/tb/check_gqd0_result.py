#!/usr/bin/env python3
"""Independently check the bounded GQD0 receipt, identity and raw markers."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def digest(path):
    path = Path(path)
    return path.stat().st_size, hashlib.sha256(path.read_bytes()).hexdigest()


def fields(line):
    return dict(re.findall(r"([A-Za-z][A-Za-z0-9_]*)=([^ ]+)", line))


def integer_fields(line):
    return {k: int(v) for k, v in fields(line).items() if re.fullmatch(r"-?\d+", v)}


def exactly(lines, prefix):
    matches = [line for line in lines if line.startswith(prefix)]
    if len(matches) != 1:
        raise RuntimeError(f"{prefix}: expected one marker, saw {len(matches)}")
    return matches[0]


def check(attempt):
    receipt = json.loads((attempt / "receipt.json").read_text())
    manifest = json.loads((attempt / "input_manifest.json").read_text())
    if receipt["status"] != "PASS_SCOPED_GQD0":
        raise RuntimeError("full attempt not PASS_SCOPED_GQD0")
    frozen = []
    for row in manifest["files"]:
        item = row["frozen"]
        if digest(item["path"]) != (item["bytes"], item["sha256"]):
            raise RuntimeError("frozen identity drift: " + item["path"])
        frozen.append(item["path"])
    phases = {}
    for mode in ("static", "pilot", "full"):
        phase = receipt["phases"][mode]
        guard = phase["guard"]
        if phase["status"] != "PASS" or guard["child_exit_code"] != 0 or guard["trigger"] is not None:
            raise RuntimeError(mode + " guard did not pass")
        phases[mode] = {
            "elapsed_seconds": guard["elapsed_seconds"],
            "peak_owned_rss_kb": guard["peak_owned_rss_kb"],
            "trigger": guard["trigger"],
        }
    raw = (attempt / "raw_full.log").read_text(errors="replace").splitlines()
    if any(line.startswith(("Fatal:", "ERROR:")) for line in raw):
        raise RuntimeError("simulation fatal/error")
    pilot = (attempt / "raw_pilot.log").read_text(errors="replace").splitlines()
    pf = integer_fields(exactly(pilot, "GQD0_PILOT_PASS "))
    if {k: pf[k] for k in ("real_Wi_words", "gate_AW", "gate_W", "gate_B")} != {
        "real_Wi_words": 5248, "gate_AW": 164, "gate_W": 164, "gate_B": 164
    }:
        raise RuntimeError("pilot is not true first GATE row")
    handoff = integer_fields(exactly(raw, "MATRIX_PROGRESS cycle=59403 GQD0_A_ready=1 "))
    if {k: handoff[k] for k in ("gate_AW", "gate_W", "gate_B", "gate_R", "quant_groups")} != {
        "gate_AW": 656, "gate_W": 656, "gate_B": 656, "gate_R": 656, "quant_groups": 328
    }:
        raise RuntimeError("GATE/quant handoff mismatch")
    bridge = integer_fields(exactly(raw, "GQD0_CHAIN_PASS "))
    if {k: bridge[k] for k in ("gate_W", "gate_R", "quant_groups",
                               "Down_A_reads", "Down_A_returns",
                               "Down_AW", "Down_W", "Down_B")} != {
        "gate_W": 656, "gate_R": 656, "quant_groups": 328,
        "Down_A_reads": 82, "Down_A_returns": 82,
        "Down_AW": 256, "Down_W": 256, "Down_B": 256
    }:
        raise RuntimeError("bridge final coverage mismatch")
    down = integer_fields(exactly(raw, "TM4_MATRIX_RESIDENT_FULL_PASS "))
    for key, value in {"rows": 4, "K": 2624, "N": 1024, "real_stripes": 10496,
                       "PS_lane_groups": 335872, "final_packets": 512,
                       "real_output_words": 4096, "A_fixture_prequantized": 0,
                       "actual_AW": 256, "actual_W": 256, "actual_B": 256}.items():
        if down[key] != value:
            raise RuntimeError(f"Down {key} mismatch")
    b = integer_fields(exactly(raw, "DOWN_MEASURE_BOUNDARIES "))
    st = integer_fields(exactly(raw, "DOWN_MEASURE_STATES "))
    out = integer_fields(exactly(raw, "DOWN_MEASURE_OUTPUT "))
    if b["cfg_accept"] != 86469 or b["first_done_valid"] != 102652 or (
        b["actual_done_consume"] != 102659 or b["finish"] != 102660
    ):
        raise RuntimeError("Down endpoint mismatch")
    if (sum(st["s" + str(k)] for k in range(13)) != st["cycles"] or
            st["cycles"] != b["first_done_valid"] - b["cfg_accept"]):
        raise RuntimeError("exclusive state accounting mismatch")
    if out["actual_done_consumes"] != 1 or out["useful_strobe_bytes"] != 16384 or (
        out["physical_W_bytes"] != 16384
    ):
        raise RuntimeError("Down physical/consume mismatch")
    if bridge["cycle"] != b["finish"]:
        raise RuntimeError("final cycle disagreement")
    # This inherited observer catches the rejected G admission at cycle 23.
    # The positive G acceptance is the explicit cycle-25 marker.
    accepted = integer_fields(exactly(raw, "MATRIX_PROGRESS cycle=25 GQD0_cfg_accepted=1"))
    assert accepted["cycle"] == 25 and b["A_fill_accept"] == 23
    return {
        "status": "PASS_SCOPED_GQD0",
        "scope": "normal four-row cold same-runtime G/quant/shared-dualA/KB1 Down",
        "frozen_file_count": len(frozen),
        "phases": phases,
        "pilot": pf,
        "bridge": bridge,
        "Down_boundaries": b,
        "Down_exclusive_states": st,
        "Down_output": out,
        "G_accepted_cycle": 25,
        "G_bridge_consumed_and_A_ready_by_cycle": handoff["cycle"],
        "chain_G_accept_to_Down_consume_cycles": b["actual_done_consume"] - 25,
        "whole_TB_cycles": b["finish"],
        "measurement_caveat": "A_fill_accept=23 is the intentional rejected G admission probe; positive G acceptance is cycle 25. A_publish_post_NBA=59403 is observed after G response consumption, not exact A-bank publication edge.",
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--attempt", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    obj = check(args.attempt.resolve())
    args.out.write_text(json.dumps(obj, indent=2) + "\n")
    print("GQD0_EVIDENCE_CHECK_PASS", obj["whole_TB_cycles"], flush=True)


if __name__ == "__main__":
    main()
