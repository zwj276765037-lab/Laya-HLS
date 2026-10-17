#!/usr/bin/env bash
set -euo pipefail
mode=$1
attempt=$2
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
case "$mode" in
  host)
    g++ -std=c++20 -O2 -fno-fast-math -ffp-contract=off "$attempt/frozen/ln_leaf_oracle.cpp" -o ln_leaf_oracle
    ./ln_leaf_oracle > oracle.mem
    test "$(wc -l < oracle.mem)" -eq 16
    ;;
  static)
    "$bin/xvhdl" -work xil_defaultlib "$attempt/frozen/ln_sqrt_ip.vhd"
    "$bin/xvlog" "$attempt/frozen/ln_mul.v" "$attempt/frozen/ln_div.v" "$attempt/frozen/ln_sqrt.v"
    "$bin/xvlog" --sv "$attempt/frozen/ln_leaf_probe_tb.sv"
    "$bin/xelab" work.ln_leaf_probe_tb -L xil_defaultlib -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip --relax -mt off -s ln_leaf_probe
    echo LN_LEAF_STATIC_PASS
    ;;
  sim)
    "$bin/xsim" ln_leaf_probe -runall -testplusarg ORACLE="$attempt/work/oracle.mem"
    ;;
  *) exit 2;;
esac
