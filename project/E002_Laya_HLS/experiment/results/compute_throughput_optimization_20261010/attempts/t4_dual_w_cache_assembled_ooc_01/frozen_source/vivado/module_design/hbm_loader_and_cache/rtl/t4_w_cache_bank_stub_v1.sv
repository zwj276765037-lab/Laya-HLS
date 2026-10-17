`timescale 1ns/1ps
// Intermediate OOC stub only; exact full-depth DCP is inserted before reports.
(* black_box = "yes", keep_hierarchy = "yes" *)
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
endmodule
