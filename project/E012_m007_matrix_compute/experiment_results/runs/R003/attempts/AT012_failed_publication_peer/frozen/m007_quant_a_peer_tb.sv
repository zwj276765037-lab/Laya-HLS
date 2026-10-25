`timescale 1ns/1ps
// Explicit legal-interface failure-publication peer. This validates pure adapter
// control and actual quant/DIV only; it is not evidence of a real A-cache failure.
module m007_quant_a_peer_tb;
 logic clk=0;always #1 clk=~clk;logic rst_n=0,run_enable=1;
 logic cmd_valid=0,cmd_ready,cmd_slot=0;logic [15:0] cmd_k=1024;
 logic [63:0] cmd_request=1;logic [31:0] cmd_generation=1,cmd_epoch=1;
 logic in_valid=0,in_ready;logic [31:0][31:0] in_data;
 logic [63:0] in_request;logic [31:0] in_generation,in_epoch;logic [7:0] in_row,in_group;
 logic producer_close_valid=0,producer_close_ready,producer_close_success=1;
 logic done_valid,done_ready=0;logic [2:0] status,quant_phase;logic [6:0] quant_row,quant_group;logic [4:0] quant_element;
 logic [31:0] quant_accepted,quant_retired,a_writes,a_write_acks;logic quant_last_event,a_publish_event;
 logic acfg_valid;logic acfg_ready;logic acfg_slot;logic [15:0] acfg_k;
 logic [63:0] acfg_request;logic [31:0] acfg_generation,acfg_epoch;
 logic acfg_rsp_valid;logic acfg_rsp_ready;logic [1:0] acfg_status;
 logic awr_valid;logic awr_ready;logic [6:0] awr_row,awr_group;logic [271:0] awr_data;
 logic [63:0] awr_request;logic [31:0] awr_generation,awr_epoch;
 logic awr_rsp_valid;logic awr_rsp_ready;
 logic fill_cancel_valid;logic fill_cancel_ready;logic fill_cancel_slot;
 logic [63:0] fill_cancel_request;logic [31:0] fill_cancel_generation,fill_cancel_epoch;
 logic fill_cancel_reject_valid;logic [3:0] fill_cancel_reject_code;
 logic fill_cancel_rsp_valid;logic fill_cancel_rsp_ready;logic fill_cancel_rsp_slot;
 logic [63:0] fill_cancel_rsp_request;logic [31:0] fill_cancel_rsp_generation,fill_cancel_rsp_epoch;
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


 laya_m007_quant_a_fill_v1 dut(.*);
 logic [1023:0] inputs[0:4095];logic [271:0] expected[0:4095];
 string fixture,input_fixture;
 integer cycle=0,operation=0,writes=0,acks=0,total_writes=0,total_acks=0,publications=0,close_count=0;
 logic peer_filling=0,peer_failure=1;
 assign acfg_ready=rst_n&&!peer_filling&&!acfg_rsp_valid&&!awr_rsp_valid;
 assign awr_ready=rst_n&&peer_filling&&writes<4096&&(!awr_rsp_valid||awr_rsp_ready);
 assign fill_cancel_ready=0;assign fill_cancel_reject_valid=fill_cancel_valid;assign fill_cancel_reject_code=2;
 assign fill_cancel_rsp_valid=0;assign fill_cancel_rsp_slot=0;assign fill_cancel_rsp_request=0;assign fill_cancel_rsp_generation=0;assign fill_cancel_rsp_epoch=0;
 always @(posedge clk)begin
  cycle<=cycle+1;
  if(!rst_n)begin acfg_rsp_valid<=0;acfg_status<=0;awr_rsp_valid<=0;peer_filling<=0;end
  else begin
   if(acfg_valid&&acfg_ready)begin peer_filling<=1;writes=0;acks=0;end
   if(awr_rsp_valid&&awr_rsp_ready)begin awr_rsp_valid<=0;acks=acks+1;total_acks=total_acks+1;end
   if(awr_valid&&awr_ready)begin
    if(awr_request!=cmd_request||awr_generation!=cmd_generation||awr_epoch!=cmd_epoch||awr_data!==expected[awr_row*32+awr_group])$fatal(1,"peer actual quant bytes/identity");
    writes=writes+1;total_writes=total_writes+1;awr_rsp_valid<=1;
   end
   if(peer_filling&&writes==4096&&acks==4096&&!awr_rsp_valid)begin peer_filling<=0;acfg_rsp_valid<=1;acfg_status<=peer_failure?2:0;end
   if(acfg_rsp_valid&&acfg_rsp_ready)begin acfg_rsp_valid<=0;publications=publications+1;end
   if(producer_close_valid&&producer_close_ready)close_count=close_count+1;
   if(fill_cancel_valid)$fatal(1,"adapter demanded cancel after consumed failed publication");
  end
  if(cycle>10000)$fatal(1,"failed-publication adapter bounded watchdog");
 end
 task automatic operation_task(input logic fail);
  integer start;
  peer_failure=fail;
  @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;
  for(integer i=0;i<4096;i++)begin
   @(negedge clk);in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=i/32;in_group=i%32;in_data=inputs[i];
   do @(posedge clk);while(!in_ready);
  end
  @(negedge clk);in_valid=0;producer_close_valid=1;do @(posedge clk);while(!producer_close_ready);@(negedge clk);producer_close_valid=0;
  start=cycle;wait(done_valid);@(negedge clk);
  if(status!=(fail?3:0)||writes!=4096||acks!=4096||a_writes!=4096||a_write_acks!=4096||quant_accepted!=4096||quant_retired!=4096||dut.q_reservations||d_lease_active||dut.a_write_debt||fail!=dut.a_failed_closed)$fatal(1,"peer adapter terminal status/debt");
  repeat(5)begin @(negedge clk);if(!done_valid||cmd_ready)$fatal(1,"peer done hold");end
  done_ready=1;@(negedge clk);done_ready=0;
  cmd_request=cmd_request+1;cmd_generation=cmd_generation+1;cmd_epoch=cmd_epoch+1;
 endtask
 initial begin
  if(!$value$plusargs("FIXTURE=%s",fixture)||!$value$plusargs("INPUT_FIXTURE=%s",input_fixture))$fatal(1,"fixture required");
  $readmemh({input_fixture,"/qkv_0_weight/input.hex"},inputs);$readmemh({fixture,"/qkv_0_weight/a_write.hex"},expected);
  repeat(5)@(negedge clk);rst_n=1;
  operation_task(1);operation_task(0);
  if(total_writes!=8192||total_acks!=8192||publications!=2||close_count!=2)$fatal(1,"peer exact actual counts");
  $display("HARDWARE_AGENT_SIM_PASS M007_QUANT_A_PEER failed_publication=1 no_reset_recovery=1 actual_quant_groups=%0d actual_A_peer_acks=%0d real_DIV=1 real_A_cache=0 cycles=%0d",total_writes,total_acks,cycle);$finish;
 end
 laya_shared_div8_v1 divider(.clk,.rst_n,
  .lease_valid(d_lease_valid),.lease_ready(d_lease_ready),.lease_request_id(d_lease_request_id),
  .lease_generation(d_lease_generation),.lease_epoch(d_lease_epoch),.lease_head(d_lease_head),.lease_phase(d_lease_phase),
  .release_valid(d_release_valid),.release_ready(d_release_ready),.release_phase(d_release_phase),.release_epoch(d_release_epoch),.phase_debt_clear(d_phase_debt_clear),
  .lease_active(d_lease_active),.draining(d_draining),.rsp_request_id(d_rsp_request_id),.rsp_generation(d_rsp_generation),.rsp_epoch(d_rsp_epoch),.rsp_head(d_rsp_head),.rsp_phase(d_rsp_phase),
  .req_valid(d_req_valid),.req_ready(d_req_ready),.req_generation(d_req_generation),.req_epoch(d_req_epoch),.req_phase(d_req_phase),.req_lane_mask(d_req_lane_mask),.req_tag(d_req_tag),.req_a(d_req_a),.req_b(d_req_b),
  .protocol_reject_valid(d_protocol_reject_valid),.protocol_reject_code(d_protocol_reject_code),
  .rsp_valid(d_rsp_valid),.rsp_ready(d_rsp_ready),.rsp_tag(d_rsp_tag),.rsp_lane_mask(d_rsp_lane_mask),.rsp_numeric_error(d_rsp_numeric_error),.rsp_data(d_rsp_data),
  .pending_vectors(d_pending_vectors),.in_flight_vectors(d_in_flight_vectors),.in_flight_scalars(d_in_flight_scalars),.protocol_fault(d_protocol_fault));
endmodule
