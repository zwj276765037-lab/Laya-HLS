`timescale 1ns/1ps
module laya_private_fifo2_v1 #(parameter int WIDTH=512) (
  input logic clk,rst_n,
  input logic in_valid,
  output logic in_ready,
  input logic [WIDTH-1:0] in_data,
  output logic out_valid,
  input logic out_ready,
  output logic [WIDTH-1:0] out_data,
  output logic [1:0] occupancy
);
  logic [WIDTH-1:0] data[0:1];
  logic read_index,write_index,push,pop;
  assign in_ready=rst_n && occupancy!=2;
  assign out_valid=rst_n && occupancy!=0;
  assign out_data=data[read_index];
  assign push=in_valid && in_ready;
  assign pop=out_valid && out_ready;
  always_ff @(posedge clk)begin
    if(!rst_n)begin occupancy<=0;read_index<=0;write_index<=0;end
    else begin
      if(push)begin data[write_index]<=in_data;write_index<=!write_index;end
      if(pop)read_index<=!read_index;
      case({push,pop})
        2'b10:occupancy<=occupancy+1;
        2'b01:occupancy<=occupancy-1;
        default:;
      endcase
    end
  end
endmodule
