#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
"$bin/xvlog" --sv "$attempt/frozen/laya_g_saved_wi_direct_tb.sv"
"$bin/xelab" work.laya_g_saved_wi_direct_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s gcore_diag
echo G_SAVED_CORE_ELAB_PASS
