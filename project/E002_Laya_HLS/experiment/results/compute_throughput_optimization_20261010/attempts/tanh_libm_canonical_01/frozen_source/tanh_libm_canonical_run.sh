#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
mode=${2:-full}
run="$attempt/${LAYA_CANONICAL_RUN_NAME:-rtl_run}"
mkdir "$run"
ln -s "$attempt/${LAYA_CANONICAL_STATIC_NAME:-static}/xsim.dir" "$run/xsim.dir"
cd "$run"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $mode == helper ]]; then
 "$xbin/xsim" tanh_libm_canonical_helper_static -runall -onerror quit -onfinish quit \
 --testplusarg "OPS_FILE=$attempt/fixture/ops_directed.mem" --testplusarg OPS_COUNT=1159 -log xsim.log
 rg -q 'TANH_STREAM_HELPER_RTL_PASS count=1159' xsim.log
else
 pilot=0
 if [[ $mode == pilot ]]; then pilot=1; fi
 "$xbin/xsim" tanh_libm_canonical_static -runall -onerror quit -onfinish quit \
 --testplusarg "X_FILE=$attempt/fixture/x.mem" --testplusarg "GOLD_FILE=$attempt/fixture/gold.mem" \
 --testplusarg "TRACE_FILE=$attempt/cpu/trace.mem" --testplusarg "PILOT=$pilot" -log xsim.log
 if [[ $mode == pilot ]]; then rg -q 'TANH_CANONICAL_PILOT_PASS count=128' xsim.log
 else rg -q 'TANH_CANONICAL_RTL_PASS count=3270 profiles=2' xsim.log; fi
fi
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then exit 1; fi
