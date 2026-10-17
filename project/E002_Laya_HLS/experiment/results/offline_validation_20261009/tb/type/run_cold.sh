#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 4 || ( "$1" != qtype2 && "$1" != qtype1 ) ||
      ( "$4" != trace && "$4" != full ) ]]; then
  echo 'usage: run_cold.sh CASE BUILD_DIR PAGES_DIR trace | full R_ORD B_STATE1_ORD B_OBSERVED_ORD STATE1_AW_HEX OBSERVED_AW_HEX' >&2
  exit 2
fi
case_name=$1
build=$(realpath "$2")
pages=$(realpath "$3")
mode=$4
[[ -d "$build/xsim.dir" && -f "$pages/materialization.json" ]]
[[ -L xsim.dir && "$(realpath xsim.dir)" == "$build/xsim.dir" ]]
[[ ! -e xsim.log ]]
for name in hidden_input embedding io aux state0 state1 observed; do
  [[ ! -e "init_${name}.memh" && -f "$pages/init_${name}.memh" ]]
  ln -s "$pages/init_${name}.memh" "init_${name}.memh"
done
shopt -s nullglob
data=("$build"/*.dat)
[[ ${#data[@]} -eq 88 ]]
for path in "${data[@]}"; do
  name=$(basename "$path")
  [[ ! -e "$name" && ! -L "$name" ]]
  ln -s "$path" "$name"
done
tool=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim
args=("type_cold_${case_name}_static" -runall -onerror quit -onfinish quit -log xsim.log)
if [[ "$mode" == trace ]]; then
  [[ $# -eq 4 ]]
  args+=(-testplusarg TYPE_TRACE_ONLY)
else
  [[ $# -eq 9 && $5 =~ ^[0-9]+$ && $6 =~ ^[0-9]+$ && $7 =~ ^[0-9]+$ &&
     $8 =~ ^[0-9a-fA-F]+$ && $9 =~ ^[0-9a-fA-F]+$ ]]
  args+=(-testplusarg "TYPE_R_ORDINAL=$5"
         -testplusarg "TYPE_STATE1_B_ORDINAL=$6"
         -testplusarg "TYPE_OBSERVED_B_ORDINAL=$7"
         -testplusarg "TYPE_STATE1_AW_ADDR=$8"
         -testplusarg "TYPE_OBSERVED_AW_ADDR=$9")
fi
"$tool" "${args[@]}"
if [[ "$mode" == full ]]; then
  rg -Fq "TYPE_COLD_STATIC_TB_DONE case=${case_name}" xsim.log
  if rg -n '(^|[^A-Z])(ERROR|FATAL)([^A-Z]|$)' xsim.log; then
    echo 'Type cold log contains a failure marker' >&2
    exit 1
  fi
fi
