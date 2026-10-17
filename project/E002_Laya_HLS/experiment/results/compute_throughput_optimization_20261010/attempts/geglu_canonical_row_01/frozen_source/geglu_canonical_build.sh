#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
build="$attempt/${LAYA_GEGLU_CANONICAL_BUILD_NAME:-static}"
mkdir "$build"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
mapfile -t rtl < <(rg --files "$attempt/rtl" | rg '\.v$' | sort)
cd "$build"
"$xbin/xvlog" -work xil_defaultlib "${rtl[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib "$attempt/frozen_source/tanh_libm_canonical.sv" \
 "$attempt/frozen_source/geglu_canonical_core.sv" "$attempt/frozen_source/geglu_canonical_row_adapter.sv" \
 "$attempt/frozen_source/geglu_canonical_row_tb.sv" "$attempt/frozen_source/geglu_canonical_corner_tb.sv" -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.geglu_canonical_row_tb -L unisims_ver -L xpm -L secureip --relax -mt off \
 -s geglu_canonical_row_static -log xelab.log
"$xbin/xelab" xil_defaultlib.geglu_canonical_corner_tb -L unisims_ver -L xpm -L secureip --relax -mt off \
 -s geglu_canonical_corner_static -log xelab_corner.log
echo TANH_LIBM_GEGLU_CANONICAL_STATIC_PASS
