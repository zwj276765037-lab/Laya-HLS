#!/usr/bin/env python3
"""Reuse D36 successful same-layout objects; preserve old cwd/PCH/flags for new TUs."""
import argparse,fcntl,hashlib,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent;RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004';VROOT=Path('/home/user/EDA-202/zhuowenjun/.local-tools/verilator-5.020/usr/share/verilator')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def budget():
 return sum(json.loads(p.read_text()).get('guard',{}).get('elapsed_seconds',json.loads(p.read_text()).get('elapsed_seconds',0.)) for p in [*RUN.glob('receipt_*.json'),*RUN.glob('attempts/AT*/receipt_*.json')] if json.loads(p.read_text()).get('category')=='static')
def main():
 p=argparse.ArgumentParser();p.add_argument('--attempt',required=True);p.add_argument('--base',required=True);a=p.parse_args();started=time.monotonic();at=RUN/'attempts'/a.attempt;base=RUN/'attempts'/a.base;obj=at/'work/obj';old=base/'work/obj';cfg=json.loads((at/'config.json').read_text());top='V'+cfg['top'];out=at/'guard_build';assert not out.exists() and not (at/'receipt_build.json').exists()
 assert json.loads((at/'receipt_translate.json').read_text())['verdict']=='PASS';done=json.loads((base/'complete_build_dispatch.json').read_text());assert done['status']=='PASS';br=json.loads((base/'receipt_build.json').read_text());assert br['verdict']=='PASS'
 headers=[*obj.glob('*.h'),*obj.glob('*.mk')];same=all((old/p.name).exists() and p.read_bytes()==(old/p.name).read_bytes() for p in headers)
 if not same:
  dump(at/'incremental_reuse_ineligible.json',{'status':'HEADER_OR_BUILD_FRAGMENT_CHANGED_NO_REUSE','base':str(base),'changed_headers_or_make':[p.name for p in headers if not (old/p.name).exists() or p.read_bytes()!=(old/p.name).read_bytes()]});return 2
 cpp=sorted(obj.glob('*.cpp'));assert {p.name for p in cpp}=={p.name for p in old.glob('*.cpp')};changed=[p for p in cpp if p.read_bytes()!=(old/p.name).read_bytes()];
 if len(changed)>64:
  dump(at/'incremental_reuse_ineligible.json',{'status':'CHANGED_SET_OVER64_USE_BOUNDED_FULL_PLAN','changed_cpp_count':len(changed)});return 2
 objects={Path(z['path']).name:z for z in br['completed_objects']};records={};link_record=None
 for rp in (base/'cxx_units').glob('*.json'):
  z=json.loads(rp.read_text())
  if z.get('state')!='COMPLETE' or z.get('exit_code')!=0:continue
  if z['kind']=='compile':
   for src in z.get('source_arguments',[]):
    if Path(src).name in {p.name for p in cpp}:records[Path(src).name]=(rp,z)
  elif '-o' in z['argv'] and z['argv'][z['argv'].index('-o')+1]==top:link_record=(rp,z)
 assert len(records)==len(cpp) and link_record
 deps={};commands=[]
 for src in cpp:
  name=src.stem+'.o';assert sha(old/name)==objects[name]['sha256'];dep=old/(src.stem+'.d');assert dep.exists();items=dep.read_text().replace('\\\n',' ').split(':',1)[1].split();deps[src.name]=items
  for item in items:
   q=Path(item)
   if not q.is_absolute() and q.suffix=='.h':assert (old/q).read_bytes()==(obj/q).read_bytes(),item
  if src in changed:
   record_path,z=records[src.name];argv=list(z['argv'][1:]);assert '-ffast-math' not in argv;argv[argv.index(z['source_arguments'][0])]=str(src);argv[argv.index('-o')+1]=str(obj/name);commands.append([sys.executable,str(HERE/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*argv])
 pch=[p for p in old.glob('*pch*') if p.is_file()];assert pch
 archive=old/(top+'__ALL.a');members=subprocess.check_output(['/usr/bin/ar','t',str(archive)],text=True).splitlines();assert set(members)=={p.stem+'.o' for p in cpp}
 for name in members:assert hashlib.sha256(subprocess.check_output(['/usr/bin/ar','p',str(archive),name])).hexdigest()==objects[name]['sha256'],name
 newarchive=obj/archive.name;link=list(link_record[1]['argv'][1:]);link=[str(newarchive) if q==archive.name else str(obj/top) if q==top else q for q in link];assert str(newarchive) in link
 link=[sys.executable,str(HERE/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*link]
 driver=at/'incremental_build_commands.py';driver.write_text('import concurrent.futures,shutil,subprocess\ncommands='+repr(commands)+'\ncwd='+repr(str(old))+'\nwith concurrent.futures.ThreadPoolExecutor(max_workers=4) as ex:\n list(ex.map(lambda cmd: subprocess.run(cmd,cwd=cwd,check=True),commands))\nshutil.copy2('+repr(str(archive))+','+repr(str(newarchive))+')\nsubprocess.run('+repr(['/usr/bin/ar','-r',str(newarchive),*[str(obj/(p.stem+'.o')) for p in changed]])+',cwd=cwd,check=True)\nsubprocess.run('+repr(link)+',cwd=cwd,check=True)\n')
 proof={'status':'VERIFIED_COMPATIBLE_INCREMENTAL_REUSE','base':str(base),'base_build_receipt':identify(base/'receipt_build.json'),'all_generated_headers_and_make_fragments_equal':[identify(p) for p in headers],'total_cpp':len(cpp),'changed_cpp':[identify(p) for p in changed],'reused_cpp_count':len(cpp)-len(changed),'successful_original_compile_records':[identify(records[p.name][0]) for p in cpp],'actual_original_dependencies':deps,'reused_objects':[objects[p.stem+'.o'] for p in cpp if p not in changed],'original_PCH_and_exact_compile_cwd':[identify(p) for p in pch],'compile_commands':commands,'old_archive':identify(archive),'old_archive_all_members_equal_successful_objects':True,'link_record':identify(link_record[0]),'same_compiler_and_flags_except_source_output_paths':True,'base_fixed_runtime':identify(old/'verilated_timing.o'),'new_fixed_runtime':identify(obj/'verilated_timing.o')};assert proof['base_fixed_runtime']['sha256']==proof['new_fixed_runtime']['sha256'];dump(at/'incremental_reuse_proof.json',proof)
 paths=[Path(__file__),driver,at/'incremental_reuse_proof.json',archive,*pch,*[Path(z['path']) for z in proof['reused_objects']],old/'verilated.o',old/'verilated_threads.o',old/'verilated_timing.o',*headers,*changed];paths.extend(q for q in VROOT.rglob('*.h') if q.is_file());dump(at/'incremental_execution_manifest.json',{'sources_and_inputs':[identify(q) for q in dict.fromkeys(paths)],'scope':'SEGMENTED_SUFFIX build only'})
 dump(at/'receipt_incremental_prepare.json',{'category':'static','verdict':'PASS','stage':'exact_incremental_dependency_object_archive_PCH_verification','elapsed_seconds':time.monotonic()-started,'guarded':False,'new_simulation_or_build':False})
 assert budget()+120<=1800,'D36 static budget'
 cmd=[sys.executable,str(HERE/'fullgraph_guard_v1.py'),'--out',str(out),'--cwd',str(at/'work'),'--rss-gib','24','--timeout-seconds','120','--semantic-stall-seconds','120','--phase','static','--artifact-progress-root',str(at/'work'),'--',sys.executable,str(driver)];dump(at/'command_build.json',{'category':'static','argv':cmd,'budget_before_seconds':budget(),'reuse_proof':identify(at/'incremental_reuse_proof.json')});env=os.environ.copy();env['VERILATOR_ROOT']=str(VROOT);env['PYTHONPATH']=str(ROOT/'project/E002_Laya_HLS/experiment/tools')
 with (ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
  print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
  with (at/'build_wrapper.log').open('w') as f:rc=subprocess.call(cmd,cwd=at/'work',env=env,stdout=f,stderr=subprocess.STDOUT)
 g=json.loads((out/'guard_result.json').read_text());exe=obj/top;ok=rc==0 and not g['trigger'] and exe.exists();final_objects=[identify(obj/(p.stem+'.o')) if p in changed else objects[p.stem+'.o'] for p in cpp];dump(at/'receipt_build.json',{'category':'static','verdict':'PASS' if ok else 'COST_STOP' if g['trigger'] else 'FAIL','guard':g,'guard_wrapper_exit':rc,'completed_objects':final_objects,'executable':identify(exe) if exe.exists() else None,'recompiled_generated_objects':len(changed),'reused_generated_objects':len(cpp)-len(changed),'archive':identify(newarchive) if newarchive.exists() else None});print(json.dumps({'verdict':'PASS' if ok else 'FAIL','elapsed_seconds':g['elapsed_seconds'],'recompiled':len(changed),'reused':len(cpp)-len(changed)}),flush=True);return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
