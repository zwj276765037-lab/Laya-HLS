#!/usr/bin/env bash
# Source only. XSim execution requires a separate reviewed finite release.
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 2 ]]; then
  echo 'usage: run_boundary.sh STATIC_BUILD_DIR FRESH_RUNTIME_DIR' >&2
  exit 2
fi
build="$(readlink -f "$1")"
runtime="$(readlink -f "$2")"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
[[ -d "$build/xsim.dir" && -d "$runtime" && ! -e "$runtime/xsim.log" && ! -e "$runtime/xsim.dir" ]]
ln -s "$build/xsim.dir" "$runtime/xsim.dir"
cd "$runtime"
"$xbin/xsim" fp_boundary -runall -onerror quit -onfinish quit -log xsim.log
rg -Fq 'FP_CHARACTERIZATION_COMPLETE planned=119 observed=119' xsim.log
rg -Fq 'FP_CONFORMANCE_PASS cases=119 wrappers=7' xsim.log
