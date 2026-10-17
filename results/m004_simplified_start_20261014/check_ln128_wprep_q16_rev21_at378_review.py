"""Read-only incremental AT378 audit; AT352-377 original evidence is reused."""
import hashlib,json,os,re,resource,time
from decimal import Decimal
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3))
start=time.monotonic();root=Path(__file__).resolve().parents[2];here=Path(__file__).parent
run=root/'project/E004_full_accelerator_integration/experiment_results/runs/R001'
at=next((run/'attempts').glob('AT378_*'));parent=next((run/'attempts').glob('AT377_*'))
prior=json.loads((here/'ln128_wprep_q16_rev21_at377_review_20261016.json').read_text())
op=run/'reports/SM004_rev21_guard_ledger_AT352_AT377_20261016.json'
lp=run/'reports/SM004_rev21_guard_ledger_AT352_AT378_20261016.json'
old=json.loads(op.read_text());ledger=json.loads(lp.read_text())
checks=[];identities=[];guards=[];policies=0
totals={k:Decimal(v) for k,v in prior['totals'].items()}
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def check(name,ok):checks.append({'name':name,'pass':bool(ok)})
check('reuse_prior',not prior['failures'] and prior['check_count']==1005 and prior['ledger_sha256']==h(op))
old_guards={(e['attempt'],e['guard']):e for e in old['guards']}
for e in ledger['guards']:
    if not e['attempt'].startswith('AT378_'):
        check('preserve:'+e['attempt']+':'+e['guard'],e==old_guards[(e['attempt'],e['guard'])]);continue
    gp=at/e['guard'];result=json.loads((gp/'guard_result.json').read_text(),parse_float=Decimal)
    plan=json.loads((gp/'guard_plan.json').read_text());samples=json.loads((gp/'policy_checks.json').read_text())
    log=(gp/'driver.log').read_text();kind='static' if gp.name=='guard_static' else 'rtl'
    check('receipt:'+gp.name,str(result['elapsed_seconds'])==e['elapsed_seconds'] and all(result[k]==e[k] for k in ['trigger','child_exit_code']))
    check('clean:'+gp.name,result['child_exit_code']==0 and result['trigger'] is None and not re.search(r'^(Fatal:|ERROR:)',log,re.M))
    check('resource:'+gp.name,result['minimum_mem_available_kb']>192*1024**2 and result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and result['elapsed_seconds']<plan['maximum_seconds'])
    check('policy_count:'+gp.name,len(samples)==e['policy_checked_records'])
    for i,s in enumerate(samples):check(f'policy:{gp.name}:{i}',s['matches'] and s['affinity']==[0,1,2,3] and s['nice']==19 and s['ionice']=='idle' and s['ionice_exit']==0)
    policies+=len(samples);totals[kind]+=result['elapsed_seconds'];guards.append(e)
    if kind=='rtl':
        check('actual_scenario',all(x in plan['command'] for x in ['FIXTURE=../fixture','CHAIN_W_BUS_FAULT','CHAIN_W_ERROR_RECOVER']) and Path(plan['cwd'])==at/'work')
        check('same_run_two_markers',log.count('CHAIN_W_BUS_ERROR_BOUNDARY_PASS')==1 and log.count('CHAIN_W_ERROR_DISCARD_RECOVERY_PASS')==1)
    else:check('snapshot','Built simulation snapshot rev21_chain_sim' in log)
manifest=json.loads((at/'source_manifest.json').read_text())
for e in manifest['entries']:
    p=at/e['path'];digest=h(p)
    check('identity:'+e['path'],digest==e['sha256'] and p.stat().st_size==e['bytes'])
    identities.append({'path':e['path'],'sha256':digest,'bytes':p.stat().st_size})
    if e['path'].startswith('fixture/'):
        check('fixture_unchanged:'+e['path'],digest==h(parent/e['path']))
for name in ['laya_source_norm_service_v1.sv','laya_lnq_bank_service_v1.sv','laya_w_prep_service_v1.sv','t4_dual_w_cache_v1.sv']:
    check('production_unchanged:'+name,h(at/'frozen'/name)==h(parent/'frozen'/name))
