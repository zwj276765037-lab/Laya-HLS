`timescale 1ns/1ps

// The independent directed expf words are read from the frozen fixture.
// The HLS leaf must accept one new call on each of twelve consecutive edges.
module attention_exp_ii1_tb;
  logic ap_clk = 0;
  always #1.667 ap_clk = ~ap_clk;
  logic ap_rst = 1;
  logic ap_start = 0;
  logic [31:0] x = 0;
  wire ap_done, ap_idle, ap_ready;
  wire [31:0] result, status;
  wire result_ap_vld, status_ap_vld;
  logic [31:0] directed_x [0:11], directed_gold [0:11];
  integer sent = 0, received = 0, cycle = 0;
  integer first_accept = -1, first_return = -1;
  string fixture;

  attention_exp_leaf dut (
    .ap_clk, .ap_rst, .ap_start, .ap_done, .ap_idle, .ap_ready,
    .x, .result, .result_ap_vld, .status, .status_ap_vld
  );

  initial begin
    if (!$value$plusargs("FIXTURE=%s", fixture))
      $fatal(1, "EXP_FIXTURE_REQUIRED");
    $readmemh({fixture, "/exp_directed_x.mem"}, directed_x);
    $readmemh({fixture, "/exp_directed_gold.mem"}, directed_gold);
    repeat (5) @(negedge ap_clk);
    ap_rst = 0;
  end

  always @(negedge ap_clk) begin
    if (ap_rst) begin ap_start <= 0; x <= 0; end
    else begin
      ap_start <= sent < 12;
      x <= sent < 12 ? directed_x[sent] : 32'd0;
    end
  end

  always @(posedge ap_clk) if (!ap_rst) begin
    cycle <= cycle + 1;
    if (cycle > 400) $fatal(1, "EXP_II1_CYCLE_CAP sent=%0d received=%0d", sent, received);
    if (ap_start) begin
      if (!ap_ready || sent >= 12)
        $fatal(1, "EXP_II1_ACCEPT_GAP cycle=%0d sent=%0d ready=%b", cycle, sent, ap_ready);
      if (sent == 0) first_accept <= cycle;
      sent <= sent + 1;
    end
    if (result_ap_vld || status_ap_vld) begin
      if (!result_ap_vld || !status_ap_vld || received >= 12)
        $fatal(1, "EXP_II1_RETURN_PROTOCOL received=%0d", received);
      if (result !== directed_gold[received] || status !== 0)
        $fatal(1, "EXP_II1_ORACLE index=%0d got=%h expected=%h status=%h",
               received, result, directed_gold[received], status);
      if (received == 0) first_return <= cycle;
      received <= received + 1;
      if (received == 11) begin
        if (sent != 12 || first_accept < 0 || first_return < 0)
          $fatal(1, "EXP_II1_COUNT");
        $display("ATTENTION_EXP_II1_RTL_PASS accepted=12 returned=12 first_latency=%0d",
                 first_return - first_accept);
        $finish;
      end
    end
  end
endmodule
