"""Controller byte/receipt audit of revision17; does not simulate/evaluate gold."""
import hashlib,json,os,re,struct,subprocess
from decimal import Decimal
from pathlib import Path
R=Path(__file__).resolve().parents[2]
B=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
L=R/'project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev17_guard_ledger_AT273_AT300_20261015.json'
checks=[];ids=[]
def ck(k,v):
 checks.append({'name':k,'pass':bool(v)});assert v,k
def read(p,want=None):
 b=p.read_bytes();h=hashlib.sha256(b).hexdigest()
 if want:ck('sha:'+str(p.relative_to(R)),h==want)
 ids.append({'path':str(p.relative_to(R)),'sha256':h,'bytes':len(b)})
 return b
ledger=json.loads(read(L));attempts={};nfiles=0;version_map={}
for n in range(273,301):
 a=next(B.glob(f'AT{n}_*'));m=json.loads(read(a/'source_manifest.json'));attempts[a.name]=a;nfiles+=len(m['files'])
 version_map[a.name]={}
 for k,v in m['files'].items():
  h=v if isinstance(v,str) else v['sha256'];read((R if k.startswith('project/') else a)/k,h)
  if Path(k).name in ['laya_lnq_row_v1.sv','laya_lnq_wi_gqdown_row_v1.sv','laya_qkv_scratch_row_v1.sv','laya_qkv_s128_request_v1.sv']:version_map[a.name][Path(k).name]=h
ck('1821_manifest_entries_recounted',nfiles==1821)
sums={'static':Decimal(0),'rtl':Decimal(0)};policy_total=0;rows=[]
for e in ledger['entries']:
 g=(R/e['guard_result']).parent;r=json.loads(read(g/'guard_result.json'),parse_float=Decimal);p=json.loads(read(g/'guard_plan.json'));pol=json.loads(read(g/'policy_checks.json'));log=read(g/'driver.log').decode()
 ck('entry:'+e['attempt']+'/'+e['guard'],Decimal(e['elapsed_seconds'])==r['elapsed_seconds'] and e['child_exit_code']==r['child_exit_code'] and e['trigger']==r['trigger'] and e['source_manifest_sha256']==hashlib.sha256((attempts[e['attempt']]/'source_manifest.json').read_bytes()).hexdigest() and len(pol)==e['policy_samples'])
 for v in pol:ck('policy:'+str(g.relative_to(B))+':'+str(v['pid']),v['matches'] and v['affinity']==[0,1,2,3] and v['nice']==19 and v['ionice']=='idle' and v['ionice_exit']==0)
 ck('memory:'+str(g.relative_to(B)),r['minimum_mem_available_kb']>192*1024**2 and r['peak_owned_rss_kb']<=p['maximum_owned_rss_kb'])
 for mark in e['pass_markers']:ck('recorded_marker:'+str(g.relative_to(B))+':'+mark,mark in log)
 sums[e['class']]+=r['elapsed_seconds'];policy_total+=len(pol)
 rows.append({'attempt':e['attempt'],'guard':e['guard'],'elapsed_seconds_exact':str(r['elapsed_seconds']),'exit':r['child_exit_code'],'trigger':r['trigger'],'reported_verdict':e['verdict_from_log'],'pass_markers':e['pass_markers'],'fatal_lines':[x for x in log.splitlines() if re.search(r'^(Fatal:|ERROR:)',x)]})
ck('54guards27static27rtl',len(rows)==54 and sum(e['class']=='static' for e in ledger['entries'])==27)
ck('400_policy_samples',policy_total==400==ledger['totals']['policy_samples'])
for c in sums:
 ck('exact_total:'+c,sums[c]==Decimal(ledger['totals'][c+'_seconds']))
 ck('exact_remaining:'+c,Decimal(ledger['limits'][c+'_seconds'])-sums[c]==Decimal(ledger['totals'][c+'_remaining_seconds']))
at297=next(B.glob('AT297_*'));m=json.loads((at297/'source_manifest.json').read_text())
for name in ['raw','norm']:
 b=b''.join(struct.pack('<I',int(w,16)) for w in (at297/f'fixture/{name}_s128.hex').read_text().split())
 ck('hex_independent_binary:'+name,len(b)==524288 and hashlib.sha256(b).hexdigest()==m['source_binary_sha256'][name])
