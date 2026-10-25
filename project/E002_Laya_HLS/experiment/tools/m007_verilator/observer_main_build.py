#!/usr/bin/env python3
"""Compile/relink a read-only observer main; preserve the failing model and original assertion."""
import fcntl, importlib.util, json, os, subprocess, sys
from pathlib import Path
here=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('d33_observe',here/'run.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
at=m.RUN/'attempts/AT032_model4_readonly_observer'
model=m.RUN/'attempts/AT030_model4_context4_head1'
source=m.RUN/'attempts/AT031_model4_fixedbatch_head1'
cfg=json.loads((at/'config.json').read_text());obj=at/'work/obj';obj.mkdir(exist_ok=True)
out=at/'guard_build'
if out.exists():raise SystemExit('preserve prior observer build')
prior=json.loads((source/'source_manifest.json').read_text())
for manifest in [prior,json.loads((at/'source_manifest.json').read_text())]:
 for x in manifest['sources_and_inputs']:
  if m.sha(Path(x['path']))!=x['sha256']:raise SystemExit('source identity changed: '+x['path'])
name='V'+cfg['top']+'__main.cpp';main=at/'frozen'/name
records=[]
for q in (model/'cxx_units').glob('*.json'):
 x=json.loads(q.read_text())
 if name in x['source_arguments']:records.append((q,x))
if len(records)!=1 or records[0][1]['state']!='COMPLETE':raise SystemExit('actual successful model4 main flags required')
record_path,record=records[0];args=list(record['argv'][1:]);new_object=obj/(Path(name).stem+'.o')
args[args.index(name)]=str(main);args[args.index('-o')+1]=str(new_object)
compile_cmd=[sys.executable,str(here/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*args]
archive_name='V'+cfg['top']+'__ALL.a';source_archive=model/'work/obj'/archive_name;archive=obj/archive_name
old_link=json.loads((source/'overlay_commands.json').read_text())['link'];link_args=list(old_link[old_link.index('--')+1:]);link_args[link_args.index(str(source_archive))]=str(archive);link_args[link_args.index('-o')+1]=str(obj/('V'+cfg['top']))
commands=[compile_cmd,['/usr/bin/ar','-r',str(archive),str(new_object)],[sys.executable,str(here/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*link_args]]
driver=at/'observer_build_commands.py';driver.write_text('import shutil,subprocess\nshutil.copy2('+repr(str(source_archive))+','+repr(str(archive))+')\n'+'\n'.join('subprocess.run('+repr(c)+',cwd='+repr(record['cwd'])+',check=True)' for c in commands)+'\n')
for q in (model/'work').glob('*.dat'):(at/'work'/q.name).symlink_to(q)
paths=[Path(x['path']) for x in prior['sources_and_inputs']]+[source_archive,source/'receipt_build.json',source/'receipt_rtl.json',source/'overlay_commands.json',at/'config.json',at/'source_manifest.json',main,at/'frozen/observer_fields.json',record_path,driver,Path(__file__),here/'cxx_record.py']
m.dump(at/'runtime_build_manifest.json',{'runtime_identity':cfg['runtime_identity']+'; read-only rootp observer main','sources_and_inputs':[m.identify(q) for q in dict.fromkeys(paths)],'DUT_assignments':False,'original_assertion_unchanged':True,'only_main_object_new':True,'compile_commands':commands})
if m.budget()['static']+20>1800:raise SystemExit('D33 budget')
guard=Path(cfg['guard_path']);argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(at/'work'),'--rss-gib','24','--timeout-seconds','20','--semantic-stall-seconds','120','--phase','static','--artifact-progress-root',str(at/'work'),'--',sys.executable,str(driver)]
m.dump(at/'command_build.json',{'category':'static','argv':argv,'budget_before_seconds':m.budget(),'actual_main_compiler_record':m.identify(record_path)})
env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
 with (at/'build_wrapper.log').open('w') as f:rc=subprocess.call(argv,cwd=at/'work',env=env,stdout=f,stderr=subprocess.STDOUT)
g=json.loads((out/'guard_result.json').read_text());exe=obj/('V'+cfg['top']);ok=rc==0 and not g.get('trigger') and exe.exists()
m.dump(at/'receipt_build.json',{'category':'static','stage':'build','verdict':'PASS' if ok else ('COST_STOP' if g.get('trigger') else 'FAIL'),'guard':g,'guard_wrapper_exit':rc,'executable':m.identify(exe) if exe.exists() else None,'only_main_object_new':True,'diagnostic_only':True})
print(json.dumps({'verdict':'PASS' if ok else 'FAIL','elapsed_seconds':g['elapsed_seconds']}),flush=True)
raise SystemExit(0 if ok else 1)
