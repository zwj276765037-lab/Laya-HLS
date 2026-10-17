#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

if [[ $# -ne 3 || ( "$1" != byte && "$1" != wide ) ||
      ( "$2" != normal && "$2" != pressure ) || ! -d "$3" ]]; then
  echo 'usage: front16_run_rtl.sh byte|wide normal|pressure FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
mode=$1
profile=$2
run_dir=$3
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$base/vivado/module_design/layernorm_engine"
build="$module/rtl/front16_$mode/${FRONT16_STATIC_NAME:-static}"
xsim=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim
[[ -x "$build/xsim.dir/front16_static/xsimk" ]]
cd "$run_dir"
[[ ! -e xsim.dir && ! -e xsim.log ]]
ln -s "$build/xsim.dir" xsim.dir
ln -s "$build/libfront16_mem.so" libfront16_mem.so
shopt -s nullglob
for path in "$build"/*.dat; do ln -s "$path" "$(basename "$path")"; done

manifest="${FRONT16_FIXTURE_MANIFEST:-$module/tb/front16_work/fixture_manifest.json}"
export FRONT16_STATE0=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["state0"]["path"])' "$manifest")
export FRONT16_AUX=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["aux"]["path"])' "$manifest")
export FRONT16_RAW_GOLD=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["raw_gold"]["path"])' "$manifest")
export FRONT16_NORM_GOLD=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["norm_gold"]["path"])' "$manifest")
plus=()
if [[ "$profile" == pressure ]]; then plus=(+PRESSURE); fi
"$xsim" front16_static -runall -onerror quit -onfinish quit \
  "${plus[@]}" -log xsim.log
rg -Fq 'FRONT16_MEM_PASS raw_f32=16384 norm_f32=16384' xsim.log
rg -Fq "FRONT16_RTL_PASS mode=$mode" xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
  echo 'front16 RTL log contains failure marker' >&2
  exit 1
fi
