`timescale 1ns/1ps
// Validation-only composition: exactly one existing native storage, one frozen
// TANH8 and one external 56mul/16add G pool. The production engine stays pure.
module m007_g_tag_fault_validation_shell(
 input logic clk,rst_n,input int fault_mode,input logic fault_enable,
 output logic bad_tag_injected,bad_fp_tag_injected,real_sfu_return,
 output logic [95:0] actual_sfu_tag,output logic [8:0] actual_fp_rsp_valid,
 output logic [8:0][95:0] actual_fp_rsp_tag,
 input logic bind_valid,output logic bind_ready,output logic resources_bound,
 input logic [63:0] request_id,input logic [31:0] generation,epoch,
 input logic release_valid,output logic release_ready,
 input logic cmd_valid,output logic cmd_ready,
 input logic fill_valid,output logic fill_ready,input logic fill_slot,fill_half,
 input logic [6:0] fill_s,fill_row,input logic [31:0][31:0] fill_data,
 output logic fill_reject_valid,output logic [1:0] fill_reject_code,
 output logic out_valid,input logic out_ready,output logic [7:0][31:0] out_data,out_status,
 output logic [95:0] out_tag,output logic [6:0] out_s,out_row,output logic [1:0] out_chunk,
 output logic done_valid,input logic done_ready,output logic [31:0] done_status,
 output logic [2:0] done_error_rank,output logic [6:0] done_error_row,output logic [11:0] done_error_column,
 output logic [63:0] rsp_request_id,output logic [31:0] rsp_generation,rsp_epoch,
 input logic discard_valid,output logic discard_ready,output logic discard_reject_valid,
 output logic engine_idle,active,needs_discard,protocol_fault,
 output logic [1:0] slot_active,slot_ready,output logic [1:0][6:0] slot_s,
 output logic [1:0][9:0] slot_consumed_vectors,
 output logic [1:0][8:0] slot_math_pending,slot_sfu_debt,output logic [1:0][7:0] slot_fp_debt,
 output logic [7:0][18:0] covered,evaluated,output logic [8:0] sfu_pending,sfu_flight,
 output logic slot_release_fire,slot_release_slot,output logic [6:0] slot_release_s,
 output logic g_wr_valid,g_wr_ready,g_wr_rsp_valid,g_wr_rsp_ready,
 output logic [95:0] g_wr_rsp_tag,
 output logic g_rd_valid,g_rd_ready,g_rd_rsp_valid,g_rd_rsp_ready,
 output logic [95:0] g_rd_tag,g_rd_rsp_tag,
 output logic [8:0] fp_rsp_valid,output logic [8:0][95:0] fp_rsp_tag,
 output logic [8:0][7:0][31:0] fp_rsp_data,fp_rsp_status,
 output logic sfu_rsp_valid,sfu_rsp_ready,output logic [95:0] sfu_rsp_tag,
 output logic [7:0] sfu_rsp_mask,output logic [7:0][31:0] sfu_rsp_data,sfu_rsp_status
);
 logic raw_sv,raw_sr,injected_once,fp_probe;logic [95:0] raw_st,fp_probe_tag;logic [7:0] raw_sm;
 logic [7:0][31:0] raw_sy,raw_ss;
 assign actual_sfu_tag=raw_st;
 assign real_sfu_return=raw_sv&&raw_sr;
 always_comb begin
  bad_tag_injected=fault_enable&&fault_mode<4&&!injected_once&&raw_sv&&raw_st[15:0]==512;
  bad_fp_tag_injected=fault_enable&&fault_mode==4&&!injected_once&&fp_probe&&!actual_fp_rsp_valid[8];
  sfu_rsp_valid=raw_sv;sfu_rsp_tag=raw_st;sfu_rsp_mask=raw_sm;sfu_rsp_data=raw_sy;sfu_rsp_status=raw_ss;
  raw_sr=sfu_rsp_ready&&!bad_tag_injected;
  if(bad_tag_injected)case(fault_mode)
   0:sfu_rsp_tag[95:64]=raw_st[95:64]-1'b1;
   1:sfu_rsp_tag[63:32]=raw_st[63:32]+1'b1;
   2:sfu_rsp_tag[16]=1;
   3:sfu_rsp_tag[15:0]=16'd256; // same ring8 as real seq512
  endcase
  fp_rsp_valid=actual_fp_rsp_valid;fp_rsp_tag=actual_fp_rsp_tag;
  if(bad_fp_tag_injected)begin fp_rsp_valid[8]=1;fp_rsp_tag[8]={fp_probe_tag[95:16],16'd256};end
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin injected_once<=0;fp_probe<=0;fp_probe_tag<=0;end
  else begin
   if(fault_enable&&fault_mode==4&&!injected_once&&engine.fp_req_valid[8]&&engine.fp_req_ready[8]&&engine.fp_req_tag[8][15:0]==0)begin fp_probe<=1;fp_probe_tag<=engine.fp_req_tag[8];end
   if((bad_tag_injected&&sfu_rsp_ready)||bad_fp_tag_injected)begin injected_once<=1;fp_probe<=0;end
  end
 end
 logic storage_bind_ready,lease_ready,lease_active,draining,storage_idle;
 logic actual_bind,resource_owned,pool_reset_n,pool_fault,sfu_fault,sfu_reject;
 logic [1:0] sfu_reject_code;
 logic [63:0] storage_rid,sfu_rid;logic [31:0] storage_gen,storage_epoch,sfu_gen,sfu_epoch;
 logic [2:0] storage_phase,sfu_phase;
 logic [8:0] fp_req_valid,fp_req_ready;logic [8:0][95:0] fp_req_tag;
 logic [8:0][7:0][31:0] fp_req_a,fp_req_b;
 logic sfu_req_valid,sfu_req_ready,tanh_release_ready;
 logic [95:0] sfu_req_tag;logic [7:0] sfu_req_mask;logic [7:0][31:0] sfu_req_x;
 logic [255:0] g_wr_mask,g_rd_mask,g_rd_rsp_mask;
 logic [255:0][5:0] g_wr_addr,g_rd_addr;
 logic [255:0][31:0] g_wr_data,g_rd_rsp_data;logic [95:0] g_wr_tag;
 assign slot_release_fire=engine.pair_release_valid&&engine.pair_release_ready;
 assign slot_release_slot=engine.pair_release_slot;
 assign slot_release_s=engine.pair_release_s;
 assign bind_ready=rst_n&&!resource_owned&&storage_bind_ready&&lease_ready&&engine_idle;
 assign actual_bind=bind_valid&&bind_ready;
 assign resources_bound=resource_owned&&lease_active&&storage_rid==request_id&&storage_gen==generation&&storage_epoch==epoch&&storage_phase==1&&
  sfu_rid==request_id&&sfu_gen==generation&&sfu_epoch==epoch&&sfu_phase==1;
 assign release_ready=resources_bound&&engine_idle&&storage_idle&&sfu_pending==0&&sfu_flight==0&&tanh_release_ready;
 always_ff @(posedge clk)begin
  if(!rst_n)resource_owned<=0;
  else begin if(actual_bind)resource_owned<=1;if(release_valid&&release_ready)resource_owned<=0;end
 end
 laya_m007_g_engine_v1 engine(.clk,.rst_n,.cmd_valid(cmd_valid&&resources_bound),.cmd_ready,
  .cmd_request_id(request_id),.cmd_generation(generation),.cmd_epoch(epoch),
  .storage_owner_valid(resource_owned),.storage_owner_request_id(storage_rid),.storage_owner_generation(storage_gen),.storage_owner_epoch(storage_epoch),.storage_owner_phase(storage_phase),
  .sfu_owner_valid(lease_active),.sfu_owner_request_id(sfu_rid),.sfu_owner_generation(sfu_gen),.sfu_owner_epoch(sfu_epoch),.sfu_owner_phase(sfu_phase),
  .fill_valid,.fill_ready,.fill_request_id(request_id),.fill_generation(generation),.fill_epoch(epoch),.fill_slot,.fill_half,.fill_s,.fill_row,.fill_data,.fill_reject_valid,.fill_reject_code,
  .out_valid,.out_ready,.out_data,.out_status,.out_tag,.out_s,.out_row,.out_chunk,
  .done_valid,.done_ready,.done_status,.done_error_rank,.done_error_row,.done_error_column,.rsp_request_id,.rsp_generation,.rsp_epoch,
  .discard_valid,.discard_ready,.discard_request_id(request_id),.discard_generation(generation),.discard_epoch(epoch),.discard_reject_valid,
  .engine_idle,.active,.needs_discard,.protocol_fault,.slot_active,.slot_ready,.slot_s,.slot_consumed_vectors,.slot_math_pending,.slot_sfu_debt,.slot_fp_debt,.covered,.evaluated,.pool_reset_n,
  .fp_req_valid,.fp_req_ready,.fp_req_tag,.fp_req_a,.fp_req_b,.fp_rsp_valid,.fp_rsp_tag,.fp_rsp_data,.fp_rsp_status,.fp_pool_fault(pool_fault),
  .sfu_req_valid,.sfu_req_ready,.sfu_req_tag,.sfu_req_mask,.sfu_req_x,.sfu_rsp_valid,.sfu_rsp_ready,.sfu_rsp_tag,.sfu_rsp_data,.sfu_rsp_status,.sfu_protocol_fault(sfu_fault),.sfu_reject_valid(sfu_reject),
  .g_wr_valid,.g_wr_ready,.g_wr_mask,.g_wr_addr,.g_wr_data,.g_wr_tag,.g_wr_rsp_valid,.g_wr_rsp_ready,.g_wr_rsp_tag,
  .g_rd_valid,.g_rd_ready,.g_rd_mask,.g_rd_addr,.g_rd_tag,.g_rd_rsp_valid,.g_rd_rsp_ready,.g_rd_rsp_data,.g_rd_rsp_mask,.g_rd_rsp_tag);
 laya_m007_g_vector_pool_v1 pool(.clk,.rst_n(pool_reset_n),.req_valid(fp_req_valid),.req_ready(fp_req_ready),.req_tag(fp_req_tag),.req_a(fp_req_a),.req_b(fp_req_b),
  .rsp_valid(actual_fp_rsp_valid),.rsp_tag(actual_fp_rsp_tag),.rsp_data(fp_rsp_data),.rsp_status(fp_rsp_status),.protocol_fault(pool_fault));
 laya_m007_tanh8_v1 tanh(.clk,.rst_n,.lease_valid(actual_bind),.lease_ready,.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_phase(3'd1),
  .release_valid(release_valid&&resource_owned&&engine_idle&&storage_idle&&sfu_pending==0&&sfu_flight==0),.release_ready(tanh_release_ready),.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(engine_idle&&storage_idle),
  .lease_active,.draining,.rsp_request_id(sfu_rid),.rsp_generation(sfu_gen),.rsp_epoch(sfu_epoch),.rsp_phase(sfu_phase),
  .req_valid(sfu_req_valid),.req_ready(sfu_req_ready),.req_mode(2'd1),.req_request_id(rsp_request_id),.req_generation(rsp_generation),.req_epoch(rsp_epoch),.req_phase(3'd1),.req_tag(sfu_req_tag),.req_mask(sfu_req_mask),.req_x(sfu_req_x),
  .reject_valid(sfu_reject),.reject_code(sfu_reject_code),.rsp_valid(raw_sv),.rsp_ready(raw_sr),.rsp_tag(raw_st),.rsp_mask(raw_sm),.rsp_data(raw_sy),.rsp_status(raw_ss),
  .pending_vectors(sfu_pending),.in_flight_vectors(sfu_flight),.protocol_fault(sfu_fault));
 laya_attention_storage_v1 storage(.clk,.rst_n,.bind_valid(actual_bind),.bind_ready(storage_bind_ready),.bind_request_id(request_id),.bind_generation(generation),.bind_epoch(epoch),.bind_head(4'd0),.bind_phase(3'd1),
  .op_request_id(rsp_request_id),.op_generation(rsp_generation),.op_epoch(rsp_epoch),.op_phase(3'd1),.rsp_request_id(storage_rid),.rsp_generation(storage_gen),.rsp_epoch(storage_epoch),.rsp_head(),.rsp_phase(storage_phase),
  .ps_wr_valid(1'b0),.ps_wr_ready(),.ps_wr_mask('0),.ps_wr_addr('0),.ps_wr_data('0),.ps_wr_tag('0),.ps_wr_rsp_valid(),.ps_wr_rsp_ready(1'b0),.ps_wr_rsp_tag(),
  .ps_rd_valid(1'b0),.ps_rd_ready(),.ps_rd_mask('0),.ps_rd_addr('0),.ps_rd_tag('0),.ps_rd_rsp_valid(),.ps_rd_rsp_ready(1'b0),.ps_rd_rsp_data(),.ps_rd_rsp_mask(),.ps_rd_rsp_tag(),
  .g_wr_valid,.g_wr_ready,.g_wr_mask,.g_wr_addr,.g_wr_data,.g_wr_tag,.g_wr_rsp_valid,.g_wr_rsp_ready,.g_wr_rsp_tag,
  .g_rd_valid,.g_rd_ready,.g_rd_mask,.g_rd_addr,.g_rd_tag,.g_rd_rsp_valid,.g_rd_rsp_ready,.g_rd_rsp_data,.g_rd_rsp_mask,.g_rd_rsp_tag,
  .context_wr_valid(1'b0),.context_wr_ready(),.context_wr_mask('0),.context_wr_addr('0),.context_wr_data('0),.context_wr_tag('0),.context_wr_rsp_valid(),.context_wr_rsp_ready(1'b0),.context_wr_rsp_tag(),
  .context_rd_valid(1'b0),.context_rd_ready(),.context_rd_mask('0),.context_rd_addr('0),.context_rd_tag('0),.context_rd_rsp_valid(),.context_rd_rsp_ready(1'b0),.context_rd_rsp_data(),.context_rd_rsp_mask(),.context_rd_rsp_tag(),.idle(storage_idle));
endmodule
