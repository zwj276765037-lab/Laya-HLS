"""Read-only evidence audit; no EDA or numerical reference evaluation."""
import hashlib,json,os,re,subprocess
from decimal import Decimal
from pathlib import Path
R=Path(__file__).resolve().parents[2]
B=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
P=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/reports'
checks=[];ids=[]
def ck(name,ok): checks.append({'name':name,'pass':bool(ok)})
def read(p,want=None):
    b=p.read_bytes();h=hashlib.sha256(b).hexdigest()
    ids.append({'path':str(p.relative_to(R)),'sha256':h,'bytes':len(b)})
    if want: ck('sha:'+str(p.relative_to(R)),h==want)
    return b
ledger=json.loads(read(P/'SM004_rev18_guard_ledger_AT301_AT306_20261015.json'))
ab=json.loads(read(P/'SM004_rev18_ln128_default_vs_O3_cost_20261015.json'))
A={n:next(B.glob(f'AT{n}_*')) for n in range(301,307)};M={};files=0
for n,a in A.items():
    me=next(x for x in ledger['manifests'] if x['attempt']==a.name)
    m=json.loads(read(a/'source_manifest.json',me['sha256']));M[n]=m
    ck(f'AT{n}_manifest_count',len(m['files'])==me['entries_verified']);files+=len(m['files'])
    for k,v in m['files'].items(): read((R if k.startswith('project/') else a)/k,v if isinstance(v,str) else v['sha256'])
ck('756_manifest_entries',files==756==ledger['totals']['manifest_entries_verified'])
sums={'static':Decimal(0),'RTL':Decimal(0)};policy=0;rows=[]
for e in ledger['entries']:
    g=(R/e['guard_result_path']).parent
    r=json.loads(read(g/'guard_result.json'),parse_float=Decimal);p=json.loads(read(g/'guard_plan.json'))
    if (g/'policy_checks.json').exists(): pol=json.loads(read(g/'policy_checks.json'))
    else:
        pol=[]
        ck(str(g.relative_to(B))+':launch_error_no_policy_receipt',r['child_exit_code']==127 and e['policy_samples']==0)
    log=read(g/'driver.log').decode()
    ck(str(g.relative_to(B))+':receipt',r['elapsed_seconds']==Decimal(e['elapsed_seconds']) and r['child_exit_code']==e['child_exit_code'] and r['trigger']==e['trigger'])
    ck(str(g.relative_to(B))+':policy_count',len(pol)==e['policy_samples'])
    for v in pol: ck(str(g.relative_to(B))+':policy:'+str(v['pid']),v['matches'] and v['affinity']==[0,1,2,3] and v['nice']==19 and v['ionice']=='idle' and v['ionice_exit']==0)
    ck(str(g.relative_to(B))+':memory',r['minimum_mem_available_kb']>192*1024**2 and (r['peak_owned_rss_kb'] is None or r['peak_owned_rss_kb']<=p['maximum_owned_rss_kb']))
    for mark in e['markers']: ck(str(g.relative_to(B))+':marker:'+mark,mark in log)
    ck(str(g.relative_to(B))+':fatal_flag',bool(re.search(r'^(?:Fatal:|ERROR:)',log,re.M))==e['log_fatal_or_error'])
    sums[e['class']]+=r['elapsed_seconds'];policy+=len(pol)
    rows.append({'attempt':e['attempt'],'guard':e['guard'],'class':e['class'],'seconds':str(r['elapsed_seconds']),'exit':r['child_exit_code'],'trigger':r['trigger']})
ck('12guards_7static_5rtl',len(rows)==12 and sum(x['class']=='static' for x in rows)==7)
ck('101_policy_samples',policy==101==ledger['totals']['actual_policy_samples'])
for k in sums:
    ck(k+':exact_total',sums[k]==Decimal(ledger['totals'][k+'_seconds']))
    ck(k+':exact_remaining',Decimal(ledger['limits'][k+'_seconds'])-sums[k]==Decimal(ledger['totals'][k+'_remaining_seconds']))
