`timescale 1ns/1ps
module m007_matrix_producer_cancel_tb #(parameter bit PROFILE_ENABLE=0);

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
 always #1 clk=~clk;
 always @(posedge clk)begin
  cycle=cycle+1;
  if(cycle>100000)$fatal(1,"producer-close bounded watchdog");
  if(rst_n)begin
   if(in_valid&&in_ready)actual_inputs=actual_inputs+1;
   if(front.q_out_valid&&front.q_out_ready)actual_quant_returns=actual_quant_returns+1;
   if(awr_valid&&awr_ready)begin
    if(awr_data!==expected_a[32*awr_row+awr_group])$fatal(1,"real original quant/A bytes");actual_writes=actual_writes+1;
   end
   if(awr_rsp_valid&&awr_rsp_ready)actual_acks=actual_acks+1;
   if(acfg_rsp_valid&&acfg_rsp_ready)actual_publications=actual_publications+1;
   if(producer_close_valid&&producer_close_ready)begin actual_close_inputs=in_valid&&in_ready;actual_close_groups=actual_inputs;end
   if(front.producer_closed&&in_valid&&in_ready)$fatal(1,"accepted input after failed producer close");
   if(fill_cancel_reject_valid||d_protocol_fault||front.q_fault)$fatal(1,"unexpected physical cancel/DIV/quant protocol fault");
  end
 end
 task automatic begin_command(input logic slot);
  begin
   @(negedge clk);cmd_request=cmd_request+1;cmd_generation=cmd_generation+1;cmd_epoch=cmd_epoch+1;cmd_slot=slot;
   actual_inputs=0;actual_quant_returns=0;actual_writes=0;actual_acks=0;actual_publications=0;actual_close_inputs=0;actual_close_groups=0;sender_closed=0;
   ack_enable=1;cancel_enable=0;run_enable=1;cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;wait(front.state==2);
  end
 endtask
 task automatic send_until_close;
  integer idx;logic closed;
  begin
   idx=0;closed=0;
   while(!closed&&idx<4096)begin
    @(negedge clk);in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=idx/32;in_group=idx%32;in_data=input_words[idx];
    begin:accept_wait
     forever begin
      @(posedge clk);
      if(producer_close_valid&&producer_close_ready)begin closed=1;disable accept_wait;end
      if(in_ready)disable accept_wait;
     end
    end
    idx=idx+1;
   end
   @(negedge clk);in_valid=0;sender_closed=1;
  end
 endtask
 task automatic send_full;
  begin
   for(integer idx=0;idx<4096;idx++)begin
    @(negedge clk);in_valid=1;in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=idx/32;in_group=idx%32;in_data=input_words[idx];do @(posedge clk);while(!in_ready);
   end
   @(negedge clk);in_valid=0;
   producer_close_success=1;producer_close_valid=1;do @(posedge clk);while(!producer_close_ready);@(negedge clk);producer_close_valid=0;
  end
 endtask
 task automatic fail_close;
  begin
   producer_close_success=0;producer_close_valid=1;do @(posedge clk);while(!producer_close_ready);@(negedge clk);producer_close_valid=0;
  end
 endtask
 task automatic hold_cancel_response;
  logic [128:0] held;
  begin
   wait(cache_cancel_valid);@(negedge clk);held={cache_cancel_slot,cache_cancel_request,cache_cancel_generation,cache_cancel_epoch};
   if(held!={cmd_slot,cmd_request,cmd_generation,cmd_epoch})$fatal(1,"actual cancellation response identity");
   repeat(8)begin @(negedge clk);if(!cache_cancel_valid||{cache_cancel_slot,cache_cancel_request,cache_cancel_generation,cache_cancel_epoch}!==held||done_valid||cmd_ready||fill_cancel_rsp_valid)$fatal(1,"full physical cancel response hold");end
   cancel_enable=1;
  end
 endtask
 task automatic finish_response(input logic [2:0] expected);
  logic [153:0] held;
  begin
   wait(done_valid);@(negedge clk);
   if(status!=expected||quant_accepted!=actual_inputs||quant_retired!=actual_inputs||actual_quant_returns!=actual_inputs||a_writes!=actual_writes||a_write_acks!=actual_acks||actual_writes!=actual_acks||front.q_reservations||front.a_write_debt||d_lease_active||d_pending_vectors||d_in_flight_vectors||d_in_flight_scalars)$fatal(1,"producer close real accepted debt not drained status=%0d accepted=%0d quant_returns=%0d writes=%0d acks=%0d",status,actual_inputs,actual_quant_returns,actual_writes,actual_acks);
   held={acfg_request,acfg_generation,acfg_epoch,acfg_slot,status,quant_phase,quant_row,quant_group,quant_element};cmd_valid=1;
   repeat(5)begin @(negedge clk);if(!done_valid||cmd_ready||{acfg_request,acfg_generation,acfg_epoch,acfg_slot,status,quant_phase,quant_row,quant_group,quant_element}!==held)$fatal(1,"front full actual response fields/owner hold");end
   cmd_valid=0;done_ready=1;@(negedge clk);done_ready=0;
  end
 endtask
 task automatic scan_slot1(input logic [63:0] request,input logic [31:0] gen,ep);
  logic [4351:0] expected;
  begin
   expected=0;for(integer r=0;r<16;r++)begin expected[256*r+:256]=expected_a[32*r][255:0];expected[4096+16*r+:16]=expected_a[32*r][271:256];end
   @(negedge clk);a_lease_request=request;a_lease_generation=gen;a_lease_epoch=ep;a_lease_valid=1;do @(posedge clk);while(!a_lease_ready);@(negedge clk);a_lease_valid=0;
   a_rd_tag={ep,gen,32'hc1000001};a_rd_valid=1;do @(posedge clk);while(!a_rd_ready);@(negedge clk);a_rd_valid=0;wait(a_rsp_valid);
   repeat(5)begin @(negedge clk);if(a_rsp_data!==expected||a_rsp_tag!==a_rd_tag||!a_rsp_slot||!a_rsp_valid)$fatal(1,"real preserved/published other-slot public read/hold");end
   a_rsp_ready=1;@(negedge clk);a_rsp_ready=0;a_ret_tag=a_rd_tag;a_ret_valid=1;do @(posedge clk);while(!a_ret_ready);@(negedge clk);a_ret_valid=0;a_release_valid=1;do @(posedge clk);while(!a_release_ready);@(negedge clk);a_release_valid=0;
  end
 endtask
 task automatic successful_recovery;
  begin
   begin_command(1);cancel_enable=1;send_full;finish_response(0);
   if(actual_inputs!=4096||actual_writes!=4096||actual_publications!=1||!cache_slot_valid[1])$fatal(1,"new-generation real full requantization/publication");
   previous_request=cmd_request;previous_generation=cmd_generation;previous_epoch=cmd_epoch;scan_slot1(previous_request,previous_generation,previous_epoch);
   $display("M007_PURE_PRODUCER_RECOVERY_PASS request=%h generation=%0d epoch=%0d actual_inputs=%0d actual_quant_returns=%0d real_A_writes=%0d real_A_acks=%0d actual_publications=%0d public_read_verified=1",cmd_request,cmd_generation,cmd_epoch,actual_inputs,actual_quant_returns,actual_writes,actual_acks,actual_publications);$fflush();
  end
 endtask
 initial begin
  clk=0;rst_n=0;run_enable=1;cmd_valid=0;cmd_slot=0;cmd_k=1024;cmd_request=64'hc104000000;cmd_generation=10;cmd_epoch=20;in_valid=0;in_data=0;in_request=0;in_generation=0;in_epoch=0;in_row=0;in_group=0;producer_close_valid=0;producer_close_success=0;done_ready=0;
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"fixture required");if(!$value$plusargs("INPUT_FIXTURE=%s",input_fixture))input_fixture=fixture;
  $readmemh({input_fixture,"/wo_0_weight/input.hex"},input_words);$readmemh({fixture,"/wo_0_weight/a_write.hex"},expected_a);
  repeat(5)@(negedge clk);rst_n=1;
  for(integer mode=0;mode<3;mode++)begin
   begin_command(0);
   if(mode==0)begin @(negedge clk);fail_close;end
   else if(mode==1)begin
    fork
     send_until_close;
     begin wait(a_writes>=32&&front.q_reservations>0);@(negedge clk);producer_close_success=0;producer_close_valid=1;#0.1;if(!in_valid||!in_ready)$fatal(1,"same-edge close input was not actually eligible");@(posedge clk);if(!producer_close_ready||!in_ready)$fatal(1,"same-edge close did not accept actual input");@(negedge clk);producer_close_valid=0;end
    join
   end else begin
    fork
     send_until_close;
     begin
      wait(a_writes>=32);@(negedge clk);ack_enable=0;wait(cache_ack_valid&&front.q_out_valid);@(negedge clk);run_enable=0;
      begin
       logic [643:0] held_quant;logic [13:0] held_ack;
       held_quant={front.q_out_request,front.q_out_generation,front.q_out_epoch,front.q_out_k,front.q_out_row,front.q_out_group,front.q_out_tag,front.q_out_data,front.q_out_status,front.q_out_stage,front.q_out_element,front.q_amax,front.q_d_full,front.q_inverse,front.q_d_valid,front.q_inverse_valid};held_ack={cache_ack_row,cache_ack_group};
       repeat(8)begin @(negedge clk);if(!front.q_out_valid||front.q_out_ready||!cache_ack_valid||{cache_ack_row,cache_ack_group}!==held_ack||{front.q_out_request,front.q_out_generation,front.q_out_epoch,front.q_out_k,front.q_out_row,front.q_out_group,front.q_out_tag,front.q_out_data,front.q_out_status,front.q_out_stage,front.q_out_element,front.q_amax,front.q_d_full,front.q_inverse,front.q_d_valid,front.q_inverse_valid}!==held_quant)$fatal(1,"real held last quant/A-ack payload changed");end
      end
      fail_close;run_enable=1;
      repeat(8)begin @(negedge clk);if(done_valid||cache_cancel_valid||!cache_ack_valid)$fatal(1,"fabricated cancel completion before held actual A ack");end
      ack_enable=1;
     end
    join
   end
   hold_cancel_response;finish_response(3);
   if(actual_inputs!=actual_close_groups||actual_publications!=0||cache_slot_valid[0]||(mode==0&&actual_inputs!=0)||(mode>0&&(actual_writes==0||actual_inputs<=actual_writes))||(mode==1&&!actual_close_inputs))$fatal(1,"producer failure case actual boundary mismatch mode=%0d",mode);
   $display("M007_PURE_PRODUCER_CLOSE_PASS mode=%0d accepted_groups=%0d quant_returns=%0d real_A_writes=%0d real_A_acks=%0d accepted_on_close_edge=%0d real_cancel_held=8 old_A_slot_invalid=1",mode,actual_inputs,actual_quant_returns,actual_writes,actual_acks,actual_close_inputs);$fflush();
   if(previous_request!=0)scan_slot1(previous_request,previous_generation,previous_epoch);
   successful_recovery;
  end
  $display("HARDWARE_AGENT_SIM_PASS M007_PURE_PRODUCER_CANCEL real_cases=3 new_generation_recoveries=3 no_reset=1");$finish;
 end
endmodule
