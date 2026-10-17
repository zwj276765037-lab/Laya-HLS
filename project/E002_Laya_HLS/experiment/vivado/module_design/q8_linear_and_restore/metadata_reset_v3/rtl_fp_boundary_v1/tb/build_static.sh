#!/usr/bin/env bash
# Source only. Vivado execution requires a separate reviewed finite release.
set -euo pipefail
export LC_ALL=C
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo 'usage: build_static.sh FRESH_EXISTING_BUILD_DIR' >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
build="$(readlink -f "$1")"
release=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_actual_fp_boundary_source_preparation_release.json
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
[[ ! -e "$build/xsim.dir" && ! -e "$build/xvhdl.log" && ! -e "$build/xvlog.log" && ! -e "$build/xelab.log" ]]
python3 "$root/tb/verify_source_binding.py" "$root/source/source_packet.json" --out "$build/source_pre.json"
python3 - "$release" "$build" <<'PY'
import json, pathlib, sys
release=json.loads(pathlib.Path(sys.argv[1]).read_text())
build=pathlib.Path(sys.argv[2])
wrappers=release['exact_wrappers']
assert len(wrappers)==7
for key, name in [('simulation_vhdl','vhdl.list'),('outer_verilog','verilog.list')]:
    (build/name).write_text(''.join(row[key]['path']+'\n' for row in wrappers))
PY
mapfile -t vhdl < "$build/vhdl.list"
mapfile -t verilog < "$build/verilog.list"
[[ ${#vhdl[@]} -eq 7 && ${#verilog[@]} -eq 7 ]]
cd "$build"
"$xbin/xvhdl" -work xil_defaultlib "${vhdl[@]}" -log xvhdl.log
"$xbin/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog.log
"$xbin/xvlog" --sv -work xil_defaultlib -i "$root/tb" "$root/tb/fp_boundary_top.sv" -log xvlog_tb.log
"$xbin/xelab" xil_defaultlib.fp_boundary_top \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s fp_boundary -log xelab.log
python3 "$root/tb/verify_source_binding.py" "$root/source/source_packet.json" \
  --snapshot "$build/xsim.dir" --out "$build/source_snapshot_post.json"
