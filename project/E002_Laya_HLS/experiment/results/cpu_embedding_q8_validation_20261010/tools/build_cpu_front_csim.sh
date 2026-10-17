#!/usr/bin/env bash
set -euo pipefail
root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
if [[ $# -ne 2 ]]; then
  echo 'usage: build_cpu_front_csim.sh MODEL_PACKAGE OUTPUT' >&2
  exit 2
fi
package=$1
output=$2
cd "$root"
mapfile -t sources < <(sed -n '/^[[:space:]]*hls\/.*\.cpp[[:space:]]*$/ { s/^[[:space:]]*//; p; }' config/full_sources.cmake)
[[ ${#sources[@]} -gt 20 ]]
/usr/bin/g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic \
  -fno-fast-math -fno-associative-math -ffp-contract=off \
  -Iinclude -Ihls -I"$package" \
  "${sources[@]}" \
  hls/platform/full_frontend_wrapper.cpp \
  results/cpu_embedding_q8_validation_20261010/tools/cpu_front_csim_tb.cpp \
  -o "$output"
