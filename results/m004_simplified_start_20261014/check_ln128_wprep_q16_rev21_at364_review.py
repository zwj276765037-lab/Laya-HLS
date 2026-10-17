"""Read-only frozen milestone review. No EDA or new numeric reference."""
import hashlib
import json
import os
import re
import resource
import time
from decimal import Decimal
from pathlib import Path

resource.setrlimit(resource.RLIMIT_AS, (1024**3, 1024**3))
started = time.monotonic()
root = Path(__file__).resolve().parents[2]
base = root / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
at = {n: next(base.glob(f'AT{n}_*')) for n in range(352,365)}
checks, identities, guards, policies = [], [], [], 0
manifests, maps = {}, {}
sums = {'static': Decimal(0), 'rtl': Decimal(0)}
counts = {'frozen': 0, 'fixture': 0}

def check(name, value):
    checks.append({'name': name, 'pass': bool(value)})

def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def verify(p, h, size=None):
    data = p.read_bytes()
    got = hashlib.sha256(data).hexdigest()
    check('identity:' + str(p.relative_to(root)), got == h and (size is None or len(data) == size))
    identities.append({'path': str(p.relative_to(root)), 'sha256': got, 'bytes': len(data)})
    return data

for n,p in at.items():
    manifest = json.loads((p/'source_manifest.json').read_text())
    manifests[n] = manifest
    entries = []
    if 'entries' in manifest:
        entries = [(p/x['path'],x['sha256'],x.get('bytes')) for x in manifest['entries']]
    elif 'files' in manifest:
        for name,v in manifest['files'].items():
            entries.append((root/v['frozen'],v['sha256'],None) if isinstance(v,dict) else (p/'frozen'/Path(name).name,v,None))
    else:
        for name,h in manifest.get('frozen',manifest.get('source',{})).items():
            entries.append((p/'frozen'/name,h,None))
        for name,h in manifest.get('fixture',{}).items():
            entries.append((p/'fixture'/name,h,None))
    maps[n] = {str(path.relative_to(p)):h for path,h,_ in entries}
    for path,h,size in entries:
        verify(path,h,size)
        counts['fixture' if path.parent.name=='fixture' else 'frozen'] += 1
    for g in sorted(p.glob('guard*')):
        if not (g/'guard_result.json').exists(): continue
        plan=json.loads((g/'guard_plan.json').read_text())
        result=json.loads((g/'guard_result.json').read_text(),parse_float=Decimal)
        policy_file=g/'policy_checks.json'
        samples=json.loads(policy_file.read_text()) if policy_file.exists() else []
        if not policy_file.exists():
            check(f'{n}:{g.name}:unobserved_policy_explicit',n==361 and result['child_exit_code']==127)
        log=(g/'driver.log').read_text()
        kind='static' if g.name.startswith('guard_static') else 'rtl'
        check(f'{n}:{g.name}:available_memory',result['minimum_mem_available_kb']>192*1024**2)
        if result['peak_owned_rss_kb'] is None:
            check(f'{n}:{g.name}:RSS_unobserved_explicit',n==361 and result['child_exit_code']==127)
        else:
            check(f'{n}:{g.name}:owned_memory',result['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'])
        check(f'{n}:{g.name}:policy_plan',plan['selected_cpu_ids']==[0,1,2,3] and plan['semantic_stall_seconds']==120)
        for i,s in enumerate(samples):
            check(f'{n}:{g.name}:policy:{i}',s['matches'] and s['affinity']==[0,1,2,3] and s['nice']==19 and s['ionice']=='idle' and s['ionice_exit']==0)
        policies+=len(samples)
        if kind=='rtl':
            check(f'{n}:{g.name}:actual_fixture', 'FIXTURE=../fixture' in plan['command'] and Path(plan['cwd'])==p/'work')
            if n==363 and g.name=='guard_rtl_full_chain':
                check('AT363_Fatal_preserved',result['child_exit_code']==0 and 'Fatal:' in log and 'CHAIN_A16_PASS' not in log)
            else:
                check(f'{n}:{g.name}:clean_result',result['child_exit_code']==0 and result['trigger'] is None and not re.search(r'^(Fatal:|ERROR:)',log,re.M))
        sums[kind]+=result['elapsed_seconds']
        guards.append({'attempt':n,'guard':g.name,'kind':kind,'elapsed_seconds':str(result['elapsed_seconds']),'child_exit_code':result['child_exit_code'],'trigger':result['trigger'],'policy_samples':len(samples),'policy_observed':policy_file.exists(),'fatal':bool(re.search(r'^Fatal:',log,re.M)),'finished_at':result['finished_at'],'plan_at':plan['at']})

