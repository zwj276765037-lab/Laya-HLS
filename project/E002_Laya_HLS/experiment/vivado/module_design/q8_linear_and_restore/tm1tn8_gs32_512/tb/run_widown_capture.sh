#!/usr/bin/env bash
set -euo pipefail

root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
if [[ $# -ne 3 || ! -f "$1" || ! -f "$2/source_manifest.json" || ! -d "$3" ]]; then
  echo 'usage: run_widown_capture.sh BUILT_BINARY PREPARED_SOURCE_DIR FRESH_WORK_DIR' >&2
  exit 2
fi
binary=$(realpath "$1")
prepared=$(realpath "$2")
work=$(realpath "$3")
[[ ! -e "$work/generated" && ! -e "$work/capture" ]]
cp -a "$prepared" "$work/generated"
mkdir "$work/capture"
cd "$root"
export LAYA_T2_CAPTURE_ROOT="$work/capture"
export LAYA_FULL_HLS_PACKAGE="$root/build/model-cpu-embedding-ln-v4-20261010"
export LAYA_FULL_HLS_INPUT_ROOT="$root/build/cpu-embedding-requests-v4-20261010"
export LAYA_FULL_HLS_ORACLE_ROOT="$root/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle"
export LAYA_CPU_STAGE="$root/results/cpu_embedding_q8_validation_20261010"
export LAYA_CPU_RAW_ATTEMPT_SUFFIX=03
exec "$binary"
