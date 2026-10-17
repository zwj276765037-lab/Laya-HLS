#!/usr/bin/env bash
set -euo pipefail
mode=$1
attempt=$2
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
case "$mode" in
  static)
    "$bin/xvhdl" -work xil_defaultlib "$attempt"/frozen/*.vhd
    "$bin/xvlog" "$attempt"/frozen/attention*.v "$attempt"/frozen/ln_mul.v \
      "$attempt"/frozen/ln_div.v "$attempt"/frozen/ln_sqrt.v \
      "$attempt"/frozen/laya_quant16_functional_*.v
    "$bin/xvlog" --sv "$attempt/frozen/r0_fp_bits_pkg.sv" \
      "$attempt/frozen/ln_add_stream.sv" "$attempt/frozen/ln_add.v" \
      "$attempt"/frozen/quant16_*.sv "$attempt/frozen/laya_ln_row_v1.sv" \
      "$attempt/frozen/laya_lnq_row_v1.sv" "$attempt/frozen/laya_lnq_row_v1_tb.sv"
    "$bin/xelab" work.laya_lnq_row_v1_tb -L xil_defaultlib \
      -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
      --relax -mt off -s lnq_row_v1
    echo LNQ_STATIC_PASS
    ;;
  sim)
    "$bin/xsim" lnq_row_v1 -runall -testplusarg FIXTURE="$attempt/frozen/fixture" | tee sim.log
    grep -q '^LNQ_ROW_PASS cases=3 gold=P1_original_input_stats_q' sim.log
    ! grep -Eq '(Fatal:|ERROR:)' sim.log
    ;;
  *) exit 2;;
esac
