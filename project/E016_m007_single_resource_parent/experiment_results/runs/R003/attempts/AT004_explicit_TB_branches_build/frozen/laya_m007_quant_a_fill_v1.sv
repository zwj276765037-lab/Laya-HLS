`timescale 1ns/1ps
// Pure quant/A-fill control. Caller owns unique coordinate order; no tensor reorder RAM.
// Producer completion is independent of last A ack/publication. The cancel hook
// drains only actual accepted work on an upstream failure; no missing-input padding.
module laya_m007_quant_a_fill_v1(
 input logic clk,rst_n,run_enable,
 input logic cmd_valid,output logic cmd_ready,input logic cmd_slot,input logic [15:0] cmd_k,
 input logic [63:0] cmd_request,input logic [31:0] cmd_generation,cmd_epoch,
 input logic in_valid,output logic in_ready,input logic [31:0][31:0] in_data,
 input logic [63:0] in_request,input logic [31:0] in_generation,in_epoch,input logic [7:0] in_row,in_group,
 input logic producer_close_valid,output logic producer_close_ready,input logic producer_close_success,
 output logic done_valid,input logic done_ready,output logic [2:0] status,
 output logic [2:0] quant_phase,output logic [6:0] quant_row,quant_group,output logic [4:0] quant_element,
 output logic [31:0] quant_accepted,quant_retired,a_writes,a_write_acks,
 output logic quant_last_event,a_publish_event,
 output logic acfg_valid,input logic acfg_ready,output logic acfg_slot,output logic [15:0] acfg_k,
 output logic [63:0] acfg_request,output logic [31:0] acfg_generation,acfg_epoch,
 input logic acfg_rsp_valid,output logic acfg_rsp_ready,input logic [1:0] acfg_status,
 output logic awr_valid,input logic awr_ready,output logic [6:0] awr_row,awr_group,output logic [271:0] awr_data,
 output logic [63:0] awr_request,output logic [31:0] awr_generation,awr_epoch,
 input logic awr_rsp_valid,output logic awr_rsp_ready,
 output logic fill_cancel_valid,input logic fill_cancel_ready,output logic fill_cancel_slot,
 output logic [63:0] fill_cancel_request,output logic [31:0] fill_cancel_generation,fill_cancel_epoch,
 input logic fill_cancel_reject_valid,input logic [3:0] fill_cancel_reject_code,
 input logic fill_cancel_rsp_valid,output logic fill_cancel_rsp_ready,input logic fill_cancel_rsp_slot,
 input logic [63:0] fill_cancel_rsp_request,input logic [31:0] fill_cancel_rsp_generation,fill_cancel_rsp_epoch,
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
 localparam logic [2:0] IDLE=0,BIND=1,Q_RUN=2,Q_DRAIN=3,FINISH=4;
 logic [2:0] state;
 logic [63:0] request_id;logic [31:0] generation,epoch,total_groups;logic [15:0] k;logic a_slot;
 logic a_failed_closed,quant_error,producer_closed,producer_success,q_released,a_published,cancel_sent,cancel_completed;
 logic [21:0] quant_error_key,candidate_key;logic [2:0] candidate_phase;
 logic [8:0] a_write_debt;
 // 256B bounded FIFO metadata, not payload reordering. Preserves caller order.
 logic [15:0] accepted_coordinates[0:127];logic q_output_identity_ok,q_output_payload_ok,input_legal;
 logic q_lease_valid,q_lease_ready,q_release_valid,q_release_ready,q_lease_active,q_draining;
 logic q_in_valid,q_in_ready,q_out_valid,q_out_ready,q_reject_valid,q_fault;
 logic [3:0] q_reject_code;logic [63:0] q_out_request;logic [31:0] q_out_generation,q_out_epoch;logic [12:0] q_out_k;
 logic [7:0] q_out_row,q_out_group,q_out_status,q_out_stage;logic [95:0] q_out_tag;logic [271:0] q_out_data;
 logic [4:0] q_out_element;logic [31:0] q_amax,q_d_full,q_inverse;logic q_d_valid,q_inverse_valid;
 logic [8:0] q_reservations;logic [31:0] q_scale_divisions,q_inverse_divisions;
 logic q_trace_mul_valid;logic [95:0] q_trace_mul_tag;logic [1023:0] q_trace_mul_products;
 wire input_fire=in_valid&&in_ready;
 wire quant_fire=q_out_valid&&q_out_ready;
 wire a_write_fire=awr_valid&&awr_ready;
 wire a_ack_fire=awr_rsp_valid&&awr_rsp_ready;
 function automatic logic [2:0] global_phase(input logic [7:0] local_stage);
  case(local_stage)1:return 1;2:return 2;4:return 3;3:return 4;5:return 5;6:return 6;default:return 7;endcase
 endfunction
 always_comb begin
  cmd_ready=rst_n&&state==IDLE&&!done_valid;
  input_legal=state==Q_RUN&&!producer_closed&&quant_accepted<total_groups&&in_request==request_id&&in_generation==generation&&in_epoch==epoch&&in_row<128&&{8'b0,in_group}<(k>>5);
  in_ready=rst_n&&input_legal&&run_enable&&q_in_ready;
  q_in_valid=in_valid&&input_legal&&run_enable;
  producer_close_ready=rst_n&&state==Q_RUN&&!producer_closed&&(!producer_close_success||quant_accepted==total_groups);
  q_output_identity_ok=q_out_request==request_id&&q_out_generation==generation&&q_out_epoch==epoch&&q_out_k==k[12:0]&&{q_out_row,q_out_group}==accepted_coordinates[quant_retired[6:0]]&&q_out_tag=={epoch,generation,q_out_row,q_out_group,16'b0};
  q_output_payload_ok=q_out_status!=0||!((q_out_data[270:266]==31)||(q_out_data[271]&&q_out_data[270:256]!=0));
  q_lease_valid=state==BIND&&acfg_ready;
  acfg_valid=state==BIND&&q_lease_ready;acfg_slot=a_slot;acfg_k=k;acfg_request=request_id;acfg_generation=generation;acfg_epoch=epoch;
  awr_valid=(state==Q_RUN||state==Q_DRAIN)&&q_out_valid&&q_out_status==0&&q_output_identity_ok&&q_output_payload_ok&&!quant_error&&run_enable&&!(producer_close_valid&&producer_close_ready&&!producer_close_success);
  awr_row=q_out_row[6:0];awr_group=q_out_group[6:0];awr_data=q_out_data;awr_request=request_id;awr_generation=generation;awr_epoch=epoch;
  q_out_ready=(state==Q_RUN||state==Q_DRAIN)&&run_enable&&((q_out_status!=0||quant_error||!q_output_identity_ok||!q_output_payload_ok||(producer_close_valid&&producer_close_ready&&!producer_close_success))||awr_ready);
  awr_rsp_ready=(state==Q_RUN||state==Q_DRAIN)&&run_enable;
  acfg_rsp_ready=(state==Q_RUN||state==Q_DRAIN)&&run_enable;
  // Early upstream cancel asserts real release while actual quant returns drain.
  // Numeric quant errors enter Q_DRAIN only after all required tensor checks.
  q_release_valid=state==Q_DRAIN&&!q_released&&(quant_error||a_published);
  fill_cancel_valid=state==Q_DRAIN&&quant_error&&!cancel_sent&&!a_failed_closed;
  fill_cancel_slot=a_slot;fill_cancel_request=request_id;fill_cancel_generation=generation;fill_cancel_epoch=epoch;
  fill_cancel_rsp_ready=state==Q_DRAIN&&quant_error&&run_enable;
  candidate_phase=global_phase(q_out_stage);
  candidate_key={candidate_phase,q_out_row[6:0],q_out_group[6:0],q_out_element};
  quant_last_event=quant_fire&&quant_retired+1==total_groups;
  a_publish_event=acfg_rsp_valid&&acfg_rsp_ready;
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   state<=IDLE;request_id<=0;generation<=0;epoch<=0;total_groups<=0;k<=0;a_slot<=0;
   a_failed_closed<=0;quant_error<=0;producer_closed<=0;producer_success<=0;quant_error_key<='1;q_released<=0;a_published<=0;cancel_sent<=0;cancel_completed<=0;a_write_debt<=0;
   done_valid<=0;status<=0;quant_phase<=0;quant_row<=0;quant_group<=0;quant_element<=0;a_writes<=0;a_write_acks<=0;
  end else begin
   if(done_valid&&done_ready)begin done_valid<=0;state<=IDLE;end
   if(cmd_valid&&cmd_ready)begin
    generation<=cmd_generation;epoch<=cmd_epoch;request_id<=cmd_request;k<=cmd_k;a_slot<=cmd_slot;total_groups<=128*(cmd_k>>5);
    a_failed_closed<=0;quant_error<=0;producer_closed<=0;producer_success<=0;quant_error_key<='1;q_released<=0;a_published<=0;cancel_sent<=0;cancel_completed<=0;a_write_debt<=0;status<=0;quant_phase<=0;quant_row<=0;quant_group<=0;quant_element<=0;a_writes<=0;a_write_acks<=0;
    if(cmd_k!=1024&&cmd_k!=2624&&cmd_k!=4096)begin status<=1;done_valid<=1;state<=FINISH;end else state<=BIND;
   end
   if(state==BIND&&q_lease_valid&&q_lease_ready&&acfg_valid&&acfg_ready)state<=Q_RUN;
   if(input_fire)accepted_coordinates[quant_accepted[6:0]]<={in_row,in_group};
   if(producer_close_valid&&producer_close_ready)begin
    producer_closed<=1;producer_success<=producer_close_success;
    if(!producer_close_success)begin quant_error<=1;status<=3;state<=Q_DRAIN;end
   end
   if(a_write_fire)a_writes<=a_writes+1;
   if(a_ack_fire)a_write_acks<=a_write_acks+1;
   case({a_write_fire,a_ack_fire})2'b10:a_write_debt<=a_write_debt+1;2'b01:a_write_debt<=a_write_debt-1;default:;endcase
   if(quant_fire)begin
    if(!q_output_identity_ok||!q_output_payload_ok)begin quant_error<=1;status<=3;end
    else if(q_out_status!=0)begin
     quant_error<=1;if(status!=3)status<=2;
     if(candidate_key<quant_error_key)begin quant_error_key<=candidate_key;quant_phase<=candidate_phase;quant_row<=q_out_row[6:0];quant_group<=q_out_group[6:0];quant_element<=q_out_element;end
    end
   end
   if(state==Q_RUN&&producer_closed&&producer_success&&quant_retired==total_groups&&a_write_debt==0)state<=Q_DRAIN;
   if(acfg_rsp_valid&&acfg_rsp_ready)begin
    a_published<=1;
    // Nonzero publication already invalidated its slot; after real response
    // consumption it owns no fill. Do not demand a fabricated cancel response.
    if(acfg_status!=0)begin a_failed_closed<=1;quant_error<=1;status<=3;end
   end
   if(q_release_valid&&q_release_ready)q_released<=1;
   if(fill_cancel_valid&&fill_cancel_ready)cancel_sent<=1;
   if(fill_cancel_rsp_valid&&fill_cancel_rsp_ready)begin
    if(fill_cancel_rsp_slot==a_slot&&fill_cancel_rsp_request==request_id&&fill_cancel_rsp_generation==generation&&fill_cancel_rsp_epoch==epoch)cancel_completed<=1;
    else begin status<=3;quant_error<=1;end
   end
   if(state==Q_DRAIN&&q_released&&!q_lease_active&&!d_lease_active&&a_write_debt==0)begin
    if((quant_error&&(cancel_completed||a_failed_closed))||(!quant_error&&a_published&&producer_closed&&producer_success))begin done_valid<=1;state<=FINISH;end
   end
  end
 end
 laya_m007_quant_group32_v1 quant(
  .clk,.rst_n,.lease_valid(q_lease_valid),.lease_ready(q_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_source_epoch(epoch),.lease_k(k[12:0]),
  .release_valid(q_release_valid),.release_ready(q_release_ready),.release_request_id(request_id),.release_generation(generation),.release_source_epoch(epoch),.lease_active(q_lease_active),.draining(q_draining),
  .in_valid(q_in_valid),.in_ready(q_in_ready),.in_request_id(in_request),.in_generation(in_generation),.in_source_epoch(in_epoch),.in_row,.in_group,.in_tag({epoch,generation,in_row,in_group,16'b0}),.in_data,
  .protocol_reject_valid(q_reject_valid),.protocol_reject_code(q_reject_code),.out_valid(q_out_valid),.out_ready(q_out_ready),.out_request_id(q_out_request),.out_generation(q_out_generation),.out_source_epoch(q_out_epoch),.out_k(q_out_k),.out_row(q_out_row),.out_group(q_out_group),.out_tag(q_out_tag),.out_data(q_out_data),.out_status(q_out_status),.out_stage(q_out_stage),.out_source_element(q_out_element),.out_amax(q_amax),.out_d_full(q_d_full),.out_inverse(q_inverse),.out_d_valid(q_d_valid),.out_inverse_valid(q_inverse_valid),.reservations(q_reservations),.protocol_fault(q_fault),.accepted_groups(quant_accepted),.retired_groups(quant_retired),.scale_divisions(q_scale_divisions),.inverse_divisions(q_inverse_divisions),.trace_mul_valid(q_trace_mul_valid),.trace_mul_tag(q_trace_mul_tag),.trace_mul_products(q_trace_mul_products),
  .d_lease_valid,.d_lease_ready,.d_lease_request_id,.d_lease_generation,.d_lease_epoch,.d_lease_head,.d_lease_phase,.d_release_valid,.d_release_ready,.d_release_phase,.d_release_epoch,.d_phase_debt_clear,.d_lease_active,.d_draining,.d_rsp_request_id,.d_rsp_generation,.d_rsp_epoch,.d_rsp_head,.d_rsp_phase,.d_req_valid,.d_req_ready,.d_req_generation,.d_req_epoch,.d_req_phase,.d_req_lane_mask,.d_req_tag,.d_req_a,.d_req_b,.d_protocol_reject_valid,.d_protocol_reject_code,.d_rsp_valid,.d_rsp_ready,.d_rsp_tag,.d_rsp_lane_mask,.d_rsp_numeric_error,.d_rsp_data,.d_pending_vectors,.d_in_flight_vectors,.d_in_flight_scalars,.d_protocol_fault);
endmodule
