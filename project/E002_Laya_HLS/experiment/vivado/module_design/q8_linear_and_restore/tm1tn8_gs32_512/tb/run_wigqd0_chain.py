#!/usr/bin/env python3
"""Freeze and run one bounded WIGQD0 same-runtime RTL attempt."""
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
HERE = E / MODULE / "tb"
ROOT = P / "project/E005_full_request_performance/experiment_results/runs/R001"
DOWN = ROOT / "attempts/AT002_KB1_Down_rowpack/evidence/measurement"
G = E / "results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04"
QIP = E / "results/compute_throughput_optimization_20261010/attempts/quant16_hls_syn_03/work/quant16_project/solution1/syn/verilog"
G_SV = ["quant16_slot_banks", "quant16_amax16", "quant16_half_rne",
        "quant16_tiny_div127", "quant16_divider_service", "quant16_stream_row",
        "quant_a_row_bank_v1", "quant_dual_a_v1", "quant_f32_row_bank_v1",
        "quant_f32_two_row_feeder_v1", "quant_task_to_dual_a_v1",
        "geglu_gate_writer_ledger_v1", "geglu_gate_quant_bridge_v1"]
V_SV = ["tanh_libm_canonical", "geglu_canonical_core",
        "geglu_row_bank_v1", "geglu_canonical_row_adapter"]


