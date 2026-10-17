#!/usr/bin/env bash
set -euo pipefail
module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/vector_and_ffn
out=$(realpath "$1")
mkdir -p "$out/cpu"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -fno-builtin-tanhf \
  -Wno-unknown-pragmas -I"$module/source" "$module/source/tanh_libm_bits.cpp" \
  "$module/tb/tanh_libm_cpu.cpp" -lm -o "$out/cpu/tanh_libm_cpu"
"$out/cpu/tanh_libm_cpu" "$out/fixture/x.bin" "$out/fixture/gold.bin" "$out/cpu/add_directed.mem"
