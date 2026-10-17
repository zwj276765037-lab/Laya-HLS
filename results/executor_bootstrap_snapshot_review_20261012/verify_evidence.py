from pathlib import Path
import hashlib,json,shutil,difflib
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[2];OUT=Path(__file__).resolve().parent
RUNS=ROOT/'project/E003_production_chain_closure/experiment_results/runs/R003'
NAMES=['task_lifecycle_port_host_02','executor_bootstrap_host_02','bootstrap_snapshot_rtl_02','generated_store_monitor_10']
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def read(p):return json.loads(Path(p).read_text())
pairs=[];refs=[];snaps=[];attempts={};diffs=[]
def snap(p):
 t=OUT/'snapshot'/p.relative_to(ROOT);t.parent.mkdir(parents=True,exist_ok=True)
 if not t.exists():shutil.copyfile(p,t)
 assert sha(t)==sha(p)
 snaps.append({'path':str(t.relative_to(ROOT)),'sha256':sha(t)})
def walk(x,origin):
 if isinstance(x,dict):
  if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str):
   p=Path(x['path']);refs.append({'origin':origin,'path':str(p),'expected':x['sha256'],'actual':sha(p) if p.is_file() else None,'match':p.is_file() and sha(p)==x['sha256']})
  for value in x.values():walk(value,origin)
 elif isinstance(x,list):
  for value in x:walk(value,origin)
def diff(a,b,label):
 t=OUT/'diff'/label;t.parent.mkdir(parents=True,exist_ok=True)
 t.write_text(''.join(difflib.unified_diff(a.read_text().splitlines(True),b.read_text().splitlines(True),fromfile=str(a.relative_to(ROOT)),tofile=str(b.relative_to(ROOT)))))
 diffs.append(str(t.relative_to(ROOT)))
for name in NAMES:
 base=RUNS/name;m=read(base/'input_manifest.json');r=read(base/'receipt.json')
 for e in m['files']+[m[k] for k in ['contract','bootstrap_contract'] if k in m]:
  a,b=e['original'],e['frozen'];pa,pb=Path(a['path']),Path(b['path'])
  row={'attempt':name,'path':str(pa),'current_match':sha(pa)==a['sha256'],'frozen_match':sha(pb)==b['sha256'],'declared_pair_match':a['sha256']==b['sha256']}
  pairs.append(row)
  if not row['current_match']:
   diff(pb,pa,name+'/'+pa.name+'.diff');snap(pa);snap(pb)
  if pb.suffix in ['.cpp','.h','.sv'] and any(key in pb.name for key in ['executor_bootstrap','bootstrap_snapshot','lifecycle_port','generated_provenance_hub']):snap(pb)
 for kind,data in [('manifest',m),('receipt',r)]:walk(data,name+'/'+kind)
 for f in ['input_manifest.json','receipt.json','launcher.json','run.log','build.log','fixture.log']:
  if (base/f).exists():snap(base/f)
 guards=[]
 for gd in sorted(base.glob('guard*')):
  if not gd.is_dir():continue
  plan=read(gd/'guard_plan.json');result=read(gd/'guard_result.json');policy=read(gd/'policy_checks.json')
  guards.append({'name':gd.name,'plan':plan,'result':result,'policy_rows':len(policy),'policy_ok':bool(policy) and all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy),'budget_ok':result['elapsed_seconds']<=plan['maximum_seconds'] and result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and result['minimum_mem_available_kb']>=plan['minimum_mem_available_kb']})
  for f in ['guard_plan.json','guard_result.json','policy_checks.json','launch.json','driver.log']:snap(gd/f)
 attempts[name]={'status':r['status'],'scope':r['scope'],'launcher':read(base/'launcher.json'),'guards':guards,'commands':[{k:v for k,v in c.items() if k!='command'} for c in r.get('commands',[])],'markers':r.get('markers',r.get('marker',[])),'sources':m.get('lifecycle_sources'),'profile':m['profile']}
 changes=[]
 prior=RUNS/({'task_lifecycle_port_host_02':'task_lifecycle_port_host_01','executor_bootstrap_host_02':'executor_bootstrap_host_01','bootstrap_snapshot_rtl_02':'bootstrap_snapshot_rtl_01','generated_store_monitor_10':'generated_store_monitor_09'}[name])
 om=read(prior/'input_manifest.json')
 old={str(Path(e['original']['path']).relative_to(ROOT/'project/E002_Laya_HLS/experiment')):e for e in om['files']}
 new={str(Path(e['original']['path']).relative_to(ROOT/'project/E002_Laya_HLS/experiment')):e for e in m['files']}
 for f in sorted(old.keys()&new.keys()):
  if old[f]['frozen']['sha256']!=new[f]['frozen']['sha256']:
   changes.append(f)
   if Path(f).suffix in ['.cpp','.sv','.py','.json','.cmake','.tcl']:diff(Path(old[f]['frozen']['path']),Path(new[f]['frozen']['path']),'prior/'+name+'/'+Path(f).name+'.diff')
 attempts[name]['prior_changed_common']=changes
