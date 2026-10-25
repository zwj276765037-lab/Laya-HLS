#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,re,datetime as dt
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'project/E016_m007_single_resource_parent';R=E/'experiment_results/runs/R002';M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller';A=R/'attempts/AT005_same_source_flag_comparison_audit'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
pub=read(R/'publication_final.json')
for k,p in [('source',E/'experiment_source/summary.md'),('results',E/'experiment_results/summary.md'),('status',E/'experiment_status/summary.md')]:assert p.read_text().split('\n\n---\nPublished:',1)[0].strip()==pub[k].strip()
recon=read(R/'ledger_reconciliation.json');ledger=read(R/'budget_ledger.json');assert recon['used_s']==ledger['used_s'];assert len(recon['closed_attempts'])==5
for x in recon['closed_attempts']:assert sha(ROOT/x['receipt'])==x['sha256']
assert read(ROOT/'agent/A010/state.json')['execution_state']=='completed';assert read(A/'work/evidence_audit.json')['verdict']=='PASS'
for p in [E/'experiment_source/summary.md',E/'experiment_results/summary.md',R/'final_delivery.md']:
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if not re.match(r'https?://',target):assert (p.parent/target.split('#')[0]).exists(),(str(p),target)
paths=set(p for p in A.rglob('*') if p.is_file())
paths.update([R/n for n in ['publication_final.json','final_delivery.md','ledger_reconciliation.json','phase_comparison.json','diagnostics.json','budget_ledger.json','engineering_state_current.json','console_report_current.json','instrumentation_boundary.json']])
paths.update([E/'experiment_source/summary.md',E/'experiment_results/summary.md',E/'experiment_status/summary.md',M/'tb/m007_parent_debug_cost_run.py',M/'source/design.md',M/'source/results.md',ROOT/'agent/A010/result.md',ROOT/'agent/A010/state.json',ROOT/'agent/A010/status.md'])
paths.update(p for p in (E/'experiment_source').glob('r002_*') if p.is_file())
d={'at':dt.datetime.now(dt.timezone.utc).isoformat(),'scope':'R002 final publication/audit own artifacts; original four attempts covered by634-file inventory and R0013032 archived artifacts rechecked','self_excluded':True,'prior_inventory':str((A/'work/file_inventory.json').relative_to(ROOT)),'prior_inventory_sha256':sha(A/'work/file_inventory.json'),'files':[{'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size} for p in sorted(paths)],'checks':'Three summary bodies match publication input, publisher footer retained; all5 closed receipts and final budget sum reconcile; own console completed; new links resolve','debug_off_observed_improvement':False,'other_flags_or_long_run_admitted':False,'owned_tool_child_remaining':False}
(R/'final_delivery_manifest.json').write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n');print('R002_FINAL_DELIVERY_SEAL_PASS files='+str(len(d['files']))+' outer_attempts=5')
