#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xvlog" --sv "$at/frozen/laya_lnq_bank_service_v1.sv" "$at/frozen/laya_lnq_wi_gqdown_row_v1.sv" "$at/frozen/laya_source_norm_service_v1.sv" "$at/frozen/laya_qkv_scratch_row_v1.sv" "$at/frozen/laya_qkv_s128_request_v1.sv" "$at/frozen/laya_staged_ln128_pilot_tb.sv"
