#!/usr/bin/env bash
set -euo pipefail
mode=$1
attempt=$2
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
case "$mode" in
  host)
    g++ -std=c++20 -O2 -fno-fast-math -ffp-contract=off \
      -ffunction-sections -fdata-sections -Wl,--gc-sections \
      -I "$attempt/frozen/host_ref/include" \
      "$attempt/frozen/host_ref/laya_ln_row_edge_ref.cpp" \
      "$attempt/frozen/host_ref/layernorm_compute.cpp" \
      "$attempt/frozen/host_ref/laya_numeric.cpp" \
      -o ln_edge_ref
    ./ln_edge_ref "$attempt/frozen/edge_fixture"
    ;;
  static)
    "$bin/xvhdl" -work xil_defaultlib "$attempt/frozen/ln_sqrt_ip.vhd"
    "$bin/xvlog" "$attempt"/frozen/attention*.v "$attempt/frozen/ln_mul.v" "$attempt/frozen/ln_div.v" "$attempt/frozen/ln_sqrt.v"
    "$bin/xvlog" --sv "$attempt/frozen/ln_add_stream.sv" "$attempt/frozen/ln_add.v" "$attempt/frozen/laya_ln_row_v1.sv" "$attempt/frozen/laya_ln_row_edge_tb.sv"
    "$bin/xelab" work.laya_ln_row_edge_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s ln_row_edge
    echo LN_EDGE_STATIC_PASS
    ;;
  sim)
    "$bin/xsim" ln_row_edge -runall -testplusarg FIXTURE="$attempt/frozen/edge_fixture" | tee edge_sim.log
    grep -q '^LN_EDGE_PASS cases=6' edge_sim.log
    ! grep -Eq '(Fatal:|ERROR:)' edge_sim.log
    ;;
  *) exit 2;;
esac
