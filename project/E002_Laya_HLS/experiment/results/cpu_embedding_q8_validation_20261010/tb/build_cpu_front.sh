#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

stage=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/cpu_embedding_q8_validation_20261010
rtl="$stage/attempts/cpu_front_hls_04/work/hls/syn/verilog"
ip="$stage/attempts/cpu_front_hls_04/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
tb="$stage/tb"
top_sv="${LAYA_FRONT_TOP_SV:-$tb/cpu_front_top.sv}"
snapshot="${LAYA_FRONT_SNAPSHOT:-cpu_front_static}"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: build_cpu_front.sh FRESH_EXISTING_DIRECTORY' >&2
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
[[ ${#verilog[@]} -gt 0 && ${#data[@]} -gt 0 && ${#wrappers[@]} -gt 0 ]]
[[ -f "$top_sv" && "$snapshot" =~ ^[A-Za-z_][A-Za-z_0-9]*$ ]]
for path in "${data[@]}"; do
  ln -s "$path" "$(basename "$path")"
done
gcc -shared -fPIC -O2 -Wall -Wextra "$tb/cpu_front_mem.c" \
  -lm -o libcpu_front_mem.so
"$xbin/xvhdl" -work xil_defaultlib "${wrappers[@]}" -log xvhdl.log
"$xbin/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog_dut.log
"$xbin/xvlog" --sv -work xil_defaultlib "$top_sv" \
  -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.cpu_front_top \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --sv_lib libcpu_front_mem --sv_root "$PWD" \
  --relax -mt off -s "$snapshot" -log xelab.log
