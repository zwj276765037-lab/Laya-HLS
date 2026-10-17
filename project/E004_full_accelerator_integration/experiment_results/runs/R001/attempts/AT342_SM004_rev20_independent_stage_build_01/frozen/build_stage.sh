#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$at/frozen/laya_source_norm_service_v1.sv" "$at/frozen/laya_source_norm_stage_tb.sv"
"$bin/xelab" work.laya_source_norm_stage_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev20_independent_stage_sim
