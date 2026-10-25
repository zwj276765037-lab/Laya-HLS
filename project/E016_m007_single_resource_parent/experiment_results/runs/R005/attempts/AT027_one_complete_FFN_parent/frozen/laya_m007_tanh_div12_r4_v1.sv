`timescale 1ns/1ps
// Exact radix-4 direct division. Each digit selects an exact candidate remainder.
// Internal TANH only, 12 enabled edges / II1; no reciprocal and one final RNE.
module laya_m007_tanh_div12_r4_v1(
 input logic aclk,aclken,aresetn,s_axis_a_tvalid,s_axis_b_tvalid,
 input logic [31:0] s_axis_a_tdata,s_axis_b_tdata,
 output logic m_axis_result_tvalid,output logic [31:0] m_axis_result_tdata
);
 import laya_m007_tanh_fast_pkg::*;
 logic [11:0] valid;logic [31:0] a,b,sp1;
 logic [23:0] ma,mb,ma1,mb1;logic [4:0] la,lb;
 logic signed [10:0] ea,eb,exp1;logic sign1,special1;
 logic [24:0] rem_p[0:8];logic [23:0] den_p[0:8];logic [25:0] den3_p[0:8];
 logic [26:0] quo_p[0:8];logic signed [10:0] exp_p[0:8];
 logic [8:0] sign_p,special_p;logic [31:0] sp_p[0:8];
 logic [26:0] exact,aligned11;logic [8:0] exp11;
 logic sign11,special11;logic [31:0] sp11;
 // r<D, so 4*r<4*D. D,2D,3D and candidate differences require26 bits.
 function automatic [25:0] digit2(input logic [24:0] r,input logic [23:0] d,input logic [25:0] d3);
  logic [25:0] scaled,c1,c2,c3,chosen;logic [1:0] digit;
  begin
   scaled={r[23:0],2'b0};c1=scaled-{2'b0,d};c2=scaled-{1'b0,d,1'b0};c3=scaled-d3;
   if(scaled>=d3)begin digit=3;chosen=c3;end
   else if(scaled>={1'b0,d,1'b0})begin digit=2;chosen=c2;end
   else if(scaled>={2'b0,d})begin digit=1;chosen=c1;end
   else begin digit=0;chosen=scaled;end
   digit2={digit,chosen[23:0]};
  end
 endfunction
 always_comb begin
  a=s_axis_a_tdata;b=s_axis_b_tdata;
  ma={a[30:23]!=0,a[22:0]};mb={b[30:23]!=0,b[22:0]};
  la=lzc({ma,3'b0});lb=lzc({mb,3'b0});
  ea=$signed({3'b0,(a[30:23]==0 ? 8'd1 : a[30:23])})-11'sd127-$signed({6'b0,la});
  eb=$signed({3'b0,(b[30:23]==0 ? 8'd1 : b[30:23])})-11'sd127-$signed({6'b0,lb});
  exact=quo_p[8]|{26'b0,|rem_p[8]};
 end
 always_ff @(posedge aclk)begin
  if(!aresetn)begin valid<=0;m_axis_result_tdata<=0;end
  else if(aclken)begin
   valid<={valid[10:0],s_axis_a_tvalid&&s_axis_b_tvalid};
   ma1<=ma<<la;mb1<=mb<<lb;exp1<=ea-eb;sign1<=a[31]^b[31];
   special1<=a[30:0]==0||b[30:0]==0||(&a[30:23])||(&b[30:23]);
   if(((&a[30:23])&&|a[22:0])||((&b[30:23])&&|b[22:0])||
      ((&a[30:23])&&(&b[30:23]))||(a[30:0]==0&&b[30:0]==0))sp1<=32'h7fc00000;
   else if((&a[30:23])||b[30:0]==0)sp1<={a[31]^b[31],8'hff,23'b0};
   else sp1<={a[31]^b[31],31'b0};
   den_p[0]<=mb1;den3_p[0]<={2'b0,mb1}+{1'b0,mb1,1'b0};quo_p[0]<=27'd1;
   exp_p[0]<=exp1-(ma1<mb1 ? 11'sd1 : 11'sd0);
   rem_p[0]<=ma1<mb1 ? {ma1,1'b0}-{1'b0,mb1} : {1'b0,ma1}-{1'b0,mb1};
   sign_p[0]<=sign1;special_p[0]<=special1;sp_p[0]<=sp1;
   // Exact remainder becomes sticky only after all26 quotient bits.
   aligned11<=exp_p[8] < -11'sd126 ? jam27(exact,-11'sd126-exp_p[8]) : exact;
   exp11<=exp_p[8] < -11'sd126 ? 9'd1 : 9'(exp_p[8]+11'sd127);
   sign11<=sign_p[8];special11<=special_p[8];sp11<=sp_p[8];
   m_axis_result_tdata<=special11?sp11:pack_rne(aligned11,exp11,sign11,sign11);
  end
 end
 for(genvar stage=0;stage<8;stage++)begin:quotient_group
  wire [25:0] first=digit2(rem_p[stage],den_p[stage],den3_p[stage]);
  wire [26:0] qfirst={quo_p[stage][24:0],first[25:24]};
  wire [24:0] rem_next;wire [26:0] quo_next;
  if(stage<2)begin:four_bits
   wire [25:0] second=digit2({1'b0,first[23:0]},den_p[stage],den3_p[stage]);
   assign rem_next={1'b0,second[23:0]};assign quo_next={qfirst[24:0],second[25:24]};
  end else begin:three_bits
   wire [24:0] twice={first[23:0],1'b0};wire take=twice>={1'b0,den_p[stage]};
   assign rem_next=take?twice-{1'b0,den_p[stage]}:twice;assign quo_next={qfirst[25:0],take};
  end
  always_ff @(posedge aclk)if(aresetn&&aclken)begin
   rem_p[stage+1]<=rem_next;quo_p[stage+1]<=quo_next;den_p[stage+1]<=den_p[stage];den3_p[stage+1]<=den3_p[stage];
   exp_p[stage+1]<=exp_p[stage];sign_p[stage+1]<=sign_p[stage];special_p[stage+1]<=special_p[stage];sp_p[stage+1]<=sp_p[stage];
  end
 end
 assign m_axis_result_tvalid=valid[11];
endmodule
