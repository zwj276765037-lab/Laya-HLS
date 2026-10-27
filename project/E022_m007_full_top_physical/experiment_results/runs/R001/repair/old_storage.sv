`timescale 1ns/1ps
module old_storage(
input logic clk,rst_n,
 input logic [2:0] state,input logic [63:0][3:0] pool_state,
 input logic [12:0] issue_count,mul_next,ps_next,add_next,write_next,
 input logic format_valid,mul_rsp_valid,mul_rsp_ready,ps_rd_rsp_valid,ps_rd_rsp_ready,ps_rsp_math,
 input logic [95:0] format_tag,mul_rsp_tag,ps_rd_rsp_tag,ps_wr_rsp_tag,
 input logic [6:0] add_rsp_valid,add_rsp_ready,input logic [6:0][95:0] add_rsp_tag,
 input logic [255:0][31:0] converted,products,mul_rsp_data,add_rsp_data,
 input logic [1023:0][31:0] ps_rd_rsp_data,
 input logic ctx,ps_rsp_bias,ps_rsp_retire,out_hold_valid,out_ready,
 output logic [255:0][31:0] mul_a,mul_b,add_a,add_b,trace_commit_data,
 output logic [1023:0][31:0] ps_wr_data,
 output logic [1023:0] ps_wr_mask,output logic [1023:0][3:0] ps_wr_addr);
 localparam int IDLE=0,BIND=1,RUN=2,WRELEASE=3,FINALRELEASE=4;
 localparam int EMPTY=0,WAITDOT=1,MULREADY=2,MULWAIT=3,TERMREADY=4,PSWAIT=5,ADDREADY=6,ADDWAIT=7,SUMREADY=8,WRITEWAIT=9;
 integer bank_index;
 logic [63:0][255:0][31:0]  op0,op1;
 always_ff @(posedge clk)begin
  if(!rst_n)begin
  end else begin
   if(state==RUN)begin
    if(format_valid)begin op0[format_tag[5:0]]<=converted;op1[format_tag[5:0]]<=products;end
    if(mul_rsp_valid&&mul_rsp_ready)begin op0[mul_rsp_tag[5:0]]<=mul_rsp_data;end
    if(ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32)begin op1[ps_next[5:0]]<='0;end
   end
   if(ps_rd_rsp_valid&&ps_rd_rsp_ready&&ps_rsp_math)begin for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)op1[ps_rd_rsp_tag[18:13]][16*a+c]<=ps_rd_rsp_data[512*ps_rd_rsp_tag[28]+32*a+16*ps_rd_rsp_tag[16]+c];end
   if(add_rsp_valid[0]&&add_rsp_ready[0]&&!add_rsp_tag[0][30])begin op0[add_rsp_tag[0][5:0]]<=add_rsp_data;end
  end
 end
 // Storage-related cone: unrelated bias data branch is empty in BOTH extracts.
 always_comb begin
  mul_a=op0[mul_next[5:0]];mul_b=op1[mul_next[5:0]];
  add_a=0;add_b=0;ps_wr_mask=0;ps_wr_addr=0;ps_wr_data=0;bank_index=0;
  if(ps_rd_rsp_valid&&ps_rsp_bias&&(!ps_rsp_retire||!out_hold_valid||out_ready))begin end else if(state==RUN&&add_next<issue_count&&pool_state[add_next[5:0]]==ADDREADY)begin add_a=op0[add_next[5:0]];add_b=op1[add_next[5:0]];end
  if(add_rsp_valid[0]&&add_rsp_tag[0][30])begin end else if(state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY)begin for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)begin bank_index=512*ctx+32*a+16*write_next[3]+c;ps_wr_mask[bank_index]=1;ps_wr_addr[bank_index]=2*write_next[2:0]+write_next[4];ps_wr_data[bank_index]=op0[write_next[5:0]][16*a+c];end end
  trace_commit_data=op0[ps_wr_rsp_tag[5:0]];
 end
endmodule
