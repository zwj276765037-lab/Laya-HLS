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
      "$attempt/frozen/laya_lnq_row_v1.sv" \
      "$attempt/frozen/laya_lnq_row_v1_tb.sv" \
      "$attempt/frozen/laya_lnq_direct82_tb.sv"
    "$bin/xelab" work.laya_lnq_row_v1_tb -L xil_defaultlib \
      -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
      --relax -mt off -s lnq_row_v1
    "$bin/xelab" work.laya_lnq_direct82_tb -L xil_defaultlib \
      -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
      --relax -mt off -s lnq_direct82
    echo LNQ_DIRECT82_STATIC_PASS
    ;;
  sim_direct)
    "$bin/xsim" lnq_direct82 -runall \
      -testplusarg FIXTURE="$attempt/frozen/direct_fixture" | tee sim_direct.log
    grep -q '^LNQ_DIRECT82_PASS elements=2624 half=164 groups=82 reads=84' sim_direct.log
    ! grep -Eq '(Fatal:|ERROR:)' sim_direct.log
    ;;
  sim_ln)
    "$bin/xsim" lnq_row_v1 -runall \
      -testplusarg FIXTURE="$attempt/frozen/fixture" | tee sim_ln.log
    grep -q '^LNQ_ROW_PASS cases=5 errors=4 reset=1 q_backpressure=1' sim_ln.log
    ! grep -Eq '(Fatal:|ERROR:)' sim_ln.log
    ;;
  *)exit 2;;
esac
