#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
build="$attempt/netlist_static"
mkdir "$build";cd "$build"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$xbin/xvlog" -work xil_defaultlib "$attempt/ooc/parent/tanh_libm_canonical_assembled_sim.v" \
 "$xbin/../data/verilog/src/glbl.v" -log xvlog_netlist.log
"$xbin/xvlog" --sv -work xil_defaultlib "$attempt/frozen_source/tanh_libm_canonical_netlist_tb.sv" -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.tanh_libm_canonical_netlist_tb xil_defaultlib.glbl \
 -L unisims_ver -L xpm -L secureip --relax -mt off -s tanh_libm_canonical_netlist_static -log xelab.log
echo TANH_LIBM_CANONICAL_NETLIST_STATIC_PASS
