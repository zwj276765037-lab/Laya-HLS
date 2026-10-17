#!/usr/bin/bash
# Source prepared only. A separate reviewed gate must release this one build.
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 1 ]]; then
  echo 'usage: /usr/bin/bash build_static.sh EXPLICIT_STATIC_BUILD_ROOT' >&2
  exit 2
fi
STATIC_BUILD_ROOT=$1
MODULE_ROOT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_controller_reachable/rtl_static_mode3_v1
D2_ROOT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_controller_reachable
RTL_ROOT=$D2_ROOT/runs/v3/csynth_vector_work/hls/syn/verilog
FP_WRAPPER_ROOT=$D2_ROOT/runs/v3/csynth_vector_work/hls/impl/ip/subcore_prj/subcore_prj.gen/sources_1/ip
ENDPOINT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv
VIVADO_BIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
TB_ROOT=$MODULE_ROOT/tb
python3 "$TB_ROOT/verify_binding.py" "$MODULE_ROOT/source/source_packet.json" \
  --stage build --static-build-root "$STATIC_BUILD_ROOT"
if [[ ! -d "$STATIC_BUILD_ROOT" || -e "$STATIC_BUILD_ROOT/xsim.dir" || -e "$STATIC_BUILD_ROOT/xvlog_dut.log" ]]; then
  echo 'static build directory must exist and be fresh' >&2
  exit 2
fi
mapfile -t verilog < <(find "$RTL_ROOT" -maxdepth 1 -type f -name '*.v' | sort)
mapfile -t data < <(find "$RTL_ROOT" -maxdepth 1 -type f -name '*.dat' | sort)
mapfile -t wrappers < <(find "$FP_WRAPPER_ROOT" -path '*/sim/*_ip.vhd' -type f | sort)
[[ ${#verilog[@]} -eq 226 && ${#data[@]} -eq 73 && ${#wrappers[@]} -eq 8 ]]
cd "$STATIC_BUILD_ROOT"
for path in "${data[@]}"; do ln -s "$path" "$(basename "$path")"; done
"$VIVADO_BIN/xvhdl" -work xil_defaultlib "${wrappers[@]}" -log xvhdl.log
"$VIVADO_BIN/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog_dut.log
"$VIVADO_BIN/xvlog" --sv -work xil_defaultlib -i "$TB_ROOT" \
  "$ENDPOINT" \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_cold_v2/tb/att_static_axi_stall.sv \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_cold_v2/tb/att_axi_monitor.sv \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_cold_v2/tb/att_axi_port.sv \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_cold_v2/tb/att_axi_lite_master.sv \
  "$TB_ROOT/vector_mode3_top.sv" -log xvlog_tb.log
"$VIVADO_BIN/xelab" xil_defaultlib.vector_mode3_top \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s vector_mode3_static -log xelab.log
