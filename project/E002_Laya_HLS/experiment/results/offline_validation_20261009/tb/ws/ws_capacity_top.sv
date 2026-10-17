`timescale 1 ps / 1 ps

module ws_capacity_top;
  localparam integer FULL_DEPTH = 20992;
  reg clk = 1'b0;
  always #5000 clk = ~clk;
  reg [14:0] address0 = 0;
  reg [14:0] address1 = 0;
  reg ce0 = 0;
  reg ce1 = 0;  // The joined parent DCP net n32 is certified GND.
  reg reset = 0; // The same parent DCP net n32 is certified GND.
  reg we1 = 0;
  reg [15:0] d [0:7];
  wire [15:0] q [0:7];
// WS_BANK_INSTANCES

  integer max_addr;
  integer first_phase;
  integer phase_count;
  integer phase;
  integer addr;
  integer bank;
  integer reads;
  integer high_reads;
  integer bit_index;
  integer probe_index;
  integer probe_addr;
  reg [15:0] expected;

  function automatic [15:0] word(input integer b, input integer a,
                                  input integer p);
    reg [31:0] tag;
    integer lane;
    begin
      word = 0;
      for (lane = 0; lane < 16; lane = lane + 1) begin
        tag = ((b * FULL_DEPTH + a) * 16 + lane + 1);
        word[lane] = (tag >> p) & 1;
      end
    end
  endfunction

  initial begin
    max_addr = FULL_DEPTH;
    first_phase = 0;
    phase_count = 1;
    if ($value$plusargs("WS_MAX_ADDR=%d", max_addr)) begin end
    if ($value$plusargs("WS_FIRST_PHASE=%d", first_phase)) begin end
    if ($value$plusargs("WS_PHASE_COUNT=%d", phase_count)) begin end
    if (max_addr < 1 || max_addr > FULL_DEPTH || first_phase < 0 ||
        phase_count < 1 || first_phase + phase_count > 22)
      $fatal(1, "WS_CAPACITY_INVALID_CONFIGURATION");
    for (bank = 0; bank < 8; bank = bank + 1) d[bank] = 0;
    // Wait beyond exact glbl ROC/GRES startup support in the accepted export.
    #120000;
    ce0 = 1;
    for (probe_index = 0; probe_index < 4; probe_index = probe_index + 1) begin
      case (probe_index)
        0: probe_addr = 0;
        1: probe_addr = 16383;
        2: probe_addr = 16384;
        default: probe_addr = 20991;
      endcase
      @(negedge clk);
      address0 = probe_addr[14:0];
      repeat (4) @(posedge clk);
      #1;
      for (bank = 0; bank < 8; bank = bank + 1)
        if (q[bank] !== 16'h0000)
          $fatal(1, "WS_CAPACITY_INIT_MISMATCH bank=%0d addr=%0d got=%04x",
                 bank, probe_addr, q[bank]);
    end
    $display("WS_CAPACITY_INIT_PASS banks=8 addresses=0,16383,16384,20991");
    reads = 0;
    high_reads = 0;
    for (phase = first_phase; phase < first_phase + phase_count; phase = phase + 1) begin
      ce0 = 0;
      for (addr = 0; addr < max_addr; addr = addr + 1) begin
        @(negedge clk);
        address1 = addr[14:0];
        for (bank = 0; bank < 8; bank = bank + 1)
          d[bank] = word(bank, addr, phase);
        we1 = 1;
        @(posedge clk);
        #1;
        if ((addr + 1) % 4096 == 0)
          $display("WS_CAPACITY_WRITE_PROGRESS phase=%0d words=%0d", phase, addr + 1);
      end
      @(negedge clk);
      we1 = 0;
      ce0 = 1;
      for (addr = 0; addr < max_addr; addr = addr + 1) begin
        @(negedge clk);
        address0 = addr[14:0];
        repeat (4) @(posedge clk);
        #1;
        for (bank = 0; bank < 8; bank = bank + 1) begin
          expected = word(bank, addr, phase);
          if (q[bank] !== expected)
            $fatal(1, "WS_CAPACITY_MISMATCH phase=%0d bank=%0d addr=%0d got=%04x expected=%04x",
                   phase, bank, addr, q[bank], expected);
          reads = reads + 1;
          if (addr >= 16384) high_reads = high_reads + 1;
        end
        if ((addr + 1) % 4096 == 0)
          $display("WS_CAPACITY_READ_PROGRESS phase=%0d words=%0d", phase, addr + 1);
      end
      // Attempt a write with WE low. It must leave the full-pattern word intact.
      @(negedge clk);
      address1 = 0;
      we1 = 0;
      for (bank = 0; bank < 8; bank = bank + 1)
        d[bank] = ~word(bank, 0, phase);
      repeat (3) @(posedge clk);
      @(negedge clk);
      address0 = 0;
      repeat (4) @(posedge clk);
      #1;
      for (bank = 0; bank < 8; bank = bank + 1)
        if (q[bank] !== word(bank, 0, phase))
          $fatal(1, "WS_CAPACITY_WE0_MISMATCH phase=%0d bank=%0d got=%04x",
                 phase, bank, q[bank]);
      $display("WS_CAPACITY_PHASE_PASS phase=%0d words_per_bank=%0d", phase, max_addr);
    end
    if (max_addr == FULL_DEPTH && reads == 8 * FULL_DEPTH * phase_count &&
        high_reads == 8 * (FULL_DEPTH - 16384) * phase_count)
      $display("WS_CAPACITY_RUN_PASS banks=8 depth=20992 width=16 first_phase=%0d phase_count=%0d reads=%0d high_reads=%0d",
               first_phase, phase_count, reads, high_reads);
    else
      $display("WS_CAPACITY_PILOT_ONLY banks=8 depth=%0d first_phase=%0d phase_count=%0d reads=%0d high_reads=%0d",
               max_addr, first_phase, phase_count, reads, high_reads);
    $finish;
  end
endmodule
