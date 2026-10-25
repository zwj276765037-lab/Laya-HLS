#!/usr/bin/env python3
"""Independent Encoder0 v2 integration; frozen v1/source owners are read-only."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
MOD = ROOT / 'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
SOURCE = MOD / 'rtl/laya_m007_single_parent_v1.sv'
DEST = MOD / 'rtl/laya_m007_single_parent_v2.sv'
REPORT = ROOT / 'project/E016_m007_single_resource_parent/experiment_results/runs/R006/reports/parent_generation.json'
PART = ROOT / 'project/E016_m007_single_resource_parent/experiment_source/encoder0_parent_additions_r006.svpart'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    assert sha(SOURCE) == '62cf04f53be966ac3b214dc955fda236efba2dc0cc20b90c539352c96312b86f'
    if DEST.exists():
        assert REPORT.exists() and sha(DEST) == json.loads(REPORT.read_text())['parent_v2_sha256'], 'Preserve unexpected owned-file edits'
    s = SOURCE.read_text()
    def replace(old, new, count=1):
        nonlocal s
        assert s.count(old) >= count, old
        s = s.replace(old, new, count)
    def assign(name, value):
        nonlocal s
        s, n = re.subn(r'\bassign\s+' + name + r'\s*=.*?;', 'assign ' + name + '=' + value + ';', s, count=1)
        assert n, name
    def drop_instance(module, instance):
        nonlocal s
        s, n = re.subn(r'\b' + module + r'\s+' + instance + r'\s*\([\s\S]*?\);', '', s, count=1)
        assert n, (module, instance)
    replace('module laya_m007_single_parent_v1 #(', 'module laya_m007_single_parent_v2 #(')
    replace('input logic [1:0] cmd_kind', 'input logic [2:0] cmd_kind')
    replace('output logic [4:0] parent_state', 'output logic [5:0] parent_state')
    replace(' input logic in_valid,', ''' input logic desc_valid,output logic desc_ready,
 input logic [63:0] desc_request,input logic [31:0] desc_generation,desc_source_epoch,
 input logic [4:0] desc_global_layer,input logic desc_pair_kind,desc_slot,
 input logic [31:0] desc_tensor,input logic [3:0][63:0] desc_base,desc_span,
 output logic desc_reject_valid,output logic [3:0] desc_reject_code,
 input logic in_valid,''')
    replace('localparam [4:0] IDLE=', 'localparam [5:0] IDLE=')
    replace('localparam [4:0] F_ARENA=', 'localparam [5:0] F_ARENA=')
    replace('logic [4:0] state;', 'logic [5:0] state;')
    replace('logic [1:0] kind;', 'logic [2:0] kind;')
    replace('wire ffn_mode=kind==3;', "wire encoder0_mode=kind==3'd4;\n  wire ffn_mode=kind==3'd3||(encoder0_mode&&tensor_id[0]==32'd60);")
    replace('wire ffn_state=state>=20;', 'wire ffn_state=state==F_ARENA||state==F_NQSUB||state==F_NQRUN||state==F_WISUB||state==F_GQSUB||state==F_RUN||state==F_CLOSE||state==F_QDRAIN||state==F_ABORT||state==F_DISCARD||state==F_RELEASE||state==F_RETURN;')
    replace('(state>=QSUB&&state<=QMRUN)', '(state==QSUB||state==QRUN||state==QMSUB||state==QMRUN)')
    replace('cmd_build_id==BUILD_ID', "((cmd_kind<=3&&cmd_build_id==BUILD_ID)||(cmd_kind==4&&cmd_build_id==ENCODER0_BUILD_ID))")
    replace('tensor_key(cmd_kind,cmd_layer,0)', 'tensor_key(encoder0_island_kind(cmd_kind,0),cmd_layer,0)')
    replace('tensor_key(cmd_kind,cmd_layer,1)', 'tensor_key(encoder0_island_kind(cmd_kind,0),cmd_layer,1)')
    replace('(cmd_kind==3&&cmd_layer==0);', "(cmd_kind==3&&cmd_layer==0)||(cmd_kind==4&&cmd_layer==0&&cmd_epoch<=32'hfffffe00);")
    replace('else state<=cmd_kind==3?F_ARENA:PREP;', 'else state<=cmd_kind==4?E_H_LOAD:cmd_kind==3?F_ARENA:PREP;')
    # Sourceepoch stays a register and final DONE echo. Only downstream consumers
    # use the combinational operationepoch; identity comparisons on public H/desc
    # retain the sourceepoch.
    for lhs in ['l_prepare_epoch','l_prepare_cancel_epoch','m_cmd_epoch','q_cmd_epoch','q_in_epoch','g_cmd_epoch','g_producer_cancel_epoch','g_discard_epoch']:
        assign(lhs, 'operation_epoch')
    replace('g_out_tag!={generation,epoch,16\'b0,pack_seq}', 'g_out_tag!={generation,operation_epoch,16\'b0,pack_seq}')
    assign('l_prepare_kind', 'encoder0_island_kind(kind,0)')
    replace('tensor_key(state==IDLE?cmd_kind:kind,', 'tensor_key(encoder0_island_kind(state==IDLE?cmd_kind:kind,0),')
    replace('if(g_producer_cancel_valid&&g_producer_cancel_ready)g_cancel_sent<=1;', 'if(g_producer_cancel_valid&&g_producer_cancel_ready||v2_ln_cancel_valid&&v2_ln_cancel_ready)g_cancel_sent<=1;')
    assign('l_qkv_wr_valid', 'state==QMRUN&&m_out_valid')
    replace('wire legal_input=(state==QRUN||state==F_NQRUN)', 'wire legal_input=(!encoder0_mode&&(state==QRUN||state==F_NQRUN)||encoder0_mode&&state==E_H_LOAD)')
    assign('producer_fail_ready', 'rst_n&&!producer_failed&&producer_fail_request==request_id&&producer_fail_generation==generation&&producer_fail_epoch==epoch&&((!encoder0_mode&&(state==QRUN||state==QMRUN||state==CRUN||state==F_NQRUN))||(encoder0_mode&&state==E_H_LOAD))')
    assign('in_ready', 'legal_input&&(encoder0_mode?v2_h_wr_ready:q_in_ready)')
    original_reject_code = re.search(r'assign input_reject_code=(.*?);', SOURCE.read_text())[1]
    assign('input_reject_code', 'encoder0_mode?(state!=E_H_LOAD?1:in_request!=request_id?2:in_generation!=generation?3:in_epoch!=epoch?4:in_row!={1\'b0,inputs_accepted[11:5]}?5:6):(' + original_reject_code + ')')
    assign('out_valid', 'encoder0_mode?(state==E_EXPORT&&v2_h_rsp_valid):(state==WMRUN&&m_out_valid)')
    assign('out_data', 'encoder0_mode?v2_h_rsp_data:m_out_data')
    assign('out_row', 'encoder0_mode?v2_h_rsp_addr[11:5]:m_out_row')
    assign('out_col', "encoder0_mode?{6'b0,v2_h_rsp_addr[4:0],5'b0}:m_out_col")
    replace('if(in_valid&&in_ready)inputs_accepted<=inputs_accepted+1;', 'if(in_valid&&in_ready||encoder0_mode&&internal_source_fire)inputs_accepted<=inputs_accepted+1;')
    replace('else if(c_complete&&l_layer_idle)state<=WMSUB;', 'else if(c_complete&&l_layer_idle)state<=encoder0_mode?E_WO_LEASE:WMSUB;')
    replace('if(state==DISCWAIT&&l_layer_idle)state<=FINISH;', 'if(state==DISCWAIT&&l_layer_idle)state<=encoder0_mode?E_ABORT:FINISH;')
    replace('if(context_failed)begin if(l_layer_idle)state<=FINISH;', 'if(context_failed)begin if(l_layer_idle)state<=encoder0_mode?E_ABORT:FINISH;')
    replace('state<=ffn_mode?F_RETURN:FINISH;done_status<=matrix_status_map(m_status);', 'state<=encoder0_mode?(m_status!=0?E_ABORT:ffn_mode?F_RETURN:E_WO_POST):ffn_mode?F_RETURN:FINISH;done_status<=matrix_status_map(m_status);')
    replace('if(state==F_RETURN&&ws_a_enable)state<=FINISH;', 'if(state==F_RETURN&&ws_a_enable)state<=encoder0_mode?(done_status==0?E_FF_POST:E_ABORT):FINISH;')
    # Real resident sources feed the original quant/A entry. No 1024bit extra
    # holding register: public H/Q banks already hold their actual responses.
    old_q_valid = re.search(r'assign q_in_valid=(.*?);', s)[1]
    old_q_data = re.search(r'assign q_in_data=(.*?);', s)[1]
    old_q_row = re.search(r'assign q_in_row=(.*?);', s)[1]
    old_q_group = re.search(r'assign q_in_group=(.*?);', s)[1]
    assign('q_in_valid', 'encoder0_mode&&resident_source_phase?resident_source_valid:(' + old_q_valid + ')')
    assign('q_in_data', 'encoder0_mode&&resident_source_phase?resident_source_data:(' + old_q_data + ')')
    assign('q_in_row', "encoder0_mode&&resident_source_phase?{1'b0,resident_source_addr[11:5]}:(" + old_q_row + ')')
    assign('q_in_group', "encoder0_mode&&resident_source_phase?{3'b0,resident_source_addr[4:0]}:(" + old_q_group + ')')
    # FullEncoder0 projection writes replace only WO/Down public output.
    old_ready = re.search(r'assign m_out_ready=(.*?);', s)[1]
    assign('m_out_ready', 'encoder0_mode&&state==WMRUN?(projection_identity_ok&&v2_q_wr_ready):(' + old_ready + ')')
    # Keep physical services single in A007 composition. Remove the old
    # production instances and their now-internal layer/resource feedback.
    drop_instance('laya_m007_control_workspace_joint_v1', 'layer')
    drop_instance('laya_attention_resources_v1', 'resources')
    drop_instance('laya_rope_coeff_cache_v1', 'coeff')
    drop_instance('laya_m007_g_vector_pool_v1', 'g_pool')
    drop_instance('laya_m007_tanh8_v1', 'g_tanh')
    s = re.sub(r'\bassign\s+(?:l_res_\w+|l_cache_\w+|l_rope_wr_\w+|l_rope_reject_\w+|g_storage_owner_\w+|g_sfu_owner_\w+|g_g_\w+|r_res_st_g_\w+)\s*=.*?;', '', s)
    # External service requests only carry the matrix/quant selected bundle.
    # The layer alternative is physically inside the new wrapper.
    s = re.sub(r'\bassign\s+(r_res_\w+)\s*=([^;]*);', lambda m: 'assign '+m[1]+'='+re.sub(r'\bl_res_\w+\b', "'0", m[2])+';', s)
    assign('ws_owner_req_valid', 'state==F_ARENA||state==F_RETURN||state==E_RA_OWNER||state==E_LN_OWNER||state==E_FF_OWNER||state==E_RF_OWNER||state==E_FINAL_A')
    s = re.sub(r'\bassign\s+ws_owner_req_g\s*=.*?;', '', s)
    additions = PART.read_text().split('// === SEQUENTIAL STAGES ===\n')
    assert len(additions) == 2
    for net in ['matrix_owner','front_owner','legal_input']:
        replace('wire '+net+'=', 'assign '+net+'=')
    decl = (MOD/'rtl/laya_m007_encoder0_wrapper_declarations_v2.svh').read_text()
    pure = (MOD/'rtl/laya_m007_encoder0_parent_functions_v2.svh').read_text()
    replace(' wire producer_fail_fire=', '\nwire matrix_owner,front_owner,legal_input;\n'+decl+'\n'+pure+'\n'+additions[0]+'\n wire producer_fail_fire=')
    replace('if(done_valid&&done_ready)state<=IDLE;', additions[1]+'\n    if(done_valid&&done_ready)state<=IDLE;')
    # All in-module fragments are embedded so source closure needs no hidden
    # include lookup path at elaboration.
    replace('endmodule', (MOD/'rtl/laya_m007_encoder0_wrapper_instance_v2.svh').read_text()+'\nendmodule')
    assert 'state>=20' not in s and 'state>=QSUB' not in s
    assert s.count('laya_m007_resident_joint_v2 resident(') == 1
    assert 'laya_attention_resources_v1 resources(' not in s
    DEST.write_text(s)
    report={'schema':'m007-encoder0-parent-generation-v1','parent_v1_sha256':sha(SOURCE),
            'parent_v2_sha256':sha(DEST),'generator_sha256':sha(Path(__file__)),
            'additions_sha256':sha(PART),'status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN',
            'frozen_v1_unchanged':True,'control_census':'PENDING_ACTUAL_COMBINED_DECLARATIONS',
            'eda_launched':False}
    REPORT.write_text(json.dumps(report,indent=2)+'\n')
    print('M007_ENCODER0_PARENT_V2_SOURCE_PREPARED '+json.dumps(report))


if __name__ == '__main__':
    main()
