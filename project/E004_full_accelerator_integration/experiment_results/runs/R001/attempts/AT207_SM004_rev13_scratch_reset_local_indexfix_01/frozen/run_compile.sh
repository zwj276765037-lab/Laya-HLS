#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv ../frozen/tm1tn8_axi512_writer.sv ../frozen/laya_qkv_scratch_mock_core.sv ../frozen/laya_qkv_scratch_row_v1.sv ../frozen/laya_qkv_scratch_reset_tb.sv -log xvlog.log
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab work.laya_qkv_scratch_reset_tb --relax -mt off -s scratch_local_sim -log xelab.log
