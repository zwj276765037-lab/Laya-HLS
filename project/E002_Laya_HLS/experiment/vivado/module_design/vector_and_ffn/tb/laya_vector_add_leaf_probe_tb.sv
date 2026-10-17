`timescale 1ns/1ps
module laya_vector_add_leaf_probe_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst=1, ce=1, start=0;
  logic [31:0] a=0, b=0;
  wire [31:0] ce_result, fsm_result;
  wire fsm_done, fsm_idle, fsm_ready;
  logic [31:0] directed [0:155];
  string directed_file;
  integer c,enabled;
  logic [31:0] held_result;

  attention_tile_ce_tanh_libm_stream_leaf_stream_add_node_0_s ce_add (
    .ap_clk(clk), .ap_rst(rst), .a(a), .b(b), .ap_return(ce_result),
    .ap_ce(ce), .laya_global_ce(ce | rst));
  tanh_libm_leaf_fp_add_bits fsm_add (
    .ap_clk(clk), .ap_rst(rst), .ap_start(start),
    .ap_done(fsm_done), .ap_idle(fsm_idle), .ap_ready(fsm_ready),
    .a(directed[0]), .b(directed[1]), .ap_return(fsm_result));

  initial begin
    if (!$value$plusargs("DIRECTED_FILE=%s", directed_file))
      $fatal(1,"MISSING_DIRECTED_FILE");
    $readmemh(directed_file, directed);
    for (integer i=0;i<156;i++)
      if ($isunknown(directed[i])) $fatal(1,"UNKNOWN_DIRECTED_WORD %0d",i);
    repeat (4) @(negedge clk);
    rst=0;
    start=1;
    for (c=0;c<100;c++) begin
      if (c<52) begin
        a=directed[3*c];
        b=directed[3*c+1];
      end else begin
        a=0;
        b=0;
      end
      @(negedge clk);
      $display("FFR0_PROGRESS LEAF_SAMPLE c=%0d ce=%0b a=%08x b=%08x ce_result=%08x fsm_ready=%0b fsm_done=%0b fsm_result=%08x",
        c,ce,a,b,ce_result,fsm_ready,fsm_done,fsm_result);
    end
    // Reset the raw CE pipeline, then stop its CE in the middle of 24 real
    // directed operations. The arithmetic result must hold while stopped and
    // resume at the same ordinal in enabled-clock time.
    rst=1; ce=1; start=0;
    repeat(3) @(negedge clk);
    rst=0;
    enabled=0;
    for (c=0;c<27;c++) begin
      ce=(c<9 || c>=12);
      if (ce) begin
        a=directed[3*enabled];
        b=directed[3*enabled+1];
      end else begin
        a=32'hdeadbeef;
        b=32'hbaadf00d;
      end
      @(posedge clk);
      #1;
      if (!ce && ce_result !== held_result)
        $fatal(1,"VECTOR_CE_PAUSE_CHANGED wall=%0d got=%08x held=%08x",c,ce_result,held_result);
      if (ce && enabled>=5 && ce_result !== directed[3*(enabled-5)+2])
        $fatal(1,"VECTOR_CE_RESUME_DIFF wall=%0d ordinal=%0d got=%08x gold=%08x",
          c,enabled-5,ce_result,directed[3*(enabled-5)+2]);
      held_result=ce_result;
      if (ce) enabled++;
      @(negedge clk);
    end
    rst=1; ce=1;
    repeat(3) @(negedge clk);
    rst=0;
    for (c=0;c<16;c++) begin
      a=directed[3*c]; b=directed[3*c+1];
      @(posedge clk); #1;
      if (c>=5 && ce_result !== directed[3*(c-5)+2])
        $fatal(1,"VECTOR_CE_RESET_DIFF c=%0d got=%08x gold=%08x",
          c,ce_result,directed[3*(c-5)+2]);
      @(negedge clk);
    end
    $display("VECTOR_LEAF_PROBE_PASS samples=100 ce_pause=3 enabled=24 reset=1");
    $finish;
  end
  initial begin
    repeat(300) @(posedge clk);
    $fatal(1,"VECTOR_LEAF_PROBE_TIMEOUT");
  end
endmodule
