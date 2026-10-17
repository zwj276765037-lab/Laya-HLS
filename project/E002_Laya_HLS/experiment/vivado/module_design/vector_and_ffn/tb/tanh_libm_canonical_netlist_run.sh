#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1");run="$attempt/netlist_run"
mkdir "$run";ln -s "$attempt/netlist_static/xsim.dir" "$run/xsim.dir";cd "$run"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$xbin/xsim" tanh_libm_canonical_netlist_static -runall -onerror quit -onfinish quit \
 --testplusarg "X_FILE=$attempt/fixture/x.mem" --testplusarg "GOLD_FILE=$attempt/fixture/gold.mem" -log xsim.log
rg -q 'TANH_LIBM_CANONICAL_NETLIST_PASS selected_fixture=128 profiles=2 original_gold_unchanged=1' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log;then exit 1;fi
