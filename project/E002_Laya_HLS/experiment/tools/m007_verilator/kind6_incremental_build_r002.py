#!/usr/bin/env python3
"""Reuse only proven compatible AT003 objects, and derive a read-only global H capture."""
import concurrent.futures, fcntl, importlib.util, json, os, re, shutil, subprocess, sys
from pathlib import Path

h=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('m',h/'fullgraph_run_r002.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
at=m.RUN/'attempts/AT010_kind6_public_abi';base=m.RUN/'attempts/AT003_fullgraph_peer_unrolled';fixed=m.RUN/'attempts/AT004_fullgraph_fixedbatch_pilot'
obj=at/'work/obj';old=base/'work/obj';cfg=json.loads((at/'config.json').read_text());top='V'+cfg['top'];main_name=top+'__main.cpp'
if (at/'receipt_build.json').exists() or (at/'incremental_reuse_proof.json').exists():raise SystemExit('preserve existing build/proof')
assert json.loads((at/'receipt_translate.json').read_text())['verdict']=='PASS'
for x in json.loads((at/'source_manifest.json').read_text())['sources_and_inputs']:
 assert m.sha(Path(x['path']))==x['sha256'],x['path']
headers=sorted(obj.glob('*.h'));assert len(headers)==4
for p in [*headers,*obj.glob('*.mk')]:assert p.read_bytes()==(old/p.name).read_bytes(),p.name
cpp=sorted(obj.glob('*.cpp'));changed=[p for p in cpp if p.read_bytes()!=(old/p.name).read_bytes()]
assert len(cpp)==742 and len(changed)==10
assert main_name in [p.name for p in changed]
original_main=obj/main_name;frozen=at/'frozen';frozen.mkdir(exist_ok=True)
(frozen/(main_name+'.generated')).write_bytes(original_main.read_bytes())
prior_main=m.RUN/'attempts/AT005_first_original_layer/frozen'/main_name;text=prior_main.read_text()
prefix=cfg['top']+'__DOT__';root='topp->rootp->'+prefix;raw=root+'dut__DOT__resident__DOT__'
# Single sequential layer capture slot; every global layer keeps independent coverage/counts.
begin=text.index('    std::string export_path;');end=text.index('    // Simulate until $finish',begin)
decl=r'''
    std::string export_path;
    for (int i=1;i<argc;i++) if (std::string(argv[i]).rfind("+EXPORT=",0)==0) export_path=std::string(argv[i]).substr(8);
    if(export_path.empty()) return 3;
    FILE *layer_file=nullptr,*layer_trace=nullptr;
    bool previous_clk=false,latched_fire=false; unsigned latched_addr=0,latched_global=30,active_capture=30;
    uint32_t latched_data[32]={}; unsigned captured[30]={}; bool seen[30][4096]={},capture_complete[30]={};
    unsigned long long eval_calls=0,low_samples=0,rising_samples=0;
'''
text=text[:begin]+decl+'\n'+text[end:]
begin=text.index('        ++eval_calls;');end=text.index('        { const unsigned gl =',begin)
capture=r'''
        ++eval_calls;
        const bool current_clk=@CLK@;
        if(current_clk&&!previous_clk) {
            ++rising_samples;
            if(latched_fire) {
                const unsigned gl=latched_global;
                if(gl>=30||captured[gl]>=4096||latched_addr>=4096||seen[gl][latched_addr]||@HC@[gl]!=captured[gl]+1) {std::printf("M007_LAYER_CAPTURE_ERROR actual_edge_count_or_coordinate\n");std::fflush(stdout);return 4;}
                if(active_capture!=gl) {
                    if(active_capture<30&&!capture_complete[active_capture]) {std::printf("M007_LAYER_CAPTURE_ERROR unfinished_previous_layer\n");return 4;}
                    active_capture=gl;
                    layer_file=std::fopen((export_path+".layer"+std::to_string(gl)+".f32.bin").c_str(),"wb");
                    layer_trace=std::fopen((export_path+".layer"+std::to_string(gl)+".accepted.jsonl").c_str(),"w");
                    if(!layer_file||!layer_trace)return 4;
                }
                @BANK_CHECKS@
                unsigned char bytes[128];for(unsigned lane=0;lane<32;lane++)for(unsigned octet=0;octet<4;octet++)bytes[4*lane+octet]=(latched_data[lane]>>(8*octet))&255;
                if(std::fseek(layer_file,128*latched_addr,SEEK_SET)||std::fwrite(bytes,1,128,layer_file)!=128)return 4;
                std::fprintf(layer_trace,"{\"global_layer\":%u,\"accept_seq\":%u,\"cycle\":%llu,\"address\":%u,\"data_hex_lane0_lsb\":\"",gl,captured[gl],static_cast<unsigned long long>(@CYCLE@),latched_addr);
                for(int lane=31;lane>=0;lane--)std::fprintf(layer_trace,"%08x",latched_data[lane]);std::fprintf(layer_trace,"\"}\n");
                seen[gl][latched_addr]=true;++captured[gl];
            }
        }
        if(!current_clk) {
            ++low_samples;
            latched_fire=@STATE@==54&&@GL@<30&&@RAW@vector_h_wr_valid&&@RAW@vector_h_wr_ready&&@RAW@vector_h_wr_commit&&@RAW@raw_h_wr_commit;
            if(latched_fire) {latched_global=@GL@;latched_addr=@RAW@raw_h_wr_addr;for(unsigned lane=0;lane<32;lane++)latched_data[lane]=@RAW@raw_h_wr_data[lane];}
        }
        previous_clk=current_clk;
        if(active_capture<30&&!capture_complete[active_capture]&&(@SEEN@&(1U<<active_capture))&&@HC@[active_capture]==4096) {
            const unsigned gl=active_capture;
            if(captured[gl]!=4096) {std::printf("M007_LAYER_CAPTURE_ERROR missing_actual_handshakes\n");std::fflush(stdout);return 4;}
            for(unsigned i=0;i<4096;i++)if(!seen[gl][i])return 4;
            std::fflush(layer_file);std::fflush(layer_trace);std::fclose(layer_file);std::fclose(layer_trace);layer_file=layer_trace=nullptr;capture_complete[gl]=true;
            FILE* meta=std::fopen((export_path+".layer"+std::to_string(gl)+".capture.json").c_str(),"w");if(!meta)return 4;
            std::fprintf(meta,"{\"complete\":true,\"global_layer\":%u,\"accepted_groups32\":4096,\"unique_groups32\":4096,\"bytes\":524288,\"eval_calls\":%llu,\"logical_cycle\":%llu,\"rising_samples\":%llu,\"low_samples\":%llu,\"provenance\":\"actual low-phase interface snapshot, following posedge original checker count and committed hidden bank verified; no gold reconstruction\"}\n",gl,eval_calls,static_cast<unsigned long long>(@CYCLE@),rising_samples,low_samples);std::fclose(meta);
            std::printf("M007_LAYER_CAPTURE_COMPLETE global=%u groups=4096 bytes=524288 cycle=%llu eval_calls=%llu\n",gl,static_cast<unsigned long long>(@CYCLE@),eval_calls);std::fflush(stdout);
        }
'''
checks=[]
for lane in range(32):checks.append('if('+raw+'hidden__DOT__channel_bank__BRA__'+str(lane)+'__KET____DOT__words[latched_addr]!=latched_data['+str(lane)+']) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\\n");std::fflush(stdout);return 4;}')
for k,v in {'@CLK@':root+'clk','@HC@':root+'layer_H_count','@CYCLE@':root+'cycle','@STATE@':root+'dut__DOT__state','@GL@':root+'dut__DOT__layer_index','@RAW@':raw,'@SEEN@':root+'layer_complete_seen','@BANK_CHECKS@':'\n'.join(checks)}.items():capture=capture.replace(k,v)
assert '@' not in capture;text=text[:begin]+capture+'\n'+text[end:]
phase_end=text.index('\n\n        // Read-only post-eval observation:')
extra='''
        { const unsigned gl=@GL@,st=@STATE@; if(gl>=28&&gl<30&&st==102&&last_fc2_global!=gl) {
            std::printf("M007_DECISION_FC2_ADMITTED global=%u writes=%u acks=%u closed=%u success=%u published=%u debt=%u cycle=%llu\\n",gl,@WRITES@[gl-28],@ACKS@[gl-28],@CLOSED@,@SUCCESS@,@PUBLISHED@,@DEBT@,static_cast<unsigned long long>(@CYCLE@));std::fflush(stdout);last_fc2_global=gl;
        } }
'''
for k,v in {'@GL@':root+'dut__DOT__layer_index','@STATE@':root+'dut__DOT__state','@WRITES@':root+'fc1_Awrites','@ACKS@':root+'fc1_Aacks','@CLOSED@':root+'dut__DOT__front__DOT__producer_closed','@SUCCESS@':root+'dut__DOT__front__DOT__producer_success','@PUBLISHED@':root+'dut__DOT__front__DOT__a_published','@DEBT@':root+'dut__DOT__front__DOT__a_write_debt','@CYCLE@':root+'cycle'}.items():extra=extra.replace(k,v)
text=text[:phase_end]+extra+text[phase_end:];text=text.replace('    // Simulate until $finish','    unsigned last_fc2_global=30;\n    // Simulate until $finish')
assert text.count('topp->eval();')==1 and 'contextp->threads(1);' in text
header=(obj/(top+'___024root.h')).read_text()
for name in set(re.findall(r'topp->rootp->([A-Za-z0-9_]+)',text)):assert re.search(r'\b'+name+r'\b',header),name
original_main.write_text(text);(frozen/main_name).write_text(text)
records={}
for p in (base/'cxx_units').glob('*.json'):
 z=json.loads(p.read_text())
 if z.get('kind')=='compile' and z.get('state')=='COMPLETE' and z.get('exit_code')==0:
  for src in z.get('source_arguments',[]):
   if Path(src).suffix=='.cpp':assert Path(src).name not in records;records[Path(src).name]=(p,z)
assert all(p.name in records for p in cpp)
receipt=json.loads((base/'receipt_build.json').read_text());assert receipt['verdict']=='PASS'
object_ids={Path(x['path']).name:x for x in receipt['completed_objects']}
for p in cpp:
 op=old/(p.stem+'.o');assert m.sha(op)==object_ids[op.name]['sha256'],op
# Actual make dependencies plus generated headers are unchanged; use the exact existing PCH bytes/cwd.
deps={}
for p in cpp:
 dp=old/(p.stem+'.d');assert dp.is_file();items=dp.read_text().replace('\\\n',' ').split(':',1)[1].split();deps[p.name]=items
 for item in items:
  q=Path(item)
  if q.suffix=='.h' and not q.is_absolute():assert (old/q).read_bytes()==(obj/q).read_bytes(),q
runtime_manifest=json.loads((fixed/'source_manifest.json').read_text())
runtime_header_ids=[x for x in runtime_manifest['sources_and_inputs'] if str(m.VROOT/'include') in x['path'] and x['path'].endswith('.h')]
for x in runtime_header_ids:assert m.sha(Path(x['path']))==x['sha256'],x['path']
for p in old.glob('*pch*'):assert p.is_file()
commands=[]
for p in changed:
 record_path,z=records[p.name];argv=list(z['argv'][1:]);argv[argv.index(z['source_arguments'][0])]=str(p);argv[argv.index('-o')+1]=str(obj/(p.stem+'.o'))
 assert '-ffast-math' not in argv and ('-O2' in argv or '-O1' in argv)
 commands.append([sys.executable,str(h/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*argv])
overlay=json.loads((fixed/'overlay_commands.json').read_text());archive=old/(top+'__ALL.a');newarchive=obj/archive.name
link=overlay['link'];link=[str(at/'cxx_units') if q==str(fixed/'cxx_units') else str(newarchive) if q==str(fixed/'work/obj'/archive.name) else str(obj/top) if q==str(fixed/'work/obj'/top) else q for q in link]
assert str(newarchive) in link
driver=at/'incremental_build_commands.py'
driver.write_text('import concurrent.futures,shutil,subprocess\ncommands='+repr(commands)+'\ncwd='+repr(str(old))+'\nwith concurrent.futures.ThreadPoolExecutor(max_workers=4) as ex:\n list(ex.map(lambda cmd: subprocess.run(cmd,cwd=cwd,check=True),commands))\nshutil.copy2('+repr(str(archive))+','+repr(str(newarchive))+')\nsubprocess.run('+repr(['/usr/bin/ar','-r',str(newarchive),*[str(obj/(p.stem+'.o')) for p in changed]])+',cwd=cwd,check=True)\nsubprocess.run('+repr(link)+',cwd=cwd,check=True)\n')
proof={'status':'VERIFIED_COMPATIBLE_INCREMENTAL_REUSE','generated_headers':[m.identify(p) for p in headers],'make_fragments':[m.identify(p) for p in obj.glob('*.mk')],'total_cpp':742,'changed_cpp':[m.identify(p) for p in changed],'reused_cpp_count':732,'reused_objects':[object_ids[p.stem+'.o'] for p in cpp if p not in changed],'successful_original_compile_records':[m.identify(records[p.name][0]) for p in cpp],'actual_make_dependencies':deps,'PCH_and_same_compile_cwd':[m.identify(p) for p in old.glob('*pch*')],'compile_commands':commands,'runtime_header_identities':runtime_header_ids,'same_compiler_and_flags_except_source_output_paths':True,'runtime_overlay':m.identify(fixed/'overlay_commands.json'),'actual_baseline_archive':m.identify(archive),'main':m.identify(original_main),'prior_capture_main':m.identify(prior_main),'no_added_eval_or_DUT_writes':True,'per_global_layer_capture':True,'intended_kind6_layer':28,'system_headers_not_separately_retrospectively_hashed':True}
m.dump(at/'incremental_reuse_proof.json',proof)
manifest_paths=[at/'source_manifest.json',at/'config.json',at/'incremental_reuse_proof.json',Path(__file__),driver,*headers,*changed,*[old/(p.stem+'.o') for p in cpp if p not in changed],archive,*old.glob('*pch*'),fixed/'overlay_commands.json',fixed/'work/obj/verilated_timing.o',h/'runtime_fixed_batch_v1/verilated_timing.cpp',old/'verilated.o',old/'verilated_threads.o']
manifest_paths.extend(Path(x['path']) for x in runtime_header_ids)
m.dump(at/'incremental_execution_manifest.json',{'sources_and_inputs':[m.identify(p) for p in dict.fromkeys(manifest_paths)],'actual_model':'UNKNOWN','actual_effort':'UNKNOWN'})
if m.budget()['static']+120>1200:raise SystemExit('static launch budget')
guard=Path(cfg['guard_path']);out=at/'guard_build';assert not out.exists()
argv=[sys.executable,str(guard),'--out',str(out),'--cwd',str(at/'work'),'--rss-gib','24','--timeout-seconds','120','--semantic-stall-seconds','120','--phase','static','--artifact-progress-root',str(at/'work'),'--',sys.executable,str(driver)]
m.dump(at/'command_build.json',{'category':'static','argv':argv,'budget_before':m.budget(),'legal_incremental_proof':m.identify(at/'incremental_reuse_proof.json')})
env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 print('WAITING_PROJECT_HEAVY_LOCK',flush=True);fcntl.flock(lock,fcntl.LOCK_EX);print('ACQUIRED_PROJECT_HEAVY_LOCK',flush=True)
 with (at/'build_wrapper.log').open('w') as f:rc=subprocess.call(argv,cwd=at/'work',env=env,stdout=f,stderr=subprocess.STDOUT)
g=json.loads((out/'guard_result.json').read_text());exe=obj/top;ok=rc==0 and not g['trigger'] and exe.is_file()
m.dump(at/'receipt_build.json',{'category':'static','verdict':'PASS' if ok else 'COST_STOP' if g['trigger'] else 'FAIL','guard':g,'guard_wrapper_exit':rc,'executable':m.identify(exe) if exe.is_file() else None,'reused_generated_objects':732,'recompiled_generated_objects':10,'unchanged_PCH_and_all_generated_headers':True,'runtime_identity':cfg['runtime_identity']})
print(json.dumps({'verdict':'PASS' if ok else 'FAIL','elapsed_seconds':g['elapsed_seconds'],'recompiled':10,'reused':732}),flush=True);raise SystemExit(0 if ok else 1)
