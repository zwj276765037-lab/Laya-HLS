#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 3 || ! -d "$1" || ! -d "$2" ||
      ( "$3" != continuous && "$3" != stall ) ]]; then
  echo 'usage: tanh_service_run.sh STATIC_BUILD REAL_REFERENCE_DIR continuous|stall' >&2
  exit 2
fi
build=$(realpath "$1")
reference=$(realpath "$2")
mode=$3
[[ -x "$build/xsim.dir/tanh_service_static/xsimk" &&
   -f "$reference/z.mem" && -f "$reference/tanh.mem" ]]
run="$build/run_$mode"
mkdir "$run"
ln -s "$build/xsim.dir" "$run/xsim.dir"
for path in "$build"/*.dat; do ln -s "$path" "$run/$(basename "$path")"; done
plus=()
if [[ "$mode" == stall ]]; then plus=(--testplusarg STALL); fi
cd "$run"
xsim=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim
"$xsim" tanh_service_static -runall -onerror quit -onfinish quit \
  --testplusarg "Z_FILE=$reference/z.mem" \
  --testplusarg "GOLD_FILE=$reference/tanh.mem" \
  "${plus[@]}" -log xsim.log
rg -Fq "TANH_SERVICE_RTL_PASS count=2624" xsim.log
rg -Fq "stall=$([[ "$mode" == stall ]] && echo 1 || echo 0)" xsim.log
if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
  echo 'tanh service log contains failure marker' >&2
  exit 1
fi
