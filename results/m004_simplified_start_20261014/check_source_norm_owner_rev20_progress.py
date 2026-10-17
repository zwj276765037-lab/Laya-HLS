"""Bounded controller evidence audit; no RTL execution or numerical oracle."""
import hashlib,json,os,re,subprocess
from pathlib import Path
from decimal import Decimal
R=Path(__file__).resolve().parents[2]
B=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
A={n:next(B.glob(f'AT{n}_*')) for n in [326,327]}
checks=[];identities=[];guards=[];fixtures=[];manifests={}
def ck(name,value):checks.append({'name':name,'pass':bool(value)})
def read(p,want=None):
    data=p.read_bytes();sha=hashlib.sha256(data).hexdigest()
    identities.append({'path':str(p.relative_to(R)),'sha256':sha,'bytes':len(data)})
    if want:ck('sha:'+str(p.relative_to(R)),sha==want)
    return data
frozen=fixture_count=policies=0;sums={'static':Decimal(0),'RTL':Decimal(0)}
for n,a in A.items():
    m=json.loads(read(a/'source_manifest.json'));manifests[n]=m
    for e in m['entries']:
        data=read(a/'frozen'/e['name'],e['sha256']);frozen+=1
        ck(f'AT{n}:bytes:'+e['name'],len(data)==e['bytes'])
    origin=Path(m['fixture_source'])
    for e in m['fixture_entries']:
        actual=a/'fixture'/e['name'];data=read(actual,e['sha256']);prior=read(origin/e['name'])
        ck(f'AT{n}:fixture_binding:'+e['name'],data==prior and len(data)==e['bytes']);fixture_count+=1
        fixtures.append({'actual':str(actual.relative_to(R)),'reference':str((origin/e['name']).relative_to(R))})
    for g in sorted(a.glob('guard*')):
        if not (g/'guard_result.json').exists():continue
        r=json.loads(read(g/'guard_result.json'),parse_float=Decimal)
        p=json.loads(read(g/'guard_plan.json'));pol=json.loads(read(g/'policy_checks.json'));log=read(g/'driver.log').decode()
        kind='static' if g.name=='guard_static' else 'RTL';sums[kind]+=r['elapsed_seconds'];policies+=len(pol)
        ck(f'AT{n}:{g.name}:exit',r['child_exit_code']==0 and r['trigger'] is None)
        ck(f'AT{n}:{g.name}:no_fatal',not re.search(r'^(?:Fatal:|ERROR:)',log,re.M))
        ck(f'AT{n}:{g.name}:memory',r['minimum_mem_available_kb']>192*1024**2 and r['peak_owned_rss_kb']<=p['maximum_owned_rss_kb'])
        for i,x in enumerate(pol):ck(f'AT{n}:{g.name}:policy{i}',x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0)
        guards.append({'attempt':a.name,'guard':g.name,'class':kind,'seconds':str(r['elapsed_seconds']),'policy_samples':len(pol),'exit':r['child_exit_code'],'trigger':r['trigger']})
tb=(A[327]/'frozen/laya_staged_ln128_pilot_tb.sv').read_text()
log=(A[327]/'guard_rtl/driver.log').read_text()
ck('real_S128_request_top','laya_qkv_s128_request_v1 dut(' in tb)
ck('unique_row0_terminal',log.count('STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256')==1)
ck('row0_finish_after_checker',tb.index('STAGED_LN_ROW0_PREFIX_GOLD')<tb.index('STAGED_LN_ROW0_PREFIX_PASS')<tb.index('$finish;',tb.index('STAGED_LN_ROW0_PREFIX_PASS')))
ck('not_full128_pass','STAGED_LN128_REAL_PASS' not in log)
ck('source64_final_asserted','source_r_count!=64' in tb and 'dut.retired_rows==8\'d1' in tb)
ltb=(A[326]/'frozen/laya_shared_q16_service_tb.sv').read_text()
llog=(A[326]/'guard_rtl/driver.log').read_text()
for mark in ['SHARED_Q16_FINAL_RESCAN_PASS words=4352','SHARED_LN_ONLY_VIEW_BAD_TILE_PASS norm=1024 tile127=8 status=7 phase=12','SHARED_BANK_CLIENTS_PASS ps=16 G_x_gate_1R1W=2 QD=1 ADD_1R1W=1','SHARED_Q16_SERVICE_PASS full_rows=16 words=4352 full_rsp=512 partial_abort_discard=1 new_epoch=1']:
    ck('lower_terminal:'+mark,llog.count(mark)==1)
ck('full_check_bad_tile_assertion',all(x in ltb for x in ['staged_ln_done_id!=32\'d200','staged_ln_done_epoch!=32\'d4','staged_ln_done_check_status!=16\'d7','staged_ln_done_detail!=32\'h0710_0005','staged_ln_done_bad64!=64\'hffff_ffff_ffff_ffff']))
build_log=(A[327]/'guard_static/driver.log').read_text()
for name in ['laya_lnq_bank_service_v1','laya_lnq_wi_gqdown_row_v1','laya_source_norm_service_v1','laya_qkv_scratch_row_v1','laya_qkv_s128_request_v1','laya_staged_ln128_pilot_tb']:
    ck('actual_parent_compile:'+name,str(A[327]/'frozen'/f'{name}.sv') in build_log and 'Compiling module work.'+name in build_log)
core=(A[327]/'frozen/laya_lnq_wi_gqdown_row_v1.sv').read_text()
ck('static_risk_source_pattern',all(x in core for x in ['assign done_check_status=exec_mode==3\'d1 ?', '(staged_ln_identity_bad ? 16\'d7 : staged_ln_done_check_status)', 'done_status<=4\'d7;done_phase<=4\'d14;state<=DONE;']))
ck('247_frozen_14_fixture_4guards',frozen==247 and fixture_count==14 and len(guards)==4)
report={'scope':'AT326 lower local full-Check plus AT327 real S128 row0 prefix; upper ownership and independent16/128 remain incomplete',
 'checks':checks,'check_count':len(checks),'failures':[x for x in checks if not x['pass']], 'identities':identities,'frozen_entries':frozen,'fixture_entries':fixture_count,'fixture_bindings':fixtures,
 'guards':guards,'policy_samples':policies,'totals_through_AT327':{k:str(v) for k,v in sums.items()},'remaining_through_AT327':{k:str(Decimal(lim)-sums[k]) for k,lim in [('static',1800),('RTL',3600)]},
 'static_issue':{'id':'REV20-LOCAL-REJECT-CHECK','status':'OPEN_STATIC_NOT_RTL_REPRODUCED','source':str((A[327]/'frozen/laya_lnq_wi_gqdown_row_v1.sv').relative_to(R)),
 'witness':'After a successful staged row is consumed, submit same id/row/epoch with no prep token. Parent locally rejects (done_status7/phase14), no new lower command, identity_bad is false, lower still retains prior status0/detail0. Current mode-only Check mux can return status16=0/detail0 for parent error.',
 'required':'Choose Check source by this command having actually entered/retired the lower service; preserve local reject mapping and held full Check. Reproduce/fix with affected short test within rev20; do not stall independent upper migration.'},
 'host_complete_cumulative':'UNKNOWN','controller_policy':{'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip()}}
Path(__file__).with_name('source_norm_owner_rev20_progress_review_20261016.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['check_count','failures','frozen_entries','fixture_entries','policy_samples','totals_through_AT327','remaining_through_AT327']}))
raise SystemExit(bool(report['failures']))
