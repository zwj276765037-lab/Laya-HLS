#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
count=${2:-3270}
run="$attempt/${LAYA_TANH_RUN_NAME:-rtl_run}"
mkdir "$run"
ln -s "$attempt/static/xsim.dir" "$run/xsim.dir"
cd "$run"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim tanh_libm_static -runall -onerror quit -onfinish quit \
 --testplusarg "X_FILE=$attempt/fixture/x.mem" --testplusarg "GOLD_FILE=$attempt/fixture/gold.mem" --testplusarg "COUNT=$count" -log xsim.log
rg -q "TANH_LIBM_RTL_PASS count=$count" xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then exit 1; fi
