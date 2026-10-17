#!/usr/bin/env bash
set -euo pipefail

root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module=$root/vivado/module_design/attention_and_fp_engine
q8=$root/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
attempts=$root/results/compute_throughput_optimization_20261010/attempts
vivado_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado
if [[ $# -ne 4 ]]; then
  echo 'usage: av_feedback_real_attempt.sh ATTEMPT_NAME GOLD_DIR {3|4} TIMEOUT_SECONDS' >&2
  exit 2
fi
name=$1
gold=$(realpath "$2")
mode=$3
timeout=$4
if [[ ! $name =~ ^t2_[a-z0-9_]+$ || -e "$attempts/$name" ||
      ( $mode != 3 && $mode != 4 ) ||
      ! $timeout =~ ^[0-9]+$ || $timeout -lt 1 || $timeout -gt 3600 ]]; then
  echo 'invalid fresh attempt, mode or timeout' >&2
  exit 2
fi
python3 - "$gold" <<'PY'
import hashlib, json, sys
from pathlib import Path
directory = Path(sys.argv[1])
manifest = json.loads((directory / 'manifest.json').read_text())
assert manifest['schema'] == 'av_feedback_real_gold_v1'
assert (manifest['projected_rows'], manifest['keys'], manifest['products']) == (32, 128, 4096)
for name, record in manifest['files'].items():
    path = directory / (name + '.mem')
    assert path == Path(record['path']) and path.stat().st_size == record['bytes']
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256']
for record in [manifest['capture_source_manifest'], manifest['request']['request'],
               manifest['reference'], manifest['generator'],
               *manifest['producer_planes'].values()]:
    path = Path(record['path'])
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256']
print('AV_FEEDBACK_REAL_GOLD_IDENTITY_PASS')
PY
cd "$root"
exec python3 "$q8/tb/record_t2_attempt.py" \
  --attempt "$attempts/$name" --rss-gib 8 --timeout-seconds "$timeout" \
  --input-tree "$gold" \
  --input "$module/rtl/av_feedback_bank_v1.sv" \
  --input "$module/tb/av_feedback_real_tb.sv" \
  --input "$module/tb/av_feedback_short_tb.sv" \
  --input "$module/tb/av_feedback_real.tcl" \
  --input "$module/tb/av_feedback_real_attempt.sh" \
  --input "$q8/tb/create_fp_ip.tcl" -- \
  "$vivado_bin" -mode batch -source "$module/tb/av_feedback_real.tcl" \
  -tclargs "$attempts/$name/work" "$gold" "$mode"
