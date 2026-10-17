`timescale 1ns/1ps
module laya_lnq_row_v1_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,gamma_valid=0,x_valid=0;
  logic [1:0] gamma_kind=0;
  logic [15:0] cmd_row=0;
  logic [31:0] x_bits=0,gamma_bits=0;
  logic rd_valid=0,rsp_ready=0,row_release_valid=0,done_ready=0;
  logic [4:0] rd_group=0;
  wire cmd_ready,gamma_ready,x_ready,row_valid,rd_ready,rsp_valid;
  wire [4:0] rsp_group;
  wire [255:0] rsp_q8;
  wire [15:0] rsp_scale;
  wire row_release_ready,done_valid;
  wire [3:0] done_status;
  wire [31:0] done_bad_element,mean_bits,variance_bits,inverse_bits;
  logic [31:0] x0[0:1023],x1[0:1023],g1[0:1023];
  logic [31:0] y0[0:1023],y1[0:1023],st0[0:2],st1[0:2];
  logic [7:0] q0[0:1023],q1[0:1023];
  logic [15:0] scale0[0:31],scale1[0:31];
  laya_lnq_row_v1 dut(.*);

  task automatic read_group(input int testcase,input int group);
    logic [255:0] expected_q,held_q;
    logic [15:0] expected_scale,held_scale;
    logic [4:0] held_group;
    int n;
    begin
      expected_q=0;
      for(int lane=0;lane<32;lane++)
        expected_q[8*lane+:8]=testcase==0 ? q0[32*group+lane] : q1[32*group+lane];
      expected_scale=testcase==0 ? scale0[group] : scale1[group];
      @(negedge clk);rd_valid=1;rd_group=5'(group);rsp_ready=0;
      @(posedge clk);if(!rd_ready) $fatal(1,"LNQ_RD_NOT_READY case=%0d group=%0d",testcase,group);
      @(negedge clk);rd_valid=0;
      n=0;
      while(!rsp_valid && n<8) begin @(posedge clk); n++; end
      if(!rsp_valid || rsp_group!==5'(group) ||
         rsp_q8!==expected_q || rsp_scale!==expected_scale)
        $fatal(1,"LNQ_READ_GOLD case=%0d group=%0d got_scale=%04x exp=%04x got_q=%h exp=%h",
               testcase,group,rsp_scale,expected_scale,rsp_q8,expected_q);
      held_q=rsp_q8;held_scale=rsp_scale;held_group=rsp_group;
      repeat(3) begin
        @(posedge clk);
        if(!rsp_valid || rsp_q8!==held_q || rsp_scale!==held_scale ||
           rsp_group!==held_group || row_release_ready)
          $fatal(1,"LNQ_RSP_HOLD case=%0d group=%0d",testcase,group);
      end
      @(negedge clk);rsp_ready=1;
      @(posedge clk);if(!rsp_valid) $fatal(1,"LNQ_RSP_MISSING");
      @(negedge clk);rsp_ready=0;
    end
  endtask

  task automatic run_case(input int testcase,input bit throttle);
    int c,xi,gi,ln_seen,read_count,first_ln,first_q,last_q,row_cycle;
    bit accepted;
    begin
      c=0;xi=0;gi=0;ln_seen=0;read_count=0;accepted=0;
      first_ln=-1;first_q=-1;last_q=-1;row_cycle=-1;
      while(!row_valid && c<200000) begin
        @(negedge clk);
        cmd_valid=!accepted;gamma_kind=testcase==0 ? 0 : 1;
        cmd_row=16'(testcase);
        x_valid=accepted && xi<1024 && (!throttle || c%7!=0);
        x_bits=testcase==0 ? x0[xi<1024?xi:0] : x1[xi<1024?xi:0];
        gamma_valid=accepted && testcase!=0 && gi<1024 && (!throttle || c%5!=1);
        gamma_bits=g1[gi<1024?gi:0];
        @(posedge clk);
        if(cmd_valid && cmd_ready) accepted=1;
        if(x_valid && x_ready) xi++;
        if(gamma_valid && gamma_ready) gi++;
        if(dut.ln_out_fire) begin
          if(first_ln<0) first_ln=c;
          if(dut.ln_out_index!==10'(ln_seen) ||
             dut.ln_out_bits!==(testcase==0 ? y0[ln_seen] : y1[ln_seen]))
            $fatal(1,"LNQ_LN_GOLD case=%0d idx=%0d",testcase,ln_seen);
          ln_seen++;
        end
        if(dut.q_out_fire) begin
          if(first_q<0) first_q=c;
          last_q=c;
        end
        c++;
      end
      if(!row_valid || !accepted || xi!=1024 || (testcase!=0 && gi!=1024) ||
         ln_seen!=1024 || !dut.ln_done_seen || !dut.q_done_seen ||
         !dut.q_physical_debt_zero || dut.half_sent!=64 ||
         dut.half_written!=64 || dut.scale_written!=32 || done_valid ||
         mean_bits!==(testcase==0 ? st0[0] : st1[0]) ||
         variance_bits!==(testcase==0 ? st0[1] : st1[1]) ||
         inverse_bits!==(testcase==0 ? st0[2] : st1[2]))
        $fatal(1,"LNQ_ROW case=%0d c=%0d row=%b x=%0d gamma=%0d ln=%0d half=%0d/%0d scale=%0d lndone=%b qdone=%b debt=%b",
               testcase,c,row_valid,xi,gi,ln_seen,dut.half_sent,dut.half_written,
               dut.scale_written,dut.ln_done_seen,dut.q_done_seen,dut.q_physical_debt_zero);
      row_cycle=c;
      @(negedge clk);cmd_valid=0;x_valid=0;gamma_valid=0;
      for(int g=31;g>=0;g--) begin read_group(testcase,g);read_count++; end
      read_group(testcase,17);read_count++;
      read_group(testcase,0);read_count++;
      @(negedge clk);rd_valid=1;rd_group=5'd1;row_release_valid=1;
      @(posedge clk);
      if(!row_release_ready || rd_ready) $fatal(1,"LNQ_RELEASE_PRIORITY");
      @(negedge clk);rd_valid=0;row_release_valid=0;
      repeat(4) begin
        @(posedge clk);
        if(!done_valid || row_valid || done_status!==0 ||
           done_bad_element!==32'hffffffff || cmd_ready)
          $fatal(1,"LNQ_DONE_HOLD case=%0d",testcase);
      end
      @(negedge clk);done_ready=1;
      @(posedge clk);if(!done_valid) $fatal(1,"LNQ_DONE_LOST");
      @(negedge clk);done_ready=0;
      if(!cmd_ready || done_valid) $fatal(1,"LNQ_NEXT_CMD");
      $display("LNQ_ROW_CASE_PASS case=%0d row_cycle=%0d first_ln=%0d first_q=%0d last_q=%0d reads=%0d",
               testcase,row_cycle,first_ln,first_q,last_q,read_count);
    end
  endtask

  initial begin
    string f;
    if(!$value$plusargs("FIXTURE=%s",f)) $fatal(1,"LNQ_FIXTURE_MISSING");
    $readmemh({f,"/x0.mem"},x0);$readmemh({f,"/x1.mem"},x1);
    $readmemh({f,"/g1.mem"},g1);$readmemh({f,"/y0.mem"},y0);
    $readmemh({f,"/y1.mem"},y1);$readmemh({f,"/st0.mem"},st0);
    $readmemh({f,"/st1.mem"},st1);$readmemh({f,"/q0.mem"},q0);
    $readmemh({f,"/q1.mem"},q1);$readmemh({f,"/scale0.mem"},scale0);
    $readmemh({f,"/scale1.mem"},scale1);
    repeat(4) @(negedge clk);rst_n=1;
    run_case(0,0);
    run_case(1,1);
    run_case(0,1);
    $display("LNQ_ROW_PASS cases=3 gold=P1_original_input_stats_q");
    $finish;
  end
  initial begin repeat(1000000) @(posedge clk); $fatal(1,"LNQ_TIMEOUT"); end
endmodule