check('reported_static_total',sums['static']==Decimal('488.59907988831400432'))
check('reported_rtl_total',sums['rtl']==Decimal('736.4435322098433930'))
production=['laya_source_norm_service_v1.sv','laya_lnq_bank_service_v1.sv','laya_w_prep_service_v1.sv','t4_dual_w_cache_v1.sv']
for name in production:
    check('same_358_363_364:'+name,len({digest(at[n]/'frozen'/name) for n in [358,363,364]})==1)
for name in production[:2]:
    check('same_LN_pilot:'+name,digest(at[357]/'frozen'/name)==digest(at[364]/'frozen'/name))
for name in production[2:]:
    check('same_W_pilot:'+name,digest(at[356]/'frozen'/name)==digest(at[364]/'frozen'/name))
check('same_Q16_lower',digest(at[362]/'frozen'/production[1])==digest(at[364]/'frozen'/production[1]))
changed=[k for k in maps[363].keys()&maps[364].keys() if maps[363][k]!=maps[364][k]]
check('only_chain_TB_changed_363_364',changed==['frozen/laya_ln128_wprep_q16_chain_tb.sv'])
for n in (363,364):
    script=(at[n]/'frozen/build_chain_tb_incremental.sh').read_text()
    check(f'{n}:TB_only_compile',script.count('$f/')==1 and 'laya_ln128_wprep_q16_chain_tb.sv' in script and '-s rev21_chain_sim' in script)

support=json.loads((root/'source/fixed_graph_support_20261014/ln128_wprep_q16_20261016.json').read_text())
fixture=at[364]/'fixture'
def decode(name,width):
    return b''.join(int(w,16).to_bytes(width,'little') for w in (fixture/name).read_text().split())
for name,key,width in [('q_rows4.hex','a8_q',32),('scale_rows4.hex','a8_scale',2),('qkv_q0.hex','q0',64),('qkv_q1.hex','q1',64),('qkv_scale.hex','w_scale',64)]:
    e=support['saved_products'][key]
    check('saved_bytes:'+name,decode(name,width)==verify(root/e['path'],e['sha256'],e['bytes']))
e=support['full_norm']
check('full_norm_bytes',decode('norm_s128.hex',4)==verify(root/e['path'],e['sha256'],e['bytes']))
old=next(base.glob('AT343_*'))/'fixture'
for name in ['model_identity.hex','expected_aux_header.hex','raw_s128.hex','norm_s128.hex','gamma.hex']:
    check('same_AT343_fixture:'+name,(fixture/name).read_bytes()==(old/name).read_bytes())
for n in [356,357,358,362,363]:
    for f in (at[n]/'fixture').iterdir():
        if f.is_file() and (fixture/f.name).exists():
            check(f'same_actual_fixture:{n}:{f.name}',f.read_bytes()==(fixture/f.name).read_bytes())

