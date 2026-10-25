`timescale 1ns/1ps

module laya_attention_qkv_bank_local_tb;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 0;
  logic wr_valid = 0, wr_ready;
  logic [1:0] wr_plane = 0;
  logic [3:0] wr_head = 0;
  logic [6:0] wr_token = 0;
  logic wr_half = 0;
  logic [31:0][31:0] wr_data;
  logic [2:0] rd_valid = 0, rd_ready;
  logic [2:0][3:0] rd_head = 0;
  logic [2:0][6:0] rd_token = 0;
  logic [2:0][31:0] rd_tag = 0;
  logic [2:0] rd_rsp_valid, rd_rsp_ready = 0;
  logic [2:0][3:0] rd_rsp_head;
  logic [2:0][6:0] rd_rsp_token;
  logic [2:0][31:0] rd_rsp_tag;
  logic [2:0][63:0][31:0] rd_rsp_data;
  int cycles = 0;

  laya_attention_qkv_bank_v1 dut (.*);

  task automatic write_half(input int p, h, t, half);
    @(negedge clk);
    wr_valid=1;
    wr_plane=2'(p); wr_head=4'(h); wr_token=7'(t); wr_half=1'(half);
    for (int lane=0; lane<32; lane++)
      wr_data[lane]=32'(p*32'h01000000 + h*32'h100000 +
                        t*32'h100 + half*32'h40 + lane);
    #1;
    if(!wr_ready) $fatal(1,"QKV_WRITE_DENIED p=%0d h=%0d t=%0d half=%0d",p,h,t,half);
    @(negedge clk); wr_valid=0;
  endtask

  task automatic check_rsp(input int p, h, t, tag);
    if(!rd_rsp_valid[p] || rd_rsp_head[p]!==4'(h) ||
       rd_rsp_token[p]!==7'(t) || rd_rsp_tag[p]!==32'(tag))
      $fatal(1,"QKV_RSP_ID p=%0d h=%0d t=%0d",p,h,t);
    for (int bank=0; bank<64; bank++) begin
      if(rd_rsp_data[p][bank] !==
         32'(p*32'h01000000 + h*32'h100000 + t*32'h100 +
             (bank/32)*32'h40 + bank%32))
        $fatal(1,"QKV_RSP_DATA p=%0d h=%0d t=%0d bank=%0d got=%h",
               p,h,t,bank,rd_rsp_data[p][bank]);
    end
  endtask

  initial begin
    repeat(4) @(negedge clk);
    rst_n=1;
    for(int p=0;p<3;p++)
      for(int half=0;half<2;half++) write_half(p,0,0,half);
    for(int half=0;half<2;half++) write_half(0,15,127,half);

    // The same Q word cannot be read and overwritten on one clock edge.
    @(negedge clk);
    rd_rsp_ready=3'b111;
    wr_valid=1; wr_plane=0; wr_head=0; wr_token=0; wr_half=0;
    rd_valid=3'b001; rd_head[0]=0; rd_token[0]=0; rd_tag[0]=32'h10;
    #1;
    if(wr_ready || !rd_ready[0]) $fatal(1,"QKV_COLLISION_PRIORITY");
    @(negedge clk);
    wr_valid=0; rd_valid=0;
    check_rsp(0,0,0,32'h10);

    // Three physical planes read independently. A held Q response may not
    // change while K/V are consumed.
    @(negedge clk);
    rd_rsp_ready=3'b000;
    rd_valid=3'b111;
    for(int p=0;p<3;p++) begin
      rd_head[p]=0; rd_token[p]=0; rd_tag[p]=32'(32'h20+p);
    end
    @(negedge clk); rd_valid=0;
    repeat(3) begin
      for(int p=0;p<3;p++) check_rsp(p,0,0,32'h20+p);
      if(rd_ready!==3'b000) $fatal(1,"QKV_RSP_BACKPRESSURE");
      @(negedge clk);
    end
    rd_rsp_ready=3'b111;
    @(negedge clk);
    rd_valid=3'b001; rd_head[0]=4'd15; rd_token[0]=7'd127; rd_tag[0]=32'h30;
    @(negedge clk); rd_valid=0;
    check_rsp(0,15,127,32'h30);
    @(negedge clk);
    if(rd_rsp_valid!==3'b000) $fatal(1,"QKV_RSP_DRAIN");
    $display("QKV_BANK_LOCAL_PASS planes=3 banks_per_plane=64 depth=2048 held=3 collision=1 max_addr=2047");
    $finish;
  end

  always @(posedge clk) if(rst_n) begin
    cycles<=cycles+1;
    if(cycles>100) $fatal(1,"QKV_BANK_TIMEOUT");
  end
endmodule
