#!/usr/bin/env python3
import fcntl,importlib.util,json,os,subprocess,sys
from pathlib import Path
h=Path(__file__).resolve().parent;s=importlib.util.spec_from_file_location('m',h/'fullgraph_run_r002.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);r=m.RUN;base=r/'attempts/AT005_first_original_layer';at=r/'attempts/AT009_pc_profile';obj=at/'work/obj';obj.mkdir(parents=True,exist_ok=False);cfg=json.loads((base/'config.json').read_text());cfg['plusargs']=[f'+EXPORT={at}/work/actual_fullgraph' if z.startswith('+EXPORT=') else z for z in cfg['plusargs']];m.dump(at/'config.json',cfg);name='V'+cfg['top']+'__main.cpp';main0=(base/'frozen'/name).read_text();text=main0.replace('#include <cstdint>','#include <cstdint>\n#include <csignal>\n#include <sys/time.h>\n#include <sys/resource.h>\n#include <ucontext.h>\n#include <ctime>')
global_code=r'''
static volatile sig_atomic_t pc_count=0,pc_dropped=0,pc_done=0;
static volatile sig_atomic_t pc_low[16384],pc_high[16384];
static void sample_pc(int,siginfo_t*,void* context) {
    const auto pc=static_cast<unsigned long long>(static_cast<ucontext_t*>(context)->uc_mcontext.gregs[REG_RIP]);
    const sig_atomic_t index=pc_count;
    if(index<16384) {pc_low[index]=static_cast<sig_atomic_t>(pc&0xffffffffULL);pc_high[index]=static_cast<sig_atomic_t>(pc>>32);pc_count=index+1;if(pc_count>=1455)pc_done=1;} else {++pc_dropped;pc_done=1;}
}
'''
text=text.replace('int main(int argc',global_code+'\nint main(int argc')
setup=r'''
    struct sigaction pc_action{},old_pc_action{};pc_action.sa_sigaction=sample_pc;sigemptyset(&pc_action.sa_mask);pc_action.sa_flags=SA_SIGINFO|SA_RESTART;
    if(sigaction(SIGPROF,&pc_action,&old_pc_action))return 5;
    struct itimerval old_pc_timer{};if(getitimer(ITIMER_PROF,&old_pc_timer))return 5;
    bool pc_started=false;struct rusage pc_usage_start{};struct timespec pc_wall_start{};
    FILE* map_in=std::fopen("/proc/self/maps","r");FILE* map_out=std::fopen((export_path+".pc.maps").c_str(),"w");if(!map_in||!map_out)return 5;char map_buffer[4096];while(std::fgets(map_buffer,sizeof(map_buffer),map_in))std::fputs(map_buffer,map_out);std::fclose(map_in);std::fclose(map_out);
'''
text=text.replace('    // Simulate until $finish',setup+'\n    // Simulate until $finish');text=text.replace('while (!contextp->gotFinish())','while (!contextp->gotFinish() && !pc_done)')
trigger='''
        if(!pc_started&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__state==7&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__l_head_completed==1) {
            pc_started=true;getrusage(RUSAGE_SELF,&pc_usage_start);clock_gettime(CLOCK_MONOTONIC,&pc_wall_start);
            struct itimerval timer{};timer.it_interval.tv_usec=10309;timer.it_value=timer.it_interval;if(setitimer(ITIMER_PROF,&timer,nullptr))return 5;
        }
'''
text=text.replace('        topp->eval();','        topp->eval();\n'+trigger)
finish=r'''
    sigset_t pc_mask,old_pc_mask;sigemptyset(&pc_mask);sigaddset(&pc_mask,SIGPROF);sigprocmask(SIG_BLOCK,&pc_mask,&old_pc_mask);struct itimerval disabled{};setitimer(ITIMER_PROF,&disabled,nullptr);struct timespec zero{};while(sigtimedwait(&pc_mask,nullptr,&zero)>=0){};
    struct rusage pc_usage_end{};struct timespec pc_wall_end{};getrusage(RUSAGE_SELF,&pc_usage_end);clock_gettime(CLOCK_MONOTONIC,&pc_wall_end);
    FILE* pcs=std::fopen((export_path+".pc.samples").c_str(),"w");if(!pcs)return 5;for(sig_atomic_t i=0;i<pc_count;i++)std::fprintf(pcs,"%08x%08x\n",static_cast<unsigned>(pc_high[i]),static_cast<unsigned>(pc_low[i]));std::fclose(pcs);
    double window_cpu=(pc_usage_end.ru_utime.tv_sec-pc_usage_start.ru_utime.tv_sec)+(pc_usage_end.ru_utime.tv_usec-pc_usage_start.ru_utime.tv_usec)*1e-6+(pc_usage_end.ru_stime.tv_sec-pc_usage_start.ru_stime.tv_sec)+(pc_usage_end.ru_stime.tv_usec-pc_usage_start.ru_stime.tv_usec)*1e-6;
    double total_cpu=pc_usage_end.ru_utime.tv_sec+pc_usage_end.ru_utime.tv_usec*1e-6+pc_usage_end.ru_stime.tv_sec+pc_usage_end.ru_stime.tv_usec*1e-6;
    double window_wall=(pc_wall_end.tv_sec-pc_wall_start.tv_sec)+(pc_wall_end.tv_nsec-pc_wall_start.tv_nsec)*1e-9;
    FILE* meta=std::fopen((export_path+".pc.json").c_str(),"w");if(!meta)return 5;std::fprintf(meta,"{\"profile_started\":%s,\"samples\":%d,\"dropped\":%d,\"interval_usec\":10309,\"target_samples\":1455,\"window_cpu_seconds\":%.9f,\"window_wall_seconds\":%.9f,\"total_child_cpu_seconds\":%.9f,\"logical_cycle\":%llu,\"eval_calls\":%llu,\"diagnostic_only\":true,\"handler_only_fixed_array_RIP_store\":true,\"handler_no_allocation_print_or_RTL_access\":true}\n",pc_started?"true":"false",int(pc_count),int(pc_dropped),window_cpu,window_wall,total_cpu,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),eval_calls);std::fclose(meta);
    sigaction(SIGPROF,&old_pc_action,nullptr);setitimer(ITIMER_PROF,&old_pc_timer,nullptr);sigprocmask(SIG_SETMASK,&old_pc_mask,nullptr);
    std::printf("M007_PC_PROFILE_COMPLETE samples=%d dropped=%d cycle=%llu\n",int(pc_count),int(pc_dropped),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle));std::fflush(stdout);
'''
text=text.replace('    // Final model cleanup',finish+'\n    // Final model cleanup');assert text.count('topp->eval();')==main0.count('topp->eval();')==1
main=at/'frozen'/name;main.parent.mkdir();main.write_text(text);records=[]
for q in (base/'cxx_units').glob('*.json'):
 z=json.loads(q.read_text());z['record_path']=str(q);records.append(z)
compile_record=next(z for z in records if z['kind']=='compile');link_record=next(z for z in records if z['kind']=='link');args=list(compile_record['argv'][1:]);src=compile_record['source_arguments'][0];args[args.index(src)]=str(main);args[args.index('-o')+1]=str(obj/(Path(name).stem+'.o'));compile=[sys.executable,str(h/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*args];args=list(link_record['argv'][1:]);oldarchive=next(Path(v) for v in args if v.endswith('.a'));archive=obj/oldarchive.name;args[args.index(str(oldarchive))]=str(archive);args[args.index('-o')+1]=str(obj/('V'+cfg['top']));link=[sys.executable,str(h/'cxx_record.py'),'--records',str(at/'cxx_units'),'--',*args];commands=[compile,['/usr/bin/ar','-r',str(archive),str(obj/(Path(name).stem+'.o'))],link];driver=at/'build_commands.py';driver.write_text('import shutil,subprocess\nshutil.copy2('+repr(str(oldarchive))+','+repr(str(archive))+')\n'+'\n'.join('subprocess.run('+repr(cmd)+',cwd='+repr(compile_record['cwd'])+',check=True)' for cmd in commands)+'\n');paths=[Path(v['path']) for v in json.loads((base/'source_manifest.json').read_text())['sources_and_inputs']]+[oldarchive,base/'receipt_build.json',main,driver,Path(__file__),at/'config.json'];m.dump(at/'source_manifest.json',{'sources_and_inputs':[m.identify(p) for p in dict.fromkeys(paths)],'baseline_main_only_profile_successor':True,'not_empty_dispatch_version':True,'mathematical_model_and_runtime_unchanged':True,'sampling_starts_after_real_head0_success':True,'handler_only_PC_into_fixed_sig_atomic_arrays':True,'not_unperturbed_speed_measurement':True,'no_DUT_signal_writes_or_extra_eval_calls':True})
for q in (base/'work').glob('*.dat'):(at/'work'/q.name).symlink_to(q.resolve())
guard=Path(cfg['guard_path']);out=at/'guard_build';cmd=[sys.executable,str(guard),'--out',str(out),'--cwd',str(at/'work'),'--rss-gib','24','--timeout-seconds','120','--semantic-stall-seconds','120','--phase','static','--artifact-progress-root',str(at/'work'),'--',sys.executable,str(driver)];env=os.environ.copy();env['VERILATOR_ROOT']=str(m.VROOT);env['PYTHONPATH']=str(m.ROOT/'project/E002_Laya_HLS/experiment/tools')
with (m.ROOT/'.research-agent/m007_heavy.lock').open('a+') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 with (at/'build_wrapper.log').open('w') as stream:rc=subprocess.call(cmd,cwd=at/'work',env=env,stdout=stream,stderr=subprocess.STDOUT)
g=json.loads((out/'guard_result.json').read_text());exe=obj/('V'+cfg['top']);ok=rc==0 and not g['trigger'] and exe.exists();m.dump(at/'receipt_build.json',{'category':'static','verdict':'PASS' if ok else 'FAIL','guard':g,'guard_wrapper_exit':rc,'executable':m.identify(exe) if exe.exists() else None,'only_main_recompiled':True,'diagnostic_PC_sampling_not_speed_benchmark':True});print(json.dumps({'verdict':'PASS' if ok else 'FAIL','elapsed_seconds':g['elapsed_seconds']}),flush=True);raise SystemExit(0 if ok else 1)
