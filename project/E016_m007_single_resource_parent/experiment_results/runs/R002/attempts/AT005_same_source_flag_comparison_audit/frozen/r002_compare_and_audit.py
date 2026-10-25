#!/usr/bin/env python3
"""Audit the sole-flag short-prefix experiment; no long-run admission."""
from pathlib import Path
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,subprocess,sys
ROOT=Path(__file__).resolve().parents[3];CAPS={'reference':0,'static':300,'rtl':300,'ooc':0}
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1024*1024):h.update(b)
 return h.hexdigest()
def read(p):return json.loads(p.read_text())
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def runroot():return ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R002'
def costs():
 d={k:0. for k in CAPS}
 for p in (runroot()/'attempts').glob('*/receipt_*.json'):
  r=read(p);d[r['category']]+=r['wall_s']
 return d
def audit(out,exclude):
 run=runroot();records=[];errors=[];files=[];mutable=[];checks=0
 def check(ok,label):
  nonlocal checks;checks+=1
  if not ok:errors.append(label)
 for at in sorted((run/'attempts').iterdir()):
  if not at.is_dir() or at.name==exclude:continue
  recs=list(at.glob('receipt_*.json'));check(len(recs)==1,at.name+': one closed receipt');record={'attempt':at.name,'receipts':[read(q) for q in recs]}
  m=read(at/'source_manifest.json')
  for e in m['files']:check(sha(at/'frozen'/e['frozen'])==e['sha256'],at.name+': '+e['frozen'])
  if 'build' in m:check(sha(Path(m['build'])/'source_manifest.json')==m['build_manifest_sha256'],at.name+': build closure')
  for p in recs:
   r=read(p);cat=r['category'];gp=at/('guard_'+cat);g=read(gp/'guard_result.json');plan=read(gp/'guard_plan.json');check(r['guard']==g,at.name+': guard equality');check(sha(gp/'driver.log')==r['driver_sha256'],at.name+': log hash');check(plan['selected_cpu_ids']==[0,1,2,3] and plan['minimum_mem_available_kb']==192*1024*1024,at.name+': guard policy');check(g['minimum_mem_available_kb']>192*1024*1024 and g['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'],at.name+': actual resource bounds');check(plan['maximum_seconds']==120 and plan['semantic_stall_seconds']==120,at.name+': individual bounds');check(read(at/('command_'+cat+'.json'))['lock_held_through_children'],at.name+': shared lock')
   if cat=='rtl':
    check(plan['artifact_progress_root'] is None and not g['artifact_progress_enabled'],at.name+': strict numerical progress');check(sha(at/'frozen/m007_parent_guard_v1.py')=='76aa32642e1bffb4c0ef6eab111999d633d9261649adbd8b977d85ac3aa13c3b',at.name+': strict frozen guard');high=None
    for line in (gp/'driver.log').read_text().splitlines():
     mt=re.fullmatch(r'M007_PARENT_CHECKED checked=(\d+) phase=([A-Za-z0-9_]+) cycle=(\d+)',line)
     if mt:
      v=(int(mt[1]),int(mt[3]));check(high is None or (v[0]>high[0] and v[1]>=high[1]),at.name+': monotonic actual checked work');high=v
    check((list(high) if high else None)==g['checked_highwater'],at.name+': strict guard highwater')
  fi=at/'fixture_identity.json'
  if fi.exists():
   d=read(fi)
   for e in d['fixture_files']:check(sha(Path(e['path']))==e['sha256'],at.name+': fixture '+e['path'])
   for e in d['snapshot_files']:
    q=at/'work'/e['path'];actual=sha(q)
    if actual!=e['sha256'] and q.name in ['xsim_script.tcl','xsimkernel.log','xsimSettings.ini','xsimcrash.log']:mutable.append({'attempt':at.name,'path':e['path'],'before_sha256':e['sha256'],'after_sha256':actual})
    else:check(actual==e['sha256'],at.name+': immutable compiled product '+e['path'])
  for p in sorted(at.rglob('*')):
   if p.is_file():files.append({'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size})
  records.append(record)
  print('M007_R002_AUDIT_PROGRESS closed_attempt='+at.name,flush=True)
 typical=run/'attempts/AT001_O3_debug_typical_build';off=run/'attempts/AT003_O3_debug_off_build';tr=run/'attempts/AT002_O3_debug_typical_qkv3';orr=run/'attempts/AT004_O3_debug_off_qkv3'
 t=read(typical/'source_manifest.json');o=read(off/'source_manifest.json');check(t['files']==o['files'],'exact same source bytes and sizes both variants');ta=t['xelab_argv'][:];oa=o['xelab_argv'][:];check(ta[ta.index('-debug')+1]=='typical' and oa[oa.index('-debug')+1]=='off','explicit actual debug variants');ta[ta.index('-debug')+1]='ONLY_DIFFERENCE';oa[oa.index('-debug')+1]='ONLY_DIFFERENCE';check(ta==oa,'only xelab option difference is debug typical/off')
 baseline=(typical/'frozen/m007_single_parent_tb.sv').read_text();original=(typical/'frozen/make_parent_tb.py').read_text();ib=read(run/'instrumentation_boundary.json')
 # Remove exactly the added passive instrumentation to recover the original TB bytes.
 baseline=baseline.replace(' integer r002_quant_returns=0;\n always @(posedge clk)if(rst_n&&dut.front.q_out_valid&&dut.front.q_out_ready)r002_quant_returns=r002_quant_returns+1;\n','').replace('   if(r002_quant_returns!=4096)$fatal(1,"R002 actual quant return count");\n','');baseline='\n'.join(x for x in baseline.split('\n') if 'M007_R002_HANDSHAKES' not in x)
 check(hashlib.sha256(baseline.encode()).hexdigest()==ib['original_tb_sha256'],'all original TB text/checkers retained exactly')
 th=read(typical/'hierarchy_observation.json');oh=read(off/'hierarchy_observation.json');tm=read(tr/'observed_metrics.json');om=read(orr/'observed_metrics.json');check(tm['prefix_metrics']==om['prefix_metrics'],'same actual prefix data/cycle/feedback count');check(tm['handshake_counts']==om['handshake_counts'],'same all actual input quant A W QKV handshakes');check(tm['original_identity_rejects']==om['original_identity_rejects']==8,'same eight original identity rejects');check(tm['strict_checked_highwater']==om['strict_checked_highwater'],'same actual checked-work highwater');check(read(tr/'receipt_rtl.json')['verdict']==read(orr/'receipt_rtl.json')['verdict']=='PASS','both actual numerical/protocol runs PASS');check(read(tr/'fixture_identity.json')['fixture_files']==read(orr/'fixture_identity.json')['fixture_files'],'exact same original fixtures')
 used=costs();check(used==read(run/'budget_ledger.json')['used_s'],'closed budgets before audit charge');check(all(used[k]<=CAPS[k] for k in used),'independent caps no transfer')
 # R001 raw attempt evidence remains immutable; evolving owner summaries/status are separate.
 r1=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R001';r1inv=read(r1/'attempts/AT024_final_version_aware_evidence_audit/work/file_inventory.json')
 for e in r1inv:check(sha(ROOT/e['path'])==e['sha256'],'R001 frozen '+e['path'])
 tw=tm['wall_s'];ow=om['wall_s'];comparison={'typical_wall_s':tw,'off_wall_s':ow,'wall_reduction_s':tw-ow,'wall_reduction_percent':100*(tw-ow)/tw,'speed_ratio_typical_over_off':tw/ow,'improved_in_single_sample':ow<tw,'replicates_per_variant':1,'interpretation':'Only actual QKV3 simulator wall cost in this environment; no statistical repeatability, full-phase projection or FPGA throughput conclusion','long_run_admitted':False,'snapshot_hierarchy':{'typical':th,'off':oh},'typical_metrics':tm,'off_metrics':om,'normalized_xelab_argv':ta,'only_debug_option_diff':ta==oa,'exact_same_source_files':t['files']==o['files']}
 dump(out/'cost_comparison.json',comparison);dump(out/'file_inventory.json',files);report={'verdict':'PASS' if not errors else 'FAIL','checks':checks,'checked_R002_files':len(files),'R001_immutable_files_rechecked':len(r1inv),'errors':errors,'attempts':records,'mutable_runtime_differences':mutable,'inventory_sha256':sha(out/'file_inventory.json'),'costs_before_audit_charge':used,'scope':'Source/compiled/fixture/policy/budget consistency plus original numerical/protocol check result comparison; no long-run/hardware-performance admission'};dump(out/'evidence_audit.json',report)
 print('M007_R002_COMPARE_AUDIT_'+report['verdict']+' files='+str(len(files))+' checks='+str(checks)+' typical_s='+str(tw)+' off_s='+str(ow),flush=True)
 return 0 if not errors else 1

def launch(name):
 run=runroot();mod=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True);used=costs();assert CAPS['static']-used['static']>=60
  at=run/'attempts'/name;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
  for q in [Path(__file__),mod/'tb/m007_parent_guard_v1.py',ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py']:shutil.copy2(q,f/q.name)
  dump(at/'source_manifest.json',{'scope':'R002 audit tools only','files':[{'frozen':q.name,'sha256':sha(q)} for q in sorted(f.iterdir())]})
  cmd=[sys.executable,str(f/'m007_parent_guard_v1.py'),'--out',str(at/'guard_static'),'--cwd',str(w),'--rss-gib','24','--timeout-seconds','60','--semantic-stall-seconds','120','--phase','static','--',sys.executable,str(f/'r002_compare_and_audit.py'),'--root',str(ROOT),'--out',str(w),'--exclude-at',name]
  dump(at/'command_static.json',{'argv':cmd,'lock_held_through_children':True,'used_before_s':used,'no_old_budget_transfer':True});rc=subprocess.call(cmd,cwd=w);g=read(at/'guard_static/guard_result.json');log=(at/'guard_static/driver.log').read_text();passed=rc==0 and 'M007_R002_COMPARE_AUDIT_PASS' in log;dump(at/'receipt_static.json',{'category':'static','wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'verdict':'PASS' if passed else 'FAIL','required_marker':'M007_R002_COMPARE_AUDIT_PASS','marker_found':passed,'driver_sha256':sha(at/'guard_static/driver.log')});used=costs();dump(run/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k] for k in CAPS},'R001_balances_transferred':False});print(log[-3000:],flush=True);print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path);p.add_argument('--out',type=Path);p.add_argument('--exclude-at');p.add_argument('--launch-at');a=p.parse_args()
 if a.root:ROOT=a.root
 raise SystemExit(launch(a.launch_at) if a.launch_at else audit(a.out,a.exclude_at))
