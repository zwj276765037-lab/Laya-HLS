#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
guard="$attempt/frozen_source/tanh_libm_guard.py"
python3 "$guard" --out "$attempt/guard_cpu_01" --cwd "$attempt" --rss-gib 16 --timeout-seconds 1800 -- \
 bash "$attempt/frozen_source/tanh_libm_canonical_cpu.sh" "$attempt"
python3 "$guard" --out "$attempt/guard_static_01" --cwd "$attempt" --rss-gib 24 --timeout-seconds 1800 -- \
 bash "$attempt/frozen_source/tanh_libm_canonical_build.sh" "$attempt"
python3 "$guard" --out "$attempt/guard_helper_rtl_01" --cwd "$attempt" --rss-gib 8 --timeout-seconds 3600 -- \
 env LAYA_CANONICAL_RUN_NAME=helper_rtl_run bash "$attempt/frozen_source/tanh_libm_canonical_run.sh" "$attempt" helper
python3 "$guard" --out "$attempt/guard_pilot_01" --cwd "$attempt" --rss-gib 8 --timeout-seconds 120 -- \
 env LAYA_CANONICAL_RUN_NAME=pilot bash "$attempt/frozen_source/tanh_libm_canonical_run.sh" "$attempt" pilot
python3 "$guard" --out "$attempt/guard_rtl_01" --cwd "$attempt" --rss-gib 8 --timeout-seconds 3600 -- \
 bash "$attempt/frozen_source/tanh_libm_canonical_run.sh" "$attempt" full
