#!/usr/bin/env bash
set -euo pipefail
exec /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim \
  -testplusarg UVM_VERBOSITY=UVM_NONE \
  -testplusarg UVM_TESTNAME=attention_slice_test_lib \
  -testplusarg UVM_TIMEOUT=20000000000000 \
  --noieeewarnings attention_slice -tclbatch attention_slice.tcl
