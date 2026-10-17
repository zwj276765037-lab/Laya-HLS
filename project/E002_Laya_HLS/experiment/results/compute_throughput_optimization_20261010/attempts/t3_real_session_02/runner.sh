#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
run=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t3_real_session_02
sha256sum -c "$run/source_sha256.txt"
python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/tools/t3_real_session.py --package /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/build/model-cpu-embedding-ln-v4-20261010 --out "$run/work"
sha256sum -c "$run/source_sha256.txt"
