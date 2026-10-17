#!/usr/bin/env bash
# Dormant source only. A later release must bind one case, fresh root and guard.
set -euo pipefail
export LC_ALL=C

BASE=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
TASK="$BASE/results/attention_rtl_repair_20261008"
TYPE="$TASK/d2_type_producer_binary_v1"
RTL="$TYPE/runs/hls_synthesis_v1/work/hls/syn/verilog"
IP="$TYPE/runs/hls_synthesis_v1/work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip"
TB="$BASE/results/offline_validation_20261009/tb/type"
ACCEPTED="$BASE/results/offline_validation_20261009/tb"
ENDPOINT="$TASK/d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv"
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin

if [[ $# -ne 2 || ( "$1" != qtype2 && "$1" != qtype1 ) || ! -d "$2" ]]; then
  echo 'usage: build_static.sh qtype2|qtype1 FRESH_EXISTING_DIRECTORY' >&2
  exit 2
fi
case_name="$1"
cd "$2"
if [[ -e xsim.dir || -e xvhdl.log || -e xvlog_dut.log ||
      -e xvlog_tb.log || -e xelab.log ]]; then
  echo 'static build directory is not fresh' >&2
  exit 2
fi
mapfile -t verilog < <(find "$RTL" -maxdepth 1 -type f -name '*.v' | sort)
mapfile -t data < <(find "$RTL" -maxdepth 1 -type f -name '*.dat' | sort)
mapfile -t wrappers < <(find "$IP" -path '*/sim/*_ip.vhd' -type f | sort)
[[ ${#verilog[@]} -eq 229 && ${#data[@]} -eq 88 && ${#wrappers[@]} -eq 4 ]]
for path in "${data[@]}"; do
  ln -s "$path" "$(basename "$path")"
done
"$XBIN/xvhdl" -work xil_defaultlib "${wrappers[@]}" -log xvhdl.log
"$XBIN/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog_dut.log
"$XBIN/xvlog" --sv -work xil_defaultlib -i "$TB" \
  "$ENDPOINT" "$ACCEPTED/att_static_axi_stall.sv" \
  "$ACCEPTED/att_axi_monitor.sv" "$ACCEPTED/att_axi_port.sv" \
  "$ACCEPTED/att_axi_lite_master.sv" \
  "$TB/type_r_hold_selector.sv" \
  "$TB/type_cold_${case_name}_top.sv" -log xvlog_tb.log
"$XBIN/xelab" "xil_defaultlib.type_cold_${case_name}_top" \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s "type_cold_${case_name}_static" -log xelab.log
