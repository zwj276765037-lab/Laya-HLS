`timescale 1ns/1ps
module new_ps_cone(
 input logic clk,
 input logic [2:0] state,input logic [63:0][3:0] pool_state,
 input logic [12:0] ps_next,issue_count,commit_count,write_next,
 input logic [15:0] k,input logic ctx,bias_ctx,retire_ctx,bias_active,retire_active,aborting,
 input logic [5:0] bias_next,input logic [8:0] retire_next,
 input logic [1:0][12:0] ctx_committed,input logic [6:0] math_debt,bias_debt,
 input logic out_hold_valid,out_ready,ps_rd_ready,ps_wr_ready,ps_wr_rsp_valid,
 input logic [95:0] ps_wr_rsp_tag,ps_rd_rsp_tag,
 input logic [31:0] epoch,generation,
 input logic [6:0] add_rsp_valid,add_req_ready,input logic [6:0][95:0] add_rsp_tag,
 input logic [255:0][31:0] add_rsp_data,input logic [8191:0] op0[0:63],
 output logic [1023:0] ps_rd_mask,ps_wr_mask,
 output logic [1023:0][3:0] ps_rd_addr,ps_wr_addr,
 output logic [1023:0][31:0] ps_wr_data,
 output logic ps_rd_valid,ps_wr_valid,ps_rd_rsp_ready,ps_wr_rsp_ready,
 output logic [95:0] ps_rd_tag,ps_wr_tag,output logic [6:0] add_rsp_ready,
 output logic math_read_part,bias_read_part,retire_read_part,math_read_fire,bias_read_fire,retire_read_fire,
 output logic normal_write_ack,bias_write_ack,output logic [6:0] arithmetic_debt,output integer room);
 localparam int IDLE=0,BIND=1,RUN=2,WRELEASE=3,FINALRELEASE=4;
 localparam int EMPTY=0,WAITDOT=1,MULREADY=2,MULWAIT=3,TERMREADY=4,PSWAIT=5,ADDREADY=6,ADDWAIT=7,SUMREADY=8,WRITEWAIT=9;
 integer bank_index;logic ps_rsp_math,ps_rsp_bias,ps_rsp_retire;
 function automatic [95:0] tag(input logic kind,input logic which_ctx,input logic [12:0] seq);
  return {epoch,generation,which_ctx,kind,17'b0,seq};
 endfunction
 assign arithmetic_debt=math_debt+bias_debt;
 assign ps_wr_rsp_ready=1'b1;
 always_comb begin
  normal_write_ack=ps_wr_rsp_valid&&!ps_wr_rsp_tag[30];bias_write_ack=ps_wr_rsp_valid&&ps_wr_rsp_tag[30];
  room=64-arithmetic_debt+normal_write_ack+bias_write_ack;
  math_read_part=state==RUN&&ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next>=32&&commit_count>ps_next-32;
  bias_read_part=bias_active&&!aborting&&bias_next<32&&ctx_committed[bias_ctx]>k-32+bias_next&&room>0;
  retire_read_part=retire_active&&!aborting&&retire_next<256&&(!out_hold_valid||out_ready);
  if(math_read_part&&bias_read_part&&ctx==bias_ctx)math_read_part=0;
  if(retire_read_part&&((math_read_part&&ctx==retire_ctx)||(bias_read_part&&bias_ctx==retire_ctx)))retire_read_part=0;
  ps_rd_valid=math_read_part||bias_read_part||retire_read_part;
  ps_rd_tag={epoch,generation,math_read_part,bias_read_part,retire_read_part,ctx,bias_ctx,retire_ctx,ps_next,bias_next[4:0],retire_next[7:0]};
  math_read_fire=ps_rd_valid&&ps_rd_ready&&math_read_part;bias_read_fire=ps_rd_valid&&ps_rd_ready&&bias_read_part;retire_read_fire=ps_rd_valid&&ps_rd_ready&&retire_read_part;
  ps_rsp_math=ps_rd_rsp_tag[31];ps_rsp_bias=ps_rd_rsp_tag[30];ps_rsp_retire=ps_rd_rsp_tag[29];
  ps_rd_rsp_ready=(!ps_rsp_retire||!out_hold_valid||out_ready)&&(!ps_rsp_bias||add_req_ready[0]);
  ps_wr_valid=0;ps_wr_tag=0;
  if(add_rsp_valid[0]&&add_rsp_tag[0][30])begin
   ps_wr_valid=1;ps_wr_tag=add_rsp_tag[0];
  end else if(state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY)begin
   ps_wr_valid=1;ps_wr_tag=tag(0,ctx,write_next);
  end
  add_rsp_ready=7'b0000001;if(add_rsp_tag[0][30])add_rsp_ready[0]=ps_wr_ready;
 end
 // PS representation diagnostic: fixed bank b={context,row,half,column}.
 generate for(genvar bank=0;bank<1024;bank++)begin:g_ps_static_bank
  localparam int C=bank/512,A=(bank%512)/32,H=(bank%32)/16,J=bank%16;
  always_comb begin
   ps_rd_mask[bank]=0;ps_rd_addr[bank]=0;
   if(math_read_part&&ctx==C&&ps_next[3]==H)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*ps_next[2:0]+ps_next[4];end
   if(bias_read_part&&bias_ctx==C&&bias_next[3]==H)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*bias_next[2:0]+bias_next[4];end
   if(retire_read_part&&retire_ctx==C&&retire_next[4:1]==A)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*retire_next[7:5]+retire_next[0];end
   ps_wr_mask[bank]=0;ps_wr_addr[bank]=0;ps_wr_data[bank]=0;
   if(add_rsp_valid[0]&&add_rsp_tag[0][30])begin
    if(add_rsp_tag[0][31]==C&&add_rsp_tag[0][3]==H)begin ps_wr_mask[bank]=1;ps_wr_addr[bank]=2*add_rsp_tag[0][2:0]+add_rsp_tag[0][4];ps_wr_data[bank]=add_rsp_data[16*A+J];end
   end else if(state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY)begin
    if(ctx==C&&write_next[3]==H)begin ps_wr_mask[bank]=1;ps_wr_addr[bank]=2*write_next[2:0]+write_next[4];ps_wr_data[bank]=op0[write_next[5:0]][32*(16*A+J)+:32];end
   end
  end
 end endgenerate
endmodule
