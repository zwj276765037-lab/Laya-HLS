`timescale 1ns/1ps
// One 131072B coefficient area:128banks x256F32. No per-head/table-half inference.
// table={family(full0/slide1),sin1/cos0}; each table has128rows x64F32.
module laya_rope_coeff_cache_v1(
 input logic clk,rst_n,
 input logic bind_valid,output logic bind_ready,
 input logic[63:0]bind_model_id,input logic[31:0]bind_numeric_id,input logic[127:0]bind_table_key,
 output logic bound_valid,output logic[63:0]bound_model_id,output logic[31:0]bound_numeric_id,output logic[127:0]bound_table_key,
 output logic[1:0]family_complete,
 input logic wr_valid,output logic wr_ready,input logic[63:0]wr_model_id,input logic[31:0]wr_numeric_id,input logic[127:0]wr_table_key,
 input logic[1:0]wr_table,input logic[6:0]wr_row,input logic wr_half,input logic[31:0][31:0]wr_data,
 output logic wr_reject_valid,output logic[2:0]wr_reject_code,output logic[4:0]wr_nonfinite_lane,
 input logic owner_valid,input logic[63:0]owner_request_id,input logic[31:0]owner_generation,owner_epoch,
 input logic rd_valid,output logic rd_ready,input logic rd_family,input logic[6:0]rd_row,input logic[95:0]rd_tag,
 input logic[63:0]rd_request_id,input logic[31:0]rd_generation,rd_epoch,
 output logic rd_reject_valid,output logic[2:0]rd_reject_code,
 output logic rsp_valid,input logic rsp_ready,output logic rsp_family,output logic[6:0]rsp_row,output logic[95:0]rsp_tag,
 output logic[127:0][31:0]rsp_data
);
 logic[1023:0]coverage;
 logic wr_finite;logic[4:0]bad_lane;
 wire write_identity=bound_valid&&wr_model_id==bound_model_id&&wr_numeric_id==bound_numeric_id&&wr_table_key==bound_table_key;
 wire read_identity=owner_valid&&rd_request_id==owner_request_id&&rd_generation==owner_generation&&rd_epoch==owner_epoch;
 wire wr_fire=wr_valid&&wr_ready;wire good_write=wr_fire&&wr_finite;
 wire rd_fire=rd_valid&&rd_ready;
 assign family_complete[0]=bound_valid&&(&coverage[511:0]);
 assign family_complete[1]=bound_valid&&(&coverage[1023:512]);
 assign bind_ready=rst_n&&!owner_valid&&!rsp_valid;
 assign wr_ready=rst_n&&!owner_valid&&write_identity&&!bind_valid;
 assign rd_ready=rst_n&&read_identity&&family_complete[rd_family]&&(!rsp_valid||rsp_ready);
 always_comb begin
  wr_finite=1;bad_lane=0;
  for(int i=31;i>=0;i--)if(wr_data[i][30:23]==8'hff)begin wr_finite=0;bad_lane=5'(i);end
  wr_nonfinite_lane=bad_lane;wr_reject_code=0;
  if(!bound_valid)wr_reject_code=1;
  else if(owner_valid)wr_reject_code=2;
  else if(!write_identity)wr_reject_code=3;
  else if(!wr_finite)wr_reject_code=4;
  wr_reject_valid=rst_n&&wr_valid&&wr_reject_code!=0;
  rd_reject_code=0;
  if(!owner_valid)rd_reject_code=1;
  else if(!read_identity)rd_reject_code=2;
  else if(!family_complete[rd_family])rd_reject_code=3;
  rd_reject_valid=rst_n&&rd_valid&&rd_reject_code!=0;
 end
 always_ff@(posedge clk)begin
  if(!rst_n)begin bound_valid<=0;bound_model_id<=0;bound_numeric_id<=0;bound_table_key<=0;coverage<=0;rsp_valid<=0;rsp_family<=0;rsp_row<=0;rsp_tag<=0;end
  else begin
   if(bind_valid&&bind_ready)begin bound_valid<=1;bound_model_id<=bind_model_id;bound_numeric_id<=bind_numeric_id;bound_table_key<=bind_table_key;coverage<=0;end
   else if(wr_fire)coverage[{wr_table,wr_row,wr_half}]<=wr_finite;
   if(!rsp_valid||rsp_ready)begin rsp_valid<=rd_fire;if(rd_fire)begin rsp_family<=rd_family;rsp_row<=rd_row;rsp_tag<=rd_tag;end end
  end
 end
 for(genvar bank=0;bank<128;bank++)begin:coefficient_bank
  (*ram_style="block"*)logic[31:0]words[0:255];
  wire write_bank=good_write&&wr_table[0]==1'(bank/64)&&wr_half==1'((bank%64)/32);
  always_ff@(posedge clk)begin
   if(write_bank)words[{wr_table[1],wr_row}]<=wr_data[bank%32];
   if(rd_fire)rsp_data[bank]<=words[{rd_family,rd_row}];
  end
 end
endmodule
