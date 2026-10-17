#!/bin/bash
set -euo pipefail
a=$1;f="$a/frozen";cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_lnq_bank_service_v1.sv" "$f/tm4tn8_sync_ps_front_v2.sv" "$f/laya_matrix_service_v1.sv" "$f/laya_matrix_ps_writer_ctrl_v1.sv" "$f/laya_source_norm_service_v1.sv" "$f/t4_dual_w_cache_v1.sv" "$f/laya_w_prep_service_v1.sv" "$f/laya_rev22_ln_w_q_matrix_chain_tb.sv"
"$bin/xelab" work.laya_rev22_ln_w_q_matrix_chain_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s rev22_matrix_chain_sim