log=(at297/'guard_rtl_pilot/driver.log').read_text();res=json.loads((at297/'guard_rtl_pilot/guard_result.json').read_text())
retired=re.findall(r'^STAGED_LN_ROW_RETIRED row=(\d+) B=(\d+) sourceR=(\d+) cycle=(\d+)$',log,re.M)
ck('AT297_two_retirements',retired==[('0','64','64','15375'),('1','128','128','29462')])
ck('AT297_total_source192',res['semantic_final_counters']==[256,192,2048,128])
ck('AT297_COST_STOP_no_terminal',res['child_exit_code']==-9 and res['trigger']=='timeout' and 'STAGED_LN128_REAL_PASS' not in log and 'Fatal:' not in log)
latest={'laya_lnq_wi_gqdown_row_v1.sv':'39b3bf4b6ec32e0210b105171d176d11fdc8602ed8cf5b60c774b5f1d2ebaac0','laya_qkv_scratch_row_v1.sv':'5c88716f2a9c60f065dab6358c7d9b1d336ab1eaba689f04ae37e31b74158e26','laya_qkv_s128_request_v1.sv':'a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4','laya_lnq_row_v1.sv':'52cd1070e57d896c1ec828dc1b985b6b01b5c99a6e8b395e4b1dce3f00ad2df8'}
for n,h in latest.items():
 ck('AT297_latest:'+n,version_map[at297.name][n]==h)
 q=R/'project/E002_Laya_HLS/experiment/vivado/module_design'/('layernorm_engine/rtl' if n=='laya_lnq_row_v1.sv' else 'q8_linear_and_restore/tm1tn8_gs32_512/rtl')/n;read(q,h)
# The copied incremental database's actual compilation source is checked,
# rather than interpreting the historical database_from string as the source.
sdb_links=[]
for n,source_attempt in [('laya_lnq_wi_gqdown_row_v1.sdb',290),('laya_qkv_scratch_row_v1.sdb',296)]:
 a=next(B.glob(f'AT{source_attempt}_*'));one=a/'work/xsim.dir/work'/n;two=at297/'work/xsim.dir/work'/n
 ck('incremental_sdb:'+n,one.read_bytes()==two.read_bytes());read(one);read(two);sdb_links.append({'module':n,'compiled_source_attempt':source_attempt})
ck('core_compile_source_in_log','AT290_SM004_rev17_q16_current_core_gate_01/frozen/laya_lnq_wi_gqdown_row_v1.sv' in (at297/'guard_static/driver.log').read_text())
report={'decision':'D-M004-REV17-REVIEW-01','status':'SCOPED_EVIDENCE_ACCEPTED_WITH_COST_STOP_AND_OPEN_Q16_PARTIAL_OWNERSHIP_BUG',
 'identities':ids,'checks':checks,'check_count':len(checks),'manifest_entries':nfiles,'manifest_count_correction':{'reported':ledger['totals']['frozen_manifest_file_entries_verified'],'actual_sum_of_28_manifests':nfiles,'sha_mismatches':0,'initial_audit_exact_count_assertion_failed_and_receipt_preserved':True},'policy_samples':policy_total,'guards':rows,'version_map':version_map,'current_identities':latest,'totals_exact':{c:str(v) for c,v in sums.items()},'incremental_binding':sdb_links,
 'AT297':{'elapsed_seconds':res['elapsed_seconds'],'retired_rows':2,'retirement_cycles':[15375,29462],'gamma_R_total':256,'source_R_total':192,'source_R_of_retired_rows':128,'inflight_row2_source_R':64,'norm_output_words':2048,'OKAY_B':128,'terminal':'COST_STOP_TIMEOUT','full_LN128':'NOT_RUN_TO_COMPLETION'},
 'open_findings':[{'id':'REV17-Q16-PARTIAL-OWNER','scope':'static counterexample; not reproduced in RTL yet','evidence':'With q16_next_row=1 and a_window_ready=0, prep_begin_ready permits prep_kind01; prep_write_index0 overwrites A row0; prep_abort clears prep state but keeps q16_cover; subsequent legitimate rows can publish corrupted window. Legacy/LN commands similarly unguarded while partial A is live.','needed':'Guard partial window ownership before any incompatible prepare write or command; test partial hold/abort/release and next window without full16 numeric replay.'}],
 'manual_scope':'AT290 legal sequential fill only; AT292/294/296 distinct frozen versions/error endpoints; AT298/299 peers only; AT300 current leaf compatibility. No current full128 LN or Q16 parent graph acceptance.',
 'host_complete_cumulative':'UNKNOWN','controller_policy':{'affinity':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':subprocess.check_output(['ionice','-p',str(os.getpid())],text=True).strip()}}
Path(__file__).with_name('staged_lnq_rev17_review_20261015.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'manifest_entries':nfiles,'checks':len(checks),'policy_samples':policy_total,'totals':report['totals_exact'],'AT297':report['AT297']}))
