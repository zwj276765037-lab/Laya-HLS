#!/usr/bin/env python3
"""Finite FFN0 watchdog counterexamples; no simulator is spawned."""
import json
from pathlib import Path
import sys

from ffn0_guard import progress_decision, sim_start_decision


def run():
    started, first, duplicate = sim_start_decision(False, "FFN0_SIM_START")
    assert (started, first, duplicate) == (True, True, False)
    started, first, duplicate = sim_start_decision(started, "FFN0_SIM_START")
    assert (started, first, duplicate) == (True, False, True)
    previous, advanced, regressed = progress_decision(None, "FFN0_PROGRESS work=4")
    assert previous == (4,) and advanced and not regressed
    previous, advanced, regressed = progress_decision(previous, "FFN0_PROGRESS work=4")
    assert previous == (4,) and not advanced and not regressed
    previous, advanced, regressed = progress_decision(previous, "cycle=20000 heartbeat")
    assert previous == (4,) and not advanced and not regressed
    previous, advanced, regressed = progress_decision(previous, "FFN0_PROGRESS work=3")
    assert previous == (4,) and not advanced and regressed
    previous, advanced, regressed = progress_decision(previous, "FFN0_PROGRESS work=5")
    assert previous == (5,) and advanced and not regressed
    return {"verdict": "PASS", "cases": 6, "simulator_spawned": False}


if __name__ == "__main__":
    result = run()
    if len(sys.argv) == 3 and sys.argv[1] == "--out":
        Path(sys.argv[2]).write_text(json.dumps(result, indent=2) + "\n")
    print("FFN0_GUARD_HOST_PASS cases=6")
