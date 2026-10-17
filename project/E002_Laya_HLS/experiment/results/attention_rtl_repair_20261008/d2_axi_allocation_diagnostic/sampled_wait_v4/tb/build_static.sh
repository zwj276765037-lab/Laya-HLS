#!/usr/bin/env bash
set -euo pipefail

module_root="$(cd "$(dirname "$0")/.." && pwd)"
vivado_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin

"$vivado_bin/xvlog" --sv -L uvm \
  -i "$module_root/rtl/axivip" -i "$module_root/rtl/file_agent" \
  "$module_root/rtl/misc_interface.sv" \
  "$module_root/rtl/axivip/axi_if.sv" \
  "$module_root/rtl/axivip/axi_pkg.sv" \
  "$module_root/rtl/file_agent/file_agent_pkg.sv" \
  "$module_root/tb/phase_axi_monitor.sv" \
  "$module_root/tb/axi_allocation_diag_test.sv" \
  "$module_root/tb/axi_allocation_diag_top.sv" \
  -log xvlog.log

"$vivado_bin/xelab" work.axi_allocation_diag_top \
  -L uvm --sv_lib phase_rss --sv_root "$module_root/tb" \
  -s axi_sampled_wait --relax -mt off -log xelab.log
