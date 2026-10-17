`timescale 1ns/1ps

// Isolated four-row arithmetic/PS replay. Inputs are already quantized;
// model LOAD, FPGA quantization, bias and physical output are outside scope.
module tm4tn8_microbench_v1 #(parameter bit PACKED = 0) (
  input  logic          clk,
  input  logic          rst_n,
  input  logic          config_valid,
  output logic          config_ready,
  input  logic [15:0]   config_k,
  input  logic [15:0]   config_n,
  input  logic [2:0]    config_rows,
  input  logic [15:0]   config_row0,
  input  logic [159:0]  config_identity,
  input  logic          issue_valid,
  output logic          issue_ready,
  input  logic [95:0]   issue_identity,
  input  logic [3:0]    issue_version,
  input  logic [26:0]   issue_sequence,
  input  logic [6:0]    issue_group,
  input  logic [9:0]    issue_tile,
  input  logic [7:0]    issue_lane_mask,
  input  logic [3:0]    issue_trace_mask,
  input  logic [11:0]   issue_trace_lane,
  input  logic [1023:0] issue_a8,
  input  logic [127:0]  issue_sa,
  input  logic [2047:0] issue_w8,
  input  logic [255:0]  issue_sw,
  output logic [3:0]    commit_valid,
  input  logic [3:0]    commit_ready,
  output logic [767:0]  commit_tag,
  output logic [39:0]   commit_tile,
  output logic [31:0]   commit_lane_mask,
  output logic [31:0]   commit_bad_mask,
  output logic [95:0]   commit_phase,
  output logic [1023:0] commit_next_ps,
  output logic [3:0]    trace_valid,
  input  logic [3:0]    trace_ready,
  output logic [7:0]    trace_slot,
  output logic [767:0]  trace_tag,
  output logic [1023:0] trace_payload,
  input  logic [3:0]    trace_ack_valid,
  input  logic [7:0]    trace_ack_slot,
  input  logic [767:0]  trace_ack_tag,
  input  logic [3:0]    trace_ack_ok,
  output logic [23:0]   result_free,
  output logic [23:0]   result_reserved,
  output logic [23:0]   result_returned,
  output logic [11:0]   trace_free,
  output logic          done_valid,
  output logic          done_error,
  output logic          protocol_failure,
  output logic [63:0]   first_error_rank,
  output logic [31:0]   first_bad_element,
  output logic [26:0]   accepted_stripes
);
  typedef enum logic [1:0] {IDLE, RUN, DRAIN, FINISHED} state_t;
  state_t state;
  logic [15:0] K, N, row0;
  logic [6:0] G;
  logic [9:0] T;
  logic [3:0] rowmask;
  logic [159:0] identity;
  logic [6:0] next_group;
  logic [9:0] next_tile;
  logic [31:0] expected_stripes;
  logic [26:0] next_sequence;
  logic numeric_failure;
  logic [3:0] row_ready, row_protocol_error, row_issue_valid;
  logic [7:0] effective_mask [0:3];
  logic [255:0] old_ps [0:3];
  logic [7:0] poison [0:3][0:655];
  logic [6:0] progress [0:3][0:655];
  logic pending [0:3][0:655];
  logic [31:0] ps [0:3][0:7][0:655];
  logic [3:0] row_skip;
  logic structural_valid, tile_in_range, ps_ready, all_rows_ready, all_credits_free;
  logic accepted, rejected;
  logic [63:0] cycle_first_rank;
  logic [31:0] cycle_bad_element;
  logic [159:0] stripe_identity;
  logic [191:0] commit_tag_row [0:3];
  logic [9:0] commit_tile_row [0:3];
  logic [7:0] commit_mask_row [0:3], commit_bad_row [0:3];
  logic [23:0] commit_phase_row [0:3];
  logic [255:0] commit_ps_row [0:3];
  logic [5:0] free_row [0:3], reserved_row [0:3], returned_row [0:3];
  logic [2:0] trace_free_row [0:3];

  always_comb begin
    stripe_identity = identity;
    stripe_identity[62:36] = issue_sequence;
    tile_in_range = issue_tile < 10'd656;
    structural_valid = issue_identity == identity[159:64] &&
        issue_version == 4'd1 && issue_sequence == next_sequence &&
        issue_group < G && tile_in_range && issue_tile < T &&
        issue_group == next_group && issue_tile == next_tile &&
        issue_lane_mask != 0 &&
        ((issue_tile != T-1) ||
         issue_lane_mask == (N[2:0] == 0 ? 8'hff :
                             8'((1 << N[2:0]) - 1))) &&
        ((issue_tile == T-1) || issue_lane_mask == 8'hff) &&
        (issue_trace_mask & ~rowmask) == 0;
    ps_ready = 1;
    all_rows_ready = 1;
    for (int r=0; r<4; r++) begin
      effective_mask[r] = issue_lane_mask;
      if (issue_group != 0 && tile_in_range)
        effective_mask[r] &= ~poison[r][issue_tile];
      row_skip[r] = rowmask[r] && effective_mask[r] == 0;
      if (rowmask[r]) begin
        if (!tile_in_range) ps_ready = 0;
        else if (progress[r][issue_tile] != issue_group ||
                 pending[r][issue_tile]) ps_ready = 0;
        if (!row_skip[r] && !row_ready[r]) all_rows_ready = 0;
        if (issue_trace_mask[r] &&
            (!effective_mask[r][issue_trace_lane[r*3 +: 3]] || row_skip[r]))
          structural_valid = 0;
      end
      old_ps[r] = '0;
      if (issue_group != 0 && tile_in_range)
        for (int lane=0; lane<8; lane++)
          old_ps[r][lane*32 +: 32] = ps[r][lane][issue_tile];
    end
    all_credits_free = 1;
    for (int r=0; r<4; r++)
      if (free_row[r] != 35 || reserved_row[r] != 0 ||
          returned_row[r] != 0 || trace_free_row[r] != 4 ||
          commit_valid[r] || trace_valid[r]) all_credits_free = 0;
  end

  assign config_ready = (state == IDLE || state == FINISHED) &&
                        all_credits_free;
  assign issue_ready = state == RUN &&
                       (!structural_valid || (ps_ready && all_rows_ready));
  assign accepted = issue_valid && issue_ready && structural_valid;
  assign rejected = issue_valid && issue_ready && !structural_valid;
  always_comb begin
    longint unsigned rank_value;
    cycle_first_rank = '1;
    cycle_bad_element = '1;
    rank_value = 0;
    for (int r=0; r<4; r++)
      if (commit_valid[r] && commit_ready[r])
        for (int lane=0; lane<8; lane++)
          if (commit_mask_row[r][lane] && commit_bad_row[r][lane]) begin
            rank_value = (((longint'(commit_tile_row[r])*4+r)*8+lane)*
                         (longint'(G)+1)+
                         longint'({commit_tag_row[r][160],
                                   commit_tag_row[r][16:11]}))*5+
                         longint'(commit_phase_row[r][lane*3 +: 3]);
            if (rank_value < cycle_first_rank) begin
              cycle_first_rank = rank_value;
              cycle_bad_element = 32'(r*5248*128 +
                  (int'(commit_tile_row[r])*8+lane)*128 +
                  int'({commit_tag_row[r][160],commit_tag_row[r][16:11]}));
            end
          end
  end
  for (genvar r=0; r<4; r++) begin : row
    assign row_issue_valid[r] = accepted && rowmask[r] && !row_skip[r];
    assign commit_tag[r*192 +: 192] = commit_tag_row[r];
    assign commit_tile[r*10 +: 10] = commit_tile_row[r];
    assign commit_lane_mask[r*8 +: 8] = commit_mask_row[r];
    assign commit_bad_mask[r*8 +: 8] = commit_bad_row[r];
    assign commit_phase[r*24 +: 24] = commit_phase_row[r];
    assign commit_next_ps[r*256 +: 256] = commit_ps_row[r];
    assign result_free[r*6 +: 6] = free_row[r];
    assign result_reserved[r*6 +: 6] = reserved_row[r];
    assign result_returned[r*6 +: 6] = returned_row[r];
    assign trace_free[r*3 +: 3] = trace_free_row[r];
    tm4tn8_row_pipeline_v1 #(.PACKED(PACKED)) arithmetic (
      .clk, .rst_n, .issue_valid(row_issue_valid[r]),
      .issue_ready(row_ready[r]), .issue_identity_tag({32'd0,stripe_identity}),
      .issue_tile, .issue_lane_mask(effective_mask[r]),
      .issue_trace(issue_trace_mask[r]),
      .issue_trace_lane(issue_trace_lane[r*3 +: 3]),
      .issue_group, .issue_row(2'(r)),
      .issue_a8(issue_a8[r*256 +: 256]), .issue_w8,
      .issue_old_ps(old_ps[r]), .issue_sa(issue_sa[r*32 +: 32]),
      .issue_sw, .commit_valid(commit_valid[r]),
      .commit_ready(commit_ready[r]),
      .commit_tag(commit_tag_row[r]),
      .commit_tile(commit_tile_row[r]),
      .commit_lane_mask(commit_mask_row[r]),
      .commit_bad_mask(commit_bad_row[r]),
      .commit_phase(commit_phase_row[r]),
      .commit_next_ps(commit_ps_row[r]),
      .trace_valid(trace_valid[r]), .trace_ready(trace_ready[r]),
      .trace_slot(trace_slot[r*2 +: 2]),
      .trace_tag(trace_tag[r*192 +: 192]),
      .trace_payload(trace_payload[r*256 +: 256]),
      .trace_ack_valid(trace_ack_valid[r]),
      .trace_ack_slot(trace_ack_slot[r*2 +: 2]),
      .trace_ack_tag(trace_ack_tag[r*192 +: 192]),
      .trace_ack_ok(trace_ack_ok[r]),
      .result_free(free_row[r]),
      .result_reserved(reserved_row[r]),
      .result_returned(returned_row[r]),
      .trace_free(trace_free_row[r]),
      .protocol_error(row_protocol_error[r]));
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      done_valid <= 0;
      done_error <= 0;
      protocol_failure <= 0;
      numeric_failure <= 0;
      first_error_rank <= '1;
      first_bad_element <= '1;
      accepted_stripes <= 0;
      next_sequence <= 0;
      next_group <= 0;
      next_tile <= 0;
      for (int r=0; r<4; r++)
        for (int tile=0; tile<656; tile++) begin
          progress[r][tile] <= 0;
          pending[r][tile] <= 0;
        end
    end else begin
      if (config_valid && config_ready) begin
        if ((config_rows == 1 || config_rows == 4) &&
            config_row0 + config_rows <= 128 &&
            ((config_k == 256 && config_n == 2) ||
             (config_k == 1024 && config_n == 3072) ||
             (config_k == 1024 && config_n == 5248) ||
             (config_k == 2624 && config_n == 1024))) begin
          K <= config_k;
          N <= config_n;
          G <= config_k[15:5];
          T <= (config_n + 16'd7) >> 3;
          row0 <= config_row0;
          rowmask <= config_rows == 1 ? 4'b0001 : 4'b1111;
          identity <= config_identity;
          expected_stripes <= (config_k >> 5) * ((config_n + 7) >> 3);
          accepted_stripes <= 0;
          next_sequence <= 0;
          next_group <= 0;
          next_tile <= 0;
          numeric_failure <= 0;
          protocol_failure <= 0;
          first_error_rank <= '1;
          first_bad_element <= '1;
          done_valid <= 0;
          done_error <= 0;
          state <= RUN;
          for (int r=0; r<4; r++)
            for (int tile=0; tile<656; tile++) begin
              progress[r][tile] <= 0;
              pending[r][tile] <= 0;
            end
        end else begin
          done_valid <= 1;
          done_error <= 1;
          protocol_failure <= 1;
          state <= FINISHED;
        end
      end else begin
        if (rejected || |row_protocol_error) begin
          protocol_failure <= 1;
          state <= DRAIN;
        end
        if (cycle_first_rank < first_error_rank) begin
          first_error_rank <= cycle_first_rank;
          first_bad_element <= cycle_bad_element;
        end
        if (accepted) begin
          accepted_stripes <= accepted_stripes + 27'd1;
          next_sequence <= next_sequence + 27'd1;
          if (next_tile == T-1) begin
            next_tile <= 0;
            next_group <= next_group + 7'd1;
          end else next_tile <= next_tile + 10'd1;
          for (int r=0; r<4; r++) if (rowmask[r]) begin
            if (row_skip[r]) progress[r][issue_tile] <= progress[r][issue_tile] + 7'd1;
            else pending[r][issue_tile] <= 1;
          end
        end
        for (int r=0; r<4; r++) begin
          if (commit_valid[r] && commit_ready[r]) begin
            pending[r][commit_tile_row[r]] <= 0;
            progress[r][commit_tile_row[r]] <= progress[r][commit_tile_row[r]] + 7'd1;
            for (int lane=0; lane<8; lane++)
              if (commit_mask_row[r][lane]) begin
                if (commit_bad_row[r][lane]) begin
                  poison[r][commit_tile_row[r]][lane] <= 1;
                  numeric_failure <= 1;
                end else begin
                  ps[r][lane][commit_tile_row[r]] <=
                      commit_ps_row[r][lane*32 +: 32];
                  if ({commit_tag_row[r][160],commit_tag_row[r][16:11]} == 0)
                    poison[r][commit_tile_row[r]][lane] <= 0;
                end
              end
          end
        end
        if ((state == RUN && accepted_stripes == expected_stripes &&
             all_credits_free) || (state == DRAIN && all_credits_free)) begin
          done_valid <= 1;
          done_error <= protocol_failure || numeric_failure ||
                        |row_protocol_error || rejected;
          state <= FINISHED;
        end
      end
    end
  end
endmodule
