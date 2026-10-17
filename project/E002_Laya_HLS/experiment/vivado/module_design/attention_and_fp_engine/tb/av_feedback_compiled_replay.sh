#!/usr/bin/env bash
set -euo pipefail

root=/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline
module=$root/vivado/module_design/attention_and_fp_engine
q8=$root/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512
attempts=$root/results/compute_throughput_optimization_20261010/attempts
xsim_bin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim

if [[ ${1:-} == --execute ]]; then
  shift
  sim_src=$1; gold=$2; mode=$3
  mkdir sim
  cp -a "$sim_src/xsim.dir" "$sim_src/xsim.ini" \
    "$sim_src/av_feedback_real_tb.tcl" sim/
  cd sim
  "$xsim_bin" av_feedback_real_tb_behav \
    -tclbatch av_feedback_real_tb.tcl -log simulate.log \
    -testplusarg "GOLD_DIR=$gold" -testplusarg "MODE=$mode"
  python3 - "$mode" <<'PY'
from pathlib import Path
import sys
output = Path('simulate.log').read_text(errors='replace')
expected = f'AV_FEEDBACK_REAL_PASS mode=C{sys.argv[1]} contributions=4096'
if expected not in output or 'Fatal:' in output or 'ERROR:' in output:
    raise SystemExit('AV compiled replay did not satisfy the full PASS criterion')
print('AV_FEEDBACK_COMPILED_REPLAY_VERIFIED', expected)
PY
  exit 0
fi

if [[ $# -ne 4 ]]; then
  echo 'usage: av_feedback_compiled_replay.sh ATTEMPT_NAME GOLD_DIR COMPILED_C3_ATTEMPT TIMEOUT_SECONDS' >&2
  exit 2
fi
name=$1
gold=$(realpath "$2")
compiled=$attempts/$3
timeout=$4
sim_src=$compiled/work/vivado/av_feedback_real.sim/sim_1/behav/xsim
if [[ ! $name =~ ^t2_[a-z0-9_]+$ || -e "$attempts/$name" ||
      ! $3 =~ ^t2_[a-z0-9_]+$ || ! $timeout =~ ^[0-9]+$ ||
      $timeout -lt 1 || $timeout -gt 3600 || ! -d "$sim_src/xsim.dir" ]]; then
  echo 'invalid fresh attempt, C3 snapshot or timeout' >&2
  exit 2
fi
python3 - "$gold" "$compiled/input_manifest.json" "$compiled/guard/guard_result.json" "$module" <<'PY'
from pathlib import Path
import hashlib, json, sys
gold = Path(sys.argv[1]); compiled = json.loads(Path(sys.argv[2]).read_text())
guard = json.loads(Path(sys.argv[3]).read_text()); module = Path(sys.argv[4])
manifest = json.loads((gold / 'manifest.json').read_text())
assert manifest['schema'] == 'av_feedback_real_gold_v1'
assert (manifest['projected_rows'], manifest['keys'], manifest['products']) == (32, 128, 4096)
assert compiled['exit_code'] == guard['child_exit_code'] == 0
assert compiled['command'][-2:] == [str(gold), '3']
for name, record in manifest['files'].items():
    path = gold / (name + '.mem')
    assert path == Path(record['path']) and path.stat().st_size == record['bytes']
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256']
source_count = 0
for record in compiled['inputs']:
    path = Path(record['path'])
    if path.is_relative_to(module) and (path.suffix in ('.sv', '.tcl', '.sh')):
        assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256'], path
        source_count += 1
assert source_count >= 5
print('AV_FEEDBACK_COMPILED_IDENTITY_PASS', source_count)
PY
cd "$root"
exec python3 "$q8/tb/record_t2_attempt.py" \
  --attempt "$attempts/$name" --rss-gib 8 --timeout-seconds "$timeout" \
  --input-tree "$gold" --input-tree "$sim_src/xsim.dir" \
  --input "$compiled/input_manifest.json" \
  --input "$compiled/guard/guard_result.json" \
  --input "$sim_src/xsim.ini" \
  --input "$sim_src/av_feedback_real_tb.tcl" \
  --input "$module/tb/av_feedback_compiled_replay.sh" -- \
  /bin/bash "$module/tb/av_feedback_compiled_replay.sh" --execute \
  "$sim_src" "$gold" 4
