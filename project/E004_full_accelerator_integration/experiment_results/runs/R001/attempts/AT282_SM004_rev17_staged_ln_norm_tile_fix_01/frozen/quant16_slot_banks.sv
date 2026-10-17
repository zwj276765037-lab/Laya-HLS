`timescale 1ns/1ps

// Thirty-two reserved Group32 slots, each split into two 16-lane halves.
// Lane i uses bank i and address {slot,half}; every bank is 64x32, with one
// synchronous read and one write port. The controller must not request the
// same slot/half for read and write on one edge; no bypass is assumed.
module quant16_slot_banks (
    input  logic         clk,
    input  logic         rst,
    input  logic         write_valid,
    input  logic [4:0]   write_slot,
    input  logic         write_half,
    input  logic [511:0] write_lanes,
    input  logic         read_valid,
    input  logic [4:0]   read_slot,
    input  logic         read_half,
    output logic         read_return_valid,
    output logic [511:0] read_return_lanes
);
  wire [5:0] write_address = {write_slot,write_half};
  wire [5:0] read_address = {read_slot,read_half};

  for (genvar lane=0; lane<16; lane++) begin : g_bank
    (* ram_style = "block" *) logic [31:0] data [0:63];
    always_ff @(posedge clk) begin
      if (write_valid) data[write_address] <= write_lanes[lane*32 +: 32];
      if (read_valid) read_return_lanes[lane*32 +: 32] <= data[read_address];
    end
  end
  always_ff @(posedge clk) begin
    if (rst) read_return_valid <= 1'b0;
    else read_return_valid <= read_valid;
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk) begin
    if (!rst && read_valid && write_valid && read_address == write_address)
      $fatal(1,"quant16 slot-bank same-address read/write has no bypass");
  end
`endif
endmodule
