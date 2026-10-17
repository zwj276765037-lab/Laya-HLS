`timescale 1ns/1ps
// Passive mirror of actual control_r AW/W handshakes. The package comes from
// generated register constants, not default-offset assumptions. Cold reset is
// separate from cancellation; active bases change only on actual acceptance.
module laya_13bo_base_mirror_v1 (
  input logic clk,rst_n,
  input logic [7:0] awaddr,
  input logic awvalid,awready,
  input logic [31:0] wdata,
  input logic [3:0] wstrb,
  input logic wvalid,wready,
  input logic request_accept,
  output logic [12:0][63:0] programmed_bo_base,latched_bo_base,
  output logic [31:0] accepted_requests,
  output logic protocol_error
);
  import laya_13bo_abi_v1::*;
  logic aw_pending;
  logic [7:0] held_address,write_address;
  integer role;
  always_comb begin
    write_address=aw_pending ? held_address : {awaddr[7:2],2'b00};
    role=role_of(write_address);
  end
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      aw_pending<=0;held_address<=0;programmed_bo_base<=0;latched_bo_base<=0;
      accepted_requests<=0;protocol_error<=0;
    end else begin
      if(awvalid && awready)begin
        if(aw_pending && !(wvalid && wready))protocol_error<=1;
        held_address<={awaddr[7:2],2'b00};aw_pending<=1;
      end
      if(wvalid && wready)begin
        if(!aw_pending && !(awvalid && awready))protocol_error<=1;
        else if(role>=0)for(int byte_index=0;byte_index<4;byte_index++)
          if(wstrb[byte_index])programmed_bo_base[role][32*int'(high_half(write_address))+8*byte_index+:8]<=wdata[8*byte_index+:8];
        // A simultaneous next AW belongs to the next native control transaction.
        aw_pending<=awvalid && awready && aw_pending;
      end
      if(request_accept)begin
        latched_bo_base<=programmed_bo_base;accepted_requests<=accepted_requests+1;
      end
    end
  end
endmodule
