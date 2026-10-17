#!/usr/bin/env python3
"""Read-only V7 exact-diff audit by default; --write-packet seals source evidence.

This script never invokes a compiler, test runner, HLS, Vivado, or XSim.
"""
from __future__ import annotations

import argparse
import datetime as dt
import difflib
import hashlib
import json
from pathlib import Path
import re

MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[3]
EVIDENCE = ROOT / "results/attention_rtl_repair_20261008"
V6 = MODULE.parent / "v6_metadata_reset"
RELEASE = EVIDENCE / "reviewer_attention_v7_metadata_reset_pragma_scope_source_preparation_release.json"
V6_PACKET = V6 / "source/source_packet.json"
V6_HLS = V6 / "runs/hls_synthesis_v1"
EXPECTED_RELEASE_SHA = "8480b4f7931ac291b37666bba15bb223da955006fa1361b43103dfd556986a8f"
EXPECTED_V6_PACKET_SHA = "5adb690006430cc8cd4967228f8420bce9e999f8396adbe63d384d94b993704e"
EXPECTED_V6_TOP_SHA = "31558b89f93d28b03e804841a45133ff336c8c1da52efe710a847e7575cfbb09"
EXPECTED_V6_HLS_SHA = "008bef09743876ba2467d8ff9d3662c5de5869c7e4d3fd082b3b074b78e0e25b"


def require(ok: bool, message: str) -> None:
    if not ok:
        raise RuntimeError(message)


