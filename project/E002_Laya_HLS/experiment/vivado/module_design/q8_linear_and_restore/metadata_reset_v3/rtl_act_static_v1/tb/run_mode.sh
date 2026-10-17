#!/usr/bin/env bash
set -euo pipefail
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 3 ]]; then
  echo 'usage: run_mode.sh {legal|fault_load|identity_reset} STATIC_BUILD_DIR PREPARED_MODE_DIR' >&2
  exit 2
fi
case "$1" in
  legal) mode=0; cases=9; terminal='Q8_ACT_STATIC_LEGAL_PASS commands=9';;
  fault_load) mode=1; cases=3; terminal='Q8_ACT_STATIC_FAULT_LOAD_PASS commands=3';;
  identity_reset) mode=2; cases=24; terminal='Q8_ACT_STATIC_IDENTITY_RESET_PASS commands=24';;
  *) echo 'unknown mode' >&2; exit 2;;
esac
build="$2"
prepared="$3"
[[ -d "$build/xsim.dir" ]]
[[ -f "$prepared/case_manifest.json" && -f "$prepared/descriptor.memh" ]]
[[ -L "$prepared/xsim.dir" ]]
[[ "$(readlink "$prepared/xsim.dir")" == "$(readlink -f "$build/xsim.dir")" ]]
shopt -s nullglob
data=("$build"/*.dat)
[[ ${#data[@]} -eq 108 ]]
for path in "${data[@]}"; do
  name="$(basename "$path")"
  [[ ! -e "$prepared/$name" && ! -L "$prepared/$name" ]]
  ln -s "$(readlink -f "$path")" "$prepared/$name"
done
cd "$prepared"
"$XBIN/xsim" q8_act_static \
  -testplusarg "MODE=$mode" -testplusarg "CASE_COUNT=$cases" \
  -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq "$terminal" xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)|Q8_STATIC_.*(MISMATCH|BOUND|UNKNOWN|UNRETIRED)' xsim.log; then
  echo 'simulation log reports a failure' >&2
  exit 1
fi
