#!/usr/bin/env python3
"""Seal the source-only Head15 monitor-v3 proposal after guarded rehash."""
from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
V2 = ROOT.parent / "rtl_static_finite_monitor_v2"
TASK = ROOT.parents[2]
OUT = HERE / "source_packet.json"
RELEASE = TASK / "reviewer_attention_v5_head15_monitor_v3_explicit_record_port_source_preparation_release.json"
GUARD = TASK / "d2_controller_reachable/source/guard_16g.py"
SOURCE_SEAL = ROOT / "runs/source_seal_v1_control"


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def record(path: Path) -> dict:
    path = path.resolve(strict=True)
    return {"path": str(path), "bytes": path.stat().st_size,
            "mode": oct(path.stat().st_mode & 0o777), "sha256": sha(path)}


def guard_argv(cwd: Path, rss_gib: int, seconds: int, child: list[str]) -> list[str]:
    return ["/usr/bin/taskset", "-c", "0,1,2,3", "/usr/bin/python3",
            str(GUARD), "--out", str(cwd / "guard"), "--cwd", str(cwd),
            "--rss-gib", str(rss_gib), "--timeout-seconds", str(seconds),
            "--", *child]


def main() -> None:
    assert not OUT.exists(), OUT
    release = json.loads(RELEASE.read_text())
    prior_path = V2 / "source/source_packet.json"
    assert release["status"] == "SOURCE_ONLY_NO_COMPILER_OR_SIMULATOR"
    assert sha(RELEASE) == "5b83aa309fa35237db2269cb86a3cdc80c259bdfb9755f02ef4f8fd877891f30"
    assert sha(prior_path) == release["v2_source_packet"]["sha256"]
    assert sha(HERE / "design.md") == release["design"]["sha256"]
    prior = json.loads(prior_path.read_text())
    assert prior["schema"] == "attention_v5_head15_passive_r_accept_monitor_source_packet_v1"
    assert len(prior["verilog_modules"]) == 216 and len(prior["dat_files"]) == 35
    assert len(prior["fp_sim_vhdl_wrappers"]) == 6
    audit = json.loads((HERE / "source_static_audit.json").read_text())
    rehash = json.loads((HERE / "frozen_rehash.json").read_text())
    guard = json.loads((SOURCE_SEAL / "guard/guard_result.json").read_text())
    stage = json.loads((SOURCE_SEAL / "guard_stage.json").read_text())
    assert audit["status"] == "SOURCE_ONLY_STATIC_CHECKS_PASS_NO_EDA"
    assert rehash["status"] == "FROZEN_DEPENDENCIES_EXACT_SOURCE_ONLY"
    assert rehash["source_static_audit_sha256"] == sha(HERE / "source_static_audit.json")
    assert rehash["release_sha256"] == sha(RELEASE)
    assert guard["trigger"] is None and guard["child_exit_code"] == 0
    assert stage["exit_code"] == 0
    assert guard["minimum_mem_available_kb"] > 192 * 1024 * 1024
    assert guard["peak_owned_rss_kb"] < 2 * 1024 * 1024

    archive = json.loads((HERE / "v2_preimage_archive.json").read_text())
    assert archive["record_count"] == 30
    preimages = [record(Path(row["archived_path"])) for row in archive["records"]]
    for row, rec in zip(archive["records"], preimages):
        assert row["bytes"] == rec["bytes"] and row["sha256"] == rec["sha256"]

    local = [record(path) for folder in (ROOT / "tb", ROOT / "rtl")
             for path in sorted(folder.iterdir()) if path.is_file()]
    local += [record(path) for path in sorted(HERE.iterdir())
              if path.is_file() and path.name != "source_packet.json"]
    seal_evidence = [record(path) for path in sorted(SOURCE_SEAL.rglob("*")) if path.is_file()]
    assert len([x for x in local if x["path"].endswith("att_axi_monitor.sv")]) == 1
    assert not any("rtl_static_finite_monitor_v2/tb" in x["path"] for x in local)

    old_mode = prior["modes"]["base_h15_r63"]
    prepared = Path(release["accepted_prepared_path"])
    assert prepared == Path(old_mode["prepared_dir"]) and prepared.is_dir()
    materialize = Path(old_mode["materialize_dir"])
    prior_prepared_post = materialize / "binding_post.json"
    assert prior_prepared_post.is_file()
    build = ROOT / "runs/static_build_base_h15_r63_monitor_v3_v1"
    runtime = ROOT / "runs/rtl_base_h15_r63_monitor_v3_v1"
    assert not build.exists() and not runtime.exists()
    verify = ROOT / "tb/verify_binding.py"

    def binding(output: Path, *, snapshot=False, prepared_prior=None,
                snapshot_prior=None, run=False) -> list[str]:
        argv = ["/usr/bin/python3", str(verify), str(OUT), "base_h15_r63",
                str(output), "--prepared", str(prepared)]
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
    mode = {key: value for key, value in old_mode.items()
            if key not in ("materialize", "static", "runtime", "build_dir",
                           "runtime_dir", "stage_state")}
    mode.update({"stage_state": "SOURCE_ONLY_NEW_STATIC_AND_RUNTIME_HELD",
                 "build_dir": str(build), "runtime_dir": str(runtime),
                 "accepted_prepared_from": str(prepared)})
    mode["static"] = {
        "status": "PROPOSED_NOT_RELEASED",
        "cwd": str(build), "budget_proposal": {"rss_gib": 16, "seconds": 300},
        "commands": [
            {"step": "binding_pre", "argv": binding(build / "binding_pre.json",
                                                      prepared_prior=prior_prepared_post)},
            {"step": "guarded_static_build", "argv": guard_argv(build, 16, 300,
                ["/usr/bin/bash", str(ROOT / "tb/build_static.sh"),
                 "base_h15_r63", str(build)])},
            {"step": "binding_post", "argv": binding(build_post, snapshot=True,
                                                       prepared_prior=prior_prepared_post)},
            {"step": "archive", "argv": ["/usr/bin/python3",
                str(ROOT / "tb/archive_attempt.py"), "base_h15_r63", "static",
                str(build), str(build / "attempt_archive")]},
        ],
    }
    mode["runtime"] = {
        "status": "PROPOSED_NOT_RELEASED",
        "cwd": str(runtime), "budget_proposal": {"rss_gib": 8, "seconds": 600},
        "commands": [
            {"step": "binding_pre", "argv": binding(runtime_pre, snapshot=True,
                prepared_prior=build_post, snapshot_prior=build_post)},
            {"step": "guarded_runtime", "argv": guard_argv(runtime, 8, 600,
                ["/usr/bin/bash", str(ROOT / "tb/run_mode.sh"), "base_h15_r63",
                 str(runtime), str(build), str(prepared)])},
            {"step": "binding_post", "argv": binding(runtime / "binding_post.json",
                snapshot=True, prepared_prior=runtime_pre,
                snapshot_prior=build_post, run=True)},
            {"step": "archive", "argv": ["/usr/bin/python3",
                str(ROOT / "tb/archive_attempt.py"), "base_h15_r63", "runtime",
                str(runtime), str(runtime / "attempt_archive"),
                "--build", str(build)]},
        ],
    }
    packet = {
        "schema": "attention_v5_head15_explicit_r_record_monitor_source_packet_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "state": "SOURCE_PREPARED_ONLY_NO_STATIC_RUNTIME_OR_DUT_EXECUTION",
        "monitor_source_gate": record(RELEASE),
        "monitor_design": record(HERE / "design.md"),
        "first_failure_review": record(Path(release["independent_failure_acceptance"]["path"])),
        "first_failure_actual": record(Path(release["v2_actual_failure"]["path"])),
        "prior_monitor_source_packet": record(prior_path),
        "prior_finite_source_packet": prior["prior_finite_source_packet"],
        "preimage_archive": record(HERE / "v2_preimage_archive.json"),
        "preimage_files": preimages,
        "source_diff": record(HERE / "v2_to_v3_tb_runner.diff"),
        "source_mapping": record(HERE / "implementation_mapping.md"),
        "source_static_audit": record(HERE / "source_static_audit.json"),
        "frozen_rehash": record(HERE / "frozen_rehash.json"),
        "source_seal_evidence": seal_evidence,
        "source_gate": prior["source_gate"], "cold_gate": prior["cold_gate"],
        "accepted_endpoint": prior["accepted_endpoint"],
        "cold_v2_numeric_acceptance": prior["cold_v2_numeric_acceptance"],
        "verilog_modules": prior["verilog_modules"],
        "dat_files": prior["dat_files"],
        "fp_sim_vhdl_wrappers": prior["fp_sim_vhdl_wrappers"],
        "testbench_and_runner": local,
        "frozen_inputs": prior["frozen_inputs"],
        "guard_scripts": prior["guard_scripts"],
        "schedule_reports": prior["schedule_reports"],
        "installed_library_files": prior["installed_library_files"],
        "xsim_ini": prior["xsim_ini"],
        "xsim_lookup_manual": prior["xsim_lookup_manual"],
        "accepted_prepared_files": prior["accepted_prepared_files"],
        "modes": {"base_h15_r63": mode},
        "held_mode": "changed_h0_r0",
        "allowed_active_changes": sorted(audit["changed_files"]),
        "record_fields": audit["field_map"],
        "record_bits": 119,
        "unchanged_source_policy": "No DUT, Verilog, FP wrapper, library, endpoint, gold, prepared page or inherited acceptance check changed.",
        "next_gates": "Independent source review, then one separately released static build and later one separately released runtime attempt.",
    }
    OUT.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print("HEAD15_V3_SOURCE_PACKET", OUT, "local", len(local),
          "preimages", len(preimages), "frozen", rehash["unique_files_exact"])


if __name__ == "__main__":
    main()
