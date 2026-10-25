`timescale 1ns/1ps
// Exact finite half x half -> binary32: at most22 significant product bits.
// Minimum nonzero result2^-48 is normal binary32. No half intermediate rounding.
module laya_m007_half_product_v1 #(parameter int TAG_W=32)(
 input logic clk,rst_n,req_valid,input logic [TAG_W-1:0] req_tag,
 input logic [15:0] a,b,
 output logic rsp_valid,output logic [TAG_W-1:0] rsp_tag,
 output logic [31:0] result,output logic nonfinite
);
 logic [2:0] valid;logic [TAG_W-1:0] tag[0:2];
 logic [10:0] ma,mb;logic [5:0] ea,eb;logic sign0,bad0;
 (* use_dsp="yes" *)logic [21:0] product;
 logic [7:0] exponent_base;logic sign1,bad1;
 logic [23:0] normalized;logic [7:0] final_exponent;integer leading;
 always_comb begin
  leading=0;for(integer i=0;i<22;i=i+1)if(product[i])leading=i;
  normalized={2'b0,product}<<(23-leading);final_exponent=exponent_base+leading;
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin valid<=0;nonfinite<=0;rsp_tag<=0;end
  else begin
   valid<={valid[1:0],req_valid};
   if(req_valid)begin
    ma<={(a[14:10]!=0),a[9:0]};mb<={(b[14:10]!=0),b[9:0]};
    ea<=(a[14:10]==0)?6'd1:{1'b0,a[14:10]};eb<=(b[14:10]==0)?6'd1:{1'b0,b[14:10]};
    sign0<=a[15]^b[15];bad0<=a[14:10]==31||b[14:10]==31;tag[0]<=req_tag;
   end
   if(valid[0])begin product<=ma*mb;exponent_base<=ea+eb+8'd77;sign1<=sign0;bad1<=bad0;tag[1]<=tag[0];end
   if(valid[1])begin
    result<=bad1?32'h7fc00000:((product==0)?{sign1,31'b0}:{sign1,final_exponent,normalized[22:0]});
    nonfinite<=bad1;rsp_tag<=tag[1];
   end
  end
 end
 assign rsp_valid=valid[2];
endmodule
