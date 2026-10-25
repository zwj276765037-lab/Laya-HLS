`timescale 1ns/1ps
// Direct binary32 division, RNE with gradual underflow. No reciprocal/multiply.
// 32 enabled-edge stages, II1: decode, normalize, setup, 26 quotient bits,
// subnormal alignment, sole RNE, pack. Finite nonzero denominator domain.
module laya_fdiv_rne_v1(
 input logic aclk,aclken,aresetn,
 input logic s_axis_a_tvalid,s_axis_b_tvalid,
 input logic [31:0] s_axis_a_tdata,s_axis_b_tdata,
 output logic m_axis_result_tvalid,
 output logic [31:0] m_axis_result_tdata
);
 logic [31:0] valid;
 logic [23:0] ma1,mb1,ma2,mb2;
 logic [7:0] ea1,eb1;
 logic sign1,sign2,special1,special2;
 logic [31:0] special_bits1,special_bits2;
 logic signed [10:0] ea2,eb2;
 logic [24:0] remainder_p[0:26];
 logic [23:0] denominator_p[0:26];
 logic [26:0] quotient_p[0:26];
 logic signed [10:0] exponent_p[0:26];
 logic [26:0] sign_p,special_p;
 logic [31:0] special_bits_p[0:26];
 logic [26:0] aligned30;
 logic signed [10:0] exponent30;
 logic sign30,special30,sign31,special31;
 logic [31:0] special_bits30,special_bits31;
 logic [24:0] rounded31;
 logic [8:0] exponent31;
 logic [26:0] exact27;
 logic [8:0] pack_exp31;
 logic [22:0] pack_frac31;
 function automatic [4:0] lzc24(input logic [23:0] x);
  logic [31:0] t;logic [4:0] n;
  begin
   t={x,8'b0};n=0;
   if(t[31:16]==0)begin t=t<<16;n=n+16;end
   if(t[31:24]==0)begin t=t<<8;n=n+8;end
   if(t[31:28]==0)begin t=t<<4;n=n+4;end
   if(t[31:30]==0)begin t=t<<2;n=n+2;end
   if(t[31]==0)n=n+1;
   lzc24=n;
  end
 endfunction
 function automatic [26:0] shr_jam27(input logic [26:0] x,input logic [10:0] n);
  logic [26:0] mask;
  begin
   if(n==0)shr_jam27=x;
   else if(n>=27)shr_jam27={26'b0,|x};
   else begin mask=~(27'h7ffffff<<n);shr_jam27=(x>>n)|{26'b0,|(x&mask)};end
  end
 endfunction
 always_comb begin
  exact27=quotient_p[26]|{26'b0,|remainder_p[26]};
  pack_exp31=exponent31;pack_frac31=rounded31[22:0];
  if(rounded31[24])begin pack_exp31=exponent31+1'b1;pack_frac31=rounded31[23:1];end
  else if(exponent31==1&&!rounded31[23])pack_exp31=0;
 end
 always_ff @(posedge aclk)begin
  if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end
  else if(aclken)begin
   valid<={valid[30:0],s_axis_a_tvalid&&s_axis_b_tvalid};
   // 1: Decode. Zero/nonfinite exceptional results remain visible to callers.
   ma1<={s_axis_a_tdata[30:23]!=0,s_axis_a_tdata[22:0]};
   mb1<={s_axis_b_tdata[30:23]!=0,s_axis_b_tdata[22:0]};
   ea1<=s_axis_a_tdata[30:23]==0?8'd1:s_axis_a_tdata[30:23];
   eb1<=s_axis_b_tdata[30:23]==0?8'd1:s_axis_b_tdata[30:23];
   sign1<=s_axis_a_tdata[31]^s_axis_b_tdata[31];
   special1<=s_axis_a_tdata[30:0]==0||s_axis_b_tdata[30:0]==0||
             (&s_axis_a_tdata[30:23])||(&s_axis_b_tdata[30:23]);
   if(((&s_axis_a_tdata[30:23])&&|s_axis_a_tdata[22:0])||
      ((&s_axis_b_tdata[30:23])&&|s_axis_b_tdata[22:0])||
      ((&s_axis_a_tdata[30:23])&&(&s_axis_b_tdata[30:23]))||
      (s_axis_a_tdata[30:0]==0&&s_axis_b_tdata[30:0]==0))
     special_bits1<=32'h7fc00000;
   else if((&s_axis_a_tdata[30:23])||s_axis_b_tdata[30:0]==0)
     special_bits1<={s_axis_a_tdata[31]^s_axis_b_tdata[31],8'hff,23'b0};
   else special_bits1<={s_axis_a_tdata[31]^s_axis_b_tdata[31],31'b0};
   // 2: Normalize both finite significands exactly, including subnormals.
   ma2<=ma1<<lzc24(ma1);mb2<=mb1<<lzc24(mb1);
   ea2<=$signed({3'b0,ea1})-11'sd127-$signed({6'b0,lzc24(ma1)});
   eb2<=$signed({3'b0,eb1})-11'sd127-$signed({6'b0,lzc24(mb1)});
   sign2<=sign1;special2<=special1;special_bits2<=special_bits1;
   // 3: Ratio is normalized to [1,2), initial quotient bit is exactly one.
   denominator_p[0]<=mb2;quotient_p[0]<=27'd1;
   if(ma2<mb2)begin
    remainder_p[0]<={ma2,1'b0}-{1'b0,mb2};exponent_p[0]<=ea2-eb2-1'b1;
   end else begin
    remainder_p[0]<={1'b0,ma2}-{1'b0,mb2};exponent_p[0]<=ea2-eb2;
   end
   sign_p[0]<=sign2;special_p[0]<=special2;special_bits_p[0]<=special_bits2;
   // 30: Exact quotient remainder is reduced to guard/round/sticky once.
   if(exponent_p[26]<-11'sd126)begin
    aligned30<=shr_jam27(exact27,-11'sd126-exponent_p[26]);exponent30<=-11'sd126;
   end else begin aligned30<=exact27;exponent30<=exponent_p[26];end
   sign30<=sign_p[26];special30<=special_p[26];special_bits30<=special_bits_p[26];
   // 31: The only rounding operation, nearest/even after underflow alignment.
   rounded31<={1'b0,aligned30[26:3]}+(aligned30[2]&&(|aligned30[1:0]||aligned30[3]));
   exponent31<=9'(exponent30+11'sd127);
   sign31<=sign30;special31<=special30;special_bits31<=special_bits30;
   // 32: Pack; underflow preserves sign, overflow is infinity for Check.
   if(special31)m_axis_result_tdata<=special_bits31;
   else if(rounded31==0)m_axis_result_tdata<={sign31,31'b0};
   else if(pack_exp31>=255)m_axis_result_tdata<={sign31,8'hff,23'b0};
   else m_axis_result_tdata<={sign31,pack_exp31[7:0],pack_frac31};
  end
 end
 for(genvar i=0;i<26;i++)begin:quotient_bit
  wire [24:0] twice={remainder_p[i][23:0],1'b0};
  wire take_bit=twice>={1'b0,denominator_p[i]};
  always_ff @(posedge aclk)if(aresetn&&aclken)begin
   remainder_p[i+1]<=take_bit?twice-{1'b0,denominator_p[i]}:twice;
   quotient_p[i+1]<={quotient_p[i][25:0],take_bit};
   denominator_p[i+1]<=denominator_p[i];exponent_p[i+1]<=exponent_p[i];
   sign_p[i+1]<=sign_p[i];special_p[i+1]<=special_p[i];special_bits_p[i+1]<=special_bits_p[i];
  end
 end
 assign m_axis_result_tvalid=valid[31];
endmodule
