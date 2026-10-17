`timescale 1ns/1ps

module quant16_slot_banks_tb;
  logic clk=0, rst=1, write_valid=0, read_valid=0;
  logic [4:0] write_slot=0, read_slot=0;
  logic write_half=0, read_half=0;
  logic [511:0] write_lanes=0;
  wire read_return_valid;
  wire [511:0] read_return_lanes;
  always #3.333 clk=~clk;

  quant16_slot_banks dut (.*);

  function automatic logic [31:0] sample(input int slot,half,lane);
    sample=32'h3e800000 ^ (slot<<16) ^ (half<<12) ^ lane;
  endfunction

  initial begin
    repeat (3) @(negedge clk);
    rst=0;
    for (int slot=0;slot<32;slot++) begin
      for (int half=0;half<2;half++) begin
        @(negedge clk);
        write_valid=1; write_slot=5'(slot); write_half=1'(half);
        for (int lane=0;lane<16;lane++)
          write_lanes[lane*32 +: 32]=sample(slot,half,lane);
      end
    end
    @(negedge clk); write_valid=0;
    for (int slot=0;slot<32;slot++) begin
      for (int half=0;half<2;half++) begin
        @(negedge clk);
        read_valid=1; read_slot=5'(slot); read_half=1'(half);
        // Simultaneous write to another address exercises the 1R1W service.
        write_valid=1; write_slot=5'((slot+1)%32); write_half=1'(half);
        for (int lane=0;lane<16;lane++)
          write_lanes[lane*32 +: 32]=sample((slot+1)%32,half,lane);
        @(posedge clk);
        @(negedge clk);
        if (!read_return_valid)
          $fatal(1,"slot bank missing synchronous read response");
        for (int lane=0;lane<16;lane++)
          if (read_return_lanes[lane*32 +: 32]!==sample(slot,half,lane))
            $fatal(1,"slot bank data mismatch slot=%0d half=%0d lane=%0d",slot,half,lane);
        read_valid=0; write_valid=0;
      end
    end
    @(negedge clk); rst=1;
    @(negedge clk);
    if (read_return_valid) $fatal(1,"slot bank stale read valid after reset");
    $display("QUANT16_SLOT_BANKS_PASS slots=32 halves=2 lanes=16 bytes=4096");
    $finish;
  end
endmodule
