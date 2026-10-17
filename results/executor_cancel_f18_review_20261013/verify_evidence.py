from pathlib import Path
from datetime import datetime, timezone
import json, hashlib, shutil, difflib, struct, re

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
RUNS = ROOT / 'project/E003_production_chain_closure/experiment_results/runs/R003'
cache = {}
def sha(p):
    p = Path(p)
    if str(p) not in cache:
        cache[str(p)] = hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
    return cache[str(p)]
def read(p): return json.loads(Path(p).read_text())
snapshots = {}
def snap(p):
    p = Path(p); t = OUT / 'snapshot' / p.relative_to(ROOT)
    t.parent.mkdir(parents=True, exist_ok=True)
    if not t.exists(): shutil.copyfile(p, t)
    assert sha(p) == sha(t)
    snapshots[str(t.relative_to(ROOT))] = sha(t)
def entries(x):
    if isinstance(x, dict):
        if 'original' in x and 'frozen' in x: yield x
        else:
            for v in x.values(): yield from entries(v)
    elif isinstance(x, list):
        for v in x: yield from entries(v)
def refs(x, origin):
    if isinstance(x, dict):
        if isinstance(x.get('path'), str) and isinstance(x.get('sha256'), str):
            actual = sha(x['path'])
            yield dict(origin=origin, path=x['path'], expected=x['sha256'], actual=actual, match=actual == x['sha256'])
        for v in x.values(): yield from refs(v, origin)
    elif isinstance(x, list):
        for v in x: yield from refs(v, origin)

aggregate_path=RUNS/'executor_cancel_f18_deliverables_20261013.json'
assert sha(aggregate_path)=='8a50a0a7436b8a0e93313401942d892539ec9b48b9f29311313210d89e0bf405'
delivered=read(aggregate_path)['artifacts'];assert len(delivered)==14;snap(aggregate_path)
for item in delivered:assert sha(item['path'])==item['sha256'];snap(item['path'])
engineering=read(RUNS/'executor_cancel_f18_verification_02_20261013.json')
old_audit=read(RUNS/'executor_cancel_f18_verification_20261013.json');snap(RUNS/'executor_cancel_f18_verification_20261013.json')
assert engineering['passed'] and not old_audit['passed']
delta=read(RUNS/'executor_cancel_f18_catalog_delta_20261013.json'); after={x['after']['path']:x['after']['sha256'] for x in delta['changes']}
names=['executor_handoff_shell_rtl_04','executor_handoff_portal_rtl_04','executor_cancel_drain_host_02','executor_actor_host_06','graph_program_top_host_04']
pairs=[];references=[];stages=[];manifests={};warnings={}
for name in names:
 base=RUNS/name;m=read(base/'input_manifest.json');rc=read(base/'receipt.json');manifests[name]=m;assert rc['status']=='PASS'
 for e in entries(m):
  a,b=e['original'],e['frozen'];assert sha(b['path'])==a['sha256']==b['sha256']
  pairs.append(dict(attempt=name,path=a['path'],frozen_path=b['path'],expected=a['sha256'],current=sha(a['path']),current_match=sha(a['path'])==a['sha256'],frozen_match=True,pair_match=True));snap(b['path'])
  if sha(a['path'])!=a['sha256']:snap(a['path'])
 references.extend(refs(m,name+'/manifest'));references.extend(refs(rc,name+'/receipt'))
 launcher=read(base/'launcher.json');snap(base/'launcher.json')
 assert launcher['pass'] and launcher['cpu_affinity']==[0,1,2,3] and launcher['nice']==19 and launcher['ionice']=='idle' and launcher['mem_available_kib']>=201326592
 if name=='graph_program_top_host_04':
  dirs=[RUNS/'guard_graph_program_top_host_04']
  assert all(c['exit_code']==0 and not c['timeout'] for c in rc['commands'])
  for c in rc['commands']:snap(c['log']['path'])
 else:dirs=sorted(base.glob('guard*'))
 for gd in dirs:
  guard=read(gd/'guard_result.json');plan=read(gd/'guard_plan.json');launch=read(gd/'launch.json');policy=read(gd/'policy_checks.json') if (gd/'policy_checks.json').exists() else []
  raw=(gd/'driver.log').read_text();markers=[l for l in raw.splitlines() if l.startswith('FULL_') and '_PASS' in l]
  mode=gd.name.removeprefix('guard_');max_sec,max_rss=(120,8388608) if '_rtl_' in name else (1800,25165824)
  if gd.name=='guard':assert guard==rc['guard_result'] and all(x in markers for x in rc['marker'])
  elif mode in rc:assert guard==rc[mode]['guard'] and rc[mode]['runner_exit_code']==0 and all(x in markers for x in rc[mode]['markers'])
  else:
   assert name=='graph_program_top_host_04' and any(str(base) in x for x in plan['command'])
   assert all(x in raw or any(x in Path(c['log']['path']).read_text() for c in rc['commands']) for x in rc['markers'])
  assert guard['child_exit_code']==0 and guard['trigger'] is None
  assert plan['maximum_seconds']==max_sec and plan['maximum_owned_rss_kb']==max_rss and plan['semantic_stall_seconds']==120 and plan['minimum_mem_available_kb']==201326592
  assert guard['elapsed_seconds']<=max_sec and guard['minimum_mem_available_kb']>=201326592
  assert all(p['matches'] and p['affinity']==[0,1,2,3] and p['nice']==19 and p['ionice']=='idle' for p in policy)
  if guard['rss_captured']:assert guard['peak_owned_rss_kb']<=max_rss and policy
  else:assert (name,mode) in [('executor_handoff_shell_rtl_04','oracle'),('executor_cancel_drain_host_02','run'),('executor_actor_host_06','run')] and guard['peak_owned_rss_kb'] is None and not policy and guard['rss_capture_count']==0
  for f in ['guard_plan.json','guard_result.json','launch.json','policy_checks.json','driver.log']:
   if (gd/f).exists():snap(gd/f)
  stages.append(dict(attempt=name,mode=mode,directory=str(gd),start=launch['at'],finish=guard['finished_at'],guard=guard,plan=plan,policy_count=len(policy),markers=markers))
  warnings[name+'/'+mode]=raw.count('contains leftover data')
 for folder in ['fixture','control_fixture']:
  if (base/folder).exists():
   for p in (base/folder).rglob('*'):
    if p.is_file() and p.stat().st_size<2000000:snap(p)
