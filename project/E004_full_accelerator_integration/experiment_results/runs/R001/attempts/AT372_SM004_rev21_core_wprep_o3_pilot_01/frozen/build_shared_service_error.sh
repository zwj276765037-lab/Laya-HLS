#!/usr/bin/env bash
set -euo pipefail
at=$1
f="$at/frozen"
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/laya_staged_ln_error_tb.sv"
"$bin/xelab" work.laya_staged_ln_error_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev19_shared_service_error_sim
echo REV19_SHARED_SERVICE_ERROR_STATIC_PASS
