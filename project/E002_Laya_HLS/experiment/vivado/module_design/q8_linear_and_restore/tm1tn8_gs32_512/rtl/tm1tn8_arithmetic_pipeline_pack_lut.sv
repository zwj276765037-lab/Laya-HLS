`timescale 1ns/1ps

// Clocked GS32 arithmetic subsystem. The request is accepted only after
// atomic Q35/D4 reservation; the integer tree has six real register
// boundaries and the eight FP lanes return directly into their reserved slot.
// External commit logic owns PS RAM writes, first-error rank and output order.
module tm1tn8_arithmetic_pipeline_pack_lut (
  input  logic          clk,
  input  logic          rst_n,
  input  logic          issue_valid,
  output logic          issue_ready,
  input  logic [159:0]  issue_identity_tag,
  input  logic [8:0]    issue_tile,
  input  logic [7:0]    issue_lane_mask,
  input  logic          issue_trace,
  input  logic [2:0]    issue_trace_lane,
  input  logic [5:0]    issue_group,
  input  logic [1:0]    issue_row,
  input  logic [255:0]  issue_a8,
  input  logic [2047:0] issue_w8,
  input  logic [255:0]  issue_old_ps,
  input  logic [31:0]   issue_sa,
  input  logic [255:0]  issue_sw,
  output logic          commit_valid,
  input  logic          commit_ready,
  output logic [159:0]  commit_tag,
  output logic [8:0]    commit_tile,
  output logic [7:0]    commit_lane_mask,
  output logic [7:0]    commit_bad_mask,
  output logic [23:0]   commit_phase,
  output logic [255:0]  commit_next_ps,
  output logic          trace_valid,
  input  logic          trace_ready,
  output logic [1:0]    trace_slot,
  output logic [159:0]  trace_tag,
  output logic [255:0]  trace_payload,
  input  logic          trace_ack_valid,
  input  logic [1:0]    trace_ack_slot,
  input  logic [159:0]  trace_ack_tag,
  input  logic          trace_ack_ok,
  output logic [5:0]    result_free,
  output logic [5:0]    result_reserved,
  output logic [5:0]    result_returned,
  output logic [2:0]    trace_free,
  output logic          protocol_error
);
  logic arithmetic_issue_valid, arithmetic_issue_ready;
  logic [5:0] issue_result_slot, commit_slot;
  logic store_issue_ready;
  logic [1:0] issue_trace_slot;
  logic [159:0] tree_req_tag, tree_ret_tag;
  logic [255:0] tree_ret_old_ps;
  logic [167:0] tree_ret_dot;
  logic tree_ret_valid;
  logic [31:0] sa_pipe [0:5];
  logic [255:0] sw_pipe [0:5];
  logic fp_ret_valid, fp_protocol_error, store_protocol_error;
  logic [159:0] fp_ret_tag;
  logic [8:0] fp_ret_tile;
  logic [7:0] fp_ret_mask, fp_ret_bad;
  logic [23:0] fp_ret_phase;
  logic [255:0] fp_ret_next, fp_ret_trace;
  logic fp_ret_traced;
  logic [1:0] fp_ret_trace_slot;

  always_comb begin
    tree_req_tag = issue_identity_tag;
    tree_req_tag[4:0] = issue_result_slot[4:0];
    tree_req_tag[63] = issue_result_slot[5];
    tree_req_tag[6:5] = issue_trace_slot;
    tree_req_tag[7] = issue_trace;
    tree_req_tag[10:8] = issue_trace_lane;
    tree_req_tag[16:11] = issue_group;
    tree_req_tag[25:17] = issue_tile;
    tree_req_tag[27:26] = issue_row;
    tree_req_tag[35:28] = issue_lane_mask;
  end
  assign protocol_error = fp_protocol_error || store_protocol_error;
  assign issue_ready = !fp_protocol_error && store_issue_ready;
  tm1tn8_reserved_store store (
    .clk(clk), .rst_n(rst_n),
    .issue_valid(issue_valid && !fp_protocol_error),
    .issue_ready(store_issue_ready),
    .arithmetic_issue_valid(arithmetic_issue_valid),
    .arithmetic_issue_ready(arithmetic_issue_ready),
    .issue_tag(tree_req_tag), .issue_tile(issue_tile),
    .issue_lane_mask(issue_lane_mask), .issue_trace(issue_trace),
    .issue_trace_lane(issue_trace_lane),
    .issue_result_slot(issue_result_slot),
    .issue_trace_slot(issue_trace_slot),
    .ret_valid(fp_ret_valid),
    .ret_result_slot({fp_ret_tag[63],fp_ret_tag[4:0]}),
    .ret_trace_slot(fp_ret_trace_slot), .ret_tag(fp_ret_tag),
    .ret_tile(fp_ret_tile), .ret_lane_mask(fp_ret_mask),
    .ret_bad_mask(fp_ret_bad), .ret_phase(fp_ret_phase),
    .ret_trace(fp_ret_traced), .ret_next_ps(fp_ret_next),
    .ret_trace_payload(fp_ret_trace),
    .commit_valid(commit_valid), .commit_ready(commit_ready),
    .commit_slot(commit_slot), .commit_tag(commit_tag),
    .commit_tile(commit_tile), .commit_lane_mask(commit_lane_mask),
    .commit_bad_mask(commit_bad_mask), .commit_phase(commit_phase),
    .commit_next_ps(commit_next_ps),
    .trace_valid(trace_valid), .trace_ready(trace_ready),
    .trace_slot(trace_slot), .trace_tag(trace_tag),
    .trace_payload(trace_payload),
    .trace_ack_valid(trace_ack_valid), .trace_ack_slot(trace_ack_slot),
    .trace_ack_tag(trace_ack_tag), .trace_ack_ok(trace_ack_ok),
    .result_free(result_free), .result_reserved(result_reserved),
    .result_returned(result_returned), .trace_free(trace_free),
    .protocol_error(store_protocol_error));
  tm1tn8_integer_tree_pack_lut #(.TAG_W(160)) integer_tree (
    .clk(clk), .rst_n(rst_n), .req_valid(arithmetic_issue_valid),
    .req_ready(arithmetic_issue_ready), .req_tag(tree_req_tag),
    .req_old_ps(issue_old_ps), .req_a(issue_a8), .req_w(issue_w8),
    .ret_valid(tree_ret_valid), .ret_tag(tree_ret_tag),
    .ret_old_ps(tree_ret_old_ps), .ret_dot21(tree_ret_dot));
  always_ff @(posedge clk) begin
    if (arithmetic_issue_valid && arithmetic_issue_ready) begin
      sa_pipe[0] <= issue_sa;
      sw_pipe[0] <= issue_sw;
    end
    for (int stage=1; stage<6; stage++) begin
      sa_pipe[stage] <= sa_pipe[stage-1];
      sw_pipe[stage] <= sw_pipe[stage-1];
    end
  end
  tm1tn8_fp_restore fp_restore (
    .clk(clk), .rst_n(rst_n), .in_valid(tree_ret_valid),
    .in_tag(tree_ret_tag), .in_dot21(tree_ret_dot),
    .in_old_ps(tree_ret_old_ps), .in_sa(sa_pipe[5]),
    .in_sw(sw_pipe[5]), .out_valid(fp_ret_valid),
    .out_tag(fp_ret_tag), .out_tile(fp_ret_tile),
    .out_lane_mask(fp_ret_mask), .out_bad_mask(fp_ret_bad),
    .out_phase(fp_ret_phase), .out_next_ps(fp_ret_next),
    .out_trace(fp_ret_traced), .out_trace_slot(fp_ret_trace_slot),
    .out_trace_payload(fp_ret_trace),
    .protocol_error(fp_protocol_error));
endmodule
