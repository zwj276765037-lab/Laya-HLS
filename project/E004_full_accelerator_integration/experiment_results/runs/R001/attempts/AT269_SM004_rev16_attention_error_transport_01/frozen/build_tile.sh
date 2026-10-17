#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
export PATH="$xbin:$PATH"
"$xbin/vivado" -mode batch -nojournal -nolog -source "$attempt/frozen/build_tile.tcl" -tclargs "$attempt"
simdir="$attempt/work/vivado/attention_final_tile.sim/sim_1/behav/xsim"
cd "$simdir"
cp "$attempt"/frozen/rtl/*.dat .
bash compile.sh
bash elaborate.sh
echo ATT_FINAL_TILE_ELAB_PASS
