#!/usr/bin/env python3
"""Validate and replay both independent attention fixtures on typed DUT tasks."""

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


def validate_item(root: pathlib.Path, item: dict,
                  name: str, shape: list[int], size: int) -> None:
    path = root / (name + ".bin")
    require(pathlib.Path(item["path"]).resolve() == path.resolve() and
            item["shape"] == shape and item["bytes"] == size and
            path.stat().st_size == size and sha256(path) == item["sha256"],
            f"{name}: path, shape, byte count, and SHA-256")


def main() -> int:
    if len(sys.argv) not in (7, 8):
        print("usage: full_attention_dut_test.py ROOT PACKAGE REQUEST "
              "FIXTURE_DIR EXECUTABLE OUTPUT_DIR [SOURCE_CLOSURE_REPORT]",
              file=sys.stderr)
        return 2
    root, package, request, fixture, executable, output = (
        pathlib.Path(value).resolve() for value in sys.argv[1:7])
    closure = pathlib.Path(sys.argv[7]).resolve() if len(sys.argv) == 8 else None
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {
        "status": "RUNNING",
        "role": "typed_B2_full_slide_attention_direct_DUT",
        "scope": {
            "qkv_planes": ["Q", "K", "V"], "qkv_heads": list(range(16)),
            "qkv_batches": [0, 1], "qkv_rows": list(range(128)),
            "attention_heads": [0, 1], "attention_batches": [0, 1],
            "attention_query_row0": [0, 112], "attention_rows_per_tile": 16,
            "attention_keys_per_query": 128,
            "att_out_publication": False,
            "qkv_input": "frozen_native_enc0_qkv_as_input_only",
        },
    }
    try:
        report.update(build_identity(root, package, executable, closure))
        fixture_report = fixture / "full_attention_fixture_report.json"
        oracle = json.loads(fixture_report.read_text())
        require(oracle["status"] == "GENERATED_NO_DUT_COMPARISON",
                "independent fixture generation status")
        require(oracle["case_order"] ==
                {"heads": [0, 1], "batches": [0, 1],
                 "query_row0": [0, 112], "rows": 16},
                "attention case order")
        validate_item(fixture, oracle["raw_qkv"], "raw_qkv.f32",
                      [2, 128, 3072], 2 * 128 * 3072 * 4)
        validate_item(fixture, oracle["attention_mask"],
                      "attention_mask.u8", [2, 128], 2 * 128)
        for mode, layer in (("full", 0), ("slide", 1)):
            group = oracle[mode]
            require(group["layer"] == layer, f"{mode} layer identity")
            for key, shape, count in (
                    ("cosine", [128, 64], 128 * 64),
                    ("sine", [128, 64], 128 * 64),
                    ("final_qkv", [2, 128, 3072], 2 * 128 * 3072),
                    ("score", [2, 2, 2, 16, 128], 2 * 2 * 2 * 16 * 128),
                    ("probability", [2, 2, 2, 16, 128],
                     2 * 2 * 2 * 16 * 128),
                    ("av", [2, 2, 2, 16, 64], 2 * 2 * 2 * 16 * 64)):
                validate_item(fixture, group[key], f"{mode}_{key}.f32",
                              shape, count * 4)
        runs = []
        for mode in ("full", "slide"):
            command = [str(executable), str(package), str(request),
                       str(fixture), mode,
                       "current_source_closure" if closure else "preliminary"]
            process = subprocess.run(command, cwd=root, capture_output=True,
                                     text=True, timeout=240)
            runs.append({"mode": mode, "command": command,
                         "exit_code": process.returncode,
                         "stdout": process.stdout.strip(),
                         "stderr": process.stderr.strip()})
            require(process.returncode == 0 and
                    process.stdout.startswith(
                        f"FULL_ATTENTION_DUT_PASS mode={mode} B=2 S=128 "),
                    f"{mode} direct attention DUT result")
            print(process.stdout.strip())
        report.update({
            "runs": runs,
            "fixture_report_sha256": sha256(fixture_report),
            "model_manifest_sha256": sha256(package / "manifest.json"),
            "model_generated_header_sha256": sha256(
                package / "laya_model_layout_generated.h"),
            "request_sha256": sha256(request),
            "executable_sha256": sha256(executable),
            "test_source_sha256": sha256(root / "tests/full_attention_dut_tb.cpp"),
            "fixture_source_sha256": sha256(
                root / "tests/full_attention_fixture.py"),
            "reference_source_sha256": sha256(
                root / "tests/full_reference.py"),
            "runner_source_sha256": sha256(pathlib.Path(__file__)),
            "f32_elements_compared": [
                int(run["stdout"].split("comparisons=")[1].split()[0])
                for run in runs],
            "negative_checks": [
                "duplicate_RoPE_before_rewrite", "duplicate_bank_QK_refs",
                "live_SCORE_rejects_KV_head_replacement",
                "Softmax_rejects_KV_head_ledger_mismatch",
                "AV_rejects_wrong_head"],
        })
        require([int(run["stdout"].split("negative_checks=")[1].split()[0])
                 for run in runs] == [5, 5], "all negative checks ran")
        report["status"] = ("DUT_ATTENTION_PASS" if closure else
                            "DUT_ATTENTION_PASS_PRELIMINARY_PACKAGE")
    except Exception as exc:
        report["status"] = "DUT_ATTENTION_FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
    (output / "full_attention_dut_report.json").write_text(
        json.dumps(report, indent=2) + "\n")
    return 0 if report["status"] in (
        "DUT_ATTENTION_PASS", "DUT_ATTENTION_PASS_PRELIMINARY_PACKAGE") else 1


if __name__ == "__main__":
    raise SystemExit(main())
