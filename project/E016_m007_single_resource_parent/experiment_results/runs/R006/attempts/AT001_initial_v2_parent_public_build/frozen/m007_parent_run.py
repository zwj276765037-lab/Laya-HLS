#!/usr/bin/env python3
"""E016 independent guarded attempts; immutable build closure and actual charges."""
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R001';SRC=ROOT/'project/E016_m007_single_resource_parent/experiment_source';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');GUARD=MOD/'tb/m007_parent_guard_v1.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py';CAPS={'reference':180,'static':1800,'rtl':3600,'ooc':0}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def costs():
 v={k:0. for k in CAPS}
 for p in (RUN/'attempts').glob('*/receipt_*.json'):
  d=json.loads(p.read_text());v[d['category']]+=d['wall_s']
 return v

def closure(top):
 sources={}
 old=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R004/attempts/AT019_new_FP_consumer_build';d=json.loads((old/'source_manifest.json').read_text())
 exclude={'laya_m007_pair_ooc_v1.sv','laya_m007_matrix_f32_v1.sv','laya_m007_matrix_full_v1.sv','laya_m007_matrix_superblock_v1.sv','laya_m007_matrix_resources_v1.sv'}
 for e in d['sources']:
  p=Path(e['path'])
  if p.suffix=='.sv' and '/tb/' not in str(p) and p.name not in exclude:sources[p.name]=(old/'frozen'/e['frozen'],p,'immutable E012/R004 AT019')
 old=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R004/attempts/AT019_PREP_coefficient_ownership_guard';d=json.loads((old/'source_manifest.json').read_text())
 for e in d['files']:
  p=ROOT/e['source']
  if '/rtl/' in str(p) and (p.suffix in ['.sv','.v','.dat']):
   if p.name=='laya_attention_layer_v1.sv':continue
   frozen=old/'frozen'/e['frozen']
   if p.name in sources:assert sha(sources[p.name][0])==sha(frozen),'shared dependency divergence '+p.name
   sources[p.name]=(frozen,p,'immutable E010/R004 AT019')
 p=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/laya_attention_resources_v1.sv';assert sha(p)=='484f94579c1abe80b21e8080f32e52aefb30133b12502d42408556721c4c3a09';sources[p.name]=(p,p,'A007 read-only nine DIV output export boundary')
 for p in list((MOD/'rtl').glob('laya_m007*.sv'))+[MOD/('tb/'+top+'.sv'),Path(__file__),SRC/'audit_parent_source.py',SRC/'compose_parent.py',SRC/'make_parent_tb.py',SRC/'make_parent_fault_tb.py',SRC/'make_context_consumer_tb.py',SRC/'make_parent_reset_tb.py',MOD/'tb/m007_parent_guard_test.py',SRC/'tensor_catalog.json',RUN/'reports/parent_port_map.json',GUARD,HELPER]:sources[p.name]=(p,p,'current owned source' if p not in [GUARD,HELPER] else 'guard')
 return sources

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl','guardtest']);p.add_argument('attempt');p.add_argument('--build',type=Path);p.add_argument('--timeout',type=int,default=120);p.add_argument('--prefix',type=int,default=3);p.add_argument('--pilot',type=Path);p.add_argument('--top',choices=['m007_single_parent_tb','m007_parent_fault_tb','m007_context_consumer_tb','m007_parent_reset_tb'],default='m007_single_parent_tb');p.add_argument('--fault',choices=['quant','w','close'],default='quant');a=p.parse_args();assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
 assert a.prefix>=0
 if a.prefix==0:assert a.stage=='rtl' and a.pilot and a.top=='m007_single_parent_tb','Actual same-build QKV3 required for first-head gate'
 if a.stage=='rtl':assert a.build and json.loads((a.build.resolve()/'receipt_static.json').read_text())['verdict']=='PASS','Successful actual build required before an RTL attempt is created'
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  used=costs();cat='rtl' if a.stage=='rtl' else 'static';assert a.timeout<=min(600 if cat=='static' else (120 if a.prefix>0 else 1200),CAPS[cat]-used[cat]);at=RUN/'attempts'/a.attempt;assert not at.exists(),'preserve old attempt';f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
  if a.stage in ['build','guardtest']:
   files=closure(a.top)
   for name,(origin,current,why) in files.items():shutil.copy2(origin,f/name)
   manifest={'started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'host':socket.gethostname(),'top':a.top,'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','profile':0,'original_source_identity':{'model':'6eb6ef58bc4f99bd9db40381604108af','numeric':'aeb13e7937d29fe6a2c68c407249f294','graph':'f33f7848434b73048f957dcd232e1bd4','layout':'2d848b5fb78236c795cb1d442f088393','build':'7209eb09c3f265363cfb274f7790a733'},'original_tag_is_current_physical_build':False,'current_weight_layout':'M007-W576-v1','current_build_identity':'exact compiled source and product manifest in this AT; not a bitstream','files':[{'source':str(current.relative_to(ROOT)),'origin':str(origin),'why':why,'frozen':name,'sha256':sha(f/name),'bytes':(f/name).stat().st_size} for name,(origin,current,why) in files.items()]};dump(at/'source_manifest.json',manifest)
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nforeach scope [get_scopes -r /*] { puts $h $scope }\nclose $h\nquit\n')
   script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+sys.executable+' '+str(f/'audit_parent_source.py')+' --frozen '+str(f)+' --out '+str(at)+'\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(q) for q in sorted(f.iterdir()) if q.suffix in ['.sv','.v'])+'\n'+str(VIV/'xelab')+' work.'+a.top+' --relax -debug typical -mt 4 --O3 -s m007_parent_sim\n'+str(VIV/'xsim')+' m007_parent_sim -tclbatch '+str(hier)+'\n'+'echo M007_PARENT_BUILD_PASS\n');cmd=['/bin/bash',str(script)];marker='M007_PARENT_BUILD_PASS'
   if a.stage=='guardtest':cmd=[sys.executable,str(f/'m007_parent_guard_test.py'),'--guard',str(f/'m007_parent_guard_v1.py'),'--out',str(w)];marker='M007_PARENT_GUARD_CONTRACT_PASS'
  else:
   build=a.build.resolve();assert json.loads((build/'receipt_static.json').read_text())['verdict']=='PASS';assert json.loads((build/'source_manifest.json').read_text()).get('top','m007_single_parent_tb')==a.top
   if a.prefix==0:
    pilot=a.pilot.resolve();pr=json.loads((pilot/'receipt_rtl.json').read_text());pi=json.loads((pilot/'fixture_identity.json').read_text());assert pr['verdict']=='PASS' and pi['build_manifest_sha256']==sha(build/'source_manifest.json')
    plog=(pilot/'guard_rtl/driver.log').read_text();pm=re.search(r'M007_PARENT_QKV_PREFIX_PASS .*?blocks=(\d+).*?elapsed=(\d+)',plog);assert pm and int(pm.group(1))==3
    rates=[{'kind':'actual same-build current-observer QKV3','attempt':str(pilot),'wall_s':pr['wall_s'],'cycles':int(pm.group(2)),'receipt_sha256':sha(pilot/'receipt_rtl.json')}]
    old=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT022_current_complete_f32_qkv';rr=json.loads((old/'receipt_rtl.json').read_text());assert rr['verdict']=='PASS';lm=re.search(r'M007_F32_MATRIX_PASS .*?total_cycles=(\d+)',(old/'guard_rtl/driver.log').read_text());assert lm
    rates.append({'kind':'explicit prior complete-QKV checker cost floor, not current function evidence','attempt':str(old),'wall_s':rr['wall_s'],'cycles':int(lm.group(1)),'receipt_sha256':sha(old/'receipt_rtl.json')})
    old=ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R004/attempts/AT013_pure_layer_encoder_one_complete_head';rr=json.loads((old/'receipt_rtl.json').read_text());assert rr['verdict']=='PASS';lm=re.search(r'M011_LAYER_HEAD_END head=0 .*?cycles=(\d+)',(old/'guard_rtl/driver.log').read_text());assert lm
    rates.append({'kind':'prior complete leaf-head whole-run wall/head-cycle conservative floor; not parent16 evidence','attempt':str(old),'wall_s':rr['guard']['elapsed_seconds'],'cycles':int(lm.group(1)),'receipt_sha256':sha(old/'receipt_rtl.json')})
    for rate in rates:rate['wall_s_per_cycle']=rate['wall_s']/rate['cycles']
    projected=57344+2176+11648;estimate=max(rate['wall_s_per_cycle'] for rate in rates)*projected*1.35+10
    gate={'pilot':str(pilot),'same_build_and_observer':True,'measured_sources':rates,'projected_cycles':projected,'safety_factor':1.35,'startup_margin_s':10,'estimate_s':estimate,'remaining_rtl_s':CAPS['rtl']-used['rtl'],'reserve_s':240,'timeout_s':a.timeout,'scope':'Complete QKV and first complete head only; all16 and WO remain NOT_RUN','passed':estimate<=min(a.timeout,1200,CAPS['rtl']-used['rtl']-240)};dump(at/'cost_gate.json',gate)
    if not gate['passed']:
     dump(at/'receipt_rtl.json',{'category':'rtl','wall_s':0,'verdict':'COST_STOP','reason':'Actual same-build prefix plus conservative previous checker/head costs exceed first-head cap/reserve','cost_gate':gate});return 1
   for q in (build/'frozen').iterdir():
    if q.is_file():shutil.copy2(q,f/q.name)
   shutil.copytree(build/'work/xsim.dir',w/'xsim.dir');
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   fixed={'matrix':ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture','input':ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture','attention':ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle'}
   fixed['context']=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R004/attempts/AT005_original_context_wo_fixture/work/fixture'
   fixtures=[q for q in (fixed['matrix']/'qkv_0_weight').iterdir() if q.is_file()]+[fixed['input']/'qkv_0_weight/input.hex']+[fixed['attention']/name for name in ['cos_full.mem','sin_full.mem','mask.mem','encoder0_pre_qkv.mem','encoder0_post_qkv.mem','encoder0_score.mem','encoder0_maximum.mem','encoder0_prob.mem','encoder0_context.mem','manifest.json']]
   if a.top=='m007_context_consumer_tb':fixtures += [q for q in (fixed['context']/'wo_0_weight').iterdir() if q.is_file()]
   dump(at/'fixture_identity.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'fixture_files':[{'path':str(q),'sha256':sha(q),'bytes':q.stat().st_size} for q in fixtures],'snapshot_files':[{'path':str(q.relative_to(w)),'sha256':sha(q),'bytes':q.stat().st_size} for q in (w/'xsim.dir').rglob('*') if q.is_file()]});dump(at/'source_manifest.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)} for q in f.iterdir() if q.is_file()]})
   cmd=[str(VIV/'xsim'),'m007_parent_sim','-runall','-testplusarg','MATRIX='+str(fixed['matrix']),'-testplusarg','INPUT='+str(fixed['input']),'-testplusarg','ATTENTION='+str(fixed['attention']),'-testplusarg','PREFIX='+str(a.prefix),'-testplusarg','FAULT='+a.fault,'-testplusarg','CONTEXT='+str(fixed['context'])];marker='HARDWARE_AGENT_SIM_PASS '+('M007_PARENT_COMMON_RESET' if a.top=='m007_parent_reset_tb' else 'M007_CONTEXT_CONSUMER' if a.top=='m007_context_consumer_tb' else 'M007_PARENT_ERROR_RECOVERY' if a.top=='m007_parent_fault_tb' else 'M007_PARENT_QKV_PREFIX' if a.prefix>0 else 'M007_PARENT_FIRST_HEAD')
   runtime=MOD/'tb/m007_parent_wall_driver.py';shutil.copy2(runtime,f/runtime.name);shutil.copy2(Path(__file__),f/'m007_parent_run_control.py');dump(at/'runtime_tool_identity.json',{'wall_driver_sha256':sha(f/runtime.name),'current_run_control_sha256':sha(f/'m007_parent_run_control.py'),'compiled_build_unchanged':True})
   cmd=[sys.executable,str(f/runtime.name),'--out',str(w/'parent_wall_events.json'),'--',*cmd]
  gcmd=[sys.executable,str(f/GUARD.name),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static' else 8),'--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120','--phase',cat]+(['--artifact-progress-root',str(w)] if cat=='static' else [])+['--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':gcmd,'used_before_s':used,'lock_held_through_children':True});rc=subprocess.call(gcmd,cwd=w)
  g=json.loads((at/('guard_'+cat)/'guard_result.json').read_text());log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));passed=rc==0 and not fatal and marker in log
  dump(at/('receipt_'+cat+'.json'),{'category':cat,'wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'error_or_fatal':fatal,'marker_found':marker in log,'required_marker':marker,'verdict':'PASS' if passed else 'COST_STOP' if g.get('trigger') else 'FAIL','driver_sha256':sha(at/('guard_'+cat)/'driver.log')});used[cat]+=g['elapsed_seconds'];dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k] for k in CAPS}})
  for line in log.splitlines():
   if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line:print(line,flush=True)
  print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
