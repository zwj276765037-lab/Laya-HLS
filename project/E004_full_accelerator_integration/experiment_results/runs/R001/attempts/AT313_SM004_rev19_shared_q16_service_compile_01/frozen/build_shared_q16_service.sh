#!/usr/bin/env bash
set -euo pipefail
at=$1
f="$at/frozen"
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_lnq_bank_service_v1.sv" "$f/laya_shared_q16_service_tb.sv"
"$bin/xelab" work.laya_shared_q16_service_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev19_shared_q16_service_sim
echo REV19_SHARED_Q16_SERVICE_STATIC_PASS
