#!/bin/bash
set -euo pipefail
f=$(cd "$(dirname "$0")" && pwd)
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$f/t4_dual_w_cache_v1.sv" "$f/laya_lnq_bank_service_v1.sv" "$f/laya_w_prep_service_v1.sv" "$f/laya_lnq_wi_gqdown_row_v1.sv" "$f/laya_source_norm_service_v1.sv"
