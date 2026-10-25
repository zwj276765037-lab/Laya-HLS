#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvhdl "$at/frozen/laya_attention_fdiv_lane_v1_ip.vhd"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv "$at/frozen/laya_attention_divider_subnormal_tb.sv"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab work.laya_attention_divider_subnormal_tb -L work -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s attention_divider_subnormal_sim
