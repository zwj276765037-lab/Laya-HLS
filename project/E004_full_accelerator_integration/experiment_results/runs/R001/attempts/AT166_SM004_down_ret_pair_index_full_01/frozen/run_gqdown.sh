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
if [[ "$mode" == recompile_top_tb ]]; then
  "$bin/xvlog" --sv "$f/laya_lnq_wi_gqdown_row_v1.sv" "$f/laya_lnq_wi_gqdown_row_v1_tb.sv"
  "$bin/xelab" work.laya_lnq_wi_gqdown_row_v1_tb -L xil_defaultlib \
    -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
    --relax -mt off -s gqdown_sim
  echo GQDOWN_TOP_TB_RECOMPILE_PASS
  exit 0
fi
if [[ "$mode" == pilot ]]; then
  "$bin/xsim" gqdown_sim -runall -testplusarg "FIXTURE=$attempt/fixture" -testplusarg PILOT | tee sim_stdout.log
  if rg -q 'Fatal:|ERROR:' sim_stdout.log || ! rg -q 'GQDOWN_PILOT_PASS' sim_stdout.log; then
    echo GQDOWN_PILOT_SEMANTIC_FAIL >&2
    exit 1
  fi
else
  "$bin/xsim" gqdown_sim -runall -testplusarg "FIXTURE=$attempt/fixture" | tee sim_stdout.log
  if rg -q 'Fatal:|ERROR:' sim_stdout.log || ! rg -q 'GQDOWN_FULL_PASS' sim_stdout.log; then
    echo GQDOWN_FULL_SEMANTIC_FAIL >&2
    exit 1
  fi
fi
