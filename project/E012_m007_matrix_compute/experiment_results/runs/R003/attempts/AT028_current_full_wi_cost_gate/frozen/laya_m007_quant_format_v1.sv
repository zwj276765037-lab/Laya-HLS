`timescale 1ns/1ps
package laya_m007_quant_format_pkg;
 // Return {half_nonfinite, IEEE-RNE half}; no FTZ or saturation.
 function automatic logic[16:0]half_rne(input logic[31:0]bits);
  logic[15:0]sign,h;logic[31:0]mant,result,rem,mid,mask;integer e,shift;
  begin
   sign={bits[31],15'b0};mant={9'b0,bits[22:0]};e=int'(bits[30:23])-112;
   result=0;rem=0;mid=0;mask=0;shift=0;h=0;
   if(bits[30:23]==255)h=sign|(mant!=0?16'h7e00:16'h7c00);
   else if(e>=31)h=sign|16'h7c00;
   else if(e<=-11)h=sign;
   else if(e<=0)begin
    mant=mant|32'h00800000;shift=14-e;result=mant>>shift;
    mask=(32'b1<<shift)-1;rem=mant&mask;mid=32'b1<<(shift-1);
    if(rem>mid||(rem==mid&&result[0]))result=result+1;
    h=sign|result[15:0];
   end else begin
    result=(32'(e)<<10)|(mant>>13);rem=mant&32'h1fff;
    if(rem>32'h1000||(rem==32'h1000&&result[0]))result=result+1;
    h=sign|result[15:0];
   end
   half_rne={h[14:10]==31,h};
  end
 endfunction
 // Return {product_nonfinite, rounded_outside_Q8F, signed Q8}. Roundf ties
 // away from zero. Values outside[-127,127] are errors, never clamped.
 function automatic logic[9:0]round_q8(input logic[31:0]bits);
  logic[7:0]exp,q;logic[23:0]mant;logic[31:0]whole,rem,mid;integer shift;
  logic nonfinite,range_error;
  begin
   exp=bits[30:23];mant={1'b1,bits[22:0]};whole=0;rem=0;mid=0;shift=0;q=0;
   nonfinite=exp==255;range_error=0;
   if(!nonfinite)begin
    if(exp>=134)range_error=1;
    else begin
     if(exp<=125)whole=0;
     else if(exp==126)whole=1;
     else begin
      shift=150-int'(exp);whole=mant>>shift;
      rem=mant&((32'b1<<shift)-1);mid=32'b1<<(shift-1);
      if(rem>=mid)whole=whole+1;
     end
     if(whole>127)range_error=1;
     else q=bits[31]?8'(-int'(whole)):whole[7:0];
    end
   end
   round_q8={nonfinite,range_error,q};
  end
 endfunction
endpackage

module laya_m007_quant_format_v1(
 input logic[31:0]scale_f32,product_f32,
 output logic[15:0]scale_f16,output logic[7:0]q8,
 output logic half_error,product_nonfinite,range_error
);
 import laya_m007_quant_format_pkg::*;
 logic[16:0]h;logic[9:0]q;
 always_comb begin
  h=half_rne(scale_f32);q=round_q8(product_f32);
  scale_f16=h[15:0];half_error=h[16];q8=q[7:0];product_nonfinite=q[9];range_error=q[8];
 end
endmodule
