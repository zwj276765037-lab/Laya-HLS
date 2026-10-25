#!/usr/bin/env python3
"""FFN-CHAIN-20 current closure, fixed actual costs and one full command."""
import argparse,datetime as dt,fcntl,hashlib,json,math,re,shlex,shutil,socket,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];SRC=ROOT/'project/E016_m007_single_resource_parent/experiment_source';RUN=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin');CAPS={'reference':180,'static':900,'rtl':6000,'ooc':0}
sys.path.insert(0,str(MOD/'tb'));from m007_parent_run import closure
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n')
def read(p):return json.loads(p.read_text())
def costs():
 d={k:0. for k in CAPS}
 for p in(RUN/'attempts').glob('*/receipt*.json'):
  x=read(p);d[x.get('category',x.get('phase'))]+=x.get('wall_s',x.get('child_wall_s',0))
 return d
def fixtures():
 dest=RUN/'fixtures';p=dest/'manifest.json'
 if p.exists():
  d=read(p)
  for e in d['files']:assert sha(dest/e['frozen'])==e['sha256']
  return d
 dest.mkdir();files=[];reference=RUN/'attempts/AT009_merge_original128_reference/work';matrix=ROOT/'project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture';g=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work'
 pairs=[(reference/n,Path('reference')/n)for n in ['norm_ff_quant/source_f32_groups.hex','norm_ff_quant/a_write_row_major.hex','g_quant/a_write_row_major.hex','wi_native_output.hex','down/output.hex','report.json']]+[(matrix/folder/f'p{i}.hex',Path(name)/f'p{i}.hex')for folder,name in [('mlp_wi_0_weight','wi'),('mlp_wo_0_weight','down')]for i in range(4)]+[(g/'geglu_vectors.hex',Path('geglu_vectors.hex'))]
 for origin,rel in pairs:
  q=dest/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(origin,q);files.append({'original':str(origin),'frozen':str(rel),'sha256':sha(q),'bytes':q.stat().st_size})
 d={'scope':'Original norm_ff public input; independent CPU Wi/G/node/Q8/Down expectations only; G is never driven into production','reference_report':read(reference/'report.json'),'files':files};dump(p,d);return d
def selected_sources():
 sources=closure('m007_ffn_parent_tb');att=MOD.parent/'attention_and_fp_engine/rtl'
 # MOD is forward_controller; its sibling directories hold shared sources.
 att=MOD.parent/'attention_and_fp_engine/rtl'
 for p in att.iterdir():
  if p.is_file()and p.name in sources:sources[p.name]=(p,p,'current shared consumer; immutable in this build')
 for name in ['laya_m007_control_workspace_joint_v1.sv','laya_m007_control_workspace_v1.sv']:
  p=att/name;sources[name]=(p,p,'actual pure shared-control composition')
 vector=MOD.parent/'vector_and_ffn/rtl'
 for p in vector.glob('laya_m007*.sv'):sources[p.name]=(p,p,'original production G/pool/TANH; shared read-only')
 for p in [Path(__file__),MOD/'tb/m007_ffn_parent_wall_driver.py',SRC/'compose_ffn_parent_r005.py',SRC/'make_ffn_parent_tb_r005.py',SRC/'protocol_ffn_r005.md']:
  sources[p.name]=(p,p,'current owned FFN source/protocol')
 assert sha(vector/'laya_m007_g_engine_v1.sv')=='6b8b0114f64bdab6391ad7df251c0fd2fb3d31cfd1bde89305accd08eda8a106'
 assert sha(att/'laya_m007_control_workspace_joint_v1.sv')=='aa4c419fbfa71c6d3fc528b3fdc94d6f5de29876353157830320904002168c0f'
 return sources
