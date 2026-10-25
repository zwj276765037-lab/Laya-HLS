`timescale 1ns/1ps
// Exact fixed2^-10 scaling, single binary32 RNE with gradual underflow.
module laya_m007_ln_div1024_v1 #(parameter integer TAG_WIDTH=96)(
 input logic clk,rst_n,req_valid,output logic req_ready,input logic[31:0]req_data,
 input logic[TAG_WIDTH-1:0]req_tag,output logic rsp_valid,input logic rsp_ready,
 output logic[31:0]rsp_data,output logic rsp_error,output logic[TAG_WIDTH-1:0]rsp_tag
);
 function automatic logic[31:0]divide1024(input logic[31:0]x);
  logic[23:0]mant,rounded;logic[31:0]rem,mask,mid;integer shift;
  begin
   mant=0;rounded=0;rem=0;mask=0;mid=0;shift=0;
   if(x[30:23]==255)divide1024=32'h7fc00000;
   else if(x[30:23]>10)divide1024={x[31],8'(x[30:23]-10),x[22:0]};
   else begin
    mant={x[30:23]!=0,x[22:0]};shift=x[30:23]==0?10:11-int'(x[30:23]);
    rounded=mant>>shift;mask=(32'b1<<shift)-1;rem=32'(mant)&mask;mid=32'b1<<(shift-1);
    if(rem>mid||(rem==mid&&rounded[0]))rounded=rounded+1'b1;
    divide1024={x[31],7'b0,rounded};
   end
  end
 endfunction
 assign req_ready=rst_n&&(!rsp_valid||rsp_ready);
 always_ff@(posedge clk)begin
  if(!rst_n)begin rsp_valid<=0;rsp_error<=0;end
  else if(req_ready)begin
   rsp_valid<=req_valid;
   if(req_valid)begin rsp_data<=divide1024(req_data);rsp_error<=req_data[30:23]==255;rsp_tag<=req_tag;end
  end
 end
endmodule

// One iterative24-digit integer root. Integer remainder determines the sole RNE.
// Positive finite sqrt is normal (minimum input2^-149); signed zero is preserved.
module laya_m007_ln_sqrt_v1 #(parameter integer TAG_WIDTH=96)(
 input logic clk,rst_n,req_valid,output logic req_ready,input logic[31:0]req_data,
 input logic[TAG_WIDTH-1:0]req_tag,output logic rsp_valid,input logic rsp_ready,
 output logic[31:0]rsp_data,output logic rsp_error,output logic[TAG_WIDTH-1:0]rsp_tag,
 output logic busy
);
 logic[47:0]radicand;logic[49:0]remainder;logic[23:0]root;
 logic[4:0]step;logic signed[10:0]result_exponent;logic work_error,work_zero,work_sign;
 logic[TAG_WIDTH-1:0]work_tag;
 logic[23:0]mantissa;logic[24:0]parity_mantissa;logic signed[10:0]unbiased;
 logic[4:0]leading;logic[49:0]next_remainder,trial;logic[23:0]next_root;logic[24:0]rounded_root;
 logic[8:0]packed_exp;logic[22:0]packed_frac;
 function automatic logic[4:0]lzc24(input logic[23:0]value);
  logic found;logic[4:0]count;
  begin found=0;count=0;for(int i=23;i>=0;i--)if(!found)begin if(value[i])found=1;else count=count+1'b1;end lzc24=count;end
 endfunction
 assign req_ready=rst_n&&!busy&&(!rsp_valid||rsp_ready);
 always_comb begin
  mantissa={req_data[30:23]!=0,req_data[22:0]};leading=lzc24(mantissa);
  unbiased=req_data[30:23]==0?-11'sd126-$signed({6'b0,leading}):$signed({3'b0,req_data[30:23]})-11'sd127;
  if(req_data[30:23]==0)mantissa=mantissa<<leading;
  parity_mantissa={1'b0,mantissa};if(unbiased[0])parity_mantissa=parity_mantissa<<1;
  next_remainder=(remainder<<2)|{48'b0,radicand[47:46]};trial=({26'b0,root}<<2)|50'b1;
  next_root=root<<1;
  if(next_remainder>=trial)begin next_remainder=next_remainder-trial;next_root=next_root|24'b1;end
  // sqrt(R) is above n+1/2 exactly iff integer remainder > n; no integer R tie.
  rounded_root={1'b0,next_root}+(next_remainder>{26'b0,next_root});
  packed_exp=9'(result_exponent);packed_frac=rounded_root[22:0];
  if(rounded_root[24])begin packed_exp=9'(result_exponent+1'b1);packed_frac=rounded_root[23:1];end
 end
 always_ff@(posedge clk)begin
  if(!rst_n)begin busy<=0;rsp_valid<=0;rsp_error<=0;step<=0;end
  else begin
   if(rsp_valid&&rsp_ready)rsp_valid<=0;
   if(req_valid&&req_ready)begin
    busy<=1;step<=0;radicand<={parity_mantissa,23'b0};remainder<=0;root<=0;work_tag<=req_tag;
    work_error<=req_data[30:23]==255||(req_data[31]&&req_data[30:0]!=0);
    work_zero<=req_data[30:0]==0;work_sign<=req_data[31];
    result_exponent<=((unbiased-$signed({10'b0,unbiased[0]}))>>>1)+11'sd127;
   end else if(busy)begin
    radicand<=radicand<<2;remainder<=next_remainder;root<=next_root;
    if(step==23)begin
     busy<=0;rsp_valid<=1;rsp_tag<=work_tag;rsp_error<=work_error;
     if(work_error)rsp_data<=32'h7fc00000;
     else if(work_zero)rsp_data<={work_sign,31'b0};
     else rsp_data<={1'b0,packed_exp[7:0],packed_frac};
    end else step<=step+1'b1;
   end
  end
 end
endmodule
