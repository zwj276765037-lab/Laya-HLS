#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv ../frozen/tm1tn8_axi512_writer.sv ../frozen/laya_lnq_wi_gqdown_row_v1.sv ../frozen/laya_qkv_scratch_row_v1.sv -log xvlog.log
