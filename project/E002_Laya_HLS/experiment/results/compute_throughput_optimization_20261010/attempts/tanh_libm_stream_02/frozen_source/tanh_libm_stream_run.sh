#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
pilot=${2:-0}
run="$attempt/${LAYA_STREAM_RUN_NAME:-rtl_run}"
mkdir "$run"
ln -s "$attempt/${LAYA_STREAM_STATIC_NAME:-static}/xsim.dir" "$run/xsim.dir"
cd "$run"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim tanh_libm_stream_static -runall -onerror quit -onfinish quit \
 --testplusarg "X_FILE=$attempt/fixture/x.mem" --testplusarg "GOLD_FILE=$attempt/fixture/gold.mem" --testplusarg "PILOT=$pilot" -log xsim.log
if [[ $pilot == 1 ]]; then rg -q 'TANH_STREAM_PILOT_PASS count=128' xsim.log
else rg -q 'TANH_STREAM_RTL_PASS count=3270 profiles=2' xsim.log; fi
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then exit 1; fi
