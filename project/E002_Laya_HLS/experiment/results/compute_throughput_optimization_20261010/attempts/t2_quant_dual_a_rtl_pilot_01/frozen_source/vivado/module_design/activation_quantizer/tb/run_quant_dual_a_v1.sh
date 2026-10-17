#!/usr/bin/env bash
set -euo pipefail
work=$(realpath "$1")
module=$(realpath "$(dirname "$0")/..")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$work"
"$xbin/xvlog" --sv "$module/rtl/quant_a_row_bank_v1.sv" "$module/rtl/quant_dual_a_v1.sv" "$module/tb/quant_dual_a_tb_v1.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.quant_dual_a_tb_v1 -s quant_dual_a -mt off -log xelab.log
"$xbin/xsim" quant_dual_a -runall -onerror quit -onfinish quit -log simulate.log
rg -q QUANT_DUAL_A_FULL_PASS simulate.log
if rg -q 'Fatal:|ERROR:' simulate.log; then exit 1; fi
echo QUANT_DUAL_A_SCRIPT_PASS
