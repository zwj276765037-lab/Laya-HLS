`timescale 1ns/1ps

// Legal, bounded HLS-port peer for wrapper metadata testing only. It reads
// each synchronous operand port and writes every y address exactly once.
// Its constant result is not a RoPE arithmetic reference.
module rope_head (
  input wire ap_clk, ap_rst, ap_start,
  output wire ap_done, ap_idle, ap_ready,
  output wire [5:0] x_address0,
  output wire x_ce0,
  input wire [31:0] x_q0,
  output wire [5:0] cosine_address0,
  output wire cosine_ce0,
  input wire [31:0] cosine_q0,
  output wire [5:0] sine_address0,
  output wire sine_ce0,
  input wire [31:0] sine_q0,
  output wire [5:0] y_address0,
  output wire y_ce0, y_we0,
  output wire [31:0] y_d0,
  output wire [5:0] y_address1,
  output wire y_ce1, y_we1,
  output wire [31:0] y_d1,
  output wire [127:0] ap_return
);
  logic active;
  logic [4:0] index;
  always_ff @(posedge ap_clk) begin
    if(ap_rst)begin
      active<=0;index<=0;
    end else if(!active && ap_start)begin
      active<=1;index<=0;
    end else if(active)begin
      if(index==5'd31)active<=0;
      else index<=index+1'b1;
    end
  end
  assign ap_idle=!active;
  assign ap_ready=!active;
  assign ap_done=active && index==5'd31;
  assign x_address0={1'b0,index};
  assign x_ce0=active;
  assign cosine_address0={1'b0,index};
  assign cosine_ce0=active;
  assign sine_address0={1'b0,index};
  assign sine_ce0=active;
  assign y_address0={1'b0,index};
  assign y_address1={1'b1,index};
  assign y_ce0=active;
  assign y_ce1=active;
  assign y_we0=active;
  assign y_we1=active;
  assign y_d0=32'h3f000000;
  assign y_d1=32'h3f000000;
  assign ap_return=128'hffffffffffffffff0000000000000000;
endmodule
