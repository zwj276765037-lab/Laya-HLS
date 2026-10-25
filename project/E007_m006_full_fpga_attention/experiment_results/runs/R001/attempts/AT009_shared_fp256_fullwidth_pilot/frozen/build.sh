#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvhdl "$at/frozen/tm1tn8_fmul_ip.vhd" "$at/frozen/tm1tn8_fadd_ip.vhd"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv "$at/frozen/laya_shared_fp256_v1.sv" "$at/frozen/laya_shared_fp256_full_tb.sv"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab work.laya_shared_fp256_full_tb -L work -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s shared_fp256_sim
