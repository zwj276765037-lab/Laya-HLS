`timescale 1ns/1ps
// Production public context consumer, query/head/half order, one real read credit.
// The public storage response holds payload under backpressure; no context copy.
module laya_m007_context_quant_adapter_v1(
 input logic clk,rst_n,
 input logic start_valid,output logic start_ready,
 input logic [31:0] generation,
 input logic cancel,
 output logic rd_valid,input logic rd_ready,
 output logic [31:0] rd_generation,rd_tag,
 output logic [3:0] rd_head,output logic [6:0] rd_query,output logic rd_half,
 input logic rsp_valid,output logic rsp_ready,input logic [31:0] rsp_tag,
 input logic [31:0][31:0] rsp_data,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [7:0] out_row,out_group,
 output logic idle,complete,protocol_fault,
 output logic [12:0] accepted_reads,consumed_groups
);
 logic active,pending,stopped;
 logic [11:0] pending_coordinate;
 wire rsp_fire=rsp_valid&&rsp_ready;
 wire rd_fire=rd_valid&&rd_ready;
 wire matching=rsp_tag=={20'b0,pending_coordinate};
 assign idle=!active&&!pending;
 assign start_ready=rst_n&&idle;
 assign rd_generation=generation;
 assign rd_tag={19'b0,accepted_reads};
 assign rd_query=accepted_reads[11:5];
 assign rd_head=accepted_reads[4:1];
 assign rd_half=accepted_reads[0];
 assign rd_valid=rst_n&&active&&!stopped&&!cancel&&accepted_reads<4096&&(!pending||(rsp_fire&&matching));
 assign out_valid=rst_n&&active&&pending&&rsp_valid&&matching&&!stopped&&!cancel;
 assign out_data=rsp_data;
 assign out_row={1'b0,pending_coordinate[11:5]};
 assign out_group={3'b0,pending_coordinate[4:0]};
 assign rsp_ready=rst_n&&pending&&((stopped||cancel||!matching)||out_ready);
 always_ff @(posedge clk)begin
  if(!rst_n)begin active<=0;pending<=0;stopped<=0;pending_coordinate<=0;accepted_reads<=0;consumed_groups<=0;complete<=0;protocol_fault<=0;end
  else begin
   if(start_valid&&start_ready)begin active<=1;pending<=0;stopped<=0;accepted_reads<=0;consumed_groups<=0;complete<=0;protocol_fault<=0;end
   if(active&&cancel)stopped<=1;
   if(rd_fire)begin pending<=1;pending_coordinate<=accepted_reads[11:0];accepted_reads<=accepted_reads+1;end
   else if(rsp_fire)pending<=0;
   if(rsp_fire)begin
    if(!matching)begin protocol_fault<=1;stopped<=1;end
    if(out_valid&&out_ready)begin
     consumed_groups<=consumed_groups+1;
     if(consumed_groups==4095)begin active<=0;complete<=1;end
    end
   end
   if(active&&(stopped||cancel)&&(!pending||rsp_fire)&&!rd_fire)active<=0;
  end
 end
endmodule
