#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim scratch_local_sim -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'SCRATCH_RESET_LOCAL_PASS' xsim.log
! rg -i 'fatal|error:' xsim.log
