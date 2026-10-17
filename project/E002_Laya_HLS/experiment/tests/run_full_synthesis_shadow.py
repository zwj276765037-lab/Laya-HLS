#!/usr/bin/env python3
"""Compile the real 13-port production top as __SYNTHESIS__ and run it."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import traceback


CASES = ("B2_S128", "accepted_gamma_failure",
         "B1_from_b0_S128", "B1_from_b1_S128")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for part in iter(lambda: stream.read(4 << 20), b""):
            digest.update(part)
    return digest.hexdigest()


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("package", type=Path)
    parser.add_argument("requests", type=Path)
    parser.add_argument("oracle", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    root, package, requests, oracle, output = (
        path.resolve() for path in (args.root, args.package, args.requests,
                                    args.oracle, args.output))
    output.mkdir(parents=True, exist_ok=True)
    report = {"status": "PREPARING", "definition": "real_13_port_synthesis_branch",
              "root": str(root), "package": str(package),
              "requests": str(requests), "oracle": str(oracle),
              "output": str(output)}
    try:
        manifest_path = package / "manifest.json"
        manifest = json.loads(manifest_path.read_text())
        source_list = root / "config/full_sources.cmake"
        sources = re.findall(r"(?m)^\s*(hls/\S+\.cpp)\s*$",
                             source_list.read_text())
        require(len(sources) == len(set(sources)) == 25,
                "exact 25 production sources")
        source_paths = [root / source for source in sources]
        require(all(path.is_file() for path in source_paths),
                "production source files present")
        oracle_report_path = oracle / "full_forward_oracle_report.json"
        oracle_report = json.loads(oracle_report_path.read_text())
        require(oracle_report["status"] ==
                "ORACLE_GENERATED_B1_B2_CONSISTENT_NO_DUT_COMPARISON" and
                set(oracle_report["runs"]) ==
                {"B2_S128", "B1_from_b0_S128", "B1_from_b1_S128"},
                "independent oracle report and three scenarios")
        oracle_files = []
        for case in (CASES[0], CASES[2], CASES[3]):
            records = {entry["name"]: entry for entry in
                       oracle_report["runs"][case]["checkpoints"]}
            require(len(records) == 47 and "final18" in records,
                    case + " 47 independent oracle records")
            path = oracle / case / "final18.f32.bin"
            entry = records["final18"]
            require(path.resolve() == Path(entry["path"]).resolve() and
                    path.stat().st_size == entry["bytes"] and
                    sha256(path) == entry["sha256"],
                    case + " independent final18 hash")
            oracle_files.append(path)
        request_files = [requests / (name + ".request.bin")
                         for name in CASES]
        require(all(path.is_file() for path in request_files),
                "four isolated rebound request files")
        package_files = [package / (name + ".bin") for name in
                         ("embedding", "w_q0", "w_q1", "w_scale", "aux")]
        package_files += [manifest_path,
                          package / "laya_model_layout_generated.h"]
        test_source = root / "tests/full_synthesis_shadow_tb.cpp"
        inputs = [source_list, test_source, Path(__file__).resolve(),
                  oracle_report_path, *source_paths, *request_files,
                  *oracle_files, *package_files]
        inputs += sorted((root / "include").glob("*.h"))
        inputs += sorted((root / "hls").rglob("*.h"))
        hashes = {str(path): sha256(path) for path in inputs}
        (output / "input_hashes.json").write_text(
            json.dumps(hashes, indent=2, sort_keys=True) + "\n")
        binary = output / "full_synthesis_shadow_tb"
        command = ["g++", "-std=c++17", "-O2", "-fno-fast-math",
                   "-ffp-contract=off", "-Wno-unknown-pragmas",
                   "-D__SYNTHESIS__", "-I" + str(root / "include"),
                   "-I" + str(root / "hls"),
                   "-I" + str(root / "hls/platform"),
                   "-I" + str(package), str(test_source),
                   *(str(path) for path in source_paths), "-o", str(binary),
                   "-lm"]
        report.update({"status": "COMPILING", "compile_command": command,
                       "source_count": len(source_paths),
                       "input_hashes_sha256": sha256(output / "input_hashes.json"),
                       "package_build_tag": manifest["tags"]["build"],
                       "compiler_version": subprocess.run(
                           ["g++", "--version"], check=True,
                           capture_output=True, text=True).stdout.splitlines()[0]})
        compile_result = subprocess.run(command, capture_output=True, text=True)
        (output / "compile.log").write_text(
            compile_result.stdout + compile_result.stderr)
        report["compile_exit_code"] = compile_result.returncode
        require(compile_result.returncode == 0,
                "production synthesis-branch host compile")
        report["binary_sha256"] = sha256(binary)
        run = [str(binary), str(package), str(requests), str(oracle),
               str(output / "frames")]
        report["run_command"] = run
        report["status"] = "RUNNING"
        run_result = subprocess.run(run, capture_output=True, text=True)
        log = run_result.stdout + run_result.stderr
        (output / "run.log").write_text(log)
        report["run_exit_code"] = run_result.returncode
        require(run_result.returncode == 0 and
                "FULL_SYNTHESIS_SHADOW_PASS calls=4 successes=3 "
                "accepted_faults=1 oracle_f32_values=72" in log and
                log.count("FULL_SYNTHESIS_SHADOW_CASE_PASS") == 4,
                "four persistent real-top cases and independent F32 oracle")
        report["result_frames"] = {
            name: sha256(output / "frames" / name / "result.bin")
            for name in CASES}
        report["final18"] = {
            name: sha256(output / "frames" / name / "final18.f32.bin")
            for name in (CASES[0], CASES[2], CASES[3])}
        report["status"] = "FULL_SYNTHESIS_SHADOW_PASS"
        print(log, end="")
    except Exception as exc:
        report["status"] = "FULL_SYNTHESIS_SHADOW_FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
        if (output / "compile.log").exists():
            print((output / "compile.log").read_text()[-3000:], file=sys.stderr)
        if (output / "run.log").exists():
            print((output / "run.log").read_text()[-3000:], file=sys.stderr)
    (output / "shadow_report.json").write_text(
        json.dumps(report, indent=2, sort_keys=True) + "\n")
    return 0 if report["status"] == "FULL_SYNTHESIS_SHADOW_PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
