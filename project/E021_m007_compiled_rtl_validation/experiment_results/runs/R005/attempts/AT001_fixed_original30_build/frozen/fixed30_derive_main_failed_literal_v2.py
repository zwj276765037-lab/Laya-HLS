#!/usr/bin/env python3
"""D37: preserve generic H observer and capture actual finalLN/type at clock edges."""
import hashlib,json,math,re,shutil,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005'
AT=RUN/'attempts/AT001_fixed_original30_build';OBJ=AT/'work/obj'
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
start=time.monotonic();cfg=json.loads((AT/'config.json').read_text());top='V'+cfg['top'];main=OBJ/(top+'__main.cpp');assert not (AT/'generated_build_inputs.json').exists()
assert json.loads((AT/'receipt_translate.json').read_text())['verdict']=='PASS'
prior=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002/attempts/AT010_kind6_public_abi/frozen'/main.name
text=prior.read_text();assert text.count('topp->eval();')==1 and 'contextp->threads(1);' in text
(AT/'frozen'/(main.name+'.generated')).write_bytes(main.read_bytes())
declarations='''
    FILE *endpoint_file[2]={},*endpoint_trace[2]={};
    unsigned endpoint_count[2]={}; bool endpoint_seen[2][4096]={};
    int latched_endpoint=-1; unsigned endpoint_address=0; uint32_t endpoint_data[32]={};
    const char* endpoint_label[2]={"finalLN","type"};
    const char* endpoint_suffix[2]={"final_norm","type_add"};
'''
text=text.replace('    unsigned last_fc2_global=30;',declarations+'\n    unsigned last_fc2_global=30;',1)
r='topp->rootp->'+cfg['top']+'__DOT__'
capture=r'''
            // Capture only the payload accepted at the following physical posedge.
            if(latched_endpoint>=0) {
                const unsigned e=static_cast<unsigned>(latched_endpoint),a=endpoint_address;
                const unsigned actual_count=e==0?@ROOT@final_norm_count:@ROOT@type_count;
                if(e>=2||a>=4096||endpoint_seen[e][a]||endpoint_count[e]>=4096||actual_count!=endpoint_count[e]+1) {std::printf("M007_ENDPOINT_CAPTURE_ERROR actual_edge_count_or_coordinate\n");std::fflush(stdout);return 4;}
                if(!endpoint_file[e]) {
                    endpoint_file[e]=std::fopen((export_path+"."+endpoint_suffix[e]+".f32.bin").c_str(),"wb");
                    endpoint_trace[e]=std::fopen((export_path+"."+endpoint_suffix[e]+".accepted.jsonl").c_str(),"w");
                    if(!endpoint_file[e]||!endpoint_trace[e])return 4;
                }
                unsigned char bytes[128];for(unsigned lane=0;lane<32;lane++)for(unsigned octet=0;octet<4;octet++)bytes[4*lane+octet]=(endpoint_data[lane]>>(8*octet))&255;
                if(std::fseek(endpoint_file[e],128*a,SEEK_SET)||std::fwrite(bytes,1,128,endpoint_file[e])!=128)return 4;
                std::fprintf(endpoint_trace[e],"{\"endpoint\":\"%s\",\"accept_seq\":%u,\"cycle\":%llu,\"address\":%u,\"data_hex_lane0_lsb\":\"",endpoint_label[e],endpoint_count[e],static_cast<unsigned long long>(@ROOT@cycle),a);
                for(int lane=31;lane>=0;lane--)std::fprintf(endpoint_trace[e],"%08x",endpoint_data[lane]);std::fprintf(endpoint_trace[e],"\"}\n");
                endpoint_seen[e][a]=true;++endpoint_count[e];
                if(endpoint_count[e]==4096) {
                    for(unsigned j=0;j<4096;j++)if(!endpoint_seen[e][j])return 4;
                    std::fflush(endpoint_file[e]);std::fflush(endpoint_trace[e]);std::fclose(endpoint_file[e]);std::fclose(endpoint_trace[e]);endpoint_file[e]=endpoint_trace[e]=nullptr;
                    std::printf("M007_ENDPOINT_CAPTURE_COMPLETE endpoint=%s groups=4096 bytes=524288 cycle=%llu\n",endpoint_label[e],static_cast<unsigned long long>(@ROOT@cycle));std::fflush(stdout);
                }
            }
'''.replace('@ROOT@',r)
banks=[]
for lane in range(32):
 qbase=r+'dut__DOT__resident__DOT__resources__DOT__qkv__DOT__plane_store__BRA__0__KET____DOT__channel_bank__BRA__'
 lo=qbase+str(lane)+'__KET____DOT__words[qaddr]';hi=qbase+str(lane+32)+'__KET____DOT__words[qaddr]'
 hidden=r+'dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__'+str(lane)+'__KET____DOT__words[a]'
 banks.append('                if((e==0?((a&1)?'+hi+':'+lo+'):'+hidden+')!=endpoint_data['+str(lane)+']) {std::printf("M007_ENDPOINT_CAPTURE_ERROR committed_bank_payload\\n");std::fflush(stdout);return 4;}')
