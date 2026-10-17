#!/usr/bin/env bash
set -euo pipefail

root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module=$root/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
attempts=$root/results/compute_throughput_optimization_20261010/attempts
compiled=$attempts/t2_tm4_real_qkv_lut_pilot_01
sim_src=$compiled/work/vivado/tm4tn8_real_matrix.sim/sim_1/behav/xsim
xsim_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim

if [[ ${1:-} == --execute ]]; then
  shift
  sim_src=$1; streams=$2; rows=$3; K=$4; N=$5
  mkdir sim
  cp -a "$sim_src/xsim.dir" "$sim_src/xsim.ini" \
    "$sim_src/tm4tn8_real_matrix_tb.tcl" sim/
  cd sim
  "$xsim_bin" tm4tn8_real_matrix_tb_behav \
    -tclbatch tm4tn8_real_matrix_tb.tcl -log simulate.log \
    -testplusarg "TM4_STREAM_DIR=$streams" \
    -testplusarg "ROWS=$rows" -testplusarg "K=$K" -testplusarg "N=$N"
  python3 - "$rows" "$K" "$N" <<'PY'
from pathlib import Path
import sys
text = Path('simulate.log').read_text(errors='replace')
expected = f'TM4TN8_REAL_MATRIX_PASS rows={sys.argv[1]} K={sys.argv[2]} N={sys.argv[3]}'
if expected not in text or 'Fatal:' in text or 'ERROR:' in text:
    raise SystemExit('TM4 compiled replay did not satisfy the full PASS criterion')
print('TM4_COMPILED_REPLAY_VERIFIED', expected)
PY
  exit 0
fi

if [[ $# -ne 6 ]]; then
  echo 'usage: run_tm4_compiled_replay.sh ATTEMPT_NAME STREAMS ROWS K N TIMEOUT_SECONDS' >&2
  exit 2
fi
name=$1
streams=$(realpath "$2")
rows=$3; K=$4; N=$5; timeout=$6
if [[ ! $name =~ ^t2_[a-z0-9_]+$ || -e "$attempts/$name" ||
      ! $timeout =~ ^[0-9]+$ || $timeout -lt 1 || $timeout -gt 3600 ]]; then
  echo 'invalid fresh attempt or timeout' >&2
  exit 2
fi
python3 - "$streams" "$rows" "$K" "$N" "$compiled/input_manifest.json" "$module" <<'PY'
from pathlib import Path
import hashlib, json, sys
streams = Path(sys.argv[1]); rows, K, N = map(int, sys.argv[2:5])
compiled = json.loads(Path(sys.argv[5]).read_text())
module = Path(sys.argv[6])
manifest = json.loads((streams / 'manifest.json').read_text())
assert manifest['schema'] == 'tm4_real_streams_v1'
assert (manifest['rows'], manifest['K'], manifest['N']) == (rows, K, N)
assert manifest['stripes'] == manifest['G'] * manifest['T'] <= 21504
for name, record in manifest['files'].items():
    path = streams / (name + '.mem')
    assert path == Path(record['path']) and path.stat().st_size == record['bytes']
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256']
source = manifest['source_manifest']
assert hashlib.sha256(Path(source['path']).read_bytes()).hexdigest() == source['sha256']
assert compiled['command'][-1] == 'lut'
source_count = 0
for record in compiled['inputs']:
    path = Path(record['path'])
    if path.is_relative_to(module) and (path.suffix == '.sv' or
        path.name in ('create_fp_ip.tcl', 'run_tm4tn8_real_matrix.tcl')):
        assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256'], path
        source_count += 1
assert source_count >= 10
print('TM4_COMPILED_IDENTITY_PASS', manifest['case'], manifest['stripes'], source_count)
PY
stream_attempt=$(dirname "$(dirname "$streams")")
[[ -f "$stream_attempt/input_manifest.json" ]]
cd "$root"
exec python3 "$module/tb/record_t2_attempt.py" \
  --attempt "$attempts/$name" --rss-gib 8 --timeout-seconds "$timeout" \
  --input-tree "$streams" --input-tree "$sim_src/xsim.dir" \
  --input "$compiled/input_manifest.json" \
  --input "$stream_attempt/input_manifest.json" \
  --input "$sim_src/xsim.ini" \
  --input "$sim_src/tm4tn8_real_matrix_tb.tcl" \
  --input "$module/tb/run_tm4_compiled_replay.sh" -- \
  /bin/bash "$module/tb/run_tm4_compiled_replay.sh" --execute \
  "$sim_src" "$streams" "$rows" "$K" "$N"
