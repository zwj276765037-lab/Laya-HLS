#!/usr/bin/env bash
set -euo pipefail
a=$1; cd "$a/work"
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
"$bin/xsim" rev22_ps_writer_ctrl_sim -runall -testplusarg "FIXTURE=$a/fixture"
