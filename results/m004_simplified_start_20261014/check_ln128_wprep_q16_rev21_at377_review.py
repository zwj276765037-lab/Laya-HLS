"""Incremental AT373-377 evidence review; do not rerun experiments or prior audits."""
import hashlib
import json
import os
import re
import resource
import time
from decimal import Decimal
from pathlib import Path

resource.setrlimit(resource.RLIMIT_AS, (1024**3,1024**3))
start=time.monotonic()
root=Path(__file__).resolve().parents[2]
here=Path(__file__).parent
run=root/'project/E004_full_accelerator_integration/experiment_results/runs/R001'
base=run/'attempts'
at={n:next(base.glob(f'AT{n}_*')) for n in [362,368,*range(373,378)]}
prior=json.loads((here/'ln128_wprep_q16_rev21_at372_review_20261016.json').read_text())
old_path=run/'reports/SM004_rev21_guard_ledger_AT352_AT372_20261016.json'
ledger_path=run/'reports/SM004_rev21_guard_ledger_AT352_AT377_20261016.json'
old=json.loads(old_path.read_text());ledger=json.loads(ledger_path.read_text())
checks=[];identities=[];guards=[];policies=0
sums={k:Decimal(v) for k,v in prior['totals'].items()}

def check(name,ok):checks.append({'name':name,'pass':bool(ok)})
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def tb(n,name):return (at[n]/'frozen'/name).read_text()

check('prior_review_reused',prior['check_count']==1569 and not prior['failures'] and h(old_path)==prior['ledger_sha256'])
previous={(e['attempt'],e['guard']):e for e in old['guards']}
for e in ledger['guards']:
    n=int(e['attempt'][2:5])
    if n<=372:
        check(f'prior_guard_preserved:{n}:{e["guard"]}',e==previous[(e['attempt'],e['guard'])])
        continue
    g=at[n]/e['guard']
    result=json.loads((g/'guard_result.json').read_text(),parse_float=Decimal)
    plan=json.loads((g/'guard_plan.json').read_text())
    samples=json.loads((g/'policy_checks.json').read_text())
    log=(g/'driver.log').read_text()
    kind='static' if g.name.startswith('guard_static') else 'rtl'
    check(f'{n}:{g.name}:receipt',str(result['elapsed_seconds'])==e['elapsed_seconds'] and all(result[k]==e[k] for k in ['child_exit_code','trigger']))
    check(f'{n}:{g.name}:clean',result['child_exit_code']==0 and result['trigger'] is None and not re.search(r'^(Fatal:|ERROR:)',log,re.M))
    check(f'{n}:{g.name}:resources',result['minimum_mem_available_kb']>192*1024**2 and result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and result['elapsed_seconds']<plan['maximum_seconds'])
    check(f'{n}:{g.name}:policy_count',len(samples)==e['policy_checked_records'])
    for i,s in enumerate(samples):
        check(f'{n}:{g.name}:policy:{i}',s['matches'] and s['affinity']==[0,1,2,3] and s['nice']==19 and s['ionice']=='idle' and s['ionice_exit']==0)
    policies+=len(samples)
    if kind=='rtl':
        flag,marker={373:('PARTIAL_RECOVERY','REV21_Q16_PARTIAL_DISCARD_RECOVERY_PASS'),374:('Q_INFLIGHT_RESET','REV21_Q_INFLIGHT_RESET_RECOVERY_PASS'),375:('CHAIN_W_BUS_FAULT','CHAIN_W_BUS_ERROR_BOUNDARY_PASS'),376:('CHAIN_LAST_B_HOLD','CHAIN_LAST_B_CONTINUE_PASS'),377:('CHAIN_LAST_STATE1_R_HOLD','CHAIN_STATE1_LAST_R_HOLD_PASS')}[n]
        check(f'{n}:scenario_and_marker',flag in plan['command'] and log.count(marker)==1)
        check(f'{n}:fixture', 'FIXTURE=../fixture' in plan['command'] and Path(plan['cwd'])==at[n]/'work')
    else:
        check(f'{n}:actual_snapshot','Built simulation snapshot '+('rev21_q16_partial_sim' if n<=374 else 'rev21_chain_sim') in log)
    sums[kind]+=result['elapsed_seconds'];guards.append(e)

