"""Incremental AT379-383 audit; prior frozen reviews and reference results reused."""
import hashlib,json,os,re,resource,time
from decimal import Decimal
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3))
start=time.monotonic();root=Path(__file__).resolve().parents[2];here=Path(__file__).parent
run=root/'project/E004_full_accelerator_integration/experiment_results/runs/R001';base=run/'attempts'
at={n:next(base.glob(f'AT{n}_*')) for n in [367,368,372,*range(379,384)]}
prior=json.loads((here/'ln128_wprep_q16_rev21_at378_review_20261016.json').read_text())
op=run/'reports/SM004_rev21_guard_ledger_AT352_AT378_20261016.json';lp=run/'reports/SM004_rev21_guard_ledger_AT352_AT383_20261016.json'
old=json.loads(op.read_text());ledger=json.loads(lp.read_text());checks=[];identities=[];guards=[];policies=0
totals={k:Decimal(v) for k,v in prior['totals'].items()}
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def check(name,ok):checks.append({'name':name,'pass':bool(ok)})
def frozen(n,name):return (at[n]/'frozen'/name).read_text()
check('prior_review_reused',prior['check_count']==254 and not prior['failures'] and h(op)==prior['ledger_sha256'])
oldg={(e['attempt'],e['guard']):e for e in old['guards']}
for e in ledger['guards']:
    n=int(e['attempt'][2:5])
    if n<379:
        check('old_guard:'+e['attempt']+':'+e['guard'],e==oldg[(e['attempt'],e['guard'])]);continue
    g=at[n]/e['guard'];r=json.loads((g/'guard_result.json').read_text(),parse_float=Decimal)
    p=json.loads((g/'guard_plan.json').read_text());s=json.loads((g/'policy_checks.json').read_text());log=(g/'driver.log').read_text()
    kind='static' if g.name=='guard_static' else 'rtl'
    check(f'{n}:{g.name}:receipt',str(r['elapsed_seconds'])==e['elapsed_seconds'] and all(r[k]==e[k] for k in ['trigger','child_exit_code']))
    check(f'{n}:{g.name}:resources',r['minimum_mem_available_kb']>192*1024**2 and r['peak_owned_rss_kb']<=p['maximum_owned_rss_kb'])
    check(f'{n}:{g.name}:policy_count',len(s)==e['policy_checked_records'])
    for i,x in enumerate(s):check(f'{n}:{g.name}:policy:{i}',x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0)
    policies+=len(s);totals[kind]+=r['elapsed_seconds'];guards.append(e)
    if n in (380,381):
        check(f'{n}:compile_FAIL_preserved',r['child_exit_code']==1 and r['trigger'] is None and 'ERROR:' in log and 'Built simulation snapshot' not in log)
    elif n==383:
        check('parent_prefix_COST_STOP',r['child_exit_code']==-9 and r['trigger']=='timeout' and p['maximum_seconds']==120 and 'PREFIX_ROW0' not in p['command'] and 'STAGED_LN128_REAL_PASS' not in log and not re.search(r'^(Fatal:|ERROR:)',log,re.M))
        check('parent_two_rows_only','row=0 B=64 sourceR=64 cycle=15377' in log and 'row=1 B=128 sourceR=128 cycle=29465' in log and 'row=2 B=' not in log and 'raw=192 norm=2048 B=128' in log)
    else:check(f'{n}:{g.name}:clean',r['child_exit_code']==0 and r['trigger'] is None and not re.search(r'^(Fatal:|ERROR:)',log,re.M))
    if kind=='rtl':check(f'{n}:fixture','FIXTURE=../fixture' in p['command'] and Path(p['cwd'])==at[n]/'work')
for n in range(379,384):
    m=json.loads((at[n]/'source_manifest.json').read_text())
    for e in m['entries']:
        path=at[n]/e['path'];digest=h(path)
        check(f'{n}:identity:{e["path"]}',digest==e['sha256'] and path.stat().st_size==e['bytes'])
        identities.append({'attempt':n,'path':e['path'],'sha256':digest,'bytes':path.stat().st_size})
for n in [379,382,383]:
    for name in ['laya_source_norm_service_v1.sv','laya_lnq_bank_service_v1.sv','laya_w_prep_service_v1.sv','t4_dual_w_cache_v1.sv']:
        check(f'{n}:same_production:{name}',h(at[n]/'frozen'/name)==h(at[368]/'frozen'/name))
