`timescale 1ns/1ps
// Canonical local scalar control lives in the caller's q, with no shadow FF.
// Arithmetic is the same exact scaling/integer-root algorithm as frozen v1.
module laya_m007_ln_div1024_external_v2(
 input logic clk,rst_n,control_enable,input logic[4:0]control_q,output logic[4:0]control_next,
 input logic req_valid,output logic req_ready,input logic[31:0]req_data,input logic[2:0]req_tag,
 output logic rsp_valid,input logic rsp_ready,output logic[31:0]rsp_data,output logic rsp_error,
 output logic[2:0]rsp_tag
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
 assign req_ready=control_enable&&rst_n&&(!control_q[0]||rsp_ready);
 assign rsp_valid=control_enable&&control_q[0];assign rsp_error=control_q[1];assign rsp_tag=control_q[4:2];
 always_comb begin
  control_next=control_q;
  if(control_enable)begin
   if(!rst_n)control_next=0;
   else if(req_ready)begin
    control_next[0]=req_valid;
    if(req_valid)begin control_next[1]=req_data[30:23]==255;control_next[4:2]=req_tag;end
   end
  end
 end
 always_ff@(posedge clk)if(control_enable&&rst_n&&req_ready&&req_valid)rsp_data<=divide1024(req_data);
endmodule

module laya_m007_ln_sqrt_external_v2(
 input logic clk,rst_n,control_enable,input logic[12:0]control_q,output logic[12:0]control_next,
 input logic req_valid,output logic req_ready,input logic[31:0]req_data,input logic[1:0]req_tag,
 output logic rsp_valid,input logic rsp_ready,output logic[31:0]rsp_data,output logic rsp_error,
 output logic[1:0]rsp_tag,output logic busy
);
 logic[47:0]radicand;logic[49:0]remainder;logic[23:0]root;
 logic signed[10:0]result_exponent;logic work_zero,work_sign;
 wire[4:0]step=control_q[9:5];wire[1:0]work_tag=control_q[11:10];wire work_error=control_q[12];
 logic[23:0]mantissa;logic[24:0]parity_mantissa;logic signed[10:0]unbiased;
 logic[4:0]leading;logic[49:0]next_remainder,trial;logic[23:0]next_root;logic[24:0]rounded_root;
 logic[8:0]packed_exp;logic[22:0]packed_frac;
 function automatic logic[4:0]lzc24(input logic[23:0]value);
  logic found;logic[4:0]count;
  begin found=0;count=0;for(int i=23;i>=0;i--)if(!found)begin if(value[i])found=1;else count=count+1'b1;end lzc24=count;end
 endfunction
 assign busy=control_enable&&control_q[0];assign rsp_valid=control_enable&&control_q[1];
 assign rsp_error=control_q[2];assign rsp_tag=control_q[4:3];
 assign req_ready=control_enable&&rst_n&&!busy&&(!rsp_valid||rsp_ready);
 always_comb begin
  mantissa={req_data[30:23]!=0,req_data[22:0]};leading=lzc24(mantissa);
  unbiased=req_data[30:23]==0?-11'sd126-$signed({6'b0,leading}):$signed({3'b0,req_data[30:23]})-11'sd127;
  if(req_data[30:23]==0)mantissa=mantissa<<leading;
  parity_mantissa={1'b0,mantissa};if(unbiased[0])parity_mantissa=parity_mantissa<<1;
  next_remainder=(remainder<<2)|{48'b0,radicand[47:46]};trial=({26'b0,root}<<2)|50'b1;
  next_root=root<<1;
  if(next_remainder>=trial)begin next_remainder=next_remainder-trial;next_root=next_root|24'b1;end
  rounded_root={1'b0,next_root}+(next_remainder>{26'b0,next_root});
  packed_exp=9'(result_exponent);packed_frac=rounded_root[22:0];
  if(rounded_root[24])begin packed_exp=9'(result_exponent+1'b1);packed_frac=rounded_root[23:1];end
 end
 always_comb begin
  control_next=control_q;
  if(control_enable)begin
   if(!rst_n)control_next=0;
   else begin
    if(rsp_valid&&rsp_ready)control_next[1]=0;
    if(req_valid&&req_ready)begin
     control_next[0]=1;control_next[9:5]=0;control_next[11:10]=req_tag;
     control_next[12]=req_data[30:23]==255||(req_data[31]&&req_data[30:0]!=0);
    end else if(busy)begin
     if(step==23)begin
      control_next[0]=0;control_next[1]=1;control_next[4:3]=work_tag;control_next[2]=work_error;
     end else control_next[9:5]=step+1'b1;
    end
   end
  end
 end
 always_ff@(posedge clk)if(control_enable&&rst_n)begin
  if(req_valid&&req_ready)begin
   radicand<={parity_mantissa,23'b0};remainder<=0;root<=0;
   work_zero<=req_data[30:0]==0;work_sign<=req_data[31];
   result_exponent<=((unbiased-$signed({10'b0,unbiased[0]}))>>>1)+11'sd127;
  end else if(busy)begin
   radicand<=radicand<<2;remainder<=next_remainder;root<=next_root;
   if(step==23)begin
    if(work_error)rsp_data<=32'h7fc00000;
    else if(work_zero)rsp_data<={work_sign,31'b0};
    else rsp_data<={1'b0,packed_exp[7:0],packed_frac};
   end
  end
 end
endmodule
