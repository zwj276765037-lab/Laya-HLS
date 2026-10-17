#!/usr/bin/env bash
# Dormant until the separately reviewed distinct_rows3 CPU leaf build gate.
set -euo pipefail
export LC_ALL=C

BASE=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
MODULE="$BASE/vivado/module_design/q8_linear_and_restore/metadata_reset_v3"
TB="$MODULE/rtl_full_dimensions_distinct_rows3_v1/tb"
VITIS=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis
if [[ $# -ne 1 || ! -d "$1" || -n "$(find "$1" -mindepth 1 -print -quit)" ]]; then
  echo 'usage: build_cpu_leaf.sh FRESH_EXISTING_BUILD_DIRECTORY' >&2
  exit 2
fi
common=(-std=c++17 -O2 -ffp-contract=off -fno-fast-math
  -I"$VITIS/include" -I"$BASE/include"
  -I"$BASE/build/model-attention-rtl-repair-20261008"
  -I"$MODULE/source")
nice -n 19 ionice -c 3 /usr/bin/g++ "${common[@]}" \
  -MMD -MF "$1/q8_joint_tm4tn8.d" -MT "$1/q8_joint_tm4tn8.o" \
  -c "$MODULE/source/q8_joint_tm4tn8.cpp" -o "$1/q8_joint_tm4tn8.o"
nice -n 19 ionice -c 3 /usr/bin/g++ "${common[@]}" \
  -MMD -MF "$1/test_q8_scorer_distinct_rows3.d" -MT "$1/test_q8_scorer_distinct_rows3.o" \
  -c "$TB/test_q8_scorer_distinct_rows3.cpp" -o "$1/test_q8_scorer_distinct_rows3.o"
nice -n 19 ionice -c 3 /usr/bin/g++ \
  "$1/q8_joint_tm4tn8.o" "$1/test_q8_scorer_distinct_rows3.o" \
  -lm -o "$1/test_q8_scorer_distinct_rows3"
file "$1/test_q8_scorer_distinct_rows3"
ldd "$1/test_q8_scorer_distinct_rows3"
