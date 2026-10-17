#!/usr/bin/env bash
set -euo pipefail
attempt=$1
cd "$attempt/work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim scratch_real_sim -runall -onerror quit -onfinish quit \
  -testplusarg "FIXTURE=$attempt/fixture_qkv" \
  -testplusarg "FFN_FIXTURE=$attempt/fixture_ffn" -log xsim.log
rg -Fq 'SCRATCH_FULL_CHAIN_PASS' xsim.log
! rg -i 'fatal|error:' xsim.log
