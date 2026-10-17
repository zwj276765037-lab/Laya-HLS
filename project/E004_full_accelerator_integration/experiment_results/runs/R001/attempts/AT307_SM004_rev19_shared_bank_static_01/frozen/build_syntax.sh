#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv "$at/frozen/laya_lnq_row_v1.sv" "$at/frozen/laya_lnq_bank_service_v1.sv" "$at/frozen/laya_lnq_wi_gqdown_row_v1.sv"
echo SHARED_BANK_XVLOG_PASS
