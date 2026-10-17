#!/bin/bash
set -euo pipefail
a=$1; f="$a/frozen"
cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_lnq_bank_service_v1.sv" "$f/tm4tn8_sync_ps_front_v2.sv" "$f/laya_lnq_wi_gqdown_row_v1.sv" "$f/laya_q16_bank_window_tb.sv"
"$bin/xelab" work.laya_q16_bank_window_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s rev22_a_claim_q16_sim
