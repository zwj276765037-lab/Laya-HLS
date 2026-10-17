#!/usr/bin/bash
# Source prepared only. A separate reviewed gate must release this one run.
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 6 ]]; then
  echo 'usage: /usr/bin/bash run_mode3.sh STATIC_BUILD_ROOT RUNTIME_ROOT PREPARED_ROOT DUT_CYCLE_LIMIT TOTAL_CYCLE_LIMIT PACKET' >&2
  exit 2
fi
STATIC_BUILD_ROOT=$1
RUNTIME_ROOT=$2
PREPARED_ROOT=$3
DUT_CYCLE_LIMIT=$4
TOTAL_CYCLE_LIMIT=$5
PACKET=$6
MODULE_ROOT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_controller_reachable/rtl_static_mode3_alias_v2
VIVADO_BIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
python3 "$MODULE_ROOT/tb/verify_binding.py" "$PACKET" \
  --stage runtime --static-build-root "$STATIC_BUILD_ROOT" \
  --runtime-root "$RUNTIME_ROOT" --prepared-root "$PREPARED_ROOT"
if [[ ! -d "$RUNTIME_ROOT" || -e "$RUNTIME_ROOT/xsim.dir" || -e "$RUNTIME_ROOT/xsim.log" ]]; then
  echo 'runtime directory must exist and be fresh' >&2
  exit 2
fi
if [[ ! $DUT_CYCLE_LIMIT =~ ^[1-9][0-9]*$ || ! $TOTAL_CYCLE_LIMIT =~ ^[1-9][0-9]*$ ]]; then
  echo 'cycle limits must be positive decimal integers' >&2
  exit 2
fi
if (( TOTAL_CYCLE_LIMIT < DUT_CYCLE_LIMIT )); then
  echo 'total cycle limit must cover DUT limit' >&2
  exit 2
fi
ln -s "$STATIC_BUILD_ROOT/xsim.dir" "$RUNTIME_ROOT/xsim.dir"
mapfile -t data < <(find "$STATIC_BUILD_ROOT" -maxdepth 1 -type l -name '*.dat' | sort)
[[ ${#data[@]} -eq 73 ]]
for path in "${data[@]}"; do
  ln -s "$(readlink -f "$path")" "$RUNTIME_ROOT/$(basename "$path")"
done
for name in init_src0_input init_src1_input init_io init_aux init_state0 init_state1 init_observed expected_state1 expected_observed; do
  ln -s "$PREPARED_ROOT/$name.memh" "$RUNTIME_ROOT/$name.memh"
done
cd "$RUNTIME_ROOT"
sim_status=0
"$VIVADO_BIN/xsim" vector_mode3_static -runall -onerror quit -onfinish quit \
  -testplusarg "MODE3_DUT_LIMIT=$DUT_CYCLE_LIMIT" \
  -testplusarg "MODE3_TOTAL_LIMIT=$TOTAL_CYCLE_LIMIT" -log xsim.log || sim_status=$?
seal_status=0
python3 "$MODULE_ROOT/tb/seal_runtime.py" "$PACKET" \
  "$STATIC_BUILD_ROOT" "$RUNTIME_ROOT" "$sim_status" || seal_status=$?
# The first XSim failure remains the command's exit status even if archival
# also finds a problem. A successful XSim still requires a successful seal.
if (( sim_status != 0 )); then exit "$sim_status"; fi
if (( seal_status != 0 )); then exit "$seal_status"; fi
python3 "$MODULE_ROOT/tb/check_runtime_mode3.py" "$RUNTIME_ROOT" \
  "$RUNTIME_ROOT/independent_numeric_check.json"
