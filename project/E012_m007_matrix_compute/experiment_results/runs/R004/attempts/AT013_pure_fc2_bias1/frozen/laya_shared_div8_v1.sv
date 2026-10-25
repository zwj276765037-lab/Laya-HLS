`timescale 1ns/1ps
// One physical8lane direct F32 divide service for SM3/Q5/LN6. Active lanes
// keep caller's opaque96bit tag. Legal identity + invalid operands reserves a
// deterministic32cycle error completion; invalid leaves are never called.
module laya_shared_div8_v1(
 input logic clk,rst_n,
 input logic lease_valid,output logic lease_ready,input logic[63:0]lease_request_id,
 input logic[31:0]lease_generation,lease_epoch,input logic[3:0]lease_head,input logic[2:0]lease_phase,
 input logic release_valid,output logic release_ready,input logic[2:0]release_phase,input logic[31:0]release_epoch,input logic phase_debt_clear,
 output logic lease_active,draining,output logic[63:0]rsp_request_id,output logic[31:0]rsp_generation,rsp_epoch,output logic[3:0]rsp_head,output logic[2:0]rsp_phase,
 input logic req_valid,output logic req_ready,input logic[31:0]req_generation,req_epoch,input logic[2:0]req_phase,
 input logic[7:0]req_lane_mask,input logic[95:0]req_tag,input logic[7:0][31:0]req_a,req_b,
 output logic protocol_reject_valid,output logic[3:0]protocol_reject_code,
 output logic rsp_valid,input logic rsp_ready,output logic[95:0]rsp_tag,output logic[7:0]rsp_lane_mask,rsp_numeric_error,output logic[7:0][31:0]rsp_data,
 output logic[5:0]pending_vectors,in_flight_vectors,output logic[8:0]in_flight_scalars,output logic protocol_fault
);
 logic[2:0]held_phase;logic[31:0]held_epoch;
 logic credit_fault,local_fault,capacity,mask_legal;
 logic[7:0]bad_operand,leaf_valid;logic[7:0][31:0]leaf_result;
 logic[31:0]token_valid;logic[31:0][7:0]good_pipe,bad_pipe;
 logic[103:0]credit_tag;logic[263:0]credit_data,return_data;
 logic[7:0]return_error;logic[7:0][31:0]return_payload;
 // Freeze only the numerical leaves after ownership, metadata pipelines,
 // leaf-valid tail and every actual debt are known clear. Metadata and credit
 // continue on every physical clock; an active lease never pauses a leaf.
 wire leaf_idle_clear=(lease_active===1'b0)&&(token_valid===32'b0)&&
  (good_pipe==='0)&&(bad_pipe==='0)&&(leaf_valid===8'b0)&&
  (pending_vectors===6'b0)&&(in_flight_vectors===6'b0)&&
  (in_flight_scalars===9'b0);
 wire leaf_ce=!rst_n||!leaf_idle_clear;
 wire release_match=release_valid&&lease_active&&release_phase==held_phase&&release_epoch==held_epoch;
 wire req_fire=req_valid&&req_ready;
 function automatic bit valid_phase(input logic[2:0]p);return p==3||p==5||p==6;endfunction
 function automatic int count_bits(input logic[7:0]m);int n;n=0;for(int l=0;l<8;l++)n+=int'(m[l]);return n;endfunction
 assign rsp_phase=held_phase;assign rsp_epoch=held_epoch;assign protocol_fault=credit_fault||local_fault;
 assign lease_ready=rst_n&&!lease_active&&pending_vectors==0&&in_flight_vectors==0&&!protocol_fault&&valid_phase(lease_phase);
 assign release_ready=rst_n&&lease_active&&pending_vectors==0&&in_flight_vectors==0&&in_flight_scalars==0&&phase_debt_clear&&release_phase==held_phase&&release_epoch==held_epoch&&!protocol_fault;
 assign rsp_tag=credit_tag[95:0];assign rsp_lane_mask=credit_tag[103:96];assign rsp_data=credit_data[255:0];assign rsp_numeric_error=credit_data[263:256];
 always_comb begin
  case(held_phase)3:mask_legal=req_lane_mask==8'hff;5:mask_legal=req_lane_mask!=0&&(req_lane_mask&8'hfc)==0;6:mask_legal=req_lane_mask==1;default:mask_legal=0;endcase
  bad_operand=0;
  for(int l=0;l<8;l++)if(req_lane_mask[l]&&(req_a[l][30:23]==255||req_b[l][30:23]==255||req_b[l][30:0]==0))bad_operand[l]=1;
  protocol_reject_code=0;
  if(!lease_active)protocol_reject_code=1;
  else if(req_generation!=rsp_generation)protocol_reject_code=2;
  else if(req_epoch!=held_epoch)protocol_reject_code=3;
  else if(req_phase!=held_phase)protocol_reject_code=4;
  else if(!mask_legal)protocol_reject_code=5;
  protocol_reject_valid=req_valid&&protocol_reject_code!=0;
  if(lease_valid&&(lease_active||!valid_phase(lease_phase)))begin protocol_reject_valid=1;protocol_reject_code=6;end
  if(release_valid&&!release_match)begin protocol_reject_valid=1;protocol_reject_code=7;end
  req_ready=rst_n&&lease_active&&!draining&&!release_match&&!protocol_fault&&capacity&&protocol_reject_code==0;
  return_error=bad_pipe[31];return_payload=0;
  for(int l=0;l<8;l++)if(good_pipe[31][l])begin return_payload[l]=leaf_result[l];if(leaf_result[l][30:23]==255)return_error[l]=1;end
  return_data={return_error,return_payload};
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin lease_active<=0;draining<=0;held_phase<=0;held_epoch<=0;rsp_request_id<=0;rsp_generation<=0;rsp_head<=0;local_fault<=0;token_valid<=0;good_pipe<=0;bad_pipe<=0;in_flight_scalars<=0;end
  else begin
   if(lease_valid&&lease_ready)begin lease_active<=1;draining<=0;held_phase<=lease_phase;held_epoch<=lease_epoch;rsp_request_id<=lease_request_id;rsp_generation<=lease_generation;rsp_head<=lease_head;end
   if(release_match)draining<=1;
   if(release_valid&&release_ready)begin lease_active<=0;draining<=0;end
   token_valid<={token_valid[30:0],req_fire};good_pipe<={good_pipe[30:0],req_fire?(req_lane_mask&~bad_operand):8'b0};bad_pipe<={bad_pipe[30:0],req_fire?bad_operand:8'b0};
   if(leaf_valid!=good_pipe[31]||in_flight_scalars>256)local_fault<=1;
   in_flight_scalars<=9'(int'(in_flight_scalars)+(req_fire?count_bits(req_lane_mask&~bad_operand):0)-count_bits(leaf_valid));
  end
 end
 laya_return_vector_credit_v1 #(.WIDTH(264),.TAG_WIDTH(104),.LATENCY(32),.DEPTH(32),.HEAD_BYPASS(1))credit(
  .clk,.rst_n,.req_valid(req_fire),.req_ready(capacity),.req_tag({req_lane_mask,req_tag}),.result_valid(token_valid[31]),.result_data(return_data),.rsp_valid,.rsp_ready,.rsp_tag(credit_tag),.rsp_data(credit_data),.pending(pending_vectors),.in_flight(in_flight_vectors),.fault(credit_fault));
 for(genvar lane=0;lane<8;lane++)begin:divider_lane
  laya_fdiv_rne_v1 leaf(.aclk(clk),.aclken(leaf_ce),.aresetn(rst_n),.s_axis_a_tvalid(req_fire&&req_lane_mask[lane]&&!bad_operand[lane]),.s_axis_a_tdata(req_a[lane]),.s_axis_b_tvalid(req_fire&&req_lane_mask[lane]&&!bad_operand[lane]),.s_axis_b_tdata(req_b[lane]),.m_axis_result_tvalid(leaf_valid[lane]),.m_axis_result_tdata(leaf_result[lane]));
 end
endmodule
