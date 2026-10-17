#!/usr/bin/env bash
set -euo pipefail

/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/tb/axi_static_unit_top.sv \
  -log xvlog.log

/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab \
  work.axi_static_unit_top --sv_lib phase_rss \
  --sv_root /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/bounded_static_v1/tb \
  -s axi_bounded_static --relax -mt off -log xelab.log
