#!/usr/bin/env python3
"""Bind independent S64/256/512/1024 fixtures to real typed-task results."""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys
import traceback


SHAPES = (64, 256, 512, 1024)
MATRIX_ROLES = ("source_f32", "activation_q8", "expected_f32")


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def checked_file(record: dict, path: pathlib.Path) -> None:
    require(path.resolve() == pathlib.Path(record["path"]).resolve() and
            path.stat().st_size == record["bytes"] and
            sha256(path) == record["sha256"],
            f"independent fixture bytes/hash {path}")


def main() -> int:
    if len(sys.argv) not in (6, 7):
        print("usage: full_shape_dut_test.py ROOT PACKAGE MATRIX_FIXTURE "
              "EXECUTABLE OUTPUT_DIR [SOURCE_CLOSURE_REPORT]",
              file=sys.stderr)
        return 2
    root, package, matrix, executable, output = (
        pathlib.Path(value).resolve() for value in sys.argv[1:6])
    closure = pathlib.Path(sys.argv[6]).resolve() if len(sys.argv) == 7 else None
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "PREPARING", "role": "real_typed_task_shape_tests",
                    "scope": "S64_S256_S512_S1024_task_and_address_only",
                    "not_full_network": True, "shapes": {}}
    try:
        library = executable.parent / "liblaya_full.a"
        require(executable.is_file() and library.is_file(),
                "real DUT executable and library")
        if closure is not None:
            source_closure = json.loads(closure.read_text())
            require(source_closure["status"] == "DUT_SOURCE_CLOSURE_COMPLETE" and
                    source_closure["root"] == str(root) and
                    source_closure["build"] == str(executable.parent) and
                    source_closure["model"] == str(package) and
                    source_closure["library_sha256"] == sha256(library),
                    "exact hash-bound final source closure")
            build_identity = sha256(closure)
            build_kind = "complete_compiler_dependency_closure"
        else:
            build_identity = sha256(library)
            build_kind = "archive_hash_preliminary"
        matrix_report_path = matrix / "full_matrix_fixture_report.json"
        matrix_report = json.loads(matrix_report_path.read_text())
        require(matrix_report["status"] == "GENERATED_NO_DUT_COMPARISON",
                "independent QKV full-N oracle")
        matrix_case = next(case for case in matrix_report["cases"]
                           if case["name"] == "qkv_full_b0")
        require(matrix_case["oracle_status"] ==
                "GENERATED_NO_DUT_COMPARISON", "QKV source oracle role")
        for role in MATRIX_ROLES:
            checked_file(matrix_case["files"][role],
                         matrix / f"qkv_full_b0.{role}.bin")
        fixture_root = output / "fixture"
        fixture_command = [sys.executable,
                           str(root / "tests/full_shape_fixture.py"),
                           str(root), str(package), str(fixture_root)]
        fixture_process = subprocess.run(fixture_command, cwd=root,
                                         capture_output=True, text=True,
                                         timeout=1800, check=False)
        (output / "fixture.log").write_text(
            fixture_process.stdout + fixture_process.stderr)
        require(fixture_process.returncode == 0,
                "independent shape fixture generation")
        fixture_report_path = fixture_root / "full_shape_fixture_report.json"
        fixture_report = json.loads(fixture_report_path.read_text())
        require(fixture_report["status"] == "GENERATED_NO_DUT_COMPARISON" and
                fixture_report["not_full_network"] is True and
                set(fixture_report["shapes"]) ==
                {f"S{S}" for S in SHAPES},
                "four independent supplemental shape fixtures")
        checked_file(fixture_report["qkv_native_input"],
                     fixture_root / "raw_qkv_128.f32.bin")
        report.update({
            "source_build_sha256": build_identity,
            "source_build_kind": build_kind,
            "library_sha256": sha256(library),
            "executable_sha256": sha256(executable),
            "test_source_sha256": sha256(root / "tests/full_shape_dut_tb.cpp"),
            "fixture_source_sha256": sha256(root / "tests/full_shape_fixture.py"),
            "wrapper_source_sha256": sha256(pathlib.Path(__file__)),
            "model_manifest_sha256": sha256(package / "manifest.json"),
            "model_generated_header_sha256": sha256(
                package / "laya_model_layout_generated.h"),
            "reference_source_sha256": sha256(
                root / "tests/full_reference.py"),
            "oracle_source_sha256": sha256(
                root / "tests/full_forward_oracle.py"),
            "fixture_support_source_sha256": sha256(
                root / "tests/full_fixture_test.py"),
            "matrix_fixture_report_sha256": sha256(matrix_report_path),
            "fixture_report_sha256": sha256(fixture_report_path),
            "fixture_command": fixture_command,
            "fixture_output": fixture_process.stdout,
        })
        for S in SHAPES:
            name = f"S{S}"
            record = fixture_report["shapes"][name]
            require(record["B"] == 2 and record["S"] == S and
                    record["scope"] == "typed_tasks_and_addresses_only" and
                    record["attention_head"] == 15 and
                    record["attention_rows"] == [S - 16, S - 1],
                    name + " fixture scope")
            for key, item in record["files"].items():
                suffix = {"request": "request.bin",
                          "front_raw": "front_raw.f32.bin",
                          "front_norm": "front_norm.f32.bin",
                          "front_quant": "front_quant.q8.bin",
                          "score": "score.f32.bin",
                          "prob": "prob.f32.bin",
                          "av": "av.f32.bin"}[key]
                checked_file(item, fixture_root / name / suffix)
            command = [str(executable), str(package), str(fixture_root),
                       str(matrix), str(S)]
            run = subprocess.run(command, cwd=root, capture_output=True,
                                 text=True, timeout=1800, check=False)
            combined = run.stdout + run.stderr
            (output / f"{name}.log").write_text(combined)
            require(run.returncode == 0 and
                    f"FULL_SHAPE_DUT_PASS B=2 S={S} " in combined and
                    "scope=typed_tasks_and_addresses_not_full_network" in
                    combined,
                    name + " real typed task/address run")
            report["shapes"][name] = {
                "status": "TYPED_TASK_AND_ADDRESS_PASS",
                "command": command, "exit_code": run.returncode,
                "combined_log": combined,
                "input_sha256": record["files"]["request"]["sha256"],
                "fixture_scope": record["scope"],
            }
            print(f"{name}: typed tail tasks and addresses PASS", flush=True)
        report["status"] = "DUT_FOCUSED_SHAPES_PASS"
    except Exception as exc:
        report["status"] = "DUT_FOCUSED_SHAPES_FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
    (output / "full_shape_dut_report.json").write_text(
        json.dumps(report, indent=2, sort_keys=True) + "\n")
    return 0 if report["status"] == "DUT_FOCUSED_SHAPES_PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
