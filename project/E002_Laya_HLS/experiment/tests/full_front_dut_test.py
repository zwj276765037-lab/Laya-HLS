#!/usr/bin/env python3
"""Hash-bound direct front-task comparison against independent GGUF outputs."""

from __future__ import annotations

import hashlib
import json
import pathlib
import subprocess
import sys
import traceback


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


def main() -> int:
    if len(sys.argv) not in (8, 9):
        print("usage: full_front_dut_test.py ROOT PACKAGE REQUEST "
              "FULL_ORACLE_REPORT TYPE_FIXTURE_DIR EXECUTABLE OUTPUT_DIR "
              "[SOURCE_CLOSURE_REPORT]",
              file=sys.stderr)
        return 2
    root, package, request, oracle_path, types_dir, executable, output = (
        pathlib.Path(value).resolve() for value in sys.argv[1:8])
    closure = pathlib.Path(sys.argv[8]).resolve() if len(sys.argv) == 9 else None
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "RUNNING",
                    "role": "typed_P2_B2_embedding_and_gamma_LN_full_graph_prefix"}
    try:
        report.update(build_identity(root, package, executable, closure))
        oracle = json.loads(oracle_path.read_text())
        require(oracle["status"] ==
                "ORACLE_GENERATED_B1_B2_CONSISTENT_NO_DUT_COMPARISON",
                "independent full graph oracle status")
        b2 = {entry["name"]: entry for entry in
              oracle["runs"]["B2_S128"]["checkpoints"]}
        expected = {}
        for name in ("embedding_raw", "embedding_norm"):
            item = b2[name]
            path = pathlib.Path(item["path"])
            require(path.resolve() ==
                    (oracle_path.parent / "B2_S128" /
                     f"{name}.f32.bin").resolve(),
                    f"{name} oracle path identity")
            require(item["shape"] == [2, 128, 1024] and
                    path.stat().st_size == item["bytes"] == 2 * 128 * 1024 * 4 and
                    sha256(path) == item["sha256"],
                    f"{name} oracle shape/bytes/hash")
            expected[name] = path
        type_report_path = types_dir / "full_front_fixture_report.json"
        type_report = json.loads(type_report_path.read_text())
        require(type_report["status"] == "GENERATED_NO_DUT_COMPARISON",
                "independent GGUF type fixture status")
        type_item = type_report["type_embedding"]
        type_path = types_dir / "type_embedding.f32.bin"
        require(pathlib.Path(type_item["path"]).resolve() ==
                type_path.resolve() and type_item["shape"] == [3, 1024] and
                type_path.stat().st_size == type_item["bytes"] == 3 * 1024 * 4 and
                sha256(type_path) == type_item["sha256"],
                "independent GGUF type shape/bytes/hash")
        command = [str(executable), str(package), str(request),
                   str(expected["embedding_raw"]),
                   str(expected["embedding_norm"]), str(type_path),
                   "current_source_closure" if closure else "preliminary"]
        process = subprocess.run(command, cwd=root, capture_output=True,
                                 text=True, timeout=120)
        report.update({
            "command": command,
            "exit_code": process.returncode,
            "stdout": process.stdout.strip(),
            "stderr": process.stderr.strip(),
            "oracle_report_sha256": sha256(oracle_path),
            "type_fixture_report_sha256": sha256(type_report_path),
            "model_manifest_sha256": sha256(package / "manifest.json"),
            "model_generated_header_sha256": sha256(
                package / "laya_model_layout_generated.h"),
            "request_sha256": sha256(request),
            "executable_sha256": sha256(executable),
            "test_source_sha256": sha256(root / "tests/full_front_dut_tb.cpp"),
            "runner_source_sha256": sha256(pathlib.Path(__file__)),
            "fixture_source_sha256": sha256(
                root / "tests/full_front_fixture.py"),
            "reference_source_sha256": sha256(
                root / "tests/full_reference.py"),
            "oracle_source_sha256": sha256(
                root / "tests/full_forward_oracle.py"),
            "f32_elements_compared": 2 * 128 * 1024 * 2 + 3 * 1024,
            "negative_checks": ["wrong_stage_producer",
                                "missing_task_source_binding",
                                "duplicate_type_row"],
        })
        require(process.returncode == 0 and process.stdout.startswith(
            "FULL_FRONT_DUT_PASS B=2 S=128 raw_f32=262144 "
            "norm_f32=262144 type_f32=3072 tasks=39"),
            "direct front DUT result")
        report["status"] = ("DUT_FRONT_PASS" if closure else
                            "DUT_FRONT_PASS_PRELIMINARY_PACKAGE")
        print(report["stdout"])
    except Exception as exc:
        report["status"] = "DUT_FRONT_FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
    (output / "full_front_dut_report.json").write_text(
        json.dumps(report, indent=2) + "\n")
    return 0 if report["status"] in (
        "DUT_FRONT_PASS", "DUT_FRONT_PASS_PRELIMINARY_PACKAGE") else 1


if __name__ == "__main__":
    raise SystemExit(main())
