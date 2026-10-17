#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
run="$base/results/compute_throughput_optimization_20261010/attempts/t3_real_session_03"
cd "$base"
sha256sum -c "$run/source_sha256.txt"
python3 -m unittest discover \
  -s results/compute_throughput_optimization_20261010/tools \
  -p 't3_*test.py' -v > "$run/unit.log" 2>&1
python3 "$base/results/compute_throughput_optimization_20261010/tools/t3_real_session.py" \
  --package "$base/build/model-cpu-embedding-ln-v4-20261010" \
  --out "$run/work"
sha256sum -c "$run/source_sha256.txt"
sha256sum -c "$run/frozen_sha256.txt"
rg -Fq 'Ran 15 tests' "$run/unit.log"
rg -Fq 'OK' "$run/unit.log"
