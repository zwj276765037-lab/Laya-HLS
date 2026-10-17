`timescale 1ns/1ps

// Frozen external producer rows and independent NumPy Q8/half/scalar oracle.
// Handshakes, actual bank reads, divider, sixteen FMULs and output commit all
// execute in one clocked service; no testbench queue substitutes for an IP.
module quant16_stream_row_tb;
  logic clk=0, rst=1, start_valid=0, in_valid=0, out_ready=0, done_ready=0;
  wire start_ready, in_ready, out_valid, done_valid;
  logic [31:0] cfg_task_id=0, cfg_source_epoch=0;
  logic [15:0] cfg_row=0;
  logic [7:0] cfg_groups=0;
  logic [511:0] in_lanes=0;
  logic [31:0] in_task_id=0, in_source_epoch=0;
  logic [15:0] in_row=0, in_mask=16'hffff;
  logic [6:0] in_group=0;
  logic in_half=0;
  wire [6:0] out_group;
  wire out_half;
  wire [127:0] out_q;
  wire [15:0] out_scale;
  wire [31:0] out_d_full, out_reciprocal;
  wire [1:0] done_status;
  wire [15:0] first_bad_col;
  wire [31:0] accepted_groups, covered_groups;
  wire [31:0] scale_issues, scale_returns, recip_issues, recip_returns;
  wire [31:0] amax_read_beats, replay_read_beats;
  wire [31:0] mul_halves_issued, mul_halves_returned;
  logic [31:0] wi_source [0:1023], down_source [0:2623];
  logic [7:0] wi_q [0:1023], down_q [0:2623];
  logic [15:0] wi_scale [0:31], down_scale [0:81];
  logic [31:0] wi_amax [0:31], wi_d [0:31], wi_recip [0:31];
  logic [31:0] down_amax [0:81], down_d [0:81], down_recip [0:81];
  string fixture;

  always #3.333 clk=~clk;
  quant16_stream_row dut (.*);

  task automatic run_case(input bit use_down, input int groups);
    int sent, got, cycles, group, half, expected_recip_count;
    logic [31:0] expected_d, expected_recip;
    logic [15:0] expected_scale;
    logic [7:0] expected_q;
    bit finished;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=0;
      done_ready=0;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=use_down ? 32'd202 : 32'd101;
      cfg_source_epoch=use_down ? 32'd22 : 32'd11;
      cfg_row=use_down ? 16'd7 : 16'd3;
      cfg_groups=8'(groups);
      expected_recip_count=0;
      for (int i=0;i<groups;i++)
        if ((use_down ? down_d[i] : wi_d[i])!=0)
          expected_recip_count++;
      #1ps;
      if (!start_ready) $fatal(1,"stream start not ready case=%0d",use_down);
      @(posedge clk);
      @(negedge clk);
      start_valid=0;
      sent=0; got=0; cycles=0; finished=0;
      while (!finished) begin
        in_valid=(sent<groups*2);
        out_ready=(cycles%5!=2);
        if (in_valid) begin
          in_task_id=cfg_task_id;
          in_source_epoch=cfg_source_epoch;
          in_row=cfg_row;
          in_group=7'(sent/2);
          in_half=1'(sent%2);
          in_mask=16'hffff;
          for (int lane=0;lane<16;lane++)
            in_lanes[lane*32 +: 32]=use_down ?
                down_source[sent*16+lane] : wi_source[sent*16+lane];
        end
        @(posedge clk);
        if (in_valid && in_ready) sent++;
        if (dut.div_fire) begin
          int ordinal;
          logic [31:0] expected_operand;
          ordinal=int'(dut.div_tag[32:1]);
          if (ordinal<0 || ordinal>=groups)
            $fatal(1,"stream divider ordinal case=%0d ordinal=%0d",
                   use_down,ordinal);
          expected_operand=dut.div_phase ?
              (use_down ? down_d[ordinal] : wi_d[ordinal]) :
              (use_down ? down_amax[ordinal] : wi_amax[ordinal]);
          if ((dut.div_phase ? dut.div_denominator : dut.div_numerator)!==
              expected_operand)
            $fatal(1,"stream divider operand case=%0d ordinal=%0d phase=%0d",
                   use_down,ordinal,dut.div_phase);
        end
        if (out_valid && out_ready) begin
          group=got/2; half=got%2;
          if (out_group!==7'(group) || out_half!==1'(half))
            $fatal(1,"stream output order case=%0d got=%0d group=%0d half=%0d",
                   use_down,got,out_group,out_half);
          expected_d=use_down ? down_d[group] : wi_d[group];
          expected_recip=use_down ? down_recip[group] : wi_recip[group];
          expected_scale=half ? (use_down ? down_scale[group] : wi_scale[group]) : 0;
          if (out_d_full!==expected_d || out_reciprocal!==expected_recip ||
              out_scale!==expected_scale)
            $fatal(1,"stream scalar mismatch case=%0d group=%0d half=%0d d=%08x/%08x r=%08x/%08x h=%04x/%04x",
                   use_down,group,half,out_d_full,expected_d,
                   out_reciprocal,expected_recip,out_scale,expected_scale);
          for (int lane=0;lane<16;lane++) begin
            expected_q=use_down ? down_q[group*32+half*16+lane] :
                                  wi_q[group*32+half*16+lane];
            if (out_q[lane*8 +: 8]!==expected_q)
              $fatal(1,"stream q mismatch case=%0d col=%0d got=%02x expected=%02x",
                     use_down,group*32+half*16+lane,
                     out_q[lane*8 +: 8],expected_q);
          end
          got++;
        end
        if (done_valid) begin
          if (done_status!==0 || first_bad_col!==16'hffff ||
              sent!=groups*2 || got!=groups*2 ||
              accepted_groups!=groups || covered_groups!=groups ||
              scale_issues!=groups || scale_returns!=groups ||
              recip_issues!=expected_recip_count ||
              recip_returns!=expected_recip_count ||
              amax_read_beats!=groups*2 || replay_read_beats!=groups*2 ||
              mul_halves_issued!=groups*2 || mul_halves_returned!=groups*2)
            $fatal(1,"stream debt/READY case=%0d status=%0d sent=%0d got=%0d accepted=%0d covered=%0d scale=%0d/%0d recip=%0d/%0d read=%0d/%0d mul=%0d/%0d",
                   use_down,done_status,sent,got,accepted_groups,covered_groups,
                   scale_issues,scale_returns,recip_issues,recip_returns,
                   amax_read_beats,replay_read_beats,
                   mul_halves_issued,mul_halves_returned);
          finished=1;
          $display("QUANT16_STREAM_ROW_PASS case=%0d groups=%0d cycles=%0d q_bytes=%0d",
                   use_down,groups,cycles,groups*32);
        end
        cycles++;
        if (cycles>10000)
          $fatal(1,"stream watchdog case=%0d sent=%0d got=%0d cap=%0d write=%0d pending bank=%0d amax=%0d div=%0d mul=%0d",
                 use_down,sent,got,dut.capture_group,dut.write_group,
                 dut.bank_reads_pending,dut.amax_pending,dut.div_pending,
                 dut.mul_pending);
        @(negedge clk);
      end
    end
  endtask

  task automatic run_numeric_error(input int case_id, input int groups,
                                    input int expected_col,
                                    input int expected_scale,
                                    input int expected_recip);
    int sent, got, cycles;
    bit finished;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=1;
      done_ready=0;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=32'(400+case_id);
      cfg_source_epoch=32'(40+case_id);
      cfg_row=16'(case_id);
      cfg_groups=8'(groups);
      @(posedge clk);
      @(negedge clk);
      start_valid=0; sent=0; got=0; cycles=0; finished=0;
      while (!finished) begin
        in_valid=(sent<groups*2);
        if (in_valid) begin
          in_task_id=cfg_task_id; in_source_epoch=cfg_source_epoch;
          in_row=cfg_row; in_group=7'(sent/2);
          in_half=1'(sent%2); in_mask=16'hffff;
          for (int lane=0;lane<16;lane++)
            in_lanes[lane*32 +: 32]=wi_source[sent*16+lane];
        end
        @(posedge clk);
        if (in_valid && in_ready) sent++;
        if (out_valid && out_ready) got++;
        if (done_valid) begin
          if (done_status!==1 || first_bad_col!==16'(expected_col) ||
              sent!=groups*2 || got!=0 || accepted_groups!=groups ||
              covered_groups!=0 || scale_issues!=expected_scale ||
              scale_returns!=expected_scale ||
              recip_issues!=expected_recip ||
              recip_returns!=expected_recip ||
              amax_read_beats!=groups*2 || replay_read_beats!=0 ||
              mul_halves_issued!=0 || mul_halves_returned!=0)
            $fatal(1,"stream numerical case=%0d status=%0d col=%0d sent=%0d got=%0d amax_bits=%08x d_bits=%08x reciprocal_bits=%08x scale=%0d/%0d recip=%0d/%0d amax=%0d replay=%0d mul=%0d/%0d",
                   case_id,done_status,first_bad_col,sent,got,
                   dut.amax[0],dut.d_full[0],dut.reciprocal[0],
                   scale_issues,scale_returns,recip_issues,recip_returns,
                   amax_read_beats,replay_read_beats,
                   mul_halves_issued,mul_halves_returned);
          finished=1;
          $display("QUANT16_STREAM_NUMERIC_PASS case=%0d groups=%0d first_col=%0d scale=%0d recip=%0d",
                   case_id,groups,expected_col,expected_scale,expected_recip);
        end
        cycles++;
        if (cycles>2000)
          $fatal(1,"stream numerical watchdog case=%0d sent=%0d got=%0d",
                 case_id,sent,got);
        @(negedge clk);
      end
    end
  endtask

  task automatic run_reset_inflight(input bit wait_for_mul);
    int sent, cycles;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=1;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=wait_for_mul ? 32'd602 : 32'd601;
      cfg_source_epoch=wait_for_mul ? 32'd62 : 32'd61;
      cfg_row=16'd6; cfg_groups=8'd1;
      @(posedge clk);
      @(negedge clk);
      start_valid=0; sent=0; cycles=0;
      while (sent<2) begin
        in_valid=1;
        in_task_id=cfg_task_id; in_source_epoch=cfg_source_epoch;
        in_row=cfg_row; in_group=0; in_half=1'(sent);
        in_mask=16'hffff;
        for (int lane=0;lane<16;lane++)
          in_lanes[lane*32 +: 32]=wi_source[sent*16+lane];
        @(posedge clk);
        if (in_ready) sent++;
        @(negedge clk);
        cycles++;
        if (cycles>50) $fatal(1,"reset injection capture watchdog");
      end
      in_valid=0;
      cycles=0;
      while (wait_for_mul ? dut.mul_pending==0 : dut.div_pending==0) begin
        @(negedge clk);
        cycles++;
        if (cycles>200) $fatal(1,"reset injection pending watchdog kind=%0d",wait_for_mul);
      end
      rst=1;
      repeat (2) @(negedge clk);
      if (done_valid || out_valid || dut.div_pending!=0 ||
          dut.mul_pending!=0 || dut.protocol_error)
        $fatal(1,"reset did not cancel in-flight service kind=%0d",wait_for_mul);
      $display("QUANT16_STREAM_RESET_INFLIGHT_PASS kind=%0d",wait_for_mul);
    end
  endtask

  task automatic run_bad_second_mask;
    int cycles;
    begin
      @(negedge clk);
      rst=1; start_valid=0; in_valid=0; out_ready=1;
      repeat (3) @(negedge clk);
      rst=0; start_valid=1;
      cfg_task_id=32'd303; cfg_source_epoch=32'd33;
      cfg_row=16'd9; cfg_groups=8'd8;
      @(posedge clk);
      @(negedge clk);
      start_valid=0; in_valid=1;
      in_task_id=cfg_task_id; in_source_epoch=cfg_source_epoch;
      in_row=cfg_row; in_group=0; in_half=0;
      in_mask=16'hffff; in_lanes=0;
      @(posedge clk);
      if (!in_ready) $fatal(1,"protocol first half not accepted");
      @(negedge clk);
      in_half=1; in_mask=16'hfffe;
      @(posedge clk);
      if (!in_ready) $fatal(1,"protocol malformed half not consumed");
      @(negedge clk);
      in_valid=0; cycles=0;
      while (!done_valid) begin
        @(posedge clk);
        if (out_valid) $fatal(1,"protocol partial output published");
        cycles++;
        if (cycles>100) $fatal(1,"protocol drain watchdog");
        @(negedge clk);
      end
      if (done_status!==2 || accepted_groups!==1 || covered_groups!==0 ||
          dut.drain_groups!==1 || dut.bank_reads_pending!==0 ||
          dut.amax_pending!==0 || dut.div_pending!==0 ||
          dut.mul_pending!==0)
        $fatal(1,"protocol malformed half retirement");
      $display("QUANT16_STREAM_PROTOCOL_PASS bad_second_mask=1");
    end
  endtask

  initial begin
    if (!$value$plusargs("FIXTURE=%s",fixture))
      $fatal(1,"FIXTURE plusarg required");
    $readmemh({fixture,"/wi_source_f32.mem"},wi_source);
    $readmemh({fixture,"/wi_q.mem"},wi_q);
    $readmemh({fixture,"/wi_scale.mem"},wi_scale);
    $readmemh({fixture,"/wi_amax.mem"},wi_amax);
    $readmemh({fixture,"/wi_d_full.mem"},wi_d);
    $readmemh({fixture,"/wi_reciprocal.mem"},wi_recip);
    $readmemh({fixture,"/down_source_f32.mem"},down_source);
    $readmemh({fixture,"/down_q.mem"},down_q);
    $readmemh({fixture,"/down_scale.mem"},down_scale);
    $readmemh({fixture,"/down_amax.mem"},down_amax);
    $readmemh({fixture,"/down_d_full.mem"},down_d);
    $readmemh({fixture,"/down_reciprocal.mem"},down_recip);
    run_case(0,32);
    run_case(1,82);
    for (int i=0;i<64;i++) begin
      wi_source[i]=0;
      wi_q[i]=0;
    end
    wi_amax[0]=0; wi_d[0]=0; wi_recip[0]=0; wi_scale[0]=0;
    wi_source[32]=32'h42fe0000; wi_q[32]=8'h7f;
    wi_source[33]=32'h3f000000; wi_q[33]=8'h01;
    wi_source[34]=32'hbf000000; wi_q[34]=8'hff;
    wi_source[35]=32'h3fc00000; wi_q[35]=8'h02;
    wi_source[36]=32'hbfc00000; wi_q[36]=8'hfe;
    wi_source[37]=32'h42fd0000; wi_q[37]=8'h7f;
    wi_source[38]=32'hc2fd0000; wi_q[38]=8'h81;
    wi_amax[1]=32'h42fe0000;
    wi_d[1]=32'h3f800000; wi_recip[1]=32'h3f800000;
    wi_scale[1]=16'h3c00;
    run_case(0,2);
    run_bad_second_mask();
    for (int i=0;i<64;i++) wi_source[i]=0;
    wi_source[0]=32'h501502f9; // F32 1.0e10, half(d_full) overflows.
    run_numeric_error(2,1,0,1,1);
    wi_source[0]=0; wi_source[5]=32'h7f800000;
    run_numeric_error(3,1,5,0,0);
    wi_source[5]=0;
    wi_source[0]=32'h501502f9;
    wi_source[32+3]=32'h7f800000;
    run_numeric_error(4,2,0,1,1); // Later group fails earlier in wall time.
    wi_source[0]=0; wi_source[32+3]=32'h7f800000;
    wi_source[1]=32'h7fc00000;
    run_numeric_error(5,2,1,0,0); // Both slots need independent poison.
    for (int i=0;i<64;i++) begin
      wi_source[i]=0;
      wi_q[i]=0;
    end
    wi_amax[0]=0; wi_d[0]=0; wi_recip[0]=0; wi_scale[0]=0;
    wi_source[32]=32'h42fe0000; wi_q[32]=8'h7f;
    wi_source[33]=32'h3f000000; wi_q[33]=8'h01;
    wi_source[34]=32'hbf000000; wi_q[34]=8'hff;
    wi_source[35]=32'h3fc00000; wi_q[35]=8'h02;
    wi_source[36]=32'hbfc00000; wi_q[36]=8'hfe;
    wi_source[37]=32'h42fd0000; wi_q[37]=8'h7f;
    wi_source[38]=32'hc2fd0000; wi_q[38]=8'h81;
    wi_amax[1]=32'h42fe0000;
    wi_d[1]=32'h3f800000; wi_recip[1]=32'h3f800000;
    wi_scale[1]=16'h3c00;
    run_reset_inflight(0);
    run_case(0,2);
    run_reset_inflight(1);
    run_case(0,2);
    $display("QUANT16_STREAM_OTHER_BOUNDARIES_PASS numerical=4 reset=2 protocol=1");
    wi_source[0]=32'h006ce3ee; // Frozen CPU boundary: F32 1.0e-38.
    run_numeric_error(1,1,0,1,1); // Reciprocal nonfinite.
    $display("QUANT16_STREAM_REAL_ROWS_PASS groups=114 q_bytes=3648 edges=2 protocol=1 numerical=5 reset=2");
    $finish;
  end
endmodule