def gate(build,pilot,blocks,remaining):
 pr=read(pilot/'receipt_rtl.json');assert pr['verdict']=='PASS';pi=read(pilot/'fixture_identity.json');assert pi['build_manifest_sha256']==sha(build/'source_manifest.json')and pi['fixture_manifest_sha256']==sha(RUN/'fixtures/manifest.json')
 w=read(pilot/'work/ffn_wall_events.json');plan=read(pilot/'guard_rtl/guard_plan.json');offset=(dt.datetime.fromisoformat(w['started_at'])-dt.datetime.fromisoformat(plan['at'])).total_seconds();assert offset>=0
 gs={};ms={}
 for e in w['events']:
  m=re.fullmatch(r'M007_FFN_G_BLOCK s=(\d+) cycle=(\d+) values=(\d+) nodes=(\d+)',e['line'])
  if m:gs[int(m[1])]=e['elapsed_s']+offset
  m=re.fullmatch(r'M007_FFN_MATRIX_BLOCK phase=0 s=(\d+) cycle=(\d+) values=(\d+)',e['line'])
  if m:ms[int(m[1])]=e['elapsed_s']+offset
 count=pr['blocks'];assert count in [3,16]and len(gs)>=count
 bmax=max([gs[i]-gs[i-1]for i in range(1,count)]+[ms[i]-ms[i-1]for i in range(1,min(count,len(ms)))])
 if blocks==16:
  assert count==3;estimate=1.35*(gs[2]+13*bmax)+10;cap=1200
 else:
  assert blocks==0 and count==16;estimate=1.35*(gs[15]+66*bmax+16*(2624/1024)*bmax)+10;cap=3600
 d={'schema':'m007-ffn-chain20-current-build-cost-v1','pilot':str(pilot),'pilot_receipt_sha256':sha(pilot/'receipt_rtl.json'),'build_manifest_sha256':sha(build/'source_manifest.json'),'pilot_blocks':count,'target_blocks':82 if blocks==0 else 16,'actual_fixed_and_first_blocks_s':gs[count-1],'maximum_observed_block_s':bmax,'guard_wall_offset_s':offset,'safety_factor':1.35,'startup_margin_s':10,'estimate_s':estimate,'cap_s':cap,'remaining_rtl_s':remaining,'reserve_s':300,'passed':estimate<=cap and remaining>=estimate+300,'unmeasured_Down_basis':'Same unique matrix/A/W/FP/PS and output checker,16blocks K2624 vs Wi K1024; conservative maximum observed Wi/G-overlap block wall multiplied2624/1024. No same-runtime Down measurement yet; explicit falsifiable engineering bound.','formula':'1.35*(P3+13*Bmax)+10'if blocks==16 else'1.35*(P16+66*Bmax+16*(2624/1024)*Bmax)+10'}
 dump(RUN/('reports/full_cost_gate.json'if blocks==0 else'reports/block16_cost_gate.json'),d);return d
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('attempt');p.add_argument('--blocks',type=int,choices=[0,3,16],default=3);p.add_argument('--build',type=Path);p.add_argument('--pilot',type=Path);a=p.parse_args();assert re.fullmatch(r'AT\d{3}_[A-Za-z0-9_]+',a.attempt)
 with(ROOT/'.research-agent/m007_heavy.lock').open('a+')as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);used=costs();cat='static'if a.stage=='build'else'rtl';timeout=120
  if a.stage=='rtl':
   assert a.build and read(a.build/'receipt_static.json')['verdict']=='PASS'
   if a.blocks!=3:
    assert a.pilot;g=gate(a.build.resolve(),a.pilot.resolve(),a.blocks,CAPS['rtl']-used['rtl'])
    if not g['passed']:print('M007_FFN_COST_STOP '+json.dumps(g),flush=True);return 2
    timeout=math.ceil(g['estimate_s'])
   if a.blocks==0:assert not any(read(p).get('blocks')==0 for p in(RUN/'attempts').glob('*/receipt_rtl.json')),'One full request only; retry requires controller decision'
  assert timeout<=CAPS[cat]-used[cat]and(cat=='static'or CAPS['rtl']-used['rtl']>=timeout+300)
  at=RUN/'attempts'/a.attempt;assert not at.exists();f=at/'frozen';w=at/'work';f.mkdir(parents=True);w.mkdir();fix=fixtures()
  if a.stage=='build':
   selected=selected_sources()
   for name,(origin,current,why)in selected.items():shutil.copy2(origin,f/name)
   dump(at/'source_manifest.json',{'top':'m007_ffn_parent_tb','host':socket.gethostname(),'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','parent_sha256':sha(f/'laya_m007_single_parent_v1.sv'),'fixture_manifest_sha256':sha(RUN/'fixtures/manifest.json'),'original_build_tag_is_current_compiled_identity':False,'files':[{'frozen':name,'source':str(current),'origin':str(origin),'sha256':sha(f/name),'bytes':(f/name).stat().st_size,'why':why}for name,(origin,current,why)in selected.items()]})
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   hier=w/'hierarchy.tcl';hier.write_text('set h [open hierarchy_scopes.txt w]\nforeach scope [get_scopes -r /*] {puts $h $scope}\nclose $h\nquit\n')
   script=w/'build.sh';script.write_text('#!/bin/bash\nset -euo pipefail\n'+shlex.join([str(VIV/'xvlog'),'--sv',*[str(q)for q in sorted(f.iterdir())if q.suffix in ['.sv','.v']]])+'\n'+shlex.join([str(VIV/'xelab'),'work.m007_ffn_parent_tb','--relax','-debug','typical','-mt','4','--O3','-s','m007_ffn_parent_sim'])+'\n'+shlex.join([str(VIV/'xsim'),'m007_ffn_parent_sim','-tclbatch',str(hier)])+'\necho M007_FFN_BUILD_PASS\n');cmd=['/bin/bash',str(script)];marker='M007_FFN_BUILD_PASS'
  else:
   build=a.build.resolve()
   for q in(build/'frozen').iterdir():
    if q.is_file():shutil.copy2(q,f/q.name)
   shutil.copytree(build/'work/xsim.dir',w/'xsim.dir')
   for q in f.glob('*.dat'):shutil.copy2(q,w/q.name)
   dump(at/'source_manifest.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'files':[{'frozen':q.name,'sha256':sha(q)}for q in sorted(f.iterdir())if q.is_file()]});dump(at/'fixture_identity.json',{'build':str(build),'build_manifest_sha256':sha(build/'source_manifest.json'),'fixture_manifest_sha256':sha(RUN/'fixtures/manifest.json'),'snapshot_files':[{'path':str(q.relative_to(w)),'sha256':sha(q)}for q in sorted((w/'xsim.dir').rglob('*'))if q.is_file()]})
   cmd=[sys.executable,str(f/'m007_ffn_parent_wall_driver.py'),'--out',str(w/'ffn_wall_events.json'),'--',str(VIV/'xsim'),'m007_ffn_parent_sim','-runall','-testplusarg','FIXTURE='+str(RUN/'fixtures/reference'),'-testplusarg','WI='+str(RUN/'fixtures/wi'),'-testplusarg','DOWN='+str(RUN/'fixtures/down'),'-testplusarg','G='+str(RUN/'fixtures/geglu_vectors.hex'),'-testplusarg','BLOCKS='+str(a.blocks)];marker='HARDWARE_AGENT_SIM_PASS M007_FFN_FULL'if a.blocks==0 else'HARDWARE_AGENT_SIM_PASS M007_FFN_PREFIX'
  gcmd=[sys.executable,str(f/'m007_parent_guard_v1.py'),'--out',str(at/('guard_'+cat)),'--cwd',str(w),'--rss-gib',str(24 if cat=='static'else 8),'--timeout-seconds',str(timeout),'--semantic-stall-seconds','120','--phase',cat]+(['--artifact-progress-root',str(w)]if cat=='static'else[])+['--',*cmd];dump(at/('command_'+cat+'.json'),{'argv':gcmd,'used_before_s':used,'single_project_lock_held':True,'no_old_budget_transfer':True,'requested_timeout_s':timeout});rc=subprocess.call(gcmd,cwd=w)
  g=read(at/('guard_'+cat)/'guard_result.json');log=(at/('guard_'+cat)/'driver.log').read_text(errors='replace');fatal=bool(re.search(r'(?im)(?:^|\s)(?:FATAL_ERROR|FATAL|Fatal|ERROR)\s*[:\[]',log));passed=rc==0 and not fatal and marker in log
  dump(at/('receipt_'+cat+'.json'),{'category':cat,'blocks':a.blocks if cat=='rtl'else None,'wall_s':g['elapsed_seconds'],'guard':g,'guard_exit':rc,'required_marker':marker,'marker_found':marker in log,'error_or_fatal':fatal,'verdict':'PASS'if passed else'COST_STOP'if g['trigger']else'FAIL'});used=costs();dump(RUN/'budget_ledger.json',{'limits_s':CAPS,'used_s':used,'remaining_s':{k:CAPS[k]-used[k]for k in CAPS},'reserve_rtl_s':300,'old_balances_transferred':False})
  for line in log.splitlines():
   if '_PASS'in line or 'Fatal:'in line or 'ERROR:'in line:print(line,flush=True)
  print(json.dumps(g),flush=True);return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
