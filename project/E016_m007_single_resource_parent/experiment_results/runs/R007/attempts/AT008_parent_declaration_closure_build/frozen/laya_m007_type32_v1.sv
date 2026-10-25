`timescale 1ns/1ps
// One model-persistent96x32F32 bank,13 response-control bits+1024 payload bits.
// Parent setup owns sequential finite/index/model qualification; no identity FF.
module laya_m007_type32_v1(
 input logic clk,rst_n,model_committed,inference_active,
 input logic wr_valid,output logic wr_ready,input logic[6:0]wr_index,
 input logic[31:0][31:0]wr_data,output logic wr_commit,
 input logic rd_valid,output logic rd_ready,input logic[1:0]rd_qtype,
 input logic[11:0]rd_vector_addr,
 output logic rsp_valid,input logic rsp_ready,output logic[11:0]rsp_vector_addr,
 output logic[31:0][31:0]rsp_data,output logic bank_idle,reject_valid
);
 wire rd_fire=rd_valid&&rd_ready;
 wire[6:0]ram_addr={rd_qtype,rd_vector_addr[4:0]};
 assign bank_idle=!rsp_valid;
 assign wr_ready=rst_n&&!model_committed&&!inference_active&&bank_idle&&wr_index<96;
 assign wr_commit=wr_valid&&wr_ready;
 assign rd_ready=rst_n&&model_committed&&rd_qtype<3&&(!rsp_valid||rsp_ready);
 assign reject_valid=rst_n&&((wr_valid&&(model_committed||inference_active||wr_index>=96))||(rd_valid&&(!model_committed||rd_qtype==3)));
 always_ff@(posedge clk)begin
  if(!rst_n)begin rsp_valid<=0;rsp_vector_addr<=0;end
  else begin
   if(rsp_valid&&rsp_ready)rsp_valid<=0;
   if(rd_fire)begin rsp_valid<=1;rsp_vector_addr<=rd_vector_addr;end
  end
 end
 for(genvar lane=0;lane<32;lane++)begin:type_lane
  (* ram_style="block" *)logic[31:0]words[0:95];
  always_ff@(posedge clk)begin
   if(wr_commit)words[wr_index]<=wr_data[lane];
   if(rd_fire)rsp_data[lane]<=words[ram_addr];
  end
 end
endmodule
