from pathlib import Path
import argparse,json,re,hashlib,math
from fractions import Fraction
ROOT=Path(__file__).resolve().parents[7];R=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002';BASE=R/'input_baseline';G=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir()
old=(BASE/'laya_m007_g_engine_v1.sv').read_text();new=(G/'rtl/laya_m007_g_engine_v1.sv').read_text()
def ff_lhs(s):
 s=s[s.index(' always_ff @(posedge clk)begin'):];return set(re.findall(r'\b([A-Za-z_]\w*)(?:\[[^;\n]*?\])*\s*<=',s))
added=ff_lhs(new)-ff_lhs(old);assert added=={'done_cancelled','cancel_read_held','cancel_fill_held'},added
assert 'output logic done_cancelled'in new and 'logic cancel_read_held,cancel_fill_held;'in new
assert 'producer_cancel_request_id==rsp_request_id&&producer_cancel_generation==rsp_generation&&producer_cancel_epoch==rsp_epoch'in new
assert 'wire producer_cancel_fire=(producer_cancel_valid===1\'b1)&&producer_cancel_ready;'in new
identity=json.loads((R/'input_identity.json').read_text());readonly={}
for name,digest in identity.items():
 if Path(name).name not in('laya_m007_g_engine_v1.sv','laya_m007_control_workspace_joint_v1.sv'):
  assert sha(ROOT/name)==digest,name;readonly[name]=digest
layout=ROOT/'project/E018_m007_control_workspace_joint/experiment_source/g_control_layout_v1.json';old_delivery=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R001/final_delivery.json';od=json.loads(old_delivery.read_text());assert sha(layout)==od['layout_sha256']
for q in od['budget']['receipts']:assert sha(ROOT/q['path'])==q['receipt_sha256']
total=Fraction(4036)+Fraction(3,8)
r={'schema':'m007-cancel17-state-audit-v1','status':'PASS','new_FF_bits':3,'new_FF':sorted(added),'identity_copy_bits':0,'math_layout_bits':11343,'baseline_joint_bytes':4036,'current_joint_bytes_exact':str(total),'current_joint_bytes':float(total),'current_joint_ceiling_bytes':math.ceil(total),'remaining_raw_bytes':float(4096-total),'remaining_ceiling_bytes':4096-math.ceil(total),'source_sha256':{str((G/'rtl/laya_m007_g_engine_v1.sv').relative_to(ROOT)):sha(G/'rtl/laya_m007_g_engine_v1.sv')},'readonly_input_sources':readonly,'layout_sha256':sha(layout),'R001_all34_receipt_identities_unchanged':True,'scope':'Exact source FF declarations only; no synthesis/physical claim; cancellation functional result separate'}
(a.output/'report.json').write_text(json.dumps(r,indent=2)+'\n');print('CANCEL17_STATE_AUDIT_PASS new_bits3 joint4036.375 ceiling4037 remaining59 identity_copy0')
