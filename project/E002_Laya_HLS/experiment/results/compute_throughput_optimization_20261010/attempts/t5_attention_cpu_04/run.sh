#!/usr/bin/env bash
set -euo pipefail
export PYTHONPATH="/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/offline_validation_20261009/tools"
python3 "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_cpu_04/frozen_source/attention_guard.py" --out "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_cpu_04/guard" --cwd "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/compute_throughput_optimization_20261010/attempts/t5_attention_cpu_04/work" --rss-gib 16 --timeout-seconds 1800 -- bash run.sh
