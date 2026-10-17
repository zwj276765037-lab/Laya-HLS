#!/usr/bin/env python3
"""Read-only, streamed closure check for the inherited Head15 source packet."""
from __future__ import annotations

import csv
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
V2 = ROOT.parent / "rtl_static_finite_monitor_v2"
TASK = ROOT.parents[2]
PRIOR = V2 / "source/source_packet.json"
RELEASE = TASK / "reviewer_attention_v5_head15_monitor_v3_explicit_record_port_source_preparation_release.json"
OUT = HERE / "frozen_rehash.json"
FAILURE = HERE / "frozen_rehash_failure.json"
TIMELINE = HERE / "frozen_rehash_timeline.csv"
MIN_MEM_KIB = 192 * 1024 * 1024


def mem_available_kib() -> int:
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1])
    raise RuntimeError("MemAvailable missing")


def own_rss_kib() -> int:
    for line in Path("/proc/self/status").read_text().splitlines():
        if line.startswith("VmRSS:"):
            return int(line.split()[1])
    raise RuntimeError("VmRSS missing")


def records(value):
    if isinstance(value, dict):
        if {"path", "sha256", "bytes"} <= value.keys():
            yield value
        for child in value.values():
            yield from records(child)
    elif isinstance(value, list):
        for child in value:
            yield from records(child)


def main() -> None:
    if any(path.exists() for path in (OUT, FAILURE, TIMELINE)):
        raise FileExistsError("fresh frozen rehash outputs required")
    started = time.monotonic()
    last_sample = started - 1
    samples = []
    first_failure = None
    completed = 0
    total_bytes = 0

    def sample(force=False):
        nonlocal last_sample
        now = time.monotonic()
        if force or now - last_sample >= 0.2:
            mem = mem_available_kib()
            rss = own_rss_kib()
            samples.append((round(now - started, 6), mem, rss, completed))
            last_sample = now
            if mem <= MIN_MEM_KIB:
                raise RuntimeError(f"MemAvailable {mem} KiB is not above {MIN_MEM_KIB} KiB")

    try:
        affinity = sorted(os.sched_getaffinity(0))
        nice = os.getpriority(os.PRIO_PROCESS, 0)
        ionice = subprocess.run(["/usr/bin/ionice", "-p", str(os.getpid())],
                                check=True, capture_output=True, text=True).stdout.strip()
        if affinity != [3] or nice != 19 or ionice != "idle":
            raise RuntimeError(f"wrong execution policy: {affinity}, nice={nice}, ionice={ionice}")
        prior_bytes = PRIOR.read_bytes()
        release_bytes = RELEASE.read_bytes()
        prior = json.loads(prior_bytes)
        release = json.loads(release_bytes)
        if (hashlib.sha256(prior_bytes).hexdigest() != release["v2_source_packet"]["sha256"] or
                release["status"] != "SOURCE_ONLY_NO_COMPILER_OR_SIMULATOR"):
            raise RuntimeError("release or inherited packet identity changed")
        unique = {}
        for item in list(records(prior)) + list(records(release)):
            path = item["path"]
            if path in unique:
                if (item["bytes"], item["sha256"]) != (unique[path]["bytes"], unique[path]["sha256"]):
                    raise RuntimeError(f"conflicting frozen record: {path}")
            else:
                unique[path] = item
        sample(force=True)
        for path_name, expected in sorted(unique.items()):
            path = Path(path_name)
            if not path.is_file():
                raise RuntimeError(f"missing frozen file: {path}")
            stat = path.stat()
            if stat.st_size != expected["bytes"]:
                raise RuntimeError(f"frozen byte count changed: {path}")
            if "mode" in expected and oct(stat.st_mode & 0o777) != expected["mode"]:
                raise RuntimeError(f"frozen mode changed: {path}")
            digest = hashlib.sha256()
            with path.open("rb") as stream:
                for block in iter(lambda: stream.read(1 << 20), b""):
                    digest.update(block)
                    total_bytes += len(block)
                    sample()
            if digest.hexdigest() != expected["sha256"]:
                raise RuntimeError(f"frozen SHA-256 changed: {path}")
            completed += 1
            sample()
        sample(force=True)
        checked = subprocess.run([sys.executable, str(HERE / "check_source_only.py")],
                                 cwd=ROOT, capture_output=True, text=True)
        print(checked.stdout, end="")
        if checked.returncode != 0:
            raise RuntimeError(f"source static check failed: {checked.stderr.strip()}")
        static_audit = HERE / "source_static_audit.json"
        result = {
            "schema": "head15_monitor_v3_streamed_frozen_rehash_v1",
            "status": "FROZEN_DEPENDENCIES_EXACT_SOURCE_ONLY",
            "at_utc": datetime.now(timezone.utc).isoformat(),
            "argv": sys.argv,
            "cwd": str(Path.cwd()),
            "pid": os.getpid(),
            "affinity": affinity,
            "nice": nice,
            "ionice": ionice,
            "prior_source_packet_sha256": hashlib.sha256(prior_bytes).hexdigest(),
            "release_sha256": hashlib.sha256(release_bytes).hexdigest(),
            "source_static_audit_sha256": hashlib.sha256(static_audit.read_bytes()).hexdigest(),
            "frozen_record_occurrences": len(list(records(prior))) + len(list(records(release))),
            "unique_files_exact": completed,
            "total_bytes_streamed": total_bytes,
            "sample_seconds": 0.2,
            "samples": len(samples),
            "minimum_mem_available_kib": min(row[1] for row in samples),
            "peak_owned_rss_kib": max(row[2] for row in samples),
            "elapsed_seconds": time.monotonic() - started,
        }
        OUT.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
        print(f"HEAD15_V3_FROZEN_REHASH_PASS files={completed} bytes={total_bytes}")
    except Exception as exc:
        first_failure = {"schema": "head15_monitor_v3_frozen_rehash_first_failure_v1",
                         "at_utc": datetime.now(timezone.utc).isoformat(),
                         "completed_files": completed, "bytes_streamed": total_bytes,
                         "error": repr(exc)}
        FAILURE.write_text(json.dumps(first_failure, indent=2, sort_keys=True) + "\n")
        raise
    finally:
        with TIMELINE.open("w", newline="") as stream:
            writer = csv.writer(stream)
            writer.writerow(("elapsed_seconds", "mem_available_kib", "owned_rss_kib", "completed_files"))
            writer.writerows(samples)


if __name__ == "__main__":
    main()
