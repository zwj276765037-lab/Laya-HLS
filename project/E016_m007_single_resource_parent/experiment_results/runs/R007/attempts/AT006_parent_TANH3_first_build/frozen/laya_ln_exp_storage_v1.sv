`timescale 1ns/1ps
// Sole256bank×32F32 LN/softmax-exp entity. Softmax context e/key mapping:
// bank=(e%8)*32+k%32; addr=(e/8)*4+k/32. No payload reset or role copy.
module laya_ln_exp_storage_v1(
 input logic clk,rst_n,
 input logic bind_valid,output logic bind_ready,input logic[63:0]bind_request_id,
 input logic[31:0]bind_generation,bind_epoch,input logic[3:0]bind_head,input logic[2:0]bind_phase,
 input logic[63:0]op_request_id,input logic[31:0]op_generation,op_epoch,input logic[2:0]op_phase,
 output logic[63:0]rsp_request_id,output logic[31:0]rsp_generation,rsp_epoch,output logic[3:0]rsp_head,output logic[2:0]rsp_phase,
 input logic wr_valid,output logic wr_ready,input logic[255:0]wr_mask,input logic[255:0][4:0]wr_addr,input logic[255:0][31:0]wr_data,input logic[95:0]wr_tag,
 output logic wr_rsp_valid,input logic wr_rsp_ready,output logic[95:0]wr_rsp_tag,
 input logic rd_valid,output logic rd_ready,input logic[255:0]rd_mask,input logic[255:0][4:0]rd_addr,input logic[95:0]rd_tag,
 output logic rd_rsp_valid,input logic rd_rsp_ready,output logic[255:0][31:0]rd_rsp_data,output logic[255:0]rd_rsp_mask,output logic[95:0]rd_rsp_tag,
 output logic idle
);
 logic bound,bank_idle,bank_wr_ready,bank_rd_ready;
 wire domain=bound&&op_request_id==rsp_request_id&&op_generation==rsp_generation&&op_epoch==rsp_epoch&&op_phase==rsp_phase;
 assign bind_ready=rst_n&&bank_idle&&!wr_valid&&!rd_valid;
 assign idle=bank_idle;assign wr_ready=bank_wr_ready&&domain;assign rd_ready=bank_rd_ready&&domain;
 always_ff @(posedge clk)begin
  if(!rst_n)begin bound<=0;rsp_request_id<=0;rsp_generation<=0;rsp_epoch<=0;rsp_head<=0;rsp_phase<=0;end
  else if(bind_valid&&bind_ready)begin bound<=1;rsp_request_id<=bind_request_id;rsp_generation<=bind_generation;rsp_epoch<=bind_epoch;rsp_head<=bind_head;rsp_phase<=bind_phase;end
 end
 laya_attention_native_bankset_v1 #(.BANKS(256),.DEPTH(32),.AW(5),.RAM_STYLE("distributed"))bankset(
  .clk,.rst_n,.enabled(domain),.wr_valid(wr_valid&&domain),.wr_ready(bank_wr_ready),.wr_mask,.wr_addr,.wr_data,.wr_tag,.wr_rsp_valid,.wr_rsp_ready,.wr_rsp_tag,
  .rd_valid(rd_valid&&domain),.rd_ready(bank_rd_ready),.rd_mask,.rd_addr,.rd_tag,.rd_rsp_valid,.rd_rsp_ready,.rd_rsp_data,.rd_rsp_mask,.rd_rsp_tag,.idle(bank_idle));
endmodule