for n in range(373,378):
    manifest=json.loads((at[n]/'source_manifest.json').read_text())
    parent=at[362] if n<=374 else at[368]
    for entry in manifest['entries']:
        p=at[n]/entry['path'];digest=h(p)
        check(f'{n}:identity:{entry["path"]}',digest==entry['sha256'] and p.stat().st_size==entry['bytes'])
        identities.append({'attempt':n,'path':entry['path'],'sha256':digest,'bytes':p.stat().st_size})
        if entry['path'].startswith('fixture/'):
            check(f'{n}:fixture_unchanged:{entry["path"]}',(parent/entry['path']).exists() and digest==h(parent/entry['path']))
    for name in ['laya_source_norm_service_v1.sv','laya_lnq_bank_service_v1.sv','laya_w_prep_service_v1.sv','t4_dual_w_cache_v1.sv']:
        check(f'{n}:same_four_production:{name}',h(at[n]/'frozen'/name)==h(at[368]/'frozen'/name))
check('new_counts',len(identities)==744 and len(guards)==10 and policies==64)
check('total_counts',len(ledger['guards'])==ledger['guard_count']==51 and ledger['policy_observed_count']==prior['total_observed_policy_samples']+policies==341)
for kind in sums:
    check('total:'+kind,str(sums[kind])==ledger['totals_seconds'][kind])
    check('remaining:'+kind,Decimal(1800 if kind=='static' else 3600)-sums[kind]==Decimal(ledger['remaining_seconds'][kind]))

lower='laya_rev21_lower_q16_first16_tb.sv'
t=tb(373,lower)
p=t.split('if($test$plusargs("PARTIAL_RECOVERY"))begin')[1].split('$finish;')[0]
check('partial_refusal_not_error_completion',all(x in p for x in ['if(prep_begin_ready)','if(cmd_ready || q16_window_ok',"cmd_epoch=2",'a_window_discard=1;a_window_release_valid=1','prepare_norm(0,2);run_row(0,2)']) and 'done_ready' not in p)
check('epoch_not_independently_isolated',all(x in t for x in ['.q16_epoch(cmd_epoch)','.match_epoch(cmd_epoch)']))
check('partial_local_peer_boundary',all(x in t for x in [".bank_idle(1'b1)",'.prep_consume(cmd_valid && cmd_ready)','q16_retire_success(done_valid && done_ready && done_status==0)']))
check('partial_Q_gold_and_held_valid',all(x in t for x in ['SHARED_Q16_Q_MISMATCH','SHARED_Q16_SCALE_MISMATCH','SHARED_Q16_DONE_HOLD','q_rsp_count!=rsp_before+32']))
t=tb(374,lower)
p=t.split('if($test$plusargs("Q_INFLIGHT_RESET"))begin')[1].split('$finish;')[0]
check('Q_input_inflight_reset',all(x in p for x in ["dut.qf_state==3'd3 && dut.qf_index>=32",'quiet<510','rst_n=0;','rst_n=1;','prepare_norm(0,2);run_row(0,2)']))
check('reset_assertion_scope_is_control',all(x in p for x in ['done_valid || prep_active || prep_token_valid','dut.q16_cover!=0 || q16_next_row!=0','dut.qf_state!=0 || dut.q16_state!=0']) and 'ln_rsp_valid' not in p)

