`timescale 1ns/1ps

module owner_ct0_tb;
  localparam integer TRANSACTIONS = 131;
  localparam integer CMD_WORDS = TRANSACTIONS * 12;
  localparam integer RSP_WORDS = TRANSACTIONS * 11;
  reg ap_clk = 0;
  always #5 ap_clk = ~ap_clk;
  reg ap_rst = 1;
  wire [511:0] request_dout;
  wire request_empty_n;
  wire request_read;
  wire [511:0] response_din;
  wire response_full_n;
  wire response_write;
  reg [511:0] commands [0:CMD_WORDS-1];
  reg [511:0] expected [0:RSP_WORDS-1];
  integer command_words = 0;
  integer response_words = 0;
  integer cycles = 0;
  integer blocked_pending_cycles = 0;
  integer limit_transactions = TRANSACTIONS;
  integer done_cycle = -1;
  string command_path;
  string response_path;

  assign request_empty_n = !ap_rst &&
      command_words < limit_transactions * 12;
  assign request_dout = command_words < CMD_WORDS ?
      commands[command_words] : 512'b0;
  // Deliberate backpressure varies with time and across a result's eleven
  // physical beats. The sequence is identical for every frozen replay.
  assign response_full_n = !ap_rst && cycles % 9 != 0 && cycles % 13 != 0;

  laya_owner_ct0 dut (
      .ap_clk(ap_clk), .ap_rst(ap_rst),
      .request_dout(request_dout), .request_empty_n(request_empty_n),
      .request_read(request_read), .response_din(response_din),
      .response_full_n(response_full_n), .response_write(response_write));

  always @(posedge ap_clk) begin
    if (!ap_rst) begin
      cycles <= cycles + 1;
      if (request_read && request_empty_n)
        command_words <= command_words + 1;
      // Generated `phase` is the real pending-output state. Count only a
      // blocked response, not arbitrary low full_n cycles before a result.
      if (dut.phase == 3'd7 && !response_full_n)
        blocked_pending_cycles <= blocked_pending_cycles + 1;
      if (response_write && response_full_n) begin
        if (response_words >= limit_transactions * 11)
          $fatal(1, "CT0 extra response word");
        if (response_din !== expected[response_words])
          $fatal(1, "CT0 response mismatch word=%0d tx=%0d beat=%0d got=%h expected=%h",
                 response_words, response_words / 11,
                 response_words % 11, response_din,
                 expected[response_words]);
        response_words <= response_words + 1;
        if ((response_words + 1) % 11 == 0)
          $display("FULL_CURRENT_CT0_PROGRESS transactions=%0d cycle=%0d",
                   (response_words + 1) / 11, cycles);
        if (response_words + 1 == limit_transactions * 11)
          done_cycle <= cycles;
      end
      if (cycles > 400000)
        $fatal(1, "CT0 timeout command_words=%0d response_words=%0d",
               command_words, response_words);
    end
  end

  initial begin
    if (!$value$plusargs("COMMANDS=%s", command_path) ||
        !$value$plusargs("RESPONSES=%s", response_path))
      $fatal(1, "CT0 trace paths missing");
    if ($test$plusargs("PILOT")) limit_transactions = 2;
    $readmemh(command_path, commands);
    $readmemh(response_path, expected);
    repeat (5) @(negedge ap_clk);
    ap_rst = 0;
    wait (done_cycle >= 0);
    repeat (40) @(negedge ap_clk);
    if (command_words != limit_transactions * 12 ||
        response_words != limit_transactions * 11 ||
        blocked_pending_cycles == 0)
      $fatal(1, "CT0 incomplete or no response backpressure");
    $display("CT0_RTL_%s_PASS cycles=%0d transactions=%0d input_words=%0d output_words=%0d held_cycles=%0d",
             limit_transactions == 2 ? "PILOT" : "FULL", done_cycle,
             limit_transactions, command_words, response_words,
             blocked_pending_cycles);
    $finish;
  end
endmodule
