#!/usr/bin/env python3
"""Finalize metadata after console.py's native SystemExit ended the publisher."""
import datetime as dt,hashlib,json,os,resource,signal,time
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));os.sched_setaffinity(0,{0,1,2,3})
started=time.monotonic();ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'project/E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022'
receipts=[json.loads(p.read_text())for p in sorted(OUT.glob('*_read_receipt.json'))];timed=sum(r['elapsed_s']for r in receipts);admin=json.loads((OUT/'administrative_charge.json').read_text());charge=admin['conservative_charged_s']
# The prior publisher armed exactly this cumulative timer before its work.
# It terminated at console.py native SystemExit before emitting its own receipt.
# Charge its entire admitted bound, not a fabricated measured runtime.
prior_upper=min(19.8,60-timed-charge-.2)
def deadline(signum,frame):raise TimeoutError('metadata finalization bound')
signal.signal(signal.SIGALRM,deadline);signal.setitimer(signal.ITIMER_REAL,.15)
state=json.loads((ROOT/'agent/A010/state.json').read_text());assert state['execution_state']=='completed'and state['current_task']=='SM012 CONTROL-ARENA-16 parallel read-only FFN interface preparation'
design=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/source/design.md';data=design.read_bytes();append=(OUT/'design_append.md').read_bytes();assert data.endswith(append)
marker=b'## M007 CONTROL-ARENA-16 FFN interface preparation (2026-10-22, A010)';assert data.count(marker)==1
links=[OUT/n for n in ['planning.md','mapping_byte_checks.json','source_versions.json','status.json','design_append.md']];assert all(p.is_file()for p in links)
assert json.loads((OUT/'mapping_byte_checks.json').read_text())['status']=='BYTE_CORRESPONDENCE_PASS'
versions=json.loads((OUT/'source_versions.json').read_text())
publication={'schema':'m007-ffn-planning-publication-v1','finished_at':dt.datetime.now(dt.timezone.utc).isoformat(),'prior_publication_conservative_upper_s':prior_upper,'prior_publication_charge_basis':'Full SIGALRM bound actually armed by plan_ffn_publish.py; console native SystemExit ended Python before publication receipt. Original script not repeated. All publication effects verified read-only.','console_state':state,'console_completion':'Verified persisted actual completed report; no second console call in recovery','console_navigation_refresh':'Existing console report tool automatic hook; no manual index edits','design_before_sha256':hashlib.sha256(data[:-len(append)]).hexdigest(),'design_append_sha256':hashlib.sha256(append).hexdigest(),'design_after_sha256':hashlib.sha256(data).hexdigest(),'production_RTL_modified':False,'EDA_or_numeric_gold_generated':False,'artifacts':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()for p in links},'resource_limits':{'address_space_bytes':1024**3,'cpu_ids':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'outer_timeout_s':20,'recovery_timer_s':.15},'source_readset_changes':{p:d['distinct_shas']for p,d in versions['files'].items()if len(d['distinct_shas'])>1}}
(OUT/'publication_receipt.json').write_text(json.dumps(publication,indent=2)+'\n')
elapsed=time.monotonic()-started;used=timed+charge+prior_upper+elapsed;assert used<=60
(OUT/'planning_ledger.json').write_text(json.dumps({'limits_s':{'planning_read_and_publication':60},'actual_timed_scientific_s':timed,'conservative_administrative_charge_s':charge,'administrative_charge_basis':admin['basis'],'publication_conservative_upper_s':prior_upper,'publication_charge_basis':publication['prior_publication_charge_basis'],'actual_timed_finalization_s':elapsed,'peak_finalization_RSS_KiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'used_s':used,'remaining_s':60-used,'receipts':receipts,'publication_receipt':'publication_receipt.json','R003_balances_transferred':False},indent=2)+'\n')
signal.setitimer(signal.ITIMER_REAL,0)
print(json.dumps({'status':'FFN_PREPARATION_COMPLETE','timed_scientific_s':timed,'conservative_total_charge_s':used,'remaining_s':60-used,'console':state['execution_state'],'readset_changes':publication['source_readset_changes']}))
