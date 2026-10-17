"""Bounded controller byte/receipt audit; never runs RTL or numerical gold."""
import hashlib, json, os, re, subprocess
from decimal import Decimal
from pathlib import Path
R=Path(__file__).resolve().parents[2]
B=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
P=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev16_guard_ledger_AT266_AT272_20261015.json'
identities=[]; checks=[]
def ck(name, ok):
    checks.append({'name':name,'pass':bool(ok)})
    assert ok,name
def read(p, expected=None):
    b=p.read_bytes();h=hashlib.sha256(b).hexdigest()
    if expected:ck('sha:'+str(p.relative_to(R)),h==expected)
    identities.append({'path':str(p.relative_to(R)),'sha256':h,'bytes':len(b)})
    return b
ledger=json.loads(read(P));counts={};manifests={};manifest_items=0
for n in range(266,273):
    a=next(B.glob(f'AT{n}_*'));m=json.loads(read(a/'source_manifest.json'))
    counts[a.name]=len(m['files']);manifest_items+=len(m['files']);manifests[a.name]=hashlib.sha256((a/'source_manifest.json').read_bytes()).hexdigest()
    for k,v in m['files'].items():read((a if k.startswith('frozen/') else R)/k,v)
totals={'static':Decimal(0),'rtl':Decimal(0)};policy_total=0;rows=[]
for e in ledger['entries']:
    g=(R/e['guard_result']).parent;r=json.loads(read(g/'guard_result.json'),parse_float=Decimal)
    plan=json.loads(read(g/'guard_plan.json'));policy=json.loads(read(g/'policy_checks.json'));log=read(g/'driver.log').decode()
    ck('entry:'+e['attempt']+'/'+e['guard'],
       Decimal(e['elapsed_seconds'])==r['elapsed_seconds'] and e['child_exit_code']==r['child_exit_code'] and
       e['trigger']==r['trigger'] and e['source_manifest_sha256']==manifests[e['attempt']] and
       e['policy_samples']==len(policy) and e['peak_owned_rss_kib']==r['peak_owned_rss_kb'])
    for v in policy:
        ck('policy:'+str(g.relative_to(B))+':'+str(v['pid']),v['matches'] and v['affinity']==[0,1,2,3] and v['nice']==19 and v['ionice']=='idle' and v['ionice_exit']==0)
    ck('limits:'+str(g.relative_to(B)),r['minimum_mem_available_kb']>192*1024**2 and r['peak_owned_rss_kb']<=plan['maximum_owned_rss_kb'] and r['elapsed_seconds']<Decimal(str(plan['maximum_seconds'])))
    totals[e['class']]+=r['elapsed_seconds'];policy_total+=len(policy)
    fatal=bool(re.search(r'(?im)^\s*(?:Fatal:|ERROR\s*[:\[])',log))
    markers=[line for line in log.splitlines() if re.match(r'^(ATT_(?:ERROR_DRAIN_PASS|TILE_PASS|FINAL_TILE_PASS|STALL_COUNTS)|Fatal:)',line)]
    ck('fatal_flag:'+str(g.relative_to(B)),fatal==e['log_fatal_or_error'])
    rows.append({'attempt':e['attempt'],'guard':e['guard'],'elapsed_seconds_exact':str(r['elapsed_seconds']),
                 'child_exit_code':r['child_exit_code'],'trigger':r['trigger'],'fatal_or_error':fatal,'markers':markers})
ck('21guards_7static_14rtl',len(rows)==21 and sum(e['class']=='static' for e in ledger['entries'])==7)
ck('policy_total231',policy_total==231==ledger['totals']['policy_samples'])
for c in ['static','rtl']:
    ck('total:'+c,totals[c]==Decimal(ledger['totals'][c+'_seconds']))
    ck('remaining:'+c,Decimal(ledger['limits'][c+'_seconds'])-totals[c]==Decimal(ledger['totals'][c+'_remaining_seconds']))
