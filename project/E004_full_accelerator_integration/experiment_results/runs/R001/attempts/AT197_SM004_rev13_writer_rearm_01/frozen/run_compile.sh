#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog --sv ../frozen/tm1tn8_axi512_writer.sv ../frozen/tm1tn8_axi512_writer_tb.sv -log xvlog.log
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab work.tm1tn8_axi512_writer_tb --relax -mt off -s writer_rearm_sim -log xelab.log
