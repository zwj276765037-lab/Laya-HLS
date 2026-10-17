#!/usr/bin/env python3
"""Verify task-local priority controls before executing the HLS runner."""

import json
import os
from pathlib import Path
import subprocess
import sys


out = Path(__file__).resolve().parent
expected = [int(value) for value in os.environ["LAYA_GUARD_CPU_IDS"].split(",")]
observed = {
    "pid": os.getpid(),
    "pgid": os.getpgid(0),
    "sid": os.getsid(0),
    "nice": os.getpriority(os.PRIO_PROCESS, 0),
    "affinity": sorted(os.sched_getaffinity(0)),
}
ionice = subprocess.run(["/usr/bin/ionice", "-p", str(os.getpid())],
                        capture_output=True, text=True, timeout=5)
observed["ionice"] = (ionice.stdout or ionice.stderr).strip()
observed["ionice_exit"] = ionice.returncode
observed["policy_pass"] = (
    observed["nice"] == 19 and observed["affinity"] == expected and
    ionice.returncode == 0 and "idle" in observed["ionice"].lower())
(out / "preexec_policy.json").write_text(json.dumps(observed, indent=2) + "\n")
if not observed["policy_pass"]:
    sys.exit(86)
os.execv(sys.argv[1], sys.argv[1:])
