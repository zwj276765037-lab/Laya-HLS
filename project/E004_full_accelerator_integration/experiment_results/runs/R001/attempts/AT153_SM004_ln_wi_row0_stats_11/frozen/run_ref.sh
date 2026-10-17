#!/usr/bin/env bash
set -euo pipefail
attempt_dir="$(cd "$(dirname "$0")/.." && pwd)"
g++ -std=c++20 -O2 -fno-fast-math -ffp-contract=off -ffunction-sections \
  -fdata-sections -Wl,--gc-sections -I "$attempt_dir/frozen/include" \
  "$attempt_dir/frozen/laya_ln_wi_row0_stats_ref.cpp" \
  "$attempt_dir/frozen/layernorm_compute.cpp" \
  "$attempt_dir/frozen/laya_numeric.cpp" \
  -o "$attempt_dir/work/ln_wi_row0_stats_ref"
"$attempt_dir/work/ln_wi_row0_stats_ref" \
  "$attempt_dir/frozen/ln_source_row0.hex" \
  "$attempt_dir/frozen/ln_gold_row0.hex"
