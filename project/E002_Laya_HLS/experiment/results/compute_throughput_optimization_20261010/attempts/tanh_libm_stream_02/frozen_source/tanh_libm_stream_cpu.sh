#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/vector_and_ffn
mkdir "$attempt/cpu"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -Wno-unknown-pragmas \
 -I"$module/source" -c "$module/source/tanh_libm_stream_bits.cpp" -o "$attempt/cpu/stream.o"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -fno-builtin-tanhf -Wno-unknown-pragmas \
 -I"$module/source" -Dfp_add_bits=stream_fp_add_bits -Dfp_mul_bits=stream_fp_mul_bits \
 -Dfp_div_bits=stream_fp_div_bits -Dtanh_libm_bits=tanh_libm_stream_bits \
 -Dtanh_libm_leaf=tanh_libm_stream_leaf "$module/tb/tanh_libm_cpu.cpp" \
 "$attempt/cpu/stream.o" -lm -o "$attempt/cpu/tanh_libm_stream_cpu"
"$attempt/cpu/tanh_libm_stream_cpu" "$attempt/fixture/x.bin" "$attempt/fixture/gold.bin" "$attempt/cpu/add_directed.mem"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -Wno-unknown-pragmas \
 -I"$module/source" "$module/tb/tanh_libm_stream_helper_gold.cpp" \
 "$attempt/cpu/stream.o" -o "$attempt/cpu/stream_helper_gold"
"$attempt/cpu/stream_helper_gold" "$attempt/cpu/add_directed.mem" "$attempt/cpu/ops_directed.mem"
