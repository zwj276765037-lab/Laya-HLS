from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];B=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';M=B/'forward_controller'
s=(B/'q8_linear_and_restore/tb/m007_matrix_producer_cancel_tb.sv').read_text();s=s[:s.index(' always #1 clk=~clk;')].replace('module m007_matrix_producer_cancel_tb #(parameter bit PROFILE_ENABLE=0);','module m007_context_consumer_tb;')
s+='''
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
'''
(M/'tb/m007_context_consumer_tb.sv').write_text(s)
print('M007_CONTEXT_CONSUMER_TB_SOURCE_WRITTEN')
