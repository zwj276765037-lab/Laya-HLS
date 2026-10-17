#!/usr/bin/env bash
set -euo pipefail
attempt=$(realpath "$1")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
export PATH="$xbin:$PATH"
"$xbin/vivado" -mode batch -nojournal -nolog -source "$attempt/frozen_source/attention_tile_build.tcl" -tclargs "$attempt"
simdir="$attempt/build/vivado/attention_tile.sim/sim_1/behav/xsim"
cd "$simdir"
cp "$attempt"/rtl/*.dat .
bash compile.sh
bash elaborate.sh
echo ATTENTION_SERVICE_TILE_STATIC_PASS
