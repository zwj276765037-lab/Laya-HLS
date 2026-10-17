`timescale 1ns/1ps
// Source-only Q64/D4 owner. There is deliberately no arithmetic return ready.
// Reset is permitted only after arithmetic, results, traces, and writers drain.
// Numeric payload RAMs are not reset.
module c1_reserved_store (
  input logic clk, rst_n,
  input logic issue_valid, arithmetic_issue_ready,
  output logic issue_ready, arithmetic_issue_valid,
  input logic [16:0] issue_seq,
  input logic [3:0] issue_m0,
  input logic [6:0] issue_g,
  input logic [9:0] issue_tile,
  input logic issue_last_g,
  input logic [31:0] issue_shape_mask,
  input logic issue_trace_reserved,
  input logic [4:0] issue_trace_lane,
  output logic [5:0] issue_result_slot,
  output logic [1:0] issue_trace_slot,
  input logic ret_valid,
  input logic [16:0] ret_seq,
  input logic [3:0] ret_m0,
  input logic [6:0] ret_g,
  input logic [9:0] ret_tile,
  input logic ret_last_g,
  input logic [5:0] ret_result_slot,
  input logic ret_trace_reserved,
  input logic [1:0] ret_trace_slot,
  input logic [4:0] ret_trace_lane,
  input logic [31:0] ret_shape_mask, ret_bad_mask,
  input logic [1298:0] ret_result_payload,
  input logic [255:0] ret_trace_payload,
  output logic return_written,
  output logic [5:0] return_written_slot,
  output logic commit_valid,
  input logic commit_ready,
  output logic [5:0] commit_slot,
  output logic [1298:0] commit_payload,
  output logic trace_send_valid,
  input logic trace_send_ready,
  input logic [31:0] trace_command_seq,
  output logic [1:0] trace_send_slot,
  output logic [16:0] trace_send_seq,
  output logic [255:0] trace_send_payload,
  input logic trace_ack_valid,
  input logic [2:0] trace_ack_kind,
  input logic [1:0] trace_ack_slot,
  input logic [31:0] trace_ack_seq,
  output logic [6:0] result_free_count, result_reserved_count,
                     result_returned_count,
  output logic [2:0] trace_free_count,
  output logic protocol_error
);
  localparam logic [1:0] RF=2'd0, RR=2'd1, RD=2'd2;
  localparam logic [2:0] TF=3'd0, TR=3'd1, TY=3'd2,
                         TS=3'd3, TC=3'd4;
  localparam logic [2:0] GROUP_TRACE=3'd2;
  logic [1298:0] result_payload [0:63];
  logic [1:0] result_state [0:63];
  logic [16:0] owner_seq [0:63];
  logic [3:0] owner_m0 [0:63];
  logic [6:0] owner_g [0:63];
  logic [9:0] owner_tile [0:63];
  logic owner_last_g [0:63], owner_trace_reserved [0:63];
  logic [31:0] owner_shape [0:63];
  logic [1:0] owner_trace_slot [0:63];
  logic [4:0] owner_trace_lane [0:63];
  logic [5:0] result_issue_head, result_commit_head;
  logic [255:0] trace_payload [0:3];
  logic [2:0] trace_state [0:3];
  logic [16:0] trace_seq [0:3];
  logic [31:0] trace_expected_ack_seq [0:3];
  logic [1:0] trace_issue_head, trace_drain_head;
  logic hazard_busy [0:655];
  logic just_valid, prior_valid;
  logic [9:0] just_tile, prior_tile;
  logic credit_ready, issue_fire, ret_ok, ret_fire, commit_ok, commit_fire;
  logic send_fire, ack_ok, ack_fire, cancel_fire, trace_retire;
  logic issue_bad, return_bad, commit_bad, ack_bad;

  function automatic logic [5:0] count32(input logic [31:0] value);
    logic [5:0] count;
    count=0;
    for (int i=0;i<32;i++) count=count+value[i];
    return count;
  endfunction

  assign issue_result_slot=result_issue_head;
  assign issue_trace_slot=issue_trace_reserved ? trace_issue_head : 2'd0;
  assign credit_ready=!protocol_error && issue_tile<10'd656 &&
      result_free_count!=0 && result_state[result_issue_head]==RF &&
      !hazard_busy[issue_tile] &&
      !(just_valid && just_tile==issue_tile) &&
      !(prior_valid && prior_tile==issue_tile) &&
      (!issue_trace_reserved ||
       (issue_shape_mask[issue_trace_lane] &&
        trace_free_count!=0 && trace_state[trace_issue_head]==TF));
  assign arithmetic_issue_valid=issue_valid && credit_ready;
  assign issue_ready=credit_ready && arithmetic_issue_ready;
  assign issue_fire=issue_valid && issue_ready;
  assign issue_bad=issue_valid &&
      (issue_tile>=10'd656 ||
       (issue_trace_reserved && !issue_shape_mask[issue_trace_lane]));

  // Unchanged ResultPayload packing:
  // next 0:1023, shape 1024:1055, active 1056:1087,
  // success 1088:1119, failure 1120:1151, seq 1152:1168,
  // m0 1169:1172, g 1173:1179, tile 1180:1189, last_g 1190,
  // slot 1191:1196, trace_reserved 1197, trace_slot 1198:1199,
  // error_valid 1200, key 1201:1228, bad_element 1229:1292,
  // active_dot_count 1293:1298.
  always_comb begin
    ret_ok=1'b0;
    if (ret_valid && !protocol_error &&
        result_state[ret_result_slot]==RR &&
        owner_seq[ret_result_slot]==ret_seq &&
        owner_m0[ret_result_slot]==ret_m0 &&
        owner_g[ret_result_slot]==ret_g &&
        owner_tile[ret_result_slot]==ret_tile &&
        owner_last_g[ret_result_slot]==ret_last_g &&
        owner_shape[ret_result_slot]==ret_shape_mask &&
        owner_trace_reserved[ret_result_slot]==ret_trace_reserved &&
        owner_trace_slot[ret_result_slot]==ret_trace_slot &&
        owner_trace_lane[ret_result_slot]==ret_trace_lane &&
        ret_result_payload[1055:1024]==ret_shape_mask &&
        ret_result_payload[1087:1056]==(ret_shape_mask & ~ret_bad_mask) &&
        (ret_result_payload[1119:1088] &
         ret_result_payload[1151:1120])==32'd0 &&
        (ret_result_payload[1119:1088] |
         ret_result_payload[1151:1120])==ret_result_payload[1087:1056] &&
        ret_result_payload[1168:1152]==ret_seq &&
        ret_result_payload[1172:1169]==ret_m0 &&
        ret_result_payload[1179:1173]==ret_g &&
        ret_result_payload[1189:1180]==ret_tile &&
        ret_result_payload[1190]==ret_last_g &&
        ret_result_payload[1196:1191]==ret_result_slot &&
        ret_result_payload[1197]==ret_trace_reserved &&
        ret_result_payload[1199:1198]==ret_trace_slot &&
        ret_result_payload[1200]==(|ret_result_payload[1151:1120]) &&
        ret_result_payload[1298:1293]==
            count32(ret_result_payload[1087:1056]) &&
        (!ret_trace_reserved ||
         (trace_state[ret_trace_slot]==TR &&
          trace_seq[ret_trace_slot]==ret_seq)))
      ret_ok=1'b1;
  end
  assign ret_fire=ret_valid && ret_ok;
  assign return_bad=ret_valid && !ret_ok;
  assign commit_ok=!commit_valid || !owner_trace_reserved[commit_slot] ||
      (trace_state[owner_trace_slot[commit_slot]]==TR &&
       trace_seq[owner_trace_slot[commit_slot]]==
           commit_payload[1168:1152]);
  assign commit_fire=commit_valid && commit_ready && commit_ok &&
                     !protocol_error;
  assign commit_bad=commit_valid && commit_ready && !commit_ok;
  assign send_fire=trace_send_valid && trace_send_ready && !protocol_error;
  assign ack_ok=trace_ack_valid && trace_state[trace_drain_head]==TS &&
      trace_ack_kind==GROUP_TRACE &&
      trace_ack_slot==trace_drain_head &&
      trace_ack_seq==trace_expected_ack_seq[trace_drain_head];
  assign ack_fire=trace_ack_valid && ack_ok && !protocol_error;
  assign ack_bad=trace_ack_valid && !ack_ok;
  assign cancel_fire=trace_state[trace_drain_head]==TC &&
                     !trace_ack_valid && !protocol_error;
  assign trace_retire=ack_fire || cancel_fire;

  // Single metadata writer. Return payload writes and registered read outputs
  // use independent RAM roles and are never gated by commit/writer readiness.
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      result_issue_head<=0; result_commit_head<=0;
      result_free_count<=7'd64;
      result_reserved_count<=0; result_returned_count<=0;
      trace_issue_head<=0; trace_drain_head<=0; trace_free_count<=3'd4;
      commit_valid<=0; trace_send_valid<=0;
      return_written<=0; return_written_slot<=0;
      just_valid<=0; prior_valid<=0; protocol_error<=0;
      for (int i=0;i<64;i++) result_state[i]<=RF;
      for (int i=0;i<4;i++) trace_state[i]<=TF;
      for (int i=0;i<656;i++) hazard_busy[i]<=0;
    end else begin
      return_written<=ret_fire;
      if (ret_fire) return_written_slot<=ret_result_slot;
      if (issue_bad || return_bad || commit_bad || ack_bad)
        protocol_error<=1'b1;
`ifndef SYNTHESIS
      if (issue_bad || return_bad || commit_bad || ack_bad)
        $fatal(1,"C1_RESERVED_STORE_PROTOCOL_ERROR");
      if (ret_fire && commit_valid && ret_result_slot==commit_slot)
        $fatal(1,"C1_RESULT_DUAL_PORT_CONFLICT");
      if (ret_fire && ret_trace_reserved && trace_send_valid &&
          ret_trace_slot==trace_send_slot)
        $fatal(1,"C1_TRACE_DUAL_PORT_CONFLICT");
