`timescale 1ns/1ps

// One physical slot/parity/lane bank. No payload reset or extra read stage.
// The parent validates full addresses before narrowing to these ports.
(* keep_hierarchy = "yes" *)
module t4_w_cache_bank_v1 #(
  parameter int BANK_DEPTH = 10496,
  parameter int BIAS_DEPTH = 328
) (
  input logic clk,
  input logic q_we, s_we, b_we,
  input logic [13:0] q_waddr, s_waddr,
  input logic [8:0] b_waddr,
  input logic [255:0] q_wdata,
  input logic [15:0] s_wdata,
  input logic [31:0] b_wdata,
  input logic qs_re, b_re,
  input logic [13:0] qs_raddr,
  input logic [8:0] b_raddr,
  output logic [255:0] q_rdata,
  output logic [15:0] s_rdata,
  output logic [31:0] b_rdata
);
  (* ram_style = "ultra" *) logic [255:0] qmem [0:BANK_DEPTH-1];
  (* ram_style = "block" *) logic [15:0] smem [0:BANK_DEPTH-1];
  (* ram_style = "block" *) logic [31:0] bmem [0:BIAS_DEPTH-1];
  always_ff @(posedge clk) begin
    if (q_we) qmem[q_waddr] <= q_wdata;
    if (qs_re) q_rdata <= qmem[qs_raddr];
  end
  always_ff @(posedge clk) begin
    if (s_we) smem[s_waddr] <= s_wdata;
    if (qs_re) s_rdata <= smem[qs_raddr];
  end
  always_ff @(posedge clk) begin
    if (b_we) bmem[b_waddr] <= b_wdata;
    if (b_re) b_rdata <= bmem[b_raddr];
  end
endmodule
