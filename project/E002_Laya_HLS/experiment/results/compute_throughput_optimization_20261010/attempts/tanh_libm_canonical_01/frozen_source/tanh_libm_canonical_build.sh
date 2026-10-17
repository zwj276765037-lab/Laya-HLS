#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
build="$attempt/${LAYA_CANONICAL_BUILD_NAME:-static}"
mkdir "$build"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
mapfile -t rtl < <(rg --files "$attempt/rtl" | rg '\.v$' | sort)
cd "$build"
"$xbin/xvlog" -work xil_defaultlib "${rtl[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib "$attempt/frozen_source/tanh_libm_canonical.sv" \
 "$attempt/frozen_source/tanh_libm_canonical_tb.sv" "$attempt/frozen_source/tanh_libm_stream_helper_tb.sv" -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.tanh_libm_canonical_tb -L unisims_ver -L xpm -L secureip --relax -mt off \
 -s tanh_libm_canonical_static -log xelab.log
"$xbin/xelab" xil_defaultlib.tanh_libm_stream_helper_tb -L unisims_ver -L xpm -L secureip --relax -mt off \
 -s tanh_libm_canonical_helper_static -log xelab_helper.log
echo TANH_CANONICAL_STATIC_PASS
