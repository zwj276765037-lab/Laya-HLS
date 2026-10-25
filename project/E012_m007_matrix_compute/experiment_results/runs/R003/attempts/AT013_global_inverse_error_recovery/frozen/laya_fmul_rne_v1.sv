`timescale 1ns/1ps
// Exact finite binary32 multiplication, single RNE and gradual underflow.
// Eight enabled-edge stages, II1. No rounding precedes target-format alignment.
module laya_fmul_rne_v1(
 input logic aclk,aclken,aresetn,
 input logic s_axis_a_tvalid,s_axis_b_tvalid,
 input logic [31:0] s_axis_a_tdata,s_axis_b_tdata,
 output logic m_axis_result_tvalid,
 output logic [31:0] m_axis_result_tdata
);
 logic [7:0] valid;
 logic [23:0] ma1,mb1,ma2,mb2;
 logic [7:0] ea1,eb1;
 logic signed [10:0] ea2,eb2,exponent3,normal_exp3;
 logic [47:0] product3,product4;
 logic [8:0] shift4,exponent4,exponent5,exponent6;
 logic [26:0] aligned5;
 logic [24:0] rounded6;
 logic [8:0] pack_exp6;
 logic [22:0] pack_frac6;
 logic [31:0] packed7;
 logic sign1,sign2,sign3,sign4,sign5,sign6;
 logic special1,special2,special3,special4,special5,special6;
 logic [31:0] special_bits1,special_bits2,special_bits3;
 logic [31:0] special_bits4,special_bits5,special_bits6;
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
 function automatic [26:0] shift_jam48(input logic [47:0] x,input logic [8:0] n);
  logic [47:0] shifted,mask;
  begin
   if(n>=48)shift_jam48={26'b0,|x};
   else begin
    shifted=x>>n;mask=~(48'hffffffffffff<<n);
    shift_jam48=shifted[26:0]|{26'b0,|(x&mask)};
   end
  end
 endfunction
 always_comb begin
  normal_exp3=exponent3+$signed({10'b0,product3[47]});
  pack_exp6=exponent6;pack_frac6=rounded6[22:0];
  if(rounded6[24])begin pack_exp6=exponent6+1'b1;pack_frac6=rounded6[23:1];end
  else if(exponent6==1&&!rounded6[23])pack_exp6=0;
 end
 always_ff @(posedge aclk)begin
  if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end
  else if(aclken)begin
   valid<={valid[6:0],s_axis_a_tvalid&&s_axis_b_tvalid};
   // 1: Decode; preserve signed-zero and expose exceptions to caller Check.
   ma1<={s_axis_a_tdata[30:23]!=0,s_axis_a_tdata[22:0]};
   mb1<={s_axis_b_tdata[30:23]!=0,s_axis_b_tdata[22:0]};
   ea1<=s_axis_a_tdata[30:23]==0?8'd1:s_axis_a_tdata[30:23];
   eb1<=s_axis_b_tdata[30:23]==0?8'd1:s_axis_b_tdata[30:23];
   sign1<=s_axis_a_tdata[31]^s_axis_b_tdata[31];
   special1<=s_axis_a_tdata[30:0]==0||s_axis_b_tdata[30:0]==0||
             (&s_axis_a_tdata[30:23])||(&s_axis_b_tdata[30:23]);
   if(((&s_axis_a_tdata[30:23])&&|s_axis_a_tdata[22:0])||
      ((&s_axis_b_tdata[30:23])&&|s_axis_b_tdata[22:0])||
      ((&s_axis_a_tdata[30:23])&&s_axis_b_tdata[30:0]==0)||
      ((&s_axis_b_tdata[30:23])&&s_axis_a_tdata[30:0]==0))special_bits1<=32'h7fc00000;
   else if((&s_axis_a_tdata[30:23])||(&s_axis_b_tdata[30:23]))
    special_bits1<={s_axis_a_tdata[31]^s_axis_b_tdata[31],8'hff,23'b0};
   else special_bits1<={s_axis_a_tdata[31]^s_axis_b_tdata[31],31'b0};
   // 2: Exact normalized 24-bit integer significands, unbiased signed exponents.
   ma2<=ma1<<lzc24(ma1);mb2<=mb1<<lzc24(mb1);
   ea2<=$signed({3'b0,ea1})-11'sd127-$signed({6'b0,lzc24(ma1)});
   eb2<=$signed({3'b0,eb1})-11'sd127-$signed({6'b0,lzc24(mb1)});
   sign2<=sign1;special2<=special1;special_bits2<=special_bits1;
   // 3: Full exact product. All 48 bits survive to target-format alignment.
   product3<=ma2*mb2;exponent3<=ea2+eb2;
   sign3<=sign2;special3<=special2;special_bits3<=special_bits2;
   // 4: Select normal/subnormal precision before any rounding.
   product4<=product3;
   if(normal_exp3<-11'sd126)begin
    shift4<=9'(11'sd20+$signed({10'b0,product3[47]})-11'sd126-normal_exp3);
    exponent4<=1;
   end else begin
    shift4<=product3[47]?9'd21:9'd20;
    exponent4<=9'(normal_exp3+11'sd127);
   end
   sign4<=sign3;special4<=special3;special_bits4<=special_bits3;
   // 5: One right shift from full product to final target GRS precision.
   aligned5<=shift_jam48(product4,shift4);exponent5<=exponent4;
   sign5<=sign4;special5<=special4;special_bits5<=special_bits4;
   // 6: The sole RNE, after underflow alignment; no double rounding.
   rounded6<={1'b0,aligned5[26:3]}+(aligned5[2]&&(|aligned5[1:0]||aligned5[3]));
   exponent6<=exponent5;sign6<=sign5;special6<=special5;special_bits6<=special_bits5;
   // 7: Round carry, normal/subnormal boundary, overflow and signed zero.
   if(special6)packed7<=special_bits6;
   else if(rounded6==0)packed7<={sign6,31'b0};
   else if(pack_exp6>=255)packed7<={sign6,8'hff,23'b0};
   else packed7<={sign6,pack_exp6[7:0],pack_frac6};
   // 8: Output timing register. CE holds every stage and valid together.
   m_axis_result_tdata<=packed7;
  end
 end
 assign m_axis_result_tvalid=valid[7];
endmodule
