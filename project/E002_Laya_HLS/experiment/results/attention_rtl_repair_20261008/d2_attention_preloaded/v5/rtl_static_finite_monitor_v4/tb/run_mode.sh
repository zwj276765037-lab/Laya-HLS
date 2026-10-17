#!/usr/bin/env bash
# SOURCE ONLY. Execute one mode only after its separate runtime release.
set -euo pipefail
export LC_ALL=C
ROOT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_finite_monitor_v4
TB="$ROOT/tb"
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 4 || "$1" != base_h15_r63 ||
      ! -d "$2" || ! -d "$3" || ! -d "$4" ]]; then
  echo 'usage: run_mode.sh base_h15_r63 FRESH_RUNTIME_DIR MATCHING_STATIC_BUILD_DIR MATCHING_PREPARED_DIR' >&2
  exit 2
fi
mode="$1"
runtime="$(readlink -f "$2")"
build="$(readlink -f "$3")"
prepared="$(readlink -f "$4")"
[[ ! -e "$runtime/xsim.dir" && ! -e "$runtime/xsim.log" ]]
[[ -d "$build/xsim.dir" && -f "$prepared/materialization.json" ]]
python3 - "$mode" "$prepared/materialization.json" <<'PY'
import json,sys
mode,filename=sys.argv[1:]
record=json.load(open(filename))
assert record['schema']=='attention_v5_finite_page_materialization_v1'
assert record['mode']==mode and record['status']=='HOST_SOURCE_AND_FULL_IMAGE_CHECK_ONLY_NO_EDA'
PY
mapfile -t memh < <(find "$prepared" -maxdepth 1 -type f -name '*.memh' | sort)
mapfile -t data < <(find "$build" -maxdepth 1 -type l -name '*.dat' | sort)
[[ ${#memh[@]} -eq 10 && ${#data[@]} -eq 35 ]]
for path in "${memh[@]}" "${data[@]}"; do
  ln -s "$(readlink -f "$path")" "$runtime/$(basename "$path")"
done
ln -s "$build/xsim.dir" "$runtime/xsim.dir"
cd "$runtime"
"$XBIN/xsim" "att_finite_${mode}_static" -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq "ATT_FINITE_STATIC_${mode}_PASS commands=4" xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)|ATT_FINITE_.*(MISMATCH|WATCHDOG|UNKNOWN|DEBT)' xsim.log; then
  echo 'simulation log reports failure' >&2
  exit 1
fi
python3 "$TB/seal_runtime.py" "$mode" "$runtime"
python3 "$TB/check_runtime_numeric.py" "$mode" "$runtime" "$runtime/numeric_check.json"
