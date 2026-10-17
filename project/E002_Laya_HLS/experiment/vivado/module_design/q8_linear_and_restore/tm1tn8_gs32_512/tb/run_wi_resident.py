#!/usr/bin/env python3
"""Freeze and guard the WI0 real-cache/resident/KB1-writer diagnostic."""
import argparse
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
MODULE = Path("vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512")
TB = E / MODULE / "tb"
ROOT = P / "project/E005_full_request_performance/experiment_results/runs/R001"
ATTEMPT = ROOT / "attempts/AT026_WI0_resident_01"
BASE = ROOT / "attempts/AT002_KB1_Down_rowpack/evidence/measurement"
NEW = {"tm4tn8_matrix_resident_tb_v2.sv": TB / "tm4tn8_wi_resident_tb_v1.sv",
       "run_tm4_matrix_resident_tb_static_v2.tcl": TB / "run_wi_resident_static_v1.tcl",
       "run_tm4_matrix_resident_tb_rtl_v2.tcl": TB / "run_wi_resident_rtl_v1.tcl"}
TOOL = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado")


def ident(path: Path) -> dict:
    path = path.resolve()
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": h.hexdigest()}


def check(path: Path, expected: dict) -> dict:
    actual = ident(path)
    if any(actual[k] != expected[k] for k in ("bytes", "sha256")):
        raise RuntimeError(f"frozen input changed: {path}")
    return actual


