`timescale 1ns/1ps
// Strict group32 Q8-F engine. 128 real reservations survive until output fire.
// One external phase5 shared_div8 service; 32 dedicated strict mul leaves.
module laya_m007_quant_group32_v1(
 input logic clk,rst_n,
 input logic lease_valid,output logic lease_ready,
 input logic[63:0]lease_request_id,input logic[31:0]lease_generation,lease_source_epoch,
 input logic[12:0]lease_k,
 input logic release_valid,output logic release_ready,
 input logic[63:0]release_request_id,input logic[31:0]release_generation,release_source_epoch,
 output logic lease_active,draining,
 input logic in_valid,output logic in_ready,input logic[63:0]in_request_id,
 input logic[31:0]in_generation,in_source_epoch,input logic[7:0]in_row,in_group,
 input logic[95:0]in_tag,input logic[1023:0]in_data,
 output logic protocol_reject_valid,output logic[3:0]protocol_reject_code,
 output logic out_valid,input logic out_ready,output logic[63:0]out_request_id,
 output logic[31:0]out_generation,out_source_epoch,output logic[12:0]out_k,
 output logic[7:0]out_row,out_group,output logic[95:0]out_tag,
 output logic[271:0]out_data,output logic[7:0]out_status,out_stage,
 output logic[4:0]out_source_element,output logic[31:0]out_amax,out_d_full,out_inverse,
 output logic out_d_valid,out_inverse_valid,
 output logic[8:0]reservations,output logic protocol_fault,
 output logic[31:0]accepted_groups,retired_groups,scale_divisions,inverse_divisions,
 output logic trace_mul_valid,output logic[95:0]trace_mul_tag,
 output logic[1023:0]trace_mul_products,
 // Public service interface; this engine owns no divider leaf.
 output logic d_lease_valid,input logic d_lease_ready,
 output logic[63:0]d_lease_request_id,output logic[31:0]d_lease_generation,d_lease_epoch,
 output logic[3:0]d_lease_head,output logic[2:0]d_lease_phase,
 output logic d_release_valid,input logic d_release_ready,
 output logic[2:0]d_release_phase,output logic[31:0]d_release_epoch,
 output logic d_phase_debt_clear,input logic d_lease_active,d_draining,
 input logic[63:0]d_rsp_request_id,input logic[31:0]d_rsp_generation,d_rsp_epoch,
 input logic[3:0]d_rsp_head,input logic[2:0]d_rsp_phase,
 output logic d_req_valid,input logic d_req_ready,
 output logic[31:0]d_req_generation,d_req_epoch,output logic[2:0]d_req_phase,
 output logic[7:0]d_req_lane_mask,output logic[95:0]d_req_tag,
 output logic[7:0][31:0]d_req_a,d_req_b,
 input logic d_protocol_reject_valid,input logic[3:0]d_protocol_reject_code,
 input logic d_rsp_valid,output logic d_rsp_ready,input logic[95:0]d_rsp_tag,
 input logic[7:0]d_rsp_lane_mask,d_rsp_numeric_error,input logic[7:0][31:0]d_rsp_data,
 input logic[5:0]d_pending_vectors,d_in_flight_vectors,
 input logic[8:0]d_in_flight_scalars,input logic d_protocol_fault
);
 import laya_m007_quant_format_pkg::*;
 localparam logic[3:0]FREE=0,AMAX_WAIT=1,SCALE_READY=2,SCALE_FLIGHT=3,
  INVERSE_READY=4,INVERSE_FLIGHT=5,MUL_READY=6,MUL_FLIGHT=7,DONE=8;
 (* ram_style="block" *) logic[1023:0]raw_mem[128];
 (* ram_style="block" *) logic[271:0]packed_mem[128];
 logic[3:0]state[128];logic[7:0]row_mem[128],group_mem[128];logic[95:0]tag_mem[128];
 logic[31:0]amax_mem[128],d_mem[128],inverse_mem[128];logic[15:0]half_mem[128];
 logic[7:0]status_mem[128],stage_mem[128];logic[4:0]element_mem[128];
 logic d_seen[128],inverse_seen[128];
 logic[63:0]request_id;logic[31:0]generation,source_epoch;logic[12:0]k;
 logic[31:0]scale_scheduled,inverse_scheduled,mul_scheduled;
 wire[6:0]accept_slot=accepted_groups[6:0],retire_slot=retired_groups[6:0];
 wire[6:0]scale_slot=scale_scheduled[6:0],inverse_slot=inverse_scheduled[6:0],mul_slot=mul_scheduled[6:0];
 logic local_fault,identity_ok,coordinates_ok,release_match,internal_clear;
 logic hold_valid;logic[1:0]hold_mask;logic[6:0]hold_scale_slot,hold_inverse_slot;
 logic[31:0]hold_amax,hold_d;logic capture_scale,capture_inverse,can_capture;
 logic amax_valid,amax_bad;logic[31:0]amax_data;logic[4:0]amax_element;logic[6:0]amax_slot;
 logic raw_valid;logic[1023:0]raw_read;logic[31:0]raw_inverse;logic[6:0]raw_slot;
 logic[7:0]mul_tag_valid;logic[6:0]mul_tag[8];
 logic[31:0]mul_valid;logic[31:0][31:0]mul_data;logic[271:0]mul_packed;
 logic[7:0]mul_error_stage;logic[4:0]mul_error_element;
 logic[9:0]q_format[32];logic[16:0]returned_half;
 wire in_fire=in_valid&&in_ready;wire out_fire=out_valid&&out_ready;
 wire lease_fire=lease_valid&&lease_ready;
 wire[6:0]returned_scale_slot=d_rsp_tag[6:0],returned_inverse_slot=d_rsp_tag[13:7];
 assign protocol_fault=local_fault||d_protocol_fault;
 assign out_request_id=request_id;assign out_generation=generation;assign out_source_epoch=source_epoch;assign out_k=k;
 assign out_valid=rst_n&&lease_active&&retired_groups<mul_scheduled&&state[retire_slot]==DONE;
 assign out_row=row_mem[retire_slot];assign out_group=group_mem[retire_slot];assign out_tag=tag_mem[retire_slot];
 assign out_status=status_mem[retire_slot];assign out_stage=stage_mem[retire_slot];assign out_source_element=element_mem[retire_slot];
 assign out_data=out_status==0?packed_mem[retire_slot]:272'b0;
 assign out_amax=amax_mem[retire_slot];assign out_d_full=d_mem[retire_slot];assign out_inverse=inverse_mem[retire_slot];
 assign out_d_valid=d_seen[retire_slot];assign out_inverse_valid=inverse_seen[retire_slot];
 assign d_lease_request_id=lease_request_id;assign d_lease_generation=lease_generation;assign d_lease_epoch=lease_source_epoch;
 assign d_lease_head=0;assign d_lease_phase=5;assign d_release_phase=5;assign d_release_epoch=source_epoch;
 assign d_req_generation=generation;assign d_req_epoch=source_epoch;assign d_req_phase=5;
 assign d_req_valid=hold_valid;assign d_req_lane_mask={6'b0,hold_mask};
 assign d_req_tag={32'h51333231,generation^source_epoch,18'b0,hold_inverse_slot,hold_scale_slot};
 assign d_rsp_ready=1;
 assign trace_mul_valid=(&mul_valid)&&mul_tag_valid[7];assign trace_mul_tag=tag_mem[mul_tag[7]];
 assign trace_mul_products=mul_data;
 always_comb begin
  identity_ok=in_request_id==request_id&&in_generation==generation&&in_source_epoch==source_epoch;
  coordinates_ok=in_row<128&&{5'b0,in_group}<(k>>5);
  release_match=release_valid&&lease_active&&release_request_id==request_id&&release_generation==generation&&release_source_epoch==source_epoch;
  internal_clear=reservations==0&&!hold_valid&&!raw_valid&&mul_tag_valid==0&&accepted_groups==scale_scheduled&&scale_scheduled==inverse_scheduled&&inverse_scheduled==mul_scheduled&&mul_scheduled==retired_groups;
  d_phase_debt_clear=internal_clear;
  d_lease_valid=lease_valid&&!lease_active&&(lease_k==1024||lease_k==2624||lease_k==4096);
  lease_ready=rst_n&&!lease_active&&!protocol_fault&&(lease_k==1024||lease_k==2624||lease_k==4096)&&d_lease_ready;
  d_release_valid=release_match&&internal_clear;
  release_ready=rst_n&&release_match&&internal_clear&&d_release_ready&&!protocol_fault;
  in_ready=rst_n&&lease_active&&!draining&&!release_match&&!protocol_fault&&identity_ok&&coordinates_ok&&(reservations<128||out_fire);
  protocol_reject_code=0;
  if(in_valid)begin
   if(!lease_active)protocol_reject_code=1;
   else if(in_request_id!=request_id)protocol_reject_code=2;
   else if(in_generation!=generation)protocol_reject_code=3;
   else if(in_source_epoch!=source_epoch)protocol_reject_code=4;
   else if(!coordinates_ok)protocol_reject_code=5;
  end
  if(lease_valid&&(lease_active||!(lease_k==1024||lease_k==2624||lease_k==4096)))protocol_reject_code=6;
  if(release_valid&&!release_match)protocol_reject_code=7;
  protocol_reject_valid=rst_n&&protocol_reject_code!=0;
  can_capture=!hold_valid||d_req_ready;
  capture_scale=can_capture&&scale_scheduled<accepted_groups&&state[scale_slot]==SCALE_READY;
  capture_inverse=can_capture&&inverse_scheduled<scale_scheduled&&state[inverse_slot]==INVERSE_READY;
  d_req_a=0;d_req_b=0;d_req_a[0]=hold_amax;d_req_b[0]=32'h42fe0000;
  d_req_a[1]=32'h3f800000;d_req_b[1]=hold_d;
  returned_half=half_rne(d_rsp_data[0]);
  mul_packed=0;mul_packed[271:256]=half_mem[mul_tag[7]];
  mul_error_stage=0;mul_error_element=0;
  for(int l=0;l<32;l++)begin q_format[l]=round_q8(mul_data[l]);mul_packed[8*l+:8]=q_format[l][7:0];end
  // Original per-operation Check ordering: every product before any round.
  for(int l=0;l<32;l++)if(q_format[l][9]&&mul_error_stage==0)begin mul_error_stage=5;mul_error_element=5'(l);end
  for(int l=0;l<32;l++)if(q_format[l][8]&&mul_error_stage==0)begin mul_error_stage=6;mul_error_element=5'(l);end
 end
 always_ff@(posedge clk)begin
  if(!rst_n)begin
   lease_active<=0;draining<=0;local_fault<=0;reservations<=0;
   accepted_groups<=0;retired_groups<=0;scale_scheduled<=0;inverse_scheduled<=0;mul_scheduled<=0;
   scale_divisions<=0;inverse_divisions<=0;hold_valid<=0;hold_mask<=0;raw_valid<=0;mul_tag_valid<=0;
   request_id<=0;generation<=0;source_epoch<=0;k<=0;
   for(int i=0;i<128;i++)state[i]<=FREE;
  end else begin
   if(d_protocol_fault||d_protocol_reject_valid)local_fault<=1;
   if(lease_fire)begin
    lease_active<=1;draining<=0;request_id<=lease_request_id;generation<=lease_generation;source_epoch<=lease_source_epoch;k<=lease_k;
    accepted_groups<=0;retired_groups<=0;scale_scheduled<=0;inverse_scheduled<=0;mul_scheduled<=0;
    scale_divisions<=0;inverse_divisions<=0;
   end
   if(release_match)draining<=1;
   if(release_valid&&release_ready)begin lease_active<=0;draining<=0;end
   case({in_fire,out_fire})2'b10:reservations<=reservations+1'b1;2'b01:reservations<=reservations-1'b1;default:;endcase
   if(out_fire)begin state[retire_slot]<=FREE;retired_groups<=retired_groups+1'b1;end
   if(in_fire)begin
    state[accept_slot]<=AMAX_WAIT;raw_mem[accept_slot]<=in_data;
    row_mem[accept_slot]<=in_row;group_mem[accept_slot]<=in_group;tag_mem[accept_slot]<=in_tag;
    amax_mem[accept_slot]<=0;d_mem[accept_slot]<=0;inverse_mem[accept_slot]<=0;half_mem[accept_slot]<=0;
    status_mem[accept_slot]<=0;stage_mem[accept_slot]<=0;element_mem[accept_slot]<=0;d_seen[accept_slot]<=0;inverse_seen[accept_slot]<=0;
    accepted_groups<=accepted_groups+1'b1;
   end
   if(amax_valid)begin
    if(state[amax_slot]!=AMAX_WAIT)local_fault<=1;
    amax_mem[amax_slot]<=amax_data;
    if(amax_bad)begin state[amax_slot]<=DONE;status_mem[amax_slot]<=1;stage_mem[amax_slot]<=1;element_mem[amax_slot]<=amax_element;end
    else state[amax_slot]<=SCALE_READY;
   end
   // The single request holding register stays stable during shared backpressure.
   if(can_capture)begin
    hold_valid<=capture_scale||capture_inverse;hold_mask<={capture_inverse,capture_scale};
    if(capture_scale)begin hold_scale_slot<=scale_slot;hold_amax<=amax_mem[scale_slot];state[scale_slot]<=SCALE_FLIGHT;scale_scheduled<=scale_scheduled+1'b1;end
    if(capture_inverse)begin hold_inverse_slot<=inverse_slot;hold_d<=d_mem[inverse_slot];state[inverse_slot]<=INVERSE_FLIGHT;inverse_scheduled<=inverse_scheduled+1'b1;end
   end
   if(scale_scheduled<accepted_groups&&state[scale_slot]==DONE)scale_scheduled<=scale_scheduled+1'b1;
   if(inverse_scheduled<scale_scheduled&&(state[inverse_slot]==DONE||state[inverse_slot]==MUL_READY))inverse_scheduled<=inverse_scheduled+1'b1;
   if(d_req_valid&&d_req_ready)begin
    if(d_req_lane_mask[0])scale_divisions<=scale_divisions+1'b1;
    if(d_req_lane_mask[1])inverse_divisions<=inverse_divisions+1'b1;
   end
   if(d_rsp_valid)begin
    if(d_rsp_request_id!=request_id||d_rsp_generation!=generation||d_rsp_epoch!=source_epoch||d_rsp_phase!=5||d_rsp_head!=0||
       d_rsp_tag[95:64]!=32'h51333231||d_rsp_tag[63:32]!=(generation^source_epoch)||d_rsp_tag[31:14]!=0||d_rsp_lane_mask==0||(d_rsp_lane_mask&8'hfc)!=0)local_fault<=1;
    if(d_rsp_lane_mask[0])begin
     if(state[returned_scale_slot]!=SCALE_FLIGHT)local_fault<=1;
     d_mem[returned_scale_slot]<=d_rsp_data[0];d_seen[returned_scale_slot]<=1;half_mem[returned_scale_slot]<=returned_half[15:0];
     if(d_rsp_numeric_error[0]||d_rsp_data[0][30:23]==255)begin state[returned_scale_slot]<=DONE;status_mem[returned_scale_slot]<=1;stage_mem[returned_scale_slot]<=2;end
     else if(returned_half[16])begin state[returned_scale_slot]<=DONE;status_mem[returned_scale_slot]<=1;stage_mem[returned_scale_slot]<=3;end
     else if(d_rsp_data[0][30:0]==0)begin state[returned_scale_slot]<=MUL_READY;inverse_mem[returned_scale_slot]<=0;inverse_seen[returned_scale_slot]<=1;end
     else state[returned_scale_slot]<=INVERSE_READY;
    end
    if(d_rsp_lane_mask[1])begin
     if(state[returned_inverse_slot]!=INVERSE_FLIGHT)local_fault<=1;
     inverse_mem[returned_inverse_slot]<=d_rsp_data[1];inverse_seen[returned_inverse_slot]<=1;
     if(d_rsp_numeric_error[1]||d_rsp_data[1][30:23]==255)begin state[returned_inverse_slot]<=DONE;status_mem[returned_inverse_slot]<=1;stage_mem[returned_inverse_slot]<=4;end
     else state[returned_inverse_slot]<=MUL_READY;
    end
   end
   // Exactly one synchronous raw-bank read feeds all32 real strict multipliers.
   raw_valid<=0;
   if(mul_scheduled<inverse_scheduled)begin
    if(state[mul_slot]==DONE)mul_scheduled<=mul_scheduled+1'b1;
    else if(state[mul_slot]==MUL_READY)begin
     raw_valid<=1;raw_read<=raw_mem[mul_slot];raw_inverse<=inverse_mem[mul_slot];raw_slot<=mul_slot;
     state[mul_slot]<=MUL_FLIGHT;mul_scheduled<=mul_scheduled+1'b1;
    end
   end
   mul_tag_valid<={mul_tag_valid[6:0],raw_valid};mul_tag[0]<=raw_slot;
   for(int s=1;s<8;s++)mul_tag[s]<=mul_tag[s-1];
   if(mul_valid!={32{mul_tag_valid[7]}})local_fault<=1;
   if(trace_mul_valid)begin
    if(state[mul_tag[7]]!=MUL_FLIGHT)local_fault<=1;
    state[mul_tag[7]]<=DONE;packed_mem[mul_tag[7]]<=mul_packed;
    if(mul_error_stage!=0)begin status_mem[mul_tag[7]]<=1;stage_mem[mul_tag[7]]<=mul_error_stage;element_mem[mul_tag[7]]<=mul_error_element;end
   end
  end
 end
 laya_m007_quant_amax32_v1 #(.TAG_WIDTH(7))amax(
  .clk,.rst_n,.in_valid(in_fire),.in_data,.in_tag(accept_slot),
  .out_valid(amax_valid),.out_amax(amax_data),.out_bad(amax_bad),.out_bad_element(amax_element),.out_tag(amax_slot));
 for(genvar lane=0;lane<32;lane++)begin:quant_mul_lane
  laya_fmul_rne_v1 leaf(.aclk(clk),.aclken(1'b1),.aresetn(rst_n),
   .s_axis_a_tvalid(raw_valid),.s_axis_b_tvalid(raw_valid),.s_axis_a_tdata(raw_read[lane*32+:32]),.s_axis_b_tdata(raw_inverse),
   .m_axis_result_tvalid(mul_valid[lane]),.m_axis_result_tdata(mul_data[lane]));
 end
endmodule
