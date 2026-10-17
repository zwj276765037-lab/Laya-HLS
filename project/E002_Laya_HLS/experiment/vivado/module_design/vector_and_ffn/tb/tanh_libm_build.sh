#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/vector_and_ffn
build="$attempt/static"
mkdir "$build"
cp "$module/rtl/tanh_libm_wrapper.sv" "$module/tb/tanh_libm_tb.sv" "$build/"
mapfile -t rtl < <(rg --files "$attempt/hls_project/solution1/syn/verilog" | rg '\.v$' | sort)
[[ ${#rtl[@]} -gt 0 ]]
cd "$build"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$xbin/xvlog" -work xil_defaultlib "${rtl[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib tanh_libm_wrapper.sv tanh_libm_tb.sv -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.tanh_libm_tb -L unisims_ver -L xpm -L secureip --relax -mt off -s tanh_libm_static -log xelab.log
echo TANH_LIBM_STATIC_PASS
