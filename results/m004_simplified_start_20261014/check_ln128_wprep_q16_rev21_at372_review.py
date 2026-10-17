"""Incremental frozen evidence review; previous AT352-364 review is reused."""
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
run=root/'project/E004_full_accelerator_integration/experiment_results/runs/R001'
base=run/'attempts'
at={n:next(base.glob(f'AT{n}_*')) for n in [364,*range(365,373)]}
here=Path(__file__).parent
prior=json.loads((here/'ln128_wprep_q16_rev21_at364_review_20261016.json').read_text())
ledger_path=run/'reports/SM004_rev21_guard_ledger_AT352_AT372_20261016.json'
ledger=json.loads(ledger_path.read_text())
checks=[]; identities=[]; guards=[]; policies=0; manifest_count=0
sums={k:Decimal(v)for k,v in prior['totals'].items()}

def check(name,ok): checks.append({'name':name,'pass':bool(ok)})
def h(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read(n,name): return (at[n]/'frozen'/name).read_text()

check('reuse_prior_complete_review',prior['check_count']==1646 and not prior['failures'])
old={(g['attempt'],g['guard']):g for g in prior['guards']}
for e in ledger['guards']:
    n=int(e['attempt'][2:5])
    if n<=364:
        previous=old[(n,e['guard'])]
        check(f'old_guard_unchanged:{n}:{e["guard"]}',all(previous[k]==e[k]for k in ['elapsed_seconds','child_exit_code','trigger']) and previous['policy_samples']==e['policy_checked_records'])
        continue
    g=at[n]/e['guard']
    result=json.loads((g/'guard_result.json').read_text(),parse_float=Decimal)
    plan=json.loads((g/'guard_plan.json').read_text())
    samples=json.loads((g/'policy_checks.json').read_text())
    log=(g/'driver.log').read_text()
    kind='static' if g.name.startswith('guard_static') else 'rtl'
    check(f'{n}:{g.name}:receipt',str(result['elapsed_seconds'])==e['elapsed_seconds'] and all(result[k]==e[k]for k in ['child_exit_code','trigger']))
    check(f'{n}:{g.name}:memory',result['minimum_mem_available_kb']>192*1024**2 and result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'])
    check(f'{n}:{g.name}:policy_count',len(samples)==e['policy_checked_records'])
    for i,s in enumerate(samples):
        check(f'{n}:{g.name}:policy:{i}',s['matches'] and s['affinity']==[0,1,2,3] and s['nice']==19 and s['ionice']=='idle' and s['ionice_exit']==0)
    policies+=len(samples)
    if kind=='rtl':
        check(f'{n}:{g.name}:actual_fixture','FIXTURE=../fixture' in plan['command'] and Path(plan['cwd'])==at[n]/'work')
        if n==370:
            check('AT370_cost_stop_retained',result['child_exit_code']==-9 and result['trigger']=='timeout' and 'REV21_CORE_WPREP_PASS' not in log)
        else:
            check(f'{n}:{g.name}:clean',result['child_exit_code']==0 and result['trigger'] is None and not re.search(r'^(Fatal:|ERROR:)',log,re.M))
    sums[kind]+=result['elapsed_seconds']
    guards.append(e)

for n in range(365,373):
    manifest=json.loads((at[n]/'source_manifest.json').read_text())
    for entry in manifest['entries']:
        p=at[n]/entry['path']; digest=h(p)
        check(f'{n}:identity:{entry["path"]}',digest==entry['sha256'] and p.stat().st_size==entry['bytes'])
        identities.append({'attempt':n,'path':entry['path'],'sha256':digest,'bytes':p.stat().st_size})
        manifest_count+=1
        if entry['path'].startswith('fixture/') and (at[364]/entry['path']).exists():
            check(f'{n}:fixture_same_parent:{entry["path"]}',digest==h(at[364]/entry['path']))
check('1191_manifest_entries',manifest_count==1191)
check('19_guards_132_new_policies',len(guards)==19 and policies==132)
check('41_guards_277_observed_policies',ledger['guard_count']==41 and len(ledger['guards'])==41 and ledger['policy_observed_count']==policies+prior['policy_samples']==277)
for kind in sums:
    check('total:'+kind,str(sums[kind])==ledger['totals_seconds'][kind])
    check('remaining:'+kind,Decimal(1800 if kind=='static' else 3600)-sums[kind]==Decimal(ledger['remaining_seconds'][kind]))

production=['laya_source_norm_service_v1.sv','laya_lnq_bank_service_v1.sv','laya_w_prep_service_v1.sv','t4_dual_w_cache_v1.sv']
for name in production:
    check('AT368_same_production:'+name,h(at[368]/'frozen'/name)==h(at[364]/'frozen'/name))
for n in [371,372]:
    for name in production[2:]: check(f'{n}:same_W_production:{name}',h(at[n]/'frozen'/name)==h(at[364]/'frozen'/name))
core_name='laya_lnq_wi_gqdown_row_v1.sv'
old_core=read(367,core_name);new_core=read(370,core_name)
marker='module laya_lnq_wi_gqdown_row_v1'
check('parent_engine_bytes_unchanged',marker in old_core and old_core.split(marker)[0]==new_core.split(marker)[0])
for name in [core_name,'laya_rev21_core_wprep_tb.sv']:
    check('370_372_same_core_and_TB:'+name,h(at[370]/'frozen'/name)==h(at[372]/'frozen'/name))
check('parent_enum_widened','typedef enum logic [3:0]' in read(367,'laya_qkv_s128_request_v1.sv'))
compile366=(at[366]/'guard_static/driver.log').read_text()
check('parent_changed_sources_compiled_before_timeout',all('/frozen/'+name in compile366 for name in ['laya_qkv_s128_request_v1.sv','laya_qkv_scratch_row_v1.sv',core_name]) and 'ERROR:' not in compile366)
check('actual_parent_snapshot', 'Built simulation snapshot rev21_parent_row0_mt4_sim' in (at[367]/'guard_static/driver.log').read_text())
check('actual_core_O3_snapshot', 'Built simulation snapshot rev21_core_wprep_sim' in (at[372]/'guard_static/driver.log').read_text() and '--O3' in read(372,'build_core_wprep_tb.sh'))

tb=read(368,'laya_ln128_wprep_q16_chain_tb.sv')
check('Q_input_bits_checked_at_accept',all(x in tb for x in ['qf_state==3\'d3 && dut.bank_service.ln_x_ready','!dut.bank_service.lnq.x_valid','dut.bank_service.lnq.x_bits!==','CHAIN_Q_INPUT','q_input_count!=16384']))
check('leaf_response_mapping_not_bank_snapshot','q_observed' not in tb and all(x in tb for x in ['q_from_leaf[base_word+lane]=dut.bank_service.ln_rsp_q[32*lane+:32]','q_rsp_seen[response_index]','q_rsp_scale_seen[response_index-1]','CHAIN_Q_WRITE_SOURCE','CHAIN_SCALE_WRITE_SOURCE','CHAIN_Q_LEAF_TO_BANK','CHAIN_Q_LEAF_HOLD']))
check('independent_Q_gold_still_four_rows','for(int r=0;r<4;r++)' in tb and 'CHAIN_Q_GOLD' in tb and 'CHAIN_SCALE_GOLD' in tb)
check('publication_constants_remain_explicit',"assign done_valid=1'b0;" in tb and "assign tensor_final_valid=1'b0;" in tb and "assign tensor_raw_valid=1'b0;" in tb)
log=(at[368]/'guard_rtl_full_chain/driver.log').read_text()
check('chain_full_markers_once',log.count('CHAIN_LN128_PASS')==1 and log.count('CHAIN_A16_PASS q=16 state1R=1024 input_bits=16384 leaf_to_bank=4352')==1)
parent_tb=read(367,'laya_staged_ln128_pilot_tb.sv')
check('actual_parent_request_TB','laya_qkv_s128_request_v1' in parent_tb and 'STAGED_LN_ROW0_PREFIX_PASS' in parent_tb and 'assign done_valid=' not in parent_tb)
check('parent_row0_final_marker','STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256' in (at[367]/'guard_rtl_parent_row0/driver.log').read_text())
fields=['wp_done_status','wp_done_op','wp_done_check_status','wp_done_detail','wp_done_bad64','wp_done_model','wp_done_numeric','wp_done_id','wp_done_source_epoch','wp_done_epoch','wp_done_request','wp_done_generation','wp_done_key']
for n,name in [(371,'laya_w_prep_service_tb.sv'),(372,'laya_rev21_core_wprep_tb.sv')]:
    text=read(n,name)
    held=text.split('held_check={',1)[1].split('};',1)[0]
    compared=text.split('held_check={',1)[1].split('!==held_check',1)[0]
    check(f'{n}:W_bundle_all_fields_hold',all(x in held and x in compared for x in fields) and 'repeat(3)begin' in compared)
    check(f'{n}:error_status16_expected','wp_done_check_status!=7' in text and 'wp_done_check_status!=6' in text)
    check(f'{n}:bad_epoch_reject','W_PREP_BAD_EPOCH_REJECT' in text and 'W_PREP_BAD_EPOCH_HOLD' in text)
    for g in at[n].glob('guard_rtl*'):
        plan=json.loads((g/'guard_plan.json').read_text());cmd=plan['command'];log=(g/'driver.log').read_text()
        check(f'{n}:{g.name}:scenario_flags',('BUS_FAULT' in cmd)==('bus' in g.name or 'mixed' in g.name) and ('SCALE_FAULT' in cmd)==('scale' in g.name or 'mixed' in g.name))
        check(f'{n}:{g.name}:one_PASS',log.count('REV21_CORE_WPREP_PASS' if n==372 else 'W_PREP_SERVICE_PASS')==1)
core_tb=read(372,'laya_rev21_core_wprep_tb.sv')
check('core_local_error_hold_consume_then_W_without_reset',all(x in core_tb for x in ['CORE_LOCAL_REJECT_CHECK','CORE_LOCAL_REJECT_HOLD',"cmd_exec=3'd4;cmd_prepared_source=0;","done_bad_element!=32'hffff_ffff","result_exec!=3'd1 || result_row!=0"]) and core_tb.count('rst_n=1;')==1)
check('final_status7_is_bad_epoch',core_tb.index('wp_epoch=0;')>core_tb.index('W_PREP_DONE_NOT_CONSUMED') and core_tb.index('REV21_CORE_WPREP_PASS')>core_tb.index('W_PREP_BAD_EPOCH_NOT_CONSUMED'))
result={'scope':'INCREMENTAL_AT365_372_SCOPED_REVIEW_NOT_REV21_CLOSEOUT','check_count':len(checks),'checks':checks,'failures':[x for x in checks if not x['pass']],'new_manifest_entries':manifest_count,'new_guard_count':len(guards),'new_policy_samples':policies,'total_guard_count':41,'total_observed_policy_samples':277,'totals':{k:str(v)for k,v in sums.items()},'remaining':ledger['remaining_seconds'],'ledger_sha256':h(ledger_path),'identities':identities,'guards':guards,'scope_notes':['AT368 observer gaps closed for tested normal chain; rows4..15 no independent arithmetic oracle','AT371/372 main W completion bundle held, invalid epoch only asserted subset','AT367 complete parent hierarchy only row0 prefix','AT372 local missing-token rejection then real W, not later LN_ONLY or parent full chain','O0 prefix timeout and O3 full completion are not a matched runtime speed ratio'],'measurement':{'elapsed_seconds':time.monotonic()-start,'maxrss_kib':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'interactive_reads_cumulative':'UNKNOWN'}}
(here/'ln128_wprep_q16_rev21_at372_review_20261016.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k]for k in ['check_count','failures','new_manifest_entries','new_guard_count','new_policy_samples','totals','remaining']},ensure_ascii=False))
raise SystemExit(bool(result['failures']))
