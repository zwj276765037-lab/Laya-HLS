#!/usr/bin/env bash
set -euo pipefail
at=$1
exec /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado -mode batch -source "$at/frozen_tools/attention_exp_ooc.tcl" -tclargs "$at" "$at/work"
