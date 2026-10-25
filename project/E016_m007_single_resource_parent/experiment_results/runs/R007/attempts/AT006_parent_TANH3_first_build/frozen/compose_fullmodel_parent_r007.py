#!/usr/bin/env python3
"""Independent canonical parent successor; preserves frozen parent_v2."""
from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';S=Path(__file__).parent;R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
p=M/'forward_controller/rtl/laya_m007_single_parent_v2.sv';old=p.read_text();assert hashlib.sha256(p.read_bytes()).hexdigest()=='b6bf3d811dfa2a2036c049714e1fd5dc46fe81f4b7c0c5b12ef165912d7050df'
def sub(a,b):
 global t
 assert a in t,a[:100]
 t=t.replace(a,b)
def assign(n,x):
 global t
 t,c=re.subn(r'assign '+re.escape(n)+r'\s*=[^;]*;',lambda m:'assign '+n+'='+x+';',t);assert c==1,(n,c)
t=old
start=t.index(' input logic clk,rst_n,');end=t.index(' function automatic logic [31:0] tensor_key')
head=t[start:end]
head=re.sub(r' input logic \[1:0\]\[31:0\] cmd_tensor,[\s\S]*? output logic desc_reject_valid,output logic \[3:0\] desc_reject_code,\n','',head)
head=head.replace(' output logic input_reject_valid,output logic [3:0] input_reject_code,\n','')
head=head.replace(' input logic producer_fail_valid,input logic [95:0] producer_fail_tuple,',' input logic producer_fail_valid,input logic[7:0] producer_fail_code,input logic[79:0] producer_fail_detail,')
head=head.replace(' input logic [127:0] bias_model_id,bias_numeric_id,\n','').replace('output logic [5:0] parent_state','output logic [6:0] parent_state')
head=re.sub(r' input logic  coef_cfg_valid,[\s\S]*? output logic \[15:0\] coef_error_col,\n','',head)
head=head.replace(' output logic [6:0] out_row,output logic [15:0] out_col,',' output logic [6:0] out_row,output logic [15:0] out_col,output logic[4:0] out_slot,')
head=head.replace(' input logic cmd_valid,output logic cmd_ready,',''' input logic setup_valid,output logic setup_ready,
 input logic[63:0]setup_request,input logic[31:0]setup_generation,input logic[127:0]setup_build_id,setup_table_key,
 input logic[255:0]setup_model_sha256,setup_graph_sha256,setup_numeric_sha256,setup_layout_sha256,setup_package_build_sha256,
 input logic[63:0]setup_catalog_base,setup_catalog_span,input logic[255:0]setup_records_sha256,input logic[63:0]setup_records_crc,
 input logic invalidate_valid,output logic invalidate_ready,input logic[63:0]invalidate_request,input logic[31:0]invalidate_generation,input logic[127:0]invalidate_build_id,
 input logic model_word_valid,output logic model_word_ready,input logic[63:0]model_word_request,input logic[31:0]model_word_generation,input logic[1:0]model_word_kind,input logic[9:0]model_word_index,input logic[31:0][31:0]model_word_data,
 output logic model_committed,output logic[1:0]done_op,
 output logic reject_valid,output logic[2:0]reject_port,output logic[7:0]reject_code,output logic[95:0]reject_tuple,
 input logic[1:0]cmd_qtype,input logic[15:0][31:0]cmd_marker_rows,input logic[15:0]cmd_marker_mask,input logic[4:0]cmd_candidate_count,
 output logic tail_begin_valid,input logic tail_begin_ready,output logic[63:0]tail_request,output logic[31:0]tail_generation,tail_source_epoch,tail_expected_bytes,
 input logic tail_commit_valid,output logic tail_commit_ready,input logic[63:0]tail_commit_request,input logic[31:0]tail_commit_generation,tail_commit_source_epoch,tail_commit_bytes,input logic[7:0]tail_commit_status,
 output logic tail_abort_valid,input logic tail_abort_ready,input logic tail_owner_idle,
 input logic cmd_valid,output logic cmd_ready,''')
