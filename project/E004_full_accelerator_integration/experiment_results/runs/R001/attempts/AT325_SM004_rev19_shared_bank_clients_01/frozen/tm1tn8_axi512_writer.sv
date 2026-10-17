`timescale 1ns/1ps

// One output shard: one accumulating beat, one immutable AXI transaction,
// and one accepted tile whose remaining lanes may span a second beat.
module tm1tn8_axi512_writer #(
  parameter bit SHARD = 1'b0
) (
  input logic clk, rst_n,
  input logic tile_valid,
  output logic tile_ready,
  input logic [255:0] tile_f32,
  input logic [11:0] tile_n0,
  input logic [1:0] tile_row_local,
  input logic [9:0] tile_row0,
  input logic tile_batch,
  input logic [3:0] tile_lanes,
  input logic mode_qkv,
  input logic rearm_valid,
  output logic rearm_ready,
  input logic flush_req,
  output logic flush_done, debt_zero,
  input logic [63:0] output_base, output_span,
  output logic fault,
  output logic [31:0] aw_count, w_count, b_count,
  output logic [63:0] useful_bytes, physical_bytes,
  output logic [63:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,
  output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,
  output logic m_axi_awvalid,
  input logic m_axi_awready,
  output logic [511:0] m_axi_wdata,
  output logic [63:0] m_axi_wstrb,
  output logic m_axi_wlast, m_axi_wvalid,
  input logic m_axi_wready,
  input logic [1:0] m_axi_bresp,
  input logic m_axi_bvalid,
  output logic m_axi_bready
);
  logic held_valid, held_batch, held_qkv;
  logic [255:0] held_f32;
  logic [11:0] held_n0;
  logic [1:0] held_row_local;
  logic [9:0] held_row0;
  logic [3:0] held_lanes;
  logic [7:0] held_pending;
  logic pack_valid, tx_valid, tx_aw_sent, tx_w_sent;
  logic [63:0] pack_addr, pack_strb, tx_addr, tx_strb;
  logic [511:0] pack_data, tx_data;
  logic flushing, flush_reported;

  logic [63:0] lane_addr [0:7];
  logic [7:0] beat_mask;
  logic [63:0] next_beat;
  logic bad_held, b_fire, b_error, seal_pack, transfer_pack;
  logic merge_tile;
  logic [7:0] pending_after_merge;

  always_comb begin : address_decode
    logic [12:0] col;
    logic [1:0] plane;
    logic [9:0] feature;
    logic [3:0] head, local_head;
    logic [5:0] d;
    logic [63:0] relative_byte;
    logic [64:0] physical_sum;
    logic seen_first;
    bad_held = held_valid && (held_lanes == 0 || held_lanes > 8);
    next_beat = '0;
    beat_mask = '0;
    seen_first = 1'b0;
    for (integer i = 0; i < 8; i++) begin
      lane_addr[i] = '0;
      col = {1'b0, held_n0} + 13'(i);
      plane = col / 13'd1024;
      feature = col % 13'd1024;
      head = feature / 10'd64;
      d = feature % 10'd64;
      local_head = head >> 1;
      if (held_qkv)
        relative_byte = (((((({62'b0, plane} * 2 + held_batch) * 8 +
                          local_head) * 1024 + held_row0 + held_row_local) *
                          64) + d) * 4);
      else
        relative_byte = {49'b0, col} * 4;
      physical_sum = {1'b0, output_base} + {1'b0, relative_byte};
      lane_addr[i] = physical_sum[63:0];
      if (held_valid && i < held_lanes &&
          (physical_sum[64] || output_base[1:0] != 0 ||
           relative_byte > output_span || output_span - relative_byte < 4 ||
           (held_qkv && (plane >= 3 || head[0] != SHARD ||
                         held_row0 + held_row_local >= 1024))))
        bad_held = 1'b1;
      if (held_valid && held_pending[i] && !seen_first) begin
        next_beat = {physical_sum[63:6], 6'b0};
        seen_first = 1'b1;
      end
    end
    for (integer i = 0; i < 8; i++)
      if (held_valid && held_pending[i] &&
          {lane_addr[i][63:6], 6'b0} == next_beat)
        beat_mask[i] = 1'b1;
  end

  assign b_fire = tx_valid && tx_aw_sent && tx_w_sent && m_axi_bvalid;
  assign b_error = b_fire && m_axi_bresp != 2'b00;
  assign seal_pack = pack_valid &&
      (pack_strb == 64'hffffffffffffffff ||
       (held_valid && held_pending != 0 && pack_addr != next_beat) ||
       ((flushing || flush_req) && !held_valid));
  assign transfer_pack = seal_pack && (!tx_valid || b_fire) &&
                         !b_error && !fault && !bad_held;
  assign merge_tile = held_valid && held_pending != 0 && !bad_held &&
      !fault && !b_error &&
      (!pack_valid || pack_addr == next_beat || transfer_pack) &&
      (!seal_pack || transfer_pack);
  assign pending_after_merge = held_pending & ~beat_mask;
  assign tile_ready = !fault && !flushing && !flush_req &&
      (!held_valid || (merge_tile && pending_after_merge == 0));

  assign m_axi_awaddr = tx_addr;
  assign m_axi_awlen = 8'd0;
  assign m_axi_awsize = 3'd6;
  assign m_axi_awburst = 2'b01;
  assign m_axi_awvalid = tx_valid && !tx_aw_sent;
  assign m_axi_wdata = tx_data;
  assign m_axi_wstrb = tx_strb;
  assign m_axi_wlast = 1'b1;
  assign m_axi_wvalid = tx_valid && !tx_w_sent;
  assign m_axi_bready = tx_valid && tx_aw_sent && tx_w_sent;
  assign debt_zero = !held_valid && !pack_valid && !tx_valid;
  assign rearm_ready = rst_n && debt_zero && !tile_valid && !flush_req;

  always_ff @(posedge clk) begin : writer_registers
    logic next_held_valid, next_pack_valid, next_tx_valid;
    logic [7:0] next_pending;
    logic [63:0] next_pack_addr, next_pack_strb;
    logic [511:0] next_pack_data;
    logic [31:0] added_bytes;
    if (!rst_n) begin
      held_valid <= 0;
      held_f32 <= '0;
      held_n0 <= '0;
      held_row_local <= '0;
      held_row0 <= '0;
      held_batch <= 0;
      held_lanes <= '0;
      held_qkv <= 0;
      held_pending <= '0;
      pack_valid <= 0;
      pack_addr <= '0;
      pack_data <= '0;
      pack_strb <= '0;
      tx_valid <= 0;
      tx_addr <= '0;
      tx_data <= '0;
      tx_strb <= '0;
      tx_aw_sent <= 0;
      tx_w_sent <= 0;
      flushing <= 0;
      flush_reported <= 0;
      flush_done <= 0;
      fault <= 0;
      aw_count <= '0;
      w_count <= '0;
      b_count <= '0;
      useful_bytes <= '0;
      physical_bytes <= '0;
    end else if (rearm_valid && rearm_ready) begin
      // A new row may reuse this writer only after every old AXI debt retires.
      // In particular, rearm never cancels an already presented AW or W.
      flushing <= 0;
      flush_reported <= 0;
      flush_done <= 0;
      fault <= 0;
      aw_count <= '0;
      w_count <= '0;
      b_count <= '0;
      useful_bytes <= '0;
      physical_bytes <= '0;
    end else begin
      next_held_valid = held_valid;
      next_pending = held_pending;
      next_pack_valid = pack_valid;
      next_pack_addr = pack_addr;
      next_pack_data = pack_data;
      next_pack_strb = pack_strb;
      next_tx_valid = tx_valid;
      added_bytes = 0;
      flush_done <= 0;
      if (flush_req && !flush_reported) flushing <= 1;
      if (!flush_req && flush_reported) begin
        flushing <= 0;
        flush_reported <= 0;
      end

      if (m_axi_awvalid && m_axi_awready) begin
        tx_aw_sent <= 1;
        aw_count <= aw_count + 1;
      end
      if (m_axi_wvalid && m_axi_wready) begin
        tx_w_sent <= 1;
        w_count <= w_count + 1;
        physical_bytes <= physical_bytes + 64;
      end
      if (b_fire) begin
        b_count <= b_count + 1;
        next_tx_valid = 0;
        tx_aw_sent <= 0;
        tx_w_sent <= 0;
      end
      if (transfer_pack) begin
        tx_addr <= pack_addr;
        tx_data <= pack_data;
        tx_strb <= pack_strb;
        next_tx_valid = 1;
        tx_aw_sent <= 0;
        tx_w_sent <= 0;
        next_pack_valid = 0;
        next_pack_strb = '0;
        next_pack_data = '0;
      end
      if (merge_tile) begin
        if (!next_pack_valid) begin
          next_pack_valid = 1;
          next_pack_addr = next_beat;
          next_pack_data = '0;
          next_pack_strb = '0;
        end
        for (integer i = 0; i < 8; i++) begin
          if (beat_mask[i]) begin
            next_pack_data[lane_addr[i][5:2]*32 +: 32] =
                held_f32[i*32 +: 32];
            next_pack_strb[lane_addr[i][5:2]*4 +: 4] = 4'hf;
            added_bytes = added_bytes + 4;
          end
        end
        next_pending = pending_after_merge;
        if (pending_after_merge == 0) next_held_valid = 0;
      end
      if (added_bytes != 0) useful_bytes <= useful_bytes + added_bytes;

      if (bad_held || b_error) begin
        fault <= 1;
        next_held_valid = 0;
        next_pending = '0;
        next_pack_valid = 0;
        next_pack_data = '0;
        next_pack_strb = '0;
      end else if (tile_valid && tile_ready) begin
        held_f32 <= tile_f32;
        held_n0 <= tile_n0;
        held_row_local <= tile_row_local;
        held_row0 <= tile_row0;
        held_batch <= tile_batch;
        held_lanes <= tile_lanes;
        held_qkv <= mode_qkv;
        next_pending = 8'((9'b1 << tile_lanes) - 1);
        next_held_valid = 1;
        if (tile_lanes == 0 || tile_lanes > 8 ||
            (mode_qkv && tile_lanes != 8)) begin
          fault <= 1;
          next_held_valid = 0;
          next_pending = '0;
          next_pack_valid = 0;
          next_pack_strb = '0;
          next_pack_data = '0;
        end
      end

      held_valid <= next_held_valid;
      held_pending <= next_pending;
      pack_valid <= next_pack_valid;
      pack_addr <= next_pack_addr;
      pack_data <= next_pack_data;
      pack_strb <= next_pack_strb;
      tx_valid <= next_tx_valid;
      if (flushing && !flush_reported && !fault && !bad_held &&
          !b_error && !next_held_valid && !next_pack_valid &&
          !next_tx_valid) begin
        flush_done <= 1;
        flush_reported <= 1;
        flushing <= 0;
      end
    end
  end
endmodule
