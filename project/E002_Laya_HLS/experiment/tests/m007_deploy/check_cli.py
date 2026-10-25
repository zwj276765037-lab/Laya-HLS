#!/usr/bin/env python3
"""Exercise actual CPU CLI and device NOT_RUN result with frozen expected bytes."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "host"))
from m007_deploy.cpu_contract import file_sha


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--replay", type=Path, required=True)
    parser.add_argument("--assets", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, PYTHONPATH=str(ROOT / "host"))
    device = subprocess.run([sys.executable, "-m", "m007_deploy", "device-status"],
                            env=env, capture_output=True, text=True)
    assert device.returncode == 3, "device status must return explicit NOT_RUN code"
    status = json.loads(device.stdout)
    assert status["status"] == "NOT_RUN" and status["backend"] == "device"
    print(device.stdout.strip(), flush=True)
    assets = json.loads(args.assets.read_text())
    scenario = "B1_from_b0_S128"
    source = args.replay / scenario
    output = args.output / "actual_logits18.bin"
    command = [sys.executable, "-m", "m007_deploy", "cpu-contract-tail",
               "--request", str(source / "request.bin"),
               "--identity", str(source / "identity.json"),
               "--tail", str(source / "tail.bin"),
               "--gguf", assets["model"]["path"], "--output", str(output)]
    subprocess.run(command, env=env, check=True)
    # The expected file belongs to the original independent whole-graph run.
    expected = ROOT / ("results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/" +
                       scenario + "/final18.f32.bin")
    report = json.loads((args.replay / "report.json").read_text())
    frozen = report["checked_fixtures"][str(expected)]
    assert file_sha(expected) == frozen["sha256"], "independent expected file SHA"
    assert output.read_bytes() == expected.read_bytes(), "CLI 18 logits bit mismatch"
    h0_path = args.output / "H0.bin"
    subprocess.run([sys.executable, "-m", "m007_deploy", "prepare-h0", "--token-ids",
                    str(source / "token_ids.i32.bin"), "--gguf", assets["model"]["path"],
                    "--output", str(h0_path)], env=env, check=True)
    expected_h0 = expected.with_name("embedding_norm.f32.bin")
    assert file_sha(expected_h0) == report["checked_fixtures"][str(expected_h0)]["sha256"]
    assert h0_path.read_bytes() == expected_h0.read_bytes(), "CLI H0 bit mismatch"
    print("M007_CLI_PASS cpu_contract_final18_bits=18 H0_bits=131072 device_exit=3 device=NOT_RUN", flush=True)


if __name__ == "__main__":
    main()
