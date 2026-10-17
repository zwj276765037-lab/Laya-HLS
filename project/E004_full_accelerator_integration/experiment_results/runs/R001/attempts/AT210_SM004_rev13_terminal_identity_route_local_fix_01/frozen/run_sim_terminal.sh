#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim scratch_local_sim -runall -onerror quit -onfinish quit -log xsim_terminal.log -testplusarg TERMINAL_PROBE
rg -Fq 'SCRATCH_TERMINAL_IDENTITY_PASS' xsim_terminal.log
! rg -i 'fatal|error:' xsim_terminal.log
