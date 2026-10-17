#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 2 || ! -d "$1" || ! -d "$2" ]]; then
  echo 'usage: build_capacity.sh PREPARED_DIR FRESH_BUILD_DIR' >&2
  exit 2
fi
source_dir=$(realpath "$1")
build_dir=$(realpath "$2")
if [[ -e "$build_dir/xsim.dir" || -e "$build_dir/xvlog.log" || -e "$build_dir/xelab.log" ]]; then
  echo 'fresh build directory required' >&2
  exit 2
fi
cd "$build_dir"
vivado=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado
tool="$vivado/bin"
"$tool/xvlog" --sv -work xil_defaultlib \
  "$source_dir"/bank_{0..7}.v "$source_dir/ws_capacity_top.sv" \
  "$vivado/data/verilog/src/glbl.v" -log xvlog.log
"$tool/xelab" xil_defaultlib.ws_capacity_top xil_defaultlib.glbl \
  -L unisims_ver -L secureip \
  --relax -mt off -s ws_capacity_static -log xelab.log
