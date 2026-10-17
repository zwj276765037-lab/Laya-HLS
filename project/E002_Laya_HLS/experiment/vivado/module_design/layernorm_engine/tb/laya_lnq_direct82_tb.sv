`timescale 1ns/1ps
module laya_lnq_direct82_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,x_valid=0,gamma_valid=0;
  logic [1:0] source_mode=1;
  logic ln_only_ready=0;
  wire ln_only_valid, ln_only_last;
  logic [1:0] gamma_kind=0;
  logic [15:0] cmd_row=0;
  logic [31:0] x_bits=0,gamma_bits=0;
  logic rd_valid=0,rsp_ready=0,row_release_valid=0,done_ready=0;
  logic [6:0] rd_group=0;
  wire cmd_ready,x_ready,gamma_ready,row_valid,rd_ready,rsp_valid;
  wire [6:0] rsp_group;
  wire [255:0] rsp_q8;
  wire [15:0] rsp_scale;
  wire row_release_ready,done_valid;
  wire [3:0] done_status;
  wire [31:0] done_bad_element,mean_bits,variance_bits,inverse_bits;
  wire norm_valid; wire [9:0] norm_index; wire [31:0] norm_bits;
  logic [31:0] source[0:2623];
  logic [7:0] qgold[0:2623];
  logic [15:0] sgold[0:81];
  laya_lnq_row_v1 dut(.*);
  int cycle=0,half_accepted=0,half_returned=0;

  always @(posedge clk) if(rst_n) begin
    cycle<=cycle+1;
    if(cycle>100000)$fatal(1,"DIRECT82_TIMEOUT");
    if(dut.ln_cmd_valid || dut.ln_out_fire || gamma_ready)
      $fatal(1,"DIRECT82_LN_STARTED");
    if(dut.q_in_fire) begin
      if(dut.q_in_group!==7'(half_accepted/2) ||
         dut.q_in_half!==1'(half_accepted%2))
        $fatal(1,"DIRECT82_INPUT_TAG half=%0d",half_accepted);
      half_accepted<=half_accepted+1;
    end
    if(dut.q_out_fire) begin
      int idx;
      idx=int'(dut.q_out_group)*32+int'(dut.q_out_half)*16;
      if(idx<0 || idx>=2624)$fatal(1,"DIRECT82_OUTPUT_TAG idx=%0d",idx);
      for(int lane=0;lane<16;lane++)
        if(dut.q_out_bits[8*lane+:8]!==qgold[idx+lane])
          $fatal(1,"DIRECT82_Q_GOLD idx=%0d",idx+lane);
      if(dut.q_out_half && dut.q_out_scale!==sgold[dut.q_out_group])
        $fatal(1,"DIRECT82_SCALE_GOLD group=%0d",dut.q_out_group);
      half_returned<=half_returned+1;
    end
  end

  task automatic read_group(input int g);
    logic [255:0] expected_q, held_q;
    logic [15:0] held_s;
    @(negedge clk);
    rd_group=7'(g);rd_valid=1;
    #1ps;if(!rd_ready)$fatal(1,"DIRECT82_READ_READY group=%0d",g);
    @(negedge clk);rd_valid=0;
    for(int wait_cycle=0;wait_cycle<5 && !rsp_valid;wait_cycle++) @(negedge clk);
    if(!rsp_valid || rsp_group!==7'(g) || rsp_scale!==sgold[g])
      $fatal(1,"DIRECT82_READ_SCALE group=%0d",g);
    expected_q=0;
    for(int lane=0;lane<32;lane++)expected_q[8*lane+:8]=qgold[g*32+lane];
    if(rsp_q8!==expected_q)$fatal(1,"DIRECT82_READ_Q group=%0d",g);
    held_q=rsp_q8;held_s=rsp_scale;
    repeat(2)begin
      @(negedge clk);
      if(!rsp_valid || rsp_group!==7'(g) ||
         rsp_q8!==held_q || rsp_scale!==held_s)
        $fatal(1,"DIRECT82_RESPONSE_HOLD group=%0d",g);
    end
    rsp_ready=1;
    @(negedge clk);rsp_ready=0;
  endtask

  initial begin
    string fixture;
    int xidx;
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"DIRECT82_FIXTURE_MISSING");
    $readmemh({fixture,"/down_source_f32.mem"},source);
    $readmemh({fixture,"/down_q.mem"},qgold);
    $readmemh({fixture,"/down_scale.mem"},sgold);
    repeat(4)@(negedge clk);
    rst_n=1;
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"DIRECT82_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;
    xidx=0;
    while(xidx<2624)begin
      x_valid=(cycle%7!=2);
      x_bits=source[xidx];
      @(posedge clk);
      if(x_valid && x_ready)xidx++;
      @(negedge clk);
    end
    x_valid=0;
    for(int wait_cycle=0;wait_cycle<100000 && !row_valid && !done_valid;wait_cycle++)
      @(negedge clk);
    if(!row_valid || done_valid ||
       dut.ln_count!=2624 || half_accepted!=164 || half_returned!=164 ||
       dut.scale_written!=82 || dut.q_accepted_groups!=82 ||
       dut.q_covered_groups!=82 || !dut.q_physical_debt_zero ||
       mean_bits!=0 || variance_bits!=0 || inverse_bits!=0)
      $fatal(1,"DIRECT82_ROW_FAIL count=%0d half=%0d/%0d scale=%0d",
             dut.ln_count,half_accepted,half_returned,dut.scale_written);
    @(negedge clk);rd_group=7'd82;rd_valid=1;
    #1ps;if(rd_ready)$fatal(1,"DIRECT82_ILLEGAL_READ_ACCEPTED");
    @(negedge clk);rd_valid=0;
    for(int g=81;g>=0;g--)read_group(g);
    read_group(32);read_group(64);
    @(negedge clk);rd_group=7'd1;rd_valid=1;row_release_valid=1;
    #1ps;if(rd_ready || !row_release_ready)
      $fatal(1,"DIRECT82_RELEASE_PRIORITY");
    @(negedge clk);rd_valid=0;row_release_valid=0;
    repeat(3)begin
      @(negedge clk);
      if(!done_valid || row_valid || done_status!=0 ||
         done_bad_element!=32'hffffffff)
        $fatal(1,"DIRECT82_DONE_HOLD");
    end
    done_ready=1;
    @(negedge clk);done_ready=0;
    if(!cmd_ready)$fatal(1,"DIRECT82_NOT_REARMED");
    $display("LNQ_DIRECT82_PASS elements=2624 half=164 groups=82 reads=84 cycle=%0d",
             cycle);
    $finish;
  end
endmodule
