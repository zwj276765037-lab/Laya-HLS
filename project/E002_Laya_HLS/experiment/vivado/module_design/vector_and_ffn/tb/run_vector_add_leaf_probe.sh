#!/usr/bin/env bash
set -euo pipefail
mode=$1
attempt=$2
vivado_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
if [ "$mode" = static ]; then
  "$vivado_bin/xvlog" --sv "$attempt/frozen/laya_vector_add_leaf_probe_tb.sv" "$attempt/frozen/attention_ce_add.v" "$attempt/frozen/fsm_add.v"
  "$vivado_bin/xelab" laya_vector_add_leaf_probe_tb -s vector_add_leaf_probe -debug typical
  printf 'VECTOR_ADD_LEAF_STATIC_PASS\n'
else
  "$vivado_bin/xsim" vector_add_leaf_probe -runall -testplusarg DIRECTED_FILE="$attempt/frozen/add_directed.mem"
fi
