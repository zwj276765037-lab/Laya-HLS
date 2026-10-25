#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv "$at/frozen/laya_attention_qkv_bank_v1.sv" "$at/frozen/laya_attention_qkv_bank_local_tb.sv"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab work.laya_attention_qkv_bank_local_tb -L work -L unisims_ver -L xpm -L secureip --relax -mt 4 --O3 -s qkv_bank_sim
