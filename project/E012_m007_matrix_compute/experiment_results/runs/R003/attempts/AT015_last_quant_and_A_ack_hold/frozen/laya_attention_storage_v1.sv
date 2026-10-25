`timescale 1ns/1ps
// Native synchronous bank set: one read and one write per physical bank.
// Vector requests are atomic; a held read/commit carries its immutable tag.
module laya_attention_native_bankset_v1 #(
 parameter int BANKS=64,DEPTH=2048,AW=11,
 parameter RAM_STYLE="block"
)(
 input logic clk,rst_n,enabled,
 input logic wr_valid,output logic wr_ready,
 input logic [BANKS-1:0] wr_mask,
 input logic [BANKS-1:0][AW-1:0] wr_addr,
 input logic [BANKS-1:0][31:0] wr_data,
 input logic [95:0] wr_tag,
 output logic wr_rsp_valid,input logic wr_rsp_ready,
 output logic [95:0] wr_rsp_tag,
 input logic rd_valid,output logic rd_ready,
 input logic [BANKS-1:0] rd_mask,
 input logic [BANKS-1:0][AW-1:0] rd_addr,
 input logic [95:0] rd_tag,
 output logic rd_rsp_valid,input logic rd_rsp_ready,
 output logic [BANKS-1:0][31:0] rd_rsp_data,
 output logic [BANKS-1:0] rd_rsp_mask,
 output logic [95:0] rd_rsp_tag,
 output logic idle
);
 logic collision;
 wire rd_fire=rd_valid&&rd_ready;
 wire wr_fire=wr_valid&&wr_ready;
 always_comb begin
  collision=0;
  for(int b=0;b<BANKS;b++)
   if(rd_fire&&rd_mask[b]&&wr_mask[b]&&rd_addr[b]==wr_addr[b])collision=1;
 end
 assign rd_ready=rst_n&&enabled&&(|rd_mask)&&(!rd_rsp_valid||rd_rsp_ready);
 assign wr_ready=rst_n&&enabled&&(|wr_mask)&&(!wr_rsp_valid||wr_rsp_ready)&&!collision;
 assign idle=!rd_rsp_valid&&!wr_rsp_valid;
 always_ff @(posedge clk)begin
  if(!rst_n)begin rd_rsp_valid<=0;wr_rsp_valid<=0;rd_rsp_mask<=0;rd_rsp_tag<=0;wr_rsp_tag<=0;end
  else begin
   if(!rd_rsp_valid||rd_rsp_ready)begin
    rd_rsp_valid<=rd_fire;
    if(rd_fire)begin rd_rsp_mask<=rd_mask;rd_rsp_tag<=rd_tag;end
   end
   if(!wr_rsp_valid||wr_rsp_ready)begin
    wr_rsp_valid<=wr_fire;
    if(wr_fire)wr_rsp_tag<=wr_tag;
   end
  end
 end
 for(genvar b=0;b<BANKS;b++)begin:bank
  (* ram_style=RAM_STYLE *)logic [31:0] words[0:DEPTH-1];
  always_ff @(posedge clk)begin
   if(wr_fire&&wr_mask[b])words[wr_addr[b]]<=wr_data[b];
   if(rd_fire&&rd_mask[b])rd_rsp_data[b]<=words[rd_addr[b]];
  end
 end
endmodule

// Single future-shared physical PS/G/context instance. PS aliases score/AV;
// G aliases probability/GEGLU. No duplicated role-specific payload arrays.
module laya_attention_storage_v1(
 input logic clk,rst_n,
 input logic bind_valid,output logic bind_ready,
 input logic [63:0] bind_request_id,
 input logic [31:0] bind_generation,bind_epoch,
 input logic [3:0] bind_head,input logic [2:0] bind_phase,
 input logic [63:0] op_request_id,
 input logic [31:0] op_generation,op_epoch,
 input logic [2:0] op_phase,
 output logic [63:0] rsp_request_id,
 output logic [31:0] rsp_generation,rsp_epoch,
 output logic [3:0] rsp_head,output logic [2:0] rsp_phase,
 input logic ps_wr_valid,output logic ps_wr_ready,
 input logic [1023:0] ps_wr_mask,
 input logic [1023:0][3:0] ps_wr_addr,
 input logic [1023:0][31:0] ps_wr_data,
 input logic [95:0] ps_wr_tag,
 output logic ps_wr_rsp_valid,input logic ps_wr_rsp_ready,output logic [95:0] ps_wr_rsp_tag,
 input logic ps_rd_valid,output logic ps_rd_ready,
 input logic [1023:0] ps_rd_mask,
 input logic [1023:0][3:0] ps_rd_addr,
 input logic [95:0] ps_rd_tag,
 output logic ps_rd_rsp_valid,input logic ps_rd_rsp_ready,
 output logic [1023:0][31:0] ps_rd_rsp_data,
 output logic [1023:0] ps_rd_rsp_mask,output logic [95:0] ps_rd_rsp_tag,
 input logic g_wr_valid,output logic g_wr_ready,
 input logic [255:0] g_wr_mask,
 input logic [255:0][5:0] g_wr_addr,
 input logic [255:0][31:0] g_wr_data,
 input logic [95:0] g_wr_tag,
 output logic g_wr_rsp_valid,input logic g_wr_rsp_ready,output logic [95:0] g_wr_rsp_tag,
 input logic g_rd_valid,output logic g_rd_ready,
 input logic [255:0] g_rd_mask,
 input logic [255:0][5:0] g_rd_addr,
 input logic [95:0] g_rd_tag,
 output logic g_rd_rsp_valid,input logic g_rd_rsp_ready,
 output logic [255:0][31:0] g_rd_rsp_data,
 output logic [255:0] g_rd_rsp_mask,output logic [95:0] g_rd_rsp_tag,
 input logic context_wr_valid,output logic context_wr_ready,
 input logic [63:0] context_wr_mask,
 input logic [63:0][10:0] context_wr_addr,
 input logic [63:0][31:0] context_wr_data,
 input logic [95:0] context_wr_tag,
 output logic context_wr_rsp_valid,input logic context_wr_rsp_ready,output logic [95:0] context_wr_rsp_tag,
 input logic context_rd_valid,output logic context_rd_ready,
 input logic [63:0] context_rd_mask,
 input logic [63:0][10:0] context_rd_addr,
 input logic [95:0] context_rd_tag,
 output logic context_rd_rsp_valid,input logic context_rd_rsp_ready,
 output logic [63:0][31:0] context_rd_rsp_data,
 output logic [63:0] context_rd_rsp_mask,output logic [95:0] context_rd_rsp_tag,
 output logic idle
);
 logic bound,ps_idle,g_idle,context_idle;
 wire enabled=rst_n&&bound&&op_request_id==rsp_request_id&&op_generation==rsp_generation&&op_epoch==rsp_epoch&&op_phase==rsp_phase;
 assign idle=ps_idle&&g_idle&&context_idle;
 assign bind_ready=rst_n&&idle&&!ps_wr_valid&&!ps_rd_valid&&!g_wr_valid&&!g_rd_valid&&!context_wr_valid&&!context_rd_valid;
 always_ff @(posedge clk)begin
  if(!rst_n)begin bound<=0;rsp_request_id<=0;rsp_generation<=0;rsp_epoch<=0;rsp_head<=0;rsp_phase<=0;end
  else if(bind_valid&&bind_ready)begin
   bound<=1;rsp_request_id<=bind_request_id;rsp_generation<=bind_generation;rsp_epoch<=bind_epoch;rsp_head<=bind_head;rsp_phase<=bind_phase;
  end
 end
 laya_attention_native_bankset_v1 #(.BANKS(1024),.DEPTH(16),.AW(4),.RAM_STYLE("distributed")) ps(
  .clk,.rst_n,.enabled,.wr_valid(ps_wr_valid),.wr_ready(ps_wr_ready),.wr_mask(ps_wr_mask),.wr_addr(ps_wr_addr),.wr_data(ps_wr_data),.wr_tag(ps_wr_tag),
  .wr_rsp_valid(ps_wr_rsp_valid),.wr_rsp_ready(ps_wr_rsp_ready),.wr_rsp_tag(ps_wr_rsp_tag),.rd_valid(ps_rd_valid),.rd_ready(ps_rd_ready),.rd_mask(ps_rd_mask),.rd_addr(ps_rd_addr),.rd_tag(ps_rd_tag),
  .rd_rsp_valid(ps_rd_rsp_valid),.rd_rsp_ready(ps_rd_rsp_ready),.rd_rsp_data(ps_rd_rsp_data),.rd_rsp_mask(ps_rd_rsp_mask),.rd_rsp_tag(ps_rd_rsp_tag),.idle(ps_idle));
 laya_attention_native_bankset_v1 #(.BANKS(256),.DEPTH(64),.AW(6),.RAM_STYLE("distributed")) g(
  .clk,.rst_n,.enabled,.wr_valid(g_wr_valid),.wr_ready(g_wr_ready),.wr_mask(g_wr_mask),.wr_addr(g_wr_addr),.wr_data(g_wr_data),.wr_tag(g_wr_tag),
  .wr_rsp_valid(g_wr_rsp_valid),.wr_rsp_ready(g_wr_rsp_ready),.wr_rsp_tag(g_wr_rsp_tag),.rd_valid(g_rd_valid),.rd_ready(g_rd_ready),.rd_mask(g_rd_mask),.rd_addr(g_rd_addr),.rd_tag(g_rd_tag),
  .rd_rsp_valid(g_rd_rsp_valid),.rd_rsp_ready(g_rd_rsp_ready),.rd_rsp_data(g_rd_rsp_data),.rd_rsp_mask(g_rd_rsp_mask),.rd_rsp_tag(g_rd_rsp_tag),.idle(g_idle));
 laya_attention_native_bankset_v1 #(.BANKS(64),.DEPTH(2048),.AW(11),.RAM_STYLE("block")) context_store(
  .clk,.rst_n,.enabled,.wr_valid(context_wr_valid),.wr_ready(context_wr_ready),.wr_mask(context_wr_mask),.wr_addr(context_wr_addr),.wr_data(context_wr_data),.wr_tag(context_wr_tag),
  .wr_rsp_valid(context_wr_rsp_valid),.wr_rsp_ready(context_wr_rsp_ready),.wr_rsp_tag(context_wr_rsp_tag),.rd_valid(context_rd_valid),.rd_ready(context_rd_ready),.rd_mask(context_rd_mask),.rd_addr(context_rd_addr),.rd_tag(context_rd_tag),
  .rd_rsp_valid(context_rd_rsp_valid),.rd_rsp_ready(context_rd_rsp_ready),.rd_rsp_data(context_rd_rsp_data),.rd_rsp_mask(context_rd_rsp_mask),.rd_rsp_tag(context_rd_rsp_tag),.idle(context_idle));
endmodule
