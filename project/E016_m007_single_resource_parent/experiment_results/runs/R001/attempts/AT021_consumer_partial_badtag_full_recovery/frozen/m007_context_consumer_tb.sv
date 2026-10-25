`timescale 1ns/1ps
module m007_context_consumer_tb;

 logic clk,rst_n,run_enable;
 logic cmd_valid;
 logic cmd_ready;
 logic cmd_slot;
 logic [15:0] cmd_k;
 logic [63:0] cmd_request;
 logic [31:0] cmd_generation,cmd_epoch;
 logic in_valid;
 logic in_ready;
 logic [31:0][31:0] in_data;
 logic [63:0] in_request;
 logic [31:0] in_generation,in_epoch;
 logic [7:0] in_row,in_group;
 logic producer_close_valid;
 logic producer_close_ready;
 logic producer_close_success;
 logic done_valid;
 logic done_ready;
 logic [2:0] status;
 logic [2:0] quant_phase;
 logic [6:0] quant_row,quant_group;
 logic [4:0] quant_element;
 logic [31:0] quant_accepted,quant_retired,a_writes,a_write_acks;
 logic quant_last_event,a_publish_event;
 logic acfg_valid;
 logic acfg_ready;
 logic acfg_slot;
 logic [15:0] acfg_k;
 logic [63:0] acfg_request;
 logic [31:0] acfg_generation,acfg_epoch;
 logic acfg_rsp_valid;
 logic acfg_rsp_ready;
 logic [1:0] acfg_status;
 logic awr_valid;
 logic awr_ready;
 logic [6:0] awr_row,awr_group;
 logic [271:0] awr_data;
 logic [63:0] awr_request;
 logic [31:0] awr_generation,awr_epoch;
 logic awr_rsp_valid;
 logic awr_rsp_ready;
 logic fill_cancel_valid;
 logic fill_cancel_ready;
 logic fill_cancel_slot;
 logic [63:0] fill_cancel_request;
 logic [31:0] fill_cancel_generation,fill_cancel_epoch;
 logic fill_cancel_reject_valid;
 logic [3:0] fill_cancel_reject_code;
 logic fill_cancel_rsp_valid;
 logic fill_cancel_rsp_ready;
 logic fill_cancel_rsp_slot;
 logic [63:0] fill_cancel_rsp_request;
 logic [31:0] fill_cancel_rsp_generation,fill_cancel_rsp_epoch;
 logic d_lease_valid;
 logic d_lease_ready;
 logic[63:0]d_lease_request_id;
 logic[31:0]d_lease_generation,d_lease_epoch;
 logic[3:0]d_lease_head;
 logic[2:0]d_lease_phase;
 logic d_release_valid;
 logic d_release_ready;
 logic[2:0]d_release_phase;
 logic[31:0]d_release_epoch;
 logic d_phase_debt_clear;
 logic d_lease_active,d_draining;
 logic[63:0]d_rsp_request_id;
 logic[31:0]d_rsp_generation,d_rsp_epoch;
 logic[3:0]d_rsp_head;
 logic[2:0]d_rsp_phase;
 logic d_req_valid;
 logic d_req_ready;
 logic[31:0]d_req_generation,d_req_epoch;
 logic[2:0]d_req_phase;
 logic[7:0]d_req_lane_mask;
 logic[95:0]d_req_tag;
 logic[7:0][31:0]d_req_a,d_req_b;
 logic d_protocol_reject_valid;
 logic[3:0]d_protocol_reject_code;
 logic d_rsp_valid;
 logic d_rsp_ready;
 logic[95:0]d_rsp_tag;
 logic[7:0]d_rsp_lane_mask,d_rsp_numeric_error;
 logic[7:0][31:0]d_rsp_data;
 logic[5:0]d_pending_vectors,d_in_flight_vectors;
 logic[8:0]d_in_flight_scalars;
 logic d_protocol_fault
;

 logic ack_enable=1,cancel_enable=1,cache_ack_valid,cache_cancel_valid,cache_cancel_slot;
 logic [6:0] cache_ack_row,cache_ack_group;
 logic [63:0] cache_cancel_request;logic [31:0] cache_cancel_generation,cache_cancel_epoch;
 logic [1:0] cache_slot_valid,cache_slot_leased;logic [6:0] cache_read_debt;
 logic a_lease_valid=0,a_lease_ready,a_lease_slot=1;logic [63:0] a_lease_request=0;logic [31:0] a_lease_generation=0,a_lease_epoch=0;
 logic a_rd_valid=0,a_rd_ready,a_rd_slot=1;logic [2:0] a_rd_m=0;logic [6:0] a_rd_group=0;logic [95:0] a_rd_tag=0;
 logic a_rsp_valid,a_rsp_ready=0,a_rsp_slot;logic [95:0] a_rsp_tag;logic [4351:0] a_rsp_data;
 logic a_ret_valid=0,a_ret_ready,a_release_valid=0,a_release_ready;logic [95:0] a_ret_tag=0;
 logic [1023:0] input_words[0:4095];logic [271:0] expected_a[0:4095];string fixture,input_fixture;
 integer cycle=0,actual_inputs=0,actual_quant_returns=0,actual_writes=0,actual_acks=0,actual_publications=0,actual_close_inputs=0,actual_close_groups=0;
 logic sender_closed=0;logic [63:0] previous_request=0;logic [31:0] previous_generation=0,previous_epoch=0;
 laya_m007_quant_a_fill_v1 front(.*);
 assign awr_rsp_valid=cache_ack_valid&&ack_enable;
 assign fill_cancel_rsp_valid=cache_cancel_valid&&cancel_enable;
 assign fill_cancel_rsp_slot=cache_cancel_slot;assign fill_cancel_rsp_request=cache_cancel_request;assign fill_cancel_rsp_generation=cache_cancel_generation;assign fill_cancel_rsp_epoch=cache_cancel_epoch;
 laya_m007_a_cache_v1 cache(.clk,.rst_n,
  .cfg_valid(acfg_valid),.cfg_ready(acfg_ready),.cfg_slot(acfg_slot),.cfg_k(acfg_k),.cfg_request(acfg_request),.cfg_generation(acfg_generation),.cfg_epoch(acfg_epoch),.cfg_rsp_valid(acfg_rsp_valid),.cfg_rsp_ready(acfg_rsp_ready),.cfg_status(acfg_status),.cfg_rsp_slot(),.cfg_rsp_k(),.cfg_rsp_request(),.cfg_rsp_generation(),.cfg_rsp_epoch(),.error_row(),.error_group(),
  .wr_valid(awr_valid),.wr_ready(awr_ready),.wr_row(awr_row),.wr_group(awr_group),.wr_data(awr_data),.wr_request(awr_request),.wr_generation(awr_generation),.wr_epoch(awr_epoch),.wr_rsp_valid(cache_ack_valid),.wr_rsp_ready(awr_rsp_ready&&ack_enable),.wr_rsp_row(cache_ack_row),.wr_rsp_group(cache_ack_group),
  .fill_cancel_valid,.fill_cancel_ready,.fill_cancel_slot,.fill_cancel_request,.fill_cancel_generation,.fill_cancel_epoch,.fill_cancel_reject_valid,.fill_cancel_reject_code,.fill_cancel_rsp_valid(cache_cancel_valid),.fill_cancel_rsp_ready(fill_cancel_rsp_ready&&cancel_enable),.fill_cancel_rsp_slot(cache_cancel_slot),.fill_cancel_rsp_request(cache_cancel_request),.fill_cancel_rsp_generation(cache_cancel_generation),.fill_cancel_rsp_epoch(cache_cancel_epoch),
  .lease_valid(a_lease_valid),.lease_ready(a_lease_ready),.lease_slot(a_lease_slot),.lease_request(a_lease_request),.lease_generation(a_lease_generation),.lease_epoch(a_lease_epoch),
  .rd_valid(a_rd_valid),.rd_ready(a_rd_ready),.rd_slot(a_rd_slot),.rd_m(a_rd_m),.rd_group(a_rd_group),.rd_tag(a_rd_tag),.rd_request(a_lease_request),.rd_generation(a_lease_generation),.rd_epoch(a_lease_epoch),.rd_rsp_valid(a_rsp_valid),.rd_rsp_ready(a_rsp_ready),.rd_rsp_slot(a_rsp_slot),.rd_rsp_tag(a_rsp_tag),.rd_rsp_data(a_rsp_data),
  .ret_valid(a_ret_valid),.ret_ready(a_ret_ready),.ret_slot(a_rd_slot),.ret_tag(a_ret_tag),.ret_request(a_lease_request),.ret_generation(a_lease_generation),.ret_epoch(a_lease_epoch),.release_valid(a_release_valid),.release_ready(a_release_ready),.release_slot(a_lease_slot),.release_request(a_lease_request),.release_generation(a_lease_generation),.release_epoch(a_lease_epoch),.slot_valid(cache_slot_valid),.slot_leased(cache_slot_leased),.read_debt(cache_read_debt));
 laya_shared_div8_v1 divider(.clk,.rst_n,
  .lease_valid(d_lease_valid),.lease_ready(d_lease_ready),.lease_request_id(d_lease_request_id),.lease_generation(d_lease_generation),.lease_epoch(d_lease_epoch),.lease_head(d_lease_head),.lease_phase(d_lease_phase),
  .release_valid(d_release_valid),.release_ready(d_release_ready),.release_phase(d_release_phase),.release_epoch(d_release_epoch),.phase_debt_clear(d_phase_debt_clear),.lease_active(d_lease_active),.draining(d_draining),.rsp_request_id(d_rsp_request_id),.rsp_generation(d_rsp_generation),.rsp_epoch(d_rsp_epoch),.rsp_head(d_rsp_head),.rsp_phase(d_rsp_phase),
  .req_valid(d_req_valid),.req_ready(d_req_ready),.req_generation(d_req_generation),.req_epoch(d_req_epoch),.req_phase(d_req_phase),.req_lane_mask(d_req_lane_mask),.req_tag(d_req_tag),.req_a(d_req_a),.req_b(d_req_b),.protocol_reject_valid(d_protocol_reject_valid),.protocol_reject_code(d_protocol_reject_code),.rsp_valid(d_rsp_valid),.rsp_ready(d_rsp_ready),.rsp_tag(d_rsp_tag),.rsp_lane_mask(d_rsp_lane_mask),.rsp_numeric_error(d_rsp_numeric_error),.rsp_data(d_rsp_data),.pending_vectors(d_pending_vectors),.in_flight_vectors(d_in_flight_vectors),.in_flight_scalars(d_in_flight_scalars),.protocol_fault(d_protocol_fault));

 logic adapter_start_ready,adapter_rd_valid,adapter_rd_ready,adapter_rsp_ready,adapter_idle,adapter_complete,adapter_fault;
 logic [31:0] adapter_rd_generation,adapter_rd_tag;logic [3:0] adapter_rd_head;logic [6:0] adapter_rd_query;logic adapter_rd_half;
 logic peer_rsp_valid=0;logic [31:0] peer_rsp_tag=0;logic [1023:0] peer_rsp_data=0;
 logic cancel_consumer=0,inject_bad_tag=0;integer bad_tag_drains=0;logic close_accepted=0;logic [12:0] adapter_reads,adapter_consumed;
 integer peer_requests=0,peer_responses=0,checked_words=0,last_checked=0;
 assign in_request=cmd_request;assign in_generation=cmd_generation;assign in_epoch=cmd_epoch;
 assign producer_close_valid=!close_accepted&&(cancel_consumer||adapter_fault||adapter_complete);
 assign producer_close_success=!cancel_consumer&&!adapter_fault;
 assign adapter_rd_ready=(!peer_rsp_valid||adapter_rsp_ready)&&cycle%7!=0;
 laya_m007_context_quant_adapter_v1 adapter(.clk,.rst_n,.start_valid(cmd_valid&&cmd_ready),.start_ready(adapter_start_ready),.generation(cmd_generation),.cancel(cancel_consumer),
  .rd_valid(adapter_rd_valid),.rd_ready(adapter_rd_ready),.rd_generation(adapter_rd_generation),.rd_tag(adapter_rd_tag),.rd_head(adapter_rd_head),.rd_query(adapter_rd_query),.rd_half(adapter_rd_half),
  .rsp_valid(peer_rsp_valid),.rsp_ready(adapter_rsp_ready),.rsp_tag(peer_rsp_tag),.rsp_data(peer_rsp_data),
  .out_valid(in_valid),.out_ready(in_ready),.out_data(in_data),.out_row(in_row),.out_group(in_group),.idle(adapter_idle),.complete(adapter_complete),.protocol_fault(adapter_fault),.accepted_reads(adapter_reads),.consumed_groups(adapter_consumed));
 always #1 clk=~clk;
 always @(posedge clk)begin
  cycle=cycle+1;
  if(cycle>200000)$fatal(1,"context consumer bounded watchdog");
  if(!rst_n)begin peer_rsp_valid<=0;peer_rsp_tag<=0;peer_rsp_data<=0;end
  else begin
   if(adapter_rd_valid&&adapter_rd_ready)begin
    integer group_index;group_index=32*adapter_rd_query+2*adapter_rd_head+adapter_rd_half;
    if(group_index!=peer_requests||adapter_rd_tag!=peer_requests||adapter_rd_generation!=cmd_generation)$fatal(1,"actual public query/head/half order");
    peer_rsp_valid<=1;peer_rsp_tag<=(inject_bad_tag&&group_index==17)?32'hffff0000:adapter_rd_tag;peer_rsp_data<=input_words[group_index];peer_requests=peer_requests+1;
   end else if(peer_rsp_valid&&adapter_rsp_ready)peer_rsp_valid<=0;
   if(peer_rsp_valid&&adapter_rsp_ready)begin peer_responses=peer_responses+1;if(inject_bad_tag&&peer_rsp_tag==32'hffff0000)begin if(adapter_rd_valid&&adapter_rd_ready)$fatal(1,"known bad response tag accepted a continuation read");bad_tag_drains=bad_tag_drains+1;end end
   if(in_valid&&in_ready)begin if(in_row!=actual_inputs/32||in_group!=actual_inputs%32||in_data!==input_words[actual_inputs])$fatal(1,"actual context response to quant group");actual_inputs=actual_inputs+1;end
   if(front.q_out_valid&&front.q_out_ready)actual_quant_returns=actual_quant_returns+1;
   if(awr_valid&&awr_ready)begin
    if(awr_data!==expected_a[32*awr_row+awr_group])$fatal(1,"original context actual quant/A bytes");actual_writes=actual_writes+1;checked_words=checked_words+32;
    if(checked_words-last_checked>=4096)begin $display("M007_PARENT_CHECKED checked=%0d phase=CONTEXT_QUANT_A cycle=%0d",checked_words,cycle);$fflush();last_checked=checked_words;end
   end
   if(awr_rsp_valid&&awr_rsp_ready)actual_acks=actual_acks+1;
   if(acfg_rsp_valid&&acfg_rsp_ready)actual_publications=actual_publications+1;
   if(producer_close_valid&&producer_close_ready)close_accepted=1;
   if((adapter_fault&&!adapter_idle&&!inject_bad_tag&&!cmd_valid)||fill_cancel_reject_valid||d_protocol_fault||front.q_fault)$fatal(1,"actual context consumer resource/identity fault");
  end
 end
 task automatic step;@(posedge clk);#0.1;endtask
 task automatic begin_transfer;
  begin
   @(negedge clk);cmd_request=cmd_request+1;cmd_generation=cmd_generation+1;cmd_epoch=cmd_epoch+1;
   cancel_consumer=0;close_accepted=0;actual_inputs=0;actual_quant_returns=0;actual_writes=0;actual_acks=0;actual_publications=0;peer_requests=0;peer_responses=0;
   cmd_valid=1;#0.1;if(!cmd_ready||!adapter_start_ready)$fatal(1,"real consumer new owner start");step();@(negedge clk);cmd_valid=0;
  end
 endtask
 task automatic retire_transfer(input logic failed);
  begin
   wait(done_valid);@(negedge clk);
   if(status!=(failed?3:0)||!adapter_idle||peer_rsp_valid||d_lease_active||front.q_lease_active||front.q_reservations!=0||front.a_write_debt!=0||actual_inputs!=actual_quant_returns||actual_writes!=actual_acks)$fatal(1,"real consumer drain/retirement");
   if(failed)begin if(cache_slot_valid[0]||actual_publications!=0||actual_inputs==0||actual_inputs>=4096||peer_requests!=peer_responses)$fatal(1,"partial consumer actual cancel");end
   else if(actual_inputs!=4096||actual_writes!=4096||actual_acks!=4096||actual_publications!=1||!cache_slot_valid[0]||peer_requests!=4096||peer_responses!=4096||!adapter_complete)$fatal(1,"complete consumer actual coverage/publication");
   repeat(5)begin step();if(!done_valid||status!=(failed?3:0)||cmd_ready)$fatal(1,"held consumer done");end
   $display("M007_CONTEXT_CONSUMER_PASS failed=%0d public_reads=%0d responses=%0d actual_quant_groups=%0d physical_Awrites=%0d Aacks=%0d publications=%0d generation=%0d no_reset=1",failed,peer_requests,peer_responses,actual_inputs,actual_writes,actual_acks,actual_publications,cmd_generation);$fflush();
   @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;wait(cmd_ready);
  end
 endtask
 initial begin
  clk=0;rst_n=0;run_enable=1;cmd_valid=0;cmd_slot=0;cmd_k=1024;cmd_request=100;cmd_generation=40;cmd_epoch=50;done_ready=0;ack_enable=1;cancel_enable=1;
  if(!$value$plusargs("CONTEXT=%s",fixture))$fatal(1,"CONTEXT fixture required");
  $readmemh({fixture,"/wo_0_weight/input.hex"},input_words);$readmemh({fixture,"/wo_0_weight/a_write.hex"},expected_a);
  repeat(4)step();@(negedge clk);rst_n=1;
  begin_transfer();
  while(adapter_consumed<117)@(negedge clk);
  if(!d_lease_active||front.q_reservations==0||d_in_flight_vectors+d_pending_vectors==0)$fatal(1,"partial consumer cancel lacks real quant/DIV debt");
  $display("M007_CONTEXT_PARTIAL_CANCEL actual_consumed=%0d actual_reads=%0d pending_DIV=%0d in_flight_DIV=%0d quant_reservations=%0d",adapter_consumed,adapter_reads,d_pending_vectors,d_in_flight_vectors,front.q_reservations);$fflush();
  cancel_consumer=1;retire_transfer(1);
  inject_bad_tag=1;begin_transfer();retire_transfer(1);
  if(!adapter_fault||bad_tag_drains!=1||peer_requests!=18||actual_inputs!=17)$fatal(1,"actual malformed public response did not stop exactly at its real credit");
  $display("M007_CONTEXT_BADTAG_PASS accepted_reads=18 actual_consumed=17 bad_response_drain=1 continuation_read_same_edge=0 no_reset=1");$fflush();
  inject_bad_tag=0;begin_transfer();
  wait(peer_rsp_valid&&peer_rsp_tag==4095);@(negedge clk);run_enable=0;
  repeat(12)begin step();if(!peer_rsp_valid||peer_rsp_tag!=4095||peer_rsp_data!==input_words[4095]||adapter_complete||adapter_consumed!=4095||actual_publications!=0||done_valid)$fatal(1,"held last public response created early consumer completion");end
  @(negedge clk);run_enable=1;retire_transfer(0);
  $display("HARDWARE_AGENT_SIM_PASS M007_CONTEXT_CONSUMER partial_real_debt_cancel_badtag_and_noreset4096_recovery=1 held_last_response12=1 peer_scope_only_not_actual_layer16=1");$fflush();$finish;
 end
endmodule
