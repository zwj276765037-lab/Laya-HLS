`timescale 1ns/1ps
// One public64B catalog transaction. Caller holds catalog_base/req_word from
// req accept until idle returns; payload and request identity are not stored.
module laya_m007_catalog_reader_v1(
 input logic clk,rst_n,
 input logic req_valid,output logic req_ready,
 input logic [6:0]req_word,input logic [63:0]catalog_base,
 output logic rsp_valid,input logic rsp_ready,output logic [511:0]rsp_data,
 output logic fault,output logic [2:0]rsp_rid,output logic [1:0]rsp_rresp,
 output logic rsp_rlast,output logic idle,
 output logic arvalid,input logic arready,output logic [63:0]araddr,
 output logic [2:0]arid,output logic [7:0]arlen,
 output logic [2:0]arsize,output logic [1:0]arburst,
 input logic rvalid,output logic rready,input logic [511:0]rdata,
 input logic [2:0]rid,input logic [1:0]rresp,input logic rlast
);
 localparam logic[1:0]IDLE=0,AR=1,RSP=2,DRAIN=3;
 logic[1:0]state;
 wire[64:0]catalog_end={1'b0,catalog_base}+65'd8192;
 wire[64:0]word_address={1'b0,catalog_base}+{52'b0,req_word,6'b0};
 wire legal_request=req_word<=123&&catalog_base[11:0]==0&&!catalog_end[64];
 assign idle=rst_n&&state==IDLE;
 assign req_ready=idle&&legal_request;
 assign arvalid=rst_n&&state==AR;
 assign araddr=word_address[63:0];
 assign arid=3'd7;assign arlen=8'd0;assign arsize=3'd6;assign arburst=2'b01;
 assign rsp_valid=rst_n&&state==RSP&&rvalid;
 assign rsp_data=rdata;assign rsp_rid=rid;assign rsp_rresp=rresp;assign rsp_rlast=rlast;
 assign fault=rsp_valid&&(rid!=3'd7||rresp!=2'b00||!rlast);
 assign rready=rst_n&&((state==RSP&&rsp_ready)||state==DRAIN);
 always_ff@(posedge clk)begin
  if(!rst_n)state<=IDLE;
  else case(state)
   IDLE:if(req_valid&&req_ready)state<=AR;
   AR:if(arvalid&&arready)state<=RSP;
   RSP:if(rsp_valid&&rsp_ready)state<=rlast?IDLE:DRAIN;
   DRAIN:if(rvalid&&rready&&rlast)state<=IDLE;
  endcase
 end
endmodule
