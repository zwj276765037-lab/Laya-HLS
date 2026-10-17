#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
f="$attempt/frozen"
cd "$attempt/work"
"$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd
"$bin/xvlog" "$f"/*.v
sv=("$f/r0_fp_bits_pkg.sv")
for file in "$f"/*.sv; do
  [[ "$file" == "$f/r0_fp_bits_pkg.sv" ]] || sv+=("$file")
done
"$bin/xvlog" --sv "${sv[@]}"
"$bin/xelab" work.laya_prepared_token_boundary_tb -L xil_defaultlib \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s prepared_token_sim
echo PREPARED_TOKEN_ELAB_PASS