tb=(at[364]/'frozen/laya_ln128_wprep_q16_chain_tb.sv').read_text()
check('real_service_instances',tb.count('laya_source_norm_service_v1 dut')==1 and tb.count('laya_w_prep_service_v1 dut')==1)
check('no_force_or_norm_prefill','force ' not in tb and not re.search(r'\$readmemh\([^;]*,norm_mem\)',tb))
check('real_STATE1_memory_return','state1_rdata[32*lane+:32]=norm_mem[' in tb and '<=m_axi_wdata[2][lane*32+:32]' in tb)
check('norm_W_checker_and_rescan','STAGED_LN_NORM_GOLD' in tb and 'CHAIN_NORM_CHANGED' in tb and '131072' in tb)
check('gold_only_first_four','for(int r=0;r<4;r++)' in tb and 'CHAIN_Q_GOLD' in tb and 'CHAIN_SCALE_GOLD' in tb)
check('observed_snapshot_is_bank_not_leaf','q_observed[w]=dut.bank_service.final_bank[w%8][w/8];' in tb)
check('Q_input_only_counted','q_input_count<=q_input_count+1;' in tb and 'dut.bank_service.ln_x_bits' not in tb)
check('publication_outputs_are_constants',all(x in tb for x in ["assign done_valid=1'b0;","assign tensor_final_valid=1'b0;","assign tensor_raw_valid=1'b0;"]))
check('normal_chain_counters',all(x in tb for x in ['q_input_count!=16384','q_rsp_count!=512','q_half_count!=512','q_scale_count!=256','q_row_seen!=16','state1_r_count!=1024','w_peer.dut.load_scale_checks!=98304']))
log=(at[364]/'guard_rtl_full_chain/driver.log').read_text()
check('unique_success_markers',log.count('CHAIN_LN128_PASS')==1 and log.count('CHAIN_A16_PASS')==1)
local=(at[356]/'frozen/laya_w_prep_service_tb.sv').read_text()
check('W_class_coverage','W_PREP_BUS_CLASS' in local and 'W_PREP_SCALE_CLASS' in local and 'W_PREP_SUCCESS_CLASS' in local)
check('W_error_status16_not_asserted', 'wp_done_check_status!=7' not in local and 'wp_done_check_status!=6' not in local)
check('W_actual_error_stimuli',"beat[p]==24575" in local and "rdata[p][15:0]=16'h7c00" in local)

def elapsed(n,g):
    return next(Decimal(e['elapsed_seconds']) for e in guards if e['attempt']==n and e['guard']==g)
cost_reported=Decimal('2.5')*(8*elapsed(357,'guard_rtl_ln16')+elapsed(356,'guard_rtl_success')+elapsed(362,'guard_rtl_q16'))
cost_same_hierarchy=Decimal('2.5')*(8*elapsed(363,'guard_rtl_pilot16')+elapsed(356,'guard_rtl_success')+elapsed(362,'guard_rtl_q16'))
check('reported_gate_arithmetic',cost_reported==Decimal('825.6394895212724575'))
check('same_combination_gate_also_passes',cost_same_hierarchy<=1440)
pilot=next(e for e in guards if e['attempt']==363 and e['guard']=='guard_rtl_pilot16')
full=next(e for e in guards if e['attempt']==363 and e['guard']=='guard_rtl_full_chain')
check('real_combination_pilot_precedes_full',pilot['finished_at']<full['plan_at'])
used_before=sum((Decimal(e['elapsed_seconds']) for e in guards if e['kind']=='rtl' and e['finished_at']<full['plan_at']),Decimal(0))
check('remaining_before_full_ge_1800',Decimal(3600)-used_before>=1800)
result={'scope':'FROZEN_SCOPED_INDEPENDENT_CHAIN_MILESTONE_NOT_REV21_CLOSEOUT','check_count':len(checks),'checks':checks,'failures':[x for x in checks if not x['pass']],'file_counts':counts,'policy_samples':policies,'guards':guards,'identities':identities,'totals':{k:str(v) for k,v in sums.items()},'remaining':{'static':str(1800-sums['static']),'rtl':str(3600-sums['rtl'])},'gate':{'reported_mixed_hierarchy_estimate':str(cost_reported),'actual_combination_LN16_seconds':str(elapsed(363,'guard_rtl_pilot16')),'same_combination_estimate':str(cost_same_hierarchy),'rtl_used_before_first_full':str(used_before)},'scope_corrections':['r4..15 snapshots compare retired bank to final bank, not leaf output to bank','STATE1 R data checked; all actual Q input words only counted, not compared at Q handshake','request/RAW/FINAL flags are TB constants','W error status16 expected values and full identity blocked holding not all explicitly asserted'],'measurement':{'elapsed_seconds':time.monotonic()-started,'maxrss_kib':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'interactive_reads_cumulative':'UNKNOWN'}}
Path(__file__).with_name('ln128_wprep_q16_rev21_at364_review_20261016.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['check_count','failures','file_counts','policy_samples','totals','remaining','gate']},ensure_ascii=False))
raise SystemExit(bool(result['failures']))
