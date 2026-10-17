#!/usr/bin/env bash
# Source only. Actual Vivado compile needs a separately reviewed finite gate.
set -euo pipefail
export LC_ALL=C PYTHONDONTWRITEBYTECODE=1
if [[ $# -ne 2 || ! -d "$1" || ! -d "$2" ]]; then
  echo 'usage: build_static.sh VECTORS_DIR FRESH_EXISTING_BUILD_DIR' >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
vectors="$(readlink -f "$1")"
build="$(readlink -f "$2")"
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
[[ ! -e "$build/xsim.dir" && ! -e "$build/xvhdl.log" &&
   ! -e "$build/xvlog.log" && ! -e "$build/xelab.log" &&
   ! -e "$build/source_pre.json" ]]
/usr/bin/python3 "$root/tb/verify_generated_vectors.py" "$vectors"
/usr/bin/python3 "$root/tb/verify_source_binding.py" "$root/source/source_packet.json" \
  --out "$build/source_pre.json"
/usr/bin/python3 - "$root/source/source_packet.json" "$build" <<'PY'
import json
from pathlib import Path
import sys
packet = json.loads(Path(sys.argv[1]).read_text())
build = Path(sys.argv[2])
for kind, name in (("simulation_vhdl", "vhdl.list"),
                   ("outer_verilog", "verilog.list")):
    rows = [item["path"] for item in packet["source_inputs"] if item["kind"] == kind]
    if len(rows) != 7:
        raise RuntimeError(f"expected seven {kind} files")
    (build / name).write_text("\n".join(rows) + "\n")
PY
mapfile -t vhdl < "$build/vhdl.list"
mapfile -t verilog < "$build/verilog.list"
cd "$build"
timeout -k 5 900 "$xbin/xvhdl" -work xil_defaultlib "${vhdl[@]}" -log xvhdl.log
timeout -k 5 900 "$xbin/xvlog" -work xil_defaultlib "${verilog[@]}" -log xvlog.log
timeout -k 5 900 "$xbin/xvlog" --sv -work xil_defaultlib -i "$vectors" \
  "$root/rtl/r0_fp_bits_pkg.sv" "$root/tb/r0_adapter_probe_top.sv" -log xvlog_tb.log
timeout -k 5 900 "$xbin/xelab" xil_defaultlib.r0_adapter_probe_top \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off -s r0_adapter_probe -log xelab.log
/usr/bin/python3 "$root/tb/verify_source_binding.py" "$root/source/source_packet.json" \
  --snapshot "$build/xsim.dir" --out "$build/source_snapshot_post.json"
