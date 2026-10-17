#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

stage=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/encoder_decision_validation_20261009
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
build="$stage/attempts/frontend_chain_compile_01/work"
xsim=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: run_frontend_chain.sh FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
cd "$1"
if [[ -e xsim.dir || -e xsim.log ]]; then
  echo 'run directory is not fresh' >&2
  exit 2
fi
[[ -x "$build/xsim.dir/frontend_chain_static/xsimk" ]]
ln -s "$build/xsim.dir" xsim.dir
ln -s "$build/libfrontend_chain_mem.so" libfrontend_chain_mem.so
shopt -s nullglob
data=("$build"/*.dat)
[[ ${#data[@]} -gt 0 ]]
for path in "${data[@]}"; do
  ln -s "$path" "$(basename "$path")"
done
export LAYA_FRONT_PACKAGE="$base/build/model-encoder-decision-front-20261009"
export LAYA_FRONT_REQUEST="$base/build/frontend-requests-20261009/B1_from_b0_S128.request.bin"
export LAYA_FRONT_ORACLE="$base/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128"
"$xsim" frontend_chain_static -runall -onerror quit -onfinish quit \
  -log xsim.log
rg -Fq 'FRONTEND_CHAIN_RTL_COMPARE_PASS raw_f32=131072 norm_f32=131072' xsim.log
rg -Fq 'FRONTEND_CHAIN_RTL_PASS' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
  echo 'front chain log contains a failure marker' >&2
  exit 1
fi
