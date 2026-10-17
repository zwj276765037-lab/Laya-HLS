#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

stage=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/encoder_decision_validation_20261009
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
build="$stage/attempts/front_chain_compile_02/work"
xsim=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: run_front_chain.sh FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
cd "$1"
if [[ -e xsim.dir || -e xsim.log ]]; then
  echo 'run directory is not fresh' >&2
  exit 2
fi
[[ -x "$build/xsim.dir/front_chain_static/xsimk" ]]
ln -s "$build/xsim.dir" xsim.dir
ln -s "$build/libfront_chain_mem.so" libfront_chain_mem.so
shopt -s nullglob
data=("$build"/*.dat)
[[ ${#data[@]} -eq 208 ]]
for path in "${data[@]}"; do
  ln -s "$path" "$(basename "$path")"
done
export LAYA_FRONT_PACKAGE="$base/build/model-attention-rtl-repair-20261008"
export LAYA_FRONT_REQUEST="$base/results/attention_rtl_repair_20261008/d2_cpu_full_official/dut/inputs/B2_S128.request.bin"
export LAYA_FRONT_ORACLE="$base/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B2_S128/embedding_norm.f32.bin"
"$xsim" front_chain_static -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'FRONT_CHAIN_COMPARE_PASS bytes=1048576' xsim.log
rg -Fq 'FRONT_CHAIN_RTL_PASS' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
  echo 'front chain log contains a failure marker' >&2
  exit 1
fi
