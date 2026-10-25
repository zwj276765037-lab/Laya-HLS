`timescale 1ns/1ps
// One physical c bank of one physical slot: 512*(256+16) bits.
// Only valid/ownership state resets in the parent; payload has no reset port.
module laya_m007_w_bank_v1(
 input logic clk,we,input logic [8:0] waddr,input logic [255:0] wq,input logic [15:0] ws,
 input logic re,input logic [8:0] raddr,output logic [255:0] rq,output logic [15:0] rs
);
 (* ram_style="ultra" *)logic [255:0] q[0:511];
 (* ram_style="block" *)logic [15:0] s[0:511];
 always_ff @(posedge clk)begin
  if(we)begin q[waddr]<=wq;s[waddr]<=ws;end
  if(re)begin rq<=q[raddr];rs<=s[raddr];end
 end
endmodule
