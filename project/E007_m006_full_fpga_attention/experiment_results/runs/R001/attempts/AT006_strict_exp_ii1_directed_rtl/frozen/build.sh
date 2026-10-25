#!/usr/bin/env bash
set -euo pipefail
at=$1;cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cp "$at/frozen"/*.dat .
"$bin/xvlog" "$at/frozen"/*.v
"$bin/xvlog" --sv "$at/frozen/attention_exp_ii1_tb.sv"
"$bin/xelab" work.attention_exp_ii1_tb -L xil_defaultlib -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s attention_exp_ii1_sim
