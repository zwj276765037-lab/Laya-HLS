#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim scratch_local_sim -runall -onerror quit -onfinish quit -log xsim_flush.log -testplusarg FLUSH_ECHO_PROBE
rg -Fq "SCRATCH_FLUSH_ECHO_PASS" xsim_flush.log
! rg -i "fatal|error:" xsim_flush.log
