#!/usr/bin/env bash
# Dormant source until the distinct_rows3 numerical RTL execution gate is issued.
set -euo pipefail
export LC_ALL=C
XBIN=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ $# -ne 2 ]]; then
  echo 'usage: run_distinct_rows3.sh STATIC_BUILD_DIR PREPARED_FRESH_RUNTIME_DIR' >&2
  exit 2
fi
build="$(readlink -f "$1")"
prepared="$(readlink -f "$2")"
[[ -d "$build/xsim.dir" && -f "$prepared/runtime_input.json" ]]
[[ -L "$prepared/xsim.dir" ]]
[[ "$(readlink -f "$prepared/xsim.dir")" == "$build/xsim.dir" ]]
[[ ! -e "$prepared/xsim.log" ]]
shopt -s nullglob
data=("$build"/*.dat)
[[ ${#data[@]} -eq 108 ]]
for path in "${data[@]}"; do
  name="$(basename "$path")"
  [[ ! -e "$prepared/$name" && ! -L "$prepared/$name" ]]
  ln -s "$(readlink -f "$path")" "$prepared/$name"
done
cd "$prepared"
nice -n 19 ionice -c 3 "$XBIN/xsim" q8_scorer_distinct_rows3 \
  -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'Q8_SCORER_DISTINCT_ROWS3_PASS commands=3 rows=3 K=1024 N=1024' xsim.log
[[ "$(rg -c 'Q8_SCORER_COMMAND_PASS' xsim.log)" == 3 ]]
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)|Q8_SCORER_.*(GUARD|UNKNOWN|MISMATCH|OVERFLOW)' xsim.log; then
  echo 'pilot log reports a failure' >&2
  exit 1
fi