f304=M[304]['files'];f305=M[305]['files'];common=sorted(f304.keys()&f305.keys());frozen_common=[k for k in common if k.startswith('frozen/')]
ck('112_common_entries_107_frozen_5_fixture',len(common)==112 and len(frozen_common)==107 and all(f304[k]['sha256']==f305[k]['sha256'] for k in common))
events=[];walls=[];digests={}
for n,g in [(304,'guard_rtl_diag'),(305,'guard_rtl_diag_o3')]:
    log=(A[n]/g/'driver.log').read_text()
    e=[s for s in log.splitlines() if s.startswith(('LN128_DIAG','STAGED_LN_PROGRESS','STAGED_LN_ROW_RETIRED'))]
    events.append(e)
    digests[n]={str(final):hashlib.sha256(('\n'.join(e)+final).encode()).hexdigest() for final in ['', '\n']}
    w=[json.loads(s) for s in read(A[n]/g/'wall_events.jsonl').decode().splitlines()];walls.append(w)
    ck(f'AT{n}:monotonic_event_receipts',all(a['elapsed_monotonic_seconds']<=b['elapsed_monotonic_seconds'] for a,b in zip(w,w[1:])) and all(x['event'] in e for x in w))
    ck(f'AT{n}:fixed_30000_prefix',e[-1]=='LN128_DIAG_PREFIX_ONLY cycles=30000 retired=2 gammaR=256 rawR=192 norm=2048 B=128')
    ck(f'AT{n}:two_row_cycles',re.findall(r'STAGED_LN_ROW_RETIRED row=(\d+) B=(\d+) sourceR=(\d+) cycle=(\d+)',log)==[('0','64','64','15375'),('1','128','128','29462')])
ck('38_cycle_events_identical',len(events[0])==38 and events[0]==events[1])
ck('machine_ab_event_sha',ab['semantic_events']['ordered_text_sha256'] in digests[304].values())
ck('wall_event_sequences_identical',[x['event'] for x in walls[0]]==[x['event'] for x in walls[1]])
# Source recompile logs and unchanged precompiled dependencies, not database_from labels.
sdb=[]
changed={x+'.sdb' for x in ['laya_lnq_wi_gqdown_row_v1','laya_qkv_scratch_row_v1','laya_qkv_s128_request_v1','laya_staged_ln128_diag_tb']}
for lib in ['work','xil_defaultlib']:
    one=A[304]/'work/xsim.dir'/lib;two=A[305]/'work/xsim.dir'/lib
    for p in sorted(one.glob('*.sdb')):
        if p.name in changed: continue
        ck('unchanged_compiled_dependency:'+lib+'/'+p.name,p.read_bytes()==(two/p.name).read_bytes())
        sdb.append({'library':lib,'file':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
for n,g in [(304,'guard_static'),(305,'guard_static_o3'),(306,'guard_static_o3')]:
    log=(A[n]/g/'driver.log').read_text()
    ck(f'AT{n}:actual_new_core_compile',str(A[n]/'frozen/laya_lnq_wi_gqdown_row_v1.sv') in log and 'Compiling module work.laya_lnq_wi_gqdown_row_v1' in log)
    ck(f'AT{n}:actual_O3_option',('--O3' in log)==(n!=304))
r306=json.loads((A[306]/'guard_rtl_pilot_o3/guard_result.json').read_text())
ck('AT306_COST_STOP_two_rows',r306['child_exit_code']==-9 and r306['trigger']=='timeout' and r306['semantic_final_counters']==[256,192,2048,128])
current={'laya_lnq_wi_gqdown_row_v1.sv':'a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54','laya_qkv_scratch_row_v1.sv':'5c88716f2a9c60f065dab6358c7d9b1d336ab1eaba689f04ae37e31b74158e26','laya_qkv_s128_request_v1.sv':'a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4'}
rtl=R/'project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl'
for n,h in current.items(): read(rtl/n,h)
report={'decision':'D-M004-REV18-REVIEW-01','checks':checks,'check_count':len(checks),'failures':[x for x in checks if not x['pass']],'identities':ids,'manifest_entries':files,'policies':policy,'guards':rows,'totals':{k:str(v) for k,v in sums.items()},'current':current,'AB_common_count_correction':{'reported_frozen':110,'actual_common_total':len(common),'actual_frozen':len(frozen_common),'actual_fixture':len(common)-len(frozen_common),'sha_mismatches':0},'AB_events':events[0],'AB_event_serialization_sha256':digests[304],'AB_wall_events':{'default':walls[0],'O3':walls[1]},'unchanged_compiled_dependencies':sdb,'host_complete_cumulative':'UNKNOWN','scope':'Q16 ownership local closure, one observed default/O3 prefix comparison, LN128 COST_STOP; no full parent/16-row producer acceptance','controller_policy':{'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip()}}
Path(__file__).with_name('lnq_cost_owner_rev18_review_20261015.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['check_count','failures','manifest_entries','policies','totals','AB_event_serialization_sha256']}))
raise SystemExit(bool(report['failures']))
