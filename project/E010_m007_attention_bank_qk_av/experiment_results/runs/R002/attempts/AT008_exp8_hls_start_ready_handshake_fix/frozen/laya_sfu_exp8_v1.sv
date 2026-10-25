`timescale 1ns/1ps
// One8lane strict EXP service; TANH remains explicitly unsupported. Tag is
// {row[6:0],chunk8[3:0]}, context=row%64; owner bits come from sole row metadata.
module laya_sfu_exp8_v1(
 input logic clk,rst_n,
 input logic lease_valid,output logic lease_ready,input logic[63:0]lease_request_id,
 input logic[31:0]lease_generation,lease_epoch,input logic[3:0]lease_head,input logic[2:0]lease_phase,
 input logic release_valid,output logic release_ready,input logic[2:0]release_phase,input logic[31:0]release_epoch,input logic phase_debt_clear,
 output logic lease_active,draining,output logic[63:0]rsp_request_id,output logic[31:0]rsp_generation,rsp_epoch,output logic[3:0]rsp_head,output logic[2:0]rsp_phase,
 input logic[63:0]context_valid,context_row_hi,
 input logic req_valid,output logic req_ready,input logic[1:0]req_mode,input logic[31:0]req_generation,req_epoch,input logic[2:0]req_phase,
 input logic[10:0]req_tag,input logic[7:0][31:0]req_x,
 output logic reject_valid,output logic[1:0]reject_code,
 output logic rsp_valid,input logic rsp_ready,output logic[10:0]rsp_tag,output logic[7:0][31:0]rsp_data,
 output logic[8:0]pending_vectors,in_flight_vectors,output logic protocol_fault
);
 logic[2:0]held_phase;logic[31:0]held_epoch;logic local_fault,credit_fault,capacity;
 logic[7:0]leaf_ready,leaf_valid,status_valid;logic[7:0][31:0]leaf_result,leaf_status;
 logic legal_domain,legal_context;wire release_match=release_valid&&lease_active&&release_phase==held_phase&&release_epoch==held_epoch;
 wire req_fire=req_valid&&req_ready;
 assign rsp_phase=held_phase;assign rsp_epoch=held_epoch;assign protocol_fault=local_fault||credit_fault;
 assign lease_ready=rst_n&&!lease_active&&pending_vectors==0&&in_flight_vectors==0&&!protocol_fault&&lease_phase==3;
 assign release_ready=rst_n&&lease_active&&pending_vectors==0&&in_flight_vectors==0&&phase_debt_clear&&release_phase==held_phase&&release_epoch==held_epoch&&!protocol_fault;
 always_comb begin
  legal_domain=1;for(int lane=0;lane<8;lane++)if(req_x[lane][30:23]==255||(!req_x[lane][31]&&req_x[lane][30:0]!=0))legal_domain=0;
  legal_context=context_valid[req_tag[9:4]]&&context_row_hi[req_tag[9:4]]==req_tag[10];
  reject_code=0;
  if(req_mode!=0)reject_code=1;
  else if(!legal_domain)reject_code=2;
  else if(!lease_active||req_generation!=rsp_generation||req_epoch!=held_epoch||req_phase!=held_phase||!legal_context)reject_code=3;
  reject_valid=req_valid&&reject_code!=0;
  req_ready=rst_n&&lease_active&&!draining&&!release_match&&!protocol_fault&&capacity&&reject_code==0;
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin lease_active<=0;draining<=0;held_phase<=0;held_epoch<=0;rsp_request_id<=0;rsp_generation<=0;rsp_head<=0;local_fault<=0;end
  else begin
   if(lease_valid&&lease_ready)begin lease_active<=1;draining<=0;held_phase<=lease_phase;held_epoch<=lease_epoch;rsp_request_id<=lease_request_id;rsp_generation<=lease_generation;rsp_head<=lease_head;end
   if(release_match)draining<=1;
   if(release_valid&&release_ready)begin lease_active<=0;draining<=0;end
   if(req_fire&&!(&leaf_ready))local_fault<=1;
   if(leaf_valid!={8{leaf_valid[0]}}||status_valid!=leaf_valid)local_fault<=1;
   if(leaf_valid[0])for(int lane=0;lane<8;lane++)if(leaf_status[lane]!=0)local_fault<=1;
  end
 end
 laya_return_vector_credit_v1 #(.WIDTH(256),.TAG_WIDTH(11),.LATENCY(167),.DEPTH(256))credit(
  .clk,.rst_n,.req_valid(req_fire),.req_ready(capacity),.req_tag,.result_valid(leaf_valid[0]),.result_data(leaf_result),.rsp_valid,.rsp_ready,.rsp_tag,.rsp_data,.pending(pending_vectors),.in_flight(in_flight_vectors),.fault(credit_fault));
 for(genvar lane=0;lane<8;lane++)begin:exp_lane
  attention_exp_leaf leaf(.ap_clk(clk),.ap_rst(!rst_n),.ap_start(req_fire),.ap_done(),.ap_idle(),.ap_ready(leaf_ready[lane]),.x(req_x[lane]),.result(leaf_result[lane]),.result_ap_vld(leaf_valid[lane]),.status(leaf_status[lane]),.status_ap_vld(status_valid[lane]));
 end
endmodule
