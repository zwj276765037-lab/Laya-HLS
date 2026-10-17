#!/usr/bin/env bash
set -euo pipefail
at=$1
f="$at/frozen"
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_lnq_bank_service_v1.sv" "$f/laya_lnq_wi_gqdown_row_v1.sv" "$f/laya_shared_q16_service_tb.sv"
"$bin/xelab" work.laya_staged_ln_error_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev19_lower_staged_error_sim
"$bin/xelab" work.laya_shared_q16_service_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev19_lower_staged_q16_sim
"$bin/xelab" work.laya_staged_ln_rows_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev19_lower_staged_rows_sim
echo REV19_LOWER_STAGED_STATIC_PASS
