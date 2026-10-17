"""Controller audit of frozen rev19 evidence; no EDA or reference evaluation."""
import hashlib, json, os, re, subprocess
from decimal import Decimal
from pathlib import Path
R = Path(__file__).resolve().parents[2]
B = R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
P = B.parent/'reports'
A = {n:next(B.glob(f'AT{n}_*')) for n in range(307,326)}
checks=[]; identities=[]; manifests={}; guard_rows=[]; fixture_bindings=[]; db_bindings=[]
def ck(name,value): checks.append({'name':name,'pass':bool(value)})
def read(p,expected=None):
    data=p.read_bytes(); sha=hashlib.sha256(data).hexdigest()
    identities.append({'path':str(p.relative_to(R)),'sha256':sha,'bytes':len(data)})
    if expected is not None: ck('sha:'+str(p.relative_to(R)),sha==expected)
    return data
ledger=json.loads(read(P/'SM004_rev19_guard_ledger_AT307_AT325_20261016.json'))
frozen_count=fixture_count=0
for item in ledger['manifests']:
    a=B/item['attempt']; m=json.loads(read(R/item['path'],item['sha256']))
    manifests[int(a.name[2:5])]=m
    ck(a.name+':frozen_count',len(m['entries'])==item['frozen_entries'])
    for e in m['entries']:
        data=read(a/'frozen'/e['name'],e['sha256'])
        ck(a.name+':bytes:'+e['name'],len(data)==e['bytes']);frozen_count+=1
    for e in m.get('fixture_entries',[]):
        candidates=[d/e['name'] for d in a.glob('fixture*') if d.is_dir() and (d/e['name']).is_file()]
        ck(a.name+':unique_fixture_path:'+e['name'],len(candidates)==1)
        data=read(candidates[0],e['sha256'])
        ck(a.name+':fixture_bytes:'+e['name'],len(data)==e['bytes']);fixture_count+=1
