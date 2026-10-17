#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
build="$attempt/static"
mkdir "$build"
cp "$attempt/frozen_source/geglu_row_wrapper.sv" "$attempt/frozen_source/geglu_row_tb.sv" "$build/"
mapfile -t rtl < <(rg --files "$attempt/hls_project/solution1/syn/verilog" | rg '\.v$' | sort)
[[ ${#rtl[@]} -gt 0 ]]
cd "$build"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$xbin/xvlog" -work xil_defaultlib "${rtl[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib geglu_row_wrapper.sv geglu_row_tb.sv -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.geglu_row_tb -L unisims_ver -L xpm -L secureip --relax -mt off -s geglu_libm_static -log xelab.log
echo TANH_LIBM_GEGLU_STATIC_PASS
