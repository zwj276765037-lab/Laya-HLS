#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$at/frozen/laya_source_norm_stage_error_tb.sv" "$at/frozen/laya_source_norm_stage_bus_tb.sv"
"$bin/xelab" work.laya_source_norm_stage_error_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev20_final_stage_error_extra_sim
"$bin/xelab" work.laya_source_norm_stage_bus_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s rev20_final_stage_bus_page_sim
