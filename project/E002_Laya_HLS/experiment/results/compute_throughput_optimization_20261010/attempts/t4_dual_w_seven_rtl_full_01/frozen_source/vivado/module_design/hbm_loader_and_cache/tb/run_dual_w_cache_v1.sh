#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 3 || ! -d "$1" || ! -f "$2/fixture_manifest.json" || "$3" != pilot && "$3" != full ]]; then
  echo 'usage: run_dual_w_cache_v1.sh FRESH_WORK FIXTURE {pilot|full}' >&2
  exit 2
fi
work=$(realpath "$1")
fixture=$(realpath "$2")
mode=$3
module=$(realpath "$(dirname "$0")/..")
xbin=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
if [[ -n "$(find "$work" -mindepth 1 -print -quit)" ]]; then
  echo 'fresh work directory required' >&2
  exit 2
fi
python3 - "$module" "$fixture" "$work" "$mode" <<'PY'
import hashlib,json,sys
from pathlib import Path
module,fixture,work=map(Path,sys.argv[1:4]);mode=sys.argv[4]
m=json.loads((fixture/'fixture_manifest.json').read_text())
assert m['schema']=='t4_dual_w_fixture_v1'
for name,record in m['files'].items():
 p=fixture/name
 assert p.stat().st_size==record['bytes'] and hashlib.sha256(p.read_bytes()).hexdigest()==record['sha256'],p
files=[module/'rtl'/f for f in ('t4_w_reader_port_v1.sv','t4_three_port_reader_v1.sv',
 't4_aux_bias_reader_v1.sv','t4_w_cache_bank_v1.sv','t4_dual_w_cache_v1.sv')]
files.append(module/'tb/t4_dual_w_cache_tb_v1.sv')
records={str(p):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files}
(work.parent/'input_manifest.json').write_text(json.dumps({'schema':'t4_dual_w_sim_v1',
 'mode':mode,'fixture_manifest':str(fixture/'fixture_manifest.json'),
 'fixture_manifest_sha256':hashlib.sha256((fixture/'fixture_manifest.json').read_bytes()).hexdigest(),
 'sources':records},indent=2,sort_keys=True)+'\n')
PY
cd "$work"
"$xbin/xvlog" --sv -work xil_defaultlib \
  "$module/rtl/t4_w_reader_port_v1.sv" \
  "$module/rtl/t4_three_port_reader_v1.sv" \
  "$module/rtl/t4_aux_bias_reader_v1.sv" \
  "$module/rtl/t4_w_cache_bank_v1.sv" \
  "$module/rtl/t4_dual_w_cache_v1.sv" \
  "$module/tb/t4_dual_w_cache_tb_v1.sv" -log xvlog.log
"$xbin/xelab" xil_defaultlib.t4_dual_w_cache_tb_v1 \
  --relax -mt off -s t4_dual_w_cache_v1_sim -log xelab.log
plusargs=(-testplusarg "FIXTURE=$fixture")
if [[ "$mode" == pilot ]]; then plusargs+=(-testplusarg PILOT); fi
"$xbin/xsim" t4_dual_w_cache_v1_sim -runall -onerror quit -onfinish quit \
  "${plusargs[@]}" -log simulate.log
if [[ "$mode" == pilot ]]; then
  rg -q 'T4_DUAL_W_PILOT_PASS' simulate.log
else
  rg -q 'T4_DUAL_W_FULL_PASS' simulate.log
fi
if rg -q 'Fatal:|ERROR:|FATAL_ERROR:' simulate.log; then exit 1; fi
echo "T4_DUAL_W_${mode^^}_SCRIPT_PASS"
