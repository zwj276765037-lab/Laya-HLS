#!/bin/bash
set -euo pipefail
a=$1
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xelab" work.laya_staged_ln128_pilot_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O0 -s rev21_parent_row0_mt4_sim
