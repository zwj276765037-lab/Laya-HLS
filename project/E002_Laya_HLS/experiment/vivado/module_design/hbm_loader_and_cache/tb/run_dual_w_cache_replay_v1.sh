#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 3 || ! -f "$1/input_manifest.json" || ! -f "$2/fixture_manifest.json" || ! -d "$3" ]]; then
  echo 'usage: run_dual_w_cache_replay_v1.sh PILOT_ATTEMPT FIXTURE FRESH_WORK' >&2
  exit 2
fi
pilot=$(realpath "$1")
fixture=$(realpath "$2")
work=$(realpath "$3")
python3 - "$pilot" "$fixture" "$work" <<'PY'
import hashlib,json,shutil,sys
from pathlib import Path
pilot,fixture,work=map(Path,sys.argv[1:])
assert not any(work.iterdir()),'fresh work required'
assert json.loads((pilot/'guard/guard_result.json').read_text())['child_exit_code']==0
m=json.loads((pilot/'input_manifest.json').read_text())
assert m['schema']=='t4_dual_w_sim_v1' and m['mode']=='pilot'
assert hashlib.sha256((fixture/'fixture_manifest.json').read_bytes()).hexdigest()==m['fixture_manifest_sha256']
fm=json.loads((fixture/'fixture_manifest.json').read_text())
for name,record in fm['files'].items():
 p=fixture/name
 assert p.stat().st_size==record['bytes'] and hashlib.sha256(p.read_bytes()).hexdigest()==record['sha256'],p
for name,record in m['sources'].items():
 p=Path(name)
 assert p.stat().st_size==record['bytes'] and hashlib.sha256(p.read_bytes()).hexdigest()==record['sha256'],p
assert 'T4_DUAL_W_PILOT_PASS' in (pilot/'work/simulate.log').read_text()
shutil.copytree(pilot/'work/xsim.dir',work/'xsim.dir')
snapshot=[]
for p in sorted((work/'xsim.dir').rglob('*')):
 if p.is_file(): snapshot.append({'path':str(p),'bytes':p.stat().st_size,
  'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(work.parent/'input_manifest.json').write_text(json.dumps({'schema':'t4_dual_w_replay_v1',
 'compiled_from':str(pilot),'fixture_manifest_sha256':m['fixture_manifest_sha256'],
 'sources':m['sources'],'snapshot':snapshot},indent=2,sort_keys=True)+'\n')
print('T4_DUAL_W_COMPILED_IDENTITY_PASS',len(snapshot))
PY
cd "$work"
/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xsim \
  t4_dual_w_cache_v1_sim -runall -onerror quit -onfinish quit \
  -testplusarg "FIXTURE=$fixture" -log simulate.log
rg -q 'T4_DUAL_W_FULL_PASS' simulate.log
if rg -q 'Fatal:|ERROR:|FATAL_ERROR:' simulate.log; then exit 1; fi
echo 'T4_DUAL_W_REPLAY_FULL_SCRIPT_PASS'
