`timescale 1ns/1ps

// RUN group ingress, real eight-bank PS feedback, lane-failure suppression,
// production-rank first error and last-group tile retirement. Bias and output
// B retirement consume tile_out downstream; this block never publishes them.
module tm1tn8_ps_controller (
  input  logic          clk,
  input  logic          rst_n,
  input  logic [255:0]  cfg_tdata,
  input  logic          cfg_tvalid,
  output logic          cfg_tready,
  input  logic [2815:0] group_tdata,
  input  logic          group_tvalid,
  output logic          group_tready,
  input  logic          finish_tvalid,
  output logic          finish_tready,
  output logic          compute_done,
  output logic [319:0]  tile_tdata,
  output logic          tile_tvalid,
  input  logic          tile_tready,
  output logic          trace_valid,
  input  logic          trace_ready,
  output logic [1:0]    trace_slot,
  output logic [159:0]  trace_tag,
  output logic [255:0]  trace_payload,
  input  logic          trace_ack_valid,
  input  logic [1:0]    trace_ack_slot,
  input  logic [159:0]  trace_ack_tag,
  input  logic          trace_ack_ok,
  output logic          numerical_error,
  output logic [63:0]   first_error_rank,
  output logic [63:0]   first_bad_element,
  output logic [31:0]   first_error_detail,
  output logic          protocol_error,
  output logic [31:0]   groups_accepted,
  output logic [31:0]   groups_retired,
  output logic [31:0]   groups_processed,
  output logic [63:0]   active_macs,
  output logic [5:0]    result_free,
  output logic [5:0]    result_reserved,
  output logic [5:0]    result_returned,
  output logic [2:0]    trace_free
);
  logic configured, run_mode, finish_seen;
  logic [31:0] K, N, rows, row0, batch, op, task_id;
  logic trace_enabled;
  logic [5:0] G;
  logic [8:0] T;
  logic [1:0] expect_row;
  logic [5:0] expect_group;
  logic [8:0] expect_tile;
  logic [31:0] expected_packets;
  logic [31:0] ps [0:7][0:383];
  logic bad_lane [0:7][0:383];
  logic tile_busy [0:383];
  logic release_valid;
  logic [8:0] release_tile;
  logic [8:0] in_tile;
  logic [5:0] in_group;
  logic [1:0] in_row;
  logic [7:0] in_mask, effective_mask;
  logic input_ok, skip_empty, pipe_issue_ready, pipe_issue_valid;
  logic pipe_commit_valid, pipe_commit_ready;
  logic [159:0] pipe_issue_tag, pipe_commit_tag;
  logic [8:0] pipe_commit_tile;
  logic [7:0] pipe_commit_mask, pipe_commit_bad;
  logic [23:0] pipe_commit_phase;
  logic [255:0] pipe_commit_ps, issue_old_ps;
  logic pipe_error;
  logic [63:0] best_rank;
  logic [63:0] candidate_rank, candidate_bad_element;
  logic [7:0] completed_bad;
  logic last_group_commit;
  logic tile_slot_ready;
  logic protocol_fault;
  function automatic logic [3:0] pop8(input logic [7:0] value);
    logic [3:0] count;
    count=0;
    for (int lane=0; lane<8; lane++) count=count+value[lane];
    return count;
  endfunction

  assign in_tile = group_tdata[2600:2592];
  assign in_group = group_tdata[2606:2601];
  assign in_row = group_tdata[2608:2607];
  assign in_mask = group_tdata[2616:2609];
  always_comb begin
    effective_mask = in_mask;
    if (in_group != 0 && in_tile < T)
      for (int lane=0; lane<8; lane++)
        if (bad_lane[lane][in_tile]) effective_mask[lane] = 0;
    issue_old_ps = 0;
    if (in_group != 0 && in_tile < T)
      for (int lane=0; lane<8; lane++)
        issue_old_ps[lane*32 +: 32] = ps[lane][in_tile];
    pipe_issue_tag = 0;
    pipe_issue_tag[63:36] = groups_processed[27:0];
    pipe_issue_tag[95:64] = group_tdata[2653:2622];
    pipe_issue_tag[127:96] = group_tdata[2685:2654];
    pipe_issue_tag[159:128] = group_tdata[2749:2718];
  end
  always_comb begin
    candidate_rank = best_rank;
    candidate_bad_element = first_bad_element;
    if (pipe_commit_valid)
      for (int lane=0; lane<8; lane++)
        if (pipe_commit_bad[lane]) begin
          logic [63:0] rank;
          rank = (((({55'd0,pipe_commit_tile}*4 +
                     pipe_commit_tag[27:26])*8 + lane)*
                    (G+1) + pipe_commit_tag[16:11])*5 +
                  pipe_commit_phase[lane*3 +: 3]);
          if (rank < candidate_rank) begin
            candidate_rank = rank;
            candidate_bad_element =
                {62'd0,pipe_commit_tag[27:26]}*5248*128 +
                ({55'd0,pipe_commit_tile}*8+lane)*128 +
                pipe_commit_tag[16:11];
          end
        end
  end
  assign input_ok = in_row == expect_row &&
      in_group == expect_group && in_tile == expect_tile &&
      group_tdata[2621] == (in_group == G - 1'b1) &&
      group_tdata[2653:2622] == task_id &&
      in_mask != 0 && in_tile < T &&
      in_group < G && in_row < rows &&
      in_mask == ((in_tile == T - 1) ?
                  8'((1 << (N - in_tile*8)) - 1) : 8'hff);
  assign skip_empty = effective_mask == 0;
  assign cfg_tready = !configured && result_free == 6'd32 &&
                      result_reserved == 0 && result_returned == 0 &&
                      !tile_tvalid;
  assign group_tready = configured && run_mode &&
      (protocol_error || !input_ok || skip_empty ||
       (!tile_busy[in_tile] && pipe_issue_ready));
  assign pipe_issue_valid = group_tvalid && group_tready &&
                            !protocol_error && input_ok && !skip_empty;
  assign finish_tready = configured && !finish_seen;
  assign completed_bad = pipe_commit_bad |
      {bad_lane[7][pipe_commit_tile],bad_lane[6][pipe_commit_tile],
       bad_lane[5][pipe_commit_tile],bad_lane[4][pipe_commit_tile],
       bad_lane[3][pipe_commit_tile],bad_lane[2][pipe_commit_tile],
       bad_lane[1][pipe_commit_tile],bad_lane[0][pipe_commit_tile]};
  assign last_group_commit = pipe_commit_tag[16:11] == G - 1'b1;
  assign tile_slot_ready = !tile_tvalid || tile_tready;
  assign pipe_commit_ready = !last_group_commit || tile_slot_ready ||
                             protocol_error;
  assign compute_done = configured && finish_seen &&
      groups_processed == expected_packets &&
      result_free == 6'd32 && result_reserved == 0 &&
      result_returned == 0 && !tile_tvalid && trace_free == 3'd4 &&
      !trace_valid;

  tm1tn8_arithmetic_pipeline arithmetic (
    .clk(clk), .rst_n(rst_n),
    .issue_valid(pipe_issue_valid), .issue_ready(pipe_issue_ready),
    .issue_identity_tag(pipe_issue_tag), .issue_tile(in_tile),
    .issue_lane_mask(effective_mask),
    .issue_trace(group_tdata[2617]),
    .issue_trace_lane(group_tdata[2620:2618]),
    .issue_group(in_group), .issue_row(in_row),
    .issue_a8(group_tdata[255:0]),
    .issue_w8(group_tdata[2303:256]),
    .issue_old_ps(issue_old_ps),
    .issue_sa(group_tdata[2335:2304]),
    .issue_sw(group_tdata[2591:2336]),
    .commit_valid(pipe_commit_valid),
    .commit_ready(pipe_commit_ready),
    .commit_tag(pipe_commit_tag),
    .commit_tile(pipe_commit_tile),
    .commit_lane_mask(pipe_commit_mask),
    .commit_bad_mask(pipe_commit_bad),
    .commit_phase(pipe_commit_phase),
    .commit_next_ps(pipe_commit_ps),
    .trace_valid(trace_valid), .trace_ready(trace_ready),
    .trace_slot(trace_slot), .trace_tag(trace_tag),
    .trace_payload(trace_payload),
    .trace_ack_valid(trace_ack_valid),
    .trace_ack_slot(trace_ack_slot),
    .trace_ack_tag(trace_ack_tag),
    .trace_ack_ok(trace_ack_ok),
    .result_free(result_free),
    .result_reserved(result_reserved),
    .result_returned(result_returned),
    .trace_free(trace_free),
    .protocol_error(pipe_error));
  assign protocol_error = pipe_error || protocol_fault;
  assign first_error_rank = best_rank;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      configured <= 0;
      run_mode <= 0;
      finish_seen <= 0;
      K <= 0; N <= 0; rows <= 0; row0 <= 0;
      batch <= 0; op <= 0; task_id <= 0; trace_enabled <= 0;
      G <= 0; T <= 0;
      expect_row <= 0; expect_group <= 0; expect_tile <= 0;
      expected_packets <= 0;
      groups_accepted <= 0;
      groups_retired <= 0;
      groups_processed <= 0;
      active_macs <= 0;
      numerical_error <= 0;
      first_bad_element <= '1;
      first_error_detail <= 0;
      best_rank <= '1;
      protocol_fault <= 0;
      tile_tvalid <= 0;
      tile_tdata <= 0;
      release_valid <= 0;
      release_tile <= 0;
      for (int tile=0; tile<384; tile++) tile_busy[tile] <= 0;
    end else begin
      // The RAM write happens at commit edge c. Keep the tile busy through
      // c+1 so the next group may issue no earlier than c+2.
      release_valid <= pipe_commit_valid && pipe_commit_ready;
      if (pipe_commit_valid && pipe_commit_ready)
        release_tile <= pipe_commit_tile;
      if (release_valid) tile_busy[release_tile] <= 0;
      if (cfg_tvalid && cfg_tready) begin
        configured <= 1;
        finish_seen <= 0;
        K <= cfg_tdata[31:0];
        N <= cfg_tdata[63:32];
        rows <= cfg_tdata[95:64];
        row0 <= cfg_tdata[127:96];
        batch <= cfg_tdata[159:128];
        op <= cfg_tdata[191:160];
        task_id <= cfg_tdata[223:192];
        trace_enabled <= cfg_tdata[224];
        run_mode <= cfg_tdata[225];
        G <= cfg_tdata[31:0]/32;
        T <= (cfg_tdata[63:32]+7)/8;
        expected_packets <= cfg_tdata[225] ?
            cfg_tdata[95:64] * (cfg_tdata[31:0]/32) *
            ((cfg_tdata[63:32]+7)/8) : 0;
        expect_row <= 0; expect_group <= 0; expect_tile <= 0;
        groups_accepted <= 0;
        groups_retired <= 0;
        groups_processed <= 0;
        active_macs <= 0;
        numerical_error <= 0;
        first_bad_element <= '1;
        first_error_detail <= 0;
        best_rank <= '1;
        protocol_fault <= 0;
        for (int tile=0; tile<384; tile++) tile_busy[tile] <= 0;
        if (cfg_tdata[225] &&
            !((cfg_tdata[31:0]==256 && cfg_tdata[63:32]==2 &&
               cfg_tdata[95:64]==1 && cfg_tdata[191:160]==8'h37) ||
              (cfg_tdata[31:0]==1024 && cfg_tdata[63:32]==3072 &&
               (cfg_tdata[95:64]==1 || cfg_tdata[95:64]==4) &&
               cfg_tdata[191:160]==8'h30)))
          protocol_fault <= 1;
      end
      if (group_tvalid && group_tready) begin
        groups_processed <= groups_processed + 1;
        if (!input_ok) protocol_fault <= 1;
        if (!protocol_error && input_ok && !skip_empty)
          groups_accepted <= groups_accepted + 1;
        if (!protocol_error && input_ok && !skip_empty)
          tile_busy[in_tile] <= 1;
        if (!protocol_error && input_ok && in_group == 0)
          for (int lane=0; lane<8; lane++)
            bad_lane[lane][in_tile] <= 0;
        if (expect_tile + 1 == T) begin
          expect_tile <= 0;
          if (expect_group + 1 == G) begin
            expect_group <= 0;
            expect_row <= expect_row + 1'b1;
          end else expect_group <= expect_group + 1'b1;
        end else expect_tile <= expect_tile + 1'b1;
      end
      if (finish_tvalid && finish_tready) finish_seen <= 1;
      if (pipe_commit_valid && pipe_commit_ready) begin
        groups_retired <= groups_retired + 1;
        active_macs <= active_macs + 64'(pop8(pipe_commit_mask))*32;
        if (candidate_rank < best_rank) begin
          best_rank <= candidate_rank;
          numerical_error <= 1;
          first_bad_element <= candidate_bad_element;
          first_error_detail <= {8'd7,op[7:0],16'd15};
        end
        for (int lane=0; lane<8; lane++) begin
          if (pipe_commit_tag[16:11] == 0)
            bad_lane[lane][pipe_commit_tile] <= pipe_commit_bad[lane];
          else if (pipe_commit_bad[lane])
            bad_lane[lane][pipe_commit_tile] <= 1;
          if (pipe_commit_mask[lane]) begin
            if (!pipe_commit_bad[lane])
              ps[lane][pipe_commit_tile] <=
                  pipe_commit_ps[lane*32 +: 32];
          end
        end
        if (last_group_commit && !protocol_error) begin
          tile_tvalid <= 1;
          tile_tdata[255:0] <= pipe_commit_ps;
          tile_tdata[264:256] <= pipe_commit_tile;
          tile_tdata[266:265] <= pipe_commit_tag[27:26];
          tile_tdata[274:267] <= pipe_commit_mask;
          tile_tdata[282:275] <= completed_bad;
          tile_tdata[319:283] <= 0;
        end
      end
      if (tile_tvalid && tile_tready &&
          !(pipe_commit_valid && pipe_commit_ready &&
            last_group_commit && !protocol_error))
        tile_tvalid <= 0;
      if (compute_done) configured <= 0;
    end
  end
endmodule
