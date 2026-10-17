#!/usr/bin/env bash
set -euo pipefail
a=$1
f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd
"$bin/xvlog" "$f"/*.v
sv=("$f/r0_fp_bits_pkg.sv")
for file in "$f"/*.sv;do
  [[ "$file" == "$f/r0_fp_bits_pkg.sv" ]] || sv+=("$file")
done
"$bin/xvlog" --sv "${sv[@]}"
"$bin/xelab" work.laya_staged_ln_rows_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s staged_ln_rows_sim
echo STAGED_LN_STATIC_PASS
