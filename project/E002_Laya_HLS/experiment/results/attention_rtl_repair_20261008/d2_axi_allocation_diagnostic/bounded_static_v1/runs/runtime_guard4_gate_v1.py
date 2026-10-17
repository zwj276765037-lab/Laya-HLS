#!/usr/bin/env python3
"""Run one released AXI unit mode and preserve its frozen-input audit."""

import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


RELEASE = Path(__file__).resolve().parents[3] / "reviewer_axi_bounded_static_v1_guard4_runtime_release.json"
RELEASE_SHA256 = "ee63dcebbf93110a99c11360879afad29a9cecffe1ea922e8ae8655693d86574"


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def describe(path):
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": digest(path)}


def utc():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def records(release):
    refs = [release[k] for k in ("prior_release", "source_packet", "static_evidence",
                                 "parser_failure", "snapshot_manifest")]
    refs.extend(release["static_independent_checks"]["frozen_source_tool_records"])
    refs.extend(release["guard_correction"][k] for k in ("new_guard", "helper"))
    refs.append({"path": str(RELEASE), "bytes": RELEASE.stat().st_size,
                 "sha256": RELEASE_SHA256})
    by_path = {r["path"]: r for r in refs}
    return [by_path[k] for k in sorted(by_path)]


def snapshot_files(manifest):
    root = Path(manifest["root"])
    return [(root / item["relative_path"], item) for item in manifest["files"]]


def check_records(refs, snapshot):
    checked = []
    failures = []
    for ref in refs:
        path = Path(ref["path"])
        actual = describe(path) if path.is_file() else {"path": str(path), "missing": True}
        checked.append(actual)
        if actual.get("bytes") != ref["bytes"] or actual.get("sha256") != ref["sha256"]:
            failures.append({"expected": ref, "actual": actual})
    snapshot_checked = []
    for path, ref in snapshot_files(snapshot):
        actual = describe(path) if path.is_file() else {"path": str(path), "missing": True}
        snapshot_checked.append(actual)
        if actual.get("bytes") != ref["bytes"] or actual.get("sha256") != ref["sha256"]:
            failures.append({"expected": ref, "actual": actual})
    return {"frozen_records": checked, "snapshot_files": snapshot_checked,
            "all_match": not failures, "failures": failures}


def tree_files(root):
    result = {}
    for dirpath, _, filenames in os.walk(root):
        for name in filenames:
            path = Path(dirpath) / name
            relative = str(path.relative_to(root))
            result[relative] = describe(path)
    return result