ck('2139_frozen_entries',frozen_count==2139==ledger['totals']['frozen_manifest_entries_verified'])
sums={'static':Decimal(0),'RTL':Decimal(0)};policy_count=0
for e in ledger['entries']:
    g=(R/e['guard_result']).parent
    r=json.loads(read(g/'guard_result.json'),parse_float=Decimal)
    p=json.loads(read(g/'guard_plan.json'))
    log=read(g/'driver.log').decode()
    pol=json.loads(read(g/'policy_checks.json')) if (g/'policy_checks.json').exists() else []
    ck(e['attempt']+':'+e['guard']+':receipt',r['elapsed_seconds']==Decimal(e['elapsed_seconds']) and r['child_exit_code']==e['child_exit_code'] and r['trigger']==e['trigger'])
    ck(e['attempt']+':'+e['guard']+':class',any(Path(x).name=='xsim' for x in p['command'])==(e['class']=='RTL'))
    ck(e['attempt']+':'+e['guard']+':policy_count',len(pol)==e['policy_samples'])
    for j,x in enumerate(pol):
        ck(e['attempt']+':'+e['guard']+':policy'+str(j),x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' and x['ionice_exit']==0)
    if r['peak_owned_rss_kb'] is None:
        ck(e['attempt']+':'+e['guard']+':unsampled_launch_failure',r['child_exit_code']==127 and len(pol)==0)
    else:
        ck(e['attempt']+':'+e['guard']+':memory',r['minimum_mem_available_kb']>192*1024**2 and r['peak_owned_rss_kb']<=p['maximum_owned_rss_kb'])
    fatal=bool(re.search(r'^(?:Fatal:|ERROR:)',log,re.M))
    ck(e['attempt']+':'+e['guard']+':fatal_flag',fatal==e['fatal_or_error_log'])
    sums[e['class']]+=r['elapsed_seconds'];policy_count+=len(pol)
    guard_rows.append({'attempt':e['attempt'],'guard':e['guard'],'class':e['class'],'seconds':str(r['elapsed_seconds']),'exit':r['child_exit_code'],'trigger':r['trigger'],'fatal_or_error':fatal})
ck('38_guards_17static_21RTL',len(guard_rows)==38 and sum(x['class']=='static' for x in guard_rows)==17)
ck('288_policy_samples',policy_count==288==ledger['totals']['actual_policy_samples'])
for k in sums:
    ck(k+':total',sums[k]==Decimal(ledger['totals'][k+'_seconds']))
    ck(k+':remaining',Decimal(ledger['limits'][k+'_seconds'])-sums[k]==Decimal(ledger['totals'][k+'_remaining_seconds']))

# Bind actually read runtime files, including AT323 header omitted from fixture_entries.
for n,names,origin_n,origin_folder in [
    (322,['model_identity.hex','expected_aux_header.hex','raw_s128.hex','norm_s128.hex','gamma.hex'],304,'fixture'),
    (323,['model_identity.hex','expected_aux_header.hex','raw_row0.hex','raw_row1.hex','norm_row0.hex','norm_row1.hex','gamma.hex'],225,'fixture_qkv'),
    (324,['model_identity.hex','norm_row0.hex','norm_row1.hex','raw_row0.hex','gamma.hex','q_row0.hex','q_row1.hex','scale_row0.hex','scale_row1.hex'],225,'fixture_qkv'),
    (325,['model_identity.hex','norm_row0.hex','norm_row1.hex','raw_row0.hex','gamma.hex','q_row0.hex','q_row1.hex','scale_row0.hex','scale_row1.hex'],225,'fixture_qkv')]:
    origin=next(B.glob(f'AT{origin_n}_*'))/origin_folder
    for name in names:
        p=A[n]/'fixture'/name;old=origin/name;data=read(p);prior=read(old)
        ck(f'AT{n}:runtime_input:'+name,data==prior)
        fixture_bindings.append({'actual':str(p.relative_to(R)),'reference':str(old.relative_to(R)),'sha256':hashlib.sha256(data).hexdigest()})

production={
    'laya_lnq_bank_service_v1.sv':'63da9112d2a23583a652537f6ad45a84164eecce138abbb06345df567d08908e',
    'laya_lnq_wi_gqdown_row_v1.sv':'8c799f91e4b436a78090161303efcb9cd84e69cf3f1791c4e6ed3c362e3f4667',
    'laya_source_norm_service_v1.sv':'c6ca8ca70322f4f0218bd3eec08b17c2d6e058071ccfc0e4d77f92551ef0acf6',
    'laya_qkv_scratch_row_v1.sv':'8294dc2f724b16f59937ecd0f885925eadd64295d2fc4db4eb9ec258009a1291',
    'laya_qkv_s128_request_v1.sv':'a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4'}
rtl=R/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl'
for name,sha in production.items():
    read(rtl/name,sha)
    for n in [322,323,324,325]:
        ck(f'AT{n}:production:'+name,next(e for e in manifests[n]['entries'] if e['name']==name)['sha256']==sha)
for old,new,changed in [(320,322,{'laya_lnq_bank_service_v1.sdb','laya_lnq_wi_gqdown_row_v1.sdb','laya_shared_q16_service_tb.sdb','laya_staged_ln_rows_tb.sdb'}),
                        (322,323,set()),(322,324,{'laya_shared_q16_service_tb.sdb'}),(324,325,{'laya_shared_q16_service_tb.sdb'})]:
    for p in sorted((A[old]/'work/xsim.dir/work').glob('*.sdb')):
        if p.name in changed: continue
        q=A[new]/'work/xsim.dir/work'/p.name
        one,two=read(p),read(q);ck(f'AT{old}_AT{new}:compiled:'+p.name,one==two)
        db_bindings.append({'from':old,'to':new,'name':p.name,'sha256':hashlib.sha256(one).hexdigest()})
for name in ['laya_lnq_bank_service_v1.sv','laya_lnq_wi_gqdown_row_v1.sv','laya_shared_q16_service_tb.sv','laya_staged_ln_rows_tb.sv']:
    log=(A[322]/'guard_static/driver.log').read_text()
    ck('AT322:actually_compiled:'+name,str(A[322]/'frozen'/name) in log and 'Compiling module work.'+Path(name).stem in log)
markers={
    (322,'guard_raw_last_rerr'):['STAGED_LN_ERROR_RECOVERY_PASS case=raw_last_rerr bad_status=7 recovery_B=64'],
    (322,'guard_last_b_drain'):['STAGED_LN_STORE_DRAIN_ROW_PASS row=1 B_still=64 norm=2048','STAGED_LN_ERROR_RECOVERY_PASS case=last_b_drain bad_status=7 recovery_B=64'],
    (323,'guard_rtl_row0'):['STAGED_LN_ROW_PASS row=0 B=64 sourceR=64 cycle=15377'],
    (324,'guard_rtl'):['SHARED_Q16_FINAL_RESCAN_PASS words=4352','SHARED_LN_ONLY_VIEW_BAD_TILE_PASS norm=1024 tile127=8 status=7 phase=12','SHARED_Q16_SERVICE_PASS full_rows=16 words=4352 full_rsp=512 partial_abort_discard=1 new_epoch=1'],
    (325,'guard_rtl'):['SHARED_Q16_FINAL_RESCAN_PASS words=4352','SHARED_BANK_CLIENTS_PASS ps=16 G_x_gate_1R1W=2 QD=1 ADD_1R1W=1','SHARED_Q16_SERVICE_PASS full_rows=16 words=4352 full_rsp=512 partial_abort_discard=1 new_epoch=1']}
for (n,g),marks in markers.items():
    log=(A[n]/g/'driver.log').read_text()
    for mark in marks:ck(f'AT{n}:{g}:marker:'+mark,log.count(mark)==1)
    ck(f'AT{n}:{g}:no_fatal',not re.search(r'^(?:Fatal:|ERROR:)',log,re.M))
rows_tb=(A[323]/'frozen/laya_staged_ln_rows_tb.sv').read_text()
err_tb=(A[322]/'frozen/laya_staged_ln_error_tb.sv').read_text()
ck('AT323_row_wrapper_not_request_top','laya_qkv_scratch_row_v1 dut' in rows_tb and 'laya_qkv_s128_request_v1' not in rows_tb)
ck('AT322_error_wrapper_not_request_top','laya_qkv_scratch_row_v1 dut' in err_tb and 'laya_qkv_s128_request_v1' not in err_tb)
ck('AT323_fixed_prefix','run 160 us' in (A[323]/'frozen/run_row0_prefix.tcl').read_text())
upper=(A[322]/'frozen/laya_source_norm_service_v1.sv').read_text()
ck('upper_control_still_external',all(x in upper for x in ['input logic stage_clear','input logic stage_row_retire','input logic stage_store_fault_set','input logic stage_ready_commit']))
core=(A[322]/'frozen/laya_lnq_wi_gqdown_row_v1.sv').read_text()
lower=(A[322]/'frozen/laya_lnq_bank_service_v1.sv').read_text()
ck('single_lower_instance',len(re.findall(r'laya_lnq_bank_service_v1\s+\w+\s*\(',core))==1)
ck('single_bank_and_lnq',len(re.findall(r'logic \[31:0\] final_bank \[0:7\]\[0:655\]',lower))==1 and len(re.findall(r'laya_lnq_row_v1\s+\w+\s*\(',lower))==1)
ck('staged_lower_lifecycle',all(x in lower for x in ['ST_CMD','ST_FEED','ST_VIEW','ST_DONE']) and 'STAGED_PROXY' in core)
report={'decision':'D-M004-REV19-AT325-01','checks':checks,'check_count':len(checks),'failures':[x for x in checks if not x['pass']],
 'identities':identities,'frozen_entries':frozen_count,'declared_fixture_entries_separate':fixture_count,'actual_runtime_fixture_bindings':fixture_bindings,
 'guards':guard_rows,'policy_samples':policy_count,'totals':{k:str(v) for k,v in sums.items()},
 'remaining':{k:ledger['totals'][k+'_remaining_seconds'] for k in sums},'production':production,'compiled_dependency_bindings':db_bindings,
 'scope':{'AT322':'three snapshots: error row-wrapper, local lower Q16, normal row-wrapper; no elaborated S128 request top in these snapshots',
 'AT323':'real row-wrapper+core+services row0 prefix, two-row fixture; TB drives row commands, not one accepted S128 request; no whole-run source counter or full terminal',
 'AT324_AT325':'two-sample Q16 full-window final rescan and lifecycle; saved raw/gamma LN local view; legal fixed bank clients, not full arithmetic paths',
 'errors':'real wrapper RRESP drain/recovery and one post-store-error LN row/discard/recovery, not full16-window priority',
 'upper':'128-loop/source/norm/error ownership incomplete','LN128':'NOT_RUN','full_request':'NOT_RUN'},
 'report_notes':['AT323 expected_aux_header.hex actually used but not declared in its fixture_entries; directly bound here',
                 'AT322/323 parent refers to row-wrapper hierarchy, not elaborated S128 request sequencer top'],
 'host_complete_cumulative':'UNKNOWN','controller_policy':{'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip()}}
Path(__file__).with_name('ln_shared_service_rev19_at325_review_20261016.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['check_count','failures','frozen_entries','declared_fixture_entries_separate','policy_samples','totals','remaining']},ensure_ascii=False))
raise SystemExit(bool(report['failures']))
