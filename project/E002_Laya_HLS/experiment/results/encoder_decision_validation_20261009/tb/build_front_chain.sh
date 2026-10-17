#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

stage=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/encoder_decision_validation_20261009
rtl="$stage/attempts/full_hls_01/work/hls/syn/verilog"
ip="$stage/attempts/full_hls_01/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
tb="$stage/tb"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: build_front_chain.sh FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
cd "$1"
if [[ -e xsim.dir || -e xvhdl.log || -e xvlog_dut.log ||
      -e xvlog_tb.log || -e xelab.log ]]; then
  echo 'static build directory is not fresh' >&2
  exit 2
fi
mapfile -t verilog < <(find "$rtl" -maxdepth 1 -type f -name '*.v' | sort)
mapfile -t data < <(find "$rtl" -maxdepth 1 -type f -name '*.dat' | sort)
mapfile -t wrappers < <(find "$ip" -path '*/sim/*_ip.vhd' -type f | sort)
[[ ${#verilog[@]} -eq 736 && ${#data[@]} -eq 208 &&
   ${#wrappers[@]} -eq 13 ]]
for path in "${data[@]}"; do
  ln -s "$path" "$(basename "$path")"
done
gcc -shared -fPIC -O2 -Wall -Wextra "$tb/front_chain_mem.c" -o libfront_chain_mem.so
"$xbin/xvhdl" -work xil_defaultlib "${wrappers[@]}" -log xvhdl.log
"$xbin/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib "$tb/front_chain_top.sv" -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.front_chain_top \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --sv_lib libfront_chain_mem --sv_root "$PWD" \
  --relax -mt off -s front_chain_static -log xelab.log
