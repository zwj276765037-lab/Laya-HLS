#!/usr/bin/env bash
set -euo pipefail
module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 1 || ! -d "$1" || -n "$(find "$1" -mindepth 1 -print -quit)" ]]; then
  echo 'usage: run_trace_axi32.sh FRESH_EXISTING_WORK_DIRECTORY' >&2
  exit 2
fi
cd "$1"
"$xbin/xvlog" --sv -work xil_defaultlib \
  "$module/rtl/tm1tn8_trace_axi32_writer.sv" \
  "$module/tb/tm1tn8_trace_axi32_writer_tb.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.tm1tn8_trace_axi32_writer_tb \
  --relax -mt off -s tm1tn8_trace_axi32_sim -log xelab.log
"$xbin/xsim" tm1tn8_trace_axi32_sim -runall -onerror quit -onfinish quit -log xsim.log
rg -q 'TM1TN8_TRACE_AXI32_PASS aw=8 w=8 b=8' xsim.log
