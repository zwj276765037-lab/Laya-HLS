#!/usr/bin/env python3
"""Bind P2 CPU acceptance to the current model, source closure and reports."""

from __future__ import annotations

import hashlib
import json
import pathlib
import re
import sys
import traceback


def require(ok: bool, reason: str) -> None:
    if not ok:
        raise AssertionError(reason)


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def checked_report(path: pathlib.Path, status: str) -> dict:
    report = json.loads(path.read_text())
    require(report["status"] == status, f"{path.name}: {status}")
    return report


def require_hashes(report: dict, expected: dict[str, pathlib.Path],
                   label: str) -> None:
    for field, path in expected.items():
        require(report.get(field) == sha256(path),
                f"{label}: current {field} ({path})")


def require_build_binding(report: dict, closure_sha: str,
                          library_sha: str, manifest_sha: str,
                          header_sha: str, label: str) -> None:
    require(report.get("source_build_sha256") == closure_sha and
            report.get("source_build_kind") ==
                "complete_compiler_dependency_closure" and
            report.get("library_sha256") == library_sha and
            report.get("model_manifest_sha256") == manifest_sha and
            report.get("model_generated_header_sha256") == header_sha,
            f"{label}: current complete DUT/model build binding")


def main() -> int:
    if len(sys.argv) != 5:
        print("usage: full_final_gate.py ROOT BUILD MODEL RESULT_DIR", file=sys.stderr)
        return 2
    root, build, model, output = (
        pathlib.Path(value).resolve() for value in sys.argv[1:])
    result_path = output / "full_final_gate_report.json"
    result: dict = {"status": "CHECKING", "scope": "current_P2_F0_CPU_functional_gate"}
    try:
        registry_path = root / "config/full_module_registry.json"
        registry = json.loads(registry_path.read_text())
        require(registry["schema"] == "laya_p2_f0_module_registry_v1" and
                registry["target"] == "laya_full" and
                registry["top"] == "laya_typed_q8_forward" and
                registry["implementation_state"] ==
                "implemented_pending_final_validation" and
                len(registry["modules"]) == 15,
                "P2 15-module implementation registry")
        sources = set(re.findall(r"(?m)^\s*(hls/\S+\.cpp)\s*$",
                                 (root / "config/full_sources.cmake").read_text()))
        mapped = {path for paths in registry["modules"].values()
                  for path in paths}
        require(len(sources) == 27 and mapped == sources and
                all((root / source).is_file() for source in sources),
                "registry exactly covers all current production sources")

        package_path = model / "manifest.json"
        package = json.loads(package_path.read_text())
        tags = package["tags"]
        require(set(tags) == {"model", "numeric", "layout", "build"} and
                all(isinstance(value, str) and len(value) == 32 and
                    value != "0" * 32 for value in tags.values()),
                "four nonzero model identity tags")
        build_preimage = json.loads((model /
            package["tag_preimages"]["build"]["file"]).read_text())
        require(any(item["path"] == "config/full_module_registry.json" and
                    item["sha256"] == sha256(registry_path)
                    for item in build_preimage["sources"]),
                "current P2 registry participates in build tag")
        package_report = checked_report(
            output / "model_package/full_model_package_report.json",
            "MODEL_PACKAGE_PASS")
        require(package_report["strict_current_sources"] is True and
                not package_report["build_sources_stale"] and
                package_report["manifest_sha256"] == sha256(package_path),
                "model package matches all current tagged sources")

        closure_path = output / "source_closure/full_source_closure_report.json"
        closure = checked_report(closure_path, "DUT_SOURCE_CLOSURE_COMPLETE")
        require(closure["root"] == str(root) and closure["build"] == str(build)
                and closure["model"] == str(model) and
                set(closure["compiled_sources"]) == sources and
                closure["library_sha256"] == sha256(build / "liblaya_full.a")
                and closure["cmake_lists_sha256"] == sha256(root / "CMakeLists.txt")
                and closure["cmake_source_list_sha256"] ==
                    sha256(root / "config/full_sources.cmake") and
                closure["compile_database_sha256"] ==
                    sha256(build / "compile_commands.json"),
                "exact current compiled DUT and build configuration")
        for name, entry in closure["compiled_sources"].items():
            require(entry["source_sha256"] == sha256(root / name) and
                    entry["object_sha256"] == sha256(pathlib.Path(entry["object"])),
                    f"current compiled source/object {name}")
        for name, recorded in closure["project_dependency_sha256"].items():
            require(sha256(pathlib.Path(name)) == recorded,
                    f"current project dependency {name}")

        request_path = (root / "reference/runs/typed_q8_ref_20261005/"
                        "abi_replay/request_v1.bin")
        header_path = model / "laya_model_layout_generated.h"
        manifest_sha = sha256(package_path)
        header_sha = sha256(header_path)
        closure_sha = sha256(closure_path)
        library_sha = closure["library_sha256"]
        fixture_paths = {
            name: output / f"{name}_fixture/full_{name}_fixture_report.json"
            for name in ("front", "matrix", "attention")
        }
        oracle_path = output / "oracle/full_forward_oracle_report.json"
        checked_report(output / "numeric_fixture/full_fixture_report.json", "PASS")
        checked_report(oracle_path,
                       "ORACLE_GENERATED_B1_B2_CONSISTENT_NO_DUT_COMPARISON")
        for name in ("front", "matrix", "attention"):
            checked_report(fixture_paths[name], "GENERATED_NO_DUT_COMPARISON")
            report = checked_report(
                output / f"{name}_dut/full_{name}_dut_report.json",
                f"DUT_{name.upper()}_PASS")
            require_build_binding(report, closure_sha, library_sha,
                                  manifest_sha, header_sha, name)
            require(report.get("package_status") ==
                    "current_source_closure_bound", name + " package status")
            common = {
                "executable_sha256": build / f"full_{name}_dut",
                "test_source_sha256": root / f"tests/full_{name}_dut_tb.cpp",
                "runner_source_sha256": root / f"tests/full_{name}_dut_test.py",
                "fixture_source_sha256": root / f"tests/full_{name}_fixture.py",
                "reference_source_sha256": root / "tests/full_reference.py",
                "request_sha256": request_path,
            }
            if name == "front":
                common.update({
                    "type_fixture_report_sha256": fixture_paths[name],
                    "oracle_report_sha256": oracle_path,
                    "oracle_source_sha256":
                        root / "tests/full_forward_oracle.py",
                })
                require(report.get("exit_code") == 0 and
                        report.get("f32_elements_compared") == 527360,
                        "front direct task comparison")
            else:
                common["fixture_report_sha256"] = fixture_paths[name]
            require_hashes(report, common, name)
            if name == "matrix":
                require(report.get("case_count") == 10 and
                        report.get("total_f32_elements_compared") == 329730 and
                        len(report.get("cases", [])) == 10 and
                        all(case.get("status") == "DUT_PASS" and
                            case.get("exit_code") == 0
                            for case in report["cases"]),
                        "ten direct full-N matrix cases")
            if name == "attention":
                require(len(report.get("runs", [])) == 2 and
                        all(run.get("exit_code") == 0 for run in report["runs"])
                        and report.get("f32_elements_compared") ==
                        [1622016, 1622016],
                        "both direct attention modes")
        shape = checked_report(output / "shape_dut/full_shape_dut_report.json",
                               "DUT_FOCUSED_SHAPES_PASS")
        require_build_binding(shape, closure_sha, library_sha,
                              manifest_sha, header_sha, "shape")
        require_hashes(shape, {
            "executable_sha256": build / "full_shape_dut_tb",
            "test_source_sha256": root / "tests/full_shape_dut_tb.cpp",
            "wrapper_source_sha256": root / "tests/full_shape_dut_test.py",
            "fixture_source_sha256": root / "tests/full_shape_fixture.py",
            "reference_source_sha256": root / "tests/full_reference.py",
            "oracle_source_sha256": root / "tests/full_forward_oracle.py",
            "fixture_support_source_sha256": root / "tests/full_fixture_test.py",
            "matrix_fixture_report_sha256": fixture_paths["matrix"],
            "fixture_report_sha256":
                output / "shape_dut/fixture/full_shape_fixture_report.json",
        }, "shape")
        require(set(shape["shapes"]) == {"S64", "S256", "S512", "S1024"}
                and all(one["status"] == "TYPED_TASK_AND_ADDRESS_PASS" and
                        one["exit_code"] == 0
                        for one in shape["shapes"].values()),
                "four supplemental typed task/address shape checks")

        runner = checked_report(output / "dut/full_forward_dut_run_report.json",
                                "DUT_FORWARD_DUMPS_COMPLETE")
        comparison = checked_report(
            output / "compare/full_forward_dut_compare_report.json",
            "DUT_FORWARD_141_CHECKPOINT_BITWISE_PASS")
        scenarios = {"B2_S128", "B1_from_b0_S128", "B1_from_b1_S128"}
        build_hash = closure_sha
        require(runner["model_manifest_sha256"] == manifest_sha and
                runner["source_build_sha256"] == build_hash and
                runner["source_build_kind"] ==
                    "complete_compiler_dependency_closure" and
                runner["library_sha256"] == library_sha and
                set(runner["runs"]) == scenarios and
                runner.get("exit_code") == 0 and
                runner.get("run_session_id"),
                "same-build persistent success/fault/recovery run")
        require_hashes(runner, {
            "model_aux_original_sha256": model / "aux.bin",
            "design_count_table_sha256": root / "results/p2_environment_20261007/"
                "f0_expected_task_counts_s128.json",
            "frozen_request_sha256": request_path,
            "executable_sha256": build / "full_forward_dut_runner",
            "runner_source_sha256": root / "tests/full_forward_dut_runner.cpp",
            "wrapper_source_sha256": root / "tests/full_forward_dut_run.py",
        }, "persistent runner")
        require_hashes(comparison, {
            "oracle_report_sha256": oracle_path,
            "comparator_sha256": root / "tests/full_forward_dut_compare.py",
        }, "full comparison")
        require(comparison["model_manifest_sha256"] == manifest_sha and
                comparison["source_build_sha256"] == build_hash and
                comparison["run_session_id"] == runner["run_session_id"] and
                comparison["checkpoint_count"] == 141 and
                set(comparison["runs"]) == scenarios and
                all(one["status"] == "BITWISE_PASS" and
                    one["checkpoint_count"] == 47
                    for one in comparison["runs"].values()),
                "all 141 exact full-graph checkpoints and shared session")
        for name in scenarios:
            one = runner["runs"][name]
            checked_path = output / "dut/dut" / name / "metadata.json"
            compare_one = comparison["runs"][name]
            metadata = json.loads(checked_path.read_text())
            require(pathlib.Path(one["metadata_path"]).resolve() ==
                    checked_path.resolve() and
                    one["metadata_sha256"] == compare_one["metadata_sha256"] ==
                    sha256(checked_path) and
                    metadata["source_build_sha256"] == build_hash and
                    metadata["source_build_kind"] ==
                        "complete_compiler_dependency_closure" and
                    metadata["run_session_id"] == runner["run_session_id"] and
                    metadata["tags"] == tags and
                    one["checkpoint_count"] == 47 and
                    metadata["input_sha256"] ==
                        runner["inputs"][name]["sha256"] and
                    pathlib.Path(runner["inputs"][name]["path"]).resolve() ==
                        (output / "dut/inputs" / f"{name}.request.bin").resolve()
                    and
                    sha256(pathlib.Path(runner["inputs"][name]["path"])) ==
                        metadata["input_sha256"],
                    f"{name}: same current run, request and 47 checkpoints")
        fault_path = output / "dut/dut/accepted_gamma_failure/metadata.json"
        fault_frame_path = fault_path.parent / "result.bin"
        fault = json.loads(fault_path.read_text())
        fault_run = runner["accepted_failure"]
        fault_compare = comparison["accepted_failure"]
        observed = fault["observed_error_result"]
        mutation = fault["mutation"]
        require(pathlib.Path(fault_run["metadata_path"]).resolve() ==
                fault_path.resolve() and
                fault_run["metadata_sha256"] ==
                    fault_compare["metadata_sha256"] == sha256(fault_path) and
                fault_run["result_frame_sha256"] ==
                    fault_compare["result_frame_sha256"] ==
                    fault["result_frame_sha256"] == sha256(fault_frame_path) and
                fault["status"] ==
                    "ACCEPTED_IN_GRAPH_NUMERICAL_FAILURE_OBSERVED" and
                fault_compare["status"] == "ACCEPTED_FAILURE_RECOVERED" and
                fault["request_id"] == fault_compare["request_id"] == 2 and
                fault["source_build_sha256"] == build_hash and
                fault["source_build_kind"] ==
                    "complete_compiler_dependency_closure" and
                fault["run_session_id"] == runner["run_session_id"] and
                fault["model_aux_original_sha256"] == sha256(model / "aux.bin")
                and fault["input_sha256"] ==
                    runner["inputs"]["accepted_gamma_failure"]["sha256"] and
                pathlib.Path(runner["inputs"]["accepted_gamma_failure"]
                             ["path"]).resolve() ==
                    (output / "dut/inputs/accepted_gamma_failure.request.bin")
                    .resolve() and
                sha256(pathlib.Path(runner["inputs"]["accepted_gamma_failure"]
                                    ["path"])) == fault["input_sha256"] and
                mutation["restored_before_next_request"] is True and
                mutation["entire_aux_memory_restored_bit_identical"] is True and
                mutation["package_file_unchanged"] is True and
                observed["status"] == 6 and observed["flags"] == 9 and
                observed["error_stage"] == 1 and
                observed["error_op"] == 0x82 and
                observed["error_detail"] == ((7 << 24) | (0x82 << 16) | 15)
                and observed["tasks_retired"] == 17 and
                observed["accepted_input_elements"] == 578 and
                observed["committed_output_elements"] == 0 and
                observed["output_payload_all_zero"] is True and
                fault_run["observed_error_result"] == observed and
                fault_compare["post_runtime"] == fault["post_runtime"] and
                fault["pre_runtime"] == runner["runs"]["B2_S128"]
                    ["post_runtime"] and
                fault["post_runtime"] == runner["runs"]["B1_from_b0_S128"]
                    ["pre_runtime"] and
                runner["runs"]["B1_from_b0_S128"]["post_runtime"] ==
                    runner["runs"]["B1_from_b1_S128"]["pre_runtime"],
                "accepted gamma failure, zero output and same-session recovery")

        phase = dict(registry["phase_baseline"])
        phase["cpu"] = "pass_current_build_141_checkpoints_with_recovery"
        result.update({
            "status": "P2_F0_CPU_FUNCTIONAL_READY_CURRENT_BUILD",
            "model_manifest_sha256": sha256(package_path),
            "tags": tags,
            "source_closure_sha256": build_hash,
            "compile_database_sha256": closure["compile_database_sha256"],
            "module_registry_sha256": sha256(registry_path),
            "phase_status": phase,
            "modules": {name: {"sources": paths, "target": registry["target"],
                               "phase_status": phase}
                        for name, paths in registry["modules"].items()},
            "checkpoint_count": 141,
            "persistent_requests": 4,
            "accepted_failure_recovered": 1,
            "supplemental_shapes": [64, 256, 512, 1024],
        })
        print("P2_F0_CPU_FUNCTIONAL_READY_CURRENT_BUILD "
              "modules=15 checkpoints=141 persistent_requests=4")
    except Exception as exc:
        result["status"] = "P2_F0_CPU_FUNCTIONAL_GATE_FAIL"
        result["error"] = f"{type(exc).__name__}: {exc}"
        result["traceback"] = traceback.format_exc()
        print(result["error"], file=sys.stderr)
    result_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    return 0 if result["status"] == \
        "P2_F0_CPU_FUNCTIONAL_READY_CURRENT_BUILD" else 1


if __name__ == "__main__":
    raise SystemExit(main())
