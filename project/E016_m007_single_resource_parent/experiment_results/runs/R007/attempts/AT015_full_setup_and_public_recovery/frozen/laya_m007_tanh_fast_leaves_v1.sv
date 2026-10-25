`timescale 1ns/1ps
// Internal TANH arithmetic only. Shared FP/DIV services remain unchanged.
package laya_m007_tanh_fast_pkg;
 function automatic [4:0] lzc(input logic [26:0] x);
  logic [31:0] t;logic [4:0] n;
  begin t={x,5'b0};n=0;
   if(t[31:16]==0)begin t=t<<16;n=n+16;end
   if(t[31:24]==0)begin t=t<<8;n=n+8;end
   if(t[31:28]==0)begin t=t<<4;n=n+4;end
   if(t[31:30]==0)begin t=t<<2;n=n+2;end
   if(t[31]==0)n=n+1;lzc=n;
  end
 endfunction
 function automatic [26:0] jam27(input logic [26:0] x,input logic [10:0] n);
  logic [26:0] mask;
  begin
   if(n==0)jam27=x;
   else if(n>=27)jam27={26'b0,|x};
   else begin mask=~(27'h7ffffff<<n);jam27=(x>>n)|{26'b0,|(x&mask)};end
  end
 endfunction
 function automatic [26:0] jam48(input logic [47:0] x,input logic [8:0] n);
  logic [47:0] mask,z;
  begin
   if(n>=48)jam48={26'b0,|x};
   else begin mask=~(48'hffffffffffff<<n);z=x>>n;jam48=z[26:0]|{26'b0,|(x&mask)};end
  end
 endfunction
 function automatic [31:0] pack_rne(input logic [26:0] x,input logic [8:0] exp,
                                   input logic sign,input logic negative_zero);
  logic [24:0] r;logic [8:0] e;logic [22:0] f;
  begin
   r={1'b0,x[26:3]}+(x[2]&&(|x[1:0]||x[3]));e=exp;f=r[22:0];
   if(r[24])begin e=exp+1'b1;f=r[23:1];end
   else if(exp==1&&!r[23])e=0;
   if(r==0)pack_rne={negative_zero,31'b0};
   else if(e>=255)pack_rne={sign,8'hff,23'b0};
   else pack_rne={sign,e[7:0],f};
  end
 endfunction
endpackage

module laya_m007_tanh_add3_v1(
 input logic aclk,aclken,aresetn,s_axis_a_tvalid,s_axis_b_tvalid,
 input logic [31:0] s_axis_a_tdata,s_axis_b_tdata,
 output logic m_axis_result_tvalid,output logic [31:0] m_axis_result_tdata
);
 import laya_m007_tanh_fast_pkg::*;
 logic [2:0] valid;
 logic [26:0] big1,small1,normalized;
 logic [27:0] sum2;
 logic [8:0] exp1,exp2,normalized_exp;
 logic sign1,sign2,sub1,nz1,nz2,special1,special2;
 logic [31:0] sp1,sp2;
 logic [31:0] a,b,big,smaller;
 logic [7:0] be,se;
 logic [27:0] exact_sum;
 logic [4:0] leading2,shift;
 always_comb begin
  a=s_axis_a_tdata;b=s_axis_b_tdata;
  big=a[30:0]>=b[30:0]?a:b;smaller=a[30:0]>=b[30:0]?b:a;
  be=big[30:23]==0 ? 8'd1 : big[30:23];se=smaller[30:23]==0 ? 8'd1 : smaller[30:23];
  exact_sum=sub1?{1'b0,big1}-{1'b0,small1}:{1'b0,big1}+{1'b0,small1};
  shift={4'b0,leading2}>=exp2 ? 5'(exp2-1'b1) : leading2;
  if(sum2[27])begin normalized={sum2[27:2],|sum2[1:0]};normalized_exp=exp2+1'b1;end
  else begin normalized=sum2[26:0]<<shift;normalized_exp=exp2-{4'b0,shift};end
 end
 always_ff @(posedge aclk)begin
  if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end
  else if(aclken)begin
   valid<={valid[1:0],s_axis_a_tvalid&&s_axis_b_tvalid};
   // 1: Magnitude compare, decode and full sticky alignment.
   big1<={big[30:23]!=0,big[22:0],3'b0};
   small1<=jam27({smaller[30:23]!=0,smaller[22:0],3'b0},{3'b0,be-se});
   exp1<={1'b0,be};sign1<=big[31];sub1<=a[31]^b[31];nz1<=a[31]&&b[31];
   special1<=(&a[30:23])||(&b[30:23]);
   if(((&a[30:23])&&|a[22:0])||((&b[30:23])&&|b[22:0])||
      ((&a[30:23])&&(&b[30:23])&&a[31]!=b[31]))sp1<=32'h7fc00000;
   else sp1<=(&a[30:23])?a:b;
   // 2: Exact add/subtract and leading-zero tree, before cap/shift fanout.
   sum2<=exact_sum;leading2<=lzc(exact_sum[26:0]);exp2<=exp1;
   sign2<=sign1;nz2<=nz1;special2<=special1;sp2<=sp1;
   // 3: Gradual-underflow cap/normalization, sole RNE and pack.
   m_axis_result_tdata<=special2?sp2:pack_rne(normalized,normalized_exp,sign2,nz2);
  end
 end
 assign m_axis_result_tvalid=valid[2];
endmodule

module laya_m007_tanh_mul4_v1(
 input logic aclk,aclken,aresetn,s_axis_a_tvalid,s_axis_b_tvalid,
 input logic [31:0] s_axis_a_tdata,s_axis_b_tdata,
 output logic m_axis_result_tvalid,output logic [31:0] m_axis_result_tdata
);
 import laya_m007_tanh_fast_pkg::*;
 logic [3:0] valid;
 logic [23:0] ma,mb,ma1,mb1;
 logic [4:0] la,lb;
 logic signed [10:0] ea,eb,exp1,exp2,normal_exp;
 logic [47:0] product2;
 logic [26:0] aligned3;
 logic [8:0] shift,exp3;
 logic sign1,sign2,sign3,special1,special2,special3;
 logic [31:0] a,b,sp1,sp2,sp3;
 always_comb begin
  a=s_axis_a_tdata;b=s_axis_b_tdata;
  ma={a[30:23]!=0,a[22:0]};mb={b[30:23]!=0,b[22:0]};
  la=lzc({ma,3'b0});lb=lzc({mb,3'b0});
  ea=$signed({3'b0,(a[30:23]==0?8'd1:a[30:23])})-11'sd127-$signed({6'b0,la});
  eb=$signed({3'b0,(b[30:23]==0?8'd1:b[30:23])})-11'sd127-$signed({6'b0,lb});
  normal_exp=exp2+$signed({10'b0,product2[47]});
  shift=normal_exp < -11'sd126 ? 9'(11'sd20+$signed({10'b0,product2[47]})-11'sd126-normal_exp) :
        (product2[47] ? 9'd21 : 9'd20);
 end
 always_ff @(posedge aclk)begin
  if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end
  else if(aclken)begin
   valid<={valid[2:0],s_axis_a_tvalid&&s_axis_b_tvalid};
   // 1: Exact normal/subnormal decode and normalization.
   ma1<=ma<<la;mb1<=mb<<lb;exp1<=ea+eb;sign1<=a[31]^b[31];
   special1<=a[30:0]==0||b[30:0]==0||(&a[30:23])||(&b[30:23]);
   if(((&a[30:23])&&|a[22:0])||((&b[30:23])&&|b[22:0])||
      ((&a[30:23])&&b[30:0]==0)||((&b[30:23])&&a[30:0]==0))sp1<=32'h7fc00000;
   else if((&a[30:23])||(&b[30:23]))sp1<={a[31]^b[31],8'hff,23'b0};
   else sp1<={a[31]^b[31],31'b0};
   // 2: All 48 exact product bits.
   product2<=ma1*mb1;exp2<=exp1;sign2<=sign1;special2<=special1;sp2<=sp1;
   // 3: Select final normal/subnormal target precision and jam once.
   aligned3<=jam48(product2,shift);exp3<=normal_exp < -11'sd126 ? 9'd1 : 9'(normal_exp+11'sd127);
   sign3<=sign2;special3<=special2;sp3<=sp2;
   // 4: Sole RNE and pack.
   m_axis_result_tdata<=special3?sp3:pack_rne(aligned3,exp3,sign3,sign3);
  end
 end
 assign m_axis_result_tvalid=valid[3];
endmodule

module laya_m007_tanh_div12_v1(
 input logic aclk,aclken,aresetn,s_axis_a_tvalid,s_axis_b_tvalid,
 input logic [31:0] s_axis_a_tdata,s_axis_b_tdata,
 output logic m_axis_result_tvalid,output logic [31:0] m_axis_result_tdata
);
 import laya_m007_tanh_fast_pkg::*;
 logic [11:0] valid;
 logic [31:0] a,b,sp1;
 logic [23:0] ma,mb,ma1,mb1;
 logic [4:0] la,lb;
 logic signed [10:0] ea,eb,exp1;
 logic sign1,special1;
 logic [24:0] rem_p[0:8];logic [23:0] den_p[0:8];
 logic [26:0] quo_p[0:8];logic signed [10:0] exp_p[0:8];
 logic [8:0] sign_p,special_p;logic [31:0] sp_p[0:8];
 logic [26:0] exact,aligned11;logic [8:0] exp11;
 logic sign11,special11;logic [31:0] sp11;
 always_comb begin
  a=s_axis_a_tdata;b=s_axis_b_tdata;
  ma={a[30:23]!=0,a[22:0]};mb={b[30:23]!=0,b[22:0]};
  la=lzc({ma,3'b0});lb=lzc({mb,3'b0});
  ea=$signed({3'b0,(a[30:23]==0?8'd1:a[30:23])})-11'sd127-$signed({6'b0,la});
  eb=$signed({3'b0,(b[30:23]==0?8'd1:b[30:23])})-11'sd127-$signed({6'b0,lb});
  exact=quo_p[8]|{26'b0,|rem_p[8]};
 end
 always_ff @(posedge aclk)begin
  if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end
  else if(aclken)begin
   valid<={valid[10:0],s_axis_a_tvalid&&s_axis_b_tvalid};
   // 1: Exact normalization; no reciprocal or approximate table.
   ma1<=ma<<la;mb1<=mb<<lb;exp1<=ea-eb;sign1<=a[31]^b[31];
   special1<=a[30:0]==0||b[30:0]==0||(&a[30:23])||(&b[30:23]);
   if(((&a[30:23])&&|a[22:0])||((&b[30:23])&&|b[22:0])||
      ((&a[30:23])&&(&b[30:23]))||(a[30:0]==0&&b[30:0]==0))sp1<=32'h7fc00000;
   else if((&a[30:23])||b[30:0]==0)sp1<={a[31]^b[31],8'hff,23'b0};
   else sp1<={a[31]^b[31],31'b0};
   // 2: Initial exact quotient bit one, ratio in [1,2).
   den_p[0]<=mb1;quo_p[0]<=27'd1;exp_p[0]<=exp1-(ma1<mb1?11'sd1:11'sd0);
   rem_p[0]<=ma1<mb1?{ma1,1'b0}-{1'b0,mb1}:{1'b0,ma1}-{1'b0,mb1};
   sign_p[0]<=sign1;special_p[0]<=special1;sp_p[0]<=sp1;
   // 11: Exact remainder becomes sticky; align subnormal before rounding.
   aligned11<=exp_p[8] < -11'sd126 ? jam27(exact,-11'sd126-exp_p[8]) : exact;
   exp11<=exp_p[8] < -11'sd126 ? 9'd1 : 9'(exp_p[8]+11'sd127);
   sign11<=sign_p[8];special11<=special_p[8];sp11<=sp_p[8];
   // 12: Sole RNE and pack.
   m_axis_result_tdata<=special11?sp11:pack_rne(aligned11,exp11,sign11,sign11);
  end
 end
 for(genvar stage=0;stage<8;stage++)begin:quotient_group
  localparam int BITS=stage<2?4:3; // 4+4+6*3 = 26 fractional quotient bits.
  wire [24:0] r[0:BITS];wire [26:0] q[0:BITS];
  assign r[0]=rem_p[stage];assign q[0]=quo_p[stage];
  for(genvar bit_index=0;bit_index<BITS;bit_index++)begin:step
   wire [24:0] twice={r[bit_index][23:0],1'b0};
   wire take=twice>={1'b0,den_p[stage]};
   assign r[bit_index+1]=take?twice-{1'b0,den_p[stage]}:twice;
   assign q[bit_index+1]={q[bit_index][25:0],take};
  end
  always_ff @(posedge aclk)if(aresetn&&aclken)begin
   rem_p[stage+1]<=r[BITS];quo_p[stage+1]<=q[BITS];den_p[stage+1]<=den_p[stage];
   exp_p[stage+1]<=exp_p[stage];sign_p[stage+1]<=sign_p[stage];
   special_p[stage+1]<=special_p[stage];sp_p[stage+1]<=sp_p[stage];
  end
 end
 assign m_axis_result_tvalid=valid[11];
endmodule
