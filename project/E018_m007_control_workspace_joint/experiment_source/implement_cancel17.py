from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];MOD=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';BASE=ROOT/'project/E018_m007_control_workspace_joint/experiment_results/runs/R002/input_baseline';G=MOD/'vector_and_ffn';A=MOD/'attention_and_fp_engine'
s=(BASE/'laya_m007_g_engine_v1.sv').read_text()
s=s.replace(' input logic cmd_valid,', ' input logic producer_cancel_valid,output logic producer_cancel_ready,\n input logic [63:0] producer_cancel_request_id,input logic [31:0] producer_cancel_generation,producer_cancel_epoch,\n output logic producer_cancel_reject_valid,\n input logic cmd_valid,',1)
s=s.replace('output logic done_valid,input logic done_ready,', 'output logic done_valid,input logic done_ready,output logic done_cancelled,',1)
s=s.replace(' logic all_covered;', ' logic all_covered;\n logic cancel_read_held,cancel_fill_held;\n wire producer_cancel_identity=producer_cancel_request_id==rsp_request_id&&producer_cancel_generation==rsp_generation&&producer_cancel_epoch==rsp_epoch;\n wire producer_cancel_fire=(producer_cancel_valid===1\'b1)&&producer_cancel_ready;\n wire fill_admit=active&&((!done_cancelled&&!protocol_fault)||cancel_fill_held);\n assign producer_cancel_ready=control_enabled&&active&&!done_cancelled&&!done_valid&&producer_cancel_identity;\n assign producer_cancel_reject_valid=control_enabled&&(producer_cancel_valid===1\'b1)&&!producer_cancel_ready;',1)
s=s.replace('assign fill_ready=active&&!protocol_fault&&pair_fill_ready;', 'assign fill_ready=fill_admit&&pair_fill_ready;')
s=s.replace('fill_valid&&(!active||pair_fill_reject)', 'fill_valid&&(!active||(done_cancelled&&!cancel_fill_held)||pair_fill_reject)')
s=s.replace('assign fill_reject_code=!active?', 'assign fill_reject_code=(!active||(done_cancelled&&!cancel_fill_held))?')
s=s.replace('bank_req_valid=active&&read_index<41984&&!protocol_fault;', 'bank_req_valid=active&&read_index<41984&&((!done_cancelled&&!protocol_fault)||cancel_read_held);')
s=s.replace('.fill_valid(fill_valid&&active&&!protocol_fault)', '.fill_valid(fill_valid&&fill_admit)')
s=s.replace('active<=0;needs_discard<=0;done_valid<=0;', 'active<=0;needs_discard<=0;done_valid<=0;done_cancelled<=0;cancel_read_held<=0;cancel_fill_held<=0;',1)
s=s.replace('if(done_valid&&done_ready)done_valid<=0;', 'if(done_valid&&done_ready)begin done_valid<=0;done_cancelled<=0;end')
s=s.replace('if(cmd_fire)begin active<=1;', 'if(cmd_fire)begin done_cancelled<=0;cancel_read_held<=0;cancel_fill_held<=0;active<=1;')
s=s.replace('   if(bank_req_valid&&bank_req_ready)', '''   // Preserve only external bank requests already published before cancel.
   // Their payload remains supplied by the original stable upstream signals.
   if(cancel_read_held&&g_rd_valid&&g_rd_ready)cancel_read_held<=0;
   if(cancel_fill_held&&g_wr_valid&&g_wr_ready)cancel_fill_held<=0;
   if(producer_cancel_fire)begin
    done_cancelled<=1;
    cancel_read_held<=g_rd_valid&&!g_rd_ready;
    cancel_fill_held<=g_wr_valid&&!g_wr_ready;
   end
   if(bank_req_valid&&bank_req_ready)''',1)
s=s.replace('if(active&&math_idle&&!write_pending&&bank_issued==bank_returned&&\n      ((read_index==41984&&completed_groups==82&&slot_active==0&&all_covered)||protocol_fault))begin', '''if(active&&math_idle&&math_control_retired&&!write_pending&&bank_issued==bank_returned&&
      !out_valid&&!g_wr_valid&&!g_rd_valid&&!g_wr_rsp_valid&&!g_rd_rsp_valid&&!cancel_read_held&&!cancel_fill_held&&!producer_cancel_fire&&
      (done_cancelled||(read_index==41984&&completed_groups==82&&slot_active==0&&all_covered)||protocol_fault))begin''')
s=s.replace('needs_discard<=protocol_fault||first_error;', 'needs_discard<=done_cancelled||protocol_fault||first_error;')
s=s.replace('if(discard_fire)begin needs_discard<=0;', 'if(discard_fire)begin done_cancelled<=0;cancel_read_held<=0;cancel_fill_held<=0;needs_discard<=0;')
(G/'rtl/laya_m007_g_engine_v1.sv').write_text(s)
s=(BASE/'laya_m007_control_workspace_joint_v1.sv').read_text()
s=s.replace(' input logic  g_cmd_valid,', ' input logic g_producer_cancel_valid,output logic g_producer_cancel_ready,\n input logic [63:0]g_producer_cancel_request_id,input logic [31:0]g_producer_cancel_generation,g_producer_cancel_epoch,\n output logic g_producer_cancel_reject_valid,g_done_cancelled,\n input logic  g_cmd_valid,',1)
assert 'g_producer_cancel_valid'in s
s=s.replace('  .cmd_valid(g_cmd_valid),', '  .producer_cancel_valid(g_producer_cancel_valid),.producer_cancel_ready(g_producer_cancel_ready),\n  .producer_cancel_request_id(g_producer_cancel_request_id),.producer_cancel_generation(g_producer_cancel_generation),.producer_cancel_epoch(g_producer_cancel_epoch),\n  .producer_cancel_reject_valid(g_producer_cancel_reject_valid),.done_cancelled(g_done_cancelled),\n  .cmd_valid(g_cmd_valid),',1)
(A/'rtl/laya_m007_control_workspace_joint_v1.sv').write_text(s)
print('CANCEL17_ENGINE_AND_JOINT_IMPLEMENTED new_FF_bits3')
