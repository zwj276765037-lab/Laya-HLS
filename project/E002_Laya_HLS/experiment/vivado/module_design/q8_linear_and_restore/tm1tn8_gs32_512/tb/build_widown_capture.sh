#!/usr/bin/env bash
set -euo pipefail

root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
if [[ $# -ne 3 || ! -d "$1" || ! -d "$2" || ! -d "$3" ]]; then
  echo 'usage: build_widown_capture.sh V4_MODEL_PACKAGE PREPARED_SOURCE_DIR OUTPUT_DIR' >&2
  exit 2
fi
package=$(realpath "$1")
prepared=$(realpath "$2")
output=$(realpath "$3")
[[ -f "$prepared/source_manifest.json" ]]
[[ ! -e "$output/t2_widown_capture_csim" ]]
cd "$root"
mapfile -t sources < <(sed -n '/^[[:space:]]*hls\/.*\.cpp[[:space:]]*$/ { s/^[[:space:]]*//; p; }' config/full_sources.cmake)
[[ ${#sources[@]} -gt 20 ]]
replaced=0
for i in "${!sources[@]}"; do
  if [[ ${sources[i]} == hls/control/full_forward_controller.cpp ]]; then
    sources[i]="$prepared/full_forward_controller_t2_capture.cpp"
    replaced=$((replaced + 1))
  fi
done
[[ $replaced -eq 1 ]]
/usr/bin/g++ -std=c++17 -O2 -Wall -Wextra -Wpedantic \
  -fno-fast-math -fno-associative-math -ffp-contract=off \
  -Iinclude -Ihls -I"$package" \
  "${sources[@]}" \
  "$prepared/persistent_cpu_full_csim_t2_capture_tb.cpp" \
  -o "$output/t2_widown_capture_csim"
