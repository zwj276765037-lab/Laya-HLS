#!/usr/bin/env bash
set -euo pipefail
compiled=$1
attempt=$2
cd "$compiled/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim
"$bin" switch_sim -runall -testplusarg "FIXTURE=$compiled/fixture_qkv" \
  -testplusarg "FFN_FIXTURE=$compiled/fixture_ffn" | tee "$attempt/sim_stdout.log"
if rg -q 'Fatal:|ERROR:' "$attempt/sim_stdout.log" ||
   ! rg -q 'QKV_FFN_SWITCH_PASS' "$attempt/sim_stdout.log"; then
  echo SWITCH_FULL_SEMANTIC_FAIL >&2
  exit 1
fi
