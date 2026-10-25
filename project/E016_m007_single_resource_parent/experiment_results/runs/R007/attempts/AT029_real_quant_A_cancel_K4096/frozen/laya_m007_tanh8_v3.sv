`timescale 1ns/1ps
// Standalone TANH side of the future shared SFU. One vector reservation and
// exactly eight original-DAG cores; no EXP copy or private G/PS/context banks.
// Mode1/phase1. Numerical errors are held, consumable per-lane status records.
module laya_m007_tanh8_v3 #(parameter bit FORCE_CORE_CE=0)(
 input logic clk,rst_n,
 input logic lease_valid,output logic lease_ready,
 input logic [63:0] lease_request_id,input logic [31:0] lease_generation,lease_epoch,
 input logic [2:0] lease_phase,
 input logic release_valid,output logic release_ready,
 input logic [2:0] release_phase,input logic [31:0] release_epoch,input logic phase_debt_clear,
 output logic lease_active,draining,
 output logic [63:0] rsp_request_id,output logic [31:0] rsp_generation,rsp_epoch,
 output logic [2:0] rsp_phase,
 input logic req_valid,output logic req_ready,input logic [1:0] req_mode,
 input logic [63:0] req_request_id,input logic [31:0] req_generation,req_epoch,
 input logic [2:0] req_phase,input logic [95:0] req_tag,input logic [7:0] req_mask,
 input logic [7:0][31:0] req_x,
 output logic reject_valid,output logic [1:0] reject_code,
 output logic rsp_valid,input logic rsp_ready,output logic [95:0] rsp_tag,
 output logic [7:0] rsp_mask,output logic [7:0][31:0] rsp_data,rsp_status,
 output logic [8:0] pending_vectors,in_flight_vectors,output logic protocol_fault
);
 logic capacity,credit_fault,alignment_fault;
 logic [7:0] core_valid;
 logic [7:0][31:0] core_result,core_status;
 logic [511:0] packed_result,packed_response;
 logic [103:0] response_meta;
 wire release_match=release_valid&&lease_active&&release_phase==rsp_phase&&release_epoch==rsp_epoch;
 wire req_fire=req_valid&&req_ready;
 wire lease_fire=lease_valid&&lease_ready;
 wire [7:0] core_token_empty;
 wire all_token_empty=&core_token_empty;
 wire core_ce=FORCE_CORE_CE||!rst_n||lease_active||lease_fire||req_fire||
  (pending_vectors!=0)||(in_flight_vectors!=0)||!all_token_empty||protocol_fault;
 assign protocol_fault=credit_fault||alignment_fault;
 assign lease_ready=rst_n&&!lease_active&&pending_vectors==0&&in_flight_vectors==0&&!protocol_fault&&lease_phase==1;
 assign release_ready=rst_n&&lease_active&&pending_vectors==0&&in_flight_vectors==0&&phase_debt_clear&&release_phase==rsp_phase&&release_epoch==rsp_epoch&&!protocol_fault;
 assign {rsp_tag,rsp_mask}=response_meta;
 assign {rsp_status,rsp_data}=packed_response;
 assign packed_result={core_status,core_result};
 always_comb begin
  reject_code=0;
  if(req_mode!=1)reject_code=1;
  else if(req_mask==0)reject_code=2;
  else if(!lease_active||req_request_id!=rsp_request_id||req_generation!=rsp_generation||req_epoch!=rsp_epoch||req_phase!=rsp_phase)reject_code=3;
  reject_valid=rst_n&&req_valid&&reject_code!=0;
  req_ready=rst_n&&lease_active&&!draining&&!release_match&&!protocol_fault&&capacity&&reject_code==0;
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   lease_active<=0;draining<=0;rsp_request_id<=0;rsp_generation<=0;rsp_epoch<=0;rsp_phase<=0;alignment_fault<=0;
  end else begin
   if(lease_valid&&lease_ready)begin
    lease_active<=1;draining<=0;rsp_request_id<=lease_request_id;
    rsp_generation<=lease_generation;rsp_epoch<=lease_epoch;rsp_phase<=lease_phase;
   end
   if(release_match)draining<=1;
   if(release_valid&&release_ready)begin lease_active<=0;draining<=0;end
   if(core_valid!={8{core_valid[0]}})alignment_fault<=1;
  end
 end
 laya_return_vector_credit_v1 #(.WIDTH(512),.TAG_WIDTH(104),.LATENCY(152),.DEPTH(256),.HEAD_BYPASS(0)) credit(
  .clk,.rst_n,.req_valid(req_fire),.req_ready(capacity),.req_tag({req_tag,req_mask}),
  .result_valid(core_valid[0]),.result_data(packed_result),.rsp_valid,.rsp_ready,
  .rsp_tag(response_meta),.rsp_data(packed_response),.pending(pending_vectors),.in_flight(in_flight_vectors),.fault(credit_fault));
 for(genvar lane=0;lane<8;lane++)begin:tanh_lane
  laya_m007_tanh_core_v3 core(.clk,.reset(!rst_n),.core_ce,.token_empty(core_token_empty[lane]),.in_valid(req_fire),
   .in_data(req_mask[lane]?req_x[lane]:32'b0),.commit_valid(core_valid[lane]),.result(core_result[lane]),.status(core_status[lane]));
 end
endmodule
