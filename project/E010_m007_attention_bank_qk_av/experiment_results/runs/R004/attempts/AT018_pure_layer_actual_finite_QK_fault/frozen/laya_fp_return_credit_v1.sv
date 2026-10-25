`timescale 1ns/1ps
// Reservation covers both in-flight nonblocking results and buffered returns.
// DEPTH=64 on mul and add gives 128 independently reservable vector slots.
module laya_fp_return_credit_v1 #(parameter int WIDTH=128, LATENCY=8, DEPTH=64)(
 input logic clk,rst_n,req_valid,
 input logic bypass_enable,
 output logic req_ready,
 input logic [95:0] req_tag,
 input logic result_valid,
 input logic [WIDTH-1:0] result_data,
 output logic rsp_valid,
 input logic rsp_ready,
 output logic [95:0] rsp_tag,
 output logic [WIDTH-1:0] rsp_data,
 output logic [6:0] pending,in_flight,
 output logic fault
);
 localparam int AW=$clog2(DEPTH);
 logic [AW-1:0] issue_ptr,return_ptr,head_ptr;
 logic [DEPTH-1:0] available;
 logic [95:0] tags [DEPTH];
 logic [WIDTH-1:0] payload [DEPTH];
 logic [LATENCY-1:0] issued_valid;
 wire issue_fire=req_valid&&req_ready;
 wire consume_fire=rsp_valid&&rsp_ready;
 assign req_ready=rst_n&&!fault&&pending<DEPTH;
 // Consume only an actual ordered head return. If ready is low the same
 // reserved slot captures it below, and the next cycle exposes identical data.
 wire bypass_head=bypass_enable&&rst_n&&!fault&&pending!=0&&!available[head_ptr]&&
                  return_ptr==head_ptr&&result_valid&&issued_valid[LATENCY-1]&&in_flight!=0;
 assign rsp_valid=rst_n&&!fault&&pending!=0&&(available[head_ptr]||bypass_head);
 assign rsp_tag=tags[head_ptr];assign rsp_data=bypass_head?result_data:payload[head_ptr];
 always_ff @(posedge clk) begin
  if(!rst_n) begin
   issue_ptr<=0;return_ptr<=0;head_ptr<=0;available<=0;
   pending<=0;in_flight<=0;issued_valid<=0;fault<=0;
  end else begin
   issued_valid<={issued_valid[LATENCY-2:0],issue_fire};
   if(result_valid!=issued_valid[LATENCY-1] || (result_valid&&in_flight==0)) fault<=1;
   if(issue_fire) begin
    tags[issue_ptr]<=req_tag;available[issue_ptr]<=0;issue_ptr<=issue_ptr+1'b1;
   end
   if(result_valid) begin
    payload[return_ptr]<=result_data;available[return_ptr]<=1;return_ptr<=return_ptr+1'b1;
   end
   if(consume_fire) begin available[head_ptr]<=0;head_ptr<=head_ptr+1'b1;end
   case({issue_fire,consume_fire})
    2'b10:pending<=pending+1'b1;2'b01:pending<=pending-1'b1;default:;
   endcase
   case({issue_fire,result_valid})
    2'b10:in_flight<=in_flight+1'b1;2'b01:in_flight<=in_flight-1'b1;default:;
   endcase
  end
 end
endmodule