def ident(path: Path) -> dict[str, object]:
    data = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def same_record(path: Path, expected: dict[str, object]) -> None:
    actual = ident(path)
    require(actual == expected, f"identity mismatch: {path}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write-packet", action="store_true",
                        help="write new diff and source packet after read-only checks")
    args = parser.parse_args()

    release_id = ident(RELEASE)
    packet_id = ident(V6_PACKET)
    hls_evidence_id = ident(V6_HLS / "actual_result_evidence.json")
    require(release_id["sha256"] == EXPECTED_RELEASE_SHA, "V7 gate changed")
    require(packet_id["sha256"] == EXPECTED_V6_PACKET_SHA, "V6 packet changed")
    require(hls_evidence_id["sha256"] == EXPECTED_V6_HLS_SHA,
            "first-failure evidence changed")
    release = json.loads(RELEASE.read_text())
    old_packet = json.loads(V6_PACKET.read_text())
    hls_evidence = json.loads((V6_HLS / "actual_result_evidence.json").read_text())
    require(release["status"] == "SOURCE_PREPARATION_ONLY_RELEASED" and
            str(MODULE) == release["new_root"], "scope gate/root mismatch")
    require(release["v6_source_packet"] == packet_id and
            release["v6_top"] == ident(V6 / "source/attention_preloaded_slice.cpp"),
            "gate baseline mismatched")
    require(release["v6_top"]["sha256"] == EXPECTED_V6_TOP_SHA,
            "V6 top identity mismatched")
    require(hls_evidence["first_failure"]["line"] == 448 and
            "undeclared identifier 'metadata_initialized'" in
            hls_evidence["first_failure"]["verbatim_error"] and
            hls_evidence["partial_outputs"]["preprocessed_tu_count"] == 25 and
            hls_evidence["archive_file_count"] == 507,
            "V6 first failure facts mismatched")
    require(old_packet["official_production_translation_units"] == 25 and
            len(old_packet["immutable_inputs"]) == 84 and
            len(old_packet["prepared_files"]) == 13,
            "V6 source-packet closure changed")

    archive = MODULE / "evidence/preimage_manifest.json"
    archive_data = json.loads(archive.read_text())
    require(archive_data["v6_source_packet"] == packet_id and
            len(archive_data["files"]) == 14, "preimage archive malformed")
    expected_old = {r["path"]: r for r in old_packet["prepared_files"]}
    expected_old[str(V6_PACKET)] = packet_id
    for entry in archive_data["files"]:
        original = Path(entry["original_path"])
        copied = Path(entry["archived_path"])
        require(str(original) in expected_old and
                copied == MODULE / "evidence/preimages" / original.relative_to(V6),
                f"preimage path not bound: {original}")
        record = {k: entry[k] for k in ("bytes", "sha256")}
        require(record == {k: expected_old[str(original)][k] for k in record},
                f"preimage identity not bound: {original}")
        same_record(original, expected_old[str(original)])
        require(ident(copied)["sha256"] == entry["sha256"] and
                ident(copied)["bytes"] == entry["bytes"],
                f"archived preimage changed: {copied}")
    require({r["original_path"] for r in archive_data["files"]} == set(expected_old),
            "preimage coverage incomplete")

    frozen_checks = []
    for phase in ("pre", "post"):
        source_check_path = V6_HLS / f"source_binding_{phase}.json"
        same_record(source_check_path, hls_evidence[f"{phase}check"])
        source_check = json.loads(source_check_path.read_text())
        checks = source_check["nested_checks"]
        require(source_check["all_match"] and len(checks) == 101 and
                source_check["nested_record_count"] == 101 and
                source_check["nested_unique_path_count"] == 97,
                f"V6 {phase} binding record shape changed")
        for check in checks:
            require(check["match"], f"V6 {phase} original check had mismatch")
            same_record(Path(check["expected"]["path"]), check["expected"])
        frozen_checks.append({"phase": phase, "binding": ident(source_check_path),
                              "record_count": 101, "unique_paths": 97,
                              "all_current_identities_match": True})
    closure_path = Path(hls_evidence["actual_preprocessed_dependencies"]["path"])
    same_record(closure_path, hls_evidence["actual_preprocessed_dependencies"])
    closure = json.loads(closure_path.read_text())
    require(closure["preprocessed_tu_count"] == 25 and
            closure["unique_real_file_count"] == 227 and
            len(closure["unique_real_files"]) == 227,
            "actual V6 preprocessing closure changed")
    same_record(Path(hls_evidence["archive_inventory"]["path"]),
                hls_evidence["archive_inventory"])

    old_top_path = V6 / "source/attention_preloaded_slice.cpp"
    new_top_path = MODULE / "source/attention_preloaded_slice.cpp"
    old = old_top_path.read_text()
    new = new_top_path.read_text()
    old_head = "                                            uint32_t* observed) {\n#ifdef __SYNTHESIS__\n"
    new_head = "                                            uint32_t* observed) {\n  using namespace laya::full;\n#ifdef __SYNTHESIS__\n"
    old_tail = "  using namespace laya;\n  using namespace laya::full;\n  using namespace laya::d2_preload;\n"
    new_tail = "  using namespace laya;\n  using namespace laya::d2_preload;\n"
    require(old.count(old_head) == old.count(old_tail) == 1,
            "V6 top expected lexical anchors missing")
    expected_new = old.replace(old_head, new_head, 1).replace(old_tail, new_tail, 1)
    require(new == expected_new, "V7 top differs beyond one using-directive move")
    directive = "  using namespace laya::full;\n"
    require(old.count(directive) == new.count(directive) == 1 and
            old.replace(directive, "") == new.replace(directive, ""),
            "normalized top comparison differs")
    require(new.count("#pragma HLS reset variable=metadata_initialized") == 1 and
            new.index(new_head) < new.index("#pragma HLS reset variable=metadata_initialized") <
            new.index(new_tail), "reset pragma/direct-function-scope check failed")
    require(new.count('extern "C" void attention_preloaded_slice(') == 1 and
            new.index("if (!metadata_initialized)") < new.index("FullMemory memory{"),
            "entry/gate structure changed")
    normalized_sha = hashlib.sha256(new.replace(directive, "").encode()).hexdigest()
    diff = "".join(difflib.unified_diff(old.splitlines(True), new.splitlines(True),
                   fromfile="v6_metadata_reset/source/attention_preloaded_slice.cpp",
                   tofile="v7_metadata_reset_scope/source/attention_preloaded_slice.cpp"))
    require(diff.count("-  using namespace laya::full;") == 1 and
            diff.count("+  using namespace laya::full;") == 1,
            "literal diff is not a single move")

    copied = ("source/attention_preloaded_abi.h", "source/run_preloaded_cpu.py",
              "source/metadata_field_checklist.md", "source/v5_to_v6_metadata_only.diff",
              "tb/test_attention_preloaded.cpp", "tb/sha256_test_only.h")
    for rel in copied:
        require((MODULE / rel).read_bytes() == (V6 / rel).read_bytes(),
                f"nonfunctional copied file changed: {rel}")
    old_cfg = (V6 / "config.cfg").read_text()
    new_cfg = (MODULE / "config.cfg").read_text()
    old_root = str(V6) + "/"
    new_root = str(MODULE) + "/"
    require(old_cfg.count(old_root) == new_cfg.count(new_root) == 5 and
            old_cfg.replace(old_root, new_root) == new_cfg and
            old_root not in new_cfg,
            "config differs beyond five local path replacements")
    config_sources = re.findall(r"^syn.file=(\S+)$", new_cfg, re.MULTILINE)
    production = old_packet["official_production_paths"]
    controller = str(ROOT / "hls/control/full_forward_controller.cpp")
    require(len(production) == 25 and production.count(controller) == 1 and
            len(config_sources) == 25 and config_sources[0] == str(new_top_path) and
            config_sources[1:] == [p for p in production if p != controller],
            "25 source closure/Controller inclusion changed")
    require("-std=c++17 -O2 -fno-fast-math -ffp-contract=off" in new_cfg and
            "-DD2_PRELOADED_RESET_TEST_HOOK" in new_cfg and
            "part=xcu55c-fsvh2892-2L-e\nfreqhz=150000000" in new_cfg,
            "HLS part, clock, or strict flags changed")

    plan_path = MODULE / "source/execution_plan.json"
    plan = json.loads(plan_path.read_text())
    require(plan["status"] == "PROPOSAL_ONLY_NOT_EXECUTION_RELEASED" and
            plan["source_preparation_release"] == release_id and
            plan["prior_accepted_source_packet"] == packet_id and
            plan["v7_top"] == ident(new_top_path) and
            plan["v7_config"] == ident(MODULE / "config.cfg"),
            "dormant execution plan binding changed")
    for stage in ("cpu_build", "cpu_execute", "csim"):
        require(plan["stages"][stage] == "NOT_AUTHORIZED_FOR_V7",
                f"{stage} accidentally active")
    hls = plan["stages"]["hls_synthesis"]
    require(hls["status"] == "HELD_FOR_SOURCE_REVIEW_AND_SEPARATE_SINGLE_USE_GATE" and
            hls["max_owned_rss_gib"] == 16 and hls["max_wall_seconds"] == 1800 and
            hls["run_root"] == str(MODULE / "runs/hls_synthesis_v1") and
            hls["payload_argv"][5] == str(MODULE / "config.cfg"),
            "future HLS stage changed")
    require(plan["policy"]["cpus"] == [0, 1, 2, 3] and
            plan["policy"]["minimum_mem_available_kib_strictly_above"] == 201326592 and
            plan["policy"]["one_laya_heavy_tool"], "guard policy changed")
    require(not (MODULE / "runs").exists(), "source-only variant has run artifacts")

    diff_path = MODULE / "source/v6_to_v7_scope_only.diff"
    packet_path = MODULE / "source/source_packet.json"
    if args.write_packet:
        require(not diff_path.exists() and not packet_path.exists(),
                "source packet already sealed; refuse overwrite")
        diff_path.write_text(diff)
        prepared_names = (
            "config.cfg", "source/attention_preloaded_slice.cpp",
            "source/attention_preloaded_abi.h", "source/run_preloaded_cpu.py",
            "source/design.md", "source/results.md",
            "source/metadata_field_checklist.md", "source/v5_to_v6_metadata_only.diff",
            "source/make_source_packet.py", "source/execution_plan.json",
            "source/v6_to_v7_scope_only.diff", "tb/test_attention_preloaded.cpp",
            "tb/sha256_test_only.h", "rtl/README.md",
            "evidence/preimage_manifest.json")
        packet = {
            "schema": "d2_attention_v7_metadata_reset_scope_source_preparation_v1",
            "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
            "status": "SOURCE_PREPARED_NO_V7_CPU_CSIM_HLS_OR_RTL_EXECUTION",
            "authority": release_id,
            "v6_source_packet": packet_id,
            "v6_hls_first_failure": hls_evidence_id,
            "v6_frozen_pre_and_post_rechecks": frozen_checks,
            "v6_actual_preprocessed_dependencies": ident(closure_path),
            "v6_archive_inventory": ident(Path(hls_evidence["archive_inventory"]["path"])),
            "exact_preimages": ident(archive),
            "source_diff": ident(diff_path),
            "normalized_top_without_moved_directive_sha256": normalized_sha,
            "scope_checks": {
                "one_direct_function_body_using_directive": True,
                "directive_precedes_synthesis_pragma_block": True,
                "one_unchanged_reset_pragma": True,
                "single_move_exact_byte_comparison": True,
                "normalized_top_bytes_identical": True,
                "config_only_five_local_path_replacements": True,
                "copied_tb_abi_and_runner_byte_identical": True,
                "official_production_tus": 25,
                "hls_config_tus": 25,
                "included_controller_once": True,
                "frozen_original_pre_and_post_records_each": 101,
                "frozen_original_unique_paths_each": 97,
                "actual_preprocessed_tus": 25,
                "actual_dependency_files": 227,
                "prior_archived_hls_files": 507,
                "compiler_or_eda_invocations": 0,
            },
            "prepared_files": [ident(MODULE / name) for name in prepared_names],
            "execution": {"cpu_build": "not_run_v7", "cpu": "not_run_v7",
                          "csim": "not_run_v7", "hls": "not_run_v7",
                          "rtl_static": "not_run_v7", "rtl_runtime": "not_run_v7"},
            "next_gate": "independent exact-diff review, then separate one-shot HLS release",
        }
        packet_path.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
        print("V7_SOURCE_PACKET_SEALED", ident(packet_path)["sha256"],
              "preimages=14 frozen_checks=202")
    else:
        if diff_path.exists():
            require(diff_path.read_text() == diff, "sealed literal diff changed")
        if packet_path.exists():
            packet = json.loads(packet_path.read_text())
            require(packet["authority"] == release_id and
                    packet["v6_source_packet"] == packet_id and
                    packet["source_diff"] == ident(diff_path) and
                    packet["normalized_top_without_moved_directive_sha256"] == normalized_sha,
                    "sealed packet binding changed")
            for item in packet["prepared_files"]:
                same_record(Path(item["path"]), item)
        print("V7_SOURCE_READ_ONLY_CHECK_PASS",
              "frozen_checks=202 copied_inputs=6 top_move=1 config_paths=5",
              "packet_sealed=" + str(packet_path.exists()).lower())


if __name__ == "__main__":
    main()
