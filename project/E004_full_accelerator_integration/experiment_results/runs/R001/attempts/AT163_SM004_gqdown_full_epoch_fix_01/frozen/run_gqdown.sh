#!/usr/bin/env bash
set -euo pipefail
attempt=$1
mode=${2:-pilot}
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
f="$attempt/frozen"
cd "$attempt/work"
if [[ "$mode" == compile ]]; then
  "$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd
  "$bin/xvlog" "$f"/*.v
  sv=("$f/r0_fp_bits_pkg.sv")
  for file in "$f"/*.sv; do
    [[ "$file" == "$f/r0_fp_bits_pkg.sv" ]] || sv+=("$file")
  done
  "$bin/xvlog" --sv "${sv[@]}"
  "$bin/xelab" work.laya_lnq_wi_gqdown_row_v1_tb -L xil_defaultlib \
    -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
    --relax -mt off -s gqdown_sim
  echo GQDOWN_COMPILE_PASS
  exit 0
fi
if [[ "$mode" == recompile_tb ]]; then
  "$bin/xvlog" --sv "$f/laya_lnq_wi_gqdown_row_v1_tb.sv"
  "$bin/xelab" work.laya_lnq_wi_gqdown_row_v1_tb -L xil_defaultlib \
    -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
    --relax -mt off -s gqdown_sim
  echo GQDOWN_TB_RECOMPILE_PASS
  exit 0
fi
if [[ "$mode" == pilot ]]; then
  "$bin/xsim" gqdown_sim -runall -testplusarg "FIXTURE=$attempt/fixture" -testplusarg PILOT
else
  "$bin/xsim" gqdown_sim -runall -testplusarg "FIXTURE=$attempt/fixture"
fi
