`timescale 1ns/1ps
// One matrix descriptor, one existing compute/restore core, one A/W cache pair.
module laya_m007_matrix_f32_v1 #(parameter bit PROFILE_ENABLE=0)(
 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,input logic [31:0] cmd_version,
 input logic [63:0] cmd_request,cmd_model,input logic [31:0] cmd_generation,cmd_epoch,cmd_tensor,
 input logic [15:0] cmd_k,cmd_n,input logic cmd_a_slot,cmd_bias,
 input logic [3:0][63:0] cmd_base,cmd_span,
 input logic in_valid,output logic in_ready,input logic [31:0][31:0] in_data,
 input logic [63:0] in_request,input logic [31:0] in_generation,in_epoch,input logic [7:0] in_row,in_group,
 output logic input_reject_valid,output logic [3:0] input_reject_code,
 output logic [1:0] error_domain,output logic [2:0] quant_phase,output logic [6:0] quant_row,quant_group,output logic [4:0] quant_element,
 output logic [31:0] first_input_cycle,last_input_cycle,quant_last_cycle,a_publish_cycle,first_w_cycle,first_matrix_cycle,matrix_elapsed_cycles,
 output logic [31:0] quant_accepted,quant_retired,a_writes,a_write_acks,
 output logic done_valid,input logic done_ready,output logic [2:0] status,
 output logic [63:0] done_request,output logic [31:0] done_generation,done_epoch,
 output logic [6:0] error_row,output logic [15:0] error_col,output logic [7:0] error_group,output logic [3:0] error_stage,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [6:0] out_row,output logic [15:0] out_col,out_s,
 output logic [63:0] out_request,output logic [31:0] out_generation,out_epoch,
 input logic coef_cfg_valid,output logic coef_cfg_ready,input logic [63:0] coef_model,coef_request,input logic [31:0] coef_tensor,coef_generation,coef_epoch,input logic [15:0] coef_n,
 input logic coef_wr_valid,output logic coef_wr_ready,input logic [6:0] coef_wr_addr,input logic [31:0][31:0] coef_wr_data,
 output logic coef_rsp_valid,input logic coef_rsp_ready,output logic [1:0] coef_status,output logic [15:0] coef_error_col,
 output logic [3:0] arvalid,input logic [3:0] arready,output logic [3:0][63:0] araddr,output logic [3:0][2:0] arid,output logic [3:0][7:0] arlen,
 input logic [3:0] rvalid,output logic [3:0] rready,input logic [3:0][2:0] rid,input logic [3:0][511:0] rdata,input logic [3:0][1:0] rresp,input logic [3:0] rlast,
 input logic run_enable,
 output logic [31:0] elapsed_cycles,first_output_cycle,w_wait_cycles,ctx_wait_cycles,
 output logic [15:0] blocks_issued,blocks_computed,blocks_retired,
 output logic [31:0] ps_merged_reads,ps_response_holds,bias_add_conflicts,compute_output_overlap,
 output logic [7:0] peak_return_reservations,output logic [6:0] arithmetic_debt,peak_arithmetic_reservations
);
 logic d_lease_valid,d_lease_ready;logic[63:0]d_lease_request_id;
 logic[31:0]d_lease_generation,d_lease_epoch;logic[3:0]d_lease_head;logic[2:0]d_lease_phase;
 logic d_release_valid,d_release_ready;logic[2:0]d_release_phase;logic[31:0]d_release_epoch;
 logic d_phase_debt_clear,d_lease_active,d_draining;logic[63:0]d_rsp_request_id;
 logic[31:0]d_rsp_generation,d_rsp_epoch;logic[3:0]d_rsp_head;logic[2:0]d_rsp_phase;
 logic d_req_valid,d_req_ready;logic[31:0]d_req_generation,d_req_epoch;logic[2:0]d_req_phase;
 logic[7:0]d_req_lane_mask;logic[95:0]d_req_tag;logic[7:0][31:0]d_req_a,d_req_b;
 logic d_protocol_reject_valid;logic[3:0]d_protocol_reject_code;
 logic d_rsp_valid,d_rsp_ready;logic[95:0]d_rsp_tag;
 logic[7:0]d_rsp_lane_mask,d_rsp_numeric_error;logic[7:0][31:0]d_rsp_data;
 logic[5:0]d_pending_vectors,d_in_flight_vectors;logic[8:0]d_in_flight_scalars;logic d_protocol_fault;


 localparam logic [2:0] IDLE=0,Q_SUBMIT=1,Q_RUN=2,M_SUBMIT=3,M_RUN=4,FINISH=5;
 logic [2:0] state;logic [31:0] version,generation,epoch,tensor,tick,total_groups;
 logic [63:0] request_id,model;logic [15:0] k,n;logic a_slot,bias;logic [3:0][63:0] base,span;
 logic [7:0] groups,expect_row,expect_group;logic [31:0] inputs_accepted;
 logic input_legal,fill_cmd_valid,fill_cmd_ready,fill_in_ready,fill_done_valid,producer_close_ready;
 logic [2:0] fill_status,fill_quant_phase;logic [6:0] fill_quant_row,fill_quant_group;logic [4:0] fill_quant_element;logic quant_last_event,a_publish_event;
 logic matrix_cmd_valid,matrix_cmd_ready,matrix_descriptor_precheck_ok,matrix_done_valid;
 logic [2:0] matrix_status;logic [63:0] matrix_done_request;logic [31:0] matrix_done_generation,matrix_done_epoch,matrix_first_output;
 logic [6:0] matrix_error_row;logic [15:0] matrix_error_col;logic [7:0] matrix_error_group;logic [3:0] matrix_error_stage;
 logic acfg_valid,acfg_ready,acfg_slot,acfg_rsp_valid,acfg_rsp_ready;logic [1:0] acfg_status;logic [15:0] acfg_k;
 logic [63:0] acfg_request;logic [31:0] acfg_generation,acfg_epoch;
 logic awr_valid,awr_ready,awr_rsp_valid,awr_rsp_ready;logic [6:0] awr_row,awr_group;logic [271:0] awr_data;
 logic [63:0] awr_request;logic [31:0] awr_generation,awr_epoch;
 logic fill_cancel_valid,fill_cancel_ready,fill_cancel_slot,fill_cancel_reject_valid,fill_cancel_rsp_valid,fill_cancel_rsp_ready,fill_cancel_rsp_slot;
 logic [3:0] fill_cancel_reject_code;logic [63:0] fill_cancel_request,fill_cancel_rsp_request;logic [31:0] fill_cancel_generation,fill_cancel_epoch,fill_cancel_rsp_generation,fill_cancel_rsp_epoch;
 logic coef_cfg_ready_internal,coef_wr_ready_internal;
 wire input_fire=in_valid&&in_ready;
 always_comb begin
  quant_phase=error_domain==2?fill_quant_phase:0;quant_row=error_domain==2?fill_quant_row:0;quant_group=error_domain==2?fill_quant_group:0;quant_element=error_domain==2?fill_quant_element:0;
  cmd_ready=rst_n&&state==IDLE&&!done_valid&&matrix_cmd_ready&&!coef_cfg_valid&&!coef_wr_valid;
  input_legal=state==Q_RUN&&inputs_accepted<total_groups&&in_request==request_id&&in_generation==generation&&in_epoch==epoch&&in_row==expect_row&&in_group==expect_group;
  in_ready=rst_n&&input_legal&&fill_in_ready;
  input_reject_code=0;
  if(in_valid)begin
   if(state!=Q_RUN||inputs_accepted>=total_groups)input_reject_code=1;
   else if(in_request!=request_id)input_reject_code=2;
   else if(in_generation!=generation)input_reject_code=3;
   else if(in_epoch!=epoch)input_reject_code=4;
   else if(in_row!=expect_row)input_reject_code=5;
   else if(in_group!=expect_group)input_reject_code=6;
  end
  input_reject_valid=rst_n&&input_reject_code!=0;
  fill_cmd_valid=state==Q_SUBMIT;
  matrix_cmd_valid=state==M_SUBMIT;
  coef_cfg_ready=state==IDLE&&!done_valid&&coef_cfg_ready_internal;
  coef_wr_ready=state==IDLE&&!done_valid&&coef_wr_ready_internal;
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   state<=IDLE;version<=0;generation<=0;epoch<=0;tensor<=0;tick<=0;total_groups<=0;request_id<=0;model<=0;k<=0;n<=0;a_slot<=0;bias<=0;base<=0;span<=0;groups<=0;expect_row<=0;expect_group<=0;inputs_accepted<=0;
   done_valid<=0;status<=0;done_request<=0;done_generation<=0;done_epoch<=0;error_domain<=0;error_row<=0;error_col<=0;error_group<=0;error_stage<=0;
   elapsed_cycles<=0;first_output_cycle<=0;first_input_cycle<=0;last_input_cycle<=0;quant_last_cycle<=0;a_publish_cycle<=0;first_w_cycle<=0;first_matrix_cycle<=0;
  end else begin
   if(state!=IDLE&&state!=FINISH)tick<=tick+1;
   if(done_valid&&done_ready)begin done_valid<=0;state<=IDLE;end
   if(cmd_valid&&cmd_ready)begin
    version<=cmd_version;generation<=cmd_generation;epoch<=cmd_epoch;tensor<=cmd_tensor;request_id<=cmd_request;model<=cmd_model;k<=cmd_k;n<=cmd_n;a_slot<=cmd_a_slot;bias<=cmd_bias;base<=cmd_base;span<=cmd_span;groups<=cmd_k>>5;total_groups<=128*(cmd_k>>5);expect_row<=0;expect_group<=0;inputs_accepted<=0;tick<=1;
    status<=0;done_request<=cmd_request;done_generation<=cmd_generation;done_epoch<=cmd_epoch;error_domain<=0;error_row<=0;error_col<=0;error_group<=0;error_stage<=0;
    elapsed_cycles<=0;first_output_cycle<=0;first_input_cycle<=0;last_input_cycle<=0;quant_last_cycle<=0;a_publish_cycle<=0;first_w_cycle<=0;first_matrix_cycle<=0;
    if(!matrix_descriptor_precheck_ok)begin done_valid<=1;status<=1;error_domain<=1;state<=FINISH;end else state<=Q_SUBMIT;
   end
   if(fill_cmd_valid&&fill_cmd_ready)state<=Q_RUN;
   if(input_fire)begin
    if(inputs_accepted==0)first_input_cycle<=tick;last_input_cycle<=tick;inputs_accepted<=inputs_accepted+1;
    if(expect_group+1==groups)begin expect_group<=0;expect_row<=expect_row+1;end else expect_group<=expect_group+1;
   end
   if(quant_last_event)quant_last_cycle<=tick;
   if(a_publish_event)a_publish_cycle<=tick;
   if(state==Q_RUN&&fill_done_valid&&run_enable)begin
    if(fill_status==0)state<=M_SUBMIT;
    else begin status<=fill_status;error_domain<=2;done_valid<=1;elapsed_cycles<=tick;state<=FINISH;end
   end
   if(matrix_cmd_valid&&matrix_cmd_ready)begin state<=M_RUN;first_matrix_cycle<=tick;end
   if(first_w_cycle==0&&|(arvalid&arready))first_w_cycle<=tick;
   if(first_output_cycle==0&&out_valid&&out_ready)first_output_cycle<=tick;
   if(state==M_RUN&&matrix_done_valid&&run_enable)begin
    status<=matrix_status;error_domain<=matrix_status==0?0:3;error_row<=matrix_error_row;error_col<=matrix_error_col;error_group<=matrix_error_group;error_stage<=matrix_error_stage;
    done_valid<=1;elapsed_cycles<=tick;state<=FINISH;
   end
  end
 end
 laya_m007_quant_a_fill_v1 front(
  .clk,.rst_n,.run_enable,.cmd_valid(fill_cmd_valid),.cmd_ready(fill_cmd_ready),.cmd_slot(a_slot),.cmd_k(k),.cmd_request(request_id),.cmd_generation(generation),.cmd_epoch(epoch),
  .in_valid(in_valid&&input_legal),.in_ready(fill_in_ready),.in_data,.in_request,.in_generation,.in_epoch,.in_row,.in_group,
  .producer_close_valid(state==Q_RUN&&inputs_accepted==total_groups),.producer_close_ready,.producer_close_success(1'b1),
  .done_valid(fill_done_valid),.done_ready(state==Q_RUN&&run_enable),.status(fill_status),.quant_phase(fill_quant_phase),.quant_row(fill_quant_row),.quant_group(fill_quant_group),.quant_element(fill_quant_element),
  .quant_accepted,.quant_retired,.a_writes,.a_write_acks,.quant_last_event,.a_publish_event,
  .acfg_valid,.acfg_ready,.acfg_slot,.acfg_k,.acfg_request,.acfg_generation,.acfg_epoch,.acfg_rsp_valid,.acfg_rsp_ready,.acfg_status,
  .awr_valid,.awr_ready,.awr_row,.awr_group,.awr_data,.awr_request,.awr_generation,.awr_epoch,.awr_rsp_valid,.awr_rsp_ready,
  .fill_cancel_valid,.fill_cancel_ready,.fill_cancel_slot,.fill_cancel_request,.fill_cancel_generation,.fill_cancel_epoch,.fill_cancel_reject_valid,.fill_cancel_reject_code,.fill_cancel_rsp_valid,.fill_cancel_rsp_ready,.fill_cancel_rsp_slot,.fill_cancel_rsp_request,.fill_cancel_rsp_generation,.fill_cancel_rsp_epoch,
  .d_lease_valid,.d_lease_ready,.d_lease_request_id,.d_lease_generation,.d_lease_epoch,.d_lease_head,.d_lease_phase,.d_release_valid,.d_release_ready,.d_release_phase,.d_release_epoch,.d_phase_debt_clear,.d_lease_active,.d_draining,.d_rsp_request_id,.d_rsp_generation,.d_rsp_epoch,.d_rsp_head,.d_rsp_phase,.d_req_valid,.d_req_ready,.d_req_generation,.d_req_epoch,.d_req_phase,.d_req_lane_mask,.d_req_tag,.d_req_a,.d_req_b,.d_protocol_reject_valid,.d_protocol_reject_code,.d_rsp_valid,.d_rsp_ready,.d_rsp_tag,.d_rsp_lane_mask,.d_rsp_numeric_error,.d_rsp_data,.d_pending_vectors,.d_in_flight_vectors,.d_in_flight_scalars,.d_protocol_fault);
 laya_shared_div8_v1 divider(.clk,.rst_n,
  .lease_valid(d_lease_valid),.lease_ready(d_lease_ready),.lease_request_id(d_lease_request_id),
  .lease_generation(d_lease_generation),.lease_epoch(d_lease_epoch),.lease_head(d_lease_head),.lease_phase(d_lease_phase),
  .release_valid(d_release_valid),.release_ready(d_release_ready),.release_phase(d_release_phase),.release_epoch(d_release_epoch),.phase_debt_clear(d_phase_debt_clear),
  .lease_active(d_lease_active),.draining(d_draining),.rsp_request_id(d_rsp_request_id),.rsp_generation(d_rsp_generation),.rsp_epoch(d_rsp_epoch),.rsp_head(d_rsp_head),.rsp_phase(d_rsp_phase),
  .req_valid(d_req_valid),.req_ready(d_req_ready),.req_generation(d_req_generation),.req_epoch(d_req_epoch),.req_phase(d_req_phase),.req_lane_mask(d_req_lane_mask),.req_tag(d_req_tag),.req_a(d_req_a),.req_b(d_req_b),
  .protocol_reject_valid(d_protocol_reject_valid),.protocol_reject_code(d_protocol_reject_code),
  .rsp_valid(d_rsp_valid),.rsp_ready(d_rsp_ready),.rsp_tag(d_rsp_tag),.rsp_lane_mask(d_rsp_lane_mask),.rsp_numeric_error(d_rsp_numeric_error),.rsp_data(d_rsp_data),
  .pending_vectors(d_pending_vectors),.in_flight_vectors(d_in_flight_vectors),.in_flight_scalars(d_in_flight_scalars),.protocol_fault(d_protocol_fault));
 laya_m007_matrix_full_v1 #(.PROFILE_ENABLE(PROFILE_ENABLE)) matrix(
  .clk,.rst_n,.cmd_valid(matrix_cmd_valid),.cmd_ready(matrix_cmd_ready),.descriptor_precheck_ok(matrix_descriptor_precheck_ok),
  .cmd_version(state==IDLE?cmd_version:version),.cmd_request(state==IDLE?cmd_request:request_id),.cmd_model(state==IDLE?cmd_model:model),.cmd_generation(state==IDLE?cmd_generation:generation),.cmd_epoch(state==IDLE?cmd_epoch:epoch),.cmd_tensor(state==IDLE?cmd_tensor:tensor),.cmd_k(state==IDLE?cmd_k:k),.cmd_n(state==IDLE?cmd_n:n),.cmd_a_slot(state==IDLE?cmd_a_slot:a_slot),.cmd_bias(state==IDLE?cmd_bias:bias),.cmd_base(state==IDLE?cmd_base:base),.cmd_span(state==IDLE?cmd_span:span),
  .done_valid(matrix_done_valid),.done_ready(state==M_RUN&&run_enable),.status(matrix_status),.done_request(matrix_done_request),.done_generation(matrix_done_generation),.done_epoch(matrix_done_epoch),.error_row(matrix_error_row),.error_col(matrix_error_col),.error_group(matrix_error_group),.error_stage(matrix_error_stage),
  .acfg_valid,.acfg_ready,.acfg_slot,.acfg_k,.acfg_request,.acfg_generation,.acfg_epoch,.acfg_rsp_valid,.acfg_rsp_ready,.acfg_status,
  .awr_valid,.awr_ready,.awr_row,.awr_group,.awr_data,.awr_request,.awr_generation,.awr_epoch,.awr_rsp_valid,.awr_rsp_ready,
  .fill_cancel_valid,.fill_cancel_ready,.fill_cancel_slot,.fill_cancel_request,.fill_cancel_generation,.fill_cancel_epoch,.fill_cancel_reject_valid,.fill_cancel_reject_code,.fill_cancel_rsp_valid,.fill_cancel_rsp_ready,.fill_cancel_rsp_slot,.fill_cancel_rsp_request,.fill_cancel_rsp_generation,.fill_cancel_rsp_epoch,
  .coef_cfg_valid(coef_cfg_valid&&state==IDLE&&!done_valid),.coef_cfg_ready(coef_cfg_ready_internal),.coef_wr_valid(coef_wr_valid&&state==IDLE&&!done_valid),.coef_wr_ready(coef_wr_ready_internal),
  .elapsed_cycles(matrix_elapsed_cycles),.first_output_cycle(matrix_first_output),.*);
endmodule
