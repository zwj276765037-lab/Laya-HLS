#!/usr/bin/env python3
"""Exercise real frontend/decode CLIs against already verified independent inputs."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "host"))
from check_frontend import Oracle


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("binary", "oracle", "model", "assets", "reference-checks", "frozen", "output"):
        parser.add_argument("--" + name, type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    evidence = json.loads((args.reference_checks / "report.json").read_text())
    assert evidence["status"] == "PASS_FRONTEND02"
    source = args.reference_checks / "prepare_input.json"
    assert sha(source) == evidence["prepared_input_sha256"]
    env = dict(os.environ, PYTHONPATH=str(ROOT / "host"))
    common = ["--native", str(args.binary), "--gguf", str(args.model), "--assets", str(args.assets)]
    records = []
    def run(name, parameters, expected_exit):
        command = [sys.executable, "-m", "m007_deploy"] + parameters
        result = subprocess.run(command, env=env, capture_output=True, text=True)
        (args.output / (name + ".stdout.log")).write_text(result.stdout)
        (args.output / (name + ".stderr.log")).write_text(result.stderr)
        assert result.returncode == expected_exit, (name, result.returncode, result.stderr)
        records.append({"name": name, "command": command, "exit_code": result.returncode})
        return result
    prepared = args.output / "prepared"
    result = run("prepare", ["frontend-prepare", "--input", str(source), "--output-dir", str(prepared),
        "--request-id", "81985529216486895", "--generation", "9"] + common, 0)
    assert json.loads(result.stdout)["status"] == "H0_PREPARED_NO_DEVICE"
    manifest = json.loads((prepared / "manifest.json").read_text())
    cases = {item["name"]: item for item in evidence["cases"]}
    oracle = Oracle(args.oracle, args.model, args.output)
    try:
        request_data = json.loads(source.read_text())
        baseline = oracle.call({"op": "legacy-encode", **request_data})
        for index, item in enumerate(manifest["questions"]):
            folder = prepared / item["folder"]
            assert sha(folder / "H0.bin") == cases[f"frontend_H0_{index}"]["independent_reference_sha256"]
            assert np.frombuffer((folder / "token_ids.i32.bin").read_bytes(), dtype="<i4").tolist() == baseline["questions"][index]["token_ids"]
            scenario = "B1_from_b0_S128" if index == 0 else "B1_from_b1_S128"
            logits = args.frozen / scenario / "actual_logits18.bin"
            output = args.output / f"answer_{index}.json"
            run("decode_" + str(index), ["decode-answer", "--prepared", str(prepared),
                "--question-index", str(index), "--logits18", str(logits), "--output", str(output)] + common, 0)
            actual = json.loads(output.read_text())
            values = np.frombuffer(logits.read_bytes(), dtype="<f4")
            expected = oracle.call({"op": "decode", "question_id": item["question_id"],
                "question": item["question"], "candidate_u32": values[:item["candidate_count"]].view("<u4").tolist(),
                "act_u32": values[16:].view("<u4").tolist()})
            assert actual["raw"] == expected["raw"] and actual["answer"] == expected["answer"]
            assert actual["request_id"] == 81985529216486895 + index and actual["generation"] == 9
        long_input = args.output / "too_long.json"
        long_input.write_text(json.dumps({"state": " x" * 300, "questions": request_data["questions"]}))
        result = run("length_error", ["frontend-prepare", "--input", str(long_input),
            "--output-dir", str(args.output / "must_not_exist")] + common, 2)
        assert json.loads(result.stderr)["code"] == "LENGTH_ERROR"
        assert not (args.output / "must_not_exist").exists()
        invalid = args.output / "nonfinite_logits.bin"
        values = np.zeros(18, dtype="<f4"); values[17] = np.nan; invalid.write_bytes(values.tobytes())
        result = run("numeric_error", ["decode-answer", "--prepared", str(prepared),
            "--logits18", str(invalid), "--output", str(args.output / "no_answer.json")] + common, 2)
        assert json.loads(result.stderr)["code"] == "NUMERIC_ERROR"
        assert not (args.output / "no_answer.json").exists()
        result = run("device_not_run", ["device-status"], 3)
        assert json.loads(result.stdout)["status"] == "NOT_RUN"
    finally:
        oracle.close()
    report = {"status": "PASS_FRONTEND02_CLI", "commands": records,
        "native_binary_sha256": sha(args.binary), "source_json_sha256": sha(source),
        "device": "NOT_RUN", "full_forward": "NOT_RUN", "functional_stage_timing": manifest["functional_stage_timing"],
        "H0_functional_elapsed_ns": [item["reference_h0_elapsed_ns"] for item in manifest["questions"]]}
    (args.output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print("M007_FRONTEND02_CLI_PASS requests=2 H0_independent=2 business_decode_original=2 length_error=1 numeric_error=1 device_exit=3 full_forward=NOT_RUN", flush=True)


if __name__ == "__main__":
    main()
