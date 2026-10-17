#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 4 || ( "$1" != byte && "$1" != wide ) ||
      ( "$2" != raw_nan && "$2" != gamma_nan && "$2" != reset_raw ) ||
      ! "$3" =~ ^fault_static_[0-9]+$ || ! -d "$4" ]]; then
  echo 'usage: front16_run_fault.sh byte|wide raw_nan|gamma_nan|reset_raw fault_static_N FRESH_DIRECTORY' >&2
  exit 2
fi
mode=$1
fault=$2
static_name=$3
run_dir=$4
[[ "$fault" != reset_raw || "$mode" == wide ]]
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$base/vivado/module_design/layernorm_engine"
build="$module/rtl/front16_$mode/$static_name"
xsim=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim
[[ -x "$build/xsim.dir/front16_fault_static/xsimk" ]]
cd "$run_dir"
[[ ! -e xsim.dir && ! -e xsim.log ]]
ln -s "$build/xsim.dir" xsim.dir
ln -s "$build/libfront16_fault_mem.so" libfront16_fault_mem.so
shopt -s nullglob
for path in "$build"/*.dat; do ln -s "$path" "$(basename "$path")"; done
manifest="${FRONT16_FIXTURE_MANIFEST:-$module/tb/front16_work/fixture_manifest.json}"
export FRONT16_STATE0=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["state0"]["path"])' "$manifest")
export FRONT16_AUX=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["aux"]["path"])' "$manifest")
export FRONT16_RAW_GOLD=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["raw_gold"]["path"])' "$manifest")
export FRONT16_NORM_GOLD=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["norm_gold"]["path"])' "$manifest")
export FRONT16_FAULT="$fault"
plus=()
if [[ "$fault" == reset_raw ]]; then plus=(--testplusarg RESET); fi
"$xsim" front16_fault_static -runall -onerror quit -onfinish quit \
  "${plus[@]}" -log xsim.log
rg -Fq 'FRONT16_FAULT_MEM_PASS' xsim.log
rg -Fq "FRONT16_FAULT_RTL_PASS mode=$mode" xsim.log
if [[ "$fault" == reset_raw ]]; then rg -Fq 'FRONT16_FAULT_RESET first_active=1' xsim.log; fi
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
  echo 'front16 fault RTL log contains failure marker' >&2
  exit 1
fi
