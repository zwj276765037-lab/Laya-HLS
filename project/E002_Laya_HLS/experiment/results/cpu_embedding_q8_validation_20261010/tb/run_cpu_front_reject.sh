#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
stage="$base/results/cpu_embedding_q8_validation_20261010"
build="${LAYA_FRONT_REJECT_BUILD:-$stage/attempts/cpu_front_reject_static_01/work}"
xsim=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: run_cpu_front_reject.sh FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
cd "$1"
if [[ -e xsim.dir || -e xsim.log ]]; then
  echo 'reject run directory is not fresh' >&2
  exit 2
fi
[[ -x "$build/xsim.dir/cpu_front_reject_static/xsimk" ]]
ln -s "$build/xsim.dir" xsim.dir
ln -s "$build/libcpu_front_mem.so" libcpu_front_mem.so
shopt -s nullglob
data=("$build"/*.dat)
[[ ${#data[@]} -gt 0 ]]
for path in "${data[@]}"; do
  ln -s "$path" "$(basename "$path")"
done
export LAYA_FRONT_PACKAGE="$base/build/model-cpu-embedding-ln-v4-20261010"
export LAYA_FRONT_IO="$stage/attempts/cpu_front_reject_adapter_01/work/io_bad_descriptor_crc.bin"
export LAYA_FRONT_STATE0="$stage/attempts/new_raw_B1_from_b0_S128_03/work/state0.bin"
export LAYA_FRONT_ORACLE="$base/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128"
"$xsim" cpu_front_reject_static -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'FRONTEND_REJECT_RTL_COMPARE_PASS observed_words=432 norm_bytes=0 import_words=0 reason=descriptor_crc' xsim.log
rg -Fq 'CPU_FRONT_REJECT_ADAPTER_PASS' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
  echo 'reject adapter log contains a failure marker' >&2
  exit 1
fi
