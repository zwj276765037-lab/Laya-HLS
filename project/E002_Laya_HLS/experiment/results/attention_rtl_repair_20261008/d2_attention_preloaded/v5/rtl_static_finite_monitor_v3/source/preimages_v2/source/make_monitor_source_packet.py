#!/usr/bin/env python3
"""Seal source-only monitor repair and inherited finite closure; no EDA execution."""
from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
OLD = ROOT.parent / "rtl_static_finite_v1"
TASK = ROOT.parents[2]
OUT = HERE / "source_packet.json"
RELEASE = TASK / "reviewer_attention_v5_head15_passive_r_accept_monitor_source_preparation_release.json"
FAILURE_REVIEW = TASK / "reviewer_attention_v5_head15_first_failure_and_partial_bytes_diagnosis.json"
FAILURE_ACTUAL = OLD / "runs/rtl_base_h15_r63_v1/head15_runtime_actual_result_evidence.json"
PRIOR = OLD / "source/source_packet.json"
DESIGN = HERE / "design.md"
STATIC_AUDIT = HERE / "source_static_audit.json"
DIFF = HERE / "old_to_new_tb.diff"
MAPPING = HERE / "implementation_mapping.md"
GUARD = TASK / "d2_controller_reachable/source/guard_16g.py"


def sha(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def record(path: Path) -> dict:
    assert path.is_file(), path
    path = path.resolve(strict=True)
    return {"path": str(path), "bytes": path.stat().st_size,
            "mode": oct(path.stat().st_mode & 0o777), "sha256": sha(path)}


def verify_records(records: list[dict]) -> None:
    for item in records:
        assert record(Path(item["path"])) == item, item["path"]


def guard_argv(cwd: Path, budget_gib: int, seconds: int, child: list[str]) -> list[str]:
    return ["/usr/bin/taskset", "-c", "0,1,2,3",
            "/usr/bin/nice", "-n", "19", "/usr/bin/ionice", "-c", "3",
            "/usr/bin/python3", str(GUARD), "--out", str(cwd / "guard"),
            "--cwd", str(cwd), "--rss-gib", str(budget_gib),
            "--timeout-seconds", str(seconds), "--", *child]


def main() -> None:
    assert not OUT.exists(), OUT
    assert sha(RELEASE) == "68bcb430f9199a31af5a2c47eb02f437084ea7fd6ade5984223555ba3b116308"
    assert sha(DESIGN) == "842ff3517fa225397a3d5473df79b5e1f73d0c96149f46c96c78e247e28db0ed"
    assert sha(FAILURE_REVIEW) == "f6a539b8103c7a266bb634606ce36d34ec079cb2a35545a318073d5c17ec5520"
    assert sha(FAILURE_ACTUAL) == "db1bad461f7469f017d7c618dabddfa8d4c9293273e68d4d26184b74aa122569"
    assert sha(PRIOR) == "cccbc316c4bed7e245c7a714bf36e872d70aae1c118d0e39c4e20bc27b521656"
    assert json.loads(STATIC_AUDIT.read_text())["status"] == "SOURCE_ONLY_STATIC_CHECKS_PASS_NO_COMPILER_OR_DUT_EXECUTION"
    old = json.loads(PRIOR.read_text())
    assert old["schema"] == "attention_v5_finite_static_source_packet_v1"
    assert len(old["verilog_modules"]) == 216
    assert len(old["dat_files"]) == 35
    assert len(old["fp_sim_vhdl_wrappers"]) == 6
    for key in ("verilog_modules", "dat_files", "fp_sim_vhdl_wrappers",
                "frozen_inputs", "guard_scripts", "schedule_reports"):
        verify_records(old[key])
    for group in old["installed_library_files"].values():
        verify_records(group)
    for key in ("source_gate", "cold_gate", "accepted_endpoint",
                "cold_v2_numeric_acceptance", "xsim_ini", "xsim_lookup_manual"):
        assert record(Path(old[key]["path"])) == old[key]

    old_mode = old["modes"]["base_h15_r63"]
    prepared = Path(old_mode["prepared_dir"])
    prior_prepared_post = Path(old_mode["materialize_dir"]) / "binding_post.json"
    old_materialization = Path(old_mode["materialize_dir"]) / "materialization_execution_packet.json"
    assert prepared.is_dir() and prior_prepared_post.is_file()
    accepted_pages = sorted(prepared.glob("*.memh"))
    assert len(accepted_pages) == 10
    accepted_prepared_files = [record(path) for path in accepted_pages]
    accepted_prepared_files += [record(prepared / "materialization.json"),
                                record(prepared.parent / "independent_page_check.json"),
                                record(prior_prepared_post), record(old_materialization)]

    tb_files = sorted(path for path in (ROOT / "tb").iterdir() if path.is_file())
    source_files = sorted(path for path in HERE.iterdir()
                          if path.is_file() and path.name != "source_packet.json")
    local_source_files = tb_files + source_files + [ROOT / "rtl/README.md"]
    local_records = [record(path) for path in sorted(local_source_files)]
    build = ROOT / "runs/static_build_base_h15_r63_monitor_v2_v1"
    runtime = ROOT / "runs/rtl_base_h15_r63_monitor_v2_v1"
    assert not build.exists() and not runtime.exists()
    mode = {key: value for key, value in old_mode.items()
            if key not in ("materialize", "static", "runtime", "build_dir",
                           "runtime_dir", "stage_state")}
    mode.update({"stage_state": "SOURCE_ONLY_NEW_STATIC_AND_RUNTIME_HELD",
                 "build_dir": str(build), "runtime_dir": str(runtime),
                 "accepted_prepared_from": str(prepared)})
    verify = str(ROOT / "tb/verify_binding.py")
    packet_path = str(OUT)
    name = "base_h15_r63"
    def binding(output: Path, *, pages: bool = True, snapshot: bool = False,
                prepared_prior: Path | None = None,
                snapshot_prior: Path | None = None, run: bool = False) -> list[str]:
        argv = ["/usr/bin/python3", verify, packet_path, name, str(output)]
        if pages:
            argv += ["--prepared", str(prepared)]
        if snapshot:
            argv += ["--snapshot", str(build / "xsim.dir")]
        if prepared_prior:
            argv += ["--expected-prepared-report", str(prepared_prior)]
        if snapshot_prior:
            argv += ["--expected-snapshot-report", str(snapshot_prior)]
        if run:
            argv += ["--runtime", str(runtime)]
        return argv
    build_post = build / "binding_post.json"
    runtime_pre = runtime / "binding_pre.json"
    mode["static"] = {
        "cwd": str(build), "budget_proposal": {"rss_gib": 16, "seconds": 300},
        "binding_pre_argv": binding(build / "binding_pre.json",
                                    prepared_prior=prior_prepared_post),
        "guard_argv": guard_argv(build, 16, 300,
                                 [str(ROOT / "tb/build_static.sh"), name, str(build)]),
        "binding_post_argv": binding(build_post, snapshot=True,
                                     prepared_prior=prior_prepared_post),
        "archive_argv": ["/usr/bin/python3", str(ROOT / "tb/archive_attempt.py"),
                         name, "static", str(build), str(build / "attempt_archive")],
    }
    mode["runtime"] = {
        "cwd": str(runtime), "budget_proposal": {"rss_gib": 8, "seconds": 600},
        "binding_pre_argv": binding(runtime_pre, snapshot=True,
                                    prepared_prior=build_post,
                                    snapshot_prior=build_post),
        "guard_argv": guard_argv(runtime, 8, 600,
                                 [str(ROOT / "tb/run_mode.sh"), name, str(runtime),
                                  str(build), str(prepared)]),
        "binding_post_argv": binding(runtime / "binding_post.json",
                                     snapshot=True, prepared_prior=runtime_pre,
                                     snapshot_prior=build_post, run=True),
        "archive_argv": ["/usr/bin/python3", str(ROOT / "tb/archive_attempt.py"),
                         name, "runtime", str(runtime),
                         str(runtime / "attempt_archive"), "--build", str(build)],
    }
    packet = {
        "schema": "attention_v5_head15_passive_r_accept_monitor_source_packet_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "state": "SOURCE_PREPARED_ONLY_NO_STATIC_RUNTIME_OR_DUT_EXECUTION",
        "monitor_source_gate": record(RELEASE), "monitor_design": record(DESIGN),
        "first_failure_review": record(FAILURE_REVIEW),
        "first_failure_actual": record(FAILURE_ACTUAL),
        "prior_finite_source_packet": record(PRIOR),
        "source_diff": record(DIFF), "source_mapping": record(MAPPING),
        "source_static_audit": record(STATIC_AUDIT),
        "source_gate": old["source_gate"], "cold_gate": old["cold_gate"],
        "accepted_endpoint": old["accepted_endpoint"],
        "cold_v2_numeric_acceptance": old["cold_v2_numeric_acceptance"],
        "verilog_modules": old["verilog_modules"], "dat_files": old["dat_files"],
        "fp_sim_vhdl_wrappers": old["fp_sim_vhdl_wrappers"],
        "testbench_and_runner": local_records,
        "frozen_inputs": old["frozen_inputs"],
        "guard_scripts": old["guard_scripts"],
        "schedule_reports": old["schedule_reports"],
        "installed_library_files": old["installed_library_files"],
        "xsim_ini": old["xsim_ini"], "xsim_lookup_manual": old["xsim_lookup_manual"],
        "accepted_prepared_files": accepted_prepared_files,
        "modes": {name: mode},
        "held_mode": "changed_h0_r0",
        "held_historical_tb_helpers": ["generate_top.py", "make_source_packet.py",
                                       "materialize_cold_pages.py"],
        "unchanged_source_policy": "No DUT, Verilog, FP wrapper, library, endpoint, gold, prepared page or inherited check change.",
        "next_gates": "Independent source review, then separate first static and runtime releases; neither is authorized here.",
    }
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print("ATT_FINITE_MONITOR_SOURCE_PACKET", OUT, "new_files", len(local_records),
          "verilog", len(packet["verilog_modules"]), "dat", len(packet["dat_files"]),
          "vhdl", len(packet["fp_sim_vhdl_wrappers"]),
          "prepared", len(accepted_prepared_files))


if __name__ == "__main__":
    main()
