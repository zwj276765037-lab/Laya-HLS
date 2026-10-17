#!/usr/bin/env bash
set -euo pipefail

module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: run_axi512_writer.sh FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
cd "$1"
if [[ -e xsim.dir || -e xvlog.log || -e xelab.log || -e xsim.log ]]; then
  echo 'run directory is not fresh' >&2
  exit 2
fi
"$xbin/xvlog" --sv -work xil_defaultlib \
  "$module/rtl/tm1tn8_axi512_writer.sv" \
  "$module/tb/tm1tn8_axi512_writer_tb.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.tm1tn8_axi512_writer_tb \
  --relax -mt off -s tm1tn8_writer_sim -log xelab.log
"$xbin/xsim" tm1tn8_writer_sim -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'TM1TN8_AXI512_WRITER_PASS' xsim.log
