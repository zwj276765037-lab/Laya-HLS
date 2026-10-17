`timescale 1ns/1ps

module tanh_service_tb;
  localparam int N = 2624;
  logic clk=0, rst=1, in_valid=0, out_ready=1;
  wire in_ready, out_valid;
  logic [31:0] in_bits=0, in_tag=0;
  wire [31:0] out_bits, out_tag;
  logic [31:0] z [0:N-1];
  logic [31:0] gold [0:N-1];
  int accept_cycle [0:N-1];
  int complete_cycle [0:N-1];
  int branch [0:N-1];
  int accepts=0, returns=0, cycle=0, active_done=0;
  int branch_count [0:2];
  int gap_count [0:2], gap_min [0:2], gap_max [0:2];
  longint gap_sum [0:2];
  int latency_min [0:2], latency_max [0:2];
  longint latency_sum [0:2];
  int retire_delay_max [0:2];
  bit finite_stall=0;
  string z_file, gold_file;

  always #3.333 clk=~clk;

  tanh_service_wrapper dut (
      .clk(clk), .rst(rst), .in_valid(in_valid), .in_ready(in_ready),
      .in_bits(in_bits), .in_tag(in_tag), .out_valid(out_valid),
      .out_ready(out_ready), .out_bits(out_bits), .out_tag(out_tag)
  );

  initial begin
    if (!$value$plusargs("Z_FILE=%s", z_file) ||
        !$value$plusargs("GOLD_FILE=%s", gold_file))
      $fatal(1,"tanh real z/gold paths required");
    finite_stall=$test$plusargs("STALL");
    $readmemh(z_file,z);
    $readmemh(gold_file,gold);
    for (int b=0;b<3;b++) begin
      branch_count[b]=0; gap_count[b]=0; gap_sum[b]=0;
      gap_min[b]=2147483647; gap_max[b]=0;
      latency_min[b]=2147483647; latency_max[b]=0; latency_sum[b]=0;
      retire_delay_max[b]=0;
    end
    repeat (8) @(negedge clk);
    rst=0;
    wait (returns==N);
    #1ps;
    if (accepts!=N || active_done!=N || out_valid)
      $fatal(1,"tanh endpoint debt accepts=%0d returns=%0d active_done=%0d",
             accepts,returns,active_done);
    for (int b=0;b<3;b++)
      $display("TANH_SERVICE_BRANCH branch=%0d count=%0d gap_count=%0d gap_min=%0d gap_max=%0d gap_sum=%0d latency_min=%0d latency_max=%0d latency_sum=%0d retire_delay_max=%0d",
               b,branch_count[b],gap_count[b],gap_min[b],gap_max[b],gap_sum[b],
               latency_min[b],latency_max[b],latency_sum[b],retire_delay_max[b]);
    $display("TANH_SERVICE_RTL_PASS count=%0d first_accept=%0d last_accept=%0d last_return=%0d stall=%0d",
             N,accept_cycle[0],accept_cycle[N-1],cycle,finite_stall);
    $finish;
  end

  always @(negedge clk) begin
    in_valid = !rst && accepts<N;
    if (accepts<N) begin
      in_bits = z[accepts];
      in_tag = accepts;
    end
    out_ready = !finite_stall || cycle<300 || cycle>=304;
  end

  always @(posedge clk) if (!rst) begin
    cycle <= cycle+1;
    if (cycle>1000000) $fatal(1,"tanh 1M-cycle watchdog");
    if (dut.busy && dut.leaf_ready) begin
      if (!dut.leaf_done) $fatal(1,"active ready without done");
      if (dut.active_tag!==active_done || active_done>=N)
        $fatal(1,"tanh completion ordering tag=%0d done=%0d",
               dut.active_tag,active_done);
      complete_cycle[active_done]=cycle;
      active_done <= active_done+1;
    end
    if (in_valid && in_ready) begin
      if (in_tag!==accepts || accepts>=N)
        $fatal(1,"tanh input ordering tag=%0d accepted=%0d",in_tag,accepts);
      accept_cycle[accepts]=cycle;
      if (dut.u_leaf.ap_NS_fsm==dut.u_leaf.ap_ST_fsm_state2) branch[accepts]=0;
      else if (dut.u_leaf.ap_NS_fsm==dut.u_leaf.ap_ST_fsm_state53) branch[accepts]=1;
      else if (dut.u_leaf.ap_NS_fsm==dut.u_leaf.ap_ST_fsm_state59) branch[accepts]=2;
      else $fatal(1,"tanh unknown active branch tag=%0d",accepts);
      branch_count[branch[accepts]]++;
      if (accepts>0) begin
        int prev=branch[accepts-1];
        int gap=cycle-accept_cycle[accepts-1];
        gap_count[prev]++;
        gap_sum[prev]+=gap;
        if (gap<gap_min[prev]) gap_min[prev]=gap;
        if (gap>gap_max[prev]) gap_max[prev]=gap;
        if (gap<3) $fatal(1,"tanh accepted faster than frozen FSM lower bound");
      end
      accepts <= accepts+1;
    end
    if (out_valid && out_ready) begin
      if (out_tag!==returns || returns>=N)
        $fatal(1,"tanh output ordering tag=%0d retired=%0d",out_tag,returns);
      if (out_bits!==gold[returns])
        $fatal(1,"tanh numeric mismatch ordinal=%0d z=%08x got=%08x gold=%08x",
               returns,z[returns],out_bits,gold[returns]);
      begin
        int b=branch[returns];
        int latency=complete_cycle[returns]-accept_cycle[returns];
        int retire_delay=cycle-complete_cycle[returns];
        latency_sum[b]+=latency;
        if (latency<latency_min[b]) latency_min[b]=latency;
        if (latency>latency_max[b]) latency_max[b]=latency;
        if (retire_delay>retire_delay_max[b]) retire_delay_max[b]=retire_delay;
      end
      returns <= returns+1;
    end
  end
endmodule
