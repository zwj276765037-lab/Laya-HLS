#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
mkdir "$attempt/cpu"
g++ -std=c++17 -O2 -fno-fast-math -ffp-contract=off -Wno-unknown-pragmas \
 -I"$attempt/frozen_source" "$attempt/frozen_source/tanh_libm_canonical_cpu.cpp" \
 -o "$attempt/cpu/tanh_libm_canonical_cpu"
"$attempt/cpu/tanh_libm_canonical_cpu" "$attempt/fixture/x.mem" "$attempt/fixture/gold.mem" \
 "$attempt/fixture/ops_directed.mem" "$attempt/cpu/trace.mem"
