#!/usr/bin/env bash
set -euo pipefail
work=$(realpath "$1")
fixture=$(realpath "$2")
module=$(realpath "$(dirname "$0")/..")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$work"
"$xbin/xvlog" --sv -work xil_defaultlib "$module/rtl/tm4tn8_bias_bits_v1.sv" "$module/tb/tm4_bias_bits_tb.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.tm4_bias_bits_tb -s bias_bits -mt off -log xelab.log
"$xbin/xsim" bias_bits -runall -testplusarg "FIXTURE=$fixture" -onerror quit -onfinish quit -log simulate.log
rg -q TM4_BIAS_BITS_PASS simulate.log
if rg -q 'Fatal:|ERROR:' simulate.log; then exit 1; fi
echo TM4_BIAS_BITS_SCRIPT_PASS
