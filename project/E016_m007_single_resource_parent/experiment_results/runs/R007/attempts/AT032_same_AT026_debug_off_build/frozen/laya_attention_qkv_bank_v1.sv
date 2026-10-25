`timescale 1ns/1ps
// Legacy signature; one v2 payload instance, new RoPE aliases explicitly disabled.
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
 laya_attention_qkv_bank_v2 bank( .clk,.rst_n,.wr_valid,.wr_ready,.wr_plane,.wr_head,.wr_token,.wr_half,.wr_data,.rd_valid,.rd_ready,.rd_head,.rd_token,.rd_tag,.rd_rsp_valid,.rd_rsp_ready,.rd_rsp_head,.rd_rsp_token,.rd_rsp_tag,.rd_rsp_data,
 .rope_owner_valid(1'b0),.rope_owner_request_id(64'b0),.rope_owner_generation(32'b0),.rope_owner_epoch(32'b0),
 .rope_wr_valid(1'b0),.rope_wr_ready(),.rope_wr_request_id(64'b0),.rope_wr_generation(32'b0),.rope_wr_epoch(32'b0),.rope_wr_head(4'b0),.rope_wr_token(7'b0),.rope_wr_tag(96'b0),.rope_wr_q(2048'b0),.rope_wr_k(2048'b0),.rope_wr_commit_valid(),.rope_wr_commit_tag(),.rope_reject_valid(),.rope_reject_code());
endmodule
