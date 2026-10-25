from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];G=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn'
s=(G/'tb/m007_g_engine_validation_shell.sv').read_text().replace('module m007_g_engine_validation_shell(','''module m007_cancel17_validation_shell(
 input logic hold_wr,hold_rd,hold_ack,hold_bank_rsp,peer_enable,output logic peer_injected,
 input logic producer_cancel_valid,input logic [63:0]producer_cancel_request_id,
 input logic [31:0]producer_cancel_generation,producer_cancel_epoch,
 output logic producer_cancel_ready,producer_cancel_reject_valid,done_cancelled,control_retired,''',1)
s=s.replace(' logic storage_bind_ready,', ' logic raw_wr_ready,raw_rd_ready,raw_ack_valid,raw_bank_rsp_valid;\n logic [8:0][7:0][31:0]raw_fp_status;\n logic storage_bind_ready,',1)
anchor=' assign slot_release_fire='
extra=''' assign g_wr_ready=raw_wr_ready&&!hold_wr;
 assign g_rd_ready=raw_rd_ready&&!hold_rd;
 assign g_wr_rsp_valid=raw_ack_valid&&!hold_ack;
 assign g_rd_rsp_valid=raw_bank_rsp_valid&&!hold_bank_rsp;
 always_comb begin
  fp_rsp_status=raw_fp_status;
  peer_injected=peer_enable&&fp_rsp_valid[8]&&fp_rsp_tag[8][15:0]==511;
  if(peer_injected)fp_rsp_status[8][0]=32'd8;
 end
'''
s=s.replace(anchor,extra+anchor,1)
fragment=''' logic [12287:0]control_q;logic [11342:0]control_next;
 logic control_enable,a_enable,rearm,owner_g,owner_ready,g_private_idle;
 wire request_a=active||done_valid||needs_discard||(release_valid&&release_ready);
 laya_m007_control_workspace_v1 workspace(.clk,.rst_n,.owner_req_valid(1'b1),.owner_req_g(!request_a),.owner_req_ready(owner_ready),
  .a_retired(1'b1),.a_private_idle(1'b1),.g_retired(control_retired),.g_private_idle,.a_next(12288'b0),.g_next(control_next),.state_q(control_q),.a_enable,.g_enable(control_enable),.rearm,.owner_g);
 always @(posedge clk)if(rst_n&&owner_g&&request_a&&(active||done_valid||needs_discard))begin
  if(owner_ready||rearm||!control_enable)$fatal(1,"CANCEL_OWNER_BARRIER");
 end
 laya_m007_g_engine_v1 #(.EXTERNAL_CONTROL(1)) engine(.external_control_enable(control_enable),.external_control_q(control_q[11342:0]),.external_control_next(control_next),.control_retired,.control_private_idle(g_private_idle),
 .producer_cancel_valid,.producer_cancel_ready,.producer_cancel_request_id,.producer_cancel_generation,.producer_cancel_epoch,.producer_cancel_reject_valid,.done_cancelled,'''
s=s.replace(' laya_m007_g_engine_v1 engine(',fragment,1)
# Only the test boundary gates actual storage handshakes. No responses or debt are fabricated.
start=s.index(' laya_attention_storage_v1 storage(');storage=s[start:];s=s[:start]
storage=storage.replace('.g_wr_valid,.g_wr_ready,','.g_wr_valid(g_wr_valid&&!hold_wr),.g_wr_ready(raw_wr_ready),').replace('.g_rd_valid,.g_rd_ready,','.g_rd_valid(g_rd_valid&&!hold_rd),.g_rd_ready(raw_rd_ready),').replace('.g_wr_rsp_valid,.g_wr_rsp_ready,','.g_wr_rsp_valid(raw_ack_valid),.g_wr_rsp_ready(g_wr_rsp_ready&&!hold_ack),').replace('.g_rd_rsp_valid,.g_rd_rsp_ready,','.g_rd_rsp_valid(raw_bank_rsp_valid),.g_rd_rsp_ready(g_rd_rsp_ready&&!hold_bank_rsp),')
s+=storage
# Matching status8 interposer preserves the genuine valid/tag/data.
start=s.index(' laya_m007_g_vector_pool_v1 pool(');end=s.index(' laya_m007_tanh8_v1 tanh(',start);pool=s[start:end].replace('.rsp_status(fp_rsp_status)','.rsp_status(raw_fp_status)');s=s[:start]+pool+s[end:]
(G/'tb/m007_cancel17_validation_shell.sv').write_text(s)
