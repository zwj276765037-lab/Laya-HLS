#!/usr/bin/env bash
# SOURCE ONLY. Execute only after a separate Attention compiler release.
set -euo pipefail
export LC_ALL=C
ROOT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_cold_v2
V5="$ROOT/.."
TB="$ROOT/tb"
RTL="$V5/runs/local_csynth_v1/work/hls/syn/verilog"
IP="$V5/runs/local_csynth_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
ENDPOINT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: build_static.sh FRESH_EXISTING_BUILD_DIRECTORY' >&2
  exit 2
fi
cd "$1"
if [[ -e xsim.dir || -e xvlog.log || -e xelab.log || -e xvhdl.log ]]; then
  echo 'build directory already contains simulator output' >&2
  exit 2
fi
mapfile -t verilog < <(find "$RTL" -maxdepth 1 -type f -name '*.v' | sort)
mapfile -t data < <(find "$RTL" -maxdepth 1 -type f -name '*.dat' | sort)
mapfile -t wrappers < <(find "$IP" -path '*/sim/*_ip.vhd' -type f | sort)
[[ ${#verilog[@]} -eq 216 && ${#data[@]} -eq 35 && ${#wrappers[@]} -eq 6 ]]
for path in "${data[@]}"; do ln -s "$path" "$(basename "$path")"; done
"$XBIN/xvhdl" -work xil_defaultlib "${wrappers[@]}" -log xvhdl.log
"$XBIN/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog_dut.log
"$XBIN/xvlog" --sv -work xil_defaultlib -i "$TB" \
  "$ENDPOINT" "$TB/att_static_axi_stall.sv" "$TB/att_axi_monitor.sv" \
  "$TB/att_axi_port.sv" "$TB/att_axi_lite_master.sv" \
  "$TB/att_cold_top.sv" -log xvlog_tb.log
"$XBIN/xelab" xil_defaultlib.att_cold_top \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --sv_lib phase_rss --sv_root "$TB" \
  --relax -mt off -s att_cold_static -log xelab.log
