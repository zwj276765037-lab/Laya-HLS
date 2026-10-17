#!/usr/bin/env bash
set -euo pipefail
root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$root/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512"
vitis=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis
if [[ $# -ne 5 || ! -d "$1" || ! -f "$2/laya_model_layout_generated.h" ||
      ! -f "$3/act_source_f32.bin" || ! -f "$4/register.hex" ||
      ! -f "$5/register.hex" ]]; then
  echo 'usage: build_session_dma_csim_v2.sh FRESH_BUILD_DIR PACKAGE FIXTURE STRICT_INPUTS FAST_INPUTS' >&2
  exit 2
fi
if [[ -n "$(find "$1" -mindepth 1 -print -quit)" ]]; then
  echo 'build directory must be fresh' >&2
  exit 2
fi
common=(-std=c++17 -O2 -fno-fast-math -ffp-contract=off
  -I"$vitis/include" -I"$root/include" -I"$2" -I"$module/source")
/usr/bin/g++ "${common[@]}" -MMD -MF "$1/engine.d" \
  -c "$module/source/q8_tm1tn8_session_dma_v2.cpp" -o "$1/engine.o"
/usr/bin/g++ "${common[@]}" -MMD -MF "$1/tb.d" \
  -c "$module/tb/tm1tn8_session_dma_csim_v2.cpp" -o "$1/tb.o"
/usr/bin/g++ "$1/engine.o" "$1/tb.o" -lm -o "$1/tm1tn8_session_dma_csim_v2"
"$1/tm1tn8_session_dma_csim_v2" "$2" "$3" "$4" strict
"$1/tm1tn8_session_dma_csim_v2" "$2" "$3" "$5" fast
