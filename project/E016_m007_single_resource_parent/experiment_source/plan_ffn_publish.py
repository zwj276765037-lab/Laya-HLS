#!/usr/bin/env python3
"""Publish read-only FFN preparation and actual A010 state; no RTL/EDA/gold."""
import contextlib,datetime as dt,hashlib,io,json,os,resource,runpy,signal,sys,time
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));os.sched_setaffinity(0,{0,1,2,3})
started=time.monotonic();started_at=dt.datetime.now(dt.timezone.utc).isoformat()
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'project/E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022'
receipts=[json.loads(p.read_text())for p in sorted(OUT.glob('*_read_receipt.json'))]
assert not (OUT/'publication_receipt.json').exists(),'Do not overwrite an existing publication receipt'
timed=sum(r['elapsed_s']for r in receipts);admin=json.loads((OUT/'administrative_charge.json').read_text());charge=admin['conservative_charged_s'];remaining=60-timed-charge
assert remaining>1
def deadline(signum,frame):raise TimeoutError('independent planning cumulative budget')
signal.signal(signal.SIGALRM,deadline);signal.setitimer(signal.ITIMER_REAL,min(19.8,remaining-.2))
versions={}
for r in receipts:
 for f in r.get('files',[]):
  d=versions.setdefault(f['path'],{'observations':[]})
  d['observations'].append({'stage':r['stage'],'sha256':f['sha256'],'bytes':f['bytes']})
for d in versions.values():d['distinct_shas']=sorted(set(x['sha256']for x in d['observations']))
sv={'schema':'m007-ffn-planning-source-versions-v1','scope':'Read-only observations are not an atomic implementation freeze or a new validated build','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','desired_model':'gpt-6.1-sol','desired_effort':'xhigh','R003_parent_frozen_sha256':'e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8','E015_validated_ring15_math_sha256':'849917c06995c4208d7b94b530c1071cdf6b4b76b6b0685dd1e17fc19531bb2e','G_live_external_control_validation':'NOT_CLAIMED; A007 owns implementation; old AT146 PASS stays on original identities','read_receipt_timestamp_note':'Helper receipts named started_at use end-of-read capture; elapsed_s is actual monotonic read duration. This publication separately records actual start/end.','files':versions}
(OUT/'source_versions.json').write_text(json.dumps(sv,indent=2)+'\n')
design=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/source/design.md';old=design.read_bytes();append=(OUT/'design_append.md').read_bytes()
assert b'## M007 CONTROL-ARENA-16 FFN interface preparation (2026-10-22, A010)'not in old
with design.open('ab')as f:f.write(append)
new=design.read_bytes();assert new==old+append
links=[OUT/'planning.md',OUT/'mapping_byte_checks.json',OUT/'source_versions.json']
assert all(p.is_file()for p in links)
status={'execution_state':'completed','verdict':'READ_ONLY_MAPPING_AND_INTERFACE_PREPARATION_COMPLETE','applicability':'Exact source observations and frozen original byte data only; no RTL/EDA/new numeric gold or full FFN/Encoder performance result','runtime_id':'/root/m007_weight_supply_engineering','actual_model':'UNKNOWN','actual_effort':'UNKNOWN','blocker':None,'required_successor_gaps':['Identity-qualified G producer cancellation and real partial debt/discard recovery','Parent PS/G bundle routing plus one original G pool/TANH8 integration, independent of EXP physical sharing','Same-input independent original Q8(G)/Down expected data before full-chain numerical signoff','Real saved skip/residual/LN producers and control accounting before complete Encoder integration'],'R003':'completed/frozen; no budget transfer or rerun'}
(OUT/'status.json').write_text(json.dumps(status,indent=2)+'\n')
sys.path.insert(0,'/home/zwj/.codex/skills/research-agent/scripts');sys.argv=['console.py','report','--root',str(ROOT),'--agent','A010','--input',str(OUT/'A010_completed.json')]
log=io.StringIO()
with contextlib.redirect_stdout(log):runpy.run_path('/home/zwj/.codex/skills/research-agent/scripts/console.py',run_name='__main__')
(OUT/'console_completion.log').write_text(log.getvalue())
state=json.loads((ROOT/'agent/A010/state.json').read_text());assert state['execution_state']=='completed';assert state['current_task']=='SM012 CONTROL-ARENA-16 parallel read-only FFN interface preparation'
elapsed=time.monotonic()-started;used=timed+charge+elapsed;assert elapsed<20 and used<=60
signal.setitimer(signal.ITIMER_REAL,0)
publication={'schema':'m007-ffn-planning-publication-v1','started_at':started_at,'finished_at':dt.datetime.now(dt.timezone.utc).isoformat(),'elapsed_s':elapsed,'peak_self_rss_kb':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'cpu_ids':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'address_space_limit_bytes':1024**3,'timeout_s':20,'design_before_sha256':hashlib.sha256(old).hexdigest(),'design_append_sha256':hashlib.sha256(append).hexdigest(),'design_after_sha256':hashlib.sha256(new).hexdigest(),'production_RTL_modified':False,'EDA_or_numeric_gold_generated':False,'console_state':state,'console_navigation_refresh':'Existing console report tool automatic hook; no manual shared-index edits','artifacts':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()for p in links+[OUT/'status.json',OUT/'design_append.md']}}
(OUT/'publication_receipt.json').write_text(json.dumps(publication,indent=2)+'\n')
(OUT/'planning_ledger.json').write_text(json.dumps({'limits_s':{'planning_read_and_publication':60},'actual_timed_scientific_s':timed,'conservative_administrative_charge_s':charge,'administrative_charge_basis':admin['basis'],'actual_timed_publication_console_s':elapsed,'used_s':used,'remaining_s':60-used,'receipts':receipts,'publication_receipt':'publication_receipt.json','R003_balances_transferred':False},indent=2)+'\n')
print('M007_FFN_PREPARATION_PUBLISHED '+json.dumps({'actual_timed_scientific_s':timed,'publication_console_s':elapsed,'charged_total_s':used,'remaining_s':60-used,'peak_RSS_KiB':publication['peak_self_rss_kb'],'console':state['execution_state'],'source_files':len(versions),'readset_changes':{p:d['distinct_shas']for p,d in versions.items()if len(d['distinct_shas'])>1}}))
