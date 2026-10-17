#!/usr/bin/env bash
# Dormant source recipe. A later independent gate must authorize any compile/run.
set -euo pipefail
root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/c1_pipeline_stage_v2
baseline=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
hls_include=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include
model_include="$baseline/build/model-attention-rtl-repair-20261008"
if [[ $# -ne 1 || -e "$1" ]]; then
  echo 'usage: prepare_c1_cpu.sh FRESH_OUTPUT_DIR' >&2
  exit 2
fi
mkdir -- "$1"
/usr/bin/g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -frounding-math -pthread \
  -I"$hls_include" -I"$model_include" -I"$root/source" \
  "$root/source/q8_joint_tm4tn8.cpp" "$root/tb/test_c1_contract.cpp" \
  -o "$1/test_c1_contract" 2>&1 | tee "$1/compile.log"
/usr/bin/g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -frounding-math -pthread \
  -I"$hls_include" -I"$root/source" \
  "$root/tb/test_c1_write_response_model.cpp" \
  -o "$1/test_c1_write_response_model" 2>&1 | tee "$1/model_compile.log"
printf '%s\n' 'SOURCE_RECIPE_ONLY: binary execution requires a later gate' > "$1/README.txt"
