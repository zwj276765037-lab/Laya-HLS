#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
f="$attempt/frozen"
cd "$attempt/work"
"$bin/xvhdl" -work xil_defaultlib "$f"/*.vhd
"$bin/xvlog" "$f"/*.v
"$bin/xvlog" --sv "$f"/*.sv
"$bin/xelab" work.laya_qkv_input_abort_peer_tb -L xil_defaultlib \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s input_abort_peer_sim
echo INPUT_ABORT_PEER_ELAB_PASS
