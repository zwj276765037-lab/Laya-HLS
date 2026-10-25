#!/usr/bin/env python3
"""Read only low-phase LN command values through natural provider lease/command delay."""
import argparse,hashlib,json,re,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent;RUN=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004'
def identify(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
p=argparse.ArgumentParser();p.add_argument('attempt');a=p.parse_args();started=time.monotonic();at=RUN/'attempts'/a.attempt;obj=at/'work/obj';cfg=json.loads((at/'config.json').read_text());top='V'+cfg['top'];main=obj/(top+'__main.cpp');assert not (at/'generated_build_inputs.json').exists()
subprocess.run([sys.executable,str(HERE/'suffix_derive_main_r004.py'),a.attempt],cwd=ROOT,check=True)
text=main.read_text();root='topp->rootp->'+cfg['top']+'__DOT__';r=root+'dut__DOT__resident__DOT__'
decl='''    bool ln_observe_active=false,ln_held_pending=false; unsigned ln_expected_gamma=0,ln_expected_epoch=0,ln_held_gamma=0,ln_held_epoch=0,ln_wait_cycles=0; unsigned long long ln_start_cycle=0;
'''
text=text.replace('    unsigned last_fc2_global=30;',decl+'\n    unsigned last_fc2_global=30;',1)
observation=r'''
            // Read-only snapshot before the next physical rising edge. No added eval.
            const unsigned ln_st=@STATE@,ln_gl=@GLOBAL@,ln_gamma=@GAMMA@,ln_epoch=@EPOCH@;
            const bool ln_start=@STARTV@&&@STARTR@,ln_valid=@VALID@,ln_ready=@READY@;
            if(ln_start) {
                if(ln_observe_active) {std::printf("M007_LN_HOLD_ERROR overlapping_start\n");return 4;}
                ln_observe_active=true;ln_expected_gamma=ln_st==89;ln_expected_epoch=ln_epoch;ln_start_cycle=@CYCLE@;ln_wait_cycles=0;ln_held_pending=false;
            }
            if(ln_observe_active) {
                std::printf("M007_LN_COMMAND_OBSERVE global=%u state=%u epoch=%u gamma=%u expected_gamma=%u rows=128 valid=%u ready=%u start_fire=%u cycle=%llu\n",ln_gl,ln_st,ln_epoch,ln_gamma,ln_expected_gamma,ln_valid,ln_ready,ln_start,static_cast<unsigned long long>(@CYCLE@));std::fflush(stdout);
                if(ln_gamma!=ln_expected_gamma||ln_epoch!=ln_expected_epoch||(ln_held_pending&&(!ln_valid||ln_gamma!=ln_held_gamma||ln_epoch!=ln_held_epoch))) {std::printf("M007_LN_HOLD_ERROR gamma_epoch_or_unaccepted_command_changed\n");std::fflush(stdout);return 4;}
                ln_held_pending=ln_valid&&!ln_ready;
                if(ln_held_pending) {++ln_wait_cycles;ln_held_gamma=ln_gamma;ln_held_epoch=ln_epoch;}
                if(ln_valid&&ln_ready) {
                    std::printf("M007_LN_COMMAND_HOLD_OK global=%u gamma=%u epoch=%u rows=128 start_cycle=%llu command_observed_cycle=%llu natural_delay_cycles=%llu valid_wait_cycles=%u\n",ln_gl,ln_gamma,ln_epoch,ln_start_cycle,static_cast<unsigned long long>(@CYCLE@),static_cast<unsigned long long>(@CYCLE@)-ln_start_cycle,ln_wait_cycles);std::fflush(stdout);ln_observe_active=false;ln_held_pending=false;
                }
            }
'''
for k,v in {'@STATE@':root+'dut__DOT__state','@GLOBAL@':root+'dut__DOT__layer_index','@GAMMA@':r+'p_ln_cmd_gamma','@EPOCH@':r+'p_ln_cmd_epoch','@STARTV@':root+'dut__DOT__v2_resident_ln_start_valid','@STARTR@':root+'dut__DOT__v2_resident_ln_start_ready','@VALID@':r+'p_ln_cmd_valid','@READY@':r+'ln_cmd_ready','@CYCLE@':root+'cycle'}.items():observation=observation.replace(k,v)
assert '@' not in observation;text=text.replace('            ++low_samples;','            ++low_samples;\n'+observation,1);assert text.count('topp->eval();')==1 and 'contextp->threads(1);' in text
header=(obj/(top+'___024root.h')).read_text()
for name in set(re.findall(r'topp->rootp->([A-Za-z0-9_]+)',text)):assert re.search(r'\b'+name+r'\b',header),name
main.write_text(text);(at/'frozen'/main.name).write_text(text)
g=json.loads((at/'generated_build_inputs.json').read_text());g['sources_and_inputs']=[identify(Path(z['path'])) if z['path']==str(main) else z for z in g['sources_and_inputs']];g['sources_and_inputs'].append(identify(Path(__file__)));g['low_phase_hold_observer']={'only_fixed_main_changed':True,'no_DUT_writes_or_extra_eval':True,'actual_ready_alias':'resident.ln_cmd_ready is exact p_ln_cmd_ready source alias','rows':'compiled constant128, as emitted by generated original TB command checker','request_generation_fields':'not separately sampled; original identity checker retained','natural_wait_only_no_injected_backpressure':True};(at/'generated_build_inputs.json').write_text(json.dumps(g,indent=2)+'\n')
(at/'readonly_hold_observer.json').write_text(json.dumps({'observer':identify(Path(__file__)),'new_main':identify(main),'prior_generic_main':g['main_original_generic_all_layer_capture'],'behavior':'low-phase read-only command start through actual command acceptance; gamma/epoch hold; ready alias, compiled constant rows128','no_extra_eval_or_DUT_write':True,'unreadable_additional_fields':'request/generation not separately sampled; original identity assertion remains','no_new_translation':True},indent=2)+'\n')
(at/'receipt_hold_observer_prepare.json').write_text(json.dumps({'category':'static','verdict':'PASS','stage':'derive_exact_generic_main_and_read_only_natural_LN_command_hold_observer','elapsed_seconds':time.monotonic()-started,'guarded':False,'new_simulation_or_build':False},indent=2)+'\n');print('READ_ONLY_LN_HOLD_OBSERVER_PREPARED')
