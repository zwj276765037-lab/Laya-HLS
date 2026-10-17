#!/usr/bin/env bash
set -euo pipefail
work=$(realpath "$1")
module=$(realpath "$(dirname "$0")/..")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$work"
"$xbin/xvlog" --sv -work xil_defaultlib "$module/rtl/quant_f32_row_bank_v1.sv" "$module/rtl/quant_f32_two_row_feeder_v1.sv" "$module/tb/quant_f32_two_row_feeder_tb_v1.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.quant_f32_two_row_feeder_tb_v1 -s quant_two_row -mt off -log xelab.log
"$xbin/xsim" quant_two_row -runall -onerror quit -onfinish quit -log simulate.log
rg -q QUANT_F32_TWO_ROW_PASS simulate.log
if rg -q 'Fatal:|ERROR:' simulate.log; then exit 1; fi
echo QUANT_F32_TWO_ROW_SCRIPT_PASS
