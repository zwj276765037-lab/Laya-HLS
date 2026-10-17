#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 5 ]]; then
  echo 'usage: run_session_dma_act_closure_replay_v2.sh COMPILED_ATTEMPT GENERATED_TB INPUTS VECTORS FRESH_WORK' >&2
  exit 2
fi
compiled=$(realpath "$1")
generated=$(realpath "$2")
inputs=$(realpath "$3")
vectors=$(realpath "$4")
work=$(realpath "$5")
python3 - "$compiled" "$generated" "$inputs" "$vectors" "$work" <<'PY'
import hashlib,json,shutil,sys
from pathlib import Path
c,g,i,v,w=map(Path,sys.argv[1:])
m=json.loads((c/'input_manifest.json').read_text())
assert m['closure_only'] is True
assert json.loads((c/'guard/guard_result.json').read_text())['child_exit_code']==0
assert not any(w.iterdir()), 'fresh work required'
for record in m['files'].values():
 p=Path(record['path'])
 assert p.stat().st_size==record['bytes']
 assert hashlib.sha256(p.read_bytes()).hexdigest()==record['sha256'],p
tb=g/'tm1tn8_session_dma_act_tb.sv'
assert hashlib.sha256(tb.read_bytes()).hexdigest()==m['files']['testbench']['sha256']
assert json.loads((i/'manifest.json').read_text())['trace_on'] is True
s=c/'work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim'
shutil.copytree(s/'xsim.dir',w/'xsim.dir')
shutil.copy2(s/'xsim.ini',w/'xsim.ini')
for p in list(s.glob('*.dat'))+list(s.glob('*.mem')):
 shutil.copy2(p,w/p.name)
records=[]
for p in sorted(w.rglob('*')):
 if p.is_file(): records.append({'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
for folder in (i,v):
 for p in sorted(folder.iterdir()):
  if p.is_file(): records.append({'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(w.parent/'input_manifest.json').write_text(json.dumps({'schema':'q8s2_act_closure_compiled_replay_v1','compiled_from':str(c),'generated_tb':str(tb),'files':records},indent=2,sort_keys=True)+'\n')
print('Q8S2_CLOSURE_COMPILED_IDENTITY_PASS',len(records))
PY
cd "$work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim \
  tm1tn8_session_dma_act_tb_behav -runall -onerror quit -onfinish quit \
  -testplusarg "INPUT_DIR=$inputs" -testplusarg "VEC_DIR=$vectors" \
  -testplusarg CLOSURE_ONLY -log simulate.log
rg -q 'TM1TN8_SESSION_DMA_V2_CLOSURE_PASS profile=1 reject=9 invalidated_ready=2 rebuild_runs=3' simulate.log
rg -q 'TM1TN8_SESSION_DMA_V2_ACT_PASS profile=1 closure_only=1' simulate.log
if rg -q 'Fatal:|ERROR:' simulate.log; then exit 1; fi
echo 'Q8S2_CLOSURE_REPLAY_PASS'
