#!/usr/bin/env bash
set -euo pipefail
work=$(realpath "$1")
module=$(realpath "$(dirname "$0")/..")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$work"
"$xbin/xvlog" --sv -work xil_defaultlib "$module/rtl/geglu_gate_writer_ledger_v1.sv" "$module/tb/geglu_gate_writer_ledger_tb_v1.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.geglu_gate_writer_ledger_tb_v1 -s gate_writer -mt off -log xelab.log
"$xbin/xsim" gate_writer -runall -onerror quit -onfinish quit -log simulate.log
rg -q GEGLU_GATE_WRITER_LEDGER_PASS simulate.log
if rg -q 'Fatal:|ERROR:' simulate.log; then exit 1; fi
echo GEGLU_GATE_WRITER_LEDGER_SCRIPT_PASS
