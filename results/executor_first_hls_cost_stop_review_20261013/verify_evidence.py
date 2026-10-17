from pathlib import Path
from datetime import datetime,timezone
import json,hashlib,csv
R=Path(__file__).resolve().parents[2]; D=Path(__file__).resolve().parent
P=R/'project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_01'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def load(p): return json.loads(p.read_text())
def ref(x):
 p=Path(x['path']); return p.is_file() and sha(p)==x['sha256'] and (x.get('bytes') is None or p.stat().st_size==x['bytes'])
receipt=load(P/'receipt.json'); manifest=load(P/'input_manifest.json')
guard=load(P/'guard_hls/guard_result.json'); plan=load(P/'guard_hls/guard_plan.json'); trigger=load(P/'guard_hls/guard_trigger.json')
assert receipt['status']==receipt['hls']['status']=='COST_STOP'
assert receipt['hls']['started'] and receipt['host_run']['started'] is False
assert receipt['hls']['guard']==guard
assert guard['trigger']==trigger['reason']=='semantic_stall' and guard['child_exit_code']==-9
assert plan['semantic_stall_seconds']==120 and trigger['seconds_since_progress']>=120
assert plan['maximum_owned_rss_kb']==24*1024*1024 and plan['maximum_seconds']==1800
assert guard['peak_owned_rss_kb']<plan['maximum_owned_rss_kb'] and guard['minimum_mem_available_kb']>plan['minimum_mem_available_kb']
assert len(receipt['generated_candidates'])==0 and receipt['port_evidence'] is None
assert manifest['source_count']==25 and len(manifest['files'])==90
hp=Path(receipt['host_reference']['host_attempt']); hm=load(hp/'input_manifest.json')
host_files={x['relative']:x for x in hm['files']}
pairs=[]
for x in manifest['files']:
 h=host_files[x['relative']]
 row={'relative':x['relative'],'frozen_sha256':x['frozen']['sha256'],'frozen_matches':ref(x['frozen']),
 'declared_pair_equal':x['frozen']['sha256']==x['original']['sha256'],
 'host_frozen_matches':ref(h['frozen']),'same_host_frozen':h['frozen']['sha256']==x['frozen']['sha256']}
 assert all(row[k] for k in ['frozen_matches','declared_pair_equal','host_frozen_matches','same_host_frozen'])
 pairs.append(row)
refs=[]
for x in [receipt['input_manifest'],receipt['hls']['driver_log'],receipt['host_reference']['input_manifest'],receipt['host_reference']['receipt'],*receipt['generated_artifacts']]:
 ok=ref(x); refs.append({'path':x['path'],'sha256':x['sha256'],'matches':ok}); assert ok,x['path']
policy=load(P/'guard_hls/policy_checks.json')
assert all(x['matches'] and x['affinity']==[0,1,2,3] and x['nice']==19 and x['ionice']=='idle' for x in policy)
samples=list(csv.DictReader((P/'guard_hls/memory_timeline.csv').open()))
semantic=[json.loads(s) for s in (P/'guard_hls/semantic_timeline.jsonl').read_text().splitlines() if s]
report=(P/'work/hls/syn/report/csynth_design_size.rpt').read_text()
assert '| Compile/Link  | 266,124 *' in report and '| Unroll/Inline | pending' in report
log=(P/'guard_hls/driver.log').read_text()
assert 'Elapsed time: 109.28 seconds' in log
snapshot=[
'.research-agent/communications/executor-first-baseline-hls-cost-stop-20261013.json',
'results/executor_minimum_hardware_chain_reply_20261013.md',
'results/executor_first_baseline_program_q_reply_20261013.md',
'agent/A002/state.json','agent/A005/result.md','agent/A006/result.md',
'project/E003_production_chain_closure/experiment_status/summary.md',
'mission/current.md','results/overview.md','results/review_queue.md','results/reviews/SM003.md','agent/A001/result.md']
snapshot += [str((P/x).relative_to(R)) for x in ['receipt.json','input_manifest.json','guard_hls/guard_result.json','guard_hls/guard_trigger.json','guard_hls/guard_plan.json','guard_hls/policy_checks.json','guard_hls/semantic_timeline.jsonl','guard_hls/driver.log','work/hls/syn/report/csynth_design_size.rpt','work/logs/work.steps.log']]
snap=[]
for rel in snapshot:
 b=(R/rel).read_bytes(); out=D/'snapshot'/rel; out.parent.mkdir(parents=True,exist_ok=True); out.write_bytes(b)
 snap.append({'source':rel,'snapshot':str(out.relative_to(R)),'sha256':sha(out),'bytes':len(b)})
obj={'schema':1,'review':'R-SM003-EXECUTOR-FIRST-HLS-COST-STOP-20261013','created_at':datetime.now(timezone.utc).isoformat(),
'verdict':'COST_STOP_CONFIRMED_NO_HARDWARE_PASS','dut_runs_by_reviewer':0,'hardware_root_cause':'not_established; engineering read-only localization ongoing',
'elapsed_seconds':guard['elapsed_seconds'],'peak_owned_rss_kb':guard['peak_owned_rss_kb'],'rss_capture_count':guard['rss_capture_count'],
'memory_csv_rows':len(samples),'memory_csv_fields':list(samples[0]) if samples else [],
'policy_samples':len(policy),'guard_trigger_seconds_since_observed_progress':trigger['seconds_since_progress'],
'semantic_samples':len(semantic),'last_observed_progress':trigger['last_progress_line'],
'source_analysis_elapsed_seconds':109.28,'compile_link_instructions':266124,'unroll_inline':'pending','generated_candidates':0,
'host_reused_not_rerun':True,'host_dynamic_verdict':'Referenced scoped host PASS preserved; no expanded host review in this audit',
'frozen_pairs':pairs,'artifact_and_reference_checks':refs,'snapshots':snap,
'summary_warning':'A002 state and experiment status snapshot predate incoming COST_STOP; do not treat old running-state text as live process evidence'}
p=D/'verification.json'; assert not p.exists(); p.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'frozen_pairs':len(pairs),'verified_artifact_and_references':len(refs),'policy_samples':len(policy),'memory_rows':len(samples),'verification_sha256':sha(p)},ensure_ascii=False))

