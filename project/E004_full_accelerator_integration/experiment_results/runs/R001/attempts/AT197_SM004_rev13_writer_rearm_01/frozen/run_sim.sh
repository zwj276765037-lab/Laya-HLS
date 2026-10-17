#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim writer_rearm_sim -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'TM1TN8_AXI512_WRITER_PASS cases=9 error_drain=1 rearm=1' xsim.log
! rg -i 'fatal|error:' xsim.log
