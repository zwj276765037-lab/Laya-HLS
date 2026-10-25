#!/usr/bin/env python3
"""FULL-PARENT-15; one frozen complete observer snapshot and fixed actual gate."""
import argparse,datetime as dt,fcntl,hashlib,json,math,re,shlex,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];SRC=ROOT/'project/E016_m007_single_resource_parent/experiment_source';RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R003';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');CAPS={'reference':0,'static':600,'rtl':6000,'ooc':0}
sys.path.insert(0,str(MOD/'tb'));from m007_parent_run import closure

def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1024*1024):h.update(b)
 return h.hexdigest()
def dump(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n')
def read(p):return json.loads(p.read_text())
def costs():
 d={k:0. for k in CAPS}
 for p in (RUN/'attempts').glob('*/receipt_*.json'):
  x=read(p);d[x['category']]+=x['wall_s']
 return d

def fixtures():
 dest=RUN/'fixtures';manifest=dest/'manifest.json'
 if manifest.exists():
  d=read(manifest)
  for e in d['files']:assert sha(dest/e['frozen'])==e['sha256']
  return d
 assert not dest.exists();dest.mkdir();files=[]
 matrix=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture/qkv_0_weight';inp=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture/qkv_0_weight';att=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle';ctx=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R004/attempts/AT005_original_context_wo_fixture/work/fixture/wo_0_weight'
 pairs=[(q,Path('matrix/qkv_0_weight')/q.name) for q in matrix.iterdir() if q.is_file()]+[(inp/'input.hex',Path('input/qkv_0_weight/input.hex'))]+[(att/n,Path('attention')/n) for n in ['cos_full.mem','sin_full.mem','mask.mem','encoder0_pre_qkv.mem','encoder0_post_qkv.mem','encoder0_score.mem','encoder0_maximum.mem','encoder0_prob.mem','encoder0_context.mem','manifest.json']]+[(q,Path('context/wo_0_weight')/q.name) for q in ctx.iterdir() if q.is_file()]
 for q,t in pairs:
  target=dest/t;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(q,target);files.append({'original':str(q),'frozen':str(t),'sha256':sha(target),'bytes':target.stat().st_size})
 d={'scope':'All original fixtures copied once; gold is never DUT input except original top F32 stream. Context expectation is not driven into actual layer consumer.','files':files};dump(manifest,d);return d

def full_gate(build,pilot,remaining):
 pr=read(pilot/'receipt_rtl.json');assert pr['verdict']=='PASS' and pr['scope']=='head2';pi=read(pilot/'fixture_identity.json');assert pi['build_manifest_sha256']==sha(build/'source_manifest.json') and pi['fixture_manifest_sha256']==sha(RUN/'fixtures/manifest.json')
 wall=read(pilot/'work/parent_wall_events.json');plan=read(pilot/'guard_rtl/guard_plan.json');offset=(dt.datetime.fromisoformat(wall['started_at'])-dt.datetime.fromisoformat(plan['at'])).total_seconds();assert offset>=0
 events=wall['events'];begins={};ends={};q=None
 for e in events:
  line=e['line'];m=re.fullmatch(r'M007_PARENT_HEAD_BEGIN head=(\d+) cycle=(\d+)',line)
  if m:begins[int(m[1])]=e['elapsed_s']
  m=re.fullmatch(r'M007_PARENT_HEAD_END head=(\d+) cycle=(\d+) head_cycles=(\d+)',line)
  if m:ends[int(m[1])]=e['elapsed_s']
  if line.startswith('M007_PARENT_QKV_ALL_END '):q=e['elapsed_s']+offset
 assert set(begins)==set(ends)=={0,1} and q is not None
 p2=ends[1]+offset;hmax=max(ends[h]-begins[h] for h in [0,1]);estimate=1.10*(p2+14*hmax+q)+10
 gate={'formula':'E=1.10*(P2+14*Hmax+Q)+10','P2_s':p2,'Hmax_s':hmax,'head_stage_s':{str(h):ends[h]-begins[h] for h in [0,1]},'Q_s':q,'guard_to_wall_driver_start_offset_s':offset,'P2_definition':'Guard plan launch timestamp to actual flushed second-head retirement event','Q_definition':'Same launch to actual last public QKV32 handshake event, including loading/prep/quant','Q_is_context_plus_WO_measurement':False,'Q_cost_hypothesis':'Explicit conservative engineering placeholder: same K1024, WO N1024<QKV N3072, same4096 input groups/one matrix/checker structure. Actual complete context/WO not yet measured; falsifiable by full run.','background_standalone_WO_s':203.5584944249713,'background_is_same_parent_evidence':False,'estimate_s':estimate,'single_full_cap_s':3600,'remaining_rtl_s':remaining,'reserve_s':600,'passed':estimate<=3600 and remaining>=estimate+600,'source_build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'pilot':str(pilot),'pilot_receipt_sha256':sha(pilot/'receipt_rtl.json'),'wall_events_sha256':sha(pilot/'work/parent_wall_events.json'),'fixture_manifest_sha256':sha(RUN/'fixtures/manifest.json'),'coefficient_not_modified':True}
 dump(RUN/'reports/full_chain_cost_gate.json',gate);return gate

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('attempt');p.add_argument('--scope',choices=['qkv3','head2','full'],default='qkv3');p.add_argument('--build',type=Path);p.add_argument('--pilot',type=Path);a=p.parse_args();assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
 if a.stage=='rtl':assert a.build and read(a.build/'receipt_static.json')['verdict']=='PASS'
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True);used=costs();cat='static' if a.stage=='build' else 'rtl';timeout=120 if a.stage=='build' or a.scope=='qkv3' else 1200
  if a.stage=='rtl' and a.scope=='head2':
   assert a.pilot;prior=read(a.pilot/'receipt_rtl.json');identity=read(a.pilot/'fixture_identity.json');assert prior['verdict']=='PASS' and prior['scope']=='qkv3' and identity['build_manifest_sha256']==sha(a.build/'source_manifest.json')
  if a.stage=='rtl' and a.scope=='full':
   assert a.pilot;assert not any(read(p).get('scope')=='full' for p in (RUN/'attempts').glob('*/receipt_rtl.json')),'Only one full child; another full needs controller decision'
   gate=full_gate(a.build.resolve(),a.pilot.resolve(),CAPS['rtl']-used['rtl'])
   if not gate['passed']:print('M007_PARENT_FULL_COST_STOP '+json.dumps(gate),flush=True);return 2
   timeout=min(3600,math.ceil(gate['estimate_s']))
  assert timeout<=CAPS[cat]-used[cat] and (cat=='static' or CAPS['rtl']-used['rtl']-timeout>=600)
  at=RUN/'attempts'/a.attempt;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir();fix=fixtures()
  if a.stage=='build':
   selected=closure('m007_full_parent_tb')
   for name,(origin,current,why) in selected.items():shutil.copy2(origin,f/name)
   for q in [Path(__file__),MOD/'tb/m007_full_parent_wall_driver.py',SRC/'make_full_parent_tb.py',SRC/'r003_full_parent_protocol.md',RUN/'tb_extension_boundary.json',RUN/'fixtures/manifest.json']:shutil.copy2(q,f/('fixture_registration.json' if q.name=='manifest.json' else q.name))
   manifest={'started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'host':socket.gethostname(),'top':'m007_full_parent_tb','debug':'typical','O3':True,'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','files':[{'frozen':q.name,'sha256':sha(q),'bytes':q.stat().st_size} for q in sorted(f.iterdir()) if q.is_file()],'parent_sha256':sha(f/'laya_m007_single_parent_v1.sv'),'fixture_manifest_sha256':sha(RUN/'fixtures/manifest.json'),'single_parent_single_services':True,'original_source_tags_not_current_bitstream':True};dump(at/'source_manifest.json',manifest)
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nforeach scope [get_scopes -r /*] {puts $h $scope}\nclose $h\nquit\n')
   script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join([sys.executable,str(f/'audit_parent_source.py'),'--frozen',str(f),'--out',str(at)])+'\n'+shlex.join([str(VIV/'xvlog'),'--sv',*[str(q) for q in sorted(f.iterdir()) if q.suffix in ['.sv','.v']]])+'\n'+shlex.join([str(VIV/'xelab'),'work.m007_full_parent_tb','--relax','-debug','typical','-mt','4','--O3','-s','m007_full_parent_sim'])+'\n'+shlex.join([str(VIV/'xsim'),'m007_full_parent_sim','-tclbatch',str(hier)])+'\necho M007_FULL_PARENT_BUILD_PASS\n');cmd=['/bin/bash',str(script)];marker='M007_FULL_PARENT_BUILD_PASS'
  else:
   build=a.build.resolve()
   for q in (build/'frozen').iterdir():
    if q.is_file():shutil.copy2(q,f/q.name)
   shutil.copytree(build/'work/xsim.dir',w/'xsim.dir')
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   dump(at/'source_manifest.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)} for q in sorted(f.iterdir()) if q.is_file()]})
   dump(at/'fixture_identity.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'fixture_manifest_sha256':sha(RUN/'fixtures/manifest.json'),'fixture_files':fix['files'],'snapshot_files':[{'path':str(q.relative_to(w)),'sha256':sha(q),'bytes':q.stat().st_size} for q in sorted((w/'xsim.dir').rglob('*')) if q.is_file()]})
   prefix=3 if a.scope=='qkv3' else 0;heads=2 if a.scope=='head2' else 0
   cmd=[sys.executable,str(f/'m007_full_parent_wall_driver.py'),'--out',str(w/'parent_wall_events.json'),'--',str(VIV/'xsim'),'m007_full_parent_sim','-runall','-testplusarg','MATRIX='+str(RUN/'fixtures/matrix'),'-testplusarg','INPUT='+str(RUN/'fixtures/input'),'-testplusarg','ATTENTION='+str(RUN/'fixtures/attention'),'-testplusarg','CONTEXT='+str(RUN/'fixtures/context'),'-testplusarg','PREFIX='+str(prefix),'-testplusarg','STOP_AFTER_HEAD='+str(heads)];marker='HARDWARE_AGENT_SIM_PASS '+{'qkv3':'M007_PARENT_QKV_PREFIX','head2':'M007_PARENT_TWO_HEAD','full':'M007_PARENT_FULL'}[a.scope]
  gcmd=[sys.executable,str(f/'m007_parent_guard_v1.py'),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static' else 8),'--timeout-seconds',str(timeout),'--semantic-stall-seconds','120','--phase',cat]+(['--artifact-progress-root',str(w)] if cat=='static' else [])+['--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':gcmd,'scope':a.scope if cat=='rtl' else 'build','used_before_s':used,'lock_held_through_children':True,'reserve_rtl_s':600,'no_old_budget_transfer':True});rc=subprocess.call(gcmd,cwd=w)
  g=read(at/('guard_'+cat)/'guard_result.json');log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL_ERROR|FATAL|Fatal|ERROR)\s*[:\[]',log));passed=rc==0 and not fatal and marker in log;numeric='M007_PARENT_ALL_NUMERIC_PASS' in log;cycle_fail='M007_PARENT_CYCLE_VIOLATION' in log
  verdict='PASS' if passed else 'NUMERIC_PASS_CYCLE_FAIL' if numeric and cycle_fail else 'COST_STOP' if g['trigger'] else 'FAIL'
  dump(at/('receipt_'+cat+'.json'),{'category':cat,'scope':a.scope if cat=='rtl' else 'build','wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'error_or_fatal':fatal,'marker_found':marker in log,'required_marker':marker,'all_numeric_terminal':numeric,'cycle_violation_observed':cycle_fail,'verdict':verdict,'driver_sha256':sha(at/('guard_'+cat)/'driver.log')});used=costs();dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k] for k in CAPS},'reserve_rtl_s':600,'old_balances_transferred':False})
  for line in log.splitlines():
   if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line or 'M007_PARENT_FULL_CYCLES' in line:print(line,flush=True)
  print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
