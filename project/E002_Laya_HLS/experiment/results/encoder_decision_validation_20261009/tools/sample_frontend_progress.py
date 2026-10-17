#!/usr/bin/env python3
"""Record phase-specific RTL progress at bounded intervals during a guarded run."""

from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sys
import time

attempt = Path(sys.argv[1]).resolve()
plan = json.loads((attempt / "guard/guard_plan.json").read_text())
start = datetime.fromisoformat(plan["at"])
samples = attempt / "phase_progress.jsonl"
progress_re = re.compile(r"([a-z][a-z_0-9]*)=(\d+)")

while True:
    now = datetime.now(timezone.utc)
    previous = None
    if samples.exists() and samples.stat().st_size:
        previous = datetime.fromisoformat(
            json.loads(samples.read_text().splitlines()[-1])["utc"])
    if previous is None or (now - previous).total_seconds() >= 55:
        lines = (attempt / "guard/driver.log").read_text(
            errors="replace").splitlines()
        latest = next((line for line in reversed(lines)
                       if line.startswith("FRONTEND_PROGRESS ")), None)
        if latest:
            values = {key: int(value) for key, value in progress_re.findall(latest)}
            phase = ("LN_EMB" if values["norm"] or values["state0_reads"]
                     else "LOAD_LN_PARAMS" if values["gamma_reads"]
                     else "EMB_TOKEN")
            entry = {"utc": now.isoformat(),
                     "elapsed_seconds": (now - start).total_seconds(),
                     "phase": phase, "progress": values}
            with samples.open("a") as stream:
                stream.write(json.dumps(entry, sort_keys=True) + "\n")
            print(json.dumps(entry), flush=True)
    if (attempt / "guard/guard_result.json").is_file():
        break
    time.sleep(5)
