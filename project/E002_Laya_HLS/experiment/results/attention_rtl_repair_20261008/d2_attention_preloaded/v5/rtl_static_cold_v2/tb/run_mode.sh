#!/usr/bin/env bash
# SOURCE ONLY. Execute only after a separate Attention runtime release.
set -euo pipefail
export LC_ALL=C
ROOT=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_cold_v2
TB="$ROOT/tb"
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 3 || ! -d "$1" || ! -d "$2" || ! -d "$3" ]]; then
  echo 'usage: run_mode.sh FRESH_EXISTING_RUNTIME_DIR STATIC_BUILD_DIR PREPARED_PAGES_DIR' >&2
  exit 2
fi
runtime="$(readlink -f "$1")"
build="$(readlink -f "$2")"
prepared="$(readlink -f "$3")"
[[ ! -e "$runtime/xsim.dir" && ! -e "$runtime/xsim.log" ]]
[[ -d "$build/xsim.dir" && -f "$prepared/materialization.json" ]]
mapfile -t memh < <(find "$prepared" -maxdepth 1 -type f -name '*.memh' | sort)
mapfile -t data < <(find "$build" -maxdepth 1 -type l -name '*.dat' | sort)
[[ ${#memh[@]} -eq 10 && ${#data[@]} -eq 35 ]]
for path in "${memh[@]}" "${data[@]}"; do ln -s "$(readlink -f "$path")" "$runtime/$(basename "$path")"; done
ln -s "$build/xsim.dir" "$runtime/xsim.dir"
cd "$runtime"
"$XBIN/xsim" att_cold_static -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'ATT_COLD_STATIC_BASE_H0_R0_PASS commands=4' xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)|ATT_COLD_.*(MISMATCH|WATCHDOG|UNKNOWN|DEBT)' xsim.log; then
  echo 'simulation log reports failure' >&2
  exit 1
fi
python3 "$TB/seal_runtime.py" "$runtime"
python3 "$TB/check_runtime_numeric.py" "$runtime" "$runtime/numeric_check.json"
