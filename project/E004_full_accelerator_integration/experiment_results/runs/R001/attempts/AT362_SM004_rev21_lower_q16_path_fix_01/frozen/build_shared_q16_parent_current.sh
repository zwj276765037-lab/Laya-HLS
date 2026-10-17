#!/usr/bin/env bash
set -euo pipefail
at=$1
f="$at/frozen"
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_lnq_bank_service_v1.sv" "$f/laya_source_norm_service_v1.sv" "$f/laya_lnq_wi_gqdown_row_v1.sv" "$f/laya_qkv_scratch_row_v1.sv" "$f/laya_qkv_s128_request_v1.sv" "$f/laya_staged_ln128_pilot_tb.sv"
"$bin/xelab" work.laya_staged_ln128_pilot_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev19_current_parent_row0_sim
echo REV19_CURRENT_PARENT_ROW0_STATIC_PASS
