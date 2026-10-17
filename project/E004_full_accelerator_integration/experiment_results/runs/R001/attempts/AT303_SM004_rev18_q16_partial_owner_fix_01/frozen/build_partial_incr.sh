#!/usr/bin/env bash
set -euo pipefail
a=$1
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$a/frozen/laya_q16_partial_owner_tb.sv"
"$bin/xelab" --incr work.laya_q16_partial_owner_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s q16_partial_owner_sim
echo Q16_PARTIAL_OLD_INCREMENTAL_STATIC_PASS
