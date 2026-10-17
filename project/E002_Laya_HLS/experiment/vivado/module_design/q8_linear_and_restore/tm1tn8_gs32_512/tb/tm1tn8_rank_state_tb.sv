`timescale 1ns/1ps

// Error-injection unit test: arithmetic results are synthetic; ranking and
// retained error state are the real PS/bias RTL under test.
package tm1tn8_rank_stim;
  logic valid;
  logic [159:0] tag;
  logic [8:0] tile;
  logic [7:0] mask, bad;
  logic [23:0] phase;
endpackage

module tm1tn8_arithmetic_pipeline (
  input logic clk, rst_n, issue_valid,
  output logic issue_ready,
  input logic [159:0] issue_identity_tag,
  input logic [8:0] issue_tile,
  input logic [7:0] issue_lane_mask,
  input logic issue_trace,
  input logic [2:0] issue_trace_lane,
  input logic [5:0] issue_group,
  input logic [1:0] issue_row,
  input logic [255:0] issue_a8,
  input logic [2047:0] issue_w8,
  input logic [255:0] issue_old_ps,
  input logic [31:0] issue_sa,
  input logic [255:0] issue_sw,
  output logic commit_valid,
  input logic commit_ready,
  output logic [159:0] commit_tag,
  output logic [8:0] commit_tile,
  output logic [7:0] commit_lane_mask, commit_bad_mask,
  output logic [23:0] commit_phase,
  output logic [255:0] commit_next_ps,
  output logic trace_valid,
  input logic trace_ready,
  output logic [1:0] trace_slot,
  output logic [159:0] trace_tag,
  output logic [255:0] trace_payload,
  input logic trace_ack_valid,
  input logic [1:0] trace_ack_slot,
  input logic [159:0] trace_ack_tag,
  input logic trace_ack_ok,
  output logic [5:0] result_free, result_reserved, result_returned,
  output logic [2:0] trace_free,
  output logic protocol_error
);
  assign issue_ready = 1'b1;
  assign commit_valid = tm1tn8_rank_stim::valid;
  assign commit_tag = tm1tn8_rank_stim::tag;
  assign commit_tile = tm1tn8_rank_stim::tile;
  assign commit_lane_mask = tm1tn8_rank_stim::mask;
  assign commit_bad_mask = tm1tn8_rank_stim::bad;
  assign commit_phase = tm1tn8_rank_stim::phase;
  assign commit_next_ps = '0;
  assign trace_valid = 1'b0;
  assign trace_slot = '0;
  assign trace_tag = '0;
  assign trace_payload = '0;
  assign result_free = 6'd32;
  assign result_reserved = '0;
  assign result_returned = '0;
  assign trace_free = 3'd4;
  assign protocol_error = 1'b0;
endmodule

module tm1tn8_fadd_ip (
  input logic aclk, aclken,
  input logic s_axis_a_tvalid,
  input logic [31:0] s_axis_a_tdata,
  input logic s_axis_b_tvalid,
  input logic [31:0] s_axis_b_tdata,
  output logic m_axis_result_tvalid,
  output logic [31:0] m_axis_result_tdata
);
  assign m_axis_result_tvalid = 1'b0;
  assign m_axis_result_tdata = '0;
endmodule

module tm1tn8_rank_state_tb;
  import tm1tn8_rank_stim::*;
  logic clk=0, rst_n=0, cfg_valid=0;
  logic [255:0] cfg='0;
  logic [63:0] ps_rank,ps_bad,bias_rank,bias_bad;
  logic ps_error,ps_protocol,bias_error,bias_protocol;
  logic [8:0] b_tile;
  logic [1:0] b_row;
  logic [7:0] b_mask,b_bad,b_held;
  logic b_valid;
  logic [511:0] join_completion;

  always #5 clk=~clk;
  initial begin
    #100000;
    $fatal(1,"rank-state unit watchdog");
  end
  tm1tn8_ps_controller ps (
    .clk(clk),.rst_n(rst_n),.cfg_tdata(cfg),.cfg_tvalid(cfg_valid),
    .group_tdata('0),.group_tvalid(1'b0),.finish_tvalid(1'b0),
    .tile_tready(1'b1),.trace_ready(1'b1),
    .trace_ack_valid(1'b0),.trace_ack_slot('0),
    .trace_ack_tag('0),.trace_ack_ok(1'b0),
    .numerical_error(ps_error),.first_error_rank(ps_rank),
    .first_bad_element(ps_bad),.protocol_error(ps_protocol));
  tm1tn8_bias_output bias (
    .clk(clk),.rst_n(rst_n),.cfg_tdata(cfg),.cfg_tvalid(cfg_valid),
    .bias_tdata('0),.bias_tvalid(1'b0),
    .tile_tdata('0),.tile_tvalid(1'b0),
    .out0_tready(1'b1),.out1_tready(1'b1),.command_done(1'b0),
    .numerical_error(bias_error),.first_error_rank(bias_rank),
    .first_bad_element(bias_bad),.protocol_error(bias_protocol));
  tm1tn8_joint_bridge joinmux (
    .clk(clk),.rst_n(rst_n),.cfg_tdata('0),.cfg_tvalid(1'b0),
    .compute_cfg_tdata('0),.compute_cfg_tvalid(1'b0),
    .bias_tdata('0),.bias_tvalid(1'b0),
    .group_tdata('0),.group_tvalid(1'b0),.finish_tvalid(1'b0),
    .completion_tdata(join_completion),.completion_tready(1'b0),
    .observed_base('0),.observed_span('0),.trace_command_start(1'b0),
    .observed_awready(1'b0),.observed_wready(1'b0),
    .observed_bresp('0),.observed_bvalid(1'b0),
    .m0_awready(1'b0),.m0_wready(1'b0),.m0_bresp('0),.m0_bvalid(1'b0),
    .m1_awready(1'b0),.m1_wready(1'b0),.m1_bresp('0),.m1_bvalid(1'b0));

  function automatic logic [63:0] old_bad(input int row,tile,lane,g);
    return 64'(row)*5248*128 + 64'(tile*8+lane)*128 + 64'(g);
  endfunction
  function automatic logic [63:0] old_rank(input int tile,row,lane,g,phase);
    return (((64'(tile)*4+64'(row))*8+64'(lane))*33+64'(g))*5+64'(phase);
  endfunction
  function automatic logic [63:0] key(input int tile,row,lane,g,phase);
    return (64'(tile)<<14)|(64'(row)<<12)|(64'(lane)<<9)|
           (64'(g)<<3)|64'(phase);
  endfunction
  task automatic check_ps(input logic [63:0] rank,bad_element);
    if (!ps_error || ps_protocol || ps_rank!==rank || ps_bad!==bad_element)
      $fatal(1,"PS rank state got=%h/%h error=%b proto=%b exp=%h/%h",
             ps_rank,ps_bad,ps_error,ps_protocol,rank,bad_element);
  endtask
  task automatic check_bias(input logic [63:0] rank,bad_element);
    if (!bias_error || bias_protocol || bias_rank!==rank || bias_bad!==bad_element)
      $fatal(1,"bias rank state got=%h/%h error=%b proto=%b exp=%h/%h",
             bias_rank,bias_bad,bias_error,bias_protocol,rank,bad_element);
  endtask
  task automatic ps_event(input int tile,row,g,input logic [7:0] bad,
                          input logic [23:0] phase);
    @(negedge clk);
    tm1tn8_rank_stim::tag='0;
    tm1tn8_rank_stim::tag[27:26]=2'(row);
    tm1tn8_rank_stim::tag[16:11]=6'(g);
    tm1tn8_rank_stim::tile=9'(tile);
    tm1tn8_rank_stim::mask=8'hff;
    tm1tn8_rank_stim::bad=bad;
    tm1tn8_rank_stim::phase=phase;
    tm1tn8_rank_stim::valid=1;
    @(posedge clk); #1;
    tm1tn8_rank_stim::valid=0;
  endtask
  task automatic bias_event(input int tile,row,input logic [7:0] bad,
                            input logic [7:0] held);
    @(negedge clk);
    b_tile=9'(tile);b_row=2'(row);b_mask=8'hff;
    b_bad=bad;b_held=held;b_valid=1;
    force bias.final_tile=b_tile;
    force bias.final_row=b_row;
    force bias.final_mask=b_mask;
    force bias.final_bad=b_bad;
    force bias.held_bad=b_held;
    force bias.final_valid=b_valid;
    @(posedge clk); #1;
    release bias.final_valid;
    release bias.final_tile;
    release bias.final_row;
    release bias.final_mask;
    release bias.final_bad;
    release bias.held_bad;
    b_valid=0;
  endtask

  initial begin
    tm1tn8_rank_stim::valid=0;
    tm1tn8_rank_stim::tag=0;
    tm1tn8_rank_stim::tile=0;
    tm1tn8_rank_stim::mask=0;
    tm1tn8_rank_stim::bad=0;
    tm1tn8_rank_stim::phase=0;
    repeat(3) @(negedge clk);
    rst_n=1;
    if (ps_rank!==64'hffff_ffff_ffff_ffff ||
        ps_bad!==64'hffff_ffff_ffff_ffff ||
        bias_rank!==64'hffff_ffff_ffff_ffff ||
        bias_bad!==64'hffff_ffff_ffff_ffff)
      $fatal(1,"rank no-error sentinel");
    cfg[31:0]=1024;cfg[63:32]=3072;cfg[95:64]=4;
    cfg[191:160]=8'h30;cfg[225]=1;
    cfg_valid=1;
    @(negedge clk);cfg_valid=0;
    // Hierarchical setup only seeds the bias-kind ROM for injected final events.
    bias.bias_kind[300]=1;
    bias.bias_kind[200]=1;
    // Lanes 4 and 7 fail together; lane 4 wins despite later phase.
    ps_event(300,3,20,8'h90,24'h004000);
    check_ps(key(300,3,4,20,4),old_bad(3,300,4,20));
    if (old_rank(300,3,4,20,4)>=old_rank(300,3,7,20,0))
      $fatal(1,"independent rank ordering fixture invalid");
    ps_event(300,3,20,8'h10,24'h003000);
    check_ps(key(300,3,4,20,3),old_bad(3,300,4,20));
    // A later event with smaller tile outranks earlier completion.
    ps_event(200,3,1,8'h80,24'h000000);
    check_ps(key(200,3,7,1,0),old_bad(3,200,7,1));
    @(negedge clk);ps.first_bad_element=64'h1234;
    ps_event(200,3,1,8'h80,24'h000000);
    check_ps(key(200,3,7,1,0),64'h1234);
    bias_event(300,3,8'h24,8'h00);
    check_bias(key(300,3,2,32,0),old_bad(3,300,2,32));
    // A held PS-failed lane is excluded from the bias candidate mask.
    bias_event(200,1,8'h88,8'h08);
    check_bias(key(200,1,7,32,0),old_bad(1,200,7,32));
    @(negedge clk);bias.first_bad_element=64'h5678;
    bias_event(200,1,8'h80,8'h00);
    check_bias(key(200,1,7,32,0),64'h5678);
    force joinmux.ps_rank=64'h123;
    force joinmux.bias_rank=64'h123;
    force joinmux.ps_bad_element=64'h111;
    force joinmux.bias_bad_element=64'h222;
    force joinmux.ps_detail=32'h0000_000a;
    force joinmux.bias_detail=32'h0000_000b;
    #1;
    if (join_completion[225:162]!==64'h111 ||
        join_completion[161:130]!==32'h0000_000a)
      $fatal(1,"joint rank tie must retain PS");
    release joinmux.bias_rank;
    force joinmux.bias_rank=64'h122;
    #1;
    if (join_completion[225:162]!==64'h222 ||
        join_completion[161:130]!==32'h0000_000b)
      $fatal(1,"joint lower bias rank must win");
    $display("TM1TN8_RANK_STATE_PASS ps=4 bias=3 sentinel=1 lower_rank=2 tie=3");
    $finish;
  end
endmodule
