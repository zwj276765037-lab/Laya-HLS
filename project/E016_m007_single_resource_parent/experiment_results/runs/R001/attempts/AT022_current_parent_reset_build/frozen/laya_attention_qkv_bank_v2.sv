`timescale 1ns/1ps
// Sole QKV payload: legacy matrix32 write or atomic Q64+K64 RoPE alias.
// Each bank remains synchronous1R1W; accepted same-address reads take priority.
module laya_attention_qkv_bank_v2 (
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
  output logic [2:0][63:0][31:0] rd_rsp_data,
  input logic rope_owner_valid,input logic[63:0]rope_owner_request_id,
  input logic[31:0]rope_owner_generation,rope_owner_epoch,
  input logic rope_wr_valid,output logic rope_wr_ready,
  input logic[63:0]rope_wr_request_id,input logic[31:0]rope_wr_generation,rope_wr_epoch,
  input logic[3:0]rope_wr_head,input logic[6:0]rope_wr_token,
  input logic[95:0]rope_wr_tag,input logic[63:0][31:0]rope_wr_q,rope_wr_k,
  output logic rope_wr_commit_valid,output logic[95:0]rope_wr_commit_tag,
  output logic rope_reject_valid,output logic[2:0]rope_reject_code
);

  logic [2:0] rd_fire;
  logic write_collision;
  logic wr_fire,rope_collision;
  wire rope_fire=rope_wr_valid&&rope_wr_ready;
  wire rope_identity=rope_wr_request_id==rope_owner_request_id&&rope_wr_generation==rope_owner_generation&&rope_wr_epoch==rope_owner_epoch;
  assign rope_wr_commit_valid=rope_fire;assign rope_wr_commit_tag=rope_wr_tag;
  // No write response is invented: commit is exactly the synchronous wr_fire.
  always_comb begin
    rope_reject_code=0;
    if(!rope_owner_valid)rope_reject_code=1;
    else if(rope_wr_request_id!=rope_owner_request_id)rope_reject_code=2;
    else if(rope_wr_generation!=rope_owner_generation)rope_reject_code=3;
    else if(rope_wr_epoch!=rope_owner_epoch)rope_reject_code=4;
    rope_reject_valid=rst_n&&rope_wr_valid&&rope_reject_code!=0;
  end
  assign rope_wr_ready=rst_n&&rope_owner_valid&&rope_identity&&!rope_collision;


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
        if (rope_fire && plane < 2)
          words[{rope_wr_head,rope_wr_token}] <= plane==0?rope_wr_q[bank]:rope_wr_k[bank];
        else if (write_here)
          words[{wr_head, wr_token}] <= wr_data[bank % 32];
        if (rd_fire[plane])
          rd_rsp_data[plane][bank] <= words[{rd_head[plane], rd_token[plane]}];
      end
    end
  end

  always_comb begin
    write_collision = 1'b0;rope_collision=1'b0;
    for (int plane = 0; plane < 3; plane++) begin
      if (wr_plane == 2'(plane) && rd_fire[plane] &&
          wr_head == rd_head[plane] && wr_token == rd_token[plane])
        write_collision = 1'b1;
      if(plane<2&&rd_fire[plane]&&rope_wr_head==rd_head[plane]&&rope_wr_token==rd_token[plane])rope_collision=1;
    end
  end
  assign wr_ready = rst_n && wr_plane != 2'd3 && !write_collision&&!rope_owner_valid;
  assign wr_fire = wr_valid && wr_ready;
endmodule
