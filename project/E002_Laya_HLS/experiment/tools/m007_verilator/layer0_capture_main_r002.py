#!/usr/bin/env python3
"""Derive and compile only the observer main; preserve AT004 baseline executable."""
import fcntl,importlib.util,json,os,subprocess,sys
from pathlib import Path
h=Path(__file__).resolve().parent;s=importlib.util.spec_from_file_location('m',h/'fullgraph_run_r002.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);r=m.RUN;base=r/'attempts/AT004_fullgraph_fixedbatch_pilot';at=r/'attempts/AT005_first_original_layer';obj=at/'work/obj';obj.mkdir(parents=True,exist_ok=False);cfg=json.loads((base/'config.json').read_text());cfg['plusargs']=[f'+EXPORT={at}/work/actual_fullgraph' if v.startswith('+EXPORT=') else v for v in cfg['plusargs']];m.dump(at/'config.json',cfg)
main_name='V'+cfg['top']+'__main.cpp';text=(base/'work/obj'/main_name).read_text();prefix=cfg['top']+'__DOT__';raw=prefix+'dut__DOT__resident__DOT__';clock=prefix+'clk';state=prefix+'dut__DOT__state';gl=prefix+'dut__DOT__layer_index';hc=prefix+'layer_H_count';cy=prefix+'cycle';body=r'''
    std::string export_path;
    for (int i=1;i<argc;i++) if (std::string(argv[i]).rfind("+EXPORT=",0)==0) export_path=std::string(argv[i]).substr(8);
    if(export_path.empty()) return 3;
    FILE* layer_file=std::fopen((export_path+".layer0.f32.bin").c_str(),"wb");
    FILE* layer_trace=std::fopen((export_path+".layer0.accepted.jsonl").c_str(),"w");
    if(!layer_file||!layer_trace) return 3;
    bool previous_clk=false,latched_fire=false,capture_complete=false; unsigned latched_addr=0,captured=0; uint32_t latched_data[32]={}; bool seen[4096]={};
    unsigned long long eval_calls=0,low_samples=0,rising_samples=0;
'''
text=text.replace('#include <cstdio>','#include <cstdio>\n#include <string>\n#include <cstdint>')
text=text.replace('    // Simulate until $finish',body+'\n    // Simulate until $finish')
cap='''
        ++eval_calls;
        const bool current_clk=topp->rootp->@CLK@;
        if(current_clk&&!previous_clk) {
            ++rising_samples;
            if(latched_fire) {
                if(captured>=4096||latched_addr>=4096||seen[latched_addr]||topp->rootp->@HC@[0]!=captured+1) { std::printf("M007_LAYER0_CAPTURE_ERROR actual_edge_count_or_coordinate\\n"); std::fflush(stdout); return 4; }
                @BANK_CHECKS@
                unsigned char bytes[128]; for(unsigned lane=0;lane<32;lane++)for(unsigned octet=0;octet<4;octet++)bytes[4*lane+octet]=(latched_data[lane]>>(8*octet))&255;
                if(std::fseek(layer_file,128*latched_addr,SEEK_SET)||std::fwrite(bytes,1,128,layer_file)!=128) return 4;
                std::fprintf(layer_trace,"{\\"accept_seq\\":%u,\\"cycle\\":%llu,\\"address\\":%u,\\"data_hex_lane0_lsb\\":\\"",captured,static_cast<unsigned long long>(topp->rootp->@CYCLE@),latched_addr);
                for(int lane=31;lane>=0;lane--)std::fprintf(layer_trace,"%08x",latched_data[lane]); std::fprintf(layer_trace,"\\"}\\n");
                seen[latched_addr]=true;++captured;
            }
        }
        if(!current_clk) {
            ++low_samples;
            latched_fire=topp->rootp->@STATE@==54&&topp->rootp->@GL@==0&&topp->rootp->@RAW@vector_h_wr_valid&&topp->rootp->@RAW@vector_h_wr_ready&&topp->rootp->@RAW@vector_h_wr_commit&&topp->rootp->@RAW@raw_h_wr_commit;
            if(latched_fire) { latched_addr=topp->rootp->@RAW@raw_h_wr_addr;for(unsigned lane=0;lane<32;lane++)latched_data[lane]=topp->rootp->@RAW@raw_h_wr_data[lane]; }
        }
        previous_clk=current_clk;
        if(!capture_complete&&topp->rootp->@LAYERS@==1&&(topp->rootp->@SEEN@&1)&&topp->rootp->@HC@[0]==4096) {
            if(captured!=4096) {std::printf("M007_LAYER0_CAPTURE_ERROR missing_actual_handshakes\\n");std::fflush(stdout);return 4;}
            for(unsigned i=0;i<4096;i++)if(!seen[i])return 4;
            std::fflush(layer_file);std::fflush(layer_trace);std::fclose(layer_file);std::fclose(layer_trace);capture_complete=true;
            FILE* meta=std::fopen((export_path+".layer0.capture.json").c_str(),"w");if(!meta)return 4;
            std::fprintf(meta,"{\\"complete\\":true,\\"accepted_groups32\\":4096,\\"unique_groups32\\":4096,\\"bytes\\":524288,\\"eval_calls\\":%llu,\\"logical_cycle\\":%llu,\\"rising_samples\\":%llu,\\"low_samples\\":%llu,\\"provenance\\":\\"actual low-phase interface snapshot, following posedge original checker count and committed hidden bank verified; no gold reconstruction\\"}\\n",eval_calls,static_cast<unsigned long long>(topp->rootp->@CYCLE@),rising_samples,low_samples);std::fclose(meta);
            std::printf("M007_LAYER0_CAPTURE_COMPLETE groups=4096 bytes=524288 cycle=%llu eval_calls=%llu\\n",static_cast<unsigned long long>(topp->rootp->@CYCLE@),eval_calls);std::fflush(stdout);
        }
'''
checks=[]
for lane in range(32):
 bank=raw+'hidden__DOT__channel_bank__BRA__'+str(lane)+'__KET____DOT__words';checks.append('if(topp->rootp->'+bank+'[latched_addr]!=latched_data['+str(lane)+']) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\\n");std::fflush(stdout);return 4;}')
for k,v in {'@CLK@':clock,'@HC@':hc,'@CYCLE@':cy,'@STATE@':state,'@GL@':gl,'@RAW@':raw,'@LAYERS@':prefix+'layers_completed','@SEEN@':prefix+'layer_complete_seen','@BANK_CHECKS@':'\n'.join(checks)}.items():cap=cap.replace(k,v)
# eval count advances immediately after each original eval; no additional eval or signal write.
text=text.replace('        topp->eval();','        topp->eval();\n'+cap);main=at/'frozen'/main_name;main.parent.mkdir();main.write_text(text)
prior_manifest=json.loads((base/'source_manifest.json').read_text());paths=[Path(v['path']) for v in prior_manifest['sources_and_inputs']]
for v in prior_manifest['sources_and_inputs']:
 if m.sha(Path(v['path']))!=v['sha256']:raise SystemExit('frozen baseline changed')
records=[]
for q in (base/'cxx_units').glob('*.json'):
 z=json.loads(q.read_text())
 if any(Path(v).name==main_name for v in z.get('source_arguments',[])):records.append((q,z))
assert len(records)==1 and records[0][1]['state']=='COMPLETE';q,z=records[0];args=list(z['argv'][1:]);src=z['source_arguments'][0];args[args.index(src)]=str(main);args[args.index('-o')+1]=str(obj/(Path(main_name).stem+'.o'));compile=[sys.executable,str(h/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*args]
link0=json.loads((base/'overlay_commands.json').read_text())['link'];args=list(link0[link0.index('--')+1:]);oldarchive=next(Path(v) for v in args if v.endswith('.a'));archive=obj/oldarchive.name;args[args.index(str(oldarchive))]=str(archive);args[args.index('-o')+1]=str(obj/('V'+cfg['top']));link=[sys.executable,str(h/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*args];commands=[compile,['/usr/bin/ar','-r',str(archive),str(obj/(Path(main_name).stem+'.o'))],link];driver=at/'main_build_commands.py';driver.write_text('import shutil,subprocess\nshutil.copy2('+repr(str(oldarchive))+','+repr(str(archive))+')\n'+'\n'.join('subprocess.run('+repr(cmd)+',cwd='+repr(z['cwd'])+',check=True)' for cmd in commands)+'\n')
paths += [base/'source_manifest.json',base/'receipt_build.json',oldarchive,main,q,driver,Path(__file__),at/'config.json'];m.dump(at/'source_manifest.json',{'sources_and_inputs':[m.identify(p) for p in dict.fromkeys(paths)],'baseline_executable_unchanged':True,'mathematical_model_objects_unchanged':True,'only_main_recompiled':True,'no_added_eval_calls':text.count('topp->eval();')==1,'no_DUT_signal_writes':True,'capture_actual_interface_and_check_actual_bank':True,'main_timing_overhead_separately_measured':False})
for f in (base/'work').glob('*.dat'):(at/'work'/f.name).symlink_to(f.resolve())
guard=Path(cfg['guard_path']);out=at/'guard_build';cmd=[sys.executable,str(guard),'--out',str(out),'--cwd',str(at/'work'),'--rss-gib','24','--timeout-seconds','30','--semantic-stall-seconds','120','--phase','static','--artifact-progress-root',str(at/'work'),'--',sys.executable,str(driver)];env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 with (at/'build_wrapper.log').open('w') as stream:rc=subprocess.call(cmd,cwd=at/'work',env=env,stdout=stream,stderr=subprocess.STDOUT)
g=json.loads((out/'guard_result.json').read_text());exe=obj/('V'+cfg['top']);ok=rc==0 and not g['trigger'] and exe.exists();m.dump(at/'receipt_build.json',{'category':'static','verdict':'PASS' if ok else 'FAIL','guard':g,'guard_wrapper_exit':rc,'executable':m.identify(exe) if exe.exists() else None,'source_manifest':m.identify(at/'source_manifest.json'),'only_main_recompiled':True});print(json.dumps({'verdict':'PASS' if ok else 'FAIL','elapsed_seconds':g['elapsed_seconds']}),flush=True);raise SystemExit(0 if ok else 1)
