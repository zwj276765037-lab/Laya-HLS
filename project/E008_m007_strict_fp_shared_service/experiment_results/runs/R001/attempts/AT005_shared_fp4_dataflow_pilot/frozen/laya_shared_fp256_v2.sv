`timescale 1ns/1ps
// Production shared physical array. No paired mul/add transaction or alignment.
// ADD_GROUPS=7: fixed QK groups 128/64/32/16/8/4/4, same 256 adders.
// Other phases atomically join those groups through add request/rsp group0.
// LANES=4,ADD_GROUPS=1 is a bounded instantiation of this exact source.
module laya_shared_fp256_v2 #(parameter int LANES=256, ADD_GROUPS=7)(
 input logic clk,rst_n,
 input logic lease_valid,output logic lease_ready,
 input logic [63:0] lease_request_id,
 input logic [31:0] lease_generation,lease_epoch,
 input logic [3:0] lease_head,
 input logic [2:0] lease_phase,
 input logic release_valid,output logic release_ready,
 input logic [2:0] release_phase,input logic [31:0] release_epoch,
 input logic phase_debt_clear,
 output logic lease_active,draining,
 output logic [63:0] rsp_request_id,
 output logic [31:0] rsp_generation,rsp_epoch,
 output logic [3:0] rsp_head,output logic [2:0] rsp_phase,
 input logic mul_req_valid,output logic mul_req_ready,
 input logic [2:0] mul_req_phase,input logic [31:0] mul_req_epoch,
 input logic [95:0] mul_req_tag,
 input logic [LANES-1:0][31:0] mul_a,mul_b,
 output logic mul_rsp_valid,input logic mul_rsp_ready,
 output logic [95:0] mul_rsp_tag,
 output logic [LANES-1:0][31:0] mul_rsp_data,
 input logic [ADD_GROUPS-1:0] add_req_valid,add_req_is_root,
 output logic [ADD_GROUPS-1:0] add_req_ready,
 input logic [ADD_GROUPS-1:0][2:0] add_req_phase,
 input logic [ADD_GROUPS-1:0][31:0] add_req_epoch,
 input logic [ADD_GROUPS-1:0][95:0] add_req_tag,
 input logic [LANES-1:0][31:0] add_a,add_b,
 output logic [ADD_GROUPS-1:0] add_rsp_valid,
 input logic [ADD_GROUPS-1:0] add_rsp_ready,
 output logic [ADD_GROUPS-1:0][95:0] add_rsp_tag,
 output logic [LANES-1:0][31:0] add_rsp_data,
 output logic [6:0] mul_pending,
 output logic [ADD_GROUPS-1:0][6:0] add_pending,
 output logic protocol_fault
);
 logic [2:0] held_phase;logic [31:0] held_epoch;
 logic [6:0] mul_inflight;
 logic [ADD_GROUPS-1:0][6:0] add_inflight;
 logic mul_capacity,mul_fault;
 logic [ADD_GROUPS-1:0] add_capacity,add_fault,add_raw_valid,add_raw_ready;
 logic [ADD_GROUPS-1:0] add_fire;
 logic [ADD_GROUPS-1:0][95:0] add_raw_tag;
 logic [LANES-1:0] mul_leaf_valid,add_leaf_valid;
 logic [LANES-1:0][31:0] mul_result,add_result;
 wire qk_groups=ADD_GROUPS==7 && held_phase==3'd2;
 wire release_match=release_valid&&lease_active&&release_phase==held_phase&&release_epoch==held_epoch;
 wire stop_root=draining||release_match;
 wire all_drained=mul_pending==0&&mul_inflight==0&&add_pending=='0&&add_inflight=='0;
 wire mul_fire=mul_req_valid&&mul_req_ready;
 assign rsp_phase=held_phase;assign rsp_epoch=held_epoch;
 assign lease_ready=rst_n&&!lease_active&&all_drained&&!protocol_fault;
 assign release_ready=rst_n&&lease_active&&all_drained&&phase_debt_clear&&
                      release_phase==held_phase&&release_epoch==held_epoch&&!protocol_fault;
 assign mul_req_ready=rst_n&&lease_active&&!stop_root&&!protocol_fault&&mul_capacity&&
                      mul_req_phase==held_phase&&mul_req_epoch==held_epoch;
 assign protocol_fault=mul_fault||(|add_fault)||lane_fault;
 logic lane_fault;
 always_ff @(posedge clk) begin
  if(!rst_n) begin lease_active<=0;draining<=0;held_phase<=0;held_epoch<=0;
   rsp_request_id<=0;rsp_generation<=0;rsp_head<=0;lane_fault<=0;
  end else begin
   if(lease_valid&&lease_ready) begin
    lease_active<=1;draining<=0;held_phase<=lease_phase;held_epoch<=lease_epoch;
    rsp_request_id<=lease_request_id;rsp_generation<=lease_generation;rsp_head<=lease_head;
   end
   if(release_match) draining<=1;
   if(release_valid&&release_ready) begin lease_active<=0;draining<=0;end
   if(mul_leaf_valid!={LANES{mul_leaf_valid[0]}}) lane_fault<=1;
  end
 end
 laya_fp_return_credit_v1 #(.WIDTH(LANES*32),.LATENCY(6)) mul_credit(
  .clk,.rst_n,.req_valid(mul_fire),.req_ready(mul_capacity),.req_tag(mul_req_tag),
  .result_valid(mul_leaf_valid[0]),.result_data(mul_result),
  .rsp_valid(mul_rsp_valid),.rsp_ready(mul_rsp_ready),.rsp_tag(mul_rsp_tag),
  .rsp_data(mul_rsp_data),.pending(mul_pending),.in_flight(mul_inflight),.fault(mul_fault));
 for(genvar lane=0;lane<LANES;lane++) begin:mul_lane
  tm1tn8_fmul_ip u_mul(.aclk(clk),.aresetn(rst_n),
   .s_axis_a_tvalid(mul_fire),.s_axis_a_tdata(mul_a[lane]),
   .s_axis_b_tvalid(mul_fire),.s_axis_b_tdata(mul_b[lane]),
   .m_axis_result_tvalid(mul_leaf_valid[lane]),.m_axis_result_tdata(mul_result[lane]));
 end
 for(genvar g=0;g<ADD_GROUPS;g++) begin:add_group
  localparam int LO=(ADD_GROUPS==1)?0:(g==0?0:g==1?128:g==2?192:g==3?224:g==4?240:g==5?248:252);
  localparam int N=(ADD_GROUPS==1)?LANES:(g==0?128:g==1?64:g==2?32:g==3?16:g==4?8:4);
  logic [95:0] selected_tag;
  logic selected_valid,selected_root,selected_match;
  logic group_lane_fault;
  always_comb begin
   selected_valid=qk_groups?add_req_valid[g]:add_req_valid[0];
   selected_root=qk_groups?add_req_is_root[g]:add_req_is_root[0];
   selected_match=qk_groups?(add_req_phase[g]==held_phase&&add_req_epoch[g]==held_epoch):
                            (add_req_phase[0]==held_phase&&add_req_epoch[0]==held_epoch);
   selected_tag=qk_groups?add_req_tag[g]:add_req_tag[0];
   if(qk_groups) begin
    add_req_ready[g]=rst_n&&lease_active&&!protocol_fault&&add_capacity[g]&&selected_match&&!(stop_root&&selected_root);
    add_fire[g]=selected_valid&&add_req_ready[g];
    add_rsp_valid[g]=add_raw_valid[g];add_raw_ready[g]=add_rsp_ready[g];
    add_rsp_tag[g]=add_raw_tag[g];
   end else begin
    add_req_ready[g]=(g==0)&&rst_n&&lease_active&&!protocol_fault&&(&add_capacity)&&selected_match&&!(stop_root&&selected_root);
    add_fire[g]=selected_valid&&rst_n&&lease_active&&!protocol_fault&&(&add_capacity)&&selected_match&&!(stop_root&&selected_root);
    add_rsp_valid[g]=(g==0)&&(&add_raw_valid);
    add_raw_ready[g]=add_rsp_ready[0]&&(&add_raw_valid);
    add_rsp_tag[g]=add_raw_tag[g];
   end
  end
  for(genvar k=0;k<N;k++) begin:lane
   laya_fadd_rne_v1 u_add(.aclk(clk),.aclken(1'b1),.aresetn(rst_n),
    .s_axis_a_tvalid(add_fire[g]),.s_axis_a_tdata(add_a[LO+k]),
    .s_axis_b_tvalid(add_fire[g]),.s_axis_b_tdata(add_b[LO+k]),
    .m_axis_result_tvalid(add_leaf_valid[LO+k]),.m_axis_result_tdata(add_result[LO+k]));
  end
  always_ff @(posedge clk) begin
   if(!rst_n) group_lane_fault<=0;
   else if(add_leaf_valid[LO+:N]!={N{add_leaf_valid[LO]}}) group_lane_fault<=1;
  end
  logic credit_fault;
  assign add_fault[g]=credit_fault||group_lane_fault;
  laya_fp_return_credit_v1 #(.WIDTH(N*32),.LATENCY(8)) credit(
   .clk,.rst_n,.req_valid(add_fire[g]),.req_ready(add_capacity[g]),.req_tag(selected_tag),
   .result_valid(add_leaf_valid[LO]),.result_data(add_result[LO+:N]),
   .rsp_valid(add_raw_valid[g]),.rsp_ready(add_raw_ready[g]),.rsp_tag(add_raw_tag[g]),
   .rsp_data(add_rsp_data[LO+:N]),.pending(add_pending[g]),.in_flight(add_inflight[g]),.fault(credit_fault));
 end
endmodule
