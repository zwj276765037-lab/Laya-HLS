#!/usr/bin/env python3
"""CE-JOINT-COST-27 immutable production source build and real joint runtime."""
import argparse,hashlib,json,re,shutil,struct,subprocess,tarfile,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];MOD=Path(__file__).resolve().parents[1];EXP=MOD.parents[2];VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
SRC=ROOT/'project/E019_m007_residual_ln_residency/experiment_source'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def selected_sources():
 from m007_joint23_run import selected_sources as prior_sources
 ce=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R002/ce26_production_manifest_v1.json';cm=json.loads(ce.read_text())
 for n,h in cm['v2_selected_dependencies'].items():assert sha(EXP/n)==h,'CE26 dependency drift '+n
 allowed={Path(n).name for n in cm['v2_selected_dependencies']}
 files=[q for q in prior_sources()if q.suffix in ['.sv','.v','.dat']and '/tb/'not in str(q)and('/vector_and_ffn/rtl/'not in str(q)or q.name.startswith('laya_m007_g_')or q.name in allowed)]
 files += [EXP/n for n in cm['v2_selected_dependencies']]
 files += [MOD/'rtl/laya_m007_resident_joint_v2_header.svh',MOD/'tb/m007_joint27_tb.sv',MOD/'tb/m007_joint27_run.py',MOD/'tb/m007_joint27_guard.py',MOD/'tb/m007_joint23_run.py',MOD.parent/'layernorm_engine/tb/m007_ln_process_guard.py',ce,ROOT/'project/E014_m007_layernorm32/experiment_results/runs/R002/source_manifest_v3_verified.json',SRC/'protocol_r003.md',SRC/'generate_joint27_tb.py',SRC/'joint27_functional_cycle_trace_v1.json',ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R003/dependency_manifest_prebuild_v1.json']
 return sorted(set(files))
def fixture_files():
 r=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R001/attempts/AT001_original_residual_fixture/work'
 g=ROOT/'project/E014_m007_layernorm32/experiment_results/runs/R001/attempts/AT001_original_ln_reference/fixture'
 n=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work/norm_ff.bin'
 v=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work/geglu_vectors.hex'
 return {'H':r/'H.hex','Q':r/'Q.hex','GOLD':r/'GOLD.hex','NORM':n,'GRAW':g/'gamma_encoder27/raw.hex','GGOLD':g/'gamma_encoder27/output.hex','GAMMA':g/'gamma.hex','GV':v}
def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=['build','rtl']);p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--force-ce',type=int,choices=[0,1],default=0);p.add_argument('--mode',type=int,choices=[0],default=0);p.add_argument('--rows',type=int,choices=[16,128],default=16);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False);f=o/'frozen';f.mkdir()
 with tarfile.open(o.parent/'sources.tar.gz')as arc:arc.extractall(f,filter='data')
 receipt=json.loads((o.parent/'receipt.json').read_text());sourceids=receipt['source_sha256'];sources=[f/n for n in sourceids if Path(n).suffix in ['.sv','.v']]
 for n,h in sourceids.items():assert sha(f/n)==h
 for n in sourceids:
  if n.endswith('.dat'):shutil.copy2(f/n,o/Path(n).name)
 if a.stage=='build':
  sources.sort(key=lambda q:(q.name!='laya_m007_tanh_fast_leaves_v1.sv',q.name))
  for cmd in [[str(VIV/'xvlog'),'--sv',*[str(q)for q in sources]],[str(VIV/'xelab'),'work.m007_joint27_tb','--relax','-debug','typical','-mt','4','--O3','-generic_top','FORCE_CORE_CE='+str(a.force_ce),'-s','joint27_sim']]:
   print('COMMAND',cmd,flush=True);subprocess.run(cmd,cwd=o,check=True)
  save(o/'report.json',{'status':'BUILD_COMPLETE','force_core_ce':a.force_ce,'driver_sha256':sha(Path(__file__)),'source_sha256':sourceids,'compiled_source_sha256':{n:h for n,h in sourceids.items()if Path(n).suffix in ['.sv','.v','.dat']or n.endswith('/m007_joint27_run.py')},'snapshot':{str(q.relative_to(o)):sha(q)for q in(o/'xsim.dir').rglob('*')if q.is_file()},'top':'m007_joint27_tb','scope':'Single production resident_joint_v2/resources/arena, not parent or physical implementation'})
 else:
  b=a.build.resolve();m=json.loads((b/'report.json').read_text());assert m['status']=='BUILD_COMPLETE'and sha(Path(__file__))==m['driver_sha256']and m['force_core_ce']==a.force_ce
  for n,h in m['compiled_source_sha256'].items():assert sourceids.get(n)==h,'new source differs from compiled snapshot '+n
  for n,h in m['snapshot'].items():assert sha(b/n)==h
  fix=fixture_files();assert sha(fix['NORM'])=='6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863'
  # Only exact word serialization of an existing independently generated checker.
  nf=o/'norm_ff_words.hex';nf.write_text(''.join(f'{v:08x}\n'for(v,)in struct.iter_unpack('<I',fix['NORM'].read_bytes())))
  ids={n:{'path':str(q),'sha256':sha(q),'bytes':q.stat().st_size}for n,q in fix.items()};save(o/'fixture_identity.json',{'files':ids,'norm_serialization_sha256':sha(nf),'arithmetic_or_new_gold':False})
  cmd=[str(VIV/'xsim'),'joint27_sim','-runall','-testplusarg','TRACE_FILE='+str(o/'functional_cycle_trace.hex'),'-testplusarg','MODE='+str(a.mode),'-testplusarg','ROWS='+str(a.rows),'-testplusarg','PROGRESS_FILE='+str(o/'semantic_progress.jsonl')]
  for n,q in fix.items():cmd+=['-testplusarg',n+'='+str(nf if n=='NORM'else q)]
  events=[];start=time.monotonic();print('COMMAND',cmd,flush=True)
  with(o/'xsim_stdout.log').open('w')as out:
   child=subprocess.Popen(cmd,cwd=b,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
   for line in child.stdout:
    out.write(line);out.flush();print(line,end='',flush=True)
    if line.startswith(('JOINT23_LN_','JOINT23_STAGE ','JOINT27_')):events.append({'line':line.rstrip(),'elapsed_s':time.monotonic()-start})
   rc=child.wait()
  log=(b/'xsim.log').read_text();(o/'xsim.log').write_text(log);assert rc==0 and not re.search(r'(?im)^\s*(?:Fatal|ERROR):',log)
  marker=next(x for x in log.splitlines()if x.startswith('HARDWARE_AGENT_SIM_PASS JOINT23 '));metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',marker)}
  assert metrics['rows']==a.rows and metrics['mode']==a.mode and metrics['gamma_reused']==int(a.mode==1)and metrics['nan_recovered']==int(a.mode==2)
  if a.mode==0:assert metrics['ln_vectors']==a.rows*32 and metrics['g_outputs']>=8
  cmline=next(x for x in log.splitlines()if x.startswith('JOINT27_CYCLES '));cycles={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',cmline)}
  cel=next(x for x in log.splitlines()if x.startswith('JOINT27_CE '));ce_metrics={k:int(v)for k,v in re.findall(r'(\w+)=(\d+)',cel)};assert ce_metrics['force']==a.force_ce
  trace=o/'functional_cycle_trace.hex';assert trace.stat().st_size>0
  if a.force_ce:assert ce_metrics['ce0']==0
  else:assert ce_metrics['ce0']>0 and ce_metrics['ce1']>0
  save(o/'report.json',{'status':'PASS','force_core_ce':a.force_ce,'cycles':cycles,'CE_metrics':ce_metrics,'functional_cycle_trace_sha256':sha(trace),'functional_cycle_trace_bytes':trace.stat().st_size,'scope':('JOINT_RESIDUAL_LN_'+str(a.rows)+'_PASS')if a.mode==0 else'JOINT_GAMMA_REUSE_PASS'if a.mode==1 else'JOINT_NAN_RECOVERY_PASS','metrics':metrics,'build_manifest_sha256':sha(b/'report.json'),'driver_sha256':sha(Path(__file__)),'fixture_identity_sha256':sha(o/'fixture_identity.json'),'wall_events':events,'runtime_body_wall_s':time.monotonic()-start,'xsim_log_sha256':sha(o/'xsim.log'),'result_marker':marker,'LN_binding':'verified v3 core2a9760; previous c612 full128 results independent','NOT_RUN':['complete Encoder/30layer','physical fit/timing']})
 return 0
if __name__=='__main__':raise SystemExit(main())
