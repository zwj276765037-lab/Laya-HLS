#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
count=$(( $(wc -l < "$attempt/cpu/ops_directed.mem") / 4 ))
run="$attempt/${LAYA_STREAM_HELPER_RUN_NAME:-helper_rtl_run}"
mkdir "$run"
ln -s "$attempt/${LAYA_STREAM_HELPER_STATIC_NAME:-helper_static}/xsim.dir" "$run/xsim.dir"
cd "$run"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim tanh_libm_stream_helper_static -runall -onerror quit -onfinish quit \
 --testplusarg "OPS_FILE=$attempt/cpu/ops_directed.mem" --testplusarg "OPS_COUNT=$count" -log xsim.log
rg -q "TANH_STREAM_HELPER_RTL_PASS count=$count" xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then exit 1; fi