params='''`timescale 1ns/1ps
// D32 canonical full graph. Functional/tool evidence is recorded separately.
module laya_m007_single_parent_v3 #(
 parameter logic[255:0] MODEL_SHA256=256'h6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18,
 parameter logic[255:0] GRAPH_SHA256=256'hf33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9,
 parameter logic[255:0] NUMERIC_SHA256=256'haeb13e7937d29fe6a2c68c407249f294212aa24f4e45fd3862b092795ab066f7,
 parameter logic[255:0] LAYOUT_SHA256=256'h2d848b5fb78236c795cb1d442f088393a3fd6cbd7f8ecf3cf9f984c59b5e0991,
 parameter logic[255:0] PACKAGE_BUILD_SHA256=256'h7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5,
 parameter logic[127:0] TABLE_KEY=128'hb1fdc9ca482c0210982c7245cc50c965,
 parameter logic[1:0]ADDRESS_PROFILE=0,
 parameter logic[3:0][63:0]HBM_PORT_BASE=0,HBM_PORT_SPAN=0,
 parameter logic[255:0]PLATFORM_MANIFEST_SHA256=0
)(
'''
leaf=''' localparam logic[127:0] MODEL_ID=MODEL_SHA256[255:128],GRAPH_ID=GRAPH_SHA256[255:128],NUMERIC_ID=NUMERIC_SHA256[255:128],LAYOUT_ID=LAYOUT_SHA256[255:128];
 localparam logic[127:0]BUILD_ID=128'hcedb4c130303f16da9fa1c605b2cf985;
'''
a=t.index(' endfunction logic  l_prepare_valid;')
t=params+head+leaf+' logic l_prepare_valid;'+t[a+len(' endfunction logic  l_prepare_valid;'):]
t=t.replace('localparam [5:0]','localparam [6:0]').replace('logic [5:0] state','logic [6:0] state')
sub('wire encoder0_mode=kind==3\'d4;','wire encoder0_mode=kind>=5;\n  wire decision_mode=layer_index>=28;')
sub('wire ffn_mode=kind==3\'d3||(encoder0_mode&&tensor_id[0]==32\'d60);','wire ffn_mode=active_epoch_offset==layer_offset(layer_index,4);')
sub('wire ffn_state=','wire ffn_state=state==D1SUB||state==D1RUN||state==D1DRAIN||state==D2SUB||state==D2RUN||state==D2DRAIN||')
a=t.index('// Pure combinational helpers');b=t.index(' assign l_prepare_valid=',a)
t=t[:a]+(S/'fullmodel_parent_control_r007.svpart').read_text()+'\n'+t[b:]
# Physical routing reused; each changed selector is explicit.
assign('l_prepare_kind','decision_mode?2\'d2:(layer_index%3==0?2\'d0:2\'d1)')
assign('l_prepare_layer','decision_mode?layer_index-5\'d28:layer_index')
assign('m_cmd_valid','state==QMSUB||state==WMSUB||state==F_WISUB||state==D1RUN||state==D2SUB')
assign('m_cmd_k','ffn_mode&&wo_phase?(decision_mode?16\'d4096:16\'d2624):16\'d1024')
assign('m_cmd_n','wo_phase?16\'d1024:ffn_mode?(decision_mode?16\'d4096:16\'d5248):16\'d3072')
assign('m_cmd_a_slot','ffn_mode&&wo_phase')
assign('m_cmd_bias','decision_mode')
assign('m_done_ready','state==QMRUN||state==WMRUN||state==D2RUN||state==F_ABORT||state==F_CLOSE&&ffn_close_fire||state==D1DRAIN&&ffn_close_fire')
assign('m_out_ready','state==F_ABORT?1\'b1:state==WMRUN||state==D2RUN?projection_identity_ok&&v2_q_wr_ready:state==D1DRAIN?fc1_finite&&q_in_ready:state==QMRUN?l_qkv_wr_ready:ffn_mode&&!decision_mode?g_fill_ready:1\'b0')
for n in ['m_coef_cfg_valid','m_coef_model','m_coef_request','m_coef_tensor','m_coef_generation','m_coef_epoch','m_coef_n','m_coef_wr_valid','m_coef_wr_addr','m_coef_wr_data','m_coef_rsp_ready']:assign(n,"'0")
assign('m_arready','catalog_owns?4\'b0:arready');assign('m_rvalid','catalog_owns?4\'b0:rvalid')
assign('q_cmd_valid','state==QSUB||state==F_NQSUB||state==D1SUB||state==CSUB&&c_start_ready||state==F_GQSUB&&g_cmd_ready')
assign('q_cmd_slot','state==F_GQSUB||state==D1SUB')
assign('q_cmd_k','state==D1SUB?16\'d4096:state==F_GQSUB?16\'d2624:16\'d1024')
assign('q_in_valid','resident_source_phase?resident_source_valid:state==CRUN?c_out_valid:state==D1DRAIN?m_out_valid&&fc1_finite:(state==F_RUN||state==F_CLOSE||state==F_ABORT)&&pack_full&&!q_close_sent')
assign('q_in_data','resident_source_phase?resident_source_data:state==CRUN?c_out_data:state==D1DRAIN?relu_data:pack_data')
assign('q_in_row',"resident_source_phase?{1'b0,resident_source_addr[11:5]}:state==CRUN?c_out_row:state==D1DRAIN?{1'b0,m_out_row}:{1'b0,pack_previous[8:2]}")
assign('q_in_group',"resident_source_phase?{3'b0,resident_source_addr[4:0]}:state==CRUN?c_out_group:state==D1DRAIN?8'(m_out_col>>5):{1'b0,pack_previous[15:9]}")
assign('q_producer_close_valid','(state==QRUN||state==F_NQRUN)&&(inputs_accepted==4096||producer_failure)||state==CRUN&&(c_complete||producer_failure||c_fault)||state==F_CLOSE||state==D1DRAIN&&m_done_valid&&(m_status!=0||pack_seq==16384)||state==F_ABORT&&!q_close_sent&&!q_cmd_ready&&!q_done_valid')
assign('q_producer_close_success','state!=F_ABORT&&!producer_failure&&!c_fault&&!(state==D1DRAIN&&m_status!=0)')
assign('q_done_ready','state==QRUN||state==CRUN||state==F_NQRUN||state==F_QDRAIN||state==F_ABORT')
assign('ws_owner_req_valid','state==F_ARENA||state==F_RETURN||state==E_RA_OWNER||state==E_LN_OWNER||state==E_FF_OWNER||state==E_RF_OWNER||state==E_FINAL_A||state==S_GOWNER||state==P_OWNER||state==N_OWNER||state==T_OWNER||state==C_A0_AR||state==LAYER_NEXT||state==S_ROPE||state==SETUP_ERROR')
assign('g_producer_cancel_valid','state==F_ABORT&&!decision_mode&&g_active&&!g_cancel_sent')
assign('g_fill_valid','ffn_mode&&!decision_mode&&g_active&&state!=F_ABORT&&m_out_valid&&!wo_phase')
# Reset G/Decision counters at each real new FFN island, not only BEGIN.
sub('if(cmd_valid&&cmd_ready)begin pack_seq<=0;', 'if(cmd_valid&&cmd_ready||state==E_FF_LEASE&&v2_scratch_lease_valid&&v2_scratch_lease_ready)begin pack_seq<=0;')
sub('if(g_output_fire&&state!=F_ABORT)begin','if(state==D1DRAIN&&m_out_valid&&m_out_ready)pack_seq<=pack_seq+1\'b1;\n    if(g_output_fire&&state!=F_ABORT)begin')
sub('if(q_in_valid&&q_in_ready&&ffn_mode&&state!=F_NQRUN)pack_full<=0;','if(q_in_valid&&q_in_ready&&ffn_mode&&!decision_mode&&state!=F_NQRUN)pack_full<=0;')
sub('laya_m007_matrix_facade_v1 #(.PROFILE_ENABLE(0)) matrix(','laya_m007_matrix_facade_v2 #(.PROFILE_ENABLE(0),.CANONICAL_MODEL(1),.CANONICAL_MODEL_ID(MODEL_ID[63:0])) matrix(\n .model_committed,.bias_word_valid(bias_word_valid),.bias_word_ready(bias_word_ready),.bias_word_index(model_word_index),.bias_word_data(model_word_data),.transport_idle(m_transport_idle),')
sub('laya_m007_resident_joint_v2 resident(','laya_m007_resident_joint_v3 resident(\n .type_model_committed(model_committed),.type_qtype(qtype),.type_wr_valid(type_word_valid),.type_wr_ready(type_word_ready),.type_wr_index(model_word_index[6:0]),.type_wr_data(model_word_data),.type_wr_commit(type_word_commit),.type_bank_idle(type_bank_idle),.type_reject_valid(type_reject_valid),.h_load_success_valid(h_load_success_valid),')
sub('.coeff_bind_valid(coeff_bind_valid)', '.coeff_bind_valid(coeff_bind_valid&&coeff_offer_window)')
sub('.coeff_bind_ready(coeff_bind_ready)', '.coeff_bind_ready(raw_coeff_bind_ready)')
sub('.coeff_wr_valid(coeff_wr_valid)', '.coeff_wr_valid(coeff_wr_valid&&coeff_offer_window)')
sub('.coeff_wr_ready(coeff_wr_ready)', '.coeff_wr_ready(raw_coeff_wr_ready)')
t=re.sub(r'\n[ \t]*\n(?:[ \t]*\n)+','\n\n',t)
out=M/'forward_controller/rtl/laya_m007_single_parent_v3.sv';out.write_text(t)
(R/'parent_source_preparation.json').write_text(json.dumps({'stage':'SOURCE_WRITTEN_NOT_COMPILED','source':str(out.relative_to(ROOT)),'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'parent_v2_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'D29_dependency':'CANDIDATE_PUBLIC_INTERFACE_475_PENDING_OWNER_BUILD','full_graph':'NOT_RUN','eda_launched':False},indent=2)+'\n')
print('WROTE',len(t.splitlines()),hashlib.sha256(out.read_bytes()).hexdigest())