m382=json.loads((at[382]/'source_manifest.json').read_text());m383=json.loads((at[383]/'source_manifest.json').read_text())
check('382_383_all_manifest_entries_identical',m382['entries']==m383['entries'])
fix=[e for e in m382['entries'] if e['path'].startswith('fixture/')]
check('12_parent_fixtures_unchanged',len(fix)==12 and all(h(at[382]/e['path'])==h(at[367]/e['path']) for e in fix))
for name in ['laya_qkv_s128_request_v1.sv','laya_qkv_scratch_row_v1.sv','laya_staged_ln128_pilot_tb.sv']:
    check('same_parent_AT367:'+name,h(at[382]/'frozen'/name)==h(at[367]/'frozen'/name))
check('current_core_shell',h(at[382]/'frozen/laya_lnq_wi_gqdown_row_v1.sv')==h(at[372]/'frozen/laya_lnq_wi_gqdown_row_v1.sv'))
check('actual_parent_O3_build','--O3' in frozen(382,'build_parent_continue.sh') and 'Built simulation snapshot rev21_parent_continue_sim' in (at[382]/'guard_static/driver.log').read_text())
check('parent_row0_PASS','STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256' in (at[382]/'guard_rtl_parent_row0/driver.log').read_text())
t=frozen(379,'laya_ln128_wprep_q16_chain_tb.sv')
check('real_stage_done_block',all(x in t for x in ['.stage_input_done_ready,','stage_input_done_ready=!stage_done_hold','CHAIN_STAGE_DONE_HOLD_BAD','stage_continue_ready || dut.stage_loop_state!=5\'d8','dut.stage_retired_rows!=8\'d128','!dut.bank_link.gamma_token_valid','stage_input_done_ready=1;','CHAIN_STAGE_DONE_RELEASE_BAD','CHAIN_STAGE_DONE_CONSUME_PASS']))
log=(at[379]/'guard_rtl_done_hold/driver.log').read_text()
check('stage_done_markers',log.count('CHAIN_LN128_PASS')==1 and log.count('CHAIN_STAGE_DONE_CONSUME_PASS')==1)
t=frozen(382,'laya_staged_ln128_pilot_tb.sv')
check('parent_TB_LN_only_not_WQ_chain',all(x in t for x in [".state1_arready(1'b0)",".state1_rvalid(1'b0)","arready='0;rdata='0;rresp='0;rlast='0;rvalid='0;",'STAGED_LN_FORBIDDEN_SERVICE','STAGED_LN128_REAL_PASS']))
check('parent_early_publication_checker',all(x in t for x in ['if(done_valid || tensor_final_valid || tensor_raw_valid ||','row_written!=0 || row_final!=0 || tensor_failed','STAGED_LN128_EARLY_COMPLETION']))
check('counts',len(identities)==744 and len(guards)==7 and policies==46 and len(ledger['guards'])==ledger['guard_count']==60 and ledger['policy_observed_count']==398)
for k in totals:
    check('total:'+k,str(totals[k])==ledger['totals_seconds'][k])
    check('remaining:'+k,Decimal(1800 if k=='static' else 3600)-totals[k]==Decimal(ledger['remaining_seconds'][k]))
result={'scope':'AT379_383_REVIEW_AND_REV21_COST_CLOSEOUT_BASIS','check_count':len(checks),'checks':checks,'failures':[x for x in checks if not x['pass']],'new_manifest_entries':len(identities),'new_guard_count':len(guards),'new_policy_samples':policies,'total_guard_count':60,'total_observed_policy_samples':398,'totals':{k:str(v) for k,v in totals.items()},'remaining':ledger['remaining_seconds'],'ledger_sha256':h(lp),'identities':identities,'guards':guards,'scope_notes':['AT379 upper stage done hold only','AT382 parent O3 build/row0; wrapper+sequencer same as AT367, current core shell as AT372','AT383 only two parent LN rows, timeout not numeric failure','AT382/383 TB lacks W responses and ties STATE1 ready/valid low; terminates at LN128; cannot test W/Q by extending time','full parent remains open; proceed independent same-production MATRIX16 boundary with new contract, not same-timeout rerun'],'measurement':{'elapsed_seconds':time.monotonic()-start,'maxrss_kib':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'interactive_reads_cumulative':'UNKNOWN'}}
(here/'ln128_wprep_q16_rev21_at383_review_20261016.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['check_count','failures','new_manifest_entries','new_guard_count','new_policy_samples','totals','remaining']},ensure_ascii=False));raise SystemExit(bool(result['failures']))