`endif
      if (issue_fire) begin
        result_state[result_issue_head]<=RR;
        owner_seq[result_issue_head]<=issue_seq;
        owner_m0[result_issue_head]<=issue_m0;
        owner_g[result_issue_head]<=issue_g;
        owner_tile[result_issue_head]<=issue_tile;
        owner_last_g[result_issue_head]<=issue_last_g;
        owner_shape[result_issue_head]<=issue_shape_mask;
        owner_trace_reserved[result_issue_head]<=issue_trace_reserved;
        owner_trace_slot[result_issue_head]<=issue_trace_slot;
        owner_trace_lane[result_issue_head]<=issue_trace_lane;
        result_issue_head<=result_issue_head+6'd1;
        hazard_busy[issue_tile]<=1'b1;
        if (issue_trace_reserved) begin
          trace_state[trace_issue_head]<=TR;
          trace_seq[trace_issue_head]<=issue_seq;
          trace_issue_head<=trace_issue_head+2'd1;
        end
      end
      if (ret_fire) begin
        result_payload[ret_result_slot]<=ret_result_payload;
        result_state[ret_result_slot]<=RD;
        if (ret_trace_reserved)
          trace_payload[ret_trace_slot]<=ret_trace_payload;
      end
      // Only a pre-edge RETURNED slot may reach this registered read.
      if (!commit_valid && result_state[result_commit_head]==RD &&
          !protocol_error) begin
        commit_payload<=result_payload[result_commit_head];
        commit_slot<=result_commit_head;
        commit_valid<=1'b1;
      end else if (commit_fire) begin
        commit_valid<=1'b0;
        result_state[result_commit_head]<=RF;
        result_commit_head<=result_commit_head+6'd1;
        hazard_busy[owner_tile[commit_slot]]<=1'b0;
        if (owner_trace_reserved[commit_slot])
          trace_state[owner_trace_slot[commit_slot]]<=
              commit_payload[1088+owner_trace_lane[commit_slot]] ? TY : TC;
      end
      result_free_count<=result_free_count+
          (commit_fire ? 7'd1 : 7'd0)-(issue_fire ? 7'd1 : 7'd0);
      result_reserved_count<=result_reserved_count+
          (issue_fire ? 7'd1 : 7'd0)-(ret_fire ? 7'd1 : 7'd0);
      result_returned_count<=result_returned_count+
          (ret_fire ? 7'd1 : 7'd0)-(commit_fire ? 7'd1 : 7'd0);
      prior_valid<=just_valid;
      if (just_valid) prior_tile<=just_tile;
      just_valid<=commit_fire;
      if (commit_fire) just_tile<=owner_tile[commit_slot];
      // READY-only registered read. SENDING retires on matching B ACK.
      if (!trace_send_valid && trace_state[trace_drain_head]==TY &&
          !protocol_error) begin
        trace_send_payload<=trace_payload[trace_drain_head];
        trace_send_slot<=trace_drain_head;
        trace_send_seq<=trace_seq[trace_drain_head];
        trace_send_valid<=1'b1;
      end else if (send_fire) begin
        trace_send_valid<=1'b0;
        trace_state[trace_drain_head]<=TS;
        trace_expected_ack_seq[trace_drain_head]<=trace_command_seq;
      end
      if (trace_retire) begin
        trace_state[trace_drain_head]<=TF;
        trace_drain_head<=trace_drain_head+2'd1;
      end
      trace_free_count<=trace_free_count+
          (trace_retire ? 3'd1 : 3'd0)-
          ((issue_fire && issue_trace_reserved) ? 3'd1 : 3'd0);
    end
  end
endmodule
