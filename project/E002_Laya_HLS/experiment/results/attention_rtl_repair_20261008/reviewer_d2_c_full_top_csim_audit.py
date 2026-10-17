from pathlib import Path
import json,hashlib,struct,subprocess,shlex,re,datetime,math
P=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline');R=P/'results/attention_rtl_repair_20261008';D=R/'d2_full_top_csim_official_v1';M=P/'build/model-attention-rtl-repair-20261008';B=P/'build/full-top-d2-csim-official-20261008';C=B/'csim/hls/csim/build';evidence={}
def sha(p):
 p=Path(p);h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 v=h.hexdigest();evidence[str(p)]=v;return v
def read(p):sha(p);return json.loads(Path(p).read_text())
inp={};lines=(D/'input_hashes.sha256').read_text().splitlines()
for line in lines:
 expected,n=line.split(None,1);p=Path(n.strip());assert p.is_absolute() and sha(p)==expected,str(p);inp[str(p)]=expected
assert len(lines)==113 and len(inp)==112;sha(D/'input_hashes.sha256')
manifest=read(M/'manifest.json');pre=read(M/'build_preimage.json');sources={x['path']:x['sha256'] for x in pre['sources']};assert len(sources)==104
for n,h in sources.items():assert sha(P/n)==h,n
for k,v in manifest['tag_preimages'].items():assert sha(M/v['file'])==v['sha256'] and v['sha256'].startswith(manifest['tags'][k])
for k,v in manifest['bo'].items():assert (M/v['file']).stat().st_size==v['size'] and sha(M/v['file'])==v['sha256']
assert manifest['tags']['build']=='fe067c8aa0627ad770096f9721394645'
meta=dict(line.split('=',1) for line in (D/'metadata.txt').read_text().splitlines());sha(D/'metadata.txt')
assert meta['root']==str(P) and meta['build']==str(B) and meta['model']==str(M)
request=Path(meta['request']);oracle_dir=Path(meta['oracle']);assert oracle_dir==R/'d2_cpu_full_official/oracle/B2_S128'
dut=read(R/'d2_cpu_full_official/dut/full_forward_dut_run_report.json');rq=dut['inputs']['B2_S128'];frame=request.read_bytes();assert str(request)==rq['path'] and sha(request)==rq['sha256'] and len(frame)==1856
assert frame[:4]==b'LYRQ' and struct.unpack_from('<HH',frame,20)==(2,128)
with (M/'aux.bin').open('rb') as f:aux=f.read(128)
assert frame[40:104]==aux[32:96]
prior=read(R/'reviewer_d2_c_official_cpu_review.json');assert prior['decision']=='ACCEPT_D2_C_OFFICIAL_NATIVE_CPU_SEGMENT_ONLY'
oracle_path=R/'d2_cpu_full_official/oracle/full_forward_oracle_report.json';oracle=read(oracle_path);assert prior['artifact_sha256'][str(oracle_path)]==sha(oracle_path)
assert sha(P/'tests/full_reference.py')==oracle['reference_sha256'];assert sha(P/'tests/full_forward_oracle.py')==oracle['script_sha256']
checkpoints=oracle['runs']['B2_S128']['checkpoints'];assert len(checkpoints)==47
values=0
for cp in checkpoints:
 p=Path(cp['path']);assert p.parent==oracle_dir and p.name==cp['name']+'.f32.bin';assert sha(p)==cp['sha256'] and p.stat().st_size==cp['bytes']==math.prod(cp['shape'])*4;assert str(p) in inp;values+=cp['bytes']//4
assert values==9047192 and len(list(oracle_dir.glob('*.f32.bin')))==47
config=(B/'full_top.cfg').read_text();sha(B/'full_top.cfg');prod=[Path(x.split('=',1)[1]) for x in config.splitlines() if x.startswith('syn.file=')];assert len(prod)==25
assert all(str(x) in inp and str(x.relative_to(P)) in sources for x in prod)
for prefix in ['syn.cflags=','tb.cflags=']:
 flags=next(x for x in config.splitlines() if x.startswith(prefix));assert '-O2 -fno-fast-math -ffp-contract=off' in flags
assert 'csim.stdmath=true' in config and 'syn.top=laya_typed_q8_forward' in config
mk=(C/'csim.mk').read_text();assert mk==(D/'csim.mk').read_text();sha(C/'csim.mk');sha(D/'csim.mk')
listed=[(C/x).resolve() for x in shlex.split(next(x for x in mk.splitlines() if x.startswith('HLS_SOURCES =')).split('=',1)[1])];tb=P/'hls/platform/full_kernel_csim_tb.cpp';assert set(listed)==set(prod+[tb]) and len(listed)==26
compile_lines=[l for l in mk.splitlines() if '$(CXX)' in l and '-c -MMD' in l];assert len(compile_lines)==26
assert all('-O2 -fno-fast-math -ffp-contract=off' in l for l in compile_lines);assert sum('-fhls-csim -fhlstoplevel=laya_typed_q8_forward' in l for l in compile_lines)==25
assert '__SIM_MATHSTD__ = 1' in mk and '-D__SYNTHESIS__' not in mk
objs={}
for src in listed:
 obj=C/'obj'/(src.stem+'.o');dep=C/'obj'/(src.stem+'.d');assert obj.stat().st_size>0
 text=dep.read_text().replace('\\\n',' ');paths=[(C/x).resolve() for x in shlex.split(text.split(':',1)[1])];assert src in paths
 for p in paths:
  if p.is_relative_to(P):
   assert str(p) in inp or str(p.relative_to(P)) in sources,str(p);sha(p)
 objs[str(src)]={'source_sha256':sha(src),'object':str(obj),'object_sha256':sha(obj),'dependency_file':str(dep),'dependency_sha256':sha(dep),'project_dependency_count':sum(p.is_relative_to(P) for p in paths)}
