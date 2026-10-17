#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim scratch_local_sim -runall -onerror quit -onfinish quit -log xsim_full.log
rg -Fq 'SCRATCH_LOCAL_PEER_PASS' xsim_full.log
rg -Fq 'SCRATCH_LOCAL_COVERAGE' xsim_full.log
! rg -i 'fatal|error:' xsim_full.log
