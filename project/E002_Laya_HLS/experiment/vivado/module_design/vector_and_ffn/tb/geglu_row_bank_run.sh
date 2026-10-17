#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
run="$attempt/bank_rtl_run"
mkdir "$run"
ln -s "$attempt/${LAYA_GEGLU_CANONICAL_STATIC_NAME:-static}/xsim.dir" "$run/xsim.dir"
cd "$run"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim geglu_row_bank_static \
 -runall -onerror quit -onfinish quit -log xsim.log
rg -q 'GEGLU_ROW_BANK_V1_PASS banks=3 words_per_bank=2624' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log;then exit 1;fi
