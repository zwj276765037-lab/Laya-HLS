#!/usr/bin/env bash
set -euo pipefail
a=$1
f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_qkv_scratch_row_v1.sv" "$f/laya_staged_ln_error_tb.sv"
"$bin/xelab" work.laya_staged_ln_error_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s staged_ln_error_sim
echo STAGED_LN_ERROR_STATIC_PASS
