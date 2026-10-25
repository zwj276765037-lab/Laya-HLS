#!/usr/bin/env python3
"""Launch one frozen D36 old/prefix/full suffix attempt under original project guard."""
import argparse,datetime as dt,fcntl,hashlib,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004'
VROOT=Path('/home/user/EDA-202/zhuowenjun/.local-tools/verilator-5.020/usr/share/verilator')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def budget():
 totals={'static':0.,'rtl':0.}
 for p in [*RUN.glob('receipt_*.json'),*RUN.glob('attempts/AT*/receipt_*.json')]:
  x=json.loads(p.read_text());cat=x.get('category')
  if cat in totals:totals[cat]+=x.get('guard',{}).get('elapsed_seconds',x.get('elapsed_seconds',0.))
 return totals
def verify_manifest(p):
 x=json.loads(p.read_text())
 for z in x['sources_and_inputs']:assert sha(Path(z['path']))==z['sha256'],'identity changed '+z['path']
def main():
 p=argparse.ArgumentParser();p.add_argument('mode',choices=['old','pilot','full']);p.add_argument('--attempt',required=True);p.add_argument('--build-attempt',required=True);a=p.parse_args()
 start=time.monotonic();at=RUN/'attempts'/a.attempt;assert not at.exists(),'preserve existing attempt'
 base=RUN/'attempts'/a.build_attempt;verify_manifest(base/'source_manifest.json');verify_manifest(base/'generated_build_inputs.json');incremental=base/'incremental_execution_manifest.json'
 if incremental.exists():verify_manifest(incremental)
 bp=base/'complete_build_dispatch.json';build=json.loads(bp.read_text()) if bp.exists() else json.loads((base/'receipt_build.json').read_text());assert build.get('status',build.get('verdict'))=='PASS'
 at.mkdir();work=at/'work';work.mkdir();frozen=at/'frozen';frozen.mkdir();cfg=json.loads((base/'config.json').read_text());exe=base/'work/obj'/('V'+cfg['top'])
 assert sha(exe)==build['executable']['sha256'];cfg['source_executable']=str(exe);cfg['case']='D36_SEGMENTED_SUFFIX_'+a.mode;cfg['plusargs']=[q.replace(str(base/'work'),str(work)) if q.startswith('+EXPORT=') else q for q in cfg['plusargs']]
 assert '+KIND=7' in cfg['plusargs'] and any('VERIFY_POST_ENCODER27_H=1' in q for q in cfg['verilator_flags']) and any(q.startswith('+POST_ENCODER27_H=') for q in cfg['plusargs'])
 for q in (base/'work').glob('*.dat'):(work/q.name).symlink_to(q.resolve())
 dump(at/'config.json',cfg)
 contract=ROOT/'mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md';text=contract.read_text();(frozen/'D36_contract.md').write_text(text[text.index('## D-M007-SM012-FINAL-LN-SUFFIX-36'):]);(frozen/'AGENTS.md').write_bytes((ROOT/'AGENTS.md').read_bytes())
 driver=HERE/'suffix_driver_r004.py';legacy=HERE/'original30_driver_r003.py';guard=HERE/'fullgraph_guard_v1.py'
 for q in [driver,legacy,Path(__file__)]: (frozen/q.name).write_bytes(q.read_bytes())
 paths=[exe,driver,legacy,guard,Path(__file__),at/'config.json',base/'source_manifest.json',base/'generated_build_inputs.json',base/'generated_scale_gate.json',RUN/'saved_actual_input_integrity.json',RUN/'frozen_input/encoder27.actual.f32.bin',RUN/'frozen_input/encoder27.actual.group32.hex',frozen/'D36_contract.md']
 paths.extend(Path(z['path']) for z in json.loads((base/'source_manifest.json').read_text())['sources_and_inputs'])
 if incremental.exists():paths.extend([incremental,*[Path(z['path']) for z in json.loads(incremental.read_text())['sources_and_inputs']]])
 dump(at/'source_manifest.json',{'scope':'SEGMENTED_SUFFIX','sources_and_inputs':[identify(q) for q in dict.fromkeys(paths)],'actual_model':'UNKNOWN','actual_effort':'UNKNOWN','same_runtime_model1_context1':True,'original30_fullgraph_complete':False})
 prep=time.monotonic()-start;dump(at/'receipt_prepare.json',{'category':'static','verdict':'PASS','stage':'freeze_exact_suffix_execution','elapsed_seconds':prep,'guarded':False,'new_simulation_or_build':False});assert prep<=120
 cap=1800 if a.mode=='full' else 120;assert 3600-budget()['rtl']>=cap+300,'independent RTL budget+reserve'
 prefix=Path(next(z.split('=',1)[1] for z in cfg['plusargs'] if z.startswith('+EXPORT=')));gold=ROOT/'project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128';fixture=Path(next(z.split('=',1)[1] for z in cfg['plusargs'] if z.startswith('+ORIGINAL_GRAPH=')))
 cmd=[sys.executable,str(driver),a.mode,'--receipt',str(work/'suffix_driver_receipt.json'),'--events',str(work/'wall_events.jsonl'),'--segments',str(work/'stage_retirements.jsonl'),'--status',str(work/'live_status.json'),'--prefix',str(prefix),'--gold-dir',str(gold),'--tail-hex',str(fixture/'tail544.hex'),'--actual-input',str(RUN/'frozen_input/encoder27.actual.f32.bin'),'--command',str(exe),*cfg['plusargs']]
 out=at/'guard_rtl';argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(work),'--rss-gib','8','--timeout-seconds',str(cap),'--semantic-stall-seconds','120','--phase','rtl','--',*cmd]
 dump(at/'command_rtl.json',{'scope':'SEGMENTED_SUFFIX','category':'rtl','argv':argv,'budget_before_seconds':budget(),'original30_fullgraph_complete':False,'resource_policy':{'CPU':[0,1,2,3],'model_threads':1,'nice':19,'IOclass':3,'MemAvailable_min_GiB':192,'RSS_GiB':8,'max_cycles':40000000,'global_seconds':cap,'decision_seconds':600,'continuous_stage_seconds':120,'semantic_stall_seconds':120}})
 env=os.environ.copy();env['VERILATOR_ROOT']=str(VROOT);env['PYTHONPATH']=str(ROOT/'project/E002_Laya_HLS/experiment/tools')
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  with (at/'rtl_wrapper.log').open('w') as f:rc=subprocess.call(argv,cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT)
 g=json.loads((out/'guard_result.json').read_text());ip=work/'suffix_driver_receipt.json';inner=json.loads(ip.read_text()) if ip.exists() else None;allowed={'old':'EXPECTED_FAIL_REPRODUCED','pilot':'PREFIX_PASS','full':'PASS'}[a.mode];ok=rc==0 and not g['trigger'] and inner and inner['verdict']==allowed;cost=bool(g['trigger']) or bool(inner and inner['verdict']=='COST_STOP');verdict='PASS' if ok else 'COST_STOP' if cost else 'FAIL'
 dump(at/'receipt_rtl.json',{'category':'rtl','verdict':verdict,'validation_kind':a.mode,'inner_expected_verdict':allowed,'scope':'SEGMENTED_SUFFIX','guard':g,'guard_wrapper_exit':rc,'driver_receipt':inner,'segmented_suffix_complete':bool(ok and a.mode=='full'),'original30_fullgraph_complete':False})
 dump(RUN/'budget_current.json',{'scope':'D36_SEGMENTED_SUFFIX','measured_seconds':budget(),'limits':{'static':1800,'rtl':3600,'rtl_reserve':300,'reference':0,'ooc':0},'old_balance_transferred':False,'unmeasured_orchestration_authoring_reporting_seconds':'UNKNOWN, not0'})
 print(json.dumps({'attempt':a.attempt,'mode':a.mode,'verdict':verdict,'expected_inner':allowed,'actual_inner':inner.get('verdict') if inner else None,'elapsed_seconds':g['elapsed_seconds'],'trigger':g['trigger'],'reason':inner.get('reason') if inner else None}),flush=True);return 0 if ok else 124 if cost else 1
if __name__=='__main__':raise SystemExit(main())
