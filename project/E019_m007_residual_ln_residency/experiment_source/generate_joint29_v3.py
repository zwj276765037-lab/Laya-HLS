from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[3];SRC=Path(__file__).parent;A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl'
# The new pure joint retains the original physical arena and all A/G/LN consumers.
s=(A/'laya_m007_control_workspace_joint_v2.sv').read_text().replace('laya_m007_control_workspace_joint_v2','laya_m007_control_workspace_joint_v3').replace('laya_m007_resident_vector32_v2','laya_m007_resident_vector32_v3')
type_ports=[('output','','vector_type_rd_valid'),('input','','vector_type_rd_ready'),('output','[11:0]','vector_type_rd_addr'),('input','','vector_type_rsp_valid'),('output','','vector_type_rsp_ready'),('input','[11:0]','vector_type_rsp_addr'),('input','[31:0][31:0]','vector_type_rsp_data')]
anchor=' input logic clk,rst_n,owner_req_valid,';assert anchor in s;s=s.replace(anchor, ''.join(f' {di} logic {dims} {n},\n'for di,dims,n in type_ports)+anchor,1)
anchor='  .external_control_enable(vector_enable),';assert s.count(anchor)==1;s=s.replace(anchor, ''.join('  .'+n.removeprefix('vector_')+'('+n+'),\n'for di,dims,n in type_ports)+anchor)
(A/'laya_m007_control_workspace_joint_v3.sv').write_text(s)
old=(A/'laya_m007_resident_joint_v2.sv').read_text();h=(A/'laya_m007_resident_joint_v2_header.svh').read_text();assert old.startswith(h)
extra=[('input','','type_model_committed'),('input','[1:0]','type_qtype'),('input','','type_wr_valid'),('output','','type_wr_ready'),('input','[6:0]','type_wr_index'),('input','[31:0][31:0]','type_wr_data'),('output','','type_wr_commit'),('output','','type_bank_idle'),('output','','type_reject_valid'),('input','','h_load_success_valid')]
h3=h.replace('laya_m007_resident_joint_v2','laya_m007_resident_joint_v3');assert h3.endswith('\n);\n');h3=h3[:-4]+',\n'+',\n'.join(f' {di} logic {dims} {n}'for di,dims,n in extra)+'\n);\n';(A/'laya_m007_resident_joint_v3_header.svh').write_text(h3)
s=h3+old[len(h):];s=s.replace('laya_m007_control_workspace_joint_v2 joint(', 'laya_m007_control_workspace_joint_v3 joint(\n'+''.join(' .'+n+'('+n+'),\n'for di,dims,n in type_ports),1)
s=s.replace(' parameter bit TANH_FORCE_CORE_CE=0;\n', ' parameter bit TANH_FORCE_CORE_CE=0;\n'+''.join(f' logic {dims} {n};\n'for di,dims,n in type_ports)+' wire type_inference_active;\n',1)
s=s.replace('assign resident_bank_idle=h_bank_idle&&', 'assign resident_bank_idle=type_bank_idle&&!vector_type_rd_valid&&h_bank_idle&&',1)
s=s.replace('assign vector_inputs_ready=resident_inputs_ready&&scratch_owner_active;', 'assign vector_inputs_ready=resident_inputs_ready&&scratch_owner_active&&(vector_start_op!=1||(type_model_committed&&type_qtype<3));',1)
s=s.replace('assign p_source_success_valid=vsource;', 'assign p_source_success_valid=vsource||(h_load_success_valid&&resident_owner_valid&&external_identity&&h_bank_idle&&!raw_h_wr_valid);',1)
s=s.replace('assign p_source_invalidate=h_wr_commit||', 'assign p_source_invalidate=!resident_owner_valid||h_wr_commit||',1)
s=s.replace('.normal_requests_present(a_prepare_valid||a_qkv_wr_valid||a_start_valid||a_result_rd_valid||vector_start_valid||resident_ln_start_valid)', '.normal_requests_present(a_prepare_valid||a_qkv_wr_valid||a_start_valid||a_result_rd_valid||vector_start_valid||resident_ln_start_valid||vector_type_rd_valid||vector_type_rsp_valid)',1)
s=s.replace('endmodule\n', ''' assign type_inference_active=!shared_resources_idle||vector_busy||ln_busy||!a_layer_idle||g_active||vector_start_valid||resident_ln_start_valid||a_prepare_valid||g_cmd_valid;
 laya_m007_type32_v1 type_bank(.clk,.rst_n,.model_committed(type_model_committed),.inference_active(type_inference_active),
  .wr_valid(type_wr_valid),.wr_ready(type_wr_ready),.wr_index(type_wr_index),.wr_data(type_wr_data),.wr_commit(type_wr_commit),
  .rd_valid(vector_type_rd_valid),.rd_ready(vector_type_rd_ready),.rd_qtype(type_qtype),.rd_vector_addr(vector_type_rd_addr),
  .rsp_valid(vector_type_rsp_valid),.rsp_ready(vector_type_rsp_ready),.rsp_vector_addr(vector_type_rsp_addr),.rsp_data(vector_type_rsp_data),
  .bank_idle(type_bank_idle),.reject_valid(type_reject_valid));
endmodule
''',1)
(A/'laya_m007_resident_joint_v3.sv').write_text(s)
p=json.loads((SRC/'resident_joint_v2_public_ports_v1.json').read_text());p['module']='laya_m007_resident_joint_v3';p['stage']='D29_SOURCE_PREPARATION_NOT_COMPILED';p['ports']+=extra;p['new_ports']=extra;p['h_load_success_contract']='Only valid is new; existing resident_access request/generation/epoch must match owner. Parent guarantees4096 finite commits and bank idle; wrapper has no load counter and cannot recognize arbitrary early matching pseudo-events. Owner invalid between requests, publicH commits and VECTOR accepts invalidate the same source_witness.'
(SRC/'resident_joint_v3_public_ports_v1.json').write_text(json.dumps(p,indent=2)+'\n')
print('new v3 public ports',len(p['ports']),'body_sha256',hashlib.sha256(s.encode()).hexdigest())