ordered=sorted(stages,key=lambda x:x['start']);assert all(datetime.fromisoformat(a['finish'])<=datetime.fromisoformat(b['start']) for a,b in zip(ordered,ordered[1:]))
assert len(stages)==10 and sum(s['policy_count'] for s in stages)==84
assert len(pairs)==273 and len(references)==719
changes=[{**x,'matches_catalog':after.get(x['path'])==x['current']} for x in pairs if not x['current_match']]
assert len(changes)==8 and all(x['matches_catalog'] for x in changes)
assert sum(x['match'] for x in references)==711
history=[]
for record in read(RUNS/'executor_cancel_f18_history_20261013.json'):
 oldname,newname=record['before'],record['after'];oldm=read(RUNS/oldname/'input_manifest.json');newm=read(RUNS/newname/'input_manifest.json')
 old={x['original']['path']:x for x in entries(oldm)};new={x['original']['path']:x for x in entries(newm)};changed=[]
 for path in old.keys()&new.keys():
  a,b=old[path]['frozen'],new[path]['frozen'];assert sha(a['path'])==a['sha256'] and sha(b['path'])==b['sha256']
  if a['sha256']!=b['sha256']:
   changed.append(path);snap(a['path']);snap(b['path'])
   if Path(path).suffix in ['.cpp','.h','.sv','.py','.json','.md']:
    q=OUT/'diff'/(oldname+'__'+newname)/(Path(path).name+'.diff');q.parent.mkdir(parents=True,exist_ok=True)
    q.write_text(''.join(difflib.unified_diff(Path(a['path']).read_text().splitlines(True),Path(b['path']).read_text().splitlines(True),fromfile=oldname+'/'+Path(path).name,tofile=newname+'/'+Path(path).name)))
 assert len(old.keys()&new.keys())==record['common_pair_count']
 assert set(changed)=={x['original'] for x in record['changed']}
 for name in [oldname,newname]:
  for f in ['input_manifest.json','receipt.json']:snap(RUNS/name/f)
 history.append(dict(before=oldname,after=newname,common=record['common_pair_count'],changed=sorted(changed),added=sorted(new.keys()-old.keys()),removed=sorted(old.keys()-new.keys())))
