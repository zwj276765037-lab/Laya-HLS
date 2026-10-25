#!/usr/bin/env python3
"""Finish an already translated closure in bounded disjoint object batches."""
import argparse,datetime as dt,hashlib,json,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('attempt');p.add_argument('--total-seconds',type=int,required=True);p.add_argument('--authorization-evidence',required=True,type=Path);a=p.parse_args()
root=Path(__file__).resolve().parents[5];run=root/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R001';at=run/'attempts'/a.attempt;obj=at/'work/obj';state=at/'complete_build_dispatch.json'
if state.exists():raise SystemExit('Preserve existing dispatch; no automatic timeout extension')
if a.total_seconds>900 or a.total_seconds<120:raise SystemExit('invalid bounded plan')
if not a.authorization_evidence.is_file():raise SystemExit('root plan evidence required')
tr=json.loads((at/'receipt_translate.json').read_text())
if tr['verdict']!='PASS':raise SystemExit('successful current translation required')
started=time.monotonic();cpp=sorted(obj.glob('*.cpp'),key=lambda x:x.stat().st_size,reverse=True);remaining=[x for x in cpp if not (obj/(x.stem+'.o')).is_file()];batches=[remaining[i:i+64] for i in range(0,len(remaining),64)]
s={'status':'RUNNING','started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'total_plan_seconds':a.total_seconds,'driver_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'authorization_evidence':str(a.authorization_evidence.resolve()),'authorization_sha256':hashlib.sha256(a.authorization_evidence.read_bytes()).hexdigest(),'current_translated_cpp_count':len(cpp),'initial_successful_generated_objects':len(cpp)-len(remaining),'remaining_generated_objects':len(remaining),'batch_size':64,'batches':[],'no_failed_or_interrupted_object_reuse':True}
def save():
 s['elapsed_seconds']=time.monotonic()-started;state.write_text(json.dumps(s,indent=2)+'\n')
def execute(targets,kind):
 remaining_time=a.total_seconds-(time.monotonic()-started)
 if remaining_time<=20:s.update(status='COST_STOP',reason='complete_build_plan_before_next_batch');save();return False
 cap=min(120,int(remaining_time-15));cmd=[sys.executable,str(Path(__file__).with_name('run.py')),'build',a.attempt,'--timeout',str(cap)]
 if targets:cmd+=['--targets',*targets]
 b={'kind':kind,'argv':cmd,'guard_cap_seconds':cap,'started_at':dt.datetime.now(dt.timezone.utc).isoformat(),'targets':targets};s['batches'].append(b);save();stamp=time.monotonic();rc=subprocess.call(cmd,cwd=root);b.update(exit_code=rc,wall_seconds=time.monotonic()-stamp,finished_at=dt.datetime.now(dt.timezone.utc).isoformat());save()
 if rc!=0:s.update(status='FAIL_OR_COST_STOP',reason='bounded batch failed; no extension');save();return False
 print('COMPILED_BATCH_DONE',len(s['batches']),'remaining_generated_objects',sum(not (obj/(p.stem+'.o')).is_file() for p in cpp),'elapsed',round(s['elapsed_seconds'],3),flush=True);return True
for batch in batches:
 if not execute([x.stem+'.o' for x in batch],'generated_object_batch'):raise SystemExit(1)
if not execute([], 'remaining_runtime_archive_and_link'):raise SystemExit(1)
cfg=json.loads((at/'config.json').read_text());exe=obj/('V'+cfg['top']);s['generated_objects_complete']=sum((obj/(p.stem+'.o')).is_file() for p in cpp);s['executable']={'path':str(exe),'sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'bytes':exe.stat().st_size} if exe.is_file() else None;s['status']='PASS' if s['generated_objects_complete']==len(cpp) and exe.is_file() else 'FAIL';s['finished_at']=dt.datetime.now(dt.timezone.utc).isoformat();save();print('COMPLETE_BUILD',s['status'],'elapsed',s['elapsed_seconds'],flush=True);raise SystemExit(0 if s['status']=='PASS' else 1)
