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
  int global_clocks=0;
  always @(posedge clk) global_clocks<=global_clocks+1;
  logic [31:0] x0[0:1023],x1[0:1023],g1[0:1023];
  logic [31:0] xerr[0:1023];
  logic [31:0] ylate[0:1023];
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

  // 0: old LN first-error counterexample; 1: nonfinite input; 2: late
  // finite gamma creates a half-scale numerical error; 3: real Q input
  // handshake with one deliberately wrong group tag.
  task automatic run_failure(input int mode);
    int c,xi,gi,q_written,start_count,ln_written;
    bit accepted,injected,forced,seen_done;
    logic [31:0] expect_bad;
    logic [3:0] expect_status;
    begin
      c=0;xi=0;gi=0;q_written=0;start_count=0;ln_written=0;
      accepted=0;injected=0;forced=0;seen_done=0;
      expect_status=(mode==0 || mode==1 || mode==2) ? 4'd6 : 4'd7;
      expect_bad=mode==0 ? 32'd0 : mode==1 ? 32'd7 :
                 mode==2 ? 32'd960 : 32'hffffffff;
      while(!seen_done && c<200000) begin
        @(negedge clk);
        if(forced) begin release dut.q_in_group; forced=0; end
        cmd_valid=!accepted;gamma_kind=mode==2 ? 1 : 0;cmd_row=16'(16+mode);
        x_valid=accepted && xi<1024 && c%7!=0;
        x_bits=mode==0 ? xerr[xi<1024?xi:0] :
               mode==2 ? x1[xi<1024?xi:0] : x0[xi<1024?xi:0];
        if(mode==1 && xi==7) x_bits=32'h7fc00000;
        gamma_valid=accepted && mode==2 && gi<1024;
        gamma_bits=(mode==2 && gi>=960 && gi<992) ?
                   32'h71800000 : g1[gi<1024?gi:0];
        if(mode==3 && !injected && dut.q_in_valid && dut.q_in_ready &&
           dut.half_sent==7'd10) begin
          force dut.q_in_group=7'd31;
          injected=1;forced=1;
        end
        @(posedge clk);
        if(cmd_valid && cmd_ready) accepted=1;
        if(x_valid && x_ready) xi++;
        if(gamma_valid && gamma_ready) gi++;
        if(dut.q_start_fire) start_count++;
        if(dut.q_out_fire) q_written++;
        if(dut.ln_out_fire) begin
          if(mode==2 && (dut.ln_out_index!==10'(ln_written) ||
                         dut.ln_out_bits!==ylate[ln_written]))
            $fatal(1,"LNQ_LATE_LN_GOLD idx=%0d",ln_written);
          ln_written++;
        end
        if(row_valid) $fatal(1,"LNQ_ERROR_PUBLISHED mode=%0d",mode);
        if(done_valid) begin
          if(done_status!==expect_status || done_bad_element!==expect_bad ||
             !dut.q_physical_debt_zero ||
             (mode<2 && start_count!=0) ||
             (mode>=2 && (start_count!=1 || q_written==0)) ||
             (mode==2 && (dut.half_sent!=64 || dut.q_status!=1 ||
                          ln_written!=1024)) ||
             (mode==3 && (!injected || !dut.drop_mode ||
                          dut.ln_count!=1024 || dut.q_status!=2)))
            $fatal(1,"LNQ_ERROR_DONE mode=%0d status=%0d bad=%0d qstart=%0d qwritten=%0d sent=%0d ln=%0d qstatus=%0d",
                   mode,done_status,done_bad_element,start_count,q_written,
                   dut.half_sent,dut.ln_count,dut.q_status);
          seen_done=1;
        end
        c++;
      end
      @(negedge clk);if(forced) release dut.q_in_group;
      cmd_valid=0;x_valid=0;gamma_valid=0;
      if(!seen_done) $fatal(1,"LNQ_ERROR_TIMEOUT mode=%0d",mode);
      repeat(3) begin
        @(posedge clk);
        if(!done_valid || done_status!==expect_status ||
           done_bad_element!==expect_bad || row_valid)
          $fatal(1,"LNQ_ERROR_HOLD mode=%0d",mode);
      end
      @(negedge clk);done_ready=1;
      @(posedge clk);if(!done_valid) $fatal(1,"LNQ_ERROR_DONE_LOST mode=%0d",mode);
      @(negedge clk);done_ready=0;
      if(!cmd_ready) $fatal(1,"LNQ_ERROR_RECOVERY mode=%0d",mode);
      $display("LNQ_ERROR_CASE_PASS mode=%0d cycles=%0d q_written=%0d qstart=%0d",
               mode,c,q_written,start_count);
    end
  endtask

  task automatic reset_inflight;
    int c,xi,cmd_accepts,q_starts,q_input_accepts;
    int pre_reset_half_sent,pre_reset_accepted_groups,pre_reset_covered_groups;
    logic [15:0] pre_reset_row;
    logic [1:0] pre_reset_state;
    bit accepted;
    begin
      c=0;xi=0;accepted=0;cmd_accepts=0;q_starts=0;q_input_accepts=0;
      // The previous completed row may leave q_started/half_sent at 1/64.
      // First prove this command is accepted and clears those counters.
      while(!accepted && c<8) begin
        @(negedge clk);
        cmd_valid=1;gamma_kind=0;cmd_row=16'd31;
        x_valid=0;gamma_valid=0;
        @(posedge clk);
        if(cmd_valid && cmd_ready) begin accepted=1;cmd_accepts++; end
        c++;
      end
      if(!accepted || cmd_accepts!=1) $fatal(1,"LNQ_RESET_CMD_NOT_ACCEPTED");
      @(negedge clk);
      cmd_valid=0;
      if(dut.state!==2'd1 || dut.row!==16'd31 || dut.q_started!==1'b0 ||
         dut.half_sent!==7'd0 || dut.q_accepted_groups!==32'd0)
        $fatal(1,"LNQ_RESET_NEW_ROW_NOT_RUN state=%0d row=%0d started=%b half=%0d groups=%0d",
               dut.state,dut.row,dut.q_started,dut.half_sent,dut.q_accepted_groups);
      $display("LNQ_RESET_CMD_ACCEPTED count=%0d row=%0d state=%0d half=%0d",
               cmd_accepts,dut.row,dut.state,dut.half_sent);
      while(q_input_accepts<2 && c<20000) begin
        @(negedge clk);
        x_valid=xi<1024;
        x_bits=x0[xi<1024?xi:0];
        @(posedge clk);
        if(x_valid && x_ready) xi++;
        if(dut.q_start_fire) q_starts++;
        if(dut.q_in_fire) q_input_accepts++;
        if(row_valid || done_valid || dut.q_done_valid)
          $fatal(1,"LNQ_RESET_ROW_RETIRED_EARLY");
        c++;
      end
      @(negedge clk);
      if(c>=20000 || cmd_accepts!=1 || q_starts!=1 || q_input_accepts<2 ||
         dut.state!==2'd1 || dut.row!==16'd31 || !dut.q_started ||
         !dut.q.active || dut.q_done_valid || dut.half_sent<7'd2 ||
         dut.q_accepted_groups<32'd1 ||
         dut.q_accepted_groups<=dut.q_covered_groups ||
         dut.q_physical_debt_zero || row_valid || done_valid)
        $fatal(1,"LNQ_RESET_NOT_INFLIGHT cmd=%0d qstart=%0d qin=%0d state=%0d row=%0d half=%0d groups=%0d/%0d active=%b debt_zero=%b",
               cmd_accepts,q_starts,q_input_accepts,dut.state,dut.row,
               dut.half_sent,dut.q_accepted_groups,dut.q_covered_groups,
               dut.q.active,dut.q_physical_debt_zero);
      pre_reset_half_sent=dut.half_sent;
      pre_reset_accepted_groups=dut.q_accepted_groups;
      pre_reset_covered_groups=dut.q_covered_groups;
      pre_reset_row=dut.row;pre_reset_state=dut.state;
      $display("LNQ_RESET_INFLIGHT cmd_accepts=%0d row=%0d state=%0d q_starts=%0d q_input_accepts=%0d half_sent=%0d accepted_groups=%0d covered_groups=%0d q_active=%b debt_zero=%b",
               cmd_accepts,pre_reset_row,pre_reset_state,q_starts,q_input_accepts,
               pre_reset_half_sent,pre_reset_accepted_groups,
               pre_reset_covered_groups,dut.q.active,dut.q_physical_debt_zero);
      x_valid=0;rst_n=0;
      repeat(3) @(negedge clk);
      rst_n=1;
      repeat(4) @(negedge clk);
      if(row_valid || done_valid || rsp_valid || !cmd_ready ||
         !dut.q_physical_debt_zero || dut.state!==2'd0 ||
         dut.row!==16'd0 || dut.half_sent!==7'd0 ||
         dut.q_accepted_groups!==32'd0 || dut.q.active)
        $fatal(1,"LNQ_RESET_GHOST");
      $display("LNQ_RESET_PASS cmd_accepts=%0d row=%0d q_input_accepts=%0d pre_reset_half_sent=%0d accepted_groups=%0d covered_groups=%0d post_debt_zero=%b",
               cmd_accepts,pre_reset_row,q_input_accepts,pre_reset_half_sent,
               pre_reset_accepted_groups,pre_reset_covered_groups,
               dut.q_physical_debt_zero);
    end
  endtask

  task automatic run_case(input int testcase,input bit throttle,input bit q_pause);
    int c,xi,gi,ln_seen,read_count,first_ln,first_q,last_q,row_cycle;
    int cmd_global,row_global,done_global,q_start_c,first_half_c,last_half_c;
    int ln_done_c,q_done_c,debt_c;
    int q_blocked;
    bit accepted,q_forced,prev_q_block;
    logic [127:0] held_q;
    logic [15:0] held_scale;
    logic [6:0] held_group;
    logic held_half;
    begin
      c=0;xi=0;gi=0;ln_seen=0;read_count=0;accepted=0;
      first_ln=-1;first_q=-1;last_q=-1;row_cycle=-1;
      q_blocked=0;q_forced=0;prev_q_block=0;
      cmd_global=-1;row_global=-1;done_global=-1;
      q_start_c=-1;first_half_c=-1;last_half_c=-1;
      ln_done_c=-1;q_done_c=-1;debt_c=-1;
      while(!row_valid && c<200000) begin
        @(negedge clk);
        cmd_valid=!accepted;gamma_kind=testcase==0 ? 0 : 1;
        cmd_row=16'(testcase);
        x_valid=accepted && xi<1024 && (!throttle || c%7!=0);
        x_bits=testcase==0 ? x0[xi<1024?xi:0] : x1[xi<1024?xi:0];
        gamma_valid=accepted && testcase!=0 && gi<1024 && (!throttle || c%5!=1);
        gamma_bits=g1[gi<1024?gi:0];
        if(q_pause) begin
          if(c%11<4) force dut.q_out_ready=1'b0;
          else force dut.q_out_ready=1'b1;
          q_forced=1;
        end
        @(posedge clk);
        if(cmd_valid && cmd_ready) begin accepted=1;cmd_global=global_clocks;end
        if(x_valid && x_ready) xi++;
        if(gamma_valid && gamma_ready) gi++;
        if(dut.q_start_fire && q_start_c<0) q_start_c=c;
        if(dut.q_in_fire) begin
          if(first_half_c<0) first_half_c=c;
          last_half_c=c;
        end
        if(dut.ln_done_fire && ln_done_c<0) ln_done_c=c;
        if(dut.q_done_fire && q_done_c<0) q_done_c=c;
        if(q_start_c>=0 && dut.q_done_seen &&
           dut.q_physical_debt_zero && debt_c<0) debt_c=c;
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
        if(prev_q_block && (!dut.q_out_valid ||
           dut.q_out_bits!==held_q || dut.q_out_scale!==held_scale ||
           dut.q_out_group!==held_group || dut.q_out_half!==held_half))
          $fatal(1,"LNQ_Q_OUTPUT_HOLD case=%0d",testcase);
        prev_q_block=dut.q_out_valid && !dut.q_out_ready;
        if(prev_q_block) begin
          q_blocked++;
          held_q=dut.q_out_bits;held_scale=dut.q_out_scale;
          held_group=dut.q_out_group;held_half=dut.q_out_half;
        end
        c++;
      end
      if(!row_valid || !accepted || xi!=1024 || (testcase!=0 && gi!=1024) ||
         ln_seen!=1024 || !dut.ln_done_seen || !dut.q_done_seen ||
         !dut.q_physical_debt_zero || dut.half_sent!=64 ||
         dut.half_written!=64 || dut.scale_written!=32 || done_valid ||
         mean_bits!==(testcase==0 ? st0[0] : st1[0]) ||
         variance_bits!==(testcase==0 ? st0[1] : st1[1]) ||
         inverse_bits!==(testcase==0 ? st0[2] : st1[2]) ||
         (q_pause && q_blocked==0))
        $fatal(1,"LNQ_ROW case=%0d c=%0d row=%b x=%0d gamma=%0d ln=%0d half=%0d/%0d scale=%0d lndone=%b qdone=%b debt=%b",
               testcase,c,row_valid,xi,gi,ln_seen,dut.half_sent,dut.half_written,
               dut.scale_written,dut.ln_done_seen,dut.q_done_seen,dut.q_physical_debt_zero);
      row_cycle=c;
      row_global=global_clocks;
      @(negedge clk);if(q_forced) release dut.q_out_ready;
      cmd_valid=0;x_valid=0;gamma_valid=0;
      @(negedge clk);cmd_valid=1;
      repeat(2) begin
        @(posedge clk);
        if(cmd_ready) $fatal(1,"LNQ_ROW_OVERWRITE case=%0d",testcase);
      end
      @(negedge clk);cmd_valid=0;
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
      done_global=global_clocks;
      @(negedge clk);done_ready=0;
      if(!cmd_ready || done_valid) $fatal(1,"LNQ_NEXT_CMD");
      $display("LNQ_ROW_CASE_PASS case=%0d cmd_to_row_delta=%0d cmd_to_done_delta=%0d row_cycle=%0d first_ln=%0d q_start=%0d q_first_last_in=%0d/%0d q_first_last_out=%0d/%0d ln_done=%0d q_done=%0d debt=%0d reads=%0d q_blocked=%0d",
               testcase,row_global-cmd_global,done_global-cmd_global,row_cycle,
               first_ln,q_start_c,first_half_c,last_half_c,first_q,last_q,
               ln_done_c,q_done_c,debt_c,read_count,q_blocked);
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
    $readmemh({f,"/xerr.mem"},xerr);
    $readmemh({f,"/ylate.mem"},ylate);
    repeat(4) @(negedge clk);rst_n=1;
    if($test$plusargs("RESET_ONLY")) begin
      run_case(0,0,0);
      reset_inflight();
      run_case(0,1,0);
      $display("LNQ_RESET_SCOPE_PASS prior_row=1 reset_inflight=1 post_row=1 gold=P1_original_input_stats_q");
      $finish;
    end
    run_case(0,0,0);
    run_case(1,1,1);
    run_case(0,1,0);
    run_failure(0);
    run_failure(1);
    run_failure(2);
    run_failure(3);
    run_case(0,0,0);
    reset_inflight();
    run_case(0,1,0);
    $display("LNQ_ROW_PASS cases=5 errors=4 reset=1 q_backpressure=1 gold=P1_original_input_stats_q");
    $finish;
  end
  initial begin repeat(1000000) @(posedge clk); $fatal(1,"LNQ_TIMEOUT"); end
endmodule
