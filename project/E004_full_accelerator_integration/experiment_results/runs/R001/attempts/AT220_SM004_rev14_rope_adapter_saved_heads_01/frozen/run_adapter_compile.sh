#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
f="$attempt/frozen"
cd "$attempt/work"
"$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd
"$bin/xvlog" "$f"/*.v
"$bin/xvlog" --sv "$f/laya_rope_head_adapter_v1.sv" "$f/laya_rope_head_adapter_v1_tb.sv"
"$bin/xelab" work.laya_rope_head_adapter_v1_tb -L xil_defaultlib \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s rope_adapter_sim
echo ROPE_ADAPTER_ELAB_PASS
