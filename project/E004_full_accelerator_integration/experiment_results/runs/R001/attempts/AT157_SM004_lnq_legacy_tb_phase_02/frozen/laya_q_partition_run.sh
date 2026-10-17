#!/usr/bin/env bash
set -euo pipefail
mode=$1
attempt=$2
bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
cd "$attempt/work"
case "$mode" in
  static)
    "$bin/xvhdl" -work xil_defaultlib "$attempt"/frozen/*.vhd
    "$bin/xvlog" "$attempt"/frozen/laya_quant16_functional_*.v
    "$bin/xvlog" --sv "$attempt/frozen/r0_fp_bits_pkg.sv" \
      "$attempt"/frozen/quant16_*.sv
    "$bin/xelab" work.quant16_stream_row_tb -L xil_defaultlib \
      -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
      --relax -mt off -s q_partition
    echo Q_PARTITION_STATIC_PASS
    ;;
  sim)
    "$bin/xsim" q_partition -runall \
      -testplusarg FIXTURE="$attempt/frozen/q_fixture" \
      -testplusarg ADAPTER="$attempt/frozen/adapter_fixture" | tee q_sim.log
    grep -q '^QUANT16_STREAM_REAL_ROWS_PASS groups=114 q_bytes=3648 edges=2 protocol=1 numerical=5 reset=2' q_sim.log
    grep -q '^QUANT16_ADAPTER_CASES_PASS count=27 independent_reference=R0_finite_v2' q_sim.log
    grep -q '^QUANT16_METADATA_CASES_PASS count=4 real_handshake=1 controlled_return_data=1' q_sim.log
    ! grep -Eq '(Fatal:|ERROR:)' q_sim.log
    ;;
  *) exit 2;;
esac
