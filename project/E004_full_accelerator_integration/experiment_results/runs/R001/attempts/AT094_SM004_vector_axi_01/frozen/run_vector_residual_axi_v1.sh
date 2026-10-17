#!/usr/bin/env bash
set -euo pipefail
mode=$1
attempt=$2
vivado_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
if [ "$mode" = static ]; then
  "$vivado_bin/xvlog" --sv "$attempt/frozen/laya_vector_residual_axi_v1_tb.sv" "$attempt/frozen/laya_vector_residual_axi_v1.sv" "$attempt/frozen/laya_vector_add_stream_v1.sv" "$attempt/frozen/attention_ce_add.v"
  "$vivado_bin/xelab" laya_vector_residual_axi_v1_tb -s vector_residual_axi_v1 -mt 4
  printf 'VECTOR_RESIDUAL_AXI_STATIC_PASS\n'
else
  "$vivado_bin/xsim" vector_residual_axi_v1 -runall \
    -testplusarg A_FILE="$attempt/frozen/skip.mem" \
    -testplusarg B_FILE="$attempt/frozen/down.mem" \
    -testplusarg GOLD_FILE="$attempt/frozen/gold.mem"
fi
