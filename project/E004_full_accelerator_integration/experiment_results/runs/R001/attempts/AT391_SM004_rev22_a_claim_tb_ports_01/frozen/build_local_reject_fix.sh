#!/usr/bin/env bash
set -euo pipefail
at=$1
f="$at/frozen"
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_lnq_wi_gqdown_row_v1.sv" "$f/laya_ln_only_local_reject_tb.sv"
"$bin/xelab" work.laya_ln_only_local_reject_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev20_local_reject_fix_sim
echo REV20_LOCAL_REJECT_FIX_STATIC_PASS
