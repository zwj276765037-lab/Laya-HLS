`timescale 1ns/1ps
// Finite bridge checks with the real shell and a TB executor-side consumer.
// All 512-bit FIFO pops are real. Accepted whole records are issued only
// after complete byte comparison with independent literal gold, except for
// explicit early/foreign/replay blocked-write tests. Rejection notifications
// use their separate consuming lane. This is not generated HLS.
module laya_executor_control_transport_tb_v1;
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
  int cycles=0,cases=0,tail_wait_cycles=0;

  laya_executor_control_transport_v1 bridge(
    .shell_closed_consumer_valid(closed_consumer_valid),
    .shell_closed_consumer_record(closed_consumer_record),.*);
  laya_executor_handoff_shell_v1 #(.MANAGED_REQUEST_CLOSE(1)) shell(
    .control_valid(shell_control_valid),.control_ready(shell_control_ready),.control(shell_control),
    .response_valid(shell_response_valid),.response_ready(shell_response_ready),.response(shell_response),
    .query_ingress_started(1'b0),.query_ingress_owned(),.*);

  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>5000)$fatal(1,"finite bridge cycle cap");
    if(rst_n)begin
      if(request_occupancy>2 || request_receipt_occupancy>2 || response_occupancy>2)
        $fatal(1,"depth2 occupancy exceeded");
      if(response_stalled && (!shell_response_valid || shell_response!==response_stalled_bytes))
        $fatal(1,"F18 presented shell response changed before actual receipt");
      if(control_stalled && (!shell_control_valid || shell_control!==control_stalled_bytes))
        $fatal(1,"pending complete request changed before shell consumer");
      if(control_response_receipt_full_n && (!response_active || bridge.response_mutated ||
          !shell_response_valid || shell_response!==bridge.response_record ||
          response_send_beats!=16 || response_read_beats!=16 || response_occupancy!=0 ||
          control_response_receipt_din!==bridge.response_record))
        $fatal(1,"accepted full_n allowed success without complete stable matching response drain");
      if(invalid_accepted_receipts!=0)
        $fatal(1,"invalid accepted attempt transacted despite validator backpressure");
      if(shell_response_ready && (!control_response_receipt_write ||
          !control_response_receipt_full_n ||
          response_send_beats!=16 || response_read_beats!=16 || response_occupancy!=0 ||
          control_response_receipt_din!==shell_response))
        $fatal(1,"shell popped without complete actual accepted receipt");
      if(closed_consumer_valid && (!shell_response_ready || shell_response[KIND_OFFSET*8+:8]!=CLOSED))
        $fatal(1,"non-CLOSED response created a closed-consumer fact");
      if(authority_valid && (cancel || revoked || !local_committed || !executor_owns_dispatch))
        $fatal(1,"revoked transport created authority");
    end
    response_stalled<=rst_n && shell_response_valid && !shell_response_ready;
    response_stalled_bytes<=shell_response;
    control_stalled<=rst_n && shell_control_valid && !shell_control_ready;
    control_stalled_bytes<=shell_control;
  end
  task automatic tick();@(posedge clk);#1;endtask
  task automatic idle(input int n);repeat(n)tick();endtask
  task automatic load(input string name,output logic [8191:0] packet);
    $readmemh({fixture,"/",name,".hex"},words);
    for(int beat=0;beat<16;beat++)packet[beat*512+:512]=words[beat];
  endtask
  task automatic save(input string name,input logic [8191:0] packet);
    integer file;file=$fopen({fixture,"/",name,".hex"},"w");
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
  task automatic seal_close();
    @(negedge clk);terminal_seal_record=close_error1;terminal_seal_valid=1;#1;
    if(!terminal_seal_ready || !terminal_seal_accepted || authority_valid)$fatal(1,"controlled terminal seal rejected");
    tick();@(negedge clk);terminal_seal_valid=0;
    request_work_done_record=close_error1;request_work_done_valid=1;
    host_result_consumed_record=close_error1;host_result_consumed_valid=1;
    tick();@(negedge clk);request_work_done_valid=0;host_result_consumed_valid=0;
    send_control(close_error1,1);
  endtask

  initial begin
    logic [8191:0] committed_abort,wrong;
    logic [31:0] consumed;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"fixture missing");
    load("hold",hold_frame);load("query",query_frame);load("proof",proof_frame);
    load("import_ok",import_frame);load("abort",abort_frame);
    load("held_gold",held_gold);load("grant_gold",grant_gold);
    load("close_error_c1",close_error1);load("closed_error_c1",closed_error1);

    // A cancellation in a partial request neither discards its bytes nor
    // fabricates a successful shell response. Its real rejected consume echoes.
    reset_case();
    for(int beat=0;beat<14;beat++)write_request_beat(hold_frame,beat);
    idle(12);if(shell_control_valid || shell_control_consumed || control_request_receipt_empty_n)
      $fatal(1,"partial HOLD escaped before cancel");
    @(negedge clk);cancel=1;write_request_beat(hold_frame,14);idle(12);
    if(shell_control_valid || shell_control_consumed)$fatal(1,"cancel cleared or published a partial HOLD");
    write_request_beat(hold_frame,15);await_control(1);read_echo(hold_frame,1);
    if(control_request_reads!=16 || request_receipt_reads!=16 || control_rejections!=1 ||
        shell_response_valid || locks_owned || !cancel_seen || protocol_error)
      $fatal(1,"old partial control did not finish under persistent cancel");
    cases++;

    // Successful GRANT: no write/pop-tail notification can start dispatch.
    reset_case();acquire();complete_query();send_control(import_frame,1);
    if(!local_committed || authority_valid)$fatal(1,"IMPORT did not retain commit before response receipt");
    collect_response(grant_gold,"actual_success_grant");finish_response(grant_gold);
    if(!authority_valid || !executor_owns_dispatch || grants!=1 || shell_response_pops!=2 ||
        accepted_response_receipts!=2 || protocol_error)$fatal(1,"actual matching GRANT consumer did not authorize once");
    cases++;

    // F18: keep a complete ABORT pending while the old GRANT owns the shell
    // response channel. Persistent cancel allows complete old response drain.
    reset_case();acquire();complete_query();send_control(import_frame,1);
    wait_response(grant_gold);committed_abort=abort_frame;committed_abort[COMMITTED_OFFSET*8+:8]=1;
    consumed=shell_control_consumed;queue_request(committed_abort,0);idle(4);
    if(!shell_control_valid || shell_control_ready || shell_control_consumed!=consumed ||
        shell_control!==committed_abort || control_request_receipt_empty_n)
      $fatal(1,"F18 pending ABORT overwrote/consumed presented GRANT");
    @(negedge clk);cancel=1;idle(12);
    if(!revoked || !locks_owned || authority_valid || shell_response!==grant_gold)
      $fatal(1,"cancel changed GRANT bytes or old lock");
    collect_response(grant_gold,"actual_revoked_grant");finish_response(grant_gold);
    await_control(consumed+1);read_echo(committed_abort,1);
    if(phase!=10 || !revoked || !local_committed || !locks_owned || authority_valid || grants!=0 ||
        accepted_response_receipts!=2 || shell_response_pops!=2 || protocol_error)
      $fatal(1,"revoked old GRANT/committed ABORT did not progress without authority");
    seal_close();collect_response(closed_error1,"actual_closed_error");
    wrong=closed_error1;wrong[COMMITTED_OFFSET*8+:8]=0;accepted_record(wrong,0);
    @(negedge clk);current_session=30;current_request=102;base_epoch=8;idle(12);
    if(!shell_response_valid || shell_response!==closed_error1 || !locks_owned || request_closed)
      $fatal(1,"old CLOSED owner changed with live inputs");
    finish_response(closed_error1);
    if(!request_closed || closed_requests!=1 || locks_owned || authority_valid ||
        last_closed_record!==closed_error1 || accepted_response_receipts!=3 || shell_response_pops!=3 ||
        protocol_error)$fatal(1,"CLOSED complete consumer did not release once");
    send_control(hold_frame,0);idle(12);
    if(!request_closed || closed_requests!=1 || authority_valid || sequence_high_water!=1 || handoff_high_water!=1)
      $fatal(1,"old replay reopened closed shell");
    cases++;

    $display("FULL_CURRENT_EXECUTOR_CONTROL_TRANSPORT_RTL_PASS cases=%0d cycles=%0d depth2_real=1 request16_collect_shell_echo=1 response16_write_read_separate=1 accepted_full_n_validated=1 accepted_actual_fire_shell_ack=1 rejected_whole_consumed_no_pop=1 early_foreign_replay_full_n0_no_fire=1 F18_pending_ABORT_stable_GRANT=1 cancel_old_half_response_progress=1 CLOSED_complete_record_once=1 tail2_tail1_waits12=%0d shell_actual=1 executor_consumer_TB_oracle=1 controlled_query_terminal_fences=1 generated_executor_same_runtime_NOT_RUN=1",cases,cycles,tail_wait_cycles);
    $finish;
  end
endmodule
