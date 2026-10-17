#!/bin/bash
set -euo pipefail
a=$1
f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_lnq_wi_gqdown_row_v1.sv" "$f/laya_rev21_core_wprep_tb.sv"
"$bin/xelab" work.laya_rev21_core_wprep_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s rev21_core_wprep_sim
