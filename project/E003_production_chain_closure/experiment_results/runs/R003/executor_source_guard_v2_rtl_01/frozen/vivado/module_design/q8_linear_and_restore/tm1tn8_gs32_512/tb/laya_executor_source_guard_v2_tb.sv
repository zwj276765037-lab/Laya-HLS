`timescale 1ns/1ps
// Finite bridge checks with the real shell and a TB executor-side consumer.
// All 512-bit FIFO pops are real. Accepted whole records are issued only
// after complete byte comparison with independent literal gold, except for
// explicit early/foreign/replay blocked-write tests. Rejection notifications
// use their separate consuming lane. This is not generated HLS.
module laya_executor_source_guard_v2_tb;
  import laya_executor_handoff_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;always #5 clk=~clk;
  logic [511:0] control_request_din=0;
  logic control_request_write=0,control_request_full_n;
  logic [511:0] control_request_receipt_dout,control_response_dout;
  logic control_request_receipt_empty_n,control_request_receipt_read=0;
  logic control_response_empty_n,control_response_read=0;
  logic [8191:0] control_response_receipt_din=0,control_response_rejection_din=0;
  logic control_response_receipt_write=0,control_response_receipt_full_n;
  logic control_response_rejection_write=0,control_response_rejection_full_n;
  logic shell_control_valid,shell_control_ready,shell_response_valid,shell_response_ready;
  logic [8191:0] shell_control,shell_response;
  logic protocol_error,cancel_seen,response_active;
  logic [31:0] control_request_writes,control_request_reads,shell_control_consumed;
  logic [31:0] request_receipt_writes,request_receipt_reads,response_writes,response_reads;
  logic [31:0] accepted_response_receipts,rejected_response_receipts;
  logic [31:0] invalid_accepted_receipts,shell_response_pops;
  logic [1:0] request_occupancy,request_receipt_occupancy,response_occupancy;
  logic [2:0] request_phase;
  logic [4:0] response_send_beats,response_read_beats;
  logic closed_consumer_valid;
  logic [8191:0] closed_consumer_record;
  logic [63:0] current_session=29,current_request=101;
  logic [767:0] current_identity;
  logic base_valid=1;
  logic [63:0] base_epoch=7,base_address=64'h1200000000,base_capacity=16920576;
  logic stop_predecessor,locks_owned,predecessor_done_valid=0,predecessor_done_ready;
  logic [8191:0] pending_key,predecessor_done_key=0;
  logic old_channels_drained=0,physical_safe=0,protection_valid=1;
  logic query_accepted=0,query_response_pop=0;
  logic [8191:0] query_request=0;
  logic [511:0] query_response_word=0;
  logic query_permit,import_pending,executor_owns_dispatch,authority_valid,revoked,local_committed;
  logic [63:0] sequence_high_water,handoff_high_water;
  logic [31:0] control_rejections,grants,closed_aborts,closed_requests;
  logic [3:0] phase;
  logic terminal_seal_valid=0,terminal_seal_ready,terminal_seal_accepted;
  logic request_work_done_valid=0,host_result_consumed_valid=0,request_closed;
  logic [8191:0] terminal_seal_record=0,request_work_done_record=0;
  logic [8191:0] host_result_consumed_record=0,last_closed_record;
  logic [8191:0] hold_frame,query_frame,proof_frame,import_frame,abort_frame;
  logic [8191:0] held_gold,grant_gold,close_error1,closed_error1;
  logic [511:0] words[0:15];string fixture;
  logic response_stalled=0,control_stalled=0;
  logic [8191:0] response_stalled_bytes,control_stalled_bytes;
  int cycles=0,cases=0,tail_wait_cycles=0;string capture;

  laya_executor_control_transport_v1 bridge(
    .shell_closed_consumer_valid(closed_consumer_valid),
    .shell_closed_consumer_record(closed_consumer_record),.*);
  laya_executor_handoff_shell_v1 #(.MANAGED_REQUEST_CLOSE(1)) shell(
    .control_valid(shell_control_valid),.control_ready(shell_control_ready),.control(shell_control),
    .response_valid(shell_response_valid),.response_ready(shell_response_ready),.response(shell_response),
    .query_ingress_started(1'b0),.query_ingress_owned(),.*);


  logic source_still_matches=1,guard_active,grant_valid,guard_revoked;
  logic [8191:0] guard_key;
  logic base_change_ready,source_change_ready,guard_protocol_error;
  logic action_valid=0,action_ready,producer_valid=0,producer_ready;
  logic [4095:0] action_request=0,action_literal;
  logic [8191:0] producer_request=0,producer_literal;
  logic [2047:0] lac_error,lac_success;
  logic [4095:0] f9_literal;
  logic guard_producer_active,guard_action_active,ar_offer_owned;
  logic [31:0] read_debt,guard_grants_accepted,guard_grants_rejected;
  logic [31:0] actions_accepted,producers_accepted,source_ar_pops,source_r_pops;
  logic [31:0] producer_completion_pops,action_completion_pops;
  logic [63:0] source_araddr=0;
  logic [7:0] source_arlen=0;
  logic [2:0] source_arsize=6;
  logic [1:0] source_arburst=1;
  logic source_arvalid=0,source_arready=0,source_ar_allowed;
  logic source_rvalid=0,source_rready=1,source_rlast=0;
  logic [1:0] source_rresp=0;
  logic state0_write_is_norm_target=0;
  logic [63:0] state0_awaddr=0;
  logic [7:0] state0_awlen=0;
  logic [2:0] state0_awsize=6;
  logic [1:0] state0_awburst=1;
  logic state0_write_allowed,norm_target_write_allowed;
  logic f9_in_valid=0,f9_in_ready,f9_out_valid,f9_out_read=0;
  logic [511:0] f9_in_data=0,f9_out_data;
  logic lac_in_valid=0,lac_in_ready,lac_out_valid,lac_out_read=0;
  logic [511:0] lac_in_data=0,lac_out_data;
  logic [1:0] f9_occupancy,lac_occupancy;
  wire actual_hold_fire=shell_control_valid && shell_control_ready && shell_control[8*8+:8]==HOLD;
  wire actual_receipt_fire=control_response_receipt_write && control_response_receipt_full_n;
  laya_private_fifo2_v1 f9_fifo(.clk,.rst_n,.in_valid(f9_in_valid),.in_ready(f9_in_ready),
    .in_data(f9_in_data),.out_valid(f9_out_valid),.out_ready(f9_out_read),.out_data(f9_out_data),
    .occupancy(f9_occupancy));
  laya_private_fifo2_v1 lac_fifo(.clk,.rst_n,.in_valid(lac_in_valid),.in_ready(lac_in_ready),
    .in_data(lac_in_data),.out_valid(lac_out_valid),.out_ready(lac_out_read),.out_data(lac_out_data),
    .occupancy(lac_occupancy));
  laya_executor_source_guard_v2 guard(
    .clk,.rst_n,.cancel,.shell_hold_fire(actual_hold_fire),.shell_hold_record(shell_control),
    .shell_hold_active(stop_predecessor),.shell_locks_owned(locks_owned),.shell_pending_key(pending_key),
    .shell_authority_valid(authority_valid),.shell_revoked(revoked),
    .grant_receipt_fire(actual_receipt_fire),.grant_receipt_record(control_response_receipt_din),
    .source_still_matches,.live_base_valid(base_valid),.live_base_epoch(base_epoch),
    .live_base_address(base_address),.live_base_capacity(base_capacity),.physical_safe,
    .guard_active,.grant_valid,.guard_revoked,.guard_key,.base_change_ready,.source_change_ready,
    .action_valid,.action_request,.action_ready,.producer_valid,.producer_request,.producer_ready,
    .producer_completion_empty_n(f9_out_valid),.producer_completion_read(f9_out_read),
    .action_completion_dout(lac_out_data),.action_completion_empty_n(lac_out_valid),
    .action_completion_read(lac_out_read),.source_araddr,.source_arlen,.source_arsize,.source_arburst,
    .source_arvalid,.source_arready,.source_ar_allowed,.source_rvalid,.source_rready,.source_rlast,
    .source_rresp,.read_debt,.ar_offer_owned,.state0_write_is_norm_target,.state0_awaddr,.state0_awlen,
    .state0_awsize,.state0_awburst,.state0_write_allowed,.norm_target_write_allowed,
    .producer_active(guard_producer_active),.action_active(guard_action_active),
    .protocol_error(guard_protocol_error),.grants_accepted(guard_grants_accepted),
    .grants_rejected(guard_grants_rejected),.actions_accepted,.producers_accepted,.source_ar_pops,
    .source_r_pops,.producer_completion_pops,.action_completion_pops);
  // Query, fences, source-match and F9/LAC peers are controlled. The actual
  // shell/transport and all bounded FIFO pops are real; no generated LN claim.
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>8000)$fatal(1,"finite v2 source guard cycle cap");
    if(rst_n)begin
      if(request_occupancy>2 || request_receipt_occupancy>2 || response_occupancy>2 ||
          f9_occupancy>2 || lac_occupancy>2)$fatal(1,"depth2 occupancy exceeded");
      if(response_stalled && (!shell_response_valid || shell_response!==response_stalled_bytes))
        $fatal(1,"actual old shell VALID record changed under backpressure/revoke");
      if(shell_response_ready && (!actual_receipt_fire || response_read_beats!=16 ||
          response_send_beats!=16 || response_occupancy!=0 ||
          control_response_receipt_din!==shell_response))$fatal(1,"shell response receipt was forged");
      if(guard_grants_accepted==0 && (action_ready || producer_ready || source_ar_pops!=0))
        $fatal(1,"new action/producer/AR escaped before real accepted GRANTED");
      if((cancel || guard_revoked) && (action_ready || producer_ready))
        $fatal(1,"revocation failed to close new action/producer");
      if((stop_predecessor || actual_hold_fire) && (base_change_ready || source_change_ready))
        $fatal(1,"HOLD/old shell lock opened source/base mutation");
      if(invalid_accepted_receipts || protocol_error)$fatal(1,"real control transport failed");
    end
    response_stalled<=rst_n && shell_response_valid && !shell_response_ready;
    response_stalled_bytes<=shell_response;
  end
  task automatic tick();@(posedge clk);#1;endtask
  task automatic idle(input int n);repeat(n)tick();endtask
  task automatic load(input string name,output logic [8191:0] packet);
    $readmemh({fixture,"/",name,".hex"},words);
    for(int beat=0;beat<16;beat++)packet[beat*512+:512]=words[beat];
  endtask
  task automatic save(input string name,input logic [8191:0] packet);
    integer file;file=$fopen({capture,"/",name,".hex"},"w");
    if(file==0)$fatal(1,"capture open failed");
    for(int beat=0;beat<16;beat++)$fdisplay(file,"%0128h",packet[beat*512+:512]);
    $fclose(file);
  endtask
  task automatic reset_case();
    @(negedge clk);rst_n=0;cancel=0;control_request_write=0;
    control_request_receipt_read=0;control_response_read=0;
    control_response_receipt_write=0;control_response_rejection_write=0;
    predecessor_done_valid=0;query_accepted=0;query_response_pop=0;
    terminal_seal_valid=0;request_work_done_valid=0;host_result_consumed_valid=0;
    old_channels_drained=0;physical_safe=0;protection_valid=1;base_valid=1;
    current_session=29;current_request=101;current_identity=hold_frame[64*8+:768];
    base_epoch=7;base_address=64'h1200000000;base_capacity=16920576;
    idle(3);@(negedge clk);rst_n=1;tick();
  endtask
  task automatic write_request_beat(input logic [8191:0] packet,input int beat);
    int waits;waits=0;
    @(negedge clk);control_request_din=packet[beat*512+:512];control_request_write=1;
    while(!control_request_full_n)begin tick();waits++;if(waits>80)$fatal(1,"request FIFO stuck");end
    tick();@(negedge clk);control_request_write=0;
  endtask
  task automatic queue_request(input logic [8191:0] packet,input bit tails);
    logic [31:0] consumed_before;consumed_before=shell_control_consumed;
    for(int beat=0;beat<16;beat++)begin
      write_request_beat(packet,beat);
      if(tails && (beat==13 || beat==14))begin
        repeat(12)begin tick();tail_wait_cycles++;
          if(shell_control_valid || shell_control_consumed!=consumed_before ||
              control_request_receipt_empty_n)$fatal(1,"partial request reached shell/echo");
        end
      end
    end
  endtask
  task automatic await_control(input logic [31:0] expected);
    int waits;waits=0;
    while(shell_control_consumed!=expected)begin
      tick();waits++;if(waits>80)$fatal(1,"shell whole-record consumer stuck");
    end
    if(shell_control_valid)$fatal(1,"shell consumer counted without ending presentation");
  endtask
  task automatic read_echo(input logic [8191:0] expected,input bit tails);
    logic [8191:0] actual;logic [511:0] word;int waits;
    actual=0;
    for(int beat=0;beat<16;beat++)begin
      @(negedge clk);waits=0;
      while(!control_request_receipt_empty_n)begin
        tick();@(negedge clk);waits++;if(waits>80)$fatal(1,"echo FIFO stuck");
      end
      word=control_request_receipt_dout;control_request_receipt_read=1;
      tick();actual[beat*512+:512]=word;
      @(negedge clk);control_request_receipt_read=0;
      if(tails && (beat==13 || beat==14))repeat(12)begin
        tick();tail_wait_cycles++;
        if(control_request_full_n || request_phase==0)$fatal(1,"echo tail reopened single-inflight ingress");
      end
    end
    if(actual!==expected)$fatal(1,"request echo does not match actual shell-consumed packet");
    idle(2);
    if(request_phase!=0 || request_receipt_occupancy!=0 || request_occupancy!=0)
      $fatal(1,"ended request transport did not finish bounded echo");
  endtask
  task automatic send_control(input logic [8191:0] packet,input bit tails);
    logic [31:0] expected;expected=shell_control_consumed+1;
    queue_request(packet,tails);await_control(expected);read_echo(packet,tails);
  endtask
  task automatic accepted_record(input logic [8191:0] packet,input bit should_pop);
    logic [31:0] pops,accepted,rejected,invalid;
    pops=shell_response_pops;accepted=accepted_response_receipts;
    rejected=rejected_response_receipts;invalid=invalid_accepted_receipts;
    @(negedge clk);control_response_receipt_din=packet;control_response_receipt_write=1;#1;
    if(control_response_receipt_full_n!==should_pop ||
        bridge.accepted_receipt_fire!==should_pop || shell_response_ready!==should_pop)
      $fatal(1,"accepted receipt gate mismatch");
    tick();@(negedge clk);control_response_receipt_write=0;
    if(shell_response_pops!=pops+(should_pop?1:0) ||
        accepted_response_receipts!=accepted+(should_pop?1:0) ||
        rejected_response_receipts!=rejected || invalid_accepted_receipts!=invalid)
      $fatal(1,"accepted receipt actual-fire count or blocked-attempt invariant wrong");
  endtask
  task automatic rejected_record(input logic [8191:0] packet);
    logic [31:0] count,pops;count=rejected_response_receipts;pops=shell_response_pops;
    @(negedge clk);control_response_rejection_din=packet;control_response_rejection_write=1;#1;
    if(!control_response_rejection_full_n || shell_response_ready || closed_consumer_valid)
      $fatal(1,"rejection acquired response authority");
    tick();@(negedge clk);control_response_rejection_write=0;
    if(rejected_response_receipts!=count+1 || shell_response_pops!=pops)
      $fatal(1,"rejection was not consumed exactly once without release");
  endtask
  task automatic wait_response(input logic [8191:0] expected);
    int waits;waits=0;
    while(!shell_response_valid || !response_active)begin
      tick();waits++;if(waits>80)$fatal(1,"shell response missing");
    end
    if(shell_response!==expected || authority_valid)$fatal(1,"shell response/gold or early authority wrong");
    idle(4);
    if(response_occupancy!=2 || response_send_beats!=2 || response_read_beats!=0)
      $fatal(1,"unread response did not enforce real depth2 backpressure");
  endtask
  task automatic collect_response(input logic [8191:0] expected,input string name);
    logic [8191:0] actual;logic [511:0] word;logic [31:0] pops;int waits;
    actual=0;pops=shell_response_pops;
    wait_response(expected);accepted_record(expected,0);rejected_record(expected);
    for(int beat=0;beat<16;beat++)begin
      @(negedge clk);waits=0;
      while(!control_response_empty_n)begin
        tick();@(negedge clk);waits++;if(waits>80)$fatal(1,"response FIFO stuck");
      end
      word=control_response_dout;control_response_read=1;
      tick();actual[beat*512+:512]=word;
      @(negedge clk);control_response_read=0;
      if(beat==13 || beat==14)begin
        repeat(12)begin tick();tail_wait_cycles++;
          if(!shell_response_valid || shell_response!==expected || shell_response_pops!=pops ||
              authority_valid || !locks_owned)$fatal(1,"tail write/pop consumed shell response");
        end
        if(response_send_beats!=16 || response_read_beats!=beat+1)
          $fatal(1,"tail check did not distinguish 16 writes from partial reads");
        accepted_record(expected,0);
      end
    end
    // Complete independent byte comparison is the TB consumer's validation.
    if(actual!==expected || actual[0+:32]!=CONTROL_MAGIC || actual[4*8+:16]!=1 || actual[6*8+:16]!=16)
      $fatal(1,"complete response validation failed");
    save(name,actual);idle(12);
    if(response_send_beats!=16 || response_read_beats!=16 || response_occupancy!=0 ||
        !shell_response_valid || shell_response_pops!=pops || authority_valid)
      $fatal(1,"last read bypassed complete codec receipt");
  endtask
  task automatic finish_response(input logic [8191:0] packet);
    logic [8191:0] wrong;wrong=packet;
    wrong[ACCEPTED_REQUEST_OFFSET*8+:64]=wrong[ACCEPTED_REQUEST_OFFSET*8+:64]+1'b1;
    accepted_record(wrong,0);rejected_record(packet);
    accepted_record(packet,1);accepted_record(packet,0);
  endtask
  task automatic acquire();
    send_control(hold_frame,1);
    if(phase!=1 || handoff_high_water!=1 || sequence_high_water!=1 || locks_owned)
      $fatal(1,"actual HOLD did not reserve S/H");
    @(negedge clk);predecessor_done_key=pending_key;predecessor_done_valid=1;
    tick();@(negedge clk);predecessor_done_valid=0;
    repeat(12)begin tick();if(shell_response_valid || locks_owned)$fatal(1,"HELD bypassed predecessor drain");end
    @(negedge clk);old_channels_drained=1;physical_safe=1;tick();
    collect_response(held_gold,$sformatf("actual_held_case%0d",cases));finish_response(held_gold);
    if(!query_permit || !locks_owned || authority_valid || accepted_response_receipts!=1)
      $fatal(1,"HELD complete consumer boundary wrong");
  endtask
  task automatic complete_query();
    @(negedge clk);query_request=query_frame;query_accepted=1;tick();
    @(negedge clk);query_accepted=0;
    if(phase!=4)$fatal(1,"query was not accepted by original shell");
    for(int beat=0;beat<16;beat++)begin
      @(negedge clk);query_response_word=proof_frame[beat*512+:512];query_response_pop=1;
      tick();@(negedge clk);query_response_pop=0;
      if(beat==13 || beat==14)repeat(12)begin
        tick();if(import_pending || local_committed || authority_valid)$fatal(1,"query tail granted");
      end
    end
    if(!import_pending || local_committed || authority_valid)$fatal(1,"query last pop bypassed IMPORT");
  endtask

  task automatic load_short(input string name,input int beats,output logic [4095:0] p);
    logic [511:0] w[0:7];p=0;
    $readmemh({fixture,"/",name,".hex"},w,0,beats-1);
    for(int i=0;i<beats;i++)p[i*512+:512]=w[i];
  endtask
  task automatic clean_reset();
    @(negedge clk);action_valid=0;producer_valid=0;source_arvalid=0;source_arready=0;
    source_rvalid=0;source_rlast=0;source_rresp=0;source_still_matches=1;
    state0_write_is_norm_target=0;f9_in_valid=0;f9_out_read=0;lac_in_valid=0;lac_out_read=0;
    source_arsize=6;source_arburst=1;state0_awsize=6;state0_awburst=1;state0_awlen=0;
    action_request=action_literal;producer_request=producer_literal;
    reset_case();
  endtask
  task automatic check_pregrant();
    @(negedge clk);action_valid=1;producer_valid=1;
    source_araddr=base_address;source_arlen=3;source_arvalid=1;source_arready=1;
    repeat(12)begin tick();if(action_ready || producer_ready || source_ar_allowed ||
      source_ar_pops || guard_grants_accepted)$fatal(1,"pregrant path opened");end
    @(negedge clk);action_valid=0;producer_valid=0;source_arvalid=0;source_arready=0;
  endtask
  task automatic grant_actual(input bit wrongs);
    logic [8191:0] bad;
    acquire();
    @(negedge clk);state0_awaddr=64'h1200000000;state0_write_is_norm_target=0;#1;
    if(state0_write_allowed)$fatal(1,"HELD source lock allowed physical source write");
    state0_awaddr=64'h1200800000;#1;
    if(state0_write_allowed)$fatal(1,"HELD target lock allowed arbitrary target write");
    state0_awaddr=64'h1200100000;#1;
    if(!state0_write_allowed)$fatal(1,"disjoint STATE0 interval was blanket-blocked");
    check_pregrant();complete_query();send_control(import_frame,0);
    collect_response(grant_gold,$sformatf("grant_case%0d",cases));check_pregrant();
    if(wrongs)begin
      for(int i=0;i<9;i++)begin
        bad=grant_gold;
        case(i)
          0:bad[776*8+:64]=30;
          1:bad[784*8+:64]=102;
          2:bad[16*8+:64]=2;
          3:bad[680*8+:64]=2;
          4:bad[792*8+:8]=0;
          5:bad[793*8+:8]=1;
          6:bad[576*8+:32]=2;
          7:bad[696*8+:64]=bad[696*8+:64]+64;
          8:bad[10*8+:16]=7;
        endcase
        if(guard.granted_bound(bad))$fatal(1,"v2 whole-record validator accepted bad K/commit/reserved/B");
        accepted_record(bad,0);
        if(grant_valid || guard_grants_accepted || source_ar_pops)$fatal(1,"foreign/stale receipt granted");
      end
    end
    if(!guard.granted_bound(grant_gold))$fatal(1,"independent real GRANTED does not bind retained full K");
    finish_response(grant_gold);idle(2);
    if(!grant_valid || guard_grants_accepted!=1 || guard_grants_rejected ||
        guard_protocol_error || !authority_valid || guard_key!==pending_key)
      $fatal(1,"actual accepted GRANTED failed to open exactly one local grant");
  endtask
  task automatic start_action();
    @(negedge clk);action_request=action_literal;action_valid=1;#1;
    if(!action_ready)$fatal(1,"full original NORM LAX1 rejected");
    tick();@(negedge clk);action_valid=0;
  endtask
  task automatic start_producer(input int row);
    @(negedge clk);producer_request=producer_literal;
    producer_request[148*8+:32]=5+row/16;
    producer_request[16*8+:64]=1+row/16;producer_request[24*8+:64]=12+row/16;
    producer_request[157*8+:16]=16'(row);
    producer_request[608*8+:64]=64'(row)*4096;
    producer_request[616*8+:64]=8388608+64'(row)*4096;
    producer_valid=1;#1;if(!producer_ready)$fatal(1,"full declared B1/S64 producer window rejected");
    tick();@(negedge clk);producer_valid=0;
    load_short($sformatf("f9_window%0d",row/16),8,f9_literal);
  endtask
  task automatic check_writer(input int row);
    @(negedge clk);state0_awaddr=64'h1200000000+64'(row)*4096;
    state0_write_is_norm_target=0;#1;
    if(state0_write_allowed || norm_target_write_allowed)$fatal(1,"HIDDEN source write escaped");
    state0_awaddr=64'h1200000000+8388608+64'(row)*4096;#1;
    if(state0_write_allowed)$fatal(1,"unowned writer changed held NORM target");
    state0_write_is_norm_target=1;#1;
    if(!norm_target_write_allowed || !state0_write_allowed)$fatal(1,"valid old NORM target writer blanket-blocked");
    state0_awaddr=64'h1200000000+8388608+64'(row+16)*4096;#1;
    if(norm_target_write_allowed || state0_write_allowed)
      $fatal(1,"old producer escaped its bound target window");
    state0_awaddr=64'h1200000000+64'(row)*4096;#1;
    if(state0_write_allowed)$fatal(1,"NORM route aliased source write");
  endtask
  task automatic issue_ar(input int row);
    @(negedge clk);source_araddr=64'h1200000000+64'(row)*4096;
    source_arlen=3;source_arvalid=1;source_arready=1;#1;
    if(!source_ar_allowed)$fatal(1,"old source AR rejected");
    tick();@(negedge clk);source_arvalid=0;source_arready=0;
    if(read_debt!=4)$fatal(1,"actual AR did not create beat debt");
  endtask
  task automatic rbeat(input bit last,input logic [1:0] resp);
    @(negedge clk);source_rvalid=1;source_rlast=last;source_rresp=resp;tick();
    @(negedge clk);source_rvalid=0;source_rlast=0;source_rresp=0;
  endtask
  task automatic stage_f9_tail();
    fork
      begin
        for(int beat=0;beat<8;beat++)begin
          @(negedge clk);f9_in_data=f9_literal[beat*512+:512];f9_in_valid=1;
          while(!f9_in_ready)begin tick();@(negedge clk);end
          tick();@(negedge clk);f9_in_valid=0;
        end
      end
      begin
        for(int beat=0;beat<6;beat++)begin
          @(negedge clk);while(!f9_out_valid)begin tick();@(negedge clk);end
          f9_out_read=1;tick();@(negedge clk);f9_out_read=0;
        end
      end
    join
    if(f9_occupancy!=2 || !guard_producer_active)$fatal(1,"F9 tail2 setup failed");
  endtask
  task automatic finish_f9_tail();
    repeat(12)begin tick();tail_wait_cycles++;
      if(!guard_producer_active || !guard_active || base_change_ready)$fatal(1,"F9 tail2 released old owner");end
    @(negedge clk);f9_out_read=1;tick();@(negedge clk);f9_out_read=0;
    repeat(12)begin tick();tail_wait_cycles++;
      if(f9_occupancy!=1 || !guard_producer_active || !guard_active)$fatal(1,"F9 tail1 released old owner");end
    @(negedge clk);f9_out_read=1;tick();@(negedge clk);f9_out_read=0;tick();
    if(guard_producer_active || f9_occupancy)$fatal(1,"actual F9 final pop failed to finish old producer");
  endtask
  task automatic consume_lac(input logic [2047:0] p);
    logic [511:0] held_word;
    fork
      begin
        for(int beat=0;beat<4;beat++)begin
          @(negedge clk);lac_in_data=p[beat*512+:512];lac_in_valid=1;
          while(!lac_in_ready)begin tick();@(negedge clk);end
          tick();@(negedge clk);lac_in_valid=0;
        end
      end
      begin
        for(int beat=0;beat<2;beat++)begin
          @(negedge clk);while(!lac_out_valid)begin tick();@(negedge clk);end
          lac_out_read=1;tick();@(negedge clk);lac_out_read=0;
        end
      end
    join
    held_word=lac_out_data;
    repeat(12)begin tick();tail_wait_cycles++;
      if(lac_occupancy!=2 || !guard_action_active || !guard_active || lac_out_data!==held_word)
        $fatal(1,"LAC tail2 released/mutated owner");end
    @(negedge clk);lac_out_read=1;tick();@(negedge clk);lac_out_read=0;
    repeat(12)begin tick();tail_wait_cycles++;
      if(lac_occupancy!=1 || !guard_action_active || !guard_active)$fatal(1,"LAC tail1 released owner");end
    @(negedge clk);producer_valid=guard.safe_completion(p);lac_out_read=1;#1;
    if(guard.safe_completion(p) && producer_ready)$fatal(1,"actual terminal LAC pop admitted new producer");
    tick();@(negedge clk);lac_out_read=0;producer_valid=0;tick();
    if(lac_occupancy)$fatal(1,"LAC actual final pop failed");
  endtask
  task automatic finish_local(input bit poisoned);
    @(negedge clk);physical_safe=1;source_arvalid=0;idle(4);
    if(poisoned)begin
      if(!guard_protocol_error || !guard_active || !guard_revoked || read_debt || guard_producer_active)
        $fatal(1,"R protocol error failed to retain diagnostic exclusion after old drain");
    end else if(guard_active || guard_action_active || guard_producer_active || read_debt ||
        guard_protocol_error || !locks_owned || base_change_ready || source_change_ready)
      $fatal(1,"local consume/drain changed shell old K locks or failed to finish");
    @(negedge clk);state0_awaddr=64'h1200000000;state0_write_is_norm_target=0;#1;
    if(state0_write_allowed || action_ready || producer_ready)$fatal(1,"old shell lock rearmed without CLOSED");
  endtask
  task automatic case_pass(input string label);
    $display("FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_CASE_PASS case=%0d label=%s AR=%0d R=%0d F9_pops=%0d LAC_pops=%0d debt=%0d cancel=%0d error=%0d",cases,label,
      source_ar_pops,source_r_pops,producer_completion_pops,action_completion_pops,read_debt,cancel,guard_protocol_error);
    cases++;
  endtask
  initial begin
    logic [4095:0] short_packet;
    logic [8191:0] bad;
    logic [2047:0] bad_lac;
    if(!$value$plusargs("FIXTURE=%s",fixture) || !$value$plusargs("CAPTURE=%s",capture))
      $fatal(1,"fixture/capture paths missing");
    load("hold",hold_frame);load("query",query_frame);load("proof",proof_frame);
    load("import_ok",import_frame);load("abort",abort_frame);
    load("held_gold",held_gold);load("grant_gold",grant_gold);
    load_short("action",8,action_literal);load("producer",producer_literal);
    load_short("completion_error",4,short_packet);lac_error=short_packet[0+:2048];
    load_short("completion_success",4,short_packet);lac_success=short_packet[0+:2048];
    load_short("f9_window0",8,f9_literal);
    if(hold_frame[80*8+:16]!=1 || hold_frame[82*8+:16]!=64 || action_literal[82*8+:16]!=64)
      $fatal(1,"independent full B1/S64 declaration was substituted");

    // Real HOLD/HELD/query/IMPORT/GRANTED, full response FIFO backpressure,
    // complete codec receipt separate from the 16th response pop.
    clean_reset();grant_actual(1);start_action();
    @(negedge clk);producer_request=producer_literal;producer_request[64*8+:64]=1102;producer_valid=1;
    repeat(12)begin tick();if(producer_ready || source_ar_pops)$fatal(1,"wrong producer identity admitted");end
    producer_request=producer_literal;producer_request[576*8+:32]=2;
    repeat(12)begin tick();if(producer_ready)$fatal(1,"wrong source epoch admitted");end
    producer_request=producer_literal;producer_request[661*8+:8]=1;
    repeat(12)begin tick();if(producer_ready)$fatal(1,"producer reserved bytes admitted");end
    @(negedge clk);producer_valid=0;
    for(int row=0;row<64;row+=16)begin
      start_producer(row);check_writer(row);
      @(negedge clk);source_araddr=64'h1200000000+64'(row+16)*4096;
      source_arlen=0;source_arvalid=1;source_arready=1;#1;
      if(source_ar_allowed)$fatal(1,"AR escaped producer source window");
      tick();@(negedge clk);source_arvalid=0;source_arready=0;
      issue_ar(row);for(int beat=0;beat<4;beat++)rbeat(beat==3,0);
      stage_f9_tail();finish_f9_tail();
    end
    @(negedge clk);physical_safe=0;
    bad_lac=lac_success;bad_lac[24*8+:64]=2;consume_lac(bad_lac);
    if(!guard_active || guard.action_safe_consumed)$fatal(1,"foreign complete LAC released");
    bad_lac=lac_success;bad_lac[206*8+:16]=16;consume_lac(bad_lac);
    if(!guard_active || guard.action_safe_consumed)$fatal(1,"one-window LAC substituted for S64 owner");
    consume_lac(lac_success);finish_local(0);
    if(producers_accepted!=4 || source_ar_pops!=4 || source_r_pops!=16 ||
      producer_completion_pops!=32 || action_completion_pops!=12)$fatal(1,"full declared-window finite counters wrong");
    case_pass("full_B1S64_four_windows_controlled_success");

    // Once VALID has been offered, persistent cancel/live base change cannot
    // erase its old AR. After its actual handshake only accepted old R remains.
    clean_reset();grant_actual(0);start_action();start_producer(0);check_writer(0);
    @(negedge clk);source_araddr=64'h1200000000;source_arlen=3;source_arvalid=1;source_arready=0;
    idle(4);if(!ar_offer_owned || read_debt)$fatal(1,"VALID backpressure did not retain old AR offer");
    @(negedge clk);cancel=1;base_epoch=8;idle(12);
    if(!source_ar_allowed || !ar_offer_owned || !guard_revoked || read_debt)$fatal(1,"revoke erased old VALID offer");
    @(negedge clk);source_arready=1;tick();@(negedge clk);source_arvalid=0;source_arready=0;
    if(read_debt!=4 || ar_offer_owned)$fatal(1,"old revoked AR did not transact exactly once");
    check_writer(0);
    @(negedge clk);source_araddr=64'h1200000100;source_arlen=0;source_arvalid=1;source_arready=1;
    repeat(12)begin tick();if(source_ar_allowed || source_ar_pops!=1)$fatal(1,"cancel/base change admitted new AR");end
    @(negedge clk);source_arvalid=0;source_arready=0;physical_safe=0;
    for(int beat=0;beat<3;beat++)rbeat(0,0);
    stage_f9_tail();consume_lac(lac_error);finish_f9_tail();
    if(read_debt!=1 || !guard_active || guard_producer_active || !guard_action_active)
      $fatal(1,"F9/LAC tails discarded old final R debt");
    idle(12);rbeat(1,0);idle(12);
    if(read_debt || !guard_active || !cancel)$fatal(1,"final old R/physical fence handling wrong");
    finish_local(0);case_pass("persistent_cancel_old_VALID_AR_R_F9_LAC_tails");

    clean_reset();grant_actual(0);start_action();start_producer(0);issue_ar(0);
    @(negedge clk);source_still_matches=0;physical_safe=0;idle(4);
    source_still_matches=1;idle(4);
    if(!guard_revoked || producer_ready || action_ready)$fatal(1,"source mutation was not sticky isolation");
    for(int beat=0;beat<4;beat++)rbeat(beat==3,0);
    stage_f9_tail();consume_lac(lac_error);finish_f9_tail();finish_local(0);
    case_pass("source_mutation_sticky_revoke_old_cleanup");

    for(int fault=0;fault<2;fault++)begin
      clean_reset();grant_actual(0);start_action();start_producer(0);issue_ar(0);
      @(negedge clk);physical_safe=0;
      rbeat(fault==1,fault==0?2'b10:2'b00);
      if(!guard_protocol_error || read_debt!=3)$fatal(1,"RRESP/RLAST error erased beat debt or was missed");
      @(negedge clk);source_arvalid=1;source_arready=1;
      repeat(12)begin tick();if(source_ar_allowed || source_ar_pops!=1)$fatal(1,"R error allowed further AR");end
      @(negedge clk);source_arvalid=0;source_arready=0;
      for(int beat=0;beat<3;beat++)rbeat(beat==2,0);
      stage_f9_tail();consume_lac(lac_error);finish_f9_tail();finish_local(1);
      if(source_r_pops!=4 || producer_completion_pops!=8 || action_completion_pops!=4)
        $fatal(1,"R error suppressed old F9/LAC/R actual consumption");
      case_pass(fault==0?"RRESP_error_old_debt_drained":"RLAST_error_old_debt_drained");
    end

    // The actual shell's header accepts this full old-K source reserved byte;
    // v2 independently checks the complete B codec and closes all new starts.
    clean_reset();bad=hold_frame;bad[148*8+:8]=1;
    @(negedge clk);current_identity=bad[64*8+:768];send_control(bad,0);
    @(negedge clk);predecessor_done_key=pending_key;predecessor_done_valid=1;tick();
    @(negedge clk);predecessor_done_valid=0;old_channels_drained=1;physical_safe=1;idle(12);
    if(!locks_owned || !guard_active || !guard_protocol_error || !guard_revoked ||
        guard_grants_accepted || action_ready || producer_ready || source_ar_allowed)
      $fatal(1,"actual malformed full old shell K supplied source capability");
    if(guard.control_binding_ok(pending_key))$fatal(1,"old-K full B validator missed reserved byte");
    case_pass("actual_shell_old_K_reserved_rejected");
    $display("FULL_CURRENT_EXECUTOR_SOURCE_GUARD_V2_PASS cases=%0d cycles=%0d shell_actual=1 control_transport_actual=1 full_K_B_GRANT_exact=1 no_LBR1_or_proof_boolean=1 controlled_query_fences_F9_LAC_peers=1 B1S64_declared_four_windows=1 finite_AR_not_full_tensor=1 tail2_tail1_waits12=%0d source_target_same_STATE0_disjoint=1 old_lock_retained_no_CLOSED_rearm=1 generated_executor_LN_same_runtime_NOT_RUN=1",cases,cycles,tail_wait_cycles);
    $finish;
  end
endmodule
