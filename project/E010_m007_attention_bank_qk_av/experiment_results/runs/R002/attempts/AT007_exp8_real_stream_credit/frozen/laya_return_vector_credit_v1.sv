`timescale 1ns/1ps
// Real vector reservation for fixed-latency nonblocking leaves. Capacity covers
// in-flight plus held returns; a simultaneous actual consume may free one slot.
module laya_return_vector_credit_v1 #(parameter int WIDTH=256,TAG_WIDTH=11,LATENCY=167,DEPTH=256)(
 input logic clk,rst_n,req_valid,output logic req_ready,
 input logic[TAG_WIDTH-1:0]req_tag,input logic result_valid,input logic[WIDTH-1:0]result_data,
 output logic rsp_valid,input logic rsp_ready,output logic[TAG_WIDTH-1:0]rsp_tag,output logic[WIDTH-1:0]rsp_data,
 output logic[$clog2(DEPTH):0]pending,in_flight,output logic fault
);
 localparam int AW=$clog2(DEPTH);
 logic[AW-1:0]issue_ptr,return_ptr,head_ptr;logic[DEPTH-1:0]available;
 (* ram_style="distributed" *)logic[TAG_WIDTH-1:0]tags[DEPTH];
 (* ram_style="distributed" *)logic[WIDTH-1:0]payload[DEPTH];
 logic[LATENCY-1:0]issued_valid;
 wire consume_fire=rsp_valid&&rsp_ready;wire issue_fire=req_valid&&req_ready;
 assign req_ready=rst_n&&!fault&&(pending<DEPTH||consume_fire);
 assign rsp_valid=rst_n&&!fault&&pending!=0&&available[head_ptr];
 assign rsp_tag=tags[head_ptr];assign rsp_data=payload[head_ptr];
 always_ff @(posedge clk)begin
  if(!rst_n)begin issue_ptr<=0;return_ptr<=0;head_ptr<=0;available<=0;issued_valid<=0;pending<=0;in_flight<=0;fault<=0;end
  else begin
   issued_valid<={issued_valid[LATENCY-2:0],issue_fire};
   if(result_valid!=issued_valid[LATENCY-1]||(result_valid&&in_flight==0))fault<=1;
   if(issue_fire)begin tags[issue_ptr]<=req_tag;available[issue_ptr]<=0;issue_ptr<=issue_ptr+1'b1;end
   if(result_valid)begin payload[return_ptr]<=result_data;available[return_ptr]<=1;return_ptr<=return_ptr+1'b1;end
   if(consume_fire)begin available[head_ptr]<=0;head_ptr<=head_ptr+1'b1;end
   case({issue_fire,consume_fire})2'b10:pending<=pending+1'b1;2'b01:pending<=pending-1'b1;default:;endcase
   case({issue_fire,result_valid})2'b10:in_flight<=in_flight+1'b1;2'b01:in_flight<=in_flight-1'b1;default:;endcase
  end
 end
endmodule
