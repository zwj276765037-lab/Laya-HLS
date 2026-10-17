`timescale 1ns/1ps

// Fixed-return reservation for one eight-lane group per issue. Result Q=35
// and selected-group trace D=4 are separate physical credits. A return has
// no ready signal: the issuer must obtain both credits before arithmetic
// accepts a request. Payload RAM is deliberately not reset.
module tm4tn8_reserved_store_v1 #(
  parameter int TAG_W = 192
) (
  input  logic                 clk,
  input  logic                 rst_n,
  input  logic                 issue_valid,
  output logic                 issue_ready,
  output logic                 arithmetic_issue_valid,
  input  logic                 arithmetic_issue_ready,
  input  logic [TAG_W-1:0]     issue_tag,
  input  logic [9:0]           issue_tile,
  input  logic [7:0]           issue_lane_mask,
  input  logic                 issue_trace,
  input  logic [2:0]           issue_trace_lane,
  output logic [5:0]           issue_result_slot,
  output logic [1:0]           issue_trace_slot,
  input  logic                 ret_valid,
  input  logic [5:0]           ret_result_slot,
  input  logic [1:0]           ret_trace_slot,
  input  logic [TAG_W-1:0]     ret_tag,
  input  logic [9:0]           ret_tile,
  input  logic [7:0]           ret_lane_mask,
  input  logic [7:0]           ret_bad_mask,
  input  logic [23:0]          ret_phase,
  input  logic                 ret_trace,
  input  logic [255:0]         ret_next_ps,
  input  logic [255:0]         ret_trace_payload,
  output logic                 commit_valid,
  input  logic                 commit_ready,
  output logic [5:0]           commit_slot,
  output logic [TAG_W-1:0]     commit_tag,
  output logic [9:0]           commit_tile,
  output logic [7:0]           commit_lane_mask,
  output logic [7:0]           commit_bad_mask,
  output logic [23:0]          commit_phase,
  output logic [255:0]         commit_next_ps,
  output logic                 trace_valid,
  input  logic                 trace_ready,
  output logic [1:0]           trace_slot,
  output logic [TAG_W-1:0]     trace_tag,
  output logic [255:0]         trace_payload,
  input  logic                 trace_ack_valid,
  input  logic [1:0]           trace_ack_slot,
  input  logic [TAG_W-1:0]     trace_ack_tag,
  input  logic                 trace_ack_ok,
  output logic [5:0]           result_free,
  output logic [5:0]           result_reserved,
  output logic [5:0]           result_returned,
  output logic [2:0]           trace_free,
  output logic                 protocol_error
);
  localparam logic [1:0] RF=2'd0, RR=2'd1, RD=2'd2;
  localparam logic [1:0] TF=2'd0, TR=2'd1, TY=2'd2, TW=2'd3;
  logic [1:0] result_state [0:34];
  logic [TAG_W-1:0] owner_tag [0:34];
  logic [9:0] owner_tile [0:34];
  logic [7:0] owner_mask [0:34];
  logic owner_trace [0:34];
  logic [1:0] owner_trace_slot [0:34];
  logic [255:0] result_ps [0:34];
  logic [7:0] result_bad [0:34];
  logic [23:0] result_phase [0:34];
  logic [1:0] trace_state [0:3];
  logic [TAG_W-1:0] trace_owner_tag [0:3];
  logic [255:0] trace_data [0:3];
  logic [5:0] issue_head, commit_head;
  logic [1:0] trace_issue_head, trace_drain_head;
  logic busy [0:655];
  logic just_valid, prior_valid;
  logic [9:0] just_tile, prior_tile;
  logic credit_ready, issue_fire, ret_ok, ret_fire;
  logic commit_fire, trace_fire, ack_ok, ack_fire;
  logic [5:0] next_commit_head;

  assign issue_result_slot = issue_head;
  assign issue_trace_slot = issue_trace ? trace_issue_head : 2'd0;
  assign credit_ready = !protocol_error && issue_tile < 10'd656 &&
      issue_lane_mask != 0 && result_free != 0 &&
      result_state[issue_head] == RF && !busy[issue_tile] &&
      !(just_valid && just_tile == issue_tile) &&
      !(prior_valid && prior_tile == issue_tile) &&
      (!issue_trace || (issue_lane_mask[issue_trace_lane] &&
                        trace_free != 0 &&
                        trace_state[trace_issue_head] == TF));
  assign arithmetic_issue_valid = issue_valid && credit_ready;
  assign issue_ready = credit_ready && arithmetic_issue_ready;
  assign issue_fire = issue_valid && issue_ready;
  always_comb begin
    ret_ok = 0;
    if (ret_result_slot < 6'd35)
      ret_ok = result_state[ret_result_slot] == RR &&
          owner_tag[ret_result_slot] == ret_tag &&
          owner_tile[ret_result_slot] == ret_tile &&
          owner_mask[ret_result_slot] == ret_lane_mask &&
          owner_trace[ret_result_slot] == ret_trace &&
          owner_trace_slot[ret_result_slot] == ret_trace_slot &&
          (ret_bad_mask & ~ret_lane_mask) == 0 &&
          (!ret_trace ||
           (trace_state[ret_trace_slot] == TR &&
            trace_owner_tag[ret_trace_slot] == ret_tag));
  end
  assign ret_fire = ret_valid && ret_ok;
  assign commit_fire = commit_valid && commit_ready;
  assign next_commit_head = commit_fire ?
      (commit_head == 6'd34 ? 6'd0 : commit_head + 6'd1) : commit_head;
  assign trace_fire = trace_valid && trace_ready;
  assign ack_ok = trace_state[trace_ack_slot] == TW &&
                  trace_ack_slot == trace_drain_head &&
                  trace_owner_tag[trace_ack_slot] == trace_ack_tag;
  assign ack_fire = trace_ack_valid && ack_ok;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      issue_head <= 0;
      commit_head <= 0;
      trace_issue_head <= 0;
      trace_drain_head <= 0;
      result_free <= 6'd35;
      result_reserved <= 0;
      result_returned <= 0;
      trace_free <= 3'd4;
      commit_valid <= 0;
      trace_valid <= 0;
      protocol_error <= 0;
      just_valid <= 0;
      prior_valid <= 0;
      for (int i=0; i<35; i++) result_state[i] <= RF;
      for (int i=0; i<4; i++) trace_state[i] <= TF;
      for (int i=0; i<656; i++) busy[i] <= 0;
    end else begin
      if (ret_valid && !ret_ok) protocol_error <= 1;
      if (trace_ack_valid && (!ack_ok || !trace_ack_ok))
        protocol_error <= 1;
      if (issue_fire) begin
        result_state[issue_head] <= RR;
        owner_tag[issue_head] <= issue_tag;
        owner_tile[issue_head] <= issue_tile;
        owner_mask[issue_head] <= issue_lane_mask;
        owner_trace[issue_head] <= issue_trace;
        owner_trace_slot[issue_head] <= issue_trace_slot;
        issue_head <= issue_head == 6'd34 ? 6'd0 : issue_head + 6'd1;
        busy[issue_tile] <= 1;
        if (issue_trace) begin
          trace_state[trace_issue_head] <= TR;
          trace_owner_tag[trace_issue_head] <= issue_tag;
          trace_issue_head <= trace_issue_head + 2'd1;
        end
      end
      if (ret_fire) begin
        result_ps[ret_result_slot] <= ret_next_ps;
        result_bad[ret_result_slot] <= ret_bad_mask;
        result_phase[ret_result_slot] <= ret_phase;
        result_state[ret_result_slot] <= RD;
        if (ret_trace) trace_data[ret_trace_slot] <= ret_trace_payload;
      end
      if (commit_fire) begin
        result_state[commit_slot] <= RF;
        commit_head <= commit_head == 6'd34 ? 6'd0 : commit_head + 6'd1;
        busy[commit_tile] <= 0;
        if (owner_trace[commit_slot])
          trace_state[owner_trace_slot[commit_slot]] <= TY;
      end
      if (!commit_valid || commit_fire) begin
        if (result_state[next_commit_head] == RD) begin
          commit_slot <= next_commit_head;
          commit_tag <= owner_tag[next_commit_head];
          commit_tile <= owner_tile[next_commit_head];
          commit_lane_mask <= owner_mask[next_commit_head];
          commit_bad_mask <= result_bad[next_commit_head];
          commit_phase <= result_phase[next_commit_head];
          commit_next_ps <= result_ps[next_commit_head];
          commit_valid <= 1;
        end else commit_valid <= 0;
      end
      result_free <= result_free +
          (commit_fire ? 6'd1 : 6'd0) - (issue_fire ? 6'd1 : 6'd0);
      result_reserved <= result_reserved +
          (issue_fire ? 6'd1 : 6'd0) - (ret_fire ? 6'd1 : 6'd0);
      result_returned <= result_returned +
          (ret_fire ? 6'd1 : 6'd0) - (commit_fire ? 6'd1 : 6'd0);
      prior_valid <= just_valid;
      if (just_valid) prior_tile <= just_tile;
      just_valid <= commit_fire;
      if (commit_fire) just_tile <= commit_tile;
      if (trace_fire) begin
        trace_state[trace_slot] <= TW;
        trace_valid <= 0;
      end
      if (!trace_valid && trace_state[trace_drain_head] == TY) begin
        trace_slot <= trace_drain_head;
        trace_tag <= trace_owner_tag[trace_drain_head];
        trace_payload <= trace_data[trace_drain_head];
        trace_valid <= 1;
      end
      if (ack_fire) begin
        trace_state[trace_drain_head] <= TF;
        trace_drain_head <= trace_drain_head + 2'd1;
      end
      trace_free <= trace_free +
          (ack_fire ? 3'd1 : 3'd0) -
          ((issue_fire && issue_trace) ? 3'd1 : 3'd0);
    end
  end
endmodule
