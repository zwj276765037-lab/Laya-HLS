#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
f="$attempt/frozen"
cd "$attempt/work"
mapfile -t rope_vhdl < <(find "$attempt/work/rope_ip" -type f -name 'rope_head_*_ip.vhd' | sort)
if (( ${#rope_vhdl[@]} != 2 )); then printf 'missing rope IP VHDL: %s\n' "${#rope_vhdl[@]}"; exit 2; fi
"$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd "${rope_vhdl[@]}"
"$bin/xvlog" "$f"/*.v
sv=("$f/r0_fp_bits_pkg.sv")
for file in "$f"/*.sv; do
  [[ "$file" == "$f/r0_fp_bits_pkg.sv" ]] || sv+=("$file")
done
"$bin/xvlog" --sv "${sv[@]}"
"$bin/xelab" work.laya_qkv_scratch_real_chain_tb -L xil_defaultlib \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s rope_raw_regression_sim
echo ROPE_FULL_ELAB_PASS
