#!/usr/bin/env python3
"""Remove only source-proven, actually relocated cross-TU empty dispatch calls in two generated callers."""
import difflib,fcntl,importlib.util,json,os,re,subprocess,sys
from pathlib import Path
h=Path(__file__).resolve().parent;s=importlib.util.spec_from_file_location('m',h/'fullgraph_run_r002.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);r=m.RUN;orig=r/'attempts/AT003_fullgraph_peer_unrolled';base=r/'attempts/AT005_first_original_layer';at=r/'attempts/AT006_empty_dispatch';obj=at/'work/obj';obj.mkdir(parents=True,exist_ok=False);frozen=at/'frozen';frozen.mkdir();cfg=json.loads((base/'config.json').read_text());cfg['plusargs']=[f'+EXPORT={at}/work/actual_fullgraph' if z.startswith('+EXPORT=') else z for z in cfg['plusargs']];m.dump(at/'config.json',cfg);prior=orig/'work/obj'
for item in json.loads((base/'source_manifest.json').read_text())['sources_and_inputs']:
 if m.sha(Path(item['path']))!=item['sha256']:raise SystemExit('frozen input changed')
# The entire allowed empty body consists of unused suppression, an unused Symsp pointer and debug macro.
funcs={};pattern=re.compile(r'void (Vm007_fullgraph_binary_tb___024root___eval_(?:nba|act)__\d+)\(Vm007_fullgraph_binary_tb___024root\* vlSelf\) \{\n(.*?)\n\}',re.S)
for p in prior.glob('*.cpp'):
 for q in pattern.finditer(p.read_text()):
  body=q.group(2);clean=re.sub(r'^\s*if \(false && vlSelf\) \{\}  // Prevent unused\s*$','',body,flags=re.M);clean=re.sub(r'^\s*Vm007_fullgraph_binary_tb__Syms\* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;\s*$','',clean,flags=re.M);clean=re.sub(r'^\s*VL_DEBUG_IF\(VL_DBG_MSGF\("[^"\n]*"\); \);\s*$','',clean,flags=re.M);clean=re.sub(r'^\s*// Body\s*$','',clean,flags=re.M)
  funcs[q.group(1)]={'path':p,'body':body,'empty':not clean.strip()}
records=[]
for q in (orig/'cxx_units').glob('*.json'):
 z=json.loads(q.read_text());z['record_path']=str(q);records.append(z)
assert not any(any(v.startswith('-DVL_DEBUG') for v in z['argv']) for z in records)
macros=subprocess.check_output(['/usr/bin/g++','-dM','-E','-x','c++','-I'+str(m.VROOT/'include'),'-include','verilated.h','-'],input=b'').decode();assert not re.search(r'^#define VL_DEBUG(?:\s|$)',macros,re.M);(at/'actual_preprocessor_macros.txt').write_text(macros)
changed=[];proof=[];all_removed=[];commands=[];patch=[]
for number,kind,expected in [(528,'nba',579),(104,'act',11)]:
 name='Vm007_fullgraph_binary_tb___024root__DepSet_h1b9c86bc__'+str(number)+'.cpp';source=prior/name;data=source.read_text();lines=data.splitlines(True);removed=[];new=[]
 relocation=subprocess.check_output(['/usr/bin/objdump','-r','-C',str(source.with_suffix('.o'))],text=True);(at/(str(number)+'_actual_relocations.txt')).write_text(relocation)
 for i,line in enumerate(lines):
  match=re.fullmatch(r'    (Vm007_fullgraph_binary_tb___024root___eval_'+kind+r'__\d+)\(vlSelf\);\n',line)
  if match and funcs[match.group(1)]['empty'] and funcs[match.group(1)]['path']!=source:
   symbol=match.group(1);matches=[z for z in relocation.splitlines() if re.search(r'\b'+re.escape(symbol)+r'\(',z)];assert len(matches)==1
   removed.append({'line_index':i,'line':line,'callee':symbol,'callee_source':m.identify(funcs[symbol]['path']),'callee_body':funcs[symbol]['body'],'actual_relocation':matches[0]});all_removed.append(symbol)
  else:new.append(line)
 assert len(removed)==expected,(number,len(removed));newtext=''.join(new);reverse=list(new)
 for z in removed:reverse.insert(z['line_index'],z['line'])
 assert ''.join(reverse)==data
 target=frozen/name;target.write_text(newtext);changed.append(target);proof.append({'caller':m.identify(source),'new':m.identify(target),'deleted_calls':removed,'inverse_restores_original_bytes':True,'all_other_bytes_unchanged':True});patch+=list(difflib.unified_diff(lines,newtext.splitlines(True),fromfile='original/'+name,tofile='empty_dispatch/'+name))
 recs=[z for z in records if name in z.get('source_arguments',[])];assert len(recs)==1 and recs[0]['state']=='COMPLETE';z=recs[0];args=list(z['argv'][1:]);args[args.index(name)]=str(target);args[args.index('-o')+1]=str(obj/target.with_suffix('.o').name);commands.append([sys.executable,str(h/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*args])
assert len(all_removed)==len(set(all_removed))==590
(at/'exact590_call_deletion.patch').write_text(''.join(patch));m.dump(at/'empty_dispatch_proof.json',{'scope':'two callers only;579NBA+11active exact cross-TU no-op calls','proof':proof,'actual_flags_no_VL_DEBUG':True,'actual_preprocessor_VL_DEBUG_absent':True,'empty_source_body_grammar':'only unused suppression,unused Symsp local,VL_DEBUG_IF compiled away; actual source and A010 object proof','nonempty_dispatch_trigger_NBA_time_and_convergence_unchanged':True,'removed_count':590,'old_sources_objects_executable_unchanged':True})
link0=json.loads((base/'main_build_commands.py').read_text().split('subprocess.run(')[-1].split(',cwd=')[0]) if False else json.loads((r/'attempts/AT004_fullgraph_fixedbatch_pilot/overlay_commands.json').read_text())['link'];args=list(link0[link0.index('--')+1:]);oldarchive=base/'work/obj'/('V'+cfg['top']+'__ALL.a');archive=obj/oldarchive.name;oldlinkarchive=next(v for v in args if v.endswith('.a'));args[args.index(oldlinkarchive)]=str(archive);args[args.index('-o')+1]=str(obj/('V'+cfg['top']));link=[sys.executable,str(h/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*args];driver=at/'build_commands.py';driver.write_text('import concurrent.futures,shutil,subprocess\nshutil.copy2('+repr(str(oldarchive))+','+repr(str(archive))+')\ncmds='+repr(commands)+'\ndef run(c):subprocess.run(c,cwd='+repr(str(prior))+',check=True)\nwith concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:list(pool.map(run,cmds))\nsubprocess.run('+repr(['/usr/bin/ar','-r',str(archive),*[str(obj/p.with_suffix('.o').name) for p in changed]])+',check=True)\nsubprocess.run('+repr(link)+',cwd='+repr(str(prior))+',check=True)\n')
paths=[Path(v['path']) for v in json.loads((base/'source_manifest.json').read_text())['sources_and_inputs']]+[base/'receipt_build.json',oldarchive,*changed,at/'empty_dispatch_proof.json',at/'exact590_call_deletion.patch',at/'actual_preprocessor_macros.txt',driver,Path(__file__),at/'config.json'];m.dump(at/'source_manifest.json',{'sources_and_inputs':[m.identify(p) for p in dict.fromkeys(paths)],'only_two_generated_callers_changed':True,'baseline_main_capture_and_runtime_unchanged':True,'all_layout_headers_PCH_and_actual_original_compile_flags_unchanged':True,'no_old_failed_object_reuse':True})
for p in (base/'work').glob('*.dat'):(at/'work'/p.name).symlink_to(p.resolve())
out=at/'guard_build';guard=Path(cfg['guard_path']);cmd=[sys.executable,str(guard),'--out',str(out),'--cwd',str(at/'work'),'--rss-gib','24','--timeout-seconds','120','--semantic-stall-seconds','120','--phase','static','--artifact-progress-root',str(at/'work'),'--',sys.executable,str(driver)];env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 with (at/'build_wrapper.log').open('w') as stream:rc=subprocess.call(cmd,cwd=at/'work',env=env,stdout=stream,stderr=subprocess.STDOUT)
g=json.loads((out/'guard_result.json').read_text());exe=obj/('V'+cfg['top']);ok=rc==0 and not g['trigger'] and exe.exists();m.dump(at/'receipt_build.json',{'category':'static','verdict':'PASS' if ok else 'FAIL','guard':g,'guard_wrapper_exit':rc,'executable':m.identify(exe) if exe.exists() else None,'exact_calls_removed':590,'generated_TUs_recompiled':2});print(json.dumps({'verdict':'PASS' if ok else 'FAIL','elapsed_seconds':g['elapsed_seconds'],'exact_removed_calls':590}),flush=True);raise SystemExit(0 if ok else 1)