expected={}
hashrows=[
('task_lifecycle_port_host_02','36963e6877373a7210b2a8c200213b0d9df64cf8fb623efda5d5620d0d25bf7a','3f6df97ebf53436356f71592ad565d10741b3df9fea8cbd271ab904c2765b44e','397d2259e9e6460e2b31d83f71f96d44a49f7a0303aeb43f462c8659156ab9e4'),
('executor_bootstrap_host_02','583aad56ac5f774d29fefa9a7bffc68cf3b4c0fa3d167e9c5fa108722f239d4d','41d86a4daf01a9c1b52f41eee4076e80589c83e72fef27017e767e02e8352219','80d90bd0de1d41c90f67a08a2e1cb021618d44de52a52f357a2391047cc3915b'),
('bootstrap_snapshot_rtl_02','8043e15cb9aeaf5470ef37fde80a7c22ccf6189ccd1e9f0e4594c2a88b43ca5d','0edd1c64a5d1465dd5733158146bbbcfde48c6c58e610fa79af464a97f1b2496','c350921bd093cf236cc5ff015180574308d78c539e0a2c1ffb5a2b820977f5fe'),
('generated_store_monitor_10','0fc4db1f60e595834156a38256c9b150b59e715702996840a5d4b59999c9a0a8','90096b6bd97d6e13798a976b40e65f77c3655058929c0cf5538b0fd36a59ccdd','1a6690e075f146ee46548458f4c85f03099d56cf7117bf92f063e94dd27d1edd')]
for n,m,r,v in hashrows:
 expected[RUNS/n/'input_manifest.json']=m;expected[RUNS/n/'receipt.json']=r;expected[RUNS/(n+'_verification_20261012.json')]=v
for n,h in [('verification','fd7be2aaf191493900d9fbc03a38d2a49f8e4772f62900b0d14aa9be4bc4702f'),('catalog_delta','bc25304dd0fb648569b6116348fe442b2efb3d872d2fe1260233f75c97f91822'),('count_correction','27ff8adc26aa3beba783f87c2c20e07e01b707c2b6f3f5aca6f635e7b23f480d')]:expected[RUNS/('executor_bootstrap_snapshot_'+n+'_20261012.json')]=h
hashes=[{'path':str(p.relative_to(ROOT)),'expected':h,'actual':sha(p),'match':sha(p)==h} for p,h in expected.items()]
for p in expected:
 if p.parent==RUNS:snap(p)
for f in ['results/reviews/SM003.md','results/review_queue.md','results/overview.md','mission/current.md','agent/A001/result.md','agent/A001/state.json','agent/A002/state.json','.research-agent/discussions.json']:snap(ROOT/f)
fx=RUNS/'executor_bootstrap_host_02/fixture';frozen=RUNS/'executor_bootstrap_host_02/frozen'
aux_match=(fx/'aux_header.bin').read_bytes()==(frozen/'build/model-current-production-v2-20261011/aux.bin').read_bytes()[:128]
v={'review_id':'R-SM003-EXECUTOR-BOOTSTRAP-SNAPSHOT-20261012','checked_at':datetime.now(timezone.utc).isoformat(),'pairs':pairs,'references':refs,'snapshots':snaps,'diffs':diffs,'attempts':attempts,'summary':{'pairs':len(pairs),**{k:sum(x[k] for x in pairs) for k in ['current_match','frozen_match','declared_pair_match']},'references':len(refs),'reference_matches':sum(x['match'] for x in refs)},'handoff_hashes':hashes,'aux_header_frozen_prefix_equal':aux_match,'fixture_bytes':{n:(fx/n).stat().st_size for n in ['request.bin','aux_header.bin','snapshot_request.bin','snapshot_response.bin']},'findings':[{'id':'F14','severity':'P1','kind':'static_not_dynamically_reproduced','file':'bootstrap_snapshot_rtl_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_hub_v1.sv','lines':[94,96,377,379],'issue':'LPV request_ready requires !snapshot_request_valid; snapshot_request_ready requires !request_valid; with both valid held no request can handshake, including old END needed before snapshot','fix_direction':'LPV/cleanup priority or equivalent registered fair arbiter; unaccepted query must not block old action cleanup; keep accepted snapshot response stable until consumption','required_regression':'hold both valid without withdrawing, idle collision and old active scope END/INVALIDATE with snapshot pending; cleanup then bounded snapshot response; backpressure/reset/default-disabled compatibility'}],'decision_pending':True,'no_controller_compilation_simulation_hls':True}
(OUT/'verification.json').write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'summary':v['summary'],'hash_matches':sum(x['match'] for x in hashes),'hash_total':len(hashes),'aux_equal':aux_match,'changes':{n:a['prior_changed_common'] for n,a in attempts.items()},'guards':[(n,g['policy_rows'],g['policy_ok'],g['budget_ok'],g['result']['child_exit_code'],g['result']['trigger']) for n,a in attempts.items() for g in a['guards']]},ensure_ascii=False,indent=2))

