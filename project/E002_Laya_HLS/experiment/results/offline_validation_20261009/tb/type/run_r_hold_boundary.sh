#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
BASE=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
TB="$BASE/results/offline_validation_20261009/tb"
TYPE="$TB/type"
ENDPOINT="$BASE/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv"
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
[[ $# -eq 1 && -d "$1" ]]
cd "$1"
[[ ! -e xsim.dir && ! -e xvlog.log && ! -e xelab.log && ! -e xsim.log ]]
"$XBIN/xvlog" --sv -work xil_defaultlib -i "$TYPE" \
  "$ENDPOINT" "$TB/att_static_axi_stall.sv" \
  "$TB/att_axi_monitor.sv" "$TB/att_axi_port.sv" \
  "$TYPE/type_r_hold_selector.sv" "$TYPE/type_r_hold_boundary.sv" \
  -log xvlog.log
"$XBIN/xelab" xil_defaultlib.type_r_hold_boundary --relax -mt off \
  -s type_r_hold_boundary_sim -log xelab.log
"$XBIN/xsim" type_r_hold_boundary_sim -runall -onerror quit \
  -onfinish quit -log xsim.log
rg -Fq 'TYPE_R_BOUNDARY_PASS' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then exit 1; fi
