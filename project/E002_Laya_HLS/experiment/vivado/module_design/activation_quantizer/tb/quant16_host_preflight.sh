#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 2 || ! -d "$1" || ! -f "$2/manifest.json" ]]; then
  echo 'usage: quant16_host_preflight.sh OUTPUT_DIR FROZEN_FIXTURE_DIR' >&2
  exit 2
fi
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$base/vivado/module_design/activation_quantizer"
out=$(realpath "$1")
fixture=$(realpath "$2")
cd "$base"
g++ -std=c++17 -O2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  -I include -I "$module/source" \
  "$module/source/quant16.cpp" "$module/source/quant16_hls_top.cpp" \
  hls/common/laya_numeric.cpp "$module/tb/quant16_hls_tb.cpp" \
  -o "$out/quant16_hls_tb"
"$out/quant16_hls_tb" \
  "$fixture/wi_source_f32.bin" "$fixture/wi_q.bin" \
  "$fixture/wi_scale.bin" "$fixture/wi_scalar_u32x3.bin" \
  "$fixture/down_source_f32.bin" "$fixture/down_q.bin" \
  "$fixture/down_scale.bin" "$fixture/down_scalar_u32x3.bin"