chain='laya_ln128_wprep_q16_chain_tb.sv'
t=tb(375,chain)
p=t.split('if($test$plusargs("CHAIN_W_BUS_FAULT"))begin')[1].split('$finish;')[0]
check('real_bus_fault', 'bus_fault=$test$plusargs("CHAIN_W_BUS_FAULT")' in t and 'bus_fault && p==0 && beat[p]==24575' in t)
check('W_error_endpoint',all(x in p for x in ['stage_final_status!=4\'d7','stage_done_op!=8\'h80','stage_done_check_status!=16\'d7','stage_done_detail!=32\'h0780_0005','stage_done_bad64!=64\'hffff_ffff_ffff_ffff','state1_ar_count!=0 || state1_r_count!=0','q_input_count!=0 || q_rsp_count!=0','w_peer.r_count[0]!=24576','w_peer.r_count[1]!=24576','w_peer.r_count[2]!=3072','w_peer.aux_count!=8','norm_mem[i]!==norm_gold[i]']))
held=p.split('repeat(3)begin')[1].split('for(int i=0;i<131072')[0]
check('W_error_hold_subset_only','stage_done_check_status' in held and 'stage_done_detail' in held and 'stage_done_bad64' not in held)
t=tb(376,chain)
check('last_B_delays_valid_not_ready',all(x in t for x in ['(!last_b_hold || b_count!=8191 || last_b_released)','wait(b_count==8191 && write_w && b_delay>=3)','dut.stage_retired_rows!=8\'d127','stage_continue_ready || norm_stage_ready','!dut.bank_link.gamma_token_valid','CHAIN_LAST_B_RELEASE_BAD']))
t=tb(377,chain)
check('last_R_delays_valid_and_blocks_r15',all(x in t for x in ['(!last_state1_hold || state1_r_count!=1023 ||','state1_r_count==1023 && state1_active && state1_left==1','q_input_count!=15360 || q_rsp_count!=480','stage_q_retired_rows!=5\'d15','CHAIN_STATE1_LAST_R_BARRIER_NOT_SEEN']))
check('chain_observers_and_gold_retained',all(x in t for x in ['CHAIN_Q_INPUT','CHAIN_Q_WRITE_SOURCE','CHAIN_SCALE_WRITE_SOURCE','CHAIN_Q_LEAF_TO_BANK','CHAIN_Q_LEAF_HOLD','CHAIN_Q_GOLD','CHAIN_SCALE_GOLD','q_input_count!=16384','for(int r=0;r<4;r++)']))
check('independent_not_parent_publication',all(x in t for x in ["assign done_valid=1'b0;","assign tensor_final_valid=1'b0;","assign tensor_raw_valid=1'b0;"]))
leaf=tb(377,'laya_lnq_bank_service_v1.sv')
check('Q16_export_internal_bank_no_AXI_B','Q16_WRITE:begin' in leaf and 'Q16_SCALE:begin' in leaf and 'Q16_RELEASE:if(ln_release_ready)' in leaf)

result={'scope':'INCREMENTAL_AT373_377_SCOPED_REVIEW_NOT_CLOSEOUT','check_count':len(checks),'checks':checks,'failures':[x for x in checks if not x['pass']], 'new_manifest_entries':len(identities),'new_guard_count':len(guards),'new_policy_samples':policies,'total_guard_count':51,'total_observed_policy_samples':341,'totals':{k:str(v) for k,v in sums.items()},'remaining':ledger['remaining_seconds'],'ledger_sha256':h(ledger_path),'prior_ledger_sha256':h(old_path),'identities':identities,'guards':guards,'scope_notes':['AT373 wrong kind/epoch is ready-low refusal, not error done/consume; cmd_epoch drives A epoch and match epoch together','AT374 Q input feed reset, only asserted control signals quiet, local peer not parent/FP-outstanding proof','AT375 endpoint Check fields and three-cycle status16/detail/valid subset, no no-reset recovery','AT376 delays slave BVALID; AT377 delays slave RVALID; not asserted-valid backpressure stability','r15 Q16 export is local bank write/release/done, not AXI B','parent fixed W/Q delegation and whole-runtime parent remain open'],'measurement':{'elapsed_seconds':time.monotonic()-start,'maxrss_kib':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'interactive_reads_cumulative':'UNKNOWN'}}
(here/'ln128_wprep_q16_rev21_at377_review_20261016.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['check_count','failures','new_manifest_entries','new_guard_count','new_policy_samples','totals','remaining']},ensure_ascii=False))
raise SystemExit(bool(result['failures']))
