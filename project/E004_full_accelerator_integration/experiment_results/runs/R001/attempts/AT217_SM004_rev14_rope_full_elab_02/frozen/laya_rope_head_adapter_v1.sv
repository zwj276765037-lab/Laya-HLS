`timescale 1ns/1ps

// A single original full-Check HLS RoPE leaf, with synchronous ap_memory
// operands and one 256-byte head bank reused for x and y.
module laya_rope_head_adapter_v1 (
  input  logic clk, rst_n,
  input  logic table_reset,
  input  logic head_prepare,
  input  logic x_block_valid,
  input  logic [1:0] x_block,
  input  logic [511:0] x_block_data,
  input  logic cos_block_valid, sin_block_valid,
  input  logic [3:0] table_block,
  input  logic [127:0] table_block_data,
  input  logic start_valid,
  output logic start_ready,
  output logic result_valid,
  input  logic result_ready,
  output logic [127:0] result_check,
  output logic result_protocol_error,
  input  logic [2:0] y_tile_index,
  output logic [255:0] y_tile,
  output logic [63:0] x_coverage, cos_coverage, sin_coverage,
  output logic [63:0] y_coverage,
  output logic leaf_active,
  output logic leaf_ap_done
);
  logic [31:0] head_mem [0:63];
  logic [31:0] cos_mem [0:63], sin_mem [0:63];
  logic [31:0] x_q, cos_q, sin_q;
  logic [5:0] x_addr, cos_addr, sin_addr, y_addr0, y_addr1;
  logic x_ce, cos_ce, sin_ce, y_ce0, y_ce1, y_we0, y_we1;
  logic [31:0] y_d0, y_d1;
  logic [127:0] leaf_check;
  logic leaf_idle, leaf_ready;
  logic finishing, duplicate_y, duplicate_x, duplicate_table;
  logic [9:0] reset_guard;
  logic [63:0] y_mask_next;

  assign start_ready = rst_n && reset_guard == 0 && !leaf_active &&
      !finishing && !result_valid && leaf_idle &&
      &x_coverage && &cos_coverage && &sin_coverage &&
      !duplicate_x && !duplicate_table;
  assign y_mask_next = y_coverage |
      ((leaf_active && y_ce0 && y_we0) ? (64'b1 << y_addr0) : 64'b0) |
      ((leaf_active && y_ce1 && y_we1) ? (64'b1 << y_addr1) : 64'b0);

  always_comb begin
    y_tile = '0;
    for (integer i = 0; i < 8; i++)
      y_tile[i*32 +: 32] = head_mem[{y_tile_index,3'(i)}];
  end

  rope_head leaf (
    .ap_clk(clk), .ap_rst(!rst_n), .ap_start(start_valid && start_ready),
    .ap_done(leaf_ap_done), .ap_idle(leaf_idle), .ap_ready(leaf_ready),
    .x_address0(x_addr), .x_ce0(x_ce), .x_q0(x_q),
    .cosine_address0(cos_addr), .cosine_ce0(cos_ce), .cosine_q0(cos_q),
    .sine_address0(sin_addr), .sine_ce0(sin_ce), .sine_q0(sin_q),
    .y_address0(y_addr0), .y_ce0(y_ce0), .y_we0(y_we0), .y_d0(y_d0),
    .y_address1(y_addr1), .y_ce1(y_ce1), .y_we1(y_we1), .y_d1(y_d1),
    .ap_return(leaf_check)
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      x_q <= 0; cos_q <= 0; sin_q <= 0;
      x_coverage <= 0; cos_coverage <= 0;
      sin_coverage <= 0; y_coverage <= 0;
      leaf_active <= 0; finishing <= 0; result_valid <= 0;
      result_check <= 0; result_protocol_error <= 0;
      duplicate_y <= 0; duplicate_x <= 0; duplicate_table <= 0;
      reset_guard <= 10'd510;
    end else begin
      if (reset_guard != 0) reset_guard <= reset_guard - 1'b1;
      if (x_ce) x_q <= head_mem[x_addr];
      if (cos_ce) cos_q <= cos_mem[cos_addr];
      if (sin_ce) sin_q <= sin_mem[sin_addr];
      if (table_reset && !leaf_active) begin
        cos_coverage <= 0; sin_coverage <= 0;
        duplicate_table <= 0;
      end
      if (head_prepare && !leaf_active && !result_valid) begin
        x_coverage <= 0; y_coverage <= 0;
        duplicate_x <= 0; duplicate_y <= 0;
        result_protocol_error <= 0;
      end
      if (x_block_valid && !leaf_active) begin
        if (|(x_coverage & (64'hffff << {x_block,4'b0000})))
          duplicate_x <= 1;
        for (integer i = 0; i < 16; i++) begin
          head_mem[{x_block,4'(i)}] <= x_block_data[i*32 +: 32];
          x_coverage[{x_block,4'(i)}] <= 1;
        end
      end
      if (cos_block_valid && !leaf_active) begin
        if (|(cos_coverage & (64'hf << {table_block,2'b00})))
          duplicate_table <= 1;
        for (integer i = 0; i < 4; i++) begin
          cos_mem[{table_block,2'(i)}] <= table_block_data[i*32 +: 32];
          cos_coverage[{table_block,2'(i)}] <= 1;
        end
      end
      if (sin_block_valid && !leaf_active) begin
        if (|(sin_coverage & (64'hf << {table_block,2'b00})))
          duplicate_table <= 1;
        for (integer i = 0; i < 4; i++) begin
          sin_mem[{table_block,2'(i)}] <= table_block_data[i*32 +: 32];
          sin_coverage[{table_block,2'(i)}] <= 1;
        end
      end
      if (start_valid && start_ready) leaf_active <= 1;
      if (leaf_active && reset_guard == 0) begin
        if (y_ce0 && y_we0) begin
          if (y_coverage[y_addr0]) duplicate_y <= 1;
          head_mem[y_addr0] <= y_d0;
          y_coverage[y_addr0] <= 1;
        end
        if (y_ce1 && y_we1) begin
          if (y_coverage[y_addr1] ||
              (y_ce0 && y_we0 && y_addr0 == y_addr1))
            duplicate_y <= 1;
          head_mem[y_addr1] <= y_d1;
          y_coverage[y_addr1] <= 1;
        end
        if (leaf_ap_done) begin
          result_check <= leaf_check;
          finishing <= 1;
          leaf_active <= 0;
        end
      end
      if (finishing) begin
        result_protocol_error <= duplicate_y ||
            (result_check[15:0] == 0 && !(&y_coverage));
        result_valid <= 1;
        finishing <= 0;
      end
      if (result_valid && result_ready) result_valid <= 0;
    end
  end
endmodule
