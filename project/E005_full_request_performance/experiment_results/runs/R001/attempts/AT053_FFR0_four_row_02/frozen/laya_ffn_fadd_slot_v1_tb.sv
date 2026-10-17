`timescale 1ns/1ps
module laya_ffn_fadd_slot_v1_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0, in_valid=0, out_ready=0;
  logic in_ready, out_valid, leaf_busy;
  logic [31:0] in_a=0, in_b=0, out_bits;
  logic accepted_pulse, returned_pulse, consumed_pulse;
  logic [31:0] fixture[0:155];
  string fixture_path;
  integer accepted=0, returned=0, consumed=0;
  integer cycle=0;

  laya_ffn_fadd_slot_v1 dut (
      .clk(clk),.rst_n(rst_n),.in_valid(in_valid),.in_ready(in_ready),
      .in_a(in_a),.in_b(in_b),.out_valid(out_valid),.out_ready(out_ready),
      .out_bits(out_bits),.leaf_busy(leaf_busy),
      .accepted_pulse(accepted_pulse),.returned_pulse(returned_pulse),
      .consumed_pulse(consumed_pulse)
  );

  always @(posedge clk) begin
    cycle <= cycle+1;
    if (rst_n) begin
      if (accepted_pulse) accepted <= accepted+1;
      if (returned_pulse) returned <= returned+1;
      if (consumed_pulse) consumed <= consumed+1;
    end
  end

  initial begin
    if (!$value$plusargs("ADD_FILE=%s",fixture_path))
      $fatal(1,"MISSING_ADD_FILE");
    $readmemh(fixture_path,fixture);
    for (int j=0;j<156;j++)
      if ($isunknown(fixture[j])) $fatal(1,"UNKNOWN_ADD_FIXTURE index=%0d",j);
    repeat(4) @(negedge clk);
    rst_n=1;
    repeat(3) @(posedge clk);
    if (out_valid || leaf_busy) $fatal(1,"SLOT_NOT_IDLE_AFTER_RESET");
    for (int i=0;i<52;i++) begin
      repeat(i%3) @(negedge clk);
      @(negedge clk);
      in_a=fixture[3*i];
      in_b=fixture[3*i+1];
      in_valid=1;
      do @(posedge clk); while (!in_ready);
      @(negedge clk);
      in_valid=0;
      in_a=32'hdeadbeef;
      in_b=32'hf00dd00d;
      out_ready=0;
      do @(negedge clk); while (!out_valid);
      if (out_bits !== fixture[3*i+2])
        $fatal(1,"FFR0_ADD_DIFF index=%0d a=%08x b=%08x got=%08x gold=%08x",
               i,fixture[3*i],fixture[3*i+1],out_bits,fixture[3*i+2]);
      repeat(4+(i%4)) begin
        @(negedge clk);
        if (!out_valid || out_bits !== fixture[3*i+2])
          $fatal(1,"FFR0_ADD_HOLD_FAIL index=%0d",i);
      end
      out_ready=1;
      @(posedge clk);
      @(negedge clk);
      out_ready=0;
      if (out_valid) $fatal(1,"FFR0_DUPLICATE_RETURN index=%0d",i);
    end
    repeat(4) @(negedge clk);
    if (accepted!=52 || returned!=52 || consumed!=52 || out_valid || leaf_busy)
      $fatal(1,"FFR0_ADD_DEBT accept=%0d return=%0d consume=%0d",accepted,returned,consumed);
    rst_n=0;
    repeat(3) @(negedge clk);
    rst_n=1;
    repeat(5) @(negedge clk);
    if (out_valid || leaf_busy) $fatal(1,"FFR0_ADD_GHOST_AFTER_IDLE_RESET");
    $display("FFR0_FADD_SLOT_PASS count=52 accepted=%0d returned=%0d consumed=%0d cycles=%0d",
             accepted,returned,consumed,cycle);
    $finish;
  end
  initial begin
    repeat(10000) @(posedge clk);
    $fatal(1,"FFR0_ADD_TIMEOUT");
  end
endmodule