check('counts',len(identities)==148 and len(guards)==2 and policies==11 and len(ledger['guards'])==ledger['guard_count']==53 and ledger['policy_observed_count']==352)
for kind in totals:
    check('total:'+kind,str(totals[kind])==ledger['totals_seconds'][kind])
    check('remaining:'+kind,Decimal(1800 if kind=='static' else 3600)-totals[kind]==Decimal(ledger['remaining_seconds'][kind]))
t=(at/'frozen/laya_ln128_wprep_q16_chain_tb.sv').read_text()
p=t.split('if($test$plusargs("CHAIN_W_ERROR_RECOVER"))begin')[1].split('$finish;')[0]
check('direct_stage_release_not_force',all(x in t for x in ['logic stage_release_fire=0;','.stage_release_fire,']) and 'stage_release_fire=1;' in p and not re.search(r'\bforce\s',t))
check('post_release_writer_idle',all(x in p for x in ['!cmd_ready','dut.stage_retired_rows!=0','dut.stage_loop_state!=5\'d0','!dut.writer_debt_zero']))
check('new_input_id_source_epoch',all(x in p for x in ['cmd_id=300;cmd_state0_epoch=2;','cmd_valid=1;','cmd_model_identity=model_rom[0]']))
check('no_reset_recovery','rst_n' not in p and t.count('rst_n=1;')==1)
check('real_new_row_counts',all(x in p for x in ['dut.stage_retired_rows!=1','b_count!=8256','source_r_count!=8256','gamma_r_count!=512','norm_total!=132096','norm_mem[i]!==norm_gold[i]','state1_ar_count!=0 || q_input_count!=0']))
check('new_W_handshake_gold_not_only_old_memory',all(x in t for x in ['if(m_axi_wvalid[2] && m_axi_wready[2])','m_axi_wdata[2][lane*32+:32]!==norm_gold[active_row*1024+','STAGED_LN_NORM_GOLD','if(m_axi_bvalid[2] && m_axi_bready[2])']))
check('real_source_and_gamma',all(x in t for x in ['state0_rdata[32*lane+:32]=raw[active_row*1024+source_beat*16+lane]','gamma_beat<=gamma_r_count%256','always_comb active_row=int\'(dut.stage_loop_row)']))
check('row255_diagnostic_only',all(x in t for x in ['if(dut.stage_retired_rows!=last_retired)','dut.stage_retired_rows-1\'b1','last_retired<=dut.stage_retired_rows']) and 'dut.stage_retired_rows!=1' in p)
check('independent_not_parent_publication',all(x in t for x in ["assign done_valid=1'b0;","assign tensor_raw_valid=1'b0;","assign tensor_final_valid=1'b0;"]))
check('no_W_or_full_request_recovery_claim',p.index('CHAIN_W_ERROR_DISCARD_RECOVERY_PASS')>p.index('dut.stage_retired_rows!=1') and 'stage_continue_valid=1' not in p)
report=(run/'reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md').read_text()
check('AT377_report_scope_corrections',all(x in report for x in ['不产生本次错误done','不能拆称两类独立epoch拒绝','未逐拍核全部身份/Check字段','没有AXI B']))
result={'scope':'AT378_SCOPED_STAGE_DISCARD_LN_ROW0_RECOVERY_NOT_CLOSEOUT','check_count':len(checks),'checks':checks,'failures':[c for c in checks if not c['pass']],'new_manifest_entries':len(identities),'new_guard_count':len(guards),'new_policy_samples':policies,'total_guard_count':53,'total_observed_policy_samples':352,'totals':{k:str(v) for k,v in totals.items()},'remaining':ledger['remaining_seconds'],'ledger_sha256':h(lp),'prior_ledger_sha256':h(op),'identities':identities,'guards':guards,'scope_notes':['Direct stage_release_fire caller, not parent tensor_release/e/e+1/e+2','Only writer_debt_zero directly checked at release endpoint; W response totals as observed','Recovery input id300/source epoch2; no full identity echo assertion','New real LN row0 after W failure, no second W/Q chain or full request recovery','row255 is 8-bit diagnostic subtraction when retirement resets to0'],'measurement':{'elapsed_seconds':time.monotonic()-start,'maxrss_kib':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'interactive_reads_cumulative':'UNKNOWN'}}
(here/'ln128_wprep_q16_rev21_at378_review_20261016.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['check_count','failures','new_manifest_entries','new_policy_samples','totals','remaining']},ensure_ascii=False))
raise SystemExit(bool(result['failures']))
