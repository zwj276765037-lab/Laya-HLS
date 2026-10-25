#!/usr/bin/env python3
"""E016 independent guarded attempts; immutable build closure and actual charges."""
import argparse,datetime as dt,fcntl,hashlib,json,re,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R001';SRC=ROOT/'project/E016_m007_single_resource_parent/experiment_source';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');GUARD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/production_guard.py';HELPER=ROOT/'project/E002_Laya_HLS/experiment/tools/hls_guard_helpers.py';CAPS={'reference':180,'static':1800,'rtl':3600,'ooc':0}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def costs():
 v={k:0. for k in CAPS}
 for p in (RUN/'attempts').glob('*/receipt_*.json'):
  d=json.loads(p.read_text());v[d['category']]+=d['wall_s']
 return v

def closure():
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
 for p in list((MOD/'rtl').glob('laya_m007*.sv'))+[MOD/'tb/m007_single_parent_tb.sv',Path(__file__),SRC/'audit_parent_source.py',SRC/'compose_parent.py',SRC/'make_parent_tb.py',SRC/'tensor_catalog.json',RUN/'reports/parent_port_map.json',GUARD,HELPER]:sources[p.name]=(p,p,'current owned source' if p not in [GUARD,HELPER] else 'guard')
 return sources

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('attempt');p.add_argument('--build',type=Path);p.add_argument('--timeout',type=int,default=120);p.add_argument('--prefix',type=int,default=3);a=p.parse_args();assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
 assert a.prefix>0,'Complete parent requires a later actual same-build cost gate; no launch'
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  used=costs();cat='static' if a.stage=='build' else 'rtl';assert a.timeout<=min(600 if cat=='static' else 120,CAPS[cat]-used[cat]);at=RUN/'attempts'/a.attempt;assert not at.exists(),'preserve old attempt';f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir()
  if a.stage=='build':
   files=closure()
   for name,(origin,current,why) in files.items():shutil.copy2(origin,f/name)
   manifest={'started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'host':socket.gethostname(),'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','profile':0,'original_source_identity':{'model':'6eb6ef58bc4f99bd9db40381604108af','numeric':'aeb13e7937d29fe6a2c68c407249f294','graph':'f33f7848434b73048f957dcd232e1bd4','layout':'2d848b5fb78236c795cb1d442f088393','build':'7209eb09c3f265363cfb274f7790a733'},'original_tag_is_current_physical_build':False,'current_weight_layout':'M007-W576-v1','current_build_identity':'exact compiled source and product manifest in this AT; not a bitstream','files':[{'source':str(current.relative_to(ROOT)),'origin':str(origin),'why':why,'frozen':name,'sha256':sha(f/name),'bytes':(f/name).stat().st_size} for name,(origin,current,why) in files.items()]};dump(at/'source_manifest.json',manifest)
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nforeach scope [get_scopes -r /*] { puts $h $scope }\nclose $h\nquit\n')
   script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+sys.executable+' '+str(f/'audit_parent_source.py')+' --frozen '+str(f)+' --out '+str(at)+'\n'+str(VIV/'xvlog')+' --sv '+' '.join(str(q) for q in sorted(f.iterdir()) if q.suffix in ['.sv','.v'])+'\n'+str(VIV/'xelab')+' work.m007_single_parent_tb --relax -debug typical -mt 4 --O3 -s m007_parent_sim\n'+str(VIV/'xsim')+' m007_parent_sim -tclbatch '+str(hier)+'\n'+'echo M007_PARENT_BUILD_PASS\n');cmd=['/bin/bash',str(script)];marker='M007_PARENT_BUILD_PASS'
  else:
   build=a.build.resolve();assert json.loads((build/'receipt_static.json').read_text())['verdict']=='PASS'
   for q in (build/'frozen').iterdir():
    if q.is_file():shutil.copy2(q,f/q.name)
   shutil.copytree(build/'work/xsim.dir',w/'xsim.dir');
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   fixed={'matrix':ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture','input':ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R003/attempts/AT007_original_quant_global_errors/work/fixture','attention':ROOT/'project/E010_m007_attention_bank_qk_av/experiment_results/runs/R003/attempts/AT001_original_b1_three_layer_local_reference/work/oracle'}
   fixtures=[q for q in (fixed['matrix']/'qkv_0_weight').iterdir() if q.is_file()]+[fixed['input']/'qkv_0_weight/input.hex']+[fixed['attention']/name for name in ['cos_full.mem','sin_full.mem','mask.mem','encoder0_pre_qkv.mem','manifest.json']]
   dump(at/'fixture_identity.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'fixture_files':[{'path':str(q),'sha256':sha(q),'bytes':q.stat().st_size} for q in fixtures],'snapshot_files':[{'path':str(q.relative_to(w)),'sha256':sha(q),'bytes':q.stat().st_size} for q in (w/'xsim.dir').rglob('*') if q.is_file()]});dump(at/'source_manifest.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)} for q in f.iterdir() if q.is_file()]})
   cmd=[str(VIV/'xsim'),'m007_parent_sim','-runall','-testplusarg','MATRIX='+str(fixed['matrix']),'-testplusarg','INPUT='+str(fixed['input']),'-testplusarg','ATTENTION='+str(fixed['attention']),'-testplusarg','PREFIX='+str(a.prefix)];marker='HARDWARE_AGENT_SIM_PASS M007_PARENT_QKV_PREFIX'
  gcmd=[sys.executable,str(GUARD),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static' else 8),'--timeout-seconds',str(a.timeout),'--semantic-stall-seconds','120','--artifact-progress-root',str(w),'--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':gcmd,'used_before_s':used,'lock_held_through_children':True});rc=subprocess.call(gcmd,cwd=w)
  g=json.loads((at/('guard_'+cat)/'guard_result.json').read_text());log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL|Fatal|ERROR)\s*[:\[]',log));passed=rc==0 and not fatal and marker in log
  dump(at/('receipt_'+cat+'.json'),{'category':cat,'wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'error_or_fatal':fatal,'marker_found':marker in log,'required_marker':marker,'verdict':'PASS' if passed else 'COST_STOP' if g.get('trigger') else 'FAIL','driver_sha256':sha(at/('guard_'+cat)/'driver.log')});used[cat]+=g['elapsed_seconds'];dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k] for k in CAPS}})
  for line in log.splitlines():
   if '_PASS' in line or 'Fatal:' in line or 'ERROR:' in line:print(line,flush=True)
  print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
