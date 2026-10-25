`timescale 1ns/1ps
// Public-port alias of soleQKV plane0. No payload or identity copy.
// Parent holds owner identity until lease release. Parent qualification inputs
// must be wired to actual consumers when integrated; local test is not parent proof.
module laya_m007_qscratch32_v1(
 input logic clk,rst_n,
 input logic lease_valid,output logic lease_ready,
 input logic release_valid,output logic release_ready,
 input logic layer_retired,matrix_retired,quant_retired,normal_requests_present,
 input logic rope_owner_valid,input logic[2:0]qkv_rsp_valid,
 input logic[63:0]owner_request_id,input logic[31:0]owner_generation,owner_epoch,
 output logic owner_active,normal_enable,
 input logic[63:0]access_request_id,input logic[31:0]access_generation,access_epoch,
 input logic wr_valid,output logic wr_ready,input logic[11:0]wr_addr,
 input logic[31:0][31:0]wr_data,output logic wr_commit,
 input logic rd_valid,output logic rd_ready,input logic[11:0]rd_addr,
 output logic rd_rsp_valid,input logic rd_rsp_ready,
 output logic[11:0]rd_rsp_addr,output logic[31:0][31:0]rd_rsp_data,
 output logic reject_valid,retired,
 output logic q_wr_valid,input logic q_wr_ready,output logic[1:0]q_wr_plane,
 output logic[3:0]q_wr_head,output logic[6:0]q_wr_token,output logic q_wr_half,
 output logic[31:0][31:0]q_wr_data,
 output logic q_rd_valid,input logic q_rd_ready,output logic[3:0]q_rd_head,
 output logic[6:0]q_rd_token,output logic[31:0]q_rd_tag,
 input logic q_rsp_valid,output logic q_rsp_ready,input logic[31:0]q_rsp_tag,
 input logic[63:0][31:0]q_rsp_data
);
 wire identity=access_request_id==owner_request_id&&access_generation==owner_generation&&access_epoch==owner_epoch;
 wire qualified=owner_active&&identity&&!rope_owner_valid;
 assign normal_enable=rst_n&&!owner_active;
 assign lease_ready=rst_n&&!owner_active&&layer_retired&&matrix_retired&&quant_retired&&!normal_requests_present&&!rope_owner_valid&&qkv_rsp_valid==0;
 assign release_ready=rst_n&&owner_active&&qkv_rsp_valid==0&&!wr_valid&&!rd_valid;
 assign retired=!owner_active&&qkv_rsp_valid==0;
 always_ff @(posedge clk)begin
  if(!rst_n)owner_active<=0;
  else if(release_valid&&release_ready)owner_active<=0;
  else if(lease_valid&&lease_ready)owner_active<=1;
 end
 assign q_wr_valid=rst_n&&qualified&&wr_valid;
 assign wr_ready=rst_n&&qualified&&q_wr_ready;
 assign wr_commit=wr_valid&&wr_ready;
 assign q_wr_plane=0;assign q_wr_head=wr_addr[4:1];assign q_wr_token=wr_addr[11:5];assign q_wr_half=wr_addr[0];assign q_wr_data=wr_data;
 assign q_rd_valid=rst_n&&qualified&&rd_valid;assign rd_ready=rst_n&&qualified&&q_rd_ready;
 assign q_rd_head=rd_addr[4:1];assign q_rd_token=rd_addr[11:5];assign q_rd_tag={20'b0,rd_addr};
 assign rd_rsp_valid=rst_n&&owner_active&&q_rsp_valid;
 assign q_rsp_ready=owner_active&&rd_rsp_ready;
 assign rd_rsp_addr=q_rsp_tag[11:0];
 // Select existing64lane synchronous response by its original half tag.
 for(genvar lane=0;lane<32;lane++)assign rd_rsp_data[lane]=q_rsp_data[(q_rsp_tag[0]?32:0)+lane];
 assign reject_valid=rst_n&&(wr_valid||rd_valid)&&!qualified;
endmodule
