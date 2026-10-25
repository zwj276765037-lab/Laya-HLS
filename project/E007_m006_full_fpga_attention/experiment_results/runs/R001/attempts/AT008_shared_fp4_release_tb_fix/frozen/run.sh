#!/usr/bin/env bash
set -euo pipefail
at=$1
cd "$at/work"
exec /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim shared_fp4_sim -runall
