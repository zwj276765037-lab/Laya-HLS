#!/usr/bin/env bash
set -euo pipefail

module_root="$(cd "$(dirname "$0")/.." && pwd)"
vivado_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin

"$vivado_bin/xvlog" --sv \
  -i "$module_root/rtl/axivip" \
  "$module_root/rtl/axivip/axi_if.sv" \
  "$module_root/tb/clock_wait_worker_pkg.sv" \
  "$module_root/tb/clock_wait_diag_top.sv" \
  -log xvlog.log

"$vivado_bin/xelab" work.clock_wait_diag_top \
  --sv_lib phase_rss --sv_root "$module_root/tb" \
  -s clock_wait_diag --relax -mt off -log xelab.log
