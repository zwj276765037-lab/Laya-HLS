#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

if [[ $# -ne 1 || ( "$1" != byte && "$1" != wide ) ]]; then
  echo 'usage: front16_build_rtl.sh byte|wide' >&2
  exit 2
fi
mode=$1
base=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module="$base/vivado/module_design/layernorm_engine"
root="$module/rtl/front16_$mode"
rtl="$root/hls/syn/verilog"
ip="$root/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
build="$root/${FRONT16_STATIC_NAME:-static}"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
[[ -d "$rtl" && ! -e "$build" ]]
mkdir "$build"
mkdir "$build/frozen_source"
cp "$module/tb/front16_make_top.py" "$module/tb/front16_axi_memory.sv" \
   "$module/tb/front16_mem.c" "$build/frozen_source/"
python3 "$build/frozen_source/front16_make_top.py" \
  "$rtl/laya_front16_$mode.v" "$root/front16_top.sv" | tee "$root/top_generation.log"
cp "$root/front16_top.sv" "$build/frozen_source/front16_top.sv"
cd "$build"
mapfile -t verilog < <(find "$rtl" -maxdepth 1 -type f -name '*.v' | sort)
mapfile -t data < <(find "$rtl" -maxdepth 1 -type f -name '*.dat' | sort)
mapfile -t wrappers < <(find "$ip" -path '*/sim/*_ip.vhd' -type f | sort)
[[ ${#verilog[@]} -gt 0 ]]
for path in "${data[@]}"; do ln -s "$path" "$(basename "$path")"; done
gcc -shared -fPIC -O2 -Wall -Wextra "$build/frozen_source/front16_mem.c" \
  -lm -o libfront16_mem.so
if (( ${#wrappers[@]} )); then
  "$xbin/xvhdl" -work xil_defaultlib "${wrappers[@]}" -log xvhdl.log
fi
"$xbin/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib \
  "$build/frozen_source/front16_axi_memory.sv" \
  "$build/frozen_source/front16_top.sv" \
  -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.front16_top \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --sv_lib libfront16_mem --sv_root "$PWD" \
  --relax -mt off -s front16_static -log xelab.log
echo "FRONT16_STATIC_PASS mode=$mode"
