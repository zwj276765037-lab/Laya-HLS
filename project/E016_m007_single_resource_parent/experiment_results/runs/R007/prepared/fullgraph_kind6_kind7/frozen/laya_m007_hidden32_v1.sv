`timescale 1ns/1ps
// Sole resident hidden payload,32 independent4096xF32 synchronous1R1W banks.
module laya_m007_hidden32_v1(
 input logic clk,rst_n,enabled,
 input logic wr_valid,output logic wr_ready,input logic[11:0]wr_addr,
 input logic[31:0][31:0]wr_data,output logic wr_commit,
 input logic rd_valid,output logic rd_ready,input logic[11:0]rd_addr,
 output logic rd_rsp_valid,input logic rd_rsp_ready,
 output logic[11:0]rd_rsp_addr,output logic[31:0][31:0]rd_rsp_data,
 output logic bank_idle
);
 wire rd_fire=rd_valid&&rd_ready;
 assign rd_ready=rst_n&&enabled&&(!rd_rsp_valid||rd_rsp_ready);
 assign wr_ready=rst_n&&enabled&&!(rd_fire&&rd_addr==wr_addr);
 assign wr_commit=wr_valid&&wr_ready;
 assign bank_idle=!rd_rsp_valid;
 always_ff @(posedge clk)begin
  if(!rst_n)begin rd_rsp_valid<=0;rd_rsp_addr<=0;end
  else begin
   if(rd_rsp_valid&&rd_rsp_ready)rd_rsp_valid<=0;
   if(rd_fire)begin rd_rsp_valid<=1;rd_rsp_addr<=rd_addr;end
  end
 end
 for(genvar lane=0;lane<32;lane++)begin:channel_bank
  (* ram_style="block" *)logic[31:0]words[0:4095];
  always_ff @(posedge clk)begin
   if(wr_commit)words[wr_addr]<=wr_data[lane];
   if(rd_fire)rd_rsp_data[lane]<=words[rd_addr];
  end
 end
endmodule

// Identity qualification borrows the parent's held context; no identity FF.
module laya_m007_hidden32_owner_v1(
 input logic clk,rst_n,owner_valid,
 input logic[63:0]owner_request_id,input logic[31:0]owner_generation,owner_epoch,
 input logic[63:0]access_request_id,input logic[31:0]access_generation,access_epoch,
 input logic wr_valid,output logic wr_ready,input logic[11:0]wr_addr,
 input logic[31:0][31:0]wr_data,output logic wr_commit,
 input logic rd_valid,output logic rd_ready,input logic[11:0]rd_addr,
 output logic rd_rsp_valid,input logic rd_rsp_ready,
 output logic[11:0]rd_rsp_addr,output logic[31:0][31:0]rd_rsp_data,
 output logic bank_idle,reject_valid
);
 wire qualified=owner_valid&&access_request_id==owner_request_id&&access_generation==owner_generation&&access_epoch==owner_epoch;
 logic raw_wr_ready,raw_rd_ready;
 assign wr_ready=qualified&&raw_wr_ready;assign rd_ready=qualified&&raw_rd_ready;
 assign reject_valid=rst_n&&(wr_valid||rd_valid)&&!qualified;
 laya_m007_hidden32_v1 bank(.clk,.rst_n,.enabled(owner_valid),.wr_valid(wr_valid&&qualified),.wr_ready(raw_wr_ready),.wr_addr,.wr_data,.wr_commit,
  .rd_valid(rd_valid&&qualified),.rd_ready(raw_rd_ready),.rd_addr,.rd_rsp_valid,.rd_rsp_ready,.rd_rsp_addr,.rd_rsp_data,.bank_idle);
endmodule
