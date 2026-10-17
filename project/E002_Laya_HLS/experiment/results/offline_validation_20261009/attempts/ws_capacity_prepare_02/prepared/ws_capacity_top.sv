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
  ws_capacity_bank_0 bank_0 (.address0(address0), .ce0(ce0), .q0(q[0]), .address1(address1), .ce1(ce1), .d1(d[0]), .we1(we1), .reset(reset), .clk(clk));
  ws_capacity_bank_1 bank_1 (.address0(address0), .ce0(ce0), .q0(q[1]), .address1(address1), .ce1(ce1), .d1(d[1]), .we1(we1), .reset(reset), .clk(clk));
  ws_capacity_bank_2 bank_2 (.address0(address0), .ce0(ce0), .q0(q[2]), .address1(address1), .ce1(ce1), .d1(d[2]), .we1(we1), .reset(reset), .clk(clk));
  ws_capacity_bank_3 bank_3 (.address0(address0), .ce0(ce0), .q0(q[3]), .address1(address1), .ce1(ce1), .d1(d[3]), .we1(we1), .reset(reset), .clk(clk));
  ws_capacity_bank_4 bank_4 (.address0(address0), .ce0(ce0), .q0(q[4]), .address1(address1), .ce1(ce1), .d1(d[4]), .we1(we1), .reset(reset), .clk(clk));
  ws_capacity_bank_5 bank_5 (.address0(address0), .ce0(ce0), .q0(q[5]), .address1(address1), .ce1(ce1), .d1(d[5]), .we1(we1), .reset(reset), .clk(clk));
  ws_capacity_bank_6 bank_6 (.address0(address0), .ce0(ce0), .q0(q[6]), .address1(address1), .ce1(ce1), .d1(d[6]), .we1(we1), .reset(reset), .clk(clk));
  ws_capacity_bank_7 bank_7 (.address0(address0), .ce0(ce0), .q0(q[7]), .address1(address1), .ce1(ce1), .d1(d[7]), .we1(we1), .reset(reset), .clk(clk));

  integer max_addr;
  integer phases;
  integer phase;
  integer addr;
  integer bank;
  integer reads;
  integer high_reads;
  reg [15:0] expected;

  function automatic [15:0] word(input integer b, input integer a,
                                  input integer p);
    reg [31:0] tmp;
    begin
      tmp = 32'h1357 + a * 32'd73 + b * 32'd8191;
      word = p == 0 ? tmp[15:0] : ~tmp[15:0];
    end
  endfunction

  initial begin
    max_addr = FULL_DEPTH;
    phases = 2;
    if ($value$plusargs("WS_MAX_ADDR=%d", max_addr)) begin end
    if ($value$plusargs("WS_PHASES=%d", phases)) begin end
    if (max_addr < 1 || max_addr > FULL_DEPTH || phases < 1 || phases > 2)
      $fatal(1, "WS_CAPACITY_INVALID_CONFIGURATION");
    for (bank = 0; bank < 8; bank = bank + 1) d[bank] = 0;
    // Wait beyond exact glbl ROC/GRES startup support in the accepted export.
    #120000;
    reads = 0;
    high_reads = 0;
    for (phase = 0; phase < phases; phase = phase + 1) begin
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
      $display("WS_CAPACITY_PHASE_PASS phase=%0d words_per_bank=%0d", phase, max_addr);
    end
    if (max_addr == FULL_DEPTH && phases == 2 &&
        reads == 8 * FULL_DEPTH * 2 && high_reads == 8 * (FULL_DEPTH - 16384) * 2)
      $display("WS_CAPACITY_FULL_PASS banks=8 depth=20992 width=16 phases=2 reads=%0d high_reads=%0d",
               reads, high_reads);
    else
      $display("WS_CAPACITY_PILOT_ONLY banks=8 depth=%0d phases=%0d reads=%0d high_reads=%0d",
               max_addr, phases, reads, high_reads);
    $finish;
  end
endmodule
