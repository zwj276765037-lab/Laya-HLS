#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 2 || ! -f "$1" || ! -d "$2" ]]; then
  echo 'usage: tanh_service_build.sh SOURCE_MANIFEST FRESH_BUILD_DIR' >&2
  exit 2
fi
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$base/vivado/module_design/vector_and_ffn"
manifest=$(realpath "$1")
build=$(realpath "$2")
[[ ! -e "$build/xsim.dir" && ! -e "$build/frozen_source" ]]
python3 "$module/tb/tanh_service_verify.py" "$manifest"
mkdir "$build/frozen_source"
cp "$module/rtl/tanh_service_wrapper.sv" "$module/tb/tanh_service_tb.sv" \
   "$module/tb/tanh_service_build.sh" "$module/tb/tanh_service_run.sh" \
   "$module/tb/tanh_service_verify.py" "$build/frozen_source/"
cp "$manifest" "$build/frozen_source/source_manifest.json"
mapfile -t verilog < <(python3 "$module/tb/tanh_service_verify.py" "$manifest" --list verilog)
mapfile -t vhdl < <(python3 "$module/tb/tanh_service_verify.py" "$manifest" --list vhdl)
mapfile -t rom < <(python3 "$module/tb/tanh_service_verify.py" "$manifest" --list rom)
[[ ${#verilog[@]} -gt 0 && ${#vhdl[@]} -gt 0 && ${#rom[@]} -gt 0 ]]
for path in "${rom[@]}"; do ln -s "$path" "$build/$(basename "$path")"; done
cd "$build"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$xbin/xvhdl" -work xil_defaultlib "${vhdl[@]}" -log xvhdl.log
"$xbin/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib \
  frozen_source/tanh_service_wrapper.sv frozen_source/tanh_service_tb.sv \
  -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.tanh_service_tb \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s tanh_service_static -log xelab.log
echo 'TANH_SERVICE_STATIC_PASS'
