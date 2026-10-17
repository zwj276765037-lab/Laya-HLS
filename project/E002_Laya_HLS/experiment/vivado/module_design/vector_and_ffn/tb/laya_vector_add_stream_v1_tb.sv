`timescale 1ns/1ps
module laya_vector_add_stream_v1_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n=0, in_valid=0, out_ready=0;
  logic in_ready, out_valid;
  logic [31:0] a=0, b=0, bits;
  logic [31:0] src_a [0:4095], src_b [0:4095], gold [0:4095];
  string a_file,b_file,gold_file;
  laya_vector_add_stream_v1 dut (
    .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .in_ready(in_ready),
    .a(a), .b(b), .out_valid(out_valid), .out_ready(out_ready), .bits(bits));

  task automatic run_case(input integer mode, input integer count, input bit reset_first);
    integer accepted, returned, consumed, c, first_accept, first_return;
    integer last_consume, peak, blocked_cycles;
    bit pending, blocked;
    logic [31:0] held_bits;
    begin
      if (reset_first) begin
        @(negedge clk); rst_n=0; in_valid=0; out_ready=0;
        repeat(3) @(negedge clk);
        rst_n=1;
      end
      accepted=0; returned=0; consumed=0; pending=0; blocked=0;
      first_accept=-1; first_return=-1; last_consume=-1;
      peak=0; blocked_cycles=0;
      for (c=0;c<20000 && consumed<count;c++) begin
        @(negedge clk);
        if (!pending && accepted<count && (mode==0 || (c%7)!=2)) pending=1;
        in_valid=pending;
        a=accepted<count ? src_a[accepted] : 0;
        b=accepted<count ? src_b[accepted] : 0;
        out_ready=(mode==0 || (c%11)>3);
        if (dut.occupancy>peak) peak=dut.occupancy;
        @(posedge clk);
        if (blocked && (!out_valid || bits !== held_bits))
          $fatal(1,"VECTOR_OUTPUT_HOLD_FAIL mode=%0d c=%0d",mode,c);
        if (dut.returned_pulse) begin
          if (first_return<0) first_return=c;
          returned=returned+1;
          if (dut.tag_pipe[5] !== returned-1)
            $fatal(1,"VECTOR_RETURN_TAG_FAIL mode=%0d c=%0d tag=%0d expected=%0d",
              mode,c,dut.tag_pipe[5],returned-1);
        end
        if (in_valid && in_ready) begin
          if (first_accept<0) first_accept=c;
          accepted=accepted+1;
          pending=0;
          if (accepted%512==0) $display("FFR0_PROGRESS VECTOR_ACCEPT mode=%0d count=%0d c=%0d",mode,accepted,c);
        end
        if (out_valid && out_ready) begin
          if (bits !== gold[consumed])
            $fatal(1,"VECTOR_GOLD_DIFF mode=%0d ordinal=%0d got=%08x gold=%08x",mode,consumed,bits,gold[consumed]);
          if (dut.result_tag[dut.consume_ptr] !== consumed)
            $fatal(1,"VECTOR_CONSUME_TAG_FAIL mode=%0d ordinal=%0d tag=%0d",mode,consumed,dut.result_tag[dut.consume_ptr]);
          consumed=consumed+1;
          last_consume=c;
        end
        blocked=out_valid && !out_ready;
        held_bits=bits;
        if (blocked) blocked_cycles=blocked_cycles+1;
      end
      @(negedge clk); in_valid=0; out_ready=0;
      if (accepted!=count || returned!=count || consumed!=count || dut.occupancy!=0 || out_valid)
        $fatal(1,"VECTOR_DEBT_FAIL mode=%0d accept=%0d return=%0d consume=%0d occupancy=%0d c=%0d",
          mode,accepted,returned,consumed,dut.occupancy,c);
      $display("VECTOR_STREAM_CASE_PASS mode=%0d count=%0d cycles=%0d first_accept=%0d first_return=%0d last_consume=%0d blocked=%0d peak=%0d",
        mode,count,c,first_accept,first_return,last_consume,blocked_cycles,peak);
    end
  endtask

  initial begin
    if (!$value$plusargs("A_FILE=%s",a_file) ||
        !$value$plusargs("B_FILE=%s",b_file) ||
        !$value$plusargs("GOLD_FILE=%s",gold_file))
      $fatal(1,"VECTOR_MISSING_FIXTURE");
    $readmemh(a_file,src_a); $readmemh(b_file,src_b); $readmemh(gold_file,gold);
    for (integer i=0;i<4096;i++)
      if ($isunknown(src_a[i]) || $isunknown(src_b[i]) || $isunknown(gold[i]))
        $fatal(1,"VECTOR_UNKNOWN_FIXTURE ordinal=%0d",i);
    run_case(0,4096,1);
    run_case(1,4096,1);
    @(negedge clk); rst_n=0; in_valid=0; out_ready=0;
    repeat(3) @(negedge clk);
    rst_n=1;
    for (integer j=0;j<16;j++) begin
      @(negedge clk);
      in_valid=1; a=src_a[j+100]; b=src_b[j+100]; out_ready=0;
      @(posedge clk);
      if (!in_ready) $fatal(1,"VECTOR_RESET_SETUP_NOT_READY j=%0d",j);
    end
    @(negedge clk); rst_n=0; in_valid=0;
    repeat(3) @(negedge clk);
    rst_n=1;
    repeat(12) begin
      @(negedge clk);
      if (out_valid || dut.occupancy!=0 || dut.returned_pulse)
        $fatal(1,"VECTOR_RESET_GHOST");
    end
    $display("VECTOR_LOCAL_RESET_PASS cancelled=16");
    run_case(2,32,0);
    $display("VECTOR_STREAM_PASS gold=4096 normal=4096 backpressure=4096 reset=16");
    $finish;
  end
  initial begin
    repeat(50000) @(posedge clk);
    $fatal(1,"VECTOR_STREAM_TIMEOUT");
  end
endmodule
