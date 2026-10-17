#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: front16_run_axi_short.sh FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
run=$(realpath "$1")
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
tb="$base/vivado/module_design/layernorm_engine/tb"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$run"
[[ ! -e xsim.dir && ! -e positive.log && ! -e negative.log ]]
gcc -shared -fPIC -O2 -Wall -Wextra "$run/front16_axi_short_stub.c" \
  -o libfront16_axi_short.so
"$xbin/xvlog" --sv -work xil_defaultlib "$run/front16_axi_memory.sv" \
  "$run/front16_axi_short_tb.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.front16_axi_short_tb \
  --sv_lib libfront16_axi_short --sv_root "$run" --relax -mt off \
  -s front16_axi_short -log xelab.log
"$xbin/xsim" front16_axi_short -runall -onerror quit -onfinish quit \
  -log positive.log
rg -Fq 'FRONT16_AXI_SHORT_PASS independent_AW_W=1 W_before_AW=1 AW_stall=1 reset_recovery=1' positive.log
set +e
"$xbin/xsim" front16_axi_short -runall -onerror quit -onfinish quit \
  --testplusarg BAD_WLAST -log negative.log
negative_exit=$?
set -e
[[ $negative_exit -ne 0 ]]
rg -Fq 'front16 W debt/LAST mismatch' negative.log
if rg -Fq 'malformed WLAST escaped endpoint check' negative.log; then
  exit 1
fi
echo "FRONT16_AXI_SHORT_WRAPPER_PASS negative_xsim_exit=$negative_exit"
