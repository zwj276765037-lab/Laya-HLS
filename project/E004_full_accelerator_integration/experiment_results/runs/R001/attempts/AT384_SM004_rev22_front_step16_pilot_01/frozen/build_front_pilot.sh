#!/bin/bash
set -euo pipefail
a=$1; f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/tm4tn8_sync_ps_front_v2.sv" "$f/tm4tn8_sync_ps_pilot_tb_v2.sv"
"$bin/xelab" work.tm4tn8_sync_ps_pilot_tb_v2 -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s rev22_front_pilot_sim
