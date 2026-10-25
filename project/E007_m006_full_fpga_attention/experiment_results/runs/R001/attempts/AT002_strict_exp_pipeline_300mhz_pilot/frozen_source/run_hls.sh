#!/usr/bin/env bash
set -euo pipefail
export LAYA_ATTENTION_ATTEMPT="$1"
cd "$1/work"
exec /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run --mode hls --tcl "$1/frozen_source/strict_exp_300mhz.tcl"
