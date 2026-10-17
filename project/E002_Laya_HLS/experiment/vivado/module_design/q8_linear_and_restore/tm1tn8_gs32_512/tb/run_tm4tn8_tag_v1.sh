#!/usr/bin/env bash
set -euo pipefail

module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: run_tm4tn8_tag_v1.sh FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
cd "$1"
if [[ -e xsim.dir || -e xvlog.log || -e xelab.log || -e xsim.log ]]; then
  echo 'run directory is not fresh' >&2
  exit 2
fi
"$xbin/xvlog" --sv -work xil_defaultlib \
  "$module/rtl/tm4tn8_tag_v1.sv" \
  "$module/tb/tm4tn8_tag_v1_tb.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.tm4tn8_tag_v1_tb \
  --relax -mt off -s tm4tn8_tag_v1_sim -log xelab.log
"$xbin/xsim" tm4tn8_tag_v1_sim -runall -onerror quit -onfinish quit \
  -log xsim.log
rg -Fq 'TM4TN8_TAG_V1_PASS cases=64' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
  exit 1
fi
