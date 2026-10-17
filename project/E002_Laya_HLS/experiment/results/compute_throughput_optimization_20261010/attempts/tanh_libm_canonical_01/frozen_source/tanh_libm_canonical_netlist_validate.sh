#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
guard="$attempt/frozen_source/tanh_libm_guard.py"
# Bounded assembled-netlist check: original gold, no full-domain equivalence claim.
python3 "$guard" --out "$attempt/guard_netlist_static_01" --cwd "$attempt" --rss-gib 24 --timeout-seconds 120 -- \
 bash "$attempt/frozen_source/tanh_libm_canonical_netlist_build.sh" "$attempt"
python3 "$guard" --out "$attempt/guard_netlist_rtl_01" --cwd "$attempt" --rss-gib 8 --timeout-seconds 120 -- \
 bash "$attempt/frozen_source/tanh_libm_canonical_netlist_run.sh" "$attempt"