def semantic_check(mode, released, output, invocation_rc):
    log = output / "xsim.log"
    guard_result_path = output / "guard" / "guard_result.json"
    if not log.is_file() or not guard_result_path.is_file():
        return {"accepted": False, "reason": "missing_xsim_log_or_guard_result"}
    lines = log.read_text(errors="replace").splitlines()
    guard_result = json.loads(guard_result_path.read_text())
    fatal_lines = [{"line": n, "text": line} for n, line in enumerate(lines, 1)
                   if re.search(r"\bfatal\b", line, re.IGNORECASE)]
    error_lines = [{"line": n, "text": line} for n, line in enumerate(lines, 1)
                   if re.search(r"\berror\s*:", line, re.IGNORECASE)]
    pass_lines = [{"line": n, "text": line} for n, line in enumerate(lines, 1)
                  if re.search(r"^AXI_STATIC_\w+_PASS\b", line)]
    expected_lines = [{"line": n, "text": line} for n, line in enumerate(lines, 1)
                      if released["expected_terminal"] in line]
    result = {"guard": guard_result, "guard_invocation_exit_code": invocation_rc,
              "xsim_log": describe(log), "fatal_lines": fatal_lines,
              "error_lines": error_lines, "pass_lines": pass_lines,
              "expected_terminal_lines": expected_lines}
    if released["expected_rejection"]:
        first = fatal_lines[0] if fatal_lines else None
        result["first_fatal"] = first
        result["accepted"] = (guard_result["trigger"] is None and first is not None
                              and released["expected_terminal"] in first["text"]
                              and not pass_lines)
        result["bounded_by_1000_clock_tb_watchdog"] = result["accepted"]
    else:
        expected = expected_lines[0] if len(expected_lines) == 1 else None
        result["accepted"] = (guard_result["trigger"] is None
                              and guard_result["child_exit_code"] == 0
                              and invocation_rc == 0 and expected is not None
                              and "clocks=100000" in expected["text"]
                              and "bytes=32768" in expected["text"]
                              and not fatal_lines and not error_lines
                              and len(pass_lines) == 1)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("preflight", "idle", "traffic", "reject_4k", "reject_wlast"))
    args = parser.parse_args()
    if digest(RELEASE) != RELEASE_SHA256:
        raise RuntimeError("release hash changed")
    release = json.loads(RELEASE.read_text())
    manifest_ref = release["snapshot_manifest"]
    manifest = json.loads(Path(manifest_ref["path"]).read_text())
    if manifest["file_count"] != 19 or manifest["canonical_sha256"] != release["static_independent_checks"]["snapshot_canonical_sha256"]:
        raise RuntimeError("snapshot manifest identity mismatch")
    refs = records(release)
    pre = check_records(refs, manifest)
    if not pre["all_match"]:
        raise RuntimeError("frozen precheck failed: " + json.dumps(pre["failures"]))
    if args.mode == "preflight":
        print(json.dumps({"at_utc": utc(), "frozen_record_count": len(refs),
                          "snapshot_file_count": len(pre["snapshot_files"]),
                          "all_match": True, "modes": [m["mode"] for m in release["ordered_conditional_runtime_modes"]]},
                         sort_keys=True))
        return 0
    released = next(m for m in release["ordered_conditional_runtime_modes"] if m["mode"] == args.mode)
    argv = released["exact_guard_command"]
    output = Path(argv[argv.index("--out") + 1]).parent
    work = Path(argv[argv.index("--cwd") + 1])
    if output.exists():
        raise RuntimeError("single-use output already exists: " + str(output))
    before_work = tree_files(work)
    output.mkdir(parents=True)
    with (output / "invocation.log").open("wb") as stream:
        invocation_rc = subprocess.run(argv, stdout=stream, stderr=subprocess.STDOUT).returncode
    post = check_records(refs, manifest)
    after_work = tree_files(work)
    new_work = {k: after_work[k] for k in sorted(after_work.keys() - before_work.keys())}
    changed_work = {k: {"before": before_work[k], "after": after_work[k]}
                    for k in sorted(after_work.keys() & before_work.keys())
                    if before_work[k] != after_work[k]}
    removed_work = {k: before_work[k] for k in sorted(before_work.keys() - after_work.keys())}
    semantic = semantic_check(args.mode, released, output, invocation_rc)
    evidence = {"schema": "axi_bounded_static_guard4_single_runtime_evidence_v1",
                "at_utc": utc(), "mode": args.mode, "release": describe(RELEASE),
                "exact_guard_command": argv, "pre": pre, "post": post,
                "work_created_files": new_work, "work_changed_files": changed_work,
                "work_removed_files": removed_work,
                "runtime_output_files_excluding_this_evidence": tree_files(output),
                "semantic": semantic,
                "accepted": post["all_match"] and not removed_work and semantic["accepted"]}
    write_json(output / "runtime_evidence.json", evidence)
    print(json.dumps({"mode": args.mode, "accepted": evidence["accepted"],
                      "invocation_exit_code": invocation_rc,
                      "guard": semantic.get("guard"),
                      "first_fatal": semantic.get("first_fatal"),
                      "terminal": semantic.get("expected_terminal_lines"),
                      "work_created": sorted(new_work), "work_changed": sorted(changed_work),
                      "evidence": str(output / "runtime_evidence.json")}, sort_keys=True))
    return 0 if evidence["accepted"] else 1


if __name__ == "__main__":
    sys.exit(main())
