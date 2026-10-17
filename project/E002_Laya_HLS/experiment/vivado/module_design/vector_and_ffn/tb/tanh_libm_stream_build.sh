#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
build="$attempt/${LAYA_STREAM_BUILD_NAME:-static}"
mkdir "$build"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ ${2:-stream} == helper ]]; then
 project=hls_project
 snapshot=tanh_libm_stream_helper_static
 cp "$attempt/frozen_source/tanh_libm_stream_helper_tb.sv" "$build/"
 tb=tanh_libm_stream_helper_tb
else
 project=hls_project
 snapshot=tanh_libm_stream_static
 cp "$attempt/frozen_source/tanh_libm_stream_wrapper.sv" "$attempt/frozen_source/tanh_libm_stream_tb.sv" "$build/"
 tb=tanh_libm_stream_tb
fi
mapfile -t rtl < <(rg --files "$attempt/$project/solution1/syn/verilog" | rg '\.v$' | sort)
[[ ${#rtl[@]} -gt 0 ]]
cd "$build"
"$xbin/xvlog" -work xil_defaultlib "${rtl[@]}" -log xvlog_dut.log
mapfile -t sv < <(rg --files . | rg '\.sv$' | sort)
"$xbin/xvlog" --sv -work xil_defaultlib "${sv[@]}" -log xvlog_tb.log
"$xbin/xelab" "xil_defaultlib.$tb" -L unisims_ver -L xpm -L secureip --relax -mt off -s "$snapshot" -log xelab.log
echo TANH_LIBM_STREAM_STATIC_PASS