capture=capture.replace('                if(!endpoint_file[e]) {','                const unsigned qaddr=128*((a>>1)&15)+(a>>5);\n'+'\n'.join(banks)+'\n                if(!endpoint_file[e]) {')
text=text.replace('            ++rising_samples;','            ++rising_samples;\n'+capture,1)
low=r'''
            latched_endpoint=-1;
            if(@ROOT@dut__DOT__state==90&&@ROOT@dut__DOT__resident__DOT__p_q_wr_commit) {
                latched_endpoint=0;endpoint_address=@ROOT@dut__DOT__resident__DOT__p_q_wr_addr;
                for(unsigned lane=0;lane<32;lane++)endpoint_data[lane]=@ROOT@dut__DOT__resident__DOT__ln_out_data[lane];
            } else if(@ROOT@dut__DOT__state==95&&@ROOT@dut__DOT__resident__DOT__vector_h_wr_valid&&@ROOT@dut__DOT__resident__DOT__vector_h_wr_ready&&@ROOT@dut__DOT__resident__DOT__vector_h_wr_commit) {
                latched_endpoint=1;endpoint_address=@ROOT@dut__DOT__resident__DOT__raw_h_wr_addr;
                for(unsigned lane=0;lane<32;lane++)endpoint_data[lane]=@ROOT@dut__DOT__resident__DOT__raw_h_wr_data[lane];
            }
'''.replace('@ROOT@',r)
text=text.replace('            ++low_samples;','            ++low_samples;\n'+low,1)
assert text.count('topp->eval();')==1 and text.count('contextp->threads(1);')==1
header=(OBJ/(top+'___024root.h')).read_text()
for name in set(re.findall(r'topp->rootp->([A-Za-z0-9_]+)',text)):assert re.search(r'\b'+name+r'\b',header),name
main.write_text(text);(AT/'frozen'/main.name).write_text(text)
cpp=sorted(OBJ.glob('*.cpp'));old=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004/attempts/AT004_suffix_fixed/work/obj';oldcpp=list(old.glob('*.cpp'))
scale={'actual_cpp_count':len(cpp),'actual_cpp_bytes':sum(p.stat().st_size for p in cpp),'actual_max_cpp_bytes':max(p.stat().st_size for p in cpp),'baseline_cpp_count':741,'baseline_cpp_bytes':268284937,'baseline_max_cpp_bytes':max(p.stat().st_size for p in oldcpp),'allowed_factor':1.15}
scale['verdict']='PASS' if scale['actual_cpp_count']<=math.ceil(741*1.15) and scale['actual_cpp_bytes']<=268284937*1.15 and scale['actual_max_cpp_bytes']<=scale['baseline_max_cpp_bytes']*1.15 else 'FAIL'
dump(AT/'generated_scale_gate.json',scale);assert scale['verdict']=='PASS',scale
generated='\n'.join(p.read_text(errors='replace') for p in cpp)
assert 'HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=7 layers=30 matrix=120 outputs=544 actual_tail_commit=1' in generated
assert 'HARDWARE_AGENT_SIM_PASS M007_SEGMENTED_SUFFIX' not in generated
assert 'suffix entry without real setup/H/quiet qualification' not in generated
assert 'once-BEGIN original30 graph coverage and real tail commit' in generated
assert '+POST_ENCODER27_H=' not in ' '.join(cfg['plusargs']) and cfg['verilator_flags'][-1]=='-GVERIFY_POST_ENCODER27_H=0'
dump(AT/'actual_full_parameter_expansion.json',{'verdict':'PASS','requested_parameter':0,'full30_PASS_marker_generated':True,'original_full30_coverage_checker_generated':True,'suffix_PASS_marker_generated':False,'suffix_entry_state_mutation_elaborated':False,'runtime_saved_H_plusarg':False,'full30_once_BEGIN_inputs_preserved':True})
fixed=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002/attempts/AT004_fullgraph_fixedbatch_pilot';receipt=json.loads((fixed/'receipt_build.json').read_text());rt=receipt['new_runtime_object'];src=Path(rt['path']);assert receipt['verdict']=='PASS' and identify(src)==rt
runtime=OBJ/'verilated_timing.o';shutil.copy2(src,runtime);assert identify(runtime)['sha256']==rt['sha256']
dump(AT/'fixed_runtime_object_reuse.json',{'status':'VERIFIED_REUSE_OF_ACTUAL_PASS','original_build_receipt':identify(fixed/'receipt_build.json'),'original_runtime_object':rt,'copied_runtime_object':identify(runtime),'actual_runtime_source':identify(HERE/'runtime_fixed_batch_v1/verilated_timing.cpp'),'make_excludes_recompiling_verilated_timing_object':True,'same_VROOT_headers_and_flags_as_baseline_config':cfg['runtime_identity']})
headers=[p.name for p in OBJ.glob('*.h')];different_headers=[name for name in headers if not (old/name).exists() or identify(OBJ/name)['sha256']!=identify(old/name)['sha256']]
dump(AT/'fresh_model_build_policy.json',{'model_objects_reused':0,'all_generated_model_objects_fresh':True,'reason':'parameter0 full graph new elaboration; no generated object reuse attempted','old_suffix_differing_generated_headers':different_headers,'only_verified_fixed_runtime_reused':True})
paths=[*cpp,*OBJ.glob('*.h'),*OBJ.glob('*.mk'),runtime,Path(__file__),prior]
dump(AT/'generated_build_inputs.json',{'sources_and_inputs':[identify(p) for p in paths],'read_only_observer_no_DUT_writes':True,'single_eval_per_iteration':True,'main_original_generic_all30_capture':identify(prior),'new_endpoint_capture':'actual low-phase finalLN/state90 p_q commit and type/state95 vector H commit; following posedge original count checked;4096 unique trace each','fixed_parameter':0,'all_model_objects_fresh':True})
dump(AT/'receipt_derive_main.json',{'category':'static','verdict':'PASS','elapsed_seconds':time.monotonic()-start,'stage':'derive_read_only_full30_and_finalLN_type_capture_main','guarded':False})
print(json.dumps({'scale':scale,'different_headers':different_headers,'actual_parameter_expansion':'PASS'}),flush=True)
