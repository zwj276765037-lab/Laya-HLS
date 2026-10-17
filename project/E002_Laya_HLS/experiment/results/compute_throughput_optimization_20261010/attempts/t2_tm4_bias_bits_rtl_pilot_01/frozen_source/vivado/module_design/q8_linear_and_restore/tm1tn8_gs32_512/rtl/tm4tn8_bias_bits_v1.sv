`timescale 1ns/1ps
package tm4tn8_bias_bits_v1;
  function automatic logic finite(input logic [31:0] x);
    return x[30:23]!=255;
  endfunction
  function automatic logic helper_route(input logic [31:0] a,input logic [31:0] b);
    return a[30:23]==0 || b[30:23]==0 ||
      (a[30:23]<25 && b[30:23]<25);
  endfunction
  function automatic logic [27:0] right_jam(input logic [27:0] x,input integer count);
    if(count==0) return x;
    if(count>=28) return {27'd0,|x};
    return (x>>count) | 28'((x & ((28'd1<<count)-1))!=0);
  endfunction
  // Exact finite binary32 RNE addition. Three guard/round/sticky bits
  // preserve alignment; cancellation is normalized before one rounding.
  function automatic logic [31:0] add_finite_rne(input logic [31:0] x,input logic [31:0] y);
    logic [31:0] large,small;
    logic [23:0] lm,sm;
    logic [27:0] le,se,sum;
    logic [24:0] rounded;
    logic sign,increment;
    integer exponent,small_exponent,difference;
    large=x[30:0]>=y[30:0] ? x : y;
    small=x[30:0]>=y[30:0] ? y : x;
    exponent=large[30:23]==0 ? 1 : int'(large[30:23]);
    small_exponent=small[30:23]==0 ? 1 : int'(small[30:23]);
    lm={large[30:23]!=0,large[22:0]};sm={small[30:23]!=0,small[22:0]};
    difference=exponent-small_exponent;le={1'b0,lm,3'b000};se=right_jam({1'b0,sm,3'b000},difference);
    sign=large[31];sum=large[31]==small[31] ? le+se : le-se;
    if(sum==0) return {x[31] & y[31],31'd0};
    if(sum[27]) begin sum=right_jam(sum,1);exponent=exponent+1;end
    else for(integer shift=0;shift<27;shift++) begin
      if(!sum[26] && exponent>1) begin sum=sum<<1;exponent=exponent-1;end
    end
    increment=sum[2] && (sum[1] || sum[0] || sum[3]);
    rounded={1'b0,sum[26:3]}+25'(increment);
    if(rounded[24]) begin rounded=rounded>>1;exponent=exponent+1;end
    if(exponent>=255) return {sign,8'hff,23'd0};
    if(exponent==1 && !rounded[23]) return {sign,8'd0,rounded[22:0]};
    return {sign,8'(exponent),rounded[22:0]};
  endfunction
endpackage

module tm4tn8_bias_bank_v1 (
  input logic clk,we,re,
  input logic [9:0] waddr,raddr,
  input logic [31:0] wdata,
  output logic [31:0] rdata
);
  (* ram_style = "block" *) logic [31:0] memory[0:655];
  always_ff @(posedge clk) begin
    if(we) memory[waddr]<=wdata;
    if(re) rdata<=memory[raddr];
  end
endmodule
