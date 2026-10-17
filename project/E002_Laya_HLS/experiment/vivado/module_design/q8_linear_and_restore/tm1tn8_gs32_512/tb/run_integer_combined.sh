#!/usr/bin/env bash
set -euo pipefail

module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 2 || ! -d "$1" || ! -d "$2" ]]; then
  echo 'usage: run_integer_combined.sh FRESH_EXISTING_DIRECTORY VECTOR_DIRECTORY' >&2
  exit 2
fi
vectors=$(realpath "$2")
python3 "$module/tb/check_integer_combined_vectors.py" "$vectors"
cd "$1"
if [[ -e xsim.dir || -e xvlog.log || -e xelab_short.log ||
      -e xsim_short.log || -e xelab_real.log || -e xsim_real.log ]]; then
  echo 'run directory is not fresh' >&2
  exit 2
fi
"$xbin/xvlog" --sv -work xil_defaultlib \
  "$module/rtl/tm1tn8_integer_tree.sv" \
  "$module/rtl/tm1tn8_integer_tree_lut.sv" \
  "$module/rtl/tm1tn8_signed_pack_pair.sv" \
  "$module/rtl/tm1tn8_integer_tree_packed.sv" \
  "$module/rtl/tm1tn8_integer_tree_pack_lut.sv" \
  "$module/tb/tm1tn8_integer_combined_tb.sv" \
  "$module/tb/tm1tn8_integer_combined_real_tb.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.tm1tn8_integer_combined_tb \
  --relax -mt off -s tm1tn8_combined_short_sim -log xelab_short.log
"$xbin/xsim" tm1tn8_combined_short_sim -runall -onerror quit \
  -onfinish quit -log xsim_short.log
rg -Fq 'TM1TN8_INTEGER_COMBINED_PASS' xsim_short.log
if rg -q 'Fatal:|ERROR:' xsim_short.log; then
  echo 'combined short simulation reported a fatal or error' >&2
  exit 1
fi
"$xbin/xelab" xil_defaultlib.tm1tn8_integer_combined_real_tb \
  --relax -mt off -s tm1tn8_combined_real_sim -log xelab_real.log
"$xbin/xsim" tm1tn8_combined_real_sim -runall -onerror quit \
  -onfinish quit -testplusarg "VEC_DIR=$vectors" -log xsim_real.log
rg -Fq 'TM1TN8_INTEGER_COMBINED_REAL_PASS' xsim_real.log
if rg -q 'Fatal:|ERROR:' xsim_real.log; then
  echo 'combined real simulation reported a fatal or error' >&2
  exit 1
fi
