#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
mkdir "$attempt/cpu"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -Wno-unknown-pragmas \
 -I"$attempt/frozen_source" "$attempt/frozen_source/geglu_libm_stream_cpu.cpp" \
 "$attempt/frozen_source/geglu_libm_stream_bits.cpp" \
 "$attempt/frozen_source/gelu_libm_bits.cpp" "$attempt/frozen_source/tanh_libm_bits.cpp" \
 -o "$attempt/cpu/geglu_libm_stream_cpu"
"$attempt/cpu/geglu_libm_stream_cpu" "$attempt/fixture/wi.bin" "$attempt/fixture/steps.bin"
