#!/usr/bin/env bash
set -euo pipefail
a=$1
f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd
"$bin/xvlog" "$f"/*.v
"$bin/xvlog" --sv "$f/r0_fp_bits_pkg.sv" "$f/ln_add_stream.sv" "$f"/quant16_*.sv "$f/laya_ln_row_v1.sv" "$f/laya_lnq_row_v1.sv" "$f/laya_lnq_row_v1_tb.sv" "$f/laya_lnq_direct82_tb.sv"
"$bin/xelab" work.laya_lnq_row_v1_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s lnq_legacy_row_sim
"$bin/xelab" work.laya_lnq_direct82_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s lnq_legacy_direct82_sim
echo LNQ_LEGACY_MODES_STATIC_PASS
