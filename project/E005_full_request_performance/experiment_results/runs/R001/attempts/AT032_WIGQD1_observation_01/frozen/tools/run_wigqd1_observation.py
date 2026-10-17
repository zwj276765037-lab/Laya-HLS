#!/usr/bin/env python3
"""Freeze AT031 exactly, add passive WIGQD1 observation, run bounded RTL."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

E = Path(__file__).resolve().parents[5]
P = E.parents[2]
ROOT = P / "project/E005_full_request_performance/experiment_results/runs/R001"
BASE = ROOT / "attempts/AT031_WIGQD0_chain_03"
GQD0 = ROOT / "attempts/AT025_GQD0_chain_03"
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
HERE = E / MODULE / "tb"
TB_REL = MODULE / "tb/wigqd0_chain_tb_v1.sv"


def record(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": digest.hexdigest()}


def check(path, identity):
    actual = record(path)
    if any(actual[k] != identity[k] for k in ("bytes", "sha256")):
        raise RuntimeError(f"identity drift: {path}")
    return actual


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def guard_pattern(path):
    tree = ast.parse(path.read_text())
    for node in ast.walk(tree):
        if isinstance(node, ast.Assign) and any(
                isinstance(target, ast.Name) and target.id == "semantic_pattern"
                for target in node.targets):
            return re.compile(ast.literal_eval(node.value.args[0]), re.IGNORECASE)
    raise RuntimeError("frozen guard semantic regex missing")


def observation_check(old_tb, new_tb, guard):
    old = old_tb.read_text()
    new = new_tb.read_text()
    begin = "  // WIGQD1: passive, bounded observation of accepted work."
    end = "  logic g_aw_seen=0,g_w_seen=0,g_stored=0,g_read_active=0;"
    if new.count(begin) != 1 or new.count(end) != 1:
        raise RuntimeError("observation splice markers changed")
    before, rest = new.split(begin, 1)
    observer, after = rest.split(end, 1)
    if before + end + after != old:
        raise RuntimeError("non-observer TB behavior differs from AT031")
    pattern = guard_pattern(guard)
    templates = re.findall(r'\$display\("(WIGQD_DIAG[^\"]*)"', observer)
    if len(templates) != 1:
        raise RuntimeError("unexpected diagnostic template count")
    samples = []
    for tag in ("g_cfg_edge", "wi_cfg_edge", "wi_row_edge", "fixed_sample"):
        line = re.sub(r"%0[db]|%s", "1", templates[0]).replace("tag=1", "tag=" + tag)
        if pattern.search(templates[0]) or pattern.search(line):
            raise RuntimeError("diagnostic snapshot matches frozen semantic guard: " + line)
        samples.append(line)
    progress = re.findall(r'\$display\("(MATRIX_PROGRESS[^\"]*)"', observer)
    if not progress or any(not pattern.search(line) for line in progress):
        raise RuntimeError("real handshake marker not accepted by frozen guard")
    return {"source_only_observer_splice": True,
            "frozen_guard": record(guard), "diagnostic_templates": templates,
            "representative_diagnostics": samples,
            "progress_templates": progress,
            "diagnostics_match_guard": False}


def prepare(attempt):
    if attempt.exists():
        raise RuntimeError("attempt already exists")
    base_manifest = json.loads((BASE / "input_manifest.json").read_text())
    base_receipt = json.loads((BASE / "receipt.json").read_text())
    if base_receipt["status"] != "COST_STOP" or len(base_manifest["files"]) != 102:
        raise RuntimeError("unexpected AT031 base")
    tb_old = BASE / "frozen" / TB_REL
    tb_new = HERE / "wigqd0_chain_tb_v1.sv"
    guard = BASE / "frozen/tools/production_guard.py"
    obs = observation_check(tb_old, tb_new, guard)
    attempt.mkdir(parents=True)
    rows = []
    for row in base_manifest["files"]:
        source = Path(row["frozen"]["path"])
        check(source, row["frozen"])
        rel = source.relative_to(BASE)
        dest = attempt / rel
        actual_source = tb_new if rel == Path("frozen") / TB_REL else source
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.exists():
            check(dest, record(actual_source))
        else:
            shutil.copyfile(actual_source, dest)
        rows.append({"role": "WIGQD1_observation" if actual_source == tb_new else row["role"],
                     "source": record(actual_source), "frozen": record(dest)})
    if sum(1 for row in rows if row["role"] == "WIGQD1_observation") != 1:
        raise RuntimeError("TB observation override missing")
    for old, new in zip(base_manifest["files"], rows):
        if new["role"] != "WIGQD1_observation" and old["frozen"]["sha256"] != new["frozen"]["sha256"]:
            raise RuntimeError("non-TB frozen identity changed")
    runner_frozen = attempt / "frozen/tools/run_wigqd1_observation.py"
    shutil.copyfile(__file__, runner_frozen)
    rows.append({"role": "WIGQD1_runner", "source": record(__file__),
                 "frozen": record(runner_frozen)})
    write(attempt / "diagnostic_regex_check.json", obs)
    manifest = {"scope": "WIGQD1 passive observation of same AT031 four-row WIGQD chain",
                "status": "NOT_RUN", "files": rows,
                "tool": base_manifest["tool"],
                "upstream": {"AT031_receipt": record(BASE / "receipt.json"),
                             "AT031_manifest": record(BASE / "input_manifest.json")},
                "limits": base_manifest["limits"],
                "restriction": "one full; only TB observer and runner differ"}
    write(attempt / "input_manifest.json", manifest)
    write(attempt / "receipt.json", {"status": "NOT_RUN",
                                     "manifest": record(attempt / "input_manifest.json"),
                                     "phases": {}})
    print("WIGQD1_PREPARED_NOT_RUN", attempt, flush=True)


def run(attempt):
    receipt_path = attempt / "receipt.json"
    receipt = json.loads(receipt_path.read_text())
    if receipt["status"] != "NOT_RUN" or receipt["phases"]:
        raise RuntimeError("only a fresh NOT_RUN preparation can execute")
    manifest = json.loads((attempt / "input_manifest.json").read_text())
    check(attempt / "input_manifest.json", receipt["manifest"])
    rows = manifest["files"]
    if len(rows) != 103:
        raise RuntimeError("frozen source count changed")
    for row in rows:
        check(row["frozen"]["path"], row["frozen"])
    check(manifest["tool"]["path"], manifest["tool"])
    if not {0, 1, 2, 3}.issubset(os.sched_getaffinity(0)):
        raise RuntimeError("CPU0-3 unavailable")
    os.sched_setaffinity(0, {0, 1, 2, 3})
    frozen = attempt / "frozen"
    work = attempt / "work"
    fixtures = [str(work / "fixtures" / k) for k in
                ("g", "a", "w", "streams", "wi_a", "wi_w", "wi_streams")]
    for mode, rss, seconds in (("static", 24, 1800), ("pilot", 8, 120),
                               ("full", 8, 3600)):
        if mode == "full":
            if (attempt / "full_command.json").exists():
                raise RuntimeError("WIGQD1 full already launched")
            pilot_s = receipt["phases"]["pilot"]["guard"]["elapsed_seconds"]
            base_s = json.loads((BASE / "receipt.json").read_text())["phases"]["full"]["guard"]["elapsed_seconds"]
            g_s = json.loads((GQD0 / "receipt.json").read_text())["phases"]["full"]["guard"]["elapsed_seconds"]
            estimate = 1.5 * (base_s + g_s) + 2 * pilot_s
            receipt["full_cost_basis"] = {
                "AT031_full_including_120s_guard_seconds": base_s,
                "AT025_GQD0_full_seconds": g_s,
                "WIGQD1_pilot_seconds": pilot_s,
                "conservative_seconds": estimate,
                "method": "1.5x (actual AT031 full through Wi/G boundary including guard time + AT025 GQD0 full) plus 2x new pilot; admission only"}
            if estimate > 3600:
                receipt["status"] = "COST_STOP"
                receipt["phases"]["full"] = {"status": "COST_STOP", "launched": False}
                write(receipt_path, receipt)
                print("WIGQD1_FULL_COST_STOP_NOT_LAUNCHED", flush=True)
                return
        for row in rows:
            check(row["frozen"]["path"], row["frozen"])
        script = frozen / MODULE / "tb" / ("run_wigqd0_static_v1.tcl" if mode == "static" else "run_wigqd0_rtl_v1.tcl")
        args = ([str(work), str(frozen), *fixtures] if mode == "static"
                else [str(work), mode])
        cmd = [sys.executable, str(frozen / "tools/production_guard.py"),
               "--out", str(attempt / ("guard_" + mode)), "--cwd", str(E),
               "--rss-gib", str(rss), "--timeout-seconds", str(seconds),
               "--semantic-stall-seconds", "120", "--",
               manifest["tool"]["path"], "-mode", "batch", "-notrace",
               "-log", str(attempt / (mode + ".log")),
               "-journal", str(attempt / (mode + ".jou")),
               "-source", str(script), "-tclargs", *args]
        write(attempt / (mode + "_command.json"), cmd)
        completed = subprocess.run(cmd, cwd=E)
        guard_path = attempt / ("guard_" + mode) / "guard_result.json"
        state = json.loads(guard_path.read_text()) if guard_path.exists() else {"trigger": "missing_guard_result"}
        driver = attempt / ("guard_" + mode) / "driver.log"
        log = driver.read_text(errors="replace") if driver.exists() else ""
        marker = {"static": "WIGQD0_STATIC_PASS", "pilot": "WIGQD0_PILOT_PASS",
                  "full": "WIGQD0_CHAIN_PASS"}[mode]
        passed = (completed.returncode == 0 and state.get("trigger") is None and
                  state.get("child_exit_code") == 0 and marker in log)
        phase = {"status": "PASS" if passed else ("COST_STOP" if state.get("trigger") else "FAIL"),
                 "guard": state, "driver": record(driver) if driver.exists() else None,
                 "marker": marker if marker in log else None}
        raw = work / "vivado/wigqd0_chain_tb_v1.sim/sim_1/behav/xsim/simulate.log"
        if raw.exists() and mode != "static":
            dest = attempt / ("raw_" + mode + ".log")
            shutil.copyfile(raw, dest)
            phase["raw"] = record(dest)
            if re.search(r"(^|\n)(Fatal:|ERROR:)", dest.read_text(errors="replace")):
                passed = False
                phase["status"] = "FAIL"
        receipt["phases"][mode] = phase
        receipt["status"] = ("PASS_SCOPED_WIGQD1" if passed and mode == "full"
                             else "IN_PROGRESS" if passed else phase["status"])
        write(receipt_path, receipt)
        print("WIGQD1_" + mode.upper() + "_" + phase["status"], flush=True)
        if not passed:
            return


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--attempt", required=True, type=Path)
    ap.add_argument("--prepare-only", action="store_true")
    ap.add_argument("--execute-prepared", action="store_true")
    args = ap.parse_args()
    attempt = args.attempt.resolve()
    if not attempt.is_relative_to((ROOT / "attempts").resolve()):
        ap.error("attempt must be in E005/R001/attempts")
    if args.execute_prepared:
        run(attempt)
    else:
        prepare(attempt)
        if not args.prepare_only:
            run(attempt)


if __name__ == "__main__":
    main()