def rec(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": h.hexdigest()}


def checked(path, identity):
    now = rec(path)
    if any(now[k] != identity[k] for k in ("bytes", "sha256")):
        raise RuntimeError("frozen identity mismatch " + str(path))
    return now


def write(path, obj):
    path.write_text(json.dumps(obj, indent=2) + "\n")


def copy(src, dst, rows, role, expected=None):
    if expected is not None:
        checked(src, expected)
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists():
        checked(dst, rec(src))
    else:
        shutil.copyfile(src, dst)
    rows.append({"role": role, "source": rec(src), "frozen": rec(dst)})


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--attempt", required=True, type=Path)
    ap.add_argument("--prepare-only", action="store_true")
    ap.add_argument("--execute-prepared", action="store_true")
    args = ap.parse_args()
    attempt = args.attempt.resolve()
    if not attempt.is_relative_to(ROOT.resolve()):
        ap.error("attempt must be an E005/R001 child")
    if attempt.exists() and not args.execute_prepared:
        ap.error("attempt exists; use --execute-prepared only for a NOT_RUN preparation")
    if args.execute_prepared and (
        not (attempt / "receipt.json").exists() or
        json.loads((attempt / "receipt.json").read_text()).get("status") != "NOT_RUN"
    ):
        ap.error("only a prepared NOT_RUN attempt can execute")
    down_manifest = json.loads((DOWN / "input_manifest.json").read_text())
    g_manifest = json.loads((G / "input_manifest.json").read_text())
    g_known = {Path(x["path"]).name: x for x in g_manifest["files"]}
    if len(down_manifest["files"]) != 26 or len(down_manifest["fixture_files"]) != 12:
        raise RuntimeError("KB1 frozen closure differs from accepted identity")
    # Validate every source and fixture before making the new attempt.
    for row in down_manifest["files"] + down_manifest["fixture_files"]:
        checked(row["frozen"]["path"], row["frozen"])
    for part in ["q.mem", "scale.mem"]:
        d = DOWN / "work/fixtures/a" / part
        g = G / "work/fixture" / part
        if rec(d)["sha256"] != rec(g)["sha256"]:
            raise RuntimeError("G to Down expected A mismatch " + part)
    sources = []
    gsource = G / "frozen_source/vivado/module_design"
    for name in G_SV:
        if name in {"quant_task_to_dual_a_v1", "geglu_gate_quant_bridge_v1"}:
            continue
        src = gsource / "activation_quantizer/rtl" / (name + ".sv")
        checked(src, g_known[src.name])
        sources.append(src)
    for name in V_SV:
        src = gsource / "vector_and_ffn/rtl" / (name + ".sv")
        checked(src, g_known[src.name])
        sources.append(src)
    pkg = gsource / "q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv"
    checked(pkg, g_known[pkg.name])
    sources.append(pkg)
    canon = sorted((G / "canonical_rtl").glob("*.v"))
    if len(canon) != 11:
        raise RuntimeError("unexpected canonical RTL closure")
    for src in canon:
        checked(src, g_known[src.name])
    tool = down_manifest["tool"]
    checked(tool["path"], tool)
    attempt.mkdir(parents=True, exist_ok=args.execute_prepared)
    frozen = attempt / "frozen"
    work = attempt / "work"
    rows = []
    # The accepted KB1 Down source closure supplies the candidate writer.
    for row in down_manifest["files"]:
        src = Path(row["frozen"]["path"])
        rel = src.relative_to(DOWN / "frozen")
        if src.name == "tm4tn8_matrix_resident_tb_v2.sv":
            continue
        copy(src, frozen / rel, rows, "KB1_Down", row["frozen"])
    # The bridge04 closure is the authoritative G/quant implementation.
    for src in sources:
        rel = src.relative_to(gsource)
        copy(src, frozen / "vivado/module_design" / rel, rows, "G_bridge04", g_known[src.name])
    for name in ["quant_task_to_dual_a_v1", "geglu_gate_quant_bridge_v1"]:
        src = E / "vivado/module_design/activation_quantizer/rtl" / (name + ".sv")
        copy(src, frozen / "vivado/module_design/activation_quantizer/rtl" / src.name, rows, "WIGQD_shared_A")
    reader = E / MODULE / "rtl/laya_wi_axi_reader_v1.sv"
    if rec(reader)["sha256"] != "c09248fc14750a8d9fa23e2e0e2343b9bd1c047b81f44279e470105dd047c1f6":
        raise RuntimeError("WI reader differs from accepted E003/R003 identity")
    copy(reader, frozen / MODULE / "rtl" / reader.name, rows, "WI_reader")
    for src in canon:
        copy(src, frozen / "canonical_rtl" / src.name, rows, "G_canonical_RTL", g_known[src.name])
    for name in ["laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl",
                 "laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl"]:
        copy(QIP / name, frozen / "ip" / name, rows, "quant_IP_Tcl")
    for name in ["wigqd0_chain_tb_v1.sv", "run_wigqd0_static_v1.tcl", "run_wigqd0_rtl_v1.tcl"]:
        copy(HERE / name, frozen / MODULE / "tb" / name, rows, "WIGQD0_driver")
    for name, source in [("production_guard.py", HERE / "production_guard.py"),
                         ("hls_guard_helpers.py", E / "tools/hls_guard_helpers.py")]:
        copy(source, frozen / "tools" / name, rows, "guard")
    wi = ROOT / "attempts/AT028_WI0_resident_03"
    wi_manifest = json.loads((wi / "input_manifest.json").read_text())
    wi_fixtures = {Path(row["path"]).resolve(): row for row in wi_manifest["fixture_files"]}
    fixture_dirs = {}
    for label, origin in [("wi_a", wi / "work/fixtures/a"),
                          ("wi_w", wi / "work/fixtures/w"),
                          ("wi_streams", wi / "work/fixtures/streams"),
                          ("g", G / "work/fixture"),
                          ("a", DOWN / "work/fixtures/a"),
                          ("w", DOWN / "work/fixtures/w"),
                          ("streams", DOWN / "work/fixtures/streams")]:
        dest = work / "fixtures" / label
        fixture_dirs[label] = dest
        for src in sorted(origin.iterdir()):
            if src.is_file():
                if label.startswith("wi_"):
                    checked(src, wi_fixtures[src.resolve()])
                copy(src, dest / src.name, rows, "fixture_" + label)
    manifest = {"scope": "WIGQD0 four-row real resident Wi AXI byte store/reader through GATE,"
                " quant, same dualA and resident Down to consumed completion",
                "status": "NOT_RUN", "files": rows, "tool": tool,
                "upstream": {"G_bridge04": rec(G / "receipt.json"),
                             "KB1_Down": rec(DOWN / "receipt.json"), "WI0": rec(wi / "receipt.json")},
                "limits": {"cpus": [0, 1, 2, 3], "nice": 19,
                           "idle_IO": True, "minimum_MemAvailable_GiB": 192,
                           "static_RSS_GiB": 24, "static_seconds": 1800,
                           "RTL_RSS_GiB": 8, "pilot_seconds": 120,
                           "full_seconds": 3600, "semantic_stall_seconds": 120,
                           "cycle_cap": 40000000}}
    manifest_path = attempt / "input_manifest.json"
    write(manifest_path, manifest)
    receipt_path = attempt / "receipt.json"
    receipt = {"status": "NOT_RUN", "manifest": rec(manifest_path), "phases": {}}
    write(receipt_path, receipt)
    if args.prepare_only:
        print("WIGQD0_PREPARED_NOT_RUN " + str(attempt), flush=True)
        return
    if not {0, 1, 2, 3}.issubset(os.sched_getaffinity(0)):
        raise RuntimeError("CPU0-3 unavailable")
    os.sched_setaffinity(0, {0, 1, 2, 3})
    for mode, rss, seconds in [("static", 24, 1800), ("pilot", 8, 120), ("full", 8, 3600)]:
        if mode == "full" and receipt["full_cost_basis"]["conservative_seconds"] > 3600:
            receipt["status"] = "COST_STOP"
            receipt["phases"]["full"] = {"status": "COST_STOP", "launched": False}
            write(receipt_path, receipt)
            print("WIGQD0_FULL_COST_STOP_NOT_LAUNCHED", flush=True)
            return
        for row in rows:
            checked(row["frozen"]["path"], row["frozen"])
        checked(tool["path"], tool)
        script = frozen / MODULE / "tb" / ("run_wigqd0_static_v1.tcl" if mode == "static" else "run_wigqd0_rtl_v1.tcl")
        tclargs = ([str(work), str(frozen), *[str(fixture_dirs[k]) for k in ("g", "a", "w", "streams", "wi_a", "wi_w", "wi_streams")]]
                   if mode == "static" else [str(work), mode])
        cmd = [sys.executable, str(frozen / "tools/production_guard.py"),
               "--out", str(attempt / ("guard_" + mode)), "--cwd", str(E),
               "--rss-gib", str(rss), "--timeout-seconds", str(seconds),
               "--semantic-stall-seconds", "120", "--",
               tool["path"], "-mode", "batch", "-notrace",
               "-log", str(attempt / (mode + ".log")),
               "-journal", str(attempt / (mode + ".jou")),
               "-source", str(script), "-tclargs", *tclargs]
        (attempt / (mode + "_command.json")).write_text(json.dumps(cmd, indent=2) + "\n")
        completed = subprocess.run(cmd, cwd=E)
        guard = attempt / ("guard_" + mode) / "guard_result.json"
        state = json.loads(guard.read_text()) if guard.exists() else {"trigger": "missing_guard_result"}
        driver = attempt / ("guard_" + mode) / "driver.log"
        log = driver.read_text(errors="replace") if driver.exists() else ""
        marker = {"static": "WIGQD0_STATIC_PASS", "pilot": "WIGQD0_PILOT_PASS",
                  "full": "WIGQD0_CHAIN_PASS"}[mode]
        passed = (completed.returncode == 0 and state.get("trigger") is None and
                  state.get("child_exit_code") == 0 and marker in log)
        phase = {"status": "PASS" if passed else ("COST_STOP" if state.get("trigger") else "FAIL"),
                 "guard": state, "driver": rec(driver) if driver.exists() else None,
                 "marker": marker if marker in log else None}
        raw = work / "vivado/wigqd0_chain_tb_v1.sim/sim_1/behav/xsim/simulate.log"
        if raw.exists() and mode != "static":
            saved = attempt / ("raw_" + mode + ".log")
            shutil.copyfile(raw, saved)
            phase["raw"] = rec(saved)
            if re.search(r"(^|\n)(Fatal:|ERROR:)", saved.read_text(errors="replace")):
                passed = False
                phase["status"] = "FAIL"
        receipt["phases"][mode] = phase
        receipt["status"] = "PASS_SCOPED_WIGQD0" if passed and mode == "full" else (
            "IN_PROGRESS" if passed else phase["status"])
        if passed and mode == "pilot":
            # Upstream and W-load are in both pilot and full. Add the already
            # observed full KB1 Down cost rather than extrapolating a prefix.
            receipt["full_cost_basis"] = {
                "pilot_actual_seconds": state["elapsed_seconds"],
                "prior_WI0_full_seconds": 893.130500,
                "prior_GQD0_full_seconds": 747.161240,
                "conservative_seconds": (893.130500 + 747.161240) * 1.5 +
                                        state["elapsed_seconds"] * 2,
                "method": "1.5x prior independent WI0 and GQD0 full costs plus 2x real pilot; admission estimate only"}
        write(receipt_path, receipt)
        print("WIGQD0_" + mode.upper() + "_" + phase["status"], flush=True)
        if not passed:
            return


if __name__ == "__main__":
    main()
