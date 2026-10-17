#!/usr/bin/env bash
set -euo pipefail
attempt=$1
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
"$bin/xvlog" --sv "$attempt/frozen"/*.sv
"$bin/xelab" work.laya_qkv_rope_meta_tb -L xil_defaultlib -L unisims_ver -L xpm -L secureip --relax -mt off -s rope_meta_sim
echo ROPE_META_ELAB_PASS
