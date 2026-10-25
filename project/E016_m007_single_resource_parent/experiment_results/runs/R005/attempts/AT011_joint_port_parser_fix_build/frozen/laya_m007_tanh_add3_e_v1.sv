`timescale 1ns/1ps
// Exact add3: keep the full significand compare out of alignment selection.
// Finite F32 operands are integer multiples of2^-149: a nonzero exact sum
// cannot round to zero. For large alignment gaps magnitudes cannot cancel;
// for cancellation-sized gaps (0/1 exponent) the extended alignment is exact.
module laya_m007_tanh_add3_e_v1(
 input logic aclk,aclken,aresetn,s_axis_a_tvalid,s_axis_b_tvalid,
 input logic [31:0] s_axis_a_tdata,s_axis_b_tdata,
 output logic m_axis_result_tvalid,output logic [31:0] m_axis_result_tdata
);
 import laya_m007_tanh_fast_pkg::*;
 logic [2:0] valid;logic [26:0] big1,small1,normalized;logic [27:0] sum2,exact_sum;
 logic [8:0] exp1,exp2,normalized_exp;logic [4:0] leading2,shift;
 logic sign1,sign2,sub1,nz1,nz2,zero2,overflow2,special1,special2;logic [31:0] sp1,sp2;
 logic [31:0] a,b;logic [7:0] ae,be,max_exp,exp_gap;
 logic [26:0] af,bf,large_mag,small_mag,aligned_small;
 logic a_exp_larger,equal_exp,a_mag_larger,large_sign;
 logic [24:0] rounded;logic [8:0] packed_exp;logic [22:0] packed_frac;
 logic [31:0] nonzero_result;
 always_comb begin
  a=s_axis_a_tdata;b=s_axis_b_tdata;
  ae=a[30:23]==0 ? 8'd1 : a[30:23];be=b[30:23]==0 ? 8'd1 : b[30:23];
  af={a[30:23]!=0,a[22:0],3'b0};bf={b[30:23]!=0,b[22:0],3'b0};
  a_exp_larger=ae>be;equal_exp=ae==be;a_mag_larger=af>=bf;
  max_exp=a_exp_larger?ae:be;exp_gap=a_exp_larger?ae-be:be-ae;
  // If effective exponents differ, only the exponent order chooses the
  // aligned operand. If equal (including subnormal/exp1), the shift is zero
  // and the full significand order selects direct operands after alignment.
  aligned_small=jam27(a_exp_larger?bf:af,{3'b0,exp_gap});
  if(equal_exp)begin large_mag=a_mag_larger?af:bf;small_mag=a_mag_larger?bf:af;large_sign=a_mag_larger?a[31]:b[31];end
  else begin large_mag=a_exp_larger?af:bf;small_mag=aligned_small;large_sign=a_exp_larger?a[31]:b[31];end
  exact_sum=sub1?{1'b0,big1}-{1'b0,small1}:{1'b0,big1}+{1'b0,small1};
  shift={4'b0,leading2}>=exp2 ? 5'(exp2-1'b1) : leading2;
  if(sum2[27])begin normalized={sum2[27:2],|sum2[1:0]};normalized_exp=exp2+1'b1;end
  else begin normalized=sum2[26:0]<<shift;normalized_exp=exp2-{4'b0,shift};end
  rounded={1'b0,normalized[26:3]}+(normalized[2]&&(|normalized[1:0]||normalized[3]));
  packed_exp=normalized_exp;packed_frac=rounded[22:0];
  if(rounded[24])begin packed_exp=normalized_exp+1'b1;packed_frac=rounded[23:1];end
  else if(normalized_exp==1&&!rounded[23])packed_exp=0;
  nonzero_result=overflow2 ? {sign2,8'hff,23'b0} : {sign2,packed_exp[7:0],packed_frac};
 end
 always_ff @(posedge aclk)begin
  if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end
  else if(aclken)begin
   valid<={valid[1:0],s_axis_a_tvalid&&s_axis_b_tvalid};
   big1<=large_mag;small1<=small_mag;
   exp1<={1'b0,max_exp};sign1<=large_sign;sub1<=a[31]^b[31];nz1<=a[31]&&b[31];
   special1<=(&a[30:23])||(&b[30:23]);
   if(((&a[30:23])&&|a[22:0])||((&b[30:23])&&|b[22:0])||
      ((&a[30:23])&&(&b[30:23])&&a[31]!=b[31]))sp1<=32'h7fc00000;
   else sp1<=(&a[30:23])?a:b;
   sum2<=exact_sum;leading2<=lzc(exact_sum[26:0]);exp2<=exp1;zero2<=exact_sum==0;
   // For finite operands exp1<=254. exact_sum is an unsigned magnitude
   // in retained-bit units2^(exp1-127-26), with bit0 carrying jam-sticky
   // when alignment discarded data; sign1 is separate. At exp1=254
   // the RNE overflow threshold2^128-2^103 is exact_sum>=2^27-4.
   // Bit27 or all bits26:3 plus guard2 encode precisely that threshold;
   // bits1:0 are irrelevant because the retained max significand is odd.
   // Smaller exponents cannot overflow from two finite F32 operands.
   // Cancellation has no bit26, so cannot satisfy the latter condition;
   // zero2/nz2 preserve signed-zero. special2/sp2 bypass nonfinite operands.
   overflow2<=exp1==254&&(exact_sum[27]||((&exact_sum[26:3])&&exact_sum[2]));
   sign2<=sign1;nz2<=nz1;special2<=special1;sp2<=sp1;
   m_axis_result_tdata<=special2?sp2:(zero2?{nz2,31'b0}:nonzero_result);
  end
 end
 assign m_axis_result_tvalid=valid[2];
endmodule
