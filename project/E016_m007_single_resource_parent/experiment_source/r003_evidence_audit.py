#!/usr/bin/env python3
"""Final R003 artifact and scope audit; never promotes an unrun full chain."""
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];CAPS={'reference':0,'static':600,'rtl':6000,'ooc':0}
def runroot():return ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R003'
def read(p):return json.loads(p.read_text())
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1024*1024):h.update(b)
 return h.hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def costs():
 d={k:0. for k in CAPS}
 for p in (runroot()/'attempts').glob('*/receipt_*.json'):
  r=read(p);d[r['category']]+=r['wall_s']
 return d

def audit(out,exclude):
 run=runroot();checks=[];errors=[];inventory=[];mutable=[];attempts=[];fulls=[]
 def check(ok,label):
  checks.append({'label':label,'passed':bool(ok)})
  if not ok:errors.append(label)
 fm=read(run/'fixtures/manifest.json')
 for e in fm['files']:
  check(sha(run/'fixtures'/e['frozen'])==e['sha256'],'frozen original fixture '+e['frozen']);check(sha(Path(e['original']))==e['sha256'],'unchanged origin '+e['original'])
 for at in sorted((run/'attempts').iterdir()):
  if not at.is_dir() or at.name==exclude:continue
  recs=list(at.glob('receipt_*.json'));check(len(recs)==1,at.name+': one closed receipt');row={'attempt':at.name,'receipts':[read(q) for q in recs]};m=read(at/'source_manifest.json')
  for e in m['files']:check(sha(at/'frozen'/e['frozen'])==e['sha256'],at.name+': frozen '+e['frozen'])
  if 'build' in m:check(sha(Path(m['build'])/'source_manifest.json')==m['build_manifest_sha256'],at.name+': compiled build link')
  for p in recs:
   d=read(p);cat=d['category'];gp=at/('guard_'+cat);g=read(gp/'guard_result.json');plan=read(gp/'guard_plan.json');log=(gp/'driver.log').read_text(errors='replace');check(sha(gp/'driver.log')==d['driver_sha256'],at.name+': raw log');check(g==d['guard'],at.name+': guard receipt');check(plan['selected_cpu_ids']==[0,1,2,3] and plan['minimum_mem_available_kb']==192*1024*1024,at.name+': CPU/Mem policy');check(g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and g['minimum_mem_available_kb']>192*1024*1024,at.name+': actual memory');check(plan['semantic_stall_seconds']==120,at.name+': stall120');check(read(at/('command_'+cat+'.json'))['lock_held_through_children'],at.name+': heavy lock')
   fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));check(fatal==d['error_or_fatal'] or ('FATAL_ERROR:' in log and d['verdict']=='FAIL' and not d['marker_found']),at.name+': raw fatal classification with preserved historical kernel-exception classifier');row['kernel_exception_observed']='FATAL_ERROR:' in log;check((d['required_marker'] in log)==d['marker_found'],at.name+': original terminal classification')
   if cat=='rtl':
    check(plan['artifact_progress_root'] is None and not g['artifact_progress_enabled'],at.name+': no artifact numeric progress');check(sha(at/'frozen/m007_parent_guard_v1.py')=='76aa32642e1bffb4c0ef6eab111999d633d9261649adbd8b977d85ac3aa13c3b',at.name+': strict frozen guard');high=None
    for line in log.splitlines():
     match=re.fullmatch(r'M007_PARENT_CHECKED checked=(\d+) phase=([A-Za-z0-9_]+) cycle=(\d+)',line)
     if match:
      v=(int(match[1]),int(match[3]));check(high is None or (v[0]>high[0] and v[1]>=high[1]),at.name+': strict advancing checked '+str(v));high=v
    check((list(high) if high else None)==g['checked_highwater'],at.name+': exact highwater');check(len(re.findall(r'^M007_PARENT_IDENTITY_REJECT_PASS ',log,re.M))==8,at.name+': original8 identity cases')
    if d['scope']=='full':fulls.append(at.name)
   if d['verdict']=='PASS':check(not fatal and d['marker_found'] and d['guard_exit']==0,at.name+': PASS conjunction')
  fi=at/'fixture_identity.json'
  if fi.exists():
   x=read(fi);check(x['fixture_manifest_sha256']==sha(run/'fixtures/manifest.json'),at.name+': fixture registration link')
   for e in x['snapshot_files']:
    p=at/'work'/e['path'];actual=sha(p)
    if actual!=e['sha256'] and p.name in ['xsim_script.tcl','xsimkernel.log','xsimSettings.ini','xsimcrash.log']:mutable.append({'attempt':at.name,'path':e['path'],'before_sha256':e['sha256'],'after_sha256':actual})
    else:check(actual==e['sha256'],at.name+': immutable compiled '+e['path'])
  for p in sorted(at.rglob('*')):
   if p.is_file():inventory.append({'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size})
  attempts.append(row);print('M007_R003_AUDIT_PROGRESS attempt='+at.name,flush=True)
 check(len(fulls)<=1,'no automatic second full child')
 gatep=run/'reports/full_chain_cost_gate.json'
 gate=read(gatep) if gatep.exists() else None
 if gate:
  check(abs(1.10*(gate['P2_s']+14*gate['Hmax_s']+gate['Q_s'])+10-gate['estimate_s'])<1e-7,'fixed actual cost coefficient/formula');check(gate['passed']==(gate['estimate_s']<=3600 and gate['remaining_rtl_s']>=gate['estimate_s']+600),'exact admission comparison');check(not gate['Q_is_context_plus_WO_measurement'],'Q explicitly placeholder');check(sha(Path(gate['pilot'])/'receipt_rtl.json')==gate['pilot_receipt_sha256'],'actual second-head pilot receipt');check(sha(Path(gate['source_build'])/'source_manifest.json')==gate['build_manifest_sha256'],'gate source build')
  if fulls:check(gate['passed'],'full child only after passing gate')
 # Original numerical checks remain in the extended source; the changed state/head dimensions are explicit.
 latest=next((a for a in reversed(attempts) if a['receipts'][0]['category']=='static' and a['receipts'][0]['verdict']=='PASS'),None)
 if latest:
  at=run/'attempts'/latest['attempt'];tb=(at/'frozen/m007_full_parent_tb.sv').read_text()
  for token in ['actual W mapping','actual A mapping','independent prebias','continuous K issue','real commit order','passive issue/PSack64','passive PSfeedback24','actual public QKV mapping/value','independent Attention preQKV source mismatch','resource QKV path masked','parent real RoPE data','parent real score','parent real maximum','parent real probability','parent real context','parent actual shared protocol fault','parent40Mcycle watchdog','head_maximum[dut.layer.active_head]!=128','expected_done','normal successful parent independently expected243bit held response','actual public context response credit/tag','real matrix descriptor identity/key/base remap']:
   check(token in tb,'retained/extended checker '+token)
  check(not re.search(r'\bforce\b|\$deposit',tb),'no forced internal state or response')
  scopes=(at/'work/hierarchy_scopes.txt').read_text().splitlines();paths={n:scopes.count('/m007_full_parent_tb/dut/'+n) for n in ['resources','resources/fp','resources/div','resources/st','resources/qkv','resources/ln','resources/sfu','coeff','front','matrix','matrix/core','layer','context_adapter']};check(all(v==1 for v in paths.values()),'actual sole-service hierarchy');dump(out/'actual_hierarchy_audit.json',{'attempt':at.name,'scopes':len(scopes),'paths':paths,'source_sha256':sha(at/'work/hierarchy_scopes.txt'),'scope':'Actual expanded simulation hierarchy, no physical fit'})
  control=read(at/'source_control_audit.json');check(control['combined_conservative_bytes']==3746 and control['actual_input_connections_excluding_clock_reset']==452,'source control/connectivity account')
 used=costs();check(used==read(run/'budget_ledger.json')['used_s'],'outer receipts equal current ledger');check(all(used[k]<=CAPS[k] for k in used),'independent budgets no transfer')
 report={'verdict':'PASS' if not errors else 'FAIL','scope':'Source/fixture/compiled/raw log/guard/resource/cost/scope consistency; exact DUT numerical assertion evidence remains each actual run','checks':checks,'errors':errors,'attempts':attempts,'files_checked':len(inventory),'mutable_runtime_differences':mutable,'full_children':fulls,'gate':gate,'used_before_audit_charge':used};dump(out/'file_inventory.json',inventory);report['inventory_sha256']=sha(out/'file_inventory.json');dump(out/'evidence_audit.json',report);print('M007_R003_EVIDENCE_AUDIT_'+report['verdict']+' files='+str(len(inventory))+' checks='+str(len(checks)),flush=True);return 0 if not errors else 1

def launch(name):
 run=runroot();mod=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True);used=costs();assert CAPS['static']-used['static']>=120
  at=run/'attempts'/name;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
  for p in [Path(__file__),mod/'tb/m007_parent_guard_v1.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']:shutil.copy2(p,f/p.name)
  dump(at/'source_manifest.json',{'scope':'Evidence audit tools only','files':[{'frozen':p.name,'sha256':sha(p)} for p in sorted(f.iterdir())]});cmd=[sys.executable,str(f/'m007_parent_guard_v1.py'),'--out',str(at/'guard_static'),'--cwd',str(w),'--rss-gib','24','--timeout-seconds','120','--semantic-stall-seconds','120','--phase','static','--',sys.executable,str(f/'r003_evidence_audit.py'),'--root',str(ROOT),'--out',str(w),'--exclude-at',name];dump(at/'command_static.json',{'argv':cmd,'lock_held_through_children':True,'used_before_s':used});rc=subprocess.call(cmd,cwd=w);g=read(at/'guard_static/guard_result.json');log=(at/'guard_static/driver.log').read_text();passed=rc==0 and 'M007_R003_EVIDENCE_AUDIT_PASS' in log;dump(at/'receipt_static.json',{'category':'static','scope':'evidence_audit','wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'error_or_fatal':False,'marker_found':passed,'required_marker':'M007_R003_EVIDENCE_AUDIT_PASS','verdict':'PASS' if passed else 'FAIL','driver_sha256':sha(at/'guard_static/driver.log')});used=costs();dump(run/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k] for k in CAPS},'reserve_rtl_s':600,'old_balances_transferred':False});print(log[-4000:],flush=True);print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path);p.add_argument('--out',type=Path);p.add_argument('--exclude-at');p.add_argument('--launch-at');a=p.parse_args()
 if a.root:ROOT=a.root
 raise SystemExit(launch(a.launch_at) if a.launch_at else audit(a.out,a.exclude_at))
