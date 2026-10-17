#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 3 || ! -d "$1" || ! -f "$2/source_manifest.json" || ! -d "$3" ]]; then
  echo 'usage: build_vector_wi_capture.sh V4_MODEL_PACKAGE PREPARED_SOURCE_DIR OUTPUT_DIR' >&2
  exit 2
fi
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
package=$(realpath "$1")
prepared=$(realpath "$2")
output=$(realpath "$3")
[[ ! -e "$output/vector_wi_capture_csim" ]]
cd "$base"
mapfile -t sources < <(sed -n '/^[[:space:]]*hls\/.*\.cpp[[:space:]]*$/ { s/^[[:space:]]*//; p; }' config/full_sources.cmake)
[[ ${#sources[@]} -gt 20 ]]
replaced=0
for i in "${!sources[@]}"; do
  if [[ ${sources[i]} == hls/control/full_forward_controller.cpp ]]; then
    sources[i]="$prepared/full_forward_controller_vector_capture.cpp"
    replaced=$((replaced + 1))
  fi
done
[[ $replaced -eq 1 ]]
/usr/bin/g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic \
  -fno-fast-math -fno-associative-math -ffp-contract=off \
  -Iinclude -Ihls -I"$package" "${sources[@]}" \
  "$prepared/persistent_cpu_full_csim_vector_capture_tb.cpp" \
  -o "$output/vector_wi_capture_csim"
echo 'VECTOR_WI_CAPTURE_BUILD_PASS'
