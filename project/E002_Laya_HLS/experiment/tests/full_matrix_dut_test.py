#!/usr/bin/env python3
"""Run every independently generated full-N fixture through typed P2 tasks."""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys
import time
import traceback


CASES = (
    "qkv_full_b0", "wo_full_b1", "wi_full_b0", "down_full_b1",
    "decision_qkv_full_b0", "decision_wo_full_b1",
    "decision_fc1_full_b0", "decision_fc2_full_b1",
    "scorer_fc1_full_b1", "act_fc2_n2_b0",
)


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def build_identity(root: pathlib.Path, package: pathlib.Path,
                   executable: pathlib.Path,
                   closure: pathlib.Path | None) -> dict:
    library = executable.parent / "liblaya_full.a"
    require(executable.is_file() and library.is_file(),
            "real DUT executable and library")
    library_hash = sha256(library)
    if closure is None:
        return {"source_build_sha256": library_hash,
                "source_build_kind": "archive_hash_preliminary",
                "library_sha256": library_hash,
                "package_status":
                    "preliminary_source_binding_requires_final_export"}
    source_closure = json.loads(closure.read_text())
    require(source_closure["status"] == "DUT_SOURCE_CLOSURE_COMPLETE" and
            source_closure["root"] == str(root) and
            source_closure["build"] == str(executable.parent) and
            source_closure["model"] == str(package) and
            source_closure["library_sha256"] == library_hash,
            "exact hash-bound current source closure")
    return {"source_build_sha256": sha256(closure),
            "source_build_kind": "complete_compiler_dependency_closure",
            "library_sha256": library_hash,
            "package_status": "current_source_closure_bound"}


def run(root: pathlib.Path, package: pathlib.Path,
        request: pathlib.Path, fixture: pathlib.Path,
        executable: pathlib.Path, output: pathlib.Path,
        closure: pathlib.Path | None = None) -> dict:
    report = json.loads((fixture / "full_matrix_fixture_report.json").read_text())
    require(report["status"] == "GENERATED_NO_DUT_COMPARISON" and
            report["case_count"] == 10, "independent oracle status/count")
    listed = {case["name"]: case for case in report["cases"]}
    require(set(listed) == set(CASES), "independent oracle case names")
    result: dict = {
        "status": "RUNNING",
        "role": "typed_P2_Load_Quant_Linear_full_N_physical_DUT_comparison",
        "fixture_report_sha256": sha256(fixture / "full_matrix_fixture_report.json"),
        "model_manifest_sha256": sha256(package / "manifest.json"),
        "model_generated_header_sha256": sha256(
            package / "laya_model_layout_generated.h"),
        "request_sha256": sha256(request),
        "executable_sha256": sha256(executable),
        "comparator_source_sha256": sha256(root / "tests/full_matrix_dut_tb.cpp"),
        "driver_source_sha256": sha256(pathlib.Path(__file__)),
        "test_source_sha256": sha256(root / "tests/full_matrix_dut_tb.cpp"),
        "runner_source_sha256": sha256(pathlib.Path(__file__)),
        "fixture_source_sha256": sha256(
            root / "tests/full_matrix_fixture.py"),
        "reference_source_sha256": sha256(root / "tests/full_reference.py"),
        "cases": [],
    }
    try:
        result.update(build_identity(root, package, executable, closure))
        for name in CASES:
            case = listed[name]
            for role in ("source_f32", "activation_q8", "weight_source_q8",
                         "bias_f32", "expected_f32"):
                identity = case["files"][role]
                path = pathlib.Path(identity["path"])
                require(path.resolve() ==
                        (fixture / f"{name}.{role}.bin").resolve(),
                        f"{name} {role} path identity")
                require(path.stat().st_size == identity["bytes"] and
                        sha256(path) == identity["sha256"],
                        f"{name} {role} hash identity")
            command = [str(executable), str(package), str(request),
                       str(fixture), name]
            start = time.monotonic()
            process = subprocess.run(command, cwd=root, text=True,
                                     capture_output=True, timeout=120)
            elapsed = time.monotonic() - start
            item = {
                "name": name,
                "family": case["family"],
                "layer": case["layer"],
                "batch": case["batch"],
                "row0": case["row0"],
                "rows": case["rows"],
                "K": case["K"],
                "N": case["N"],
                "elements_compared": case["rows"] * case["N"],
                "command": command,
                "exit_code": process.returncode,
                "stdout": process.stdout.strip(),
                "stderr": process.stderr.strip(),
                "seconds": round(elapsed, 3),
                "status": "DUT_PASS" if process.returncode == 0 and
                process.stdout.strip().startswith(
                    f"FULL_MATRIX_DUT_PASS case={name} ") else "DUT_FAIL",
            }
            result["cases"].append(item)
            print(f"{name}: {item['status']} ({item['elements_compared']} F32)",
                  flush=True)
            require(item["status"] == "DUT_PASS", f"{name} direct DUT result")
        result["case_count"] = len(result["cases"])
        result["total_f32_elements_compared"] = sum(
            item["elements_compared"] for item in result["cases"])
        result["status"] = ("DUT_MATRIX_PASS" if closure else
                            "DUT_MATRIX_PASS_PRELIMINARY_PACKAGE")
    except Exception as exc:
        result["status"] = "DUT_MATRIX_FAIL"
        result["error"] = f"{type(exc).__name__}: {exc}"
        result["traceback"] = traceback.format_exc()
        print(result["error"], file=sys.stderr)
    finally:
        output.mkdir(parents=True, exist_ok=True)
        (output / "full_matrix_dut_report.json").write_text(
            json.dumps(result, indent=2) + "\n")
    return result


def main() -> int:
    if len(sys.argv) not in (7, 8):
        print("usage: full_matrix_dut_test.py ROOT PACKAGE REQUEST "
              "FIXTURE_DIR EXECUTABLE OUTPUT_DIR [SOURCE_CLOSURE_REPORT]",
              file=sys.stderr)
        return 2
    root, package, request, fixture, executable, output = (
        pathlib.Path(arg).resolve() for arg in sys.argv[1:7])
    closure = pathlib.Path(sys.argv[7]).resolve() if len(sys.argv) == 8 else None
    result = run(root, package, request, fixture, executable, output, closure)
    return 0 if result["status"] in (
        "DUT_MATRIX_PASS", "DUT_MATRIX_PASS_PRELIMINARY_PACKAGE") else 1


if __name__ == "__main__":
    raise SystemExit(main())
