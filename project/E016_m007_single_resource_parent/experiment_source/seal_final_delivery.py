#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,datetime,re
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'project/E016_m007_single_resource_parent';R=E/'experiment_results/runs/R001';M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller';A=R/'attempts/AT024_final_version_aware_evidence_audit'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while b:=f.read(1024*1024):h.update(b)
 return h.hexdigest()
pub=json.loads((R/'publication_final.json').read_text())
for k,p in [('source',E/'experiment_source/summary.md'),('results',E/'experiment_results/summary.md'),('status',E/'experiment_status/summary.md')]:assert p.read_text().split('\n\n---\nPublished:',1)[0].strip()==pub[k].strip()
recon=json.loads((R/'ledger_reconciliation.json').read_text());ledger=json.loads((R/'budget_ledger.json').read_text());assert recon['used_s']==ledger['used_s'];assert len(recon['attempts'])==24
for x in recon['attempts']:assert sha(ROOT/x['receipt'])==x['sha256']
assert json.loads((ROOT/'agent/A010/state.json').read_text())['execution_state']=='completed'
paths=set(q for q in (E/'experiment_source').iterdir() if q.is_file())
paths.update([E/'experiment_results/summary.md',E/'experiment_status/summary.md',M/'source/design.md',M/'source/results.md',ROOT/'agent/A010/result.md',ROOT/'agent/A010/state.json',ROOT/'agent/A010/status.md'])
paths.update(p for p in (R/'reports').iterdir() if p.is_file())
paths.update([R/n for n in ['final_delivery.md','current_version_evidence.json','ledger_reconciliation.json','budget_ledger.json','publication_final.json','engineering_state_current.json','console_report_current.json']])
paths.update(p for p in A.rglob('*') if p.is_file())
paths.update(p for p in (M/'rtl').glob('laya_m007*.sv'))
paths.update(M/'tb'/n for n in ['m007_parent_run.py','m007_parent_wall_driver.py','m007_parent_guard_v1.py','m007_parent_guard_test.py','m007_single_parent_tb.sv','m007_parent_fault_tb.sv','m007_parent_reset_tb.sv','m007_context_consumer_tb.sv'])
for p in [E/'experiment_source/summary.md',E/'experiment_results/summary.md',M/'source/design.md',M/'source/results.md',R/'final_delivery.md']:
 text=p.read_text()
 if p.parent==M/'source':text=text.split('## M007 E016 SINGLE-PARENT-11 current bounded implementation (2026-10-22)',1)[1]
 for target in re.findall(r'\]\(([^)]+)\)',text):
  if not re.match(r'https?://',target):assert (p.parent/target.split('#')[0]).exists(),(str(p),target)
d={'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Final E016 bounded-delivery publication and AT024 own source/log/guard/receipt seal; earlier3032 artifact inventory remains referenced','self_excluded':True,'prior_evidence_inventory':str((A/'work/file_inventory.json').relative_to(ROOT)),'prior_evidence_inventory_sha256':sha(A/'work/file_inventory.json'),'files':[{'path':str(p.relative_to(ROOT)),'bytes':p.stat().st_size,'sha256':sha(p)} for p in sorted(paths)],'validation':'Published three summary bodies equal publication input (publisher footer retained); all24 receipt hashes/ledger sums reconciled after audit charge; own console completed; final new documentation links resolve','global_parent_complete':False,'owned_tool_child_remaining':False}
(R/'final_delivery_manifest.json').write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
print('E016_FINAL_DELIVERY_SEAL_PASS files='+str(len(d['files']))+' prior_inventory_files=3032 closed_attempts=24')
print(json.dumps(ledger))
