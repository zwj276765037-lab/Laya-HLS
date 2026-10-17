#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
pilot=${2:-0}
run="$attempt/${LAYA_GEGLU_RUN_NAME:-rtl_run}"
mkdir "$run"
ln -s "$attempt/static/xsim.dir" "$run/xsim.dir"
cd "$run"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim geglu_libm_static -runall -onerror quit -onfinish quit \
 --testplusarg "WI_FILE=$attempt/fixture/wi.mem" --testplusarg "STEP_FILE=$attempt/fixture/steps.mem" --testplusarg "PILOT=$pilot" -log xsim.log
if [[ $pilot == 1 ]]; then rg -q 'GEGLU_ROW_PILOT_PASS complete_inputs=5248 checked_outputs=128 checked_steps=1280' xsim.log
else rg -q 'GEGLU_ROW_RTL_PASS full_profiles=2' xsim.log; fi
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then exit 1; fi
