#!/bin/bash
set -euo pipefail
a=$1
f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/t4_dual_w_cache_v1.sv" "$f/laya_w_prep_service_v1.sv" "$f/laya_w_prep_service_tb.sv"
"$bin/xelab" work.laya_w_prep_service_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev21_wprep_local_sim
