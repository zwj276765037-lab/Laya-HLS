`timescale 1ns/1ps
module laya_rope_head_check_edges_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0, table_reset=0, head_prepare=0;
  logic x_block_valid=0, cos_block_valid=0, sin_block_valid=0;
  logic [1:0] x_block=0;
  logic [3:0] table_block=0;
  logic [511:0] x_block_data=0;
  logic [127:0] table_block_data=0;
  logic start_valid=0, start_ready, result_valid, result_ready=0;
  logic [127:0] result_check;
  logic result_protocol_error;
  logic [2:0] y_tile_index=0;
  logic [255:0] y_tile;
  logic [63:0] x_coverage, cos_coverage, sin_coverage, y_coverage;
  logic leaf_active, leaf_ap_done;
  logic [31:0] x_words[0:63], cos_words[0:63], sin_words[0:63];
  logic [31:0] saved_x[0:127], saved_expected[0:127];
  logic [31:0] saved_cos[0:63], saved_sin[0:63];
  int cycle_count=0;
  laya_rope_head_adapter_v1 dut(.*);

  always @(posedge clk) cycle_count <= cycle_count+1;

  task automatic prepare_default;
    for(int i=0;i<64;i++) begin
      x_words[i]=32'h00000000;
      cos_words[i]=32'h3f800000;
      sin_words[i]=32'h00000000;
    end
  endtask

  task automatic feed_tables;
    @(negedge clk); table_reset=1;
    @(negedge clk); table_reset=0;
    for(int t=0;t<16;t++) begin
      @(negedge clk); cos_block_valid=1; table_block=4'(t);
      for(int k=0;k<4;k++) table_block_data[k*32+:32]=cos_words[t*4+k];
    end
    @(negedge clk); cos_block_valid=0;
    for(int t=0;t<16;t++) begin
      @(negedge clk); sin_block_valid=1; table_block=4'(t);
      for(int k=0;k<4;k++) table_block_data[k*32+:32]=sin_words[t*4+k];
    end
    @(negedge clk); sin_block_valid=0;
    if(cos_coverage !== 64'hffffffffffffffff ||
       sin_coverage !== 64'hffffffffffffffff)
      $fatal(1,"TABLE_COVERAGE cos=%h sin=%h",cos_coverage,sin_coverage);
  endtask

  task automatic feed_head;
    @(negedge clk); head_prepare=1;
    @(negedge clk); head_prepare=0;
    for(int b=0;b<4;b++) begin
      @(negedge clk); x_block_valid=1; x_block=2'(b);
      for(int k=0;k<16;k++) x_block_data[k*32+:32]=x_words[b*16+k];
    end
    @(negedge clk); x_block_valid=0;
    if(x_coverage !== 64'hffffffffffffffff)
      $fatal(1,"HEAD_COVERAGE x=%h",x_coverage);
  endtask

  task automatic start_and_wait;
    int waited;
    waited=0;
    while(!start_ready && waited<1024) begin @(negedge clk); waited++; end
    if(!start_ready) $fatal(1,"START_TIMEOUT cycle=%0d",cycle_count);
    start_valid=1;
    @(negedge clk); start_valid=0;
    waited=0;
    while(!result_valid && waited<4096) begin @(negedge clk); waited++; end
    if(!result_valid) $fatal(1,"RESULT_TIMEOUT cycle=%0d",cycle_count);
  endtask

  task automatic hold_and_consume(input int case_id);
    logic [127:0] saved_check;
    logic [63:0] saved_coverage;
    saved_check=result_check;
    saved_coverage=y_coverage;
    repeat(3) begin
      @(negedge clk);
      if(result_valid !== 1'b1 || result_check !== saved_check ||
         y_coverage !== saved_coverage)
        $fatal(1,"RESULT_HOLD case=%0d check=%h coverage=%h",case_id,result_check,y_coverage);
    end
    result_ready=1;
    @(negedge clk); result_ready=0;
    if(result_valid !== 1'b0)
      $fatal(1,"RESULT_CONSUME case=%0d",case_id);
  endtask

  task automatic run_bad(input int case_id,input logic [63:0] bad);
    feed_tables();
    feed_head();
    start_and_wait();
    if(result_check[15:0] !== 16'd6 ||
       result_check[63:32] !== 32'h0740000f ||
       result_check[127:64] !== bad ||
       result_protocol_error !== 1'b0)
      $fatal(1,"CHECK_BAD case=%0d actual=%h expected_bad=%0d protocol=%0d",
             case_id,result_check,bad,result_protocol_error);
    // The leaf may have written earlier y elements; a failed head is never a success.
    if(y_coverage === 64'hffffffffffffffff)
      $fatal(1,"FAILED_HEAD_FULL_Y case=%0d",case_id);
    $display("ROPE_CHECK_BAD_PASS case=%0d bad=%0d check=%h y_coverage=%h cycle=%0d",
             case_id,bad,result_check,y_coverage,cycle_count);
    hold_and_consume(case_id);
  endtask

  task automatic run_saved_good;
    for(int i=0;i<64;i++) begin
      x_words[i]=saved_x[i]; cos_words[i]=saved_cos[i]; sin_words[i]=saved_sin[i];
    end
    feed_tables();
    feed_head();
    start_and_wait();
    if(result_check[15:0] !== 16'd0 ||
       result_check[63:32] !== 32'd0 ||
       result_check[127:64] !== 64'hffffffffffffffff ||
       result_protocol_error !== 1'b0 ||
       y_coverage !== 64'hffffffffffffffff)
      $fatal(1,"SAVED_GOOD_CHECK actual=%h coverage=%h protocol=%0d",
             result_check,y_coverage,result_protocol_error);
    for(int t=0;t<8;t++) begin
      y_tile_index=3'(t); #1;
      for(int k=0;k<8;k++)
        if(y_tile[k*32+:32] !== saved_expected[t*8+k])
          $fatal(1,"SAVED_GOOD_Y element=%0d actual=%h expected=%h",
                 t*8+k,y_tile[k*32+:32],saved_expected[t*8+k]);
      @(negedge clk);
    end
    $display("ROPE_CHECK_SAVED_RECOVERY_PASS check=%h outputs=64 cycle=%0d",
             result_check,cycle_count);
    hold_and_consume(4);
  endtask

  initial begin
    $readmemh("x.hex",saved_x);
    $readmemh("cos.hex",saved_cos);
    $readmemh("sin.hex",saved_sin);
    $readmemh("expected.hex",saved_expected);
    repeat(3) @(negedge clk); rst_n=1;

    // Precheck scans d in order across x/cos/sin, so cos[7] wins over x[63].
    prepare_default(); cos_words[7]=32'h7f800000; x_words[63]=32'h7fc00000;
    run_bad(0,64'd7);

    // Last pair: lower max - (-max) overflows before upper max + max.
    prepare_default(); x_words[31]=32'h7f7fffff; x_words[63]=32'h7f7fffff;
    sin_words[31]=32'hbf800000; sin_words[63]=32'h3f800000;
    run_bad(1,64'd31);

    // Last pair: lower stays finite, then upper max + max overflows.
    prepare_default(); x_words[31]=32'h7f7fffff; x_words[63]=32'h7f7fffff;
    sin_words[63]=32'h3f800000;
    run_bad(2,64'd63);

    // A later precheck failure wins over a would-be pair0 multiply overflow.
    prepare_default(); x_words[0]=32'h7f7fffff; cos_words[0]=32'h40000000;
    x_words[63]=32'h7fc00000;
    run_bad(3,64'd63);

    // No reset between failed heads and an original saved normal head.
    run_saved_good();
    $display("ROPE_CHECK_EDGES_PASS cases=4 recovered=1");
    $finish;
  end
endmodule
