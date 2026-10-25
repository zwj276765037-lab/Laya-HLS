#!/usr/bin/env python3
"""Version-aware E016 audit; numerical assertions remain the original TB evidence."""
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R001'
MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
CAPS={'reference':180,'static':1800,'rtl':3600,'ooc':0}
MUTABLE={'xsimSettings.ini','xsim_script.tcl','xsimkernel.log','xsimcrash.log'}
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1024*1024):h.update(b)
 return h.hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def read(p):return json.loads(p.read_text())
def costs():
 d={k:0. for k in CAPS}
 for p in (RUN/'attempts').glob('*/receipt_*.json'):
  r=read(p);d[r['category']]+=r['wall_s']
 return d
def audit(out,excluded):
 errors=[];checks=[];mutable=[];inventory=[];attempts=[]
 def check(ok,label):
  checks.append({'check':label,'passed':bool(ok)})
  if not ok:errors.append(label)
 def verify(p,expected,label):
  actual=sha(p) if p.is_file() else None;check(actual==expected,label)
  return actual
 for at in sorted((RUN/'attempts').iterdir()):
  if not at.is_dir() or at.name==excluded:continue
  receipts=list(at.glob('receipt_*.json'));check(len(receipts)==1,at.name+': closed exactly once')
  row={'attempt':at.name,'receipts':[read(p) for p in receipts]}
  mf=at/'source_manifest.json'
  if mf.exists():
   m=read(mf);row['source_manifest_sha256']=sha(mf)
   for e in m['files']:
    q=at/'frozen'/e['frozen'];verify(q,e['sha256'],at.name+': frozen '+e['frozen'])
    if e['frozen']=='laya_m007_single_parent_v1.sv':row['parent_sha256']=e['sha256']
    if e.get('why','').startswith('immutable '):verify(Path(e['origin']),e['sha256'],at.name+': immutable dependency '+e['frozen'])
   if 'build' in m:verify(Path(m['build'])/'source_manifest.json',m['build_manifest_sha256'],at.name+': exact build manifest')
  for rp in receipts:
   r=read(rp);cat=r['category'];check(0<=r['wall_s']<=CAPS[cat],at.name+': nonnegative bounded charge')
   if 'guard' not in r:continue
   gdir=at/('guard_'+cat);log=gdir/'driver.log';verify(log,r['driver_sha256'],at.name+': driver log')
   g=read(gdir/'guard_result.json');check(g==r['guard'],at.name+': guard receipt equality')
   plan=read(gdir/'guard_plan.json');check(plan['selected_cpu_ids']==[0,1,2,3],at.name+': CPU0-3')
   check(plan['minimum_mem_available_kb']==192*1024*1024,at.name+': MemAvailable policy')
   check(g['minimum_mem_available_kb']>192*1024*1024,at.name+': actual MemAvailable')
   check(g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'],at.name+': actual owned RSS')
   check(plan['maximum_seconds']<= (600 if cat=='static' else 1200),at.name+': per-attempt wall cap')
   cp=read(at/('command_'+cat+'.json'));check(cp['lock_held_through_children'],at.name+': lock declared through children')
   text=log.read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',text))
   check(fatal==r['error_or_fatal'],at.name+': original error/fatal classification')
   check((r['required_marker'] in text)==r['marker_found'],at.name+': original terminal marker')
   if r['verdict']=='PASS':check(not fatal and r['marker_found'] and r['guard_exit']==0,at.name+': PASS conjunction')
   if cat=='rtl' and int(at.name[2:5])>=12:
    verify(at/'frozen/m007_parent_guard_v1.py','76aa32642e1bffb4c0ef6eab111999d633d9261649adbd8b977d85ac3aa13c3b',at.name+': strict frozen guard')
    check(plan['artifact_progress_root'] is None and not g['artifact_progress_enabled'],at.name+': no RTL artifact progress')
    check(plan['semantic_stall_seconds']==120,at.name+': real semantic stall120s')
    high=None
    for line in text.splitlines():
     mt=re.fullmatch(r'M007_PARENT_CHECKED checked=(\d+) phase=([A-Za-z0-9_]+) cycle=(\d+)',line)
     if mt:
      v=(int(mt[1]),int(mt[3]));check(high is None or (v[0]>high[0] and v[1]>=high[1]),at.name+': advancing independently checked counter '+str(v));high=v
    check(high is None or high[1]<=40000000,at.name+': emitted semantic cycle bound')
    check((list(high) if high else None)==g['checked_highwater'],at.name+': guard highwater equals accepted checked stream')
    row['semantic_cycle_scope']='Emitted comparisons only; separate frozen TB watchdog/terminal assertions govern all cycles.'
  fi=at/'fixture_identity.json'
  if fi.exists():
   d=read(fi);verify(Path(d['build'])/'source_manifest.json',d['build_manifest_sha256'],at.name+': fixture build link')
   for e in d['fixture_files']:verify(Path(e['path']),e['sha256'],at.name+': original fixture '+e['path'])
   for e in d['snapshot_files']:
    q=at/'work'/e['path'];actual=sha(q) if q.is_file() else None
    if actual!=e['sha256'] and q.name in MUTABLE:
     mutable.append({'attempt':at.name,'path':e['path'],'before_sha256':e['sha256'],'after_sha256':actual,'classification':'xsim mutable runtime configuration/log; not claimed immutable compiled object'})
    else:check(actual==e['sha256'],at.name+': compiled snapshot '+e['path'])
   row['fixture_count']=len(d['fixture_files']);row['snapshot_count']=len(d['snapshot_files'])
  rt=at/'runtime_tool_identity.json'
  if rt.exists():
   d=read(rt);verify(at/'frozen/m007_parent_wall_driver.py',d['wall_driver_sha256'],at.name+': frozen wall runtime');verify(at/'frozen/m007_parent_run_control.py',d['current_run_control_sha256'],at.name+': frozen run control')
  for p in sorted(at.rglob('*')):
   if p.is_file():inventory.append({'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size})
  attempts.append(row)
  print('M007_EVIDENCE_AUDIT_PROGRESS closed_attempt='+at.name,flush=True)
 # Current source boundary is a sole expression change; no old run is relabeled.
 boundary=read(RUN/'reports/context_fault_phase_boundary.json')
 old=RUN/'attempts/AT011_checked_observer_declaration_fix/frozen/laya_m007_single_parent_v1.sv'
 cur=MOD/'rtl/laya_m007_single_parent_v1.sv'
 verify(old,boundary['old_parent_sha256'],'old normal parent identity');verify(cur,boundary['new_parent_sha256'],'current parent identity')
 change=boundary['exact_only_difference'];check(old.read_text().replace(change['before'],change['after'])==cur.read_text(),'sole context-fault phase boundary change')
 a22=RUN/'attempts/AT022_current_parent_reset_build';ctrl=read(a22/'source_control_audit.json')
 check(ctrl['new_control_bits']==1561 and ctrl['new_module_rounded_bytes']==196 and ctrl['combined_conservative_bytes']==3746 and ctrl['remaining_bytes']==350,'current exact declaration control account')
 check(ctrl['actual_input_connections_excluding_clock_reset']==452,'452 actual input sources')
 scopes=(a22/'work/hierarchy_scopes.txt').read_text().splitlines();prefix='/m007_parent_reset_tb/dut/'
 expected=['resources','resources/fp','resources/div','resources/st','resources/qkv','resources/ln','resources/sfu','coeff','front','matrix','matrix/core','layer','context_adapter']
 paths={x:scopes.count(prefix+x) for x in expected};check(all(v==1 for v in paths.values()),'current actual unique hierarchy paths')
 dump(out/'current_hierarchy_audit.json',{'source':str((a22/'work/hierarchy_scopes.txt').relative_to(ROOT)),'source_sha256':sha(a22/'work/hierarchy_scopes.txt'),'actual_scopes':len(scopes),'unique_expected_paths':paths,'scope':'actual elaboration; no synthesis or physical fit'})
 oldh=read(RUN/'attempts/AT003_sole_parent_clean_peer_and_hierarchy/actual_hierarchy_audit.json');check(oldh['actual_scopes']==91923 and all(v==1 for v in oldh['unique_expected_paths'].values()),'old actual hierarchy counts remain historical')
 g=read(RUN/'reports/full_parent_16head_wo_cost_gate.json');wall=RUN/'attempts/AT013_complete_qkv_and_first_head/work/parent_wall_events.json';verify(wall,g['stage_evidence_sha256'],'immutable first-head wall evidence')
 calculated=1.35*(g['actual_total_to_first_head_exit_seconds']+15*g['actual_first_head_seconds'])+10
 check(abs(calculated-g['attention_only_estimate_seconds_before_WO'])<1e-6 and not g['passed'] and calculated>1200,'full16/WO closed cost gate')
 guardtest=read(RUN/'attempts/AT008_strict_guard_frozen_helper_contract/work/guard_contract_results.json');check(len(guardtest['records'])==3 and [x['result']['trigger'] for x in guardtest['records']]==['semantic_stall','semantic_stall',None],'strict guard scaled counterexamples')
 # Nested synthetic guard elapsed time is already inside AT008 outer static receipt.
 nested=[{'case':x['case'],'elapsed_seconds':x['result']['elapsed_seconds'],'charged_separately':False} for x in guardtest['records']]
 used=costs();ledger=read(RUN/'budget_ledger.json');check(used==ledger['used_s'],'closed receipt sums equal ledger before audit charge');check(all(used[k]<=CAPS[k] for k in CAPS),'independent caps no old transfer')
 for k,v in used.items():check(abs((CAPS[k]-v)-ledger['remaining_s'][k])<1e-7,'remaining ledger '+k)
 report={'execution_state':'completed','verdict':'PASS' if not errors else 'FAIL','scope':'E016 recorded source, dependencies, fixtures, compiled products, logs, policies, boundaries and accounting; numerical proof remains exact original TB assertions','checked_files':len(inventory),'checks':checks,'errors':errors,'attempts':attempts,'mutable_runtime_snapshot_differences':mutable,'allowed_mutable_names':sorted(MUTABLE),'nested_scaled_guard_cases':nested,'costs_before_audit_charge_s':used,'audit_charge':'Receipt closes after this child; final ledger reconciliation is separate','old_parent_sha256':boundary['old_parent_sha256'],'current_parent_sha256':boundary['new_parent_sha256'],'current_parent_dynamic_scope':'AT023 actual active common reset, real coefficient reload, new-generation full-input/QKV3 only','old_first_head_scope':'AT013 old parent fullQKV/RoPE/first head; not silently inherited for the modified expression','unverified':['actual full16-layer context handoff through parent to WO','actual context-fault to next-generation parent chain','normal successful parent held DONE','last QKV write hold without legal ready control','Decision/bias dynamic parent chain','global original graph Check first-error identity','physical timing/resources/300MHz/board/HBM reset/CDC/30layer']}
 dump(out/'file_inventory.json',inventory);report['inventory_sha256']=sha(out/'file_inventory.json');dump(out/'evidence_audit.json',report)
 print('M007_EVIDENCE_AUDIT_'+report['verdict']+' files='+str(len(inventory))+' checks='+str(len(checks))+' mutable_runtime_differences='+str(len(mutable)),flush=True)
 return 0 if not errors else 1

def launch(name):
 assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',name)
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  before=costs();assert CAPS['static']-before['static']>=120
  at=RUN/'attempts'/name;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
  for src in [Path(__file__),MOD/'tb/m007_parent_guard_v1.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']:shutil.copy2(src,f/src.name)
  dump(at/'source_manifest.json',{'scope':'audit tools only; no new DUT build','files':[{'frozen':q.name,'sha256':sha(q),'bytes':q.stat().st_size} for q in sorted(f.iterdir())]})
  cmd=[sys.executable,str(f/'m007_parent_guard_v1.py'),'--out',str(at/'guard_static'),'--cwd',str(w),'--rss-gib','24','--timeout-seconds','120','--semantic-stall-seconds','120','--phase','static','--',sys.executable,str(f/'audit_evidence.py'),'--out',str(w),'--exclude-at',name]
  dump(at/'command_static.json',{'argv':cmd,'used_before_s':before,'lock_held_through_children':True})
  # Frozen script is deeper than source; explicit ROOT is supplied for its audit mode.
  cmd.extend(['--root',str(ROOT)])
  dump(at/'command_static.json',{'argv':cmd,'used_before_s':before,'lock_held_through_children':True})
  rc=subprocess.call(cmd,cwd=w);g=read(at/'guard_static/guard_result.json');log=(at/'guard_static/driver.log').read_text();passed=rc==0 and 'M007_EVIDENCE_AUDIT_PASS' in log
  dump(at/'receipt_static.json',{'category':'static','wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'error_or_fatal':False,'marker_found':passed,'required_marker':'M007_EVIDENCE_AUDIT_PASS','verdict':'PASS' if passed else 'FAIL','driver_sha256':sha(at/'guard_static/driver.log')})
  used=costs();dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k] for k in CAPS}})
  print(log[-4000:],flush=True);print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--launch-at');p.add_argument('--out',type=Path);p.add_argument('--exclude-at');p.add_argument('--root',type=Path);a=p.parse_args()
 if a.root:ROOT=a.root;RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R001';MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
 raise SystemExit(launch(a.launch_at) if a.launch_at else audit(a.out,a.exclude_at))
