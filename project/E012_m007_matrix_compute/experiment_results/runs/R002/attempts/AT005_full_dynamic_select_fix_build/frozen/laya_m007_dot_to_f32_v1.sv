`timescale 1ns/1ps
// Exact conversion for the signed21bit dot domain |dot|<=524288.
module laya_m007_dot_to_f32_v1 #(parameter int TAG_W=32)(
 input logic clk,rst_n,req_valid,input logic [TAG_W-1:0] req_tag,input logic signed [20:0] dot,
 output logic rsp_valid,output logic [TAG_W-1:0] rsp_tag,output logic [31:0] result,output logic domain_error
);
 logic [20:0] magnitude;logic [23:0] normalized;logic [7:0] exponent;integer leading;
 always_comb begin
  magnitude=dot[20]?(~dot+21'd1):dot;leading=0;
  for(integer i=0;i<21;i=i+1)if(magnitude[i])leading=i;
  normalized={3'b0,magnitude}<<(23-leading);exponent=127+leading;
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin rsp_valid<=0;rsp_tag<=0;domain_error<=0;end
  else begin
   rsp_valid<=req_valid;
   if(req_valid)begin rsp_tag<=req_tag;domain_error<=magnitude>524288;result<=(magnitude==0)?32'b0:{dot[20],exponent,normalized[22:0]};end
  end
 end
endmodule
