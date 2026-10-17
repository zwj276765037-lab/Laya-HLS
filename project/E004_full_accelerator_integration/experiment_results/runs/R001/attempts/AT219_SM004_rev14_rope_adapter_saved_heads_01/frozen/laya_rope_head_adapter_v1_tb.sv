`timescale 1ns/1ps
module laya_rope_head_adapter_v1_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,table_reset=0,head_prepare=0;
  logic x_block_valid=0,cos_block_valid=0,sin_block_valid=0;
  logic [1:0] x_block=0;
  logic [3:0] table_block=0;
  logic [511:0] x_block_data=0;
  logic [127:0] table_block_data=0;
  logic start_valid=0,start_ready,result_valid,result_ready=0;
  logic [127:0] result_check;
  logic result_protocol_error;
  logic [2:0] y_tile_index=0;
  logic [255:0] y_tile;
  logic [63:0] x_coverage,cos_coverage,sin_coverage,y_coverage;
  logic leaf_active,leaf_ap_done;
  logic [31:0] x_rom[0:127], expected_rom[0:127];
  logic [31:0] cos_rom[0:63],sin_rom[0:63];
  laya_rope_head_adapter_v1 dut(.*);

  task automatic feed_tables;
    @(negedge clk); table_reset=1;
    @(negedge clk); table_reset=0;
    for(int t=0;t<16;t++)begin
      @(negedge clk);
      cos_block_valid=1;table_block=4'(t);
      for(int k=0;k<4;k++)table_block_data[k*32+:32]=cos_rom[t*4+k];
    end
    @(negedge clk);cos_block_valid=0;
    for(int t=0;t<16;t++)begin
      @(negedge clk);
      sin_block_valid=1;table_block=4'(t);
      for(int k=0;k<4;k++)table_block_data[k*32+:32]=sin_rom[t*4+k];
    end
    @(negedge clk);sin_block_valid=0;
    if (!(&cos_coverage) || !(&sin_coverage)) $fatal(1,"TABLE_COVERAGE");
  endtask

  task automatic run_head(input int which);
    int waited;
    @(negedge clk);head_prepare=1;
    @(negedge clk);head_prepare=0;
    for(int b=0;b<4;b++)begin
      @(negedge clk);x_block_valid=1;x_block=2'(b);
      for(int k=0;k<16;k++)x_block_data[k*32+:32]=x_rom[which*64+b*16+k];
    end
    @(negedge clk);x_block_valid=0;
    if (!(&x_coverage)) $fatal(1,"X_COVERAGE head=%0d",which);
    waited=0;
    while(!start_ready && waited<1024)begin @(negedge clk);waited++;end
    if(!start_ready)$fatal(1,"START_TIMEOUT head=%0d",which);
    start_valid=1;
    @(negedge clk);start_valid=0;
    waited=0;
    while(!result_valid && waited<4096)begin @(negedge clk);waited++;end
    if(!result_valid)$fatal(1,"RESULT_TIMEOUT head=%0d",which);
    if(result_check[15:0]!=0 || result_check[63:32]!=0 ||
       result_check[127:64]!==64'hffffffffffffffff ||
       result_protocol_error || !(&y_coverage))
      $fatal(1,"BAD_CHECK head=%0d check=%h protocol=%0d coverage=%h",
             which,result_check,result_protocol_error,y_coverage);
    for(int t=0;t<8;t++)begin
      y_tile_index=3'(t);
      #1;
      for(int k=0;k<8;k++)
        if(y_tile[k*32+:32]!==expected_rom[which*64+t*8+k])
          $fatal(1,"Y_MISMATCH head=%0d element=%0d actual=%h expected=%h",
                 which,t*8+k,y_tile[k*32+:32],expected_rom[which*64+t*8+k]);
    end
    result_ready=1;
    @(negedge clk);result_ready=0;
    $display("ROPE_ADAPTER_HEAD_PASS head=%0d cycles=%0d",which,waited);
  endtask

  initial begin
    $readmemh("x.hex",x_rom);
    $readmemh("cos.hex",cos_rom);
    $readmemh("sin.hex",sin_rom);
    $readmemh("expected.hex",expected_rom);
    repeat(3)@(negedge clk);rst_n=1;
    feed_tables();
    run_head(0);
    run_head(1);
    $display("ROPE_ADAPTER_TWO_HEAD_PASS");
    $finish;
  end
endmodule
