// Four-row diagnostic ADD_RESIDUAL producer.  The two source AXI ports read
// distinct declared BO regions; only a successful final write response makes
// the new HIDDEN window locally visible.  This is not a production hub grant.
module laya_ffn0_residual_four_row_v1 (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         cfg_valid,
    output logic         cfg_ready,
    input  logic [31:0]  cfg_request,
    input  logic [31:0]  cfg_generation,
    input  logic [7:0]   cfg_op,
    input  logic [7:0]   cfg_stage,
    input  logic [7:0]   cfg_layer,
    input  logic [7:0]   cfg_batch,
    input  logic [7:0]   cfg_row,
    input  logic [7:0]   cfg_rows,
    input  logic [15:0]  cfg_length,
    input  logic [15:0]  cfg_bias_id,
    input  logic [127:0] cfg_model_tag,
    input  logic [127:0] cfg_numeric_tag,
    input  logic [127:0] cfg_layout_tag,
    input  logic [127:0] cfg_build_tag,
    input  logic [7:0]   cfg_src0_role,
    input  logic [7:0]   cfg_src0_bank,
    input  logic [31:0]  cfg_src0_epoch,
    input  logic [63:0]  cfg_src0_base,
    input  logic [31:0]  cfg_src0_capacity,
    input  logic [31:0]  cfg_src0_bytes,
    input  logic [7:0]   cfg_src1_role,
    input  logic [7:0]   cfg_src1_bank,
    input  logic [31:0]  cfg_src1_epoch,
    input  logic [63:0]  cfg_src1_base,
    input  logic [31:0]  cfg_src1_capacity,
    input  logic [31:0]  cfg_src1_bytes,
    input  logic [7:0]   cfg_dst_role,
    input  logic [7:0]   cfg_dst_bank,
    input  logic [31:0]  cfg_dst_epoch,
    input  logic [63:0]  cfg_dst_base,
    input  logic [31:0]  cfg_dst_capacity,
    input  logic [31:0]  cfg_dst_bytes,
    input  logic [415:0] cfg_context,
    output logic         rsp_valid,
    input  logic         rsp_ready,
    output logic [7:0]   rsp_status,
    output logic [415:0] rsp_context,
    output logic         source_locked,
    output logic         dst_published,
    output logic [15:0]  skip_ar_count,
    output logic [15:0]  skip_r_count,
    output logic [15:0]  down_ar_count,
    output logic [15:0]  down_r_count,
    output logic [15:0]  add_start_count,
    output logic [15:0]  add_done_count,
    output logic [15:0]  aw_count,
    output logic [15:0]  w_count,
    output logic [15:0]  b_count,
    output logic         skip_arvalid,
    input  logic         skip_arready,
    output logic [63:0]  skip_araddr,
    output logic [7:0]   skip_arlen,
    output logic [2:0]   skip_arsize,
    output logic         skip_rready,
    input  logic         skip_rvalid,
    input  logic [511:0] skip_rdata,
    input  logic [1:0]   skip_rresp,
    input  logic         skip_rlast,
    output logic         down_arvalid,
    input  logic         down_arready,
    output logic [63:0]  down_araddr,
    output logic [7:0]   down_arlen,
    output logic [2:0]   down_arsize,
    output logic         down_rready,
    input  logic         down_rvalid,
    input  logic [511:0] down_rdata,
    input  logic [1:0]   down_rresp,
    input  logic         down_rlast,
    output logic         awvalid,
    input  logic         awready,
    output logic [63:0]  awaddr,
    output logic [7:0]   awlen,
    output logic [2:0]   awsize,
    output logic         wvalid,
    input  logic         wready,
    output logic [511:0] wdata,
    output logic [63:0]  wstrb,
    output logic         wlast,
    output logic         bready,
    input  logic         bvalid,
    input  logic [1:0]   bresp
);
  import laya_model_identity_13bo_generated_v1::L13M_CANONICAL;
  localparam logic [63:0] STATE0_BASE = 64'h0000000300000000;
  localparam logic [63:0] STATE1_BASE = 64'h0000000310000000;
  localparam logic [63:0] TMP_BASE = STATE1_BASE + 64'h0000000000800000;
  localparam logic [31:0] STATE0_CAPACITY = 32'd16920576;
  localparam logic [31:0] STATE1_CAPACITY = 32'd16919104;
  localparam logic [31:0] FOUR_ROW_BYTES = 32'd16384;
  // The connected LN/Q chain uses the canonical L13M package.  The earlier
  // standalone residual fixture used the Q8S2 diagnostic layout/build tags.
  localparam logic [127:0] MODEL_TAG = L13M_CANONICAL[0+:128];
  localparam logic [127:0] NUMERIC_TAG = L13M_CANONICAL[128+:128];
  localparam logic [127:0] LAYOUT_TAG = L13M_CANONICAL[256+:128];
  localparam logic [127:0] BUILD_TAG = L13M_CANONICAL[384+:128];
  localparam logic [7:0] STATUS_OK = 8'd0;
  localparam logic [7:0] STATUS_PROTOCOL = 8'd7;
  // Local 8-bit transport of the production Status enum (laya_types.h).
  localparam logic [7:0] STATUS_NUMERICAL = 8'd6;
  localparam logic [7:0] STATUS_INTERNAL = 8'd8;

  typedef enum logic [3:0] {
    IDLE, SKIP_AR, SKIP_R, DOWN_AR, DOWN_R, ADD_LAUNCH, ADD_COLLECT,
    WRITE_AW, WRITE_W, WRITE_B, RESPONSE
  } state_t;
  state_t state;
  logic [7:0] beat_index;
  logic [7:0] last_beat;
  logic [3:0] word_index;
  logic [511:0] skip_beat, down_beat, result_beat;
  logic [31:0] skip_word, down_word;
  logic slot_in_valid, slot_in_ready, slot_out_valid, slot_out_ready;
  logic [31:0] slot_result;
  logic slot_busy, slot_accepted, slot_returned, slot_consumed;

  assign cfg_ready = (state == IDLE);
  assign rsp_valid = (state == RESPONSE);
  assign skip_arvalid = (state == SKIP_AR);
  assign skip_araddr = STATE0_BASE + {50'd0, beat_index, 6'd0};
  assign skip_arlen = 8'd0;
  assign skip_arsize = 3'd6;
  assign skip_rready = (state == SKIP_R);
  assign down_arvalid = (state == DOWN_AR);
  assign down_araddr = TMP_BASE + {50'd0, beat_index, 6'd0};
  assign down_arlen = 8'd0;
  assign down_arsize = 3'd6;
  assign down_rready = (state == DOWN_R);
  assign awvalid = (state == WRITE_AW);
  assign awaddr = STATE1_BASE + {50'd0, beat_index, 6'd0};
  assign awlen = 8'd0;
  assign awsize = 3'd6;
  assign wvalid = (state == WRITE_W);
  assign wdata = result_beat;
  assign wstrb = '1;
  assign wlast = 1'b1;
  assign bready = (state == WRITE_B);
  assign skip_word = skip_beat[32*word_index +: 32];
  assign down_word = down_beat[32*word_index +: 32];
  assign slot_in_valid = (state == ADD_LAUNCH) &&
                         (skip_word[30:23] != 8'hff) &&
                         (down_word[30:23] != 8'hff);
  assign slot_out_ready = (state == ADD_COLLECT);

  laya_ffn_fadd_slot_v1 fadd_slot (
      .clk(clk), .rst_n(rst_n), .in_valid(slot_in_valid),
      .in_ready(slot_in_ready), .in_a(skip_word), .in_b(down_word),
      .out_valid(slot_out_valid), .out_ready(slot_out_ready),
      .out_bits(slot_result), .leaf_busy(slot_busy),
      .accepted_pulse(slot_accepted), .returned_pulse(slot_returned),
      .consumed_pulse(slot_consumed)
  );

  function automatic logic descriptor_valid();
    descriptor_valid =
        cfg_request == 32'd3 && cfg_generation == 32'd1 &&
        cfg_op == 8'h62 && cfg_stage == 8'd2 && cfg_layer == 8'd0 &&
        cfg_batch == 8'd0 && cfg_row == 8'd0 &&
        (cfg_rows == 8'd1 || cfg_rows == 8'd4) &&
        cfg_length == 16'd1024 && cfg_bias_id == 16'hffff &&
        cfg_model_tag == MODEL_TAG && cfg_numeric_tag == NUMERIC_TAG &&
        cfg_layout_tag == LAYOUT_TAG && cfg_build_tag == BUILD_TAG &&
        cfg_src0_role == 8'd3 && cfg_src0_bank == 8'd0 &&
        cfg_src0_epoch == 32'd1 && cfg_src0_base == TMP_BASE &&
        cfg_src0_capacity == STATE1_CAPACITY &&
        cfg_src0_bytes == ({24'd0,cfg_rows} << 12) &&
        cfg_src1_role == 8'd1 && cfg_src1_bank == 8'd0 &&
        cfg_src1_epoch == 32'd1 && cfg_src1_base == STATE0_BASE &&
        cfg_src1_capacity == STATE0_CAPACITY &&
        cfg_src1_bytes == ({24'd0,cfg_rows} << 12) &&
        cfg_dst_role == 8'd1 && cfg_dst_bank == 8'd1 &&
        cfg_dst_epoch == 32'd2 && cfg_dst_base == STATE1_BASE &&
        cfg_dst_capacity == STATE1_CAPACITY &&
        cfg_dst_bytes == ({24'd0,cfg_rows} << 12) &&
        (STATE0_BASE + STATE0_CAPACITY > STATE0_BASE) &&
        (STATE1_BASE + STATE1_CAPACITY > STATE1_BASE) &&
        (STATE1_BASE + STATE1_CAPACITY > TMP_BASE + FOUR_ROW_BYTES) &&
        (TMP_BASE >= STATE1_BASE + FOUR_ROW_BYTES);
  endfunction

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      beat_index <= '0;
      last_beat <= '0;
      word_index <= '0;
      skip_beat <= '0;
      down_beat <= '0;
      result_beat <= '0;
      rsp_status <= STATUS_OK;
      rsp_context <= '0;
      source_locked <= 1'b0;
      dst_published <= 1'b0;
      skip_ar_count <= '0;
      skip_r_count <= '0;
      down_ar_count <= '0;
      down_r_count <= '0;
      add_start_count <= '0;
      add_done_count <= '0;
      aw_count <= '0;
      w_count <= '0;
      b_count <= '0;
    end else begin
      if (slot_accepted) add_start_count <= add_start_count + 16'd1;
      if (slot_returned) add_done_count <= add_done_count + 16'd1;
      case (state)
        IDLE: if (cfg_valid) begin
          rsp_context <= cfg_context;
          rsp_status <= STATUS_OK;
          dst_published <= 1'b0;
          source_locked <= 1'b0;
          beat_index <= '0;
          last_beat <= ({cfg_rows,6'd0} - 14'd1);
          word_index <= '0;
          skip_ar_count <= '0;
          skip_r_count <= '0;
          down_ar_count <= '0;
          down_r_count <= '0;
          add_start_count <= '0;
          add_done_count <= '0;
          aw_count <= '0;
          w_count <= '0;
          b_count <= '0;
          if (descriptor_valid()) begin
            source_locked <= 1'b1;
            state <= SKIP_AR;
          end else begin
            rsp_status <= STATUS_PROTOCOL;
            state <= RESPONSE;
          end
        end
        SKIP_AR: if (skip_arready) begin
          skip_ar_count <= skip_ar_count + 16'd1;
          state <= SKIP_R;
        end
        SKIP_R: if (skip_rvalid) begin
          skip_r_count <= skip_r_count + 16'd1;
          if (skip_rresp != 2'b00 || !skip_rlast) begin
            rsp_status <= STATUS_INTERNAL;
            source_locked <= 1'b0;
            state <= RESPONSE;
          end else begin
            skip_beat <= skip_rdata;
            state <= DOWN_AR;
          end
        end
        DOWN_AR: if (down_arready) begin
          down_ar_count <= down_ar_count + 16'd1;
          state <= DOWN_R;
        end
        DOWN_R: if (down_rvalid) begin
          down_r_count <= down_r_count + 16'd1;
          if (down_rresp != 2'b00 || !down_rlast) begin
            rsp_status <= STATUS_INTERNAL;
            source_locked <= 1'b0;
            state <= RESPONSE;
          end else begin
            down_beat <= down_rdata;
            if (beat_index == last_beat) source_locked <= 1'b0;
            word_index <= '0;
            state <= ADD_LAUNCH;
          end
        end
        ADD_LAUNCH: begin
          if (skip_word[30:23] == 8'hff ||
              down_word[30:23] == 8'hff) begin
            rsp_status <= STATUS_NUMERICAL;
            source_locked <= 1'b0;
            state <= RESPONSE;
          end else if (slot_in_ready) state <= ADD_COLLECT;
        end
        ADD_COLLECT: if (slot_out_valid) begin
          if (slot_result[30:23] == 8'hff) begin
            rsp_status <= STATUS_NUMERICAL;
            source_locked <= 1'b0;
            state <= RESPONSE;
          end else begin
            result_beat[32*word_index +: 32] <= slot_result;
            if (word_index == 4'd15) state <= WRITE_AW;
            else begin
              word_index <= word_index + 4'd1;
              state <= ADD_LAUNCH;
            end
          end
        end
        WRITE_AW: if (awready) begin
          aw_count <= aw_count + 16'd1;
          state <= WRITE_W;
        end
        WRITE_W: if (wready) begin
          w_count <= w_count + 16'd1;
          state <= WRITE_B;
        end
        WRITE_B: if (bvalid) begin
          b_count <= b_count + 16'd1;
          if (bresp != 2'b00) begin
            rsp_status <= STATUS_INTERNAL;
            source_locked <= 1'b0;
            state <= RESPONSE;
          end else if (beat_index == last_beat) begin
            dst_published <= 1'b1;
            state <= RESPONSE;
          end else begin
            beat_index <= beat_index + 8'd1;
            state <= SKIP_AR;
          end
        end
        RESPONSE: if (rsp_ready) state <= IDLE;
        default: state <= IDLE;
      endcase
    end
  end
endmodule
