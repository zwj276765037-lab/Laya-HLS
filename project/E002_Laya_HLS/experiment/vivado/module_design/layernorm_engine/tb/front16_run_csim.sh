#!/usr/bin/env bash
set -euo pipefail

base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$base/vivado/module_design/layernorm_engine"
work="$module/tb/front16_work"
mkdir -p "$work"
python3 "$module/tb/front16_fixture.py" "$work/fixture_manifest.json" > "$work/fixture_stdout.json"

vitis=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include
g++ -O2 -std=c++17 -fno-fast-math -ffp-contract=off \
  -I"$vitis" -I"$base/include" -I"$module/source" \
  "$module/source/front16.cpp" \
  "$base/hls/operators/layernorm_compute.cpp" \
  "$base/hls/common/laya_numeric.cpp" \
  "$module/tb/front16_csim.cpp" -o "$work/front16_csim" \
  > "$work/compile.log" 2>&1

state0=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["state0"]["path"])' "$work/fixture_manifest.json")
aux=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["aux"]["path"])' "$work/fixture_manifest.json")
raw=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["raw_gold"]["path"])' "$work/fixture_manifest.json")
norm=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["inputs"]["norm_gold"]["path"])' "$work/fixture_manifest.json")
"$work/front16_csim" "$state0" "$aux" "$raw" "$norm" | tee "$work/run.log"
sha256sum "$module/source/front16.h" "$module/source/front16.cpp" \
  "$module/tb/front16_csim.cpp" "$module/tb/front16_fixture.py" \
  "$base/hls/operators/layernorm_compute.cpp" "$base/hls/common/laya_numeric.cpp" \
  > "$work/source_sha256.txt"
