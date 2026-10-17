`timescale 1ns/1ps
module tm1tn8_reserved_store_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n, issue_valid, issue_ready, arithmetic_issue_valid;
  logic arithmetic_issue_ready, issue_trace;
  logic [159:0] issue_tag, ret_tag, commit_tag, trace_tag, trace_ack_tag;
  logic [8:0] issue_tile, ret_tile, commit_tile;
  logic [7:0] issue_lane_mask, ret_lane_mask, ret_bad_mask;
  logic [2:0] issue_trace_lane;
  logic [5:0] issue_result_slot, ret_result_slot, commit_slot;
  logic [1:0] issue_trace_slot, ret_trace_slot, trace_slot, trace_ack_slot;
  logic ret_valid, ret_trace, commit_valid, commit_ready;
  logic [255:0] ret_next_ps, ret_trace_payload, commit_next_ps, trace_payload;
  logic [7:0] commit_lane_mask, commit_bad_mask;
  logic [23:0] ret_phase, commit_phase;
  logic trace_valid, trace_ready, trace_ack_valid, trace_ack_ok;
  logic [5:0] result_free, result_reserved, result_returned;
  logic [2:0] trace_free;
  logic protocol_error;
  integer commit_seen;
  logic check_commits;

  function automatic logic [159:0] owner_tag(input int index);
    logic [159:0] tag_value;
    begin
      tag_value=160'(index+1);
      tag_value[63]=(index%35)>=32;
      owner_tag=tag_value;
    end
  endfunction

  tm1tn8_reserved_store dut (.*);

  initial begin
    #10000;
    $fatal(1,"reserved store watchdog issue_head=%0d commit_head=%0d free=%0d reserved=%0d returned=%0d trace_free=%0d commit_valid=%0b",
           dut.issue_head,dut.commit_head,result_free,result_reserved,
           result_returned,trace_free,commit_valid);
  end

  task automatic send_issue(input int index, input bit traced);
    begin
      @(negedge clk);
      issue_tag=owner_tag(index);
      issue_tile=9'(index);
      issue_lane_mask=8'hff;
      issue_trace=traced;
      issue_trace_lane=0;
      issue_valid=1;
      #1ps;
      if (!issue_ready || !arithmetic_issue_valid ||
          issue_result_slot !== 6'(index%35) ||
          (traced && issue_trace_slot !== 2'(index)))
        $fatal(1,"issue reservation index=%0d",index);
      @(negedge clk);
      issue_valid=0;
    end
  endtask

  task automatic send_return(input int index, input bit traced);
    begin
      @(negedge clk);
      ret_valid=1;
      ret_result_slot=6'(index%35);
      ret_trace_slot=traced ? 2'(index) : 0;
      ret_tag=owner_tag(index);
      ret_tile=9'(index);
      ret_lane_mask=8'hff;
      ret_bad_mask=0;
      ret_phase={8{3'd4}};
      ret_trace=traced;
      ret_next_ps={8{32'(index+100)}};
      ret_trace_payload={8{32'(index+200)}};
      @(negedge clk);
      ret_valid=0;
    end
  endtask

  task automatic reset_protocol_case;
    begin
      @(negedge clk);
      rst_n=0;
      issue_valid=0;
      ret_valid=0;
      commit_ready=0;
      trace_ready=0;
      trace_ack_valid=0;
      repeat (3) @(negedge clk);
      rst_n=1;
      #1ps;
      if (result_free !== 35 || result_reserved !== 0 ||
          result_returned !== 0 || protocol_error)
        $fatal(1,"protocol case reset credits");
    end
  endtask

  always @(posedge clk) begin
    if (rst_n && commit_valid && commit_ready && check_commits) begin
      if (commit_tag !== owner_tag(commit_seen) ||
          commit_slot !== 6'(commit_seen%35) ||
          commit_tile !== 9'(commit_seen) ||
          commit_next_ps !== {8{32'(commit_seen+100)}} ||
          commit_lane_mask !== 8'hff || commit_bad_mask !== 0 ||
          commit_phase !== {8{3'd4}})
        $fatal(1,"ordered commit index=%0d",commit_seen);
      commit_seen=commit_seen+1;
    end
  end

  initial begin : test
    integer timeout;
    logic [1:0] saved_slot;
    rst_n=0; issue_valid=0; arithmetic_issue_ready=1;
    issue_tag=0; issue_tile=0; issue_lane_mask=0; issue_trace=0;
    issue_trace_lane=0; ret_valid=0; ret_result_slot=0;
    ret_trace_slot=0; ret_tag=0; ret_tile=0; ret_lane_mask=0;
    ret_bad_mask=0; ret_phase=0; ret_trace=0; ret_next_ps=0;
    ret_trace_payload=0; commit_ready=0; trace_ready=0;
    trace_ack_valid=0; trace_ack_slot=0; trace_ack_tag=0;
    trace_ack_ok=1; commit_seen=0; check_commits=1;
    repeat (3) @(negedge clk);
    rst_n=1;
    if (result_free !== 35 || result_reserved !== 0 ||
        trace_free !== 4) $fatal(1,"reset credits");
    for (integer i=0;i<4;i++) send_issue(i,1);
    @(negedge clk);
    issue_valid=1; issue_tile=9'd4; issue_tag=160'd5;
    issue_trace=1; issue_lane_mask=8'hff;
    #1ps;
    repeat (3) begin
      if (issue_ready || arithmetic_issue_valid)
        $fatal(1,"D4 credit did not stall fifth selected trace");
      @(negedge clk);
    end
    issue_valid=0;
    for (integer i=4;i<35;i++) send_issue(i,0);
    if (result_free !== 0 || result_reserved !== 35 ||
        trace_free !== 0) $fatal(1,"Q35/D4 credit capacity");
    @(negedge clk);
    issue_valid=1; issue_tile=9'd100; issue_trace=0;
    #1ps;
    if (issue_ready || arithmetic_issue_valid)
      $fatal(1,"Q35 did not stall thirty-sixth issue");
    issue_valid=0;
    for (integer i=0;i<35;i++) send_return(i,i<4);
    if (result_reserved !== 0 || result_returned !== 35 ||
        result_free !== 0) $fatal(1,"return credit conservation");
    @(negedge clk);
    commit_ready=1;
    timeout=0;
    while (commit_seen<35) begin
      @(negedge clk);
      timeout++;
      if (timeout>80) $fatal(1,"commit drain timeout");
    end
    commit_ready=0;
    repeat (2) @(negedge clk);
    if (result_free !== 35 || result_returned !== 0 ||
        trace_free !== 0 || protocol_error)
      $fatal(1,"post-commit debt");
    for (integer i=0;i<4;i++) begin
      timeout=0;
      while (!trace_valid) begin
        @(negedge clk);
        timeout++;
        if (timeout>20) $fatal(1,"trace wait timeout");
      end
      if (trace_slot !== 2'(i) || trace_tag !== owner_tag(i) ||
          trace_payload !== {8{32'(i+200)}})
        $fatal(1,"D4 trace payload index=%0d",i);
      saved_slot=trace_slot;
      @(negedge clk); trace_ready=1;
      @(negedge clk); trace_ready=0;
      trace_ack_valid=1; trace_ack_slot=saved_slot;
      trace_ack_tag=owner_tag(i);
      @(negedge clk); trace_ack_valid=0;
    end
    repeat (2) @(negedge clk);
    if (trace_free !== 4 || protocol_error)
      $fatal(1,"trace ack debt");
    // Traverse 34->0 twice more, including slots 31, 32, 34 and 0.
    for (integer round=1;round<=2;round++) begin
      for (integer i=round*35;i<(round+1)*35;i++) send_issue(i,0);
      if (result_free !== 0 || result_reserved !== 35)
        $fatal(1,"Q35 wrap fill round=%0d",round);
      for (integer i=round*35;i<(round+1)*35;i++) send_return(i,0);
      @(negedge clk); commit_ready=1;
      timeout=0;
      while (commit_seen<(round+1)*35) begin
        @(negedge clk);
        timeout++;
        if (timeout>80) $fatal(1,"Q35 wrap drain round=%0d",round);
      end
      commit_ready=0;
      repeat (2) @(negedge clk);
      if (result_free !== 35 || result_reserved !== 0 ||
          result_returned !== 0 || dut.issue_head !== 0 ||
          dut.commit_head !== 0 || protocol_error)
        $fatal(1,"Q35 wrap conservation round=%0d",round);
    end
    // A committed tile remains barred for two additional issue cycles.
    check_commits=0;
    send_issue(0,0);
    send_return(0,0);
    @(negedge clk); commit_ready=1;
    wait (commit_valid);
    @(negedge clk); commit_ready=0;
    issue_valid=1; issue_tile=0; issue_lane_mask=8'hff;
    #1ps;
    if (issue_ready) $fatal(1,"feedback c+1 issue was accepted");
    @(negedge clk);
    if (issue_ready) $fatal(1,"feedback c+2 issue was accepted");
    issue_valid=0;
    if (protocol_error) $fatal(1,"protocol error");

    // Issue, fixed return, and commit may all occur on one edge.
    reset_protocol_case();
    send_issue(0,0);
    send_issue(1,0);
    send_return(0,0);
    wait (commit_valid);
    @(negedge clk);
    issue_valid=1;
    issue_tag=owner_tag(2);
    issue_tile=9'd2;
    issue_lane_mask=8'hff;
    issue_trace=0;
    ret_valid=1;
    ret_result_slot=6'd1;
    ret_tag=owner_tag(1);
    ret_tile=9'd1;
    ret_lane_mask=8'hff;
    ret_trace=0;
    ret_trace_slot=0;
    ret_bad_mask=0;
    ret_phase={8{3'd4}};
    ret_next_ps={8{32'd101}};
    ret_trace_payload={8{32'd201}};
    commit_ready=1;
    #1ps;
    if (!issue_ready || !arithmetic_issue_valid ||
        issue_result_slot !== 6'd2)
      $fatal(1,"simultaneous event issue not ready");
    @(negedge clk);
    issue_valid=0;
    ret_valid=0;
    if (result_free !== 33 || result_reserved !== 1 ||
        result_returned !== 1 || protocol_error)
      $fatal(1,"simultaneous issue/return/commit conservation");
    send_return(2,0);
    repeat (10) @(negedge clk);
    if (result_free !== 35 || result_reserved !== 0 ||
        result_returned !== 0 || protocol_error)
      $fatal(1,"simultaneous event drain");

    reset_protocol_case();
    @(negedge clk); ret_valid=1; ret_result_slot=6'd35;
    @(negedge clk); ret_valid=0;
    if (!protocol_error || result_free !== 35 || result_reserved !== 0)
      $fatal(1,"illegal result slot 35");
    reset_protocol_case();
    @(negedge clk); ret_valid=1; ret_result_slot=6'd63;
    @(negedge clk); ret_valid=0;
    if (!protocol_error || result_free !== 35 || result_reserved !== 0)
      $fatal(1,"illegal result slot 63");
    reset_protocol_case();
    send_issue(0,0);
    @(negedge clk);
    ret_valid=1; ret_result_slot=0; ret_tag=owner_tag(0)^160'h100;
    ret_tile=0; ret_lane_mask=8'hff; ret_trace=0;
    ret_trace_slot=0; ret_bad_mask=0;
    @(negedge clk); ret_valid=0;
    if (!protocol_error || result_reserved !== 1 || result_returned !== 0)
      $fatal(1,"stale or wrong fulltag return");
    reset_protocol_case();
    send_issue(0,0);
    send_return(0,0);
    send_return(0,0);
    if (!protocol_error || result_reserved !== 0 || result_returned !== 1)
      $fatal(1,"duplicate fixed return");
    $display("TM1TN8_RESERVED_STORE_PASS Q=35 D=4 commits=%0d",commit_seen);
    $finish;
  end
endmodule
