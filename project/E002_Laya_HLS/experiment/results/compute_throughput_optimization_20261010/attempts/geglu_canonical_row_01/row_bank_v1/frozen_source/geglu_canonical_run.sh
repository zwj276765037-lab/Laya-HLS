#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1");mode=${2:-full}
run="$attempt/${LAYA_GEGLU_CANONICAL_RUN_NAME:-rtl_run}"
mkdir "$run"
ln -s "$attempt/${LAYA_GEGLU_CANONICAL_STATIC_NAME:-static}/xsim.dir" "$run/xsim.dir"
cd "$run"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $mode == corner ]];then
 "$xbin/xsim" geglu_canonical_corner_static -runall -onerror quit -onfinish quit \
 --testplusarg "CORNER_FILE=$attempt/cpu/corners.mem" -log xsim.log
 rg -q 'GEGLU_CANONICAL_CORNER_RTL_PASS cases=441' xsim.log
else
 pilot=0
 if [[ $mode == pilot ]];then pilot=1;fi
 "$xbin/xsim" geglu_canonical_row_static -runall -onerror quit -onfinish quit \
 --testplusarg "WI_FILE=$attempt/fixture/wi.mem" --testplusarg "STEP_FILE=$attempt/fixture/steps.mem" \
 --testplusarg "PILOT=$pilot" -log xsim.log
 if [[ $mode == pilot ]];then rg -q 'GEGLU_CANONICAL_ROW_PILOT_PASS complete_wi=5248 returns=128' xsim.log
 else rg -q 'GEGLU_CANONICAL_ROW_RTL_PASS full_rows=6' xsim.log;fi
fi
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log;then exit 1;fi
