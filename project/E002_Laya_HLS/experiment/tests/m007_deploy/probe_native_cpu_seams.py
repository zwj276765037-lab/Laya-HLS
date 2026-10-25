#!/usr/bin/env python3
"""Bounded host object-compile diagnostic for existing strict CPU reuse seams.

No object is linked or run, no numeric gold changes, and no CPU timing inference
is made. Individual subprocess status remains explicit even if probe completes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ["hls/operators/embedding_full_compute.cpp", "hls/operators/layernorm_compute.cpp",
    "hls/operators/attention_full_compute.cpp", "hls/operators/decision_full_compute.cpp",
    "hls/operators/vector_full_compute.cpp", "hls/operators/vector_libm_bits.cpp",
    "hls/operators/activation_quantizer_compute.cpp", "hls/operators/q8_linear_compute.cpp",
    "hls/common/laya_numeric.cpp"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args(); args.output.mkdir(parents=True, exist_ok=True)
    records = []
    for index, name in enumerate(SOURCES):
        source = ROOT / name
        command = ["c++", "-std=c++17", "-O2", "-fno-fast-math", "-ffp-contract=off",
                   "-I" + str(ROOT / "include"), "-c", str(source), "-o", str(args.output / f"seam_{index}.o")]
        began = time.perf_counter()
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
        (args.output / f"seam_{index}.stdout.log").write_text(result.stdout)
        (args.output / f"seam_{index}.stderr.log").write_text(result.stderr)
        records.append({"source": name, "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            "command": command, "exit_code": result.returncode,
            "status": "HOST_OBJECT_COMPILED" if result.returncode == 0 else "HOST_COMPILE_FAILED",
            "elapsed_s": time.perf_counter() - began})
    report = {"status": "DIAGNOSTIC_COMPLETE", "results": records,
        "host_objects_compiled": sum(item["exit_code"] == 0 for item in records),
        "source_count": len(records), "linked": False, "executed": False,
        "numerical_equivalence": "NOT_RUN", "CPU_performance": "NOT_RUN"}
    (args.output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"M007_NATIVE_CPU_SEAMS_DIAGNOSTIC_COMPLETE host_objects={report['host_objects_compiled']}/{len(records)} link=NOT_RUN numeric=NOT_RUN performance=NOT_RUN", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
