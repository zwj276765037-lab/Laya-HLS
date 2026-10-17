#!/usr/bin/env bash
set -euo pipefail

module=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/hbm_loader_and_cache
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 2 || ! -d "$1" || ! -f "$2/fixture_manifest.json" ]]; then
  echo 'usage: run_three_port_reader_short.sh FRESH_EXISTING_WORKDIR FIXTURE_DIR' >&2
  exit 2
fi
work=$(realpath "$1")
fixture=$(realpath "$2")
if [[ -n "$(find "$work" -mindepth 1 -print -quit)" ]]; then
  echo 'work directory must be fresh' >&2
  exit 2
fi
cd "$work"
"$xbin/xvlog" --sv -work xil_defaultlib \
  "$module/rtl/t4_w_reader_port_v1.sv" \
  "$module/rtl/t4_three_port_reader_v1.sv" \
  "$module/tb/t4_three_port_reader_short_tb.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.t4_three_port_reader_short_tb \
  --relax -mt off -s t4_three_port_reader_short_sim -log xelab.log
for case_name in wi_boundary wi_tail down_boundary down_tail; do
  case_dir="$fixture/$case_name"
  for input in config.hex q0.hex q1.hex scale.hex; do
    test -f "$case_dir/$input"
  done
  "$xbin/xsim" t4_three_port_reader_short_sim -runall \
    -onerror quit -onfinish quit \
    -testplusarg "CASE_DIR=$case_dir" -log "$case_name.log"
  rg -Fq "T4_THREE_PORT_READER_SHORT_PASS case=$case_dir fault_port=-1" \
    "$case_name.log"
  if rg -q 'Fatal:|ERROR:' "$case_name.log"; then exit 1; fi
done
case_dir="$fixture/down_boundary"
"$xbin/xsim" t4_three_port_reader_short_sim -runall \
  -onerror quit -onfinish quit \
  -testplusarg "CASE_DIR=$case_dir" -testplusarg 'FAULT_PORT=2' \
  -log fault_scale_rresp.log
rg -Fq "T4_THREE_PORT_READER_SHORT_PASS case=$case_dir fault_port=2" \
  fault_scale_rresp.log
if rg -q 'Fatal:|ERROR:' fault_scale_rresp.log; then exit 1; fi
echo 'T4_READER_SHORT_SUITE_PASS cases=4 faults=1'
