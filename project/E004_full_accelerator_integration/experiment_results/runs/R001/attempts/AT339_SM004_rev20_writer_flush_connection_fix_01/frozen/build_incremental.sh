#!/usr/bin/env bash
set -euo pipefail
at=$1
work=$2
cd "$work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$at/frozen/laya_source_norm_service_v1.sv"
"$bin/xelab" work.laya_staged_ln128_pilot_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev20_norm_store_flush_fix_sim
echo REV20_NORM_STORE_FLUSH_FIX_STATIC_PASS
