`timescale 1ns/1ps
module laya_executor_handoff_shell_tb_v1;
  import laya_executor_handoff_layout_v1::*;
  logic clk=0,rst_n=0,cancel=0;always #5 clk=~clk;
  logic [63:0] current_session=29,current_request=101;
  logic [767:0] current_identity;
  logic base_valid=1;logic [63:0] base_epoch=7,base_address=64'h1200000000,base_capacity=16920576;
  logic control_valid=0,control_ready,response_valid,response_ready=0;
  logic [8191:0] control=0,response,pending_key;
  logic stop_predecessor,locks_owned,predecessor_done_valid=0,predecessor_done_ready;
  logic [8191:0] predecessor_done_key=0;
  logic old_channels_drained=0,physical_safe=0,protection_valid=1;
  logic query_accepted=0,query_response_pop=0;
  logic [8191:0] query_request=0;logic [511:0] query_response_word=0;
  logic query_permit,import_pending,executor_owns_dispatch,authority_valid,revoked,local_committed;
  logic [63:0] sequence_high_water,handoff_high_water;
  logic [31:0] control_rejections,grants,closed_aborts;
  logic [3:0] phase;
  logic [8191:0] hold_frame,query_frame,proof_frame,import_frame,abort_frame;
  logic [8191:0] held_gold,grant_gold,abort_closed_gold;
  logic [511:0] words[0:15];string fixture;
  logic terminal_seal_valid=0,request_work_done_valid=0,host_result_consumed_valid=0;
  logic closed_consumer_valid=0,request_closed;
  logic [8191:0] terminal_seal_record=0,request_work_done_record=0,host_result_consumed_record=0;
  logic [8191:0] closed_consumer_record=0,last_closed_record;
  logic [31:0] closed_requests;
  logic [8191:0] close_ok0,close_ok1,close_error0,close_error1;
  logic [8191:0] closed_ok0,closed_ok1,closed_error0,closed_error1;
  logic [8191:0] close_frame,closed_gold;
  int cycles=0,cases=0,close_cases=0;
  logic stalled_response=0;
  logic [8191:0] stalled_bytes;
  laya_executor_handoff_shell_v1 #(.MANAGED_REQUEST_CLOSE(1)) dut(.query_ingress_started(1'b0),.query_ingress_owned(),.*);
  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>6000)$fatal(1,"cycle cap");
    if(authority_valid && (revoked || cancel || !executor_owns_dispatch || !local_committed))
      $fatal(1,"authority without owner/commit/live binding");
    if(rst_n && stalled_response && (!response_valid || response!==stalled_bytes))
      $fatal(1,"presented response changed before consumption");
    stalled_response<=rst_n && response_valid && !response_ready;
    stalled_bytes<=response;
  end
  task automatic tick();@(posedge clk);#1;endtask
  task automatic idle(input int n);repeat(n)tick();endtask
  task automatic load(input string name,output logic [8191:0] p);
    $readmemh({fixture,"/",name,".hex"},words);
    for(int i=0;i<16;i++)p[i*512+:512]=words[i];
  endtask
  task automatic reset_case();
    @(negedge clk);rst_n=0;cancel=0;control_valid=0;response_ready=0;
    predecessor_done_valid=0;query_accepted=0;query_response_pop=0;
    old_channels_drained=0;physical_safe=0;protection_valid=1;
    terminal_seal_valid=0;request_work_done_valid=0;host_result_consumed_valid=0;closed_consumer_valid=0;
    base_epoch=7;base_address=64'h1200000000;base_capacity=16920576;
    current_session=29;current_request=101;current_identity=hold_frame[64*8+:768];
    idle(3);@(negedge clk);rst_n=1;tick();
  endtask
  task automatic send(input logic [8191:0] p);
    @(negedge clk);control=p;control_valid=1;
    while(!control_ready)tick();tick();@(negedge clk);control_valid=0;
  endtask
  task automatic hold_start();
    send(hold_frame);
    if(phase!=1 || handoff_high_water!=1 || sequence_high_water!=1 || locks_owned || query_permit)
      $fatal(1,"hold did not allocate bounded H/S before query");
    // A bound completion may arrive while old channels/physical debt still
    // remain. This prototype uses controlled safety inputs, not a monitor.
    @(negedge clk);predecessor_done_key=pending_key;predecessor_done_valid=1;
    tick();@(negedge clk);predecessor_done_valid=0;
    repeat(12)begin tick();if(response_valid || locks_owned || !stop_predecessor)$fatal(1,"early held");end
  endtask
  task automatic acquire_held();
    @(negedge clk);old_channels_drained=1;physical_safe=1;tick();
    if(!response_valid || response!==held_gold || !locks_owned || query_permit || authority_valid)
      $fatal(1,"held response or lock wrong");
    repeat(12)begin tick();if(response!==held_gold || query_permit || authority_valid)$fatal(1,"HELD backpressure");end
    @(negedge clk);response_ready=1;tick();@(negedge clk);response_ready=0;
    if(!query_permit || authority_valid)$fatal(1,"held consume boundary");
  endtask
  task automatic query_begin();
    @(negedge clk);query_request=query_frame;query_accepted=1;tick();
    @(negedge clk);query_accepted=0;
    if(phase!=4 || query_permit)$fatal(1,"query ownership");
  endtask
  task automatic query_pop(input int beat);
    @(negedge clk);query_response_word=proof_frame[beat*512+:512];query_response_pop=1;
    tick();@(negedge clk);query_response_pop=0;
  endtask
  task automatic query_complete(input int mutation);
    query_begin();
    for(int i=0;i<14;i++)query_pop(i);
    repeat(12)begin tick();if(import_pending || authority_valid)$fatal(1,"tail2 premature import");end
    query_pop(14);
    repeat(12)begin tick();if(import_pending || authority_valid)$fatal(1,"tail1 premature import");end
    if(mutation==1)cancel=1;
    if(mutation==2)base_epoch=8;
    query_pop(15);cancel=0;base_epoch=7;
    if(!import_pending || authority_valid || local_committed)$fatal(1,"last read granted");
    repeat(12)begin tick();if(authority_valid || local_committed)$fatal(1,"delayed helper granted");end
  endtask
  task automatic confirm();
    send(import_frame);
    if(!response_valid || response!==grant_gold || authority_valid || !local_committed)
      $fatal(1,"IMPORT response wrong or combinational authorization");
    repeat(12)begin tick();if(response!==grant_gold || authority_valid)$fatal(1,"GRANT backpressure");end
  endtask
  task automatic consume_grant();
    @(negedge clk);response_ready=1;tick();@(negedge clk);response_ready=0;
  endtask
  task automatic mutation(input int which);
    if(which==0)cancel=1;
    if(which==1)base_epoch=8;
    if(which==2)current_session=30;
    if(which==3)current_request=102;
  endtask
  task automatic restore();cancel=0;base_epoch=7;current_session=29;current_request=101;endtask
  task automatic close_setup(input bit commit,input bit failed);
    reset_case();hold_start();acquire_held();query_complete(0);
    if(commit)begin confirm();consume_grant();end
    close_frame=commit?(failed?close_error1:close_ok1):(failed?close_error0:close_ok0);
    closed_gold=commit?(failed?closed_error1:closed_ok1):(failed?closed_error0:closed_ok0);
  endtask
  task automatic seal_terminal();
    @(negedge clk);terminal_seal_record=close_frame;terminal_seal_valid=1;tick();
    @(negedge clk);terminal_seal_valid=0;
  endtask
  task automatic work_done();
    @(negedge clk);request_work_done_record=close_frame;request_work_done_valid=1;tick();
    @(negedge clk);request_work_done_valid=0;
  endtask
  task automatic host_done();
    @(negedge clk);host_result_consumed_record=close_frame;host_result_consumed_valid=1;tick();
    @(negedge clk);host_result_consumed_valid=0;
  endtask
  task automatic not_closed(input int n);
    repeat(n)begin tick();if(response_valid || request_closed || closed_requests ||
        !locks_owned || sequence_high_water!=1 || handoff_high_water!=1)
      $fatal(1,"early CLOSED/lock release/highwater mutation");end
  endtask
  task automatic consume_closed();
    if(!response_valid || response!==closed_gold || !locks_owned || authority_valid || request_closed)
      $fatal(1,"CLOSED result/commit/full key wrong");
    @(negedge clk);closed_consumer_record=closed_gold;closed_consumer_valid=1;response_ready=1;tick();
    @(negedge clk);closed_consumer_valid=0;response_ready=0;
    if(response_valid || !request_closed || closed_requests!=1 || locks_owned ||
        executor_owns_dispatch || authority_valid || !stop_predecessor ||
        last_closed_record!==closed_gold || sequence_high_water!=1 || handoff_high_water!=1)
      $fatal(1,"CLOSED consumption did not end old owner exactly once");
    restore();send(close_frame);send(import_frame);send(hold_frame);idle(12);
    if(!request_closed || closed_requests!=1 || !stop_predecessor || locks_owned ||
        authority_valid || last_closed_record!==closed_gold || query_permit)
      $fatal(1,"closed old owner reopened legacy IDLE");
  endtask
  task automatic save_closed(input string name);
    integer fd;fd=$fopen({fixture,"/",name,".hex"},"w");
    if(fd==0)$fatal(1,"close capture file missing");
    for(int i=0;i<16;i++)$fdisplay(fd,"%0128h",response[i*512+:512]);$fclose(fd);
  endtask
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"fixture missing");
    load("hold",hold_frame);load("query",query_frame);load("proof",proof_frame);
    load("import_ok",import_frame);load("abort",abort_frame);
    load("held_gold",held_gold);load("grant_gold",grant_gold);load("abort_closed_gold",abort_closed_gold);
    load("close_ok_c0",close_ok0);load("close_ok_c1",close_ok1);
    load("close_error_c0",close_error0);load("close_error_c1",close_error1);
    load("closed_ok_c0",closed_ok0);load("closed_ok_c1",closed_ok1);
    load("closed_error_c0",closed_error0);load("closed_error_c1",closed_error1);
    reset_case();hold_start();acquire_held();
    // Early/wrong-key confirmations are consumed, not left blocking the right
    // confirmation. They do not commit or unlock the pending transaction.
    send(import_frame);if(local_committed || authority_valid)$fatal(1,"early import");
    query_complete(0);
    for(int i=0;i<7;i++)begin
      logic [8191:0] wrong;wrong=import_frame;
      case(i)
        0:wrong[16*8+:64]=2;
        1:wrong[680*8+:64]=2;
        2:wrong[776*8+:64]=30;
        3:wrong[784*8+:64]=102;
        4:wrong[64*8+:64]=1102;
        5:wrong[40*8+:64]=8;
        6:wrong[1023*8+:8]=1;
      endcase
      send(wrong);if(local_committed || response_valid || authority_valid)$fatal(1,"wrong import key");
    end
    if(control_rejections!=8)$fatal(1,"bounded control reject count");
    confirm();consume_grant();
    if(!authority_valid || grants!=1 || !executor_owns_dispatch)$fatal(1,"unique grant failed");
    send(import_frame);if(grants!=1 || !authority_valid)$fatal(1,"duplicate grant");
    // Active debt cannot revoke its old owner. The immutable binding remains
    // live while the owner must complete its existing physical work.
    physical_safe=0;old_channels_drained=0;idle(12);
    if(!authority_valid || revoked || !executor_owns_dispatch)$fatal(1,"normal debt revoked");
    cases++;

    // F18: commit0 ABORT is accepted exactly when autonomous HELD would
    // acquire the lock. Control wins; no HELD is presented or overwritten.
    reset_case();hold_start();
    @(negedge clk);old_channels_drained=1;physical_safe=1;
    control=abort_frame;control_valid=1;#1;
    if(!control_ready)$fatal(1,"same-edge DRAIN abort not selected");
    tick();
    if(phase!=8 || response_valid || locks_owned || revoked || authority_valid)
      $fatal(1,"DRAIN abort competed with HELD");
    // Keep the request asserted while its result is backpressured. It must
    // not allocate a second key, publish HELD, or close twice.
    tick();
    if(phase!=9 || !response_valid || response!==abort_closed_gold)
      $fatal(1,"F18 bound abort response missing");
    repeat(12)begin tick();if(response!==abort_closed_gold || control_ready || locks_owned ||
        grants!=0 || closed_aborts!=0 || sequence_high_water!=1 || handoff_high_water!=1)
      $fatal(1,"F18 abort response or highwater changed under stall");end
    @(negedge clk);response_ready=1;tick();
    @(negedge clk);response_ready=0;control_valid=0;
    if(phase!=0 || response_valid || closed_aborts!=1 || locks_owned)
      $fatal(1,"F18 DRAIN abort close not unique");
    cases++;

    // HELD_READY without an accepted query: ABORT wins and closes once.
    reset_case();hold_start();acquire_held();
    @(negedge clk);control=abort_frame;control_valid=1;query_request=query_frame;#1;
    if(!query_permit || !control_ready)$fatal(1,"F18 HELD arbitration readiness");
    query_accepted=0;tick();
    @(negedge clk);query_accepted=0;
    if(phase!=8 || import_pending)$fatal(1,"F18 query accepted alongside abort");
    tick();
    repeat(12)begin tick();if(!response_valid || response!==abort_closed_gold || query_permit)
      $fatal(1,"F18 held abort response unstable");end
    @(negedge clk);response_ready=1;tick();
    @(negedge clk);response_ready=0;control_valid=0;
    if(phase!=0 || closed_aborts!=1 || grants!=0 || locks_owned)
      $fatal(1,"F18 held abort close wrong");
    cases++;

    // Actual query acceptance has priority over control acceptance. ABORT
    // stays valid throughout the old return; it is not dropped or accepted
    // as a harmless reject while QUERY still owns the response.
    reset_case();hold_start();acquire_held();
    @(negedge clk);control=abort_frame;control_valid=1;
    query_request=query_frame;query_accepted=1;#1;
    if(control_ready || !query_permit)$fatal(1,"F18 accepted query priority missing");
    tick();@(negedge clk);query_accepted=0;
    if(phase!=4 || control_ready)$fatal(1,"F18 query lost to pending abort");
    for(int i=0;i<14;i++)begin
      query_pop(i);if(control_ready || response_valid || authority_valid)
        $fatal(1,"F18 pending abort accepted before return drained");
    end
    repeat(12)begin tick();if(control_ready || !locks_owned)$fatal(1,"F18 return tail2 ownership");end
    query_pop(14);
    repeat(12)begin tick();if(control_ready || !locks_owned)$fatal(1,"F18 return tail1 ownership");end
    query_pop(15);
    if(!import_pending || response_valid || authority_valid)$fatal(1,"F18 last read authorized");
    tick();if(phase!=8)$fatal(1,"F18 persistent abort not accepted after response");
    tick();
    repeat(12)begin tick();if(!response_valid || response!==abort_closed_gold || control_ready ||
        authority_valid || grants!=0 || !locks_owned)$fatal(1,"F18 query abort close changed");end
    @(negedge clk);response_ready=1;tick();
    @(negedge clk);response_ready=0;control_valid=0;
    if(phase!=0 || closed_aborts!=1 || sequence_high_water!=1 || handoff_high_water!=1)
      $fatal(1,"F18 query abort close/highwater wrong");
    cases++;

    // Actual C++ helper reservation-hole rejection drives this bound ABORT.
    reset_case();hold_start();acquire_held();query_complete(0);
    physical_safe=0;send(abort_frame);idle(12);
    if(response_valid || authority_valid || local_committed || !locks_owned)$fatal(1,"abort before safe");
    physical_safe=1;tick();
    if(!response_valid || response!==abort_closed_gold || authority_valid)$fatal(1,"abort close binding");
    idle(12);if(response!==abort_closed_gold || !locks_owned)$fatal(1,"abort response unstable");
    @(negedge clk);response_ready=1;tick();@(negedge clk);response_ready=0;
    if(phase!=0 || locks_owned || handoff_high_water!=1 || sequence_high_water!=1 || closed_aborts!=1)
      $fatal(1,"abort cleared highwater or wrong retry state");
    begin
      logic [8191:0] next_hold;next_hold=hold_frame;next_hold[16*8+:64]=2;send(next_hold);
      if(handoff_high_water!=2 || sequence_high_water!=2)$fatal(1,"no-reset retry reused keys");
      send(import_frame);if(local_committed || authority_valid)$fatal(1,"old confirmation after retry");
    end
    cases++;

    for(int mode=0;mode<14;mode++)begin
      reset_case();hold_start();
      if(mode<2)begin
        @(negedge clk);mutation(mode);old_channels_drained=1;physical_safe=1;tick();restore();idle(12);
        if(response_valid || locks_owned || query_permit || !revoked)$fatal(1,"hold acquire revoke race");
      end else begin
        acquire_held();query_complete(mode<4?mode-1:0);
        if(mode<4)begin
          send(import_frame);if(!local_committed || response_valid || !revoked)$fatal(1,"last read revoke race");
        end else if(mode<6)begin
          @(negedge clk);mutation(mode-4);send(import_frame);restore();idle(12);
          if(!local_committed || response_valid || !revoked)$fatal(1,"import same-edge revoke race");
        end else begin
          confirm();
          if(mode<8)begin
            @(negedge clk);mutation(mode-6);tick();restore();idle(12);
            if(response!==grant_gold || authority_valid || !revoked)$fatal(1,"grant stall revoke changed bytes");
            consume_grant();
          end else if(mode<10)begin
            @(negedge clk);mutation(mode-8);consume_grant();restore();tick();
          end else begin
            consume_grant();if(!authority_valid)$fatal(1,"start authority missing");
            @(negedge clk);mutation(mode-10);#1;
            if(authority_valid)$fatal(1,"same-cycle new start after cancel/base/session/request");
            tick();restore();idle(12);
          end
          if(authority_valid || !executor_owns_dispatch || !locks_owned || !revoked || !local_committed)
            $fatal(1,"revoke lost owner/locks/commit or reopened authority");
          // Never pretend a committed import was uncommitted to regain the
          // predecessor. Old cleanup ownership is retained even in isolation.
          send(abort_frame);if(phase==0 || !local_committed)$fatal(1,"commit0 abort reopened");
          begin logic [8191:0] committed_abort;committed_abort=abort_frame;committed_abort[792*8+:8]=1;
            send(committed_abort);if(phase!=10 || !executor_owns_dispatch || !locks_owned)$fatal(1,"committed abort lost cleanup");end
        end
      end
      cases++;
    end
    // Four sealed result/commit combinations. Status is the old request
    // terminal, not a second close-operation success status.
    for(int variant=0;variant<4;variant++)begin
      close_setup(variant[0],variant[1]);
      send(close_frame);if(phase==11)$fatal(1,"unsealed terminal accepted CLOSE");
      seal_terminal();
      @(negedge clk);old_channels_drained=0;physical_safe=0;
      send(close_frame);if(phase!=11 || authority_valid)$fatal(1,"bound close intent not retained");
      not_closed(12);work_done();not_closed(12);host_done();not_closed(12);
      old_channels_drained=1;not_closed(12);old_channels_drained=0;physical_safe=1;not_closed(12);
      old_channels_drained=1;tick();
      if(!response_valid || phase!=12 || response!==closed_gold)$fatal(1,"sealed CLOSED missing");
      $display("CLOSE_CASE_PRESENTED variant=%0d cycle=%0d",variant,cycles);
      case(variant)
        0:save_closed("closed_ok_c0_capture");
        1:save_closed("closed_ok_c1_capture");
        2:save_closed("closed_error_c0_capture");
        3:save_closed("closed_error_c1_capture");
      endcase
      $display("CLOSE_CASE_CAPTURED variant=%0d cycle=%0d",variant,cycles);
      // Raw ready alone does not represent full codec/key/result consumption.
      @(negedge clk);response_ready=1;idle(12);
      if(!response_valid || request_closed || closed_requests || !locks_owned)
        $fatal(1,"untagged response read released CLOSED");
      response_ready=0;cancel=1;base_epoch=8;current_session=30;current_request=102;
      repeat(12)begin tick();if(response!==closed_gold || !response_valid || !locks_owned)
        $fatal(1,"cancel/live change overwrote CLOSED");end
      for(int wrong=0;wrong<5;wrong++)begin
        @(negedge clk);closed_consumer_record=closed_gold;closed_consumer_valid=1;response_ready=1;
        case(wrong)
          0:closed_consumer_record[776*8+:64]=30;
          1:closed_consumer_record[784*8+:64]=102;
          2:closed_consumer_record[792*8+:8]=!variant[0];
          3:closed_consumer_record[24*8+:32]=32'h0700000f;
          4:closed_consumer_record[32*8+:64]=0;
        endcase
        tick();if(!response_valid || request_closed || !locks_owned || closed_requests)
          $fatal(1,"foreign CLOSED consumer released owner");
        @(negedge clk);closed_consumer_valid=0;response_ready=0;
      end
      consume_closed();close_cases++;
    end
    // Helper committed while shell has not yet seen IMPORT. CLOSE cannot
    // invent the retained fact. Actual IMPORT under cancellation communicates
    // commit without granting a start; then the original error can close.
    close_setup(0,1);close_frame=close_error1;closed_gold=closed_error1;
    send(close_frame);seal_terminal();
    if(local_committed || phase!=5 || response_valid)$fatal(1,"CLOSE fabricated import commit");
    cancel=1;send(import_frame);
    if(!local_committed || response_valid || authority_valid)$fatal(1,"actual IMPORT fact or revoke lost");
    seal_terminal();send(close_frame);work_done();host_done();tick();consume_closed();close_cases++;
    close_setup(1,1);seal_terminal();
    for(int which=0;which<11;which++)begin
      logic [8191:0] wrong;wrong=close_frame;
      case(which)
        0:wrong[16*8+:64]=2;
        1:wrong[680*8+:64]=2;
        2:wrong[776*8+:64]=30;
        3:wrong[784*8+:64]=102;
        4:wrong[792*8+:8]=0;
        5:wrong[10*8+:16]=4;
        6:wrong[24*8+:32]=32'h0700000f;
        7:wrong[32*8+:64]=0;
        8:wrong[8*8+:8]=10;
        9:wrong[1023*8+:8]=1;
        10:wrong[64*8+:64]=1102;
      endcase
      send(wrong);if(phase!=7 || !local_committed || response_valid || request_closed)
        $fatal(1,"foreign CLOSE changed owner/phase/commit");
      close_cases++;
    end
    cancel=1;base_epoch=8;current_session=30;current_request=102;
    send(close_frame);work_done();host_done();tick();
    if(!response_valid || response!==closed_gold)$fatal(1,"old owner cancel prevented close cleanup");
    consume_closed();close_cases++;
    $display("FULL_CURRENT_EXECUTOR_HANDOFF_SHELL_RTL_PASS cases=%0d cycles=%0d close_cases=%0d sealed_terminal_commit=1 full_closed_consumer=1 closed_wait_new_admission=1 old_cancel_close_progress=1 close_safety_inputs_controlled=1 F18_drain_abort_same_edge=1 F18_held_query_abort_priority=1 F18_accepted_query_persistent_abort=1 response_stall_stable=1 actual_helper_import_abort=1 held_query_import_grant=1 final_read_no_authority=1 tail2_tail1_stalls=1 unique_grant=1 no_reset_precommit_retry=1 cancel_base_same_edge=1 active_session_request_revoke=1 cleanup_owner_retained=1 controlled_safety_inputs=1 hardware_rearm_NOT_RUN=1",cases,cycles,close_cases);
    $finish;
  end
endmodule
