#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvhdl "$at/frozen/laya_attention_fadd_lane_v2_ip.vhd"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv "$at/frozen/laya_attention_add_lane_tb.sv"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab work.laya_attention_add_lane_tb -L work -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s attention_add_sim
