#!/usr/bin/env python3
"""Current kind3 source delta and actual elaboration audit; no physical claims."""
import argparse,hashlib,json,math,re
from pathlib import Path
ROOT=None
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);a=p.parse_args();a.build=a.build.resolve();ROOT=next(q for q in a.build.parents if (q/'.research-agent/project.json').exists());f=a.build/'frozen';s=(f/'laya_m007_single_parent_v1.sv').read_text();base=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R005/reports/parent_e354_before_ffn.sv'
def seq_names(t):
 t=re.sub(r'//[^\n]*','',t)
 # Remove nested selects without treating data values as additional state.
 while re.search(r'\[[^\[\]]*\]',t):t=re.sub(r'\[[^\[\]]*\]','',t)
 return set(re.findall(r'\b(\w+)\s*<=',t))
old=seq_names(base.read_text());new=seq_names(s);extra={'pack_seq':16,'pack_full':1,'pack_fault':1,'g_cancel_sent':1,'q_close_sent':1};assert new-old==set(extra)|{'pack_data'},(new-old);assert old-new==set()
for pattern in [r'logic\s*\[15:0\]\s*pack_seq;',r'logic\s*pack_full,pack_fault,g_cancel_sent,q_close_sent;',r'logic\s*\[31:0\]\[31:0\]\s*pack_data;']:assert re.search(pattern,s)
prior=json.loads((ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R003/final_delivery.json').read_text());unchanged={}
for source,digest in prior['current_production_source_sha256'].items():
 q=f/Path(source).name;assert q.exists()and sha(q)==digest,source;unchanged[source]=digest
expected={'laya_attention_resources_v1':'resources','laya_rope_coeff_cache_v1':'coeff','laya_m007_control_workspace_joint_v1':'layer','laya_m007_matrix_facade_v1':'matrix','laya_m007_quant_a_fill_v1':'front','laya_m007_context_quant_adapter_v1':'context_adapter','laya_m007_g_vector_pool_v1':'g_pool','laya_m007_tanh8_v1':'g_tanh'}
for mod,name in expected.items():
 hits=re.findall(r'\b'+mod+r'\s*(?:#\([^;]*?\)\s*)?(\w+)\s*\(',s);assert hits==[name],(mod,hits)
for forbidden in ['laya_m007_matrix_full_v1','laya_m007_matrix_f32_v1','laya_m007_matrix_resources_v1','laya_m007_control_workspace_validation_shell_v1']:assert not re.search(r'\b'+forbidden+r'\s+\w+\s*\(',s)
h=(a.build/'work/hierarchy_scopes.txt').read_text().splitlines();h=set(q.strip()for q in h)
top=json.loads((a.build/'source_manifest.json').read_text())['top']
required=['/m007_ffn_parent_tb/dut/resources','/m007_ffn_parent_tb/dut/resources/fp','/m007_ffn_parent_tb/dut/resources/div','/m007_ffn_parent_tb/dut/layer','/m007_ffn_parent_tb/dut/layer/workspace','/m007_ffn_parent_tb/dut/layer/layer','/m007_ffn_parent_tb/dut/layer/g_engine','/m007_ffn_parent_tb/dut/g_pool','/m007_ffn_parent_tb/dut/g_tanh','/m007_ffn_parent_tb/dut/matrix','/m007_ffn_parent_tb/dut/front']
required=[q.replace('/m007_ffn_parent_tb/','/'+top+'/')for q in required]
# Resource names are read from the actual shared wrapper, then exact instance scopes asserted below.
missing=[q for q in required if q not in h]
if missing:
 print('HIERARCHY_MISSING',missing)
 print('\n'.join(q for q in sorted(h)if q.count('/')<5))
 raise SystemExit(1)
assert not any('/g_math/gen_local_control' in q or '/layer/gen_local_coverage' in q for q in h)
catalog=json.loads((f/'tensor_catalog.json').read_text());keys={q['name']:q['key']for q in catalog['records']};assert keys['mlp_wi.0.weight']==60 and keys['mlp_wo.0.weight']==88
for n,e in [('q_in_request','request_id'),('q_in_generation','generation'),('q_in_epoch','epoch')]:assert 'assign '+n+'='+e+';' in s
exact=4036.375+sum(extra.values())/8
report={'scope':'Exact unchanged E018 R003 joint control plus current parent sequential-declaration delta, actual compiled hierarchy, source connectivity only','status':'PASS','prior_exact_control_bytes':4036.375,'added_control_fields_bits':extra,'added_control_bits':sum(extra.values()),'exact_control_bytes':exact,'ceiling_control_bytes':math.ceil(exact),'capacity_bytes':4096,'ceiling_remaining_bytes':4096-math.ceil(exact),'new_numeric_payload_bytes':128,'unchanged_shared_source_sha256':unchanged,'parent_sha256':sha(f/'laya_m007_single_parent_v1.sv'),'build_manifest_sha256':sha(a.build/'source_manifest.json'),'hierarchy_sha256':sha(a.build/'work/hierarchy_scopes.txt'),'actual_required_scopes':required,'G_and_EXP_SFU_physical_sharing':False,'scope_limits':['No residual/LN/complete Encoder control accepted','Functional elaboration, no physical utilization/timing acceptance']}
(a.build/'source_control_hierarchy_audit.json').write_text(json.dumps(report,indent=2)+'\n');print('M007_FFN_SOURCE_HIERARCHY_AUDIT_PASS '+str(exact)+'B')
