`timescale 1ns/1ps
// Dormant finite probe of the real source RTL shell. No generated arithmetic
// is used: accepted arithmetic return records are driven directly at the
// no-ready port. Never interpret these source vectors as measured FP latency.
module c1_reserved_store_probe;
  logic clk=0,rst_n=0;
  logic issue_valid=0,arithmetic_issue_ready=1;
  logic issue_ready,arithmetic_issue_valid;
  logic [16:0] issue_seq=0;
  logic [3:0] issue_m0=0;
  logic [6:0] issue_g=0;
  logic [9:0] issue_tile=0;
  logic issue_last_g=0;
  logic [31:0] issue_shape_mask=1;
  logic issue_trace_reserved=0;
  logic [4:0] issue_trace_lane=0;
  logic [5:0] issue_result_slot;
  logic [1:0] issue_trace_slot;
  logic ret_valid=0,ret_last_g=0,ret_trace_reserved=0;
  logic [16:0] ret_seq=0;
  logic [3:0] ret_m0=0;
  logic [6:0] ret_g=0;
  logic [9:0] ret_tile=0;
  logic [5:0] ret_result_slot=0;
  logic [1:0] ret_trace_slot=0;
  logic [4:0] ret_trace_lane=0;
  logic [31:0] ret_shape_mask=1,ret_bad_mask=0;
  logic [1298:0] ret_result_payload=0;
  logic [255:0] ret_trace_payload=0;
  logic return_written;
  logic [5:0] return_written_slot;
  logic commit_valid,commit_ready=0;
  logic [5:0] commit_slot;
  logic [1298:0] commit_payload;
  logic trace_send_valid,trace_send_ready=0;
  logic [31:0] trace_command_seq=0;
  logic [1:0] trace_send_slot;
  logic [16:0] trace_send_seq;
  logic [255:0] trace_send_payload;
  logic trace_ack_valid=0;
  logic [2:0] trace_ack_kind=0;
  logic [1:0] trace_ack_slot=0;
  logic [31:0] trace_ack_seq=0;
  logic [6:0] result_free_count,result_reserved_count,
              result_returned_count;
  logic [2:0] trace_free_count;
  logic protocol_error;
  logic [5:0] slot_for_seq[0:127];
  logic [1:0] trace_slot_for_seq[0:127];
  logic trace_for_seq[0:127];
  logic [9:0] tile_for_seq[0:127];
  logic [16:0] issue_order[0:127];
  int cycle=0,issues=0,returns=0,commits=0;
  bit triple_seen=0;
  c1_reserved_store dut(.*);
  always #5ns clk=~clk;

  function automatic logic [1298:0] packed_result(input int seq);
    logic [1298:0] p;
    p=0;
    p[31:0]=32'h3f800000+32'(seq);
    p[1055:1024]=32'h1;
    p[1087:1056]=32'h1;
    p[1119:1088]=32'h1;
    p[1168:1152]=17'(seq);
    p[1172:1169]=4'd0;
    p[1179:1173]=7'd0;
    p[1189:1180]=tile_for_seq[seq];
    p[1190]=1'b0;
    p[1196:1191]=slot_for_seq[seq];
    p[1197]=trace_for_seq[seq];
    p[1199:1198]=trace_slot_for_seq[seq];
    p[1298:1293]=6'd1;
    return p;
  endfunction
  task automatic issue_one(input int seq,input bit traced);
    @(negedge clk);
    issue_seq=17'(seq);issue_tile=10'(seq);
    issue_trace_reserved=traced;issue_valid=1;
    do @(posedge clk); while (issue_ready!==1'b1);
    @(negedge clk);issue_valid=0;
  endtask
  task automatic return_one(input int seq);
    @(negedge clk);
    ret_seq=17'(seq);ret_tile=tile_for_seq[seq];
    ret_result_slot=slot_for_seq[seq];
    ret_trace_reserved=trace_for_seq[seq];
    ret_trace_slot=trace_slot_for_seq[seq];
    ret_result_payload=packed_result(seq);
    ret_trace_payload=0;
    ret_trace_payload[223:192]=32'd0;
    ret_trace_payload[255:224]=32'd1;
    ret_valid=1;
    @(posedge clk);
    @(negedge clk);ret_valid=0;
  endtask
  always @(posedge clk) begin
    cycle++;
    if (cycle>1000) $fatal(1,"C1_STORE_PROBE_WATCHDOG");
    if (rst_n && protocol_error) $fatal(1,"C1_STORE_PROTOCOL_ERROR");
    if (rst_n && issue_valid && issue_ready) begin
      if (!arithmetic_issue_valid || issues>=128)
        $fatal(1,"C1_STORE_ISSUE_BINDING");
      slot_for_seq[issue_seq]=issue_result_slot;
      trace_slot_for_seq[issue_seq]=issue_trace_slot;
      trace_for_seq[issue_seq]=issue_trace_reserved;
      tile_for_seq[issue_seq]=issue_tile;
      issue_order[issues]=issue_seq;
      issues++;
    end
    if (rst_n && issue_valid && issue_ready &&
        ret_valid && commit_valid && commit_ready)
      triple_seen=1;
    if (rst_n && commit_valid && commit_ready) begin
      if (commits>=issues ||
          commit_payload[1168:1152]!==issue_order[commits] ||
          commit_slot!==slot_for_seq[issue_order[commits]] ||
          commit_payload[1119:1088]!==32'h1)
        $fatal(1,"C1_STORE_COMMIT_ORDER_OR_DATA");
      commits++;
    end
    #1ps;
    if (rst_n && return_written) begin
      if (returns>=issues || return_written_slot!==ret_result_slot)
        $fatal(1,"C1_STORE_RETURN_WRITE");
      returns++;
    end
  end
  initial begin
    repeat(4) @(negedge clk);rst_n=1;
    // Fill all 64 result credits while commit and trace writer are paused.
    for (int i=0;i<64;i++) issue_one(i,i==0);
    if (result_free_count!==0 || result_reserved_count!==64 ||
        commit_valid!==0) $fatal(1,"C1_STORE_RESERVATION");
    @(negedge clk);
    issue_seq=17'd64;issue_tile=10'd64;issue_trace_reserved=0;
    issue_valid=1;
    @(posedge clk);
    if (issue_ready!==0) $fatal(1,"C1_STORE_PREEDGE_CREDIT");
    @(negedge clk);issue_valid=0;
    for (int i=0;i<64;i++) return_one(i);
    repeat(3) @(negedge clk);
    if (returns!=64 || result_reserved_count!==0 ||
        result_returned_count!==64 || result_free_count!==0)
      $fatal(1,"C1_STORE_NO_READY_RETURN_LOSS");
    if (trace_free_count!==3)
      $fatal(1,"C1_STORE_TRACE_OWNERSHIP");
    @(negedge clk);commit_ready=1;
    wait(commits==64);
    repeat(3) @(negedge clk);
    if (result_free_count!==64 || !trace_send_valid ||
        trace_send_slot!==0 || trace_send_seq!==0 ||
        trace_send_payload[255:224]!==32'd1)
      $fatal(1,"C1_STORE_COMMIT_DRAIN");
    @(negedge clk);
    trace_command_seq=32'd42;trace_send_ready=1;
    @(posedge clk);
    @(negedge clk);trace_send_ready=0;
    repeat(2) @(negedge clk);
    trace_ack_valid=1;trace_ack_kind=3'd2;
    trace_ack_slot=0;trace_ack_seq=32'd42;
    @(posedge clk);
    @(negedge clk);trace_ack_valid=0;
    repeat(2) @(negedge clk);
    if (trace_free_count!==4) $fatal(1,"C1_STORE_ACK_RETIRE");

    // Distinct slots exercise issue + return + physical commit in one edge.
    commit_ready=0;
    issue_one(100,0);
    issue_one(101,0);
    return_one(100);
    wait(commit_valid);
    @(negedge clk);
    issue_seq=17'd102;issue_tile=10'd102;
    issue_trace_reserved=0;issue_valid=1;
    ret_seq=17'd101;ret_tile=tile_for_seq[101];
    ret_result_slot=slot_for_seq[101];ret_trace_reserved=0;
    ret_trace_slot=0;ret_result_payload=packed_result(101);
    ret_trace_payload=0;ret_valid=1;commit_ready=1;
    @(posedge clk);
    @(negedge clk);issue_valid=0;ret_valid=0;
    if (!triple_seen) $fatal(1,"C1_STORE_TRIPLE_EDGE");
    return_one(102);
    wait(commits==67);
    repeat(3) @(negedge clk);
    if (result_free_count!==64 || result_reserved_count!==0 ||
        result_returned_count!==0 || trace_free_count!==4)
      $fatal(1,"C1_STORE_FINAL_DRAIN");
    rst_n=0;
    repeat(3) @(negedge clk);
    if (result_free_count!==64 || trace_free_count!==4)
      $fatal(1,"C1_STORE_METADATA_RESET");
    $display("C1_RESERVED_STORE_OBSERVATION_COMPLETE");
    $finish;
  end
endmodule
