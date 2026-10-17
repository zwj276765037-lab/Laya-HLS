`timescale 1ns/1ps
module laya_executor_adapter_lpv_owner_tb_v1;
  logic clk=0,rst_n=0,cancel=0;
  always #5 clk=~clk;
  logic installed_owner_valid=0,owner_revoked=0;
  logic [8191:0] installed_owner=0,txn_owner=0;
  logic txn_start=0,txn_route=0,txn_start_ready,txn_done;
  logic txn_owned,txn_revoked,txn_drained,protocol_error;
  logic [511:0] adapter_cmd_din,portal_cmd_din,portal_rsp_dout,adapter_rsp_dout;
  logic adapter_cmd_write,adapter_cmd_full_n,portal_cmd_write,portal_cmd_full_n;
  logic portal_rsp_empty_n,portal_rsp_read,adapter_rsp_empty_n,adapter_rsp_read=0;
  logic lpv_candidate_valid,lpv_candidate_route,lpv_pending_valid,lpv_pending_route;
  logic [8191:0] lpv_candidate_owner,lpv_pending_owner,lpv_pending_packet,lpv_response_owner;
  logic lpv_response_route;
  logic [4:0] command_captured,command_sent;
  logic [3:0] response_received,response_consumed;
  logic [1:0] response_occupancy;
  logic [31:0] transactions_started,transactions_released,invalid_done;
  laya_executor_adapter_lpv_owner_v1 dut(.*);

  // Four independent real depth2 boundaries: generated-command peer, portal
  // command consumer, portal-response peer, and normalized-LTC caller consumer.
  logic cmd_put=0,cmd_put_ready;
  logic [511:0] cmd_put_data=0;
  logic [1:0] cmd_input_occupancy;
  laya_private_fifo2_v1 cmd_input_fifo(.clk,.rst_n,.in_valid(cmd_put),
    .in_ready(cmd_put_ready),.in_data(cmd_put_data),.out_valid(adapter_cmd_write),
    .out_ready(adapter_cmd_full_n),.out_data(adapter_cmd_din),.occupancy(cmd_input_occupancy));
  logic portal_cmd_valid,portal_cmd_take=0;
  logic [511:0] portal_cmd_data;
  logic [1:0] portal_command_occupancy;
  laya_private_fifo2_v1 portal_command_fifo(.clk,.rst_n,.in_valid(portal_cmd_write),
    .in_ready(portal_cmd_full_n),.in_data(portal_cmd_din),.out_valid(portal_cmd_valid),
    .out_ready(portal_cmd_take),.out_data(portal_cmd_data),.occupancy(portal_command_occupancy));
  logic rsp_put=0,rsp_put_ready;
  logic [511:0] rsp_put_data=0;
  logic [1:0] portal_response_occupancy;
  laya_private_fifo2_v1 portal_response_fifo(.clk,.rst_n,.in_valid(rsp_put),
    .in_ready(rsp_put_ready),.in_data(rsp_put_data),.out_valid(portal_rsp_empty_n),
    .out_ready(portal_rsp_read),.out_data(portal_rsp_dout),.occupancy(portal_response_occupancy));
  logic ltc_put=0,ltc_put_ready,ltc_valid,ltc_take=0;
  logic [511:0] ltc_put_data=0,ltc_data;
  logic [1:0] ltc_occupancy;
  logic [3:0] ltc_index=0;
  integer ltc_reads=0,cmd_reads=0,rsp_reads=0,cycles=0,case_id=0;
  laya_private_fifo2_v1 ltc_fifo(.clk,.rst_n,.in_valid(ltc_put),
    .in_ready(ltc_put_ready),.in_data(ltc_put_data),.out_valid(ltc_valid),
    .out_ready(ltc_take),.out_data(ltc_data),.occupancy(ltc_occupancy));
  assign txn_done=ltc_valid && ltc_take && ltc_index==15;

  string fixture;
  logic [511:0] admission_words[0:15],command_words[0:15],response_words[0:7];
  logic [8191:0] literal_owner,literal_command;
  logic [4095:0] literal_response;
  logic expected_route=0;
  logic pending_was_valid=0,response_was_held=0;
  logic [8191:0] held_packet,held_owner;
  logic held_route;
  logic [511:0] held_response;
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>4000)$fatal(1,"LPV owner cycle cap case=%0d",case_id);
    if(!rst_n)begin
      ltc_index<=0;ltc_reads<=0;cmd_reads<=0;rsp_reads<=0;
      pending_was_valid<=0;response_was_held<=0;
    end else begin
      if(ltc_valid && ltc_take)begin ltc_index<=ltc_index+1'b1;ltc_reads<=ltc_reads+1;end
      if(portal_cmd_valid && portal_cmd_take)cmd_reads<=cmd_reads+1;
      if(adapter_rsp_empty_n && adapter_rsp_read)rsp_reads<=rsp_reads+1;
      if(txn_owned && (lpv_candidate_owner!==literal_owner ||
          lpv_candidate_route!==expected_route || lpv_response_owner!==literal_owner ||
          lpv_response_route!==expected_route))$fatal(1,"old transaction A/route rebound");
      if(portal_cmd_write && !lpv_pending_valid)$fatal(1,"partial LPV escaped collector");
      if(pending_was_valid && (!lpv_pending_valid || lpv_pending_packet!==held_packet ||
          lpv_pending_owner!==held_owner || lpv_pending_route!==held_route))
        $fatal(1,"full LPV pending changed or vanished before real LTC end");
      pending_was_valid<=lpv_pending_valid && !(txn_done && dut.lpv_done);
      held_packet<=lpv_pending_packet;held_owner<=lpv_pending_owner;held_route<=lpv_pending_route;
      if(response_was_held && (!adapter_rsp_empty_n || adapter_rsp_dout!==held_response))
        $fatal(1,"old response changed while its actual consumer stalled");
      response_was_held<=adapter_rsp_empty_n && !adapter_rsp_read;
      held_response<=adapter_rsp_dout;
    end
  end

  task automatic tick; @(posedge clk); #1; endtask
  task automatic tags;
    if(!txn_owned || !lpv_candidate_valid || lpv_candidate_owner!==literal_owner ||
       lpv_candidate_route!==expected_route || lpv_response_owner!==literal_owner ||
       lpv_response_route!==expected_route)$fatal(1,"old A/route tag mismatch");
    if(command_captured==16 && (!lpv_pending_valid || lpv_pending_packet!==literal_command ||
       lpv_pending_owner!==literal_owner || lpv_pending_route!==expected_route))
      $fatal(1,"pending is not the independently frozen complete literal");
  endtask
  task automatic reset_case(input integer selected_case);
    rst_n=0;cancel=0;owner_revoked=0;txn_start=0;
    cmd_put=0;rsp_put=0;portal_cmd_take=0;adapter_rsp_read=0;ltc_put=0;ltc_take=0;
    installed_owner_valid=1;installed_owner=literal_owner;txn_owner=literal_owner;
    repeat(3)tick();case_id=selected_case;rst_n=1;tick();
    if(!txn_drained || transactions_started!=0)$fatal(1,"reset case not initially empty");
  endtask
  task automatic load_literal(input string name);
    $readmemh({fixture,"/",name,".hex"},command_words);
    $readmemh({fixture,"/",name,"_gold.hex"},response_words);
    for(int i=0;i<16;i++)literal_command[i*512+:512]=command_words[i];
    for(int i=0;i<8;i++)literal_response[i*512+:512]=response_words[i];
  endtask
  task automatic start_transaction(input logic selected_route);
    txn_owner=literal_owner;txn_route=selected_route;expected_route=selected_route;
    txn_start=1;#1;
    if(!txn_start_ready)$fatal(1,"valid installed A could not start");
    tick();txn_start=0;tags();
    if(transactions_started!=transactions_released+1)$fatal(1,"start count mismatch");
  endtask
  task automatic blocked_start;
    txn_start=1;#1;
    repeat(12)begin if(txn_start_ready)$fatal(1,"blocked candidate was admitted");tick();end
    txn_start=0;
  endtask
  task automatic send_commands(input integer first,input integer after);
    for(int i=first;i<after;i++)begin
      cmd_put_data=command_words[i];cmd_put=1;
      while(!cmd_put_ready)tick();tick();cmd_put=0;
    end
    while(command_captured<after || cmd_input_occupancy!=0)tick();
    tags();
  endtask
  task automatic hold_partial;
    repeat(12)begin
      tags();
      if(lpv_pending_valid || portal_cmd_write || command_sent!=0)
        $fatal(1,"partial collector exposed packet before 16 generated pushes");
      tick();
    end
  endtask
  task automatic consume_commands;
    for(int i=0;i<16;i++)begin
      if(i==14 || i==15)repeat(12)begin tags();tick();end
      portal_cmd_take=1;while(!portal_cmd_valid)tick();
      if(portal_cmd_data!==command_words[i])$fatal(1,"raw generated LPV word mismatch %0d",i);
      tags();tick();portal_cmd_take=0;
    end
    if(command_sent!=16 || cmd_reads!=16)$fatal(1,"portal did not consume exactly 16 beats");
    tags();
  endtask
  function automatic logic [511:0] ltc_literal(input integer i);
    logic [511:0] v;
    v=0;v[0+:32]=32'h3143544c;v[32+:32]=32'(i);
    v[64+:32]=32'(case_id);v[511:480]=32'hcafe0000+32'(i);return v;
  endfunction
  task automatic consume_ltc(input logic expect_release);
    // txn_done is never driven by the TB: it is the real 16th depth2 pop.
    fork
      begin
        for(int i=0;i<16;i++)begin
          ltc_put_data=ltc_literal(i);ltc_put=1;
          while(!ltc_put_ready)tick();tick();ltc_put=0;
        end
      end
      begin
        for(int i=0;i<16;i++)begin
          if(i==14 || i==15)repeat(12)begin
            if(!txn_owned || txn_start_ready)$fatal(1,"LTC tail released old ownership early");
            tick();
          end
          ltc_take=1;while(!ltc_valid)tick();
          if(ltc_data!==ltc_literal(i))$fatal(1,"LTC peer depth2 bytes mismatch");
          tick();ltc_take=0;
        end
      end
    join
    if(expect_release)begin
      if(txn_owned || lpv_pending_valid || lpv_candidate_valid || !txn_drained ||
          installed_owner!==literal_owner || !installed_owner_valid)
        $fatal(1,"actual final LTC did not close only the local transaction");
    end else if(!txn_owned || !protocol_error)
      $fatal(1,"premature actual LTC end lost old frame or failed to record error");
  endtask
  task automatic return_response(input logic premature_ltc);
    fork
      begin
        for(int i=0;i<8;i++)begin
          rsp_put_data=response_words[i];rsp_put=1;
          while(!rsp_put_ready)tick();tick();rsp_put=0;
        end
      end
      begin
        for(int i=0;i<8;i++)begin
          if(i==6 && premature_ltc)begin
            consume_ltc(0);if(invalid_done!=1)$fatal(1,"unfinished response accepted txn_done");
          end
          if(i==6 || i==7)repeat(12)begin
            tags();if(!txn_owned || txn_start_ready)$fatal(1,"LPA tail released old transaction");tick();
          end
          adapter_rsp_read=1;while(!adapter_rsp_empty_n)tick();
          if(adapter_rsp_dout!==response_words[i])$fatal(1,"raw LPA literal mismatch %0d",i);
          tags();tick();adapter_rsp_read=0;
        end
      end
    join
    if(response_received!=8 || response_consumed!=8 || rsp_reads!=8 ||
        response_occupancy!=0 || portal_response_occupancy!=0)
      $fatal(1,"actual response did not complete exactly eight reads");
    tags();repeat(12)begin tags();if(txn_start_ready)$fatal(1,"LPA end substituted for LTC end");tick();end
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE missing");
    $readmemh({fixture,"/admission.hex"},admission_words);
    for(int i=0;i<16;i++)literal_owner[i*512+:512]=admission_words[i];
    literal_command=0;literal_response=0;

    reset_case(0);
    installed_owner_valid=0;blocked_start();installed_owner_valid=1;
    cancel=1;blocked_start();cancel=0;owner_revoked=1;blocked_start();owner_revoked=0;
    txn_owner=literal_owner;txn_owner[0+:32]=0;blocked_start();
    txn_owner=literal_owner;txn_owner[24*8+:64]=102;blocked_start();
    if(transactions_started!=0 || txn_owned || protocol_error)$fatal(1,"invalid candidate changed local state");
    // Two normal no-LPV transactions model compute/producer paths; no reset
    // between them, and both close only via genuine full LTC consumption.
    start_transaction(0);consume_ltc(1);
    start_transaction(1);consume_ltc(1);
    if(transactions_started!=2 || transactions_released!=2 || invalid_done!=0 || ltc_reads!=32)
      $fatal(1,"no-LPV compute/producer local cleanup mismatch");
    $display("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_CASE_PASS case=0 blocked_A=5 no_LPV_txn=2 actual_LTC_reads=32");

    reset_case(1);load_literal("claim");start_transaction(0);
    send_commands(0,14);hold_partial();send_commands(14,15);hold_partial();send_commands(15,16);
    consume_commands();return_response(0);consume_ltc(1);
    if(protocol_error || txn_revoked || transactions_released!=1 || invalid_done!=0)
      $fatal(1,"normal raw-frame transaction failed");
    $display("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_CASE_PASS case=1 command16_response8_LTC16=1 tail2_tail1_wait12=1 literal_all_bytes=1");

    reset_case(2);load_literal("preowned_claim");start_transaction(1);send_commands(0,2);
    cancel=1;owner_revoked=1;
    installed_owner=literal_owner;installed_owner[24*8+:64]=102;
    txn_owner=installed_owner;txn_route=0;blocked_start();
    if(!txn_revoked || command_captured!=2)$fatal(1,"persistent half-frame revoke was not retained");
    consume_ltc(0);if(invalid_done!=1 || command_captured!=2)$fatal(1,"premature LTC discarded half frame");
    send_commands(2,16);consume_commands();return_response(0);
    // Restore live bytes, never the retained sidecar object. Revocation remains.
    installed_owner=literal_owner;consume_ltc(1);blocked_start();
    if(!txn_revoked || !protocol_error || invalid_done!=1 || transactions_started!=1 ||
        transactions_released!=1 || ltc_reads!=32)$fatal(1,"canceled old transaction cleanup mismatch");
    $display("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_CASE_PASS case=2 half2_cancel_persistent=1 live_A_route_changed=1 old16_8_retained=1 premature_LTC_rejected=1 local_end_only=1");

    reset_case(3);load_literal("claim");start_transaction(0);send_commands(0,16);
    consume_commands();return_response(1);consume_ltc(1);
    if(!protocol_error || invalid_done!=1 || transactions_released!=1 || ltc_reads!=32)
      $fatal(1,"early txn_done while response tail was pending did not preserve cleanup");
    blocked_start();
    $display("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_CASE_PASS case=3 response_tail_premature_LTC_rejected=1 old_response_progress=1 new_txn_blocked=1");
    $display("FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_PASS cases=4 cycles=%0d no_generated_adapter=1 no_hub_authority=1 no_CLOSED=1",cycles);
    $finish;
  end
endmodule