def save(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n")


def prepare() -> None:
    if (ATTEMPT / "input_manifest.json").exists():
        raise RuntimeError("WI0 attempt already frozen")
    work = ATTEMPT / "work"
    if not (work / "fixtures/wi_fixture_identity.json").is_file():
        raise RuntimeError("first prepare the independent Wi fixture in this attempt")
    prior = json.loads((BASE / "input_manifest.json").read_text())
    if prior["label"] != "KB1" or len(prior["files"]) != 26:
        raise RuntimeError("unexpected KB1 source closure")
    receipt = json.loads((BASE / "receipt.json").read_text())
    if any(receipt["phases"][phase]["status"] != "PASS"
           for phase in ("static", "pilot", "full")):
        raise RuntimeError("KB1 source result not complete")
    frozen = ATTEMPT / "frozen"
    rows = []
    for row in prior["files"]:
        source = Path(row["frozen"]["path"])
        check(source, row["frozen"])
        rel = source.relative_to(BASE / "frozen")
        selected = NEW.get(source.name, source)
        target_rel = rel.with_name(selected.name)
        target = frozen / target_rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(selected, target)
        rows.append({"from_KB1": row["frozen"], "selected": ident(selected),
                     "frozen": ident(target)})
    for key in ("guard", "guard_helpers"):
        record = prior[key]["frozen"]
        source = Path(record["path"])
        check(source, record)
        target = frozen / source.relative_to(BASE / "frozen")
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        rows.append({"from_KB1": record, "selected": ident(source),
                     "frozen": ident(target)})
    fixture = work / "fixtures"
    expected = json.loads((fixture / "wi_fixture_identity.json").read_text())
    fixture_files = []
    for rel, record in expected["generated"].items():
        path = fixture / rel
        fixture_files.append(check(path, record))
    for item in prior["files"]:
        if Path(item["frozen"]["path"]).name == "tm4tn8_axi512_writer_v1.sv":
            if item["selected"]["sha256"] != prior["candidate_writer"]["sha256"]:
                raise RuntimeError("KB1 rowpack writer identity mismatch")
    frozen_guard = frozen / MODULE / "tb/production_guard.py"
    static = frozen / MODULE / "tb/run_wi_resident_static_v1.tcl"
    rtl = frozen / MODULE / "tb/run_wi_resident_rtl_v1.tcl"
    fixture_dirs = [fixture / x for x in ("a", "w", "streams")]
    manifest = {
        "scope": "WI0 four distinct prequantized LN_FFN A rows to true strict W/cache/resident/KB1 writer output",
        "state": "PREPARED_NOT_RUN",
        "source": ident(BASE / "input_manifest.json"),
        "source_receipt": ident(BASE / "receipt.json"),
        "runner": ident(Path(__file__)),
        "builder": ident(TB / "build_wi_resident_tb.py"),
        "fixture_builder": ident(TB / "make_wi_resident_fixture.py"),
        "tool": check(TOOL, prior["tool"]),
        "files": rows, "fixture_files": fixture_files,
        "fixture_identity": ident(fixture / "wi_fixture_identity.json"),
        "limits": {"cpus": [0,1,2,3], "nice": 19, "idle_io": True,
                   "min_available_gib": 192, "static_gib": 24, "static_seconds": 1800,
                   "rtl_gib": 8, "pilot_seconds": 120, "full_seconds": 3600,
                   "stall_seconds": 120, "cycle_cap": 40000000},
    }
    commands = {}
    for mode, rss, limit, script, args in [
        ("static", 24, 1800, static, [str(work), str(frozen), *map(str, fixture_dirs)]),
        ("pilot", 8, 120, rtl, [str(work), "pilot"]),
        ("full", 8, 3600, rtl, [str(work), "full"]),
    ]:
        commands[mode] = [sys.executable, str(frozen_guard), "--out",
                          str(ATTEMPT / ("guard_" + mode)), "--cwd", str(E),
                          "--rss-gib", str(rss), "--timeout-seconds", str(limit),
                          "--semantic-stall-seconds", "120", "--", str(TOOL),
                          "-mode", "batch", "-notrace", "-log",
                          str(ATTEMPT / (mode + ".log")), "-journal",
                          str(ATTEMPT / (mode + ".jou")), "-source", str(script),
                          "-tclargs", *args]
    manifest["commands"] = commands
    save(ATTEMPT / "input_manifest.json", manifest)
    save(ATTEMPT / "receipt.json", {
        "scope": manifest["scope"], "status": "NOT_RUN",
        "input_manifest": ident(ATTEMPT / "input_manifest.json"), "phases": {}})
    print("WI_RESIDENT_PREPARED_NOT_RUN", ATTEMPT)


def run_phase(mode: str) -> None:
    manifest = json.loads((ATTEMPT / "input_manifest.json").read_text())
    receipt = json.loads((ATTEMPT / "receipt.json").read_text())
    if mode == "pilot" and receipt["phases"].get("static", {}).get("status") != "PASS":
        raise RuntimeError("WI0 pilot requires static PASS")
    if mode == "full" and receipt["phases"].get("pilot", {}).get("status") != "PASS":
        raise RuntimeError("WI0 full requires bounded pilot PASS")
    if mode == "full":
        estimate_path = ATTEMPT / "full_cost_estimate_before_launch.json"
        estimate = json.loads(estimate_path.read_text())
        if estimate["estimate_seconds"] > 3600 or not estimate["evidence"]:
            raise RuntimeError("WI0 full cost admission not supported under original cap")
        receipt["full_cost_estimate_before_launch"] = estimate
    if mode in receipt["phases"]:
        raise RuntimeError("refusing to repeat a WI0 phase in the same attempt")
    check(Path(manifest["runner"]["path"]), manifest["runner"])
    check(Path(manifest["tool"]["path"]), manifest["tool"])
    for row in manifest["files"]:
        check(Path(row["frozen"]["path"]), row["frozen"])
    for row in manifest["fixture_files"]:
        check(Path(row["path"]), row)
    check(Path(manifest["fixture_identity"]["path"]), manifest["fixture_identity"])
    if not {0,1,2,3}.issubset(os.sched_getaffinity(0)):
        raise RuntimeError("required CPU0-3 affinity unavailable")
    os.sched_setaffinity(0, {0,1,2,3})
    result = subprocess.run(manifest["commands"][mode], cwd=E)
    guard_path = ATTEMPT / ("guard_" + mode) / "guard_result.json"
    guard = json.loads(guard_path.read_text()) if guard_path.exists() else {
        "child_exit_code": None, "trigger": "missing_guard_result"}
    driver = ATTEMPT / ("guard_" + mode) / "driver.log"
    log = driver.read_text(errors="replace") if driver.exists() else ""
    marker = {"static": "WI_RESIDENT_STATIC_PASS",
              "pilot": "WI_RESIDENT_PILOT_PASS",
              "full": "WI_RESIDENT_FULL_PASS"}[mode]
    found = [line for line in log.splitlines() if marker in line]
    passed = (result.returncode == 0 and guard.get("child_exit_code") == 0
              and guard.get("trigger") is None and len(found) == 1)
    phase = {"status": "PASS" if passed else ("COST_STOP" if guard.get("trigger") else "FAIL"),
             "guard": guard, "marker": found,
             "driver_log": ident(driver) if driver.exists() else None}
    sim = ATTEMPT / "work/vivado/wi_resident_tb_v1.sim/sim_1/behav/xsim/simulate.log"
    if mode != "static" and sim.exists():
        raw = ATTEMPT / ("raw_" + mode + ".log")
        shutil.copyfile(sim, raw)
        phase["raw_log"] = ident(raw)
        text = raw.read_text(errors="replace")
        if re.search(r"(^|\n)(Fatal:|ERROR:)", text):
            phase["status"] = "FAIL"
            passed = False
        if passed and mode == "full":
            last = found[0]
            for key, expected in (("real_stripes", 20992), ("PS_lane_groups", 671744),
                                  ("final_packets", 2624), ("real_output_words", 20992),
                                  ("actual_AW", 1312), ("actual_W", 1312), ("actual_B", 1312)):
                if f"{key}={expected}" not in last:
                    phase["status"] = "FAIL"
                    phase["validation_error"] = f"missing coverage: {key}={expected}"
                    passed = False
    receipt["phases"][mode] = phase
    receipt["status"] = "PASS" if passed and mode == "full" else (
        "NOT_RUN" if passed else phase["status"])
    save(ATTEMPT / "receipt.json", receipt)
    print(f"WI_RESIDENT_{mode.upper()}_{phase['status']}", flush=True)
    if not passed:
        raise SystemExit(1)


if __name__ == "__main__":
    cli = argparse.ArgumentParser()
    cli.add_argument("phase", choices=("prepare", "static", "pilot", "full"))
    cli.add_argument("--attempt", default="AT026_WI0_resident_01")
    args = cli.parse_args()
    if not re.fullmatch(r"AT0[0-9][0-9]_WI0_resident_0[0-9]", args.attempt):
        cli.error("WI0 attempt name outside declared sequence")
    ATTEMPT = ROOT / "attempts" / args.attempt
    prepare() if args.phase == "prepare" else run_phase(args.phase)
