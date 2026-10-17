#!/usr/bin/env python3
"""Generate real CPU token-embedding inputs and bind four frozen requests."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SCENARIOS = ("B2_S128", "accepted_gamma_failure", "B1_from_b0_S128", "B1_from_b1_S128")


def rec(path):
    path = path.resolve()
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--stage", type=Path, required=True)
    parser.add_argument("--suffix", required=True)
    parser.add_argument("--requests", type=Path, required=True)
    args = parser.parse_args()
    package, stage, requests = args.package.resolve(), args.stage.resolve(), args.requests.resolve()
    subprocess.run([sys.executable, str(ROOT / "results/cpu_embedding_q8_validation_20261010/tools/bind_cpu_requests.py"),
                    "--package", str(package), "--input-dir", str(ROOT / "results/attention_rtl_repair_20261008/d2_cpu_full_official/dut/inputs"),
                    "--output-dir", str(requests)], check=True)
    manifest = json.loads((package / "manifest.json").read_text())
    gguf = Path(manifest["source_model"]["path"])
    report = {"schema": "laya-current-production-inputs-v1", "package": rec(package / "manifest.json"),
              "generator": rec(args.binary), "requests": rec(requests / "identity_manifest.json"),
              "gguf": manifest["source_model"], "scenarios": []}
    for scenario in SCENARIOS:
        work = stage / "attempts" / ("new_raw_" + scenario + "_" + args.suffix) / "work"
        work.mkdir(parents=True, exist_ok=False)
        request = requests / (scenario + ".request.bin")
        subprocess.run([str(args.binary.resolve()), str(gguf), str(request),
                        str(work / "raw.bin"), str(work / "state0.bin"), str(work / "io.bin")], check=True)
        frozen = ROOT / "results/cpu_embedding_q8_validation_20261010/attempts" / ("new_raw_" + scenario + "_03") / "work"
        for name in ("raw.bin", "state0.bin"):
            assert (work / name).read_bytes() == (frozen / name).read_bytes(), (scenario, name)
        current, old = bytearray((work / "io.bin").read_bytes()), bytearray((frozen / "io.bin").read_bytes())
        # Only the four model tags and the two affected CRCs are rebound.
        for start, end in ((40, 104), (20480 + 32, 20480 + 96),
                           (20480 + 148, 20480 + 152), (20480 + 156, 20480 + 160)):
            current[start:end] = old[start:end]
        assert current == old, scenario
        report["scenarios"].append({"scenario": scenario, "request": rec(request),
                                    "files": [rec(work / name) for name in ("raw.bin", "state0.bin", "io.bin")],
                                    "frozen_raw": rec(frozen / "raw.bin"),
                                    "raw_and_state0_bitwise_unchanged": True,
                                    "io_only_authorized_tags_and_crcs_changed": True})
        print("FULL_CURRENT_RAW_PASS scenario=" + scenario, flush=True)
    (requests / "raw_identity_manifest.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print("FULL_CURRENT_INPUTS_PASS requests=4 real_cpu_token_embedding=1", flush=True)


if __name__ == "__main__":
    main()