exe=C/'csim.exe';binary_hash=sha(exe);assert all((C/'obj'/(s.stem+'.o')).stat().st_mtime<=exe.stat().st_mtime for s in listed)
ldd=subprocess.check_output(['ldd',str(exe)],text=True);syms=subprocess.check_output(['readelf','-Ws',str(exe)],text=True);dyn=subprocess.check_output(['readelf','-d',str(exe)],text=True)
assert 'libm.so.6' in dyn and 'libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6' in ldd
for name in ['expf','sqrtf','tanhf']:assert re.search(r'UND '+name+r'@GLIBC_',syms)
assert re.search(r'FUNC\s+GLOBAL\s+DEFAULT\s+\d+ laya_typed_q8_forward',syms)
(D/'reviewer_actual_linked_libraries.txt').write_text(ldd);(D/'reviewer_actual_binary_dynamic_symbols.txt').write_text(syms);sha(D/'reviewer_actual_linked_libraries.txt');sha(D/'reviewer_actual_binary_dynamic_symbols.txt')
command=shlex.split((D/'csim.command').read_text());sha(D/'csim.command')
for k,v in [('PACKAGE',M),('REQUEST',request),('ORACLE',oracle_dir)]:assert 'LAYA_FULL_HLS_'+k+'='+str(v) in command
assert '--csim' in command and str(B/'full_top.cfg') in command
log=(D/'csim.log').read_text();sha(D/'csim.log');assert 'FULL_KERNEL_CSIM_PASS checkpoints=47 values=9047192 tasks=37158' in log and 'CSim done with 0 errors.' in log and 'FULL_KERNEL_CSIM_FAIL' not in log
assert (D/'csim.exit').read_text().strip()=='0';sha(D/'csim.exit');guard=read(R/'d2_full_top_csim_guard_v1/guard_result.json');assert guard['child_exit_code']==0 and guard['trigger'] is None
assert sha(P/'hls/control/full_forward_controller.cpp')=='23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623'
report={'decision':'ACCEPT_D2_C_OFFICIAL_FULL_TOP_B2_S128_STANDARD_LIBM_CSIM_ONLY','reviewer':{'model':'gpt-6-astra','reasoning_effort':'xhigh'},'reviewed_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'official_root':str(P),'model_package':str(M),'tags':manifest['tags'],'independent_audit':{'input_manifest_entries_recomputed':113,'input_manifest_unique_files':112,'input_manifest_duplicate':'full_kernel_wrapper.h appears twice with the same matching hash; no inconsistency','official_build_preimage_sources_recomputed':104,'model_bos_recomputed':5,'production_translation_units':25,'testbench_translation_units':1,'objects_and_dependency_files_hashed':26,'oracle_files_recomputed':47,'oracle_values':values,'oracle_provenance':'Exact report and independent reference/driver hashes accepted in prior official CPU review; actual B2 checkpoint files rehashed here','actual_libm':'/lib/x86_64-linux-gnu/libm.so.6; expf/sqrtf/tanhf GLIBC dynamic symbols','strict_floating_point':'Both design and TB actual make rules have -O2 -fno-fast-math -ffp-contract=off; standard math selected','request':'Exact official B2/S128 request with model/header tag equality','binary':str(exe),'binary_sha256':binary_hash},'reviewed_testbench_behavior':['Loads all five actual model BOs and official B2/S128 request','Calls laya_typed_q8_forward with all 13 actual BO pointers','46 unique production graph checkpoint callbacks read actual BO bytes and compare against independent oracle','Final 36 F32 values extracted from committed result frame and compared bit-for-bit to final18 oracle','Success requires 37158 retired tasks, 28 encoder layers and 2 decision layers','No replacement arithmetic stubs in the 25 production translation units; CPU callback memory path remains a CSim proof boundary'],'result':{'checkpoints':47,'compared_f32_values':9047192,'tasks_retired':37158,'encoder_layers':28,'decision_layers':2,'csim_exit':0,'tool_errors':0,'guard':guard},'compiled_objects':objs,'phase_status':{'official_native_cpu':'accepted previously including B2, B1, fault/recovery','synthesis_storage_cpu_shadow':'accepted previously','standard_libm_csim':'accepted here for one B2/S128 call','d2_r_rtl':'separate bounded v3 attempt; not covered here','d2_i_controller_reachability':'separate pending proof','full_top_hls_release':False,'complete_functional_rtl_accepted':False},'scope_limits':['This run proves the full official 13-port CSim software path for B2/S128 only.','B1, accepted failure and recovery were not executed by this CSim testbench; they belong to separate CPU/shadow evidence.','No RTL numerical or transaction-latency conclusion follows from this CSim.','No full-top synthesis, routed timing, board result or 50ms performance acceptance.'],'artifact_sha256':evidence}
out=R/'reviewer_d2_c_full_top_csim_review.json';out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'decision':report['decision'],'report':str(out),'sha256':sha(out),'input_entries':113,'unique_inputs':112,'official_sources':104,'oracle_files':47,'values':values}))
