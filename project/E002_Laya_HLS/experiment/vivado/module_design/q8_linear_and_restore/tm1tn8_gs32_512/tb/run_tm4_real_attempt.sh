#!/usr/bin/env bash
set -euo pipefail

root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module=$root/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
attempts=$root/results/compute_throughput_optimization_20261010/attempts
vivado_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado
if [[ $# -ne 7 ]]; then
  echo 'usage: run_tm4_real_attempt.sh ATTEMPT_NAME STREAMS ROWS K N {lut|packed} TIMEOUT_SECONDS' >&2
  exit 2
fi
name=$1
streams=$(realpath "$2")
rows=$3
K=$4
N=$5
candidate=$6
timeout=$7
if [[ ! $name =~ ^t2_[a-z0-9_]+$ || -e "$attempts/$name" ||
      ( $candidate != lut && $candidate != packed ) ||
      ! $timeout =~ ^[0-9]+$ || $timeout -lt 1 || $timeout -gt 3600 ]]; then
  echo 'invalid fresh attempt, candidate or timeout' >&2
  exit 2
fi
python3 - "$streams" "$rows" "$K" "$N" <<'PY'
import hashlib
import json
from pathlib import Path
import sys

directory = Path(sys.argv[1])
manifest = json.loads((directory / "manifest.json").read_text())
assert manifest["schema"] == "tm4_real_streams_v1"
assert (manifest["rows"], manifest["K"], manifest["N"]) == tuple(map(int, sys.argv[2:]))
assert manifest["stripes"] == manifest["G"] * manifest["T"]
assert manifest["stripes"] <= 21504
for name, record in manifest["files"].items():
    path = Path(record["path"])
    assert path == directory / (name + ".mem")
    assert path.stat().st_size == record["bytes"]
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record["sha256"]
source = manifest["source_manifest"]
assert hashlib.sha256(Path(source["path"]).read_bytes()).hexdigest() == source["sha256"]
print("TM4_REAL_STREAM_IDENTITY_PASS", manifest["case"], manifest["stripes"])
PY
stream_attempt=$(dirname "$(dirname "$streams")")
[[ -f "$stream_attempt/input_manifest.json" ]]
rtl=(
  "$module/rtl/tm1tn8_integer_tree_lut.sv"
  "$module/rtl/tm1tn8_integer_tree_packed.sv"
  "$module/rtl/tm1tn8_signed_pack_pair.sv"
  "$module/rtl/tm4tn8_tag_v1.sv"
  "$module/rtl/tm4tn8_reserved_store_v1.sv"
  "$module/rtl/tm4tn8_fp_restore_v1.sv"
  "$module/rtl/tm4tn8_row_pipeline_v1.sv"
  "$module/rtl/tm4tn8_microbench_v1.sv"
)
inputs=(
  --input "$module/tb/run_tm4_real_attempt.sh"
  --input "$module/tb/run_tm4tn8_real_matrix.tcl"
  --input "$module/tb/tm4tn8_real_matrix_tb.sv"
  --input "$module/tb/create_fp_ip.tcl"
  --input "$stream_attempt/input_manifest.json"
)
for file in "${rtl[@]}"; do inputs+=(--input "$file"); done
cd "$root"
exec python3 "$module/tb/record_t2_attempt.py" \
  --attempt "$attempts/$name" --rss-gib 8 --timeout-seconds "$timeout" \
  --input-tree "$streams" "${inputs[@]}" -- \
  "$vivado_bin" -mode batch -source "$module/tb/run_tm4tn8_real_matrix.tcl" \
  -tclargs "$attempts/$name/work" "$streams" "$rows" "$K" "$N" "$candidate"