expected={
 ('AT270','guard_berr_recovery'):'ATT_ERROR_DRAIN_PASS mode=2 R=1088 AR=1025 loads=1025 B=64 svc=18691',
 ('AT270','guard_q_page_rerr_recovery'):'ATT_ERROR_DRAIN_PASS mode=4 R=1025 AR=1025 loads=1025 B=0 svc=16625',
 ('AT271','guard_page_stall'):'ATT_TILE_PASS tile=0 R=1088 AR=1026 loads=1025 B=64 svc=18691',
 ('AT272','guard_q_last_rerr'):'ATT_ERROR_DRAIN_PASS mode=5 R=1088 AR=1025 loads=1025 B=0 svc=17633',
 ('AT272','guard_k_first_rerr'):'ATT_ERROR_DRAIN_PASS mode=1 R=1 AR=1 loads=1 B=0 svc=112',
}
for (at,g),mark in expected.items():
    row=next(x for x in rows if x['attempt'].startswith(at) and x['guard']==g)
    ck('scoped_pass:'+at+'/'+g,row['child_exit_code']==0 and row['trigger'] is None and not row['fatal_or_error'] and
       sum(x.startswith(mark) for x in row['markers'])==1 and sum(x.startswith('ATT_FINAL_TILE_PASS tiles=1 ') for x in row['markers'])==1)
for n in [270,271,272]:
    a=next(B.glob(f'AT{n}_*'));ck('current_adapter:'+str(n),hashlib.sha256((a/'frozen/laya_attention_final_tile_adapter_v1.sv').read_bytes()).hexdigest()=='6d59c3903c2f65f473f1816c0ae4548a9afc36210be1939b86320985e5840dec')
current=R/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/laya_attention_final_tile_adapter_v1.sv'
read(current,'6d59c3903c2f65f473f1816c0ae4548a9afc36210be1939b86320985e5840dec')
old=next(B.glob('AT268_*'))/'frozen';new=next(B.glob('AT272_*'))/'frozen'
for name in ['attention_tile_service_prefetch_v1.sv','t4_w_reader_port_v1.sv','tm1tn8_axi512_writer.sv']:
    ck('unchanged_dependency:'+name,(old/name).read_bytes()==(new/name).read_bytes())
prior=json.loads((Path(__file__).with_name('attention_at268_milestone_review_20261015.json')).read_text())
for v in prior['identities']:
    ck('prior_evidence_preserved:'+v['path'],hashlib.sha256((R/v['path']).read_bytes()).hexdigest()==v['sha256'])
policy={'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip()}
ck('controller_policy',policy=={'affinity':[0,1,2,3],'nice':19,'ionice':'idle'})
report={'decision':'D-M004-REV16-CLOSEOUT-01','status':'PASS_SCOPED_SPLIT_IDENTITIES',
        'identities':identities,'checks':checks,'check_count':len(checks),'manifest_counts':counts,'manifest_items':manifest_items,
        'guards':rows,'totals_exact':{c:str(x) for c,x in totals.items()},'actual_policy_samples':policy_total,
        'manual_review':{'production_diff':'Q error exits and error drain->rearm only; no arithmetic changes',
          'error_done':'7/15 held3cycles; no QK on tested Q error; real reader done and writer debt zero precede completion',
          'recovery':'same runtime, no reset, independently checked score/prob1024-output normal tile after errors',
          'transport':'AR/AW/W blocked-valid field assertions; R supply gaps and B response delay hit; R ready-backpressure coverage not counted; B held-valid assertion not present',
          'sentinel':'compact logical att_mem only; no physical BO or adjacent head proof'},
        'scope_limits':['AT268 eight-tile long run belongs to old5a44a3bc','current6d59c390 has normal single tile/recovery, not eight-tile long run','simulated FINAL publication and captured QKV; no upstream128 producer handoff','full16heads/model/Host-HBM/physical timing and resources unverified'],
        'host_complete_cumulative':'UNKNOWN','controller_policy':policy}
Path(__file__).with_name('attention_rev16_closeout_review_20261015.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'checks':len(checks),'manifest_items':manifest_items,'policy_samples':policy_total,'totals':report['totals_exact']}))
