#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
TB=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/offline_validation_20261009/tb
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$XBIN/xvlog" --sv -work xil_defaultlib -i "$TB" "$TB/record_boundary_probe.sv" -log xvlog.log
"$XBIN/xelab" xil_defaultlib.record_boundary_probe -s record_boundary_probe_sim -mt off -log xelab.log
"$XBIN/xsim" record_boundary_probe_sim -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'ATT_PROBE_PASS phases=4 ports=7' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)|ATT_PROBE_FAIL' xsim.log; then exit 1; fi
