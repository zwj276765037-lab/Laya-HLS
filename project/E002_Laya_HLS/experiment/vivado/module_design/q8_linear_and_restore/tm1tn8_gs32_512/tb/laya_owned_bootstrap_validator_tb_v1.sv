`timescale 1ns/1ps
`include "owned_bootstrap_validator_ports.vh"

// Isolated actual generated validator. The Message RAM uses the generated
// parent RAM's synchronous read timing. There is no owner installation port.
module laya_owned_bootstrap_validator_tb_v1;
  reg ap_clk = 0;
  always #5 ap_clk = ~ap_clk;
  reg ap_rst = 1;
  reg ap_start = 0;
  wire ap_done, ap_idle, ap_ready;
  wire [3:0] m_address0, m_address1;
  wire m_ce0, m_ce1;
  reg [511:0] m_q0, m_q1;
  reg [511:0] message_ram [0:11];
  reg [15:0] purpose;
  reg [7:0] content;
  wire [`OWNED_BOOTSTRAP_RETURN_WIDTH-1:0] ap_return;

  `OWNED_BOOTSTRAP_VALIDATOR_MODULE dut (
    .ap_clk(ap_clk), .ap_rst(ap_rst), .ap_start(ap_start),
    .ap_done(ap_done), .ap_idle(ap_idle), .ap_ready(ap_ready),
    .m_address0(m_address0), .m_ce0(m_ce0), .m_q0(m_q0),
    .m_address1(m_address1), .m_ce1(m_ce1), .m_q1(m_q1),
    .purpose(purpose), .content(content), .ap_return(ap_return)
  );

  string message_path, case_name;
  integer purpose_arg, content_arg, expect_ok;
  integer max_cycles = 1000000;
  integer cycles = 0;
  integer reads0 = 0, reads1 = 0;
  integer start_cycle = -1, done_cycle = -1;
  integer observed_return = -1;
  reg start_seen = 0;
  reg done_seen = 0;

  // Exactly the parent RAM's registered, read-first interface; no asynchronous
  // shortcut, reset-filled read output, or hierarchy write to the DUT is used.
  always @(posedge ap_clk) begin
    if (m_ce0 === 1'b1) begin
      if ($isunknown(m_address0) || m_address0 >= 12)
        $fatal(1, "invalid Message RAM port0 address");
      m_q0 <= message_ram[m_address0];
      reads0 = reads0 + 1;
    end
    if (m_ce1 === 1'b1) begin
      if ($isunknown(m_address1) || m_address1 >= 12)
        $fatal(1, "invalid Message RAM port1 address");
      m_q1 <= message_ram[m_address1];
      reads1 = reads1 + 1;
    end
  end

  // Observe done/return on the actual edge before the FSM's nonblocking update.
  always @(posedge ap_clk) begin
    cycles = cycles + 1;
    if (cycles > max_cycles) $fatal(1, "validator cycle limit");
    if (!ap_rst) begin
      if ($isunknown({m_ce0, m_ce1, ap_done}))
        $fatal(1, "unknown validator control");
      if (ap_start && !start_seen) begin
        start_seen = 1;
        start_cycle = cycles;
        $display("FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_START case=%s cycle=%0d purpose=%0d content=%0d",
                 case_name, cycles, purpose, content);
      end
      if (start_seen && !done_seen && ap_done === 1'b1) begin
        if ($isunknown(ap_return)) $fatal(1, "unknown validator return");
        done_seen = 1;
        done_cycle = cycles;
        observed_return = ap_return;
        $display("FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_DONE case=%s cycle=%0d return=%0d",
                 case_name, cycles, observed_return);
      end
    end
  end

  initial begin : run_case
    integer i;
    m_q0 = 'x;
    m_q1 = 'x;
    if (!$value$plusargs("MESSAGE=%s", message_path) ||
        !$value$plusargs("CASE=%s", case_name) ||
        !$value$plusargs("PURPOSE=%d", purpose_arg) ||
        !$value$plusargs("CONTENT=%d", content_arg) ||
        !$value$plusargs("EXPECT_OK=%d", expect_ok))
      $fatal(1, "required validator case arguments absent");
    if ($value$plusargs("MAX_CYCLES=%d", max_cycles)) begin end
    if (max_cycles < 1 || max_cycles > 1000000 ||
        purpose_arg < 0 || purpose_arg > 65535 ||
        content_arg < 0 || content_arg > 255 ||
        (expect_ok != 0 && expect_ok != 1))
      $fatal(1, "invalid bounded validator arguments");
    purpose = purpose_arg;
    content = content_arg;
    $readmemh(message_path, message_ram);
    for (i = 0; i < 12; i = i + 1)
      if ($isunknown(message_ram[i])) $fatal(1, "unresolved Message stimulus");
    repeat (8) @(negedge ap_clk);
    ap_rst = 0;
    repeat (2) @(negedge ap_clk);
    if (ap_idle !== 1'b1) $fatal(1, "validator did not reach idle after reset");
    ap_start = 1;
    while (!done_seen) @(negedge ap_clk);
    ap_start = 0;
    if (!start_seen || done_cycle < start_cycle)
      $fatal(1, "missing actual start/done observation");
    if ((expect_ok && observed_return != 0) ||
        (!expect_ok && observed_return == 0))
      $fatal(1, "validator result mismatch case=%s expected_ok=%0d return=%0d",
             case_name, expect_ok, observed_return);
    if (expect_ok && (reads0 == 0 || reads1 == 0))
      $fatal(1, "positive validator case did not read both Message ports");
    $display("FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_RTL_PASS case=%s cycles=%0d start_cycle=%0d done_cycle=%0d purpose=%0d content=%0d return=%0d reads0=%0d reads1=%0d isolated_module=1 owner_install=NOT_RUN",
             case_name, cycles, start_cycle, done_cycle, purpose, content,
             observed_return, reads0, reads1);
    $finish;
  end
endmodule
