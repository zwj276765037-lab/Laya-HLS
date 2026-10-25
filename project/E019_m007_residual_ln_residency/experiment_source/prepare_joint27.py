from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[3];SRC=Path(__file__).parent;A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine';EXP=A.parents[2];RUN=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R003'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
RUN.mkdir(parents=True,exist_ok=True)
old=SRC.parent/'experiment_results/runs/R002/source_manifest_final.json';prior=json.loads(old.read_text());body=A/'rtl/laya_m007_resident_joint_v2.sv';s=body.read_text();assert sha(body)==prior['production_body_sha256']
param=' parameter bit TANH_FORCE_CORE_CE=0;\n'
s=s.replace(' laya_m007_tanh8_v1 g_tanh(', ' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(')
header=A/'rtl/laya_m007_resident_joint_v2_header.svh';h=header.read_text();assert s.startswith(h);s=h+param+s[len(h):]
assert hashlib.sha256(s.replace(param,'',1).replace(' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(', ' laya_m007_tanh8_v1 g_tanh(').encode()).hexdigest()==prior['production_body_sha256']
body.write_text(s)
# Maintain the existing generator without regenerating/reformatting unrelated routing.
gen=SRC/'generate_resident_joint_v2.py';t=gen.read_text();assert t.count('s=header\n')==1;t=t.replace('s=header\n',"s=header+' parameter bit TANH_FORCE_CORE_CE=0;\\n'\n");t=t.replace(' laya_m007_tanh8_v1 g_tanh(', ' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(');gen.write_text(t)
ce=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R002/ce26_production_manifest_v1.json';cm=json.loads(ce.read_text())
for n,d in cm['v2_selected_dependencies'].items():assert sha(EXP/n)==d,n
pub=json.loads((SRC/'resident_joint_v2_public_ports_v1.json').read_text())['ports'];assert len(pub)==465
unchanged={n:d for n,d in prior['production_source_sha256'].items()if n!=str(body.relative_to(ROOT))}
for n,d in unchanged.items():assert sha(ROOT/n)==d
manifest={'schema':'m007-joint27-prebuild-dependencies-v1','stage':'SOURCE_WRITTEN_NOT_COMPILED','public_ports':465,'public_header_sha256':sha(header),'body_source':str(body.relative_to(ROOT)),'body_sha256':sha(body),'prior_body_sha256':prior['production_body_sha256'],'prior_body_reconstructed_by_exact_inverse':True,'parameter':'TANH_FORCE_CORE_CE=0 default auto,1 numerical always-enabled control; module body parameter, no new port or FF','TANH_instance_count':1,'new_FF_bits':0,'CE26_manifest':str(ce.relative_to(ROOT)),'CE26_manifest_sha256':sha(ce),'CE_dependencies_experiment_relative':cm['v2_selected_dependencies'],'unchanged_production_source_sha256':unchanged,'parent_new_source_required':[str((EXP/n).relative_to(ROOT))for n in cm['v2_selected_dependencies']if n.endswith('_v2.sv')],'parent_source_selection':'Same465 public ports/default auto; exclude old tanh8_v1/lane_v1 as unused; new v2 core/wrapper use existing fast_leaves_v1/add3_e_v1/div12_r4_v1/return_vector_credit_v1. Keep only one actual TANH8 instance. Parent EDA must coordinate after D27 actual release.'}
save(RUN/'dependency_manifest_prebuild_v1.json',manifest)
print(json.dumps({'body_sha256':sha(body),'public_header_sha256':sha(header),'public_ports':len(pub),'new_dependencies':manifest['parent_new_source_required']},indent=2))
