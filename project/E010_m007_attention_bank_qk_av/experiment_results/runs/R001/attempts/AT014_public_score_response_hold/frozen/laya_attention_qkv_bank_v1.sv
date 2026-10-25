`timescale 1ns/1ps

// The fixed Q/K/V store from M006 section 10.2. Matrix retirement writes one
// 32-column half at a time; each plane has its own 64-bank synchronous read.
// Ownership of a head/epoch is controlled by the caller's phase lease.
module laya_attention_qkv_bank_v1 (
  input  logic clk, rst_n,
  input  logic wr_valid,
  output logic wr_ready,
  input  logic [1:0] wr_plane,
  input  logic [3:0] wr_head,
  input  logic [6:0] wr_token,
  input  logic wr_half,
  input  logic [31:0][31:0] wr_data,
  input  logic [2:0] rd_valid,
  output logic [2:0] rd_ready,
  input  logic [2:0][3:0] rd_head,
  input  logic [2:0][6:0] rd_token,
  input  logic [2:0][31:0] rd_tag,
  output logic [2:0] rd_rsp_valid,
  input  logic [2:0] rd_rsp_ready,
  output logic [2:0][3:0] rd_rsp_head,
  output logic [2:0][6:0] rd_rsp_token,
  output logic [2:0][31:0] rd_rsp_tag,
  output logic [2:0][63:0][31:0] rd_rsp_data
);
  logic [2:0] rd_fire;
  logic write_collision;
  logic wr_fire;

  for (genvar plane = 0; plane < 3; plane++) begin : plane_store
    assign rd_ready[plane] = rst_n &&
      (!rd_rsp_valid[plane] || rd_rsp_ready[plane]);
    assign rd_fire[plane] = rd_valid[plane] && rd_ready[plane];

    always_ff @(posedge clk) begin
      if (!rst_n) begin
        rd_rsp_valid[plane] <= 1'b0;
        rd_rsp_head[plane] <= '0;
        rd_rsp_token[plane] <= '0;
        rd_rsp_tag[plane] <= '0;
      end else if (rd_ready[plane]) begin
        rd_rsp_valid[plane] <= rd_fire[plane];
        if (rd_fire[plane]) begin
          rd_rsp_head[plane] <= rd_head[plane];
          rd_rsp_token[plane] <= rd_token[plane];
          rd_rsp_tag[plane] <= rd_tag[plane];
        end
      end
    end

    for (genvar bank = 0; bank < 64; bank++) begin : channel_bank
      (* ram_style = "block" *) logic [31:0] words [0:2047];
      wire write_here = wr_fire && wr_plane == 2'(plane) &&
                        wr_half == 1'(bank / 32);
      always_ff @(posedge clk) begin
        if (write_here)
          words[{wr_head, wr_token}] <= wr_data[bank % 32];
        if (rd_fire[plane])
          rd_rsp_data[plane][bank] <= words[{rd_head[plane], rd_token[plane]}];
      end
    end
  end

  always_comb begin
    write_collision = 1'b0;
    for (int plane = 0; plane < 3; plane++) begin
      if (wr_plane == 2'(plane) && rd_fire[plane] &&
          wr_head == rd_head[plane] && wr_token == rd_token[plane])
        write_collision = 1'b1;
    end
  end
  assign wr_ready = rst_n && wr_plane != 2'd3 && !write_collision;
  assign wr_fire = wr_valid && wr_ready;
endmodule
