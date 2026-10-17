#!/usr/bin/env bash
set -euo pipefail
mode=$1
attempt=$2
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
case "$mode" in
  static)
    "$bin/xvhdl" -work xil_defaultlib "$attempt/frozen/ln_sqrt_ip.vhd"
    "$bin/xvlog" "$attempt"/frozen/attention*.v "$attempt/frozen/ln_mul.v" "$attempt/frozen/ln_div.v" "$attempt/frozen/ln_sqrt.v"
    "$bin/xvlog" --sv "$attempt/frozen/ln_add_stream.sv" "$attempt/frozen/ln_add.v" "$attempt/frozen/laya_ln_row_v1.sv" "$attempt/frozen/laya_ln_row_v1_tb.sv"
    "$bin/xelab" work.laya_ln_row_v1_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s ln_row_v1
    echo LN_ROW_STATIC_PASS
    ;;
  sim)
    "$bin/xsim" ln_row_v1 -runall -testplusarg FIXTURE="$attempt/frozen/fixture"
    ;;
  *) exit 2;;
esac
