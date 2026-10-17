#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
f="$attempt/frozen"
cd "$attempt/work"
"$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd
"$bin/xvlog" "$f"/*.v
"$bin/xvlog" --sv "$f"/*.sv
"$bin/xelab" work.laya_qkv_scratch_row_v1_tb -L xil_defaultlib \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s rope_raw_local_sim
echo ROPE_RAW_LOCAL_ELAB_PASS
