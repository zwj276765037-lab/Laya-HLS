#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$root/vivado/module_design/vector_and_ffn"
mkdir "$attempt/cpu"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -Wno-unknown-pragmas \
 -I"$root/include" -I"$module/source" "$module/tb/geglu_libm_cpu.cpp" \
 "$root/hls/operators/vector_full_compute.cpp" "$root/hls/operators/vector_libm_bits.cpp" \
 "$root/hls/common/laya_numeric.cpp" -o "$attempt/cpu/geglu_libm_cpu"
"$attempt/cpu/geglu_libm_cpu" "$attempt/fixture/wi.bin" "$attempt/fixture/steps.bin"
