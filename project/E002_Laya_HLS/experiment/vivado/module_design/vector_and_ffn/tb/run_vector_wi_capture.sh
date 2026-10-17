#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 3 || ! -x "$1" || ! -f "$2/source_manifest.json" || ! -d "$3" ]]; then
  echo 'usage: run_vector_wi_capture.sh BUILT_BINARY PREPARED_SOURCE_DIR FRESH_WORK_DIR' >&2
  exit 2
fi
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
binary=$(realpath "$1")
prepared=$(realpath "$2")
work=$(realpath "$3")
[[ ! -e "$work/generated" && ! -e "$work/capture" ]]
cp -a "$prepared" "$work/generated"
mkdir "$work/capture"
cd "$base"
export LAYA_VECTOR_CAPTURE_ROOT="$work/capture"
export LAYA_FULL_HLS_PACKAGE="$base/build/model-cpu-embedding-ln-v4-20261010"
export LAYA_FULL_HLS_INPUT_ROOT="$base/build/cpu-embedding-requests-v4-20261010"
export LAYA_FULL_HLS_ORACLE_ROOT="$base/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle"
export LAYA_CPU_STAGE="$base/results/cpu_embedding_q8_validation_20261010"
export LAYA_CPU_RAW_ATTEMPT_SUFFIX=03
"$binary"
[[ -f "$work/capture/vector_enc0_wi_row0.f32.bin" ]]
[[ $(stat -c %s "$work/capture/vector_enc0_wi_row0.f32.bin") -eq 20992 ]]
echo 'VECTOR_WI_CAPTURE_RUN_PASS'