# Direct byte checks and literal reconstruction; no DUT or fixture runner executes.
base=RUNS/'executor_handoff_portal_rtl_04/fixture';cap=base/'actual_handoff_checkpoint.hex'
rows=cap.read_text().split();assert len(rows)==16 and all(len(x)==128 for x in rows)
raw=b''.join(bytes.fromhex(x)[::-1] for x in rows);assert raw==(base/'checkpoint_good.bin').read_bytes()
assert sha(cap)=='c2442fd8a8c35c39777229f95075c47958fde0c77c41dd8e52affa5b82a9ccc6' and hashlib.sha256(raw).hexdigest()=='05fd66a4d50e3bcca0d086a3cb2503202f595ed10a6d1e287cc817a34e1a64a6'
fixture=RUNS/'executor_cancel_drain_host_02/fixture';identity=(fixture/'v2/v1/snapshot_request.bin').read_bytes()[64:148]
owner=bytearray(19);struct.pack_into('<IBBBB',owner,0,1,1,0,0,0);owner[8:12]=bytes([2,0,255,0]);struct.pack_into('<HHH',owner,12,0,64,1024);owner[18]=1
cmd=bytearray(256);struct.pack_into('<IHH',cmd,0,0x3150474c,1,4);cmd[8]=1;struct.pack_into('<I',cmd,16,1);cmd[64:148]=identity;struct.pack_into('<Q',cmd,160,1);cmd[168:187]=owner
act=bytearray(512);struct.pack_into('<IHH5B',act,0,0x3158414c,1,8,2,0,0x11,2,1);struct.pack_into('<Q',act,24,1);act[64:148]=identity;struct.pack_into('<Q',act,168,1);act[176:195]=owner;act[224:228]=bytes([1,2,0,0]);struct.pack_into('<Q',act,232,1);act[257]=255
pending=bytearray(1024);struct.pack_into('<IHHB',pending,0,0x3150414c,1,16,1);struct.pack_into('<4Q',pending,16,29,101,1,19);pending[256:512]=cmd;pending[512:]=act
completion=bytearray(256);struct.pack_into('<IHH5B',completion,0,0x3143414c,1,4,2,0,0x11,2,1);struct.pack_into('<I',completion,16,79)
result=bytearray(256);struct.pack_into('<IHHB',result,0,0x3152474c,1,4,1);struct.pack_into('<I',result,16,15)
for p in [completion,result]:
 struct.pack_into('<Q',p,24,1);p[64:148]=identity;struct.pack_into('<H',p,148,7);struct.pack_into('<IQ',p,152,0x0700000e,2**64-1);p[201:203]=bytes([255,255])
for name,p in [('pending.bin',pending),('cancel_completion.bin',completion),('cancel_result.bin',result)]:assert bytes(p)==(fixture/name).read_bytes()
sv=(RUNS/'executor_cancel_drain_host_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_program_pending_layout_v1.sv').read_text()
for k,n in dict(BYTES=1024,BEATS=16,VERSION=1,SESSION_OFFSET=16,REQUEST_OFFSET=24,SEQUENCE_OFFSET=32,HANDOFF_OFFSET=40,COMMAND_OFFSET=256,ACTION_OFFSET=512).items():assert re.search(r'\b'+k+r'\s*=\s*'+str(n)+r'\s*[,;]',sv)
assert "MAGIC=32'h3150414c" in sv
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json','.research-agent/communications/executor-cancel-f18-milestone-20261013.json','results/executor_revoke_unaccepted_action_contract_20261013.md','results/executor_handoff_shell_reply_20261013.md','results/executor_handoff_shell_review_literal_correction_20261013.md']:
 snap(ROOT/f)
for f in ['experiment_source/summary.md','experiment_results/summary.md','experiment_status/summary.md']:snap(ROOT/'project/E003_production_chain_closure'/f)
summary=dict(pairs=len(pairs),frozen_matches=len(pairs),declared_pairs=len(pairs),current_matches=sum(x['current_match'] for x in pairs),references=len(references),reference_matches=sum(x['match'] for x in references),deliverables=len(delivered),guards=len(stages),policy_records=84,unobserved_child_stages=[dict(attempt=x['attempt'],mode=x['mode'],elapsed=x['guard']['elapsed_seconds']) for x in stages if not x['guard']['rss_captured']])
v=dict(review_id='R-SM003-EXECUTOR-CANCEL-F18-20261013',checked_at=datetime.now(timezone.utc).isoformat(),summary=summary,delivered=delivered,pairs=pairs,references=references,current_differences=changes,stages=stages,serial_no_overlap=True,history=history,literal_checks=dict(capture_direct_equal=True,capture_sha256=hashlib.sha256(raw).hexdigest(),LAP1_bytes=1024,LAC1_bytes=256,LGR1_bytes=256,independent_reconstruction=True,SV_layout_static_only=True),old_audit_preserved=True,resource_observation_complete=False,warnings=warnings,snapshots=[dict(path=p,sha256=h) for p,h in snapshots.items()],decision='pending_scoped_source_review',no_controller_compilation_simulation_hls=True)
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(summary=summary,history=[dict(before=x['before'],after=x['after'],common=x['common'],changed=[Path(p).name for p in x['changed']]) for x in history],warnings=warnings),ensure_ascii=False,indent=2))
