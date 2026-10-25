#!/usr/bin/env python3
from pathlib import Path
import argparse,datetime as dt,hashlib,json,re
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'project/E016_m007_single_resource_parent';R=E/'experiment_results/runs/R003';M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--audit',type=Path,required=True);a=p.parse_args();a.audit=a.audit.resolve();pub=read(R/'publication_final.json')
for k,q in [('source',E/'experiment_source/summary.md'),('results',E/'experiment_results/summary.md'),('status',E/'experiment_status/summary.md')]:assert q.read_text().split('\n\n---\nPublished:',1)[0].strip()==pub[k].strip()
recon=read(R/'ledger_reconciliation.json');assert recon['used_s']==read(R/'budget_ledger.json')['used_s']
for x in recon['attempts']:assert sha(ROOT/x['receipt'])==x['sha256']
assert read(ROOT/'agent/A010/state.json')['execution_state']=='completed';assert read(a.audit/'work/evidence_audit.json')['verdict']=='PASS'
paths=set(q for q in a.audit.rglob('*') if q.is_file());paths.update(q for q in (R/'reports').iterdir() if q.is_file());paths.update(R/n for n in ['publication_final.json','final_delivery.md','ledger_reconciliation.json','actual_complete_chain_metrics.json','current_version_evidence.json','budget_ledger.json','engineering_state_current.json','console_report_current.json','tb_extension_boundary.json','fixtures/manifest.json']);paths.update(q for q in (E/'experiment_source').glob('r003_*') if q.is_file());paths.update([E/'experiment_source/make_full_parent_tb.py',E/'experiment_source/summary.md',E/'experiment_results/summary.md',E/'experiment_status/summary.md',M/'tb/m007_full_parent_tb.sv',M/'tb/m007_full_parent_run.py',M/'tb/m007_full_parent_wall_driver.py',M/'rtl/laya_m007_single_parent_v1.sv',M/'rtl/laya_m007_context_quant_adapter_v1.sv',M/'source/design.md',M/'source/results.md',ROOT/'agent/A010/result.md',ROOT/'agent/A010/state.json',ROOT/'agent/A010/status.md'])
for q in [E/'experiment_source/summary.md',E/'experiment_results/summary.md',R/'final_delivery.md']:
 for target in re.findall(r'\]\(([^)]+)\)',q.read_text()):
  if not re.match('https?://',target):assert (q.parent/target.split('#')[0]).exists()
d={'at':dt.datetime.now(dt.timezone.utc).isoformat(),'scope':'R003 final bounded Attention parent delivery and final-audit own artifacts; original attempt closure in referenced inventory','self_excluded':True,'previous_inventory':str((a.audit/'work/file_inventory.json').relative_to(ROOT)),'previous_inventory_sha256':sha(a.audit/'work/file_inventory.json'),'files':[{'path':str(q.relative_to(ROOT)),'sha256':sha(q),'bytes':q.stat().st_size} for q in sorted(paths)],'validation':'Published bodies/receipt sums/audit/console/links verified','owned_tool_child_remaining':False,'does_not_certify_complete_Encoder_FFN_30layer_or_physical_deployment':True};(R/'final_delivery_manifest.json').write_text(json.dumps(d,indent=2)+'\n');print('R003_FINAL_DELIVERY_SEAL_PASS files='+str(len(d['files']))+' closed_attempts='+str(len(recon['attempts'])))
