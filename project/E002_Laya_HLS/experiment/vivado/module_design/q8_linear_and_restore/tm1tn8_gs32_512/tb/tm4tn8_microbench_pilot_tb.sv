`timescale 1ns/1ps

// Focused pilot: 256 four-row stripes at II1, then reset and complete ACT
// four-row feedback/tail. All R0 expected values are independent signed dots
// with exact F32 scale=1; this is not full real-matrix coverage.
module tm4tn8_microbench_pilot_tb;
  logic clk = 0;
  always #5 clk = ~clk;
  logic rst_n = 0;
  logic config_valid, config_ready, issue_valid, issue_ready;
  logic [15:0] config_k, config_n, config_row0;
  logic [2:0] config_rows;
  logic [159:0] config_identity;
  logic [95:0] issue_identity;
  logic [3:0] issue_version;
  logic [26:0] issue_sequence;
  logic [6:0] issue_group;
  logic [9:0] issue_tile;
  logic [7:0] issue_lane_mask;
  logic [3:0] issue_trace_mask;
  logic [11:0] issue_trace_lane;
  logic [1023:0] issue_a8;
  logic [127:0] issue_sa;
  logic [2047:0] issue_w8;
  logic [255:0] issue_sw;
  logic [3:0] commit_valid, commit_ready, trace_valid, trace_ready;
  logic [767:0] commit_tag, trace_tag, trace_ack_tag;
  logic [39:0] commit_tile;
  logic [31:0] commit_lane_mask, commit_bad_mask;
  logic [95:0] commit_phase;
  logic [1023:0] commit_next_ps, trace_payload;
  logic [7:0] trace_slot, trace_ack_slot;
  logic [3:0] trace_ack_valid, trace_ack_ok;
  logic [23:0] result_free, result_reserved, result_returned;
  logic [11:0] trace_free;
  logic done_valid, done_error, protocol_failure;
  logic [63:0] first_error_rank;
  logic [31:0] first_bad_element;
  logic [26:0] accepted_stripes;
  tm4tn8_microbench_v1 #(.PACKED(0)) dut (.*);

  logic [31:0] expected_ps [0:255][0:3][0:7];
  integer signed running_ps [0:3][0:7];
  integer signed av, wv;
  longint signed dot;
  shortreal expected_f32;
  int commits [0:3];
  int limit;
  bit act_mode;

  task automatic drive_data(input int seq);
    for (int r=0; r<4; r++) begin
      issue_sa[r*32 +: 32] = 32'h3f80_0000;
      for (int k=0; k<32; k++) begin
        av = ((seq*7 + r*23 + k*29) % 256) - 128;
        issue_a8[r*256 + k*8 +: 8] = av[7:0];
      end
    end
    for (int lane=0; lane<8; lane++) begin
      issue_sw[lane*32 +: 32] = 32'h3f80_0000;
      for (int k=0; k<32; k++) begin
        wv = ((seq*11 + lane*17 + k*19) % 256) - 128;
        issue_w8[lane*256 + k*8 +: 8] = wv[7:0];
      end
    end
    for (int r=0; r<4; r++)
      for (int lane=0; lane<8; lane++) begin
        dot = 0;
        for (int k=0; k<32; k++) begin
          av = $signed(issue_a8[r*256 + k*8 +: 8]);
          wv = $signed(issue_w8[lane*256 + k*8 +: 8]);
          dot += av * wv;
        end
        if (act_mode) running_ps[r][lane] += int'(dot);
        else running_ps[r][lane] = int'(dot);
        expected_f32 = running_ps[r][lane];
        expected_ps[seq][r][lane] = $shortrealtobits(expected_f32);
      end
  endtask

  task automatic start_config(input int k, input int n);
    @(negedge clk);
    config_k = k;
    config_n = n;
    config_rows = 4;
    config_row0 = 0;
    config_identity = {32'hf190_d171, 32'h781a_09ce,
                       32'h61b2_819d, 32'h0f80_0000, 32'h9cd2_8100};
    issue_identity = config_identity[159:64];
    issue_version = 4'd1;
    config_valid = 1;
    #1ps;
    if (!config_ready) $fatal(1, "TM4 config not ready");
    @(posedge clk);
    @(negedge clk);
    config_valid = 0;
  endtask

  task automatic reject_case(input int fault);
    act_mode=1;
    limit=1;
    for (int r=0; r<4; r++) begin
      commits[r]=0;
      for (int lane=0; lane<8; lane++) running_ps[r][lane]=0;
    end
    start_config(256,2);
    issue_sequence=0;
    issue_group=0;
    issue_tile=0;
    issue_lane_mask=8'h03;
    drive_data(0);
    issue_valid=1;
    #1ps;
    if (!issue_ready) $fatal(1,"TM4 reject setup not ready fault=%0d",fault);
    @(posedge clk);
    @(negedge clk);
    issue_valid=0;
    for (int timeout=0; timeout<300; timeout++) begin
      if (commits[0]==1 && commits[1]==1 &&
          commits[2]==1 && commits[3]==1) break;
      @(negedge clk);
    end
    if (commits[0]!=1 || commits[1]!=1 ||
        commits[2]!=1 || commits[3]!=1)
      $fatal(1,"TM4 reject setup did not retire fault=%0d",fault);
    issue_sequence=1;
    issue_group=1;
    issue_tile=0;
    case (fault)
      0: issue_identity[95] = ~issue_identity[95];
      1: issue_version = 4'd2;
      2: issue_sequence = 0;
      3: issue_sequence = 2;
      4: issue_tile = 10'd700;
      default: $fatal(1,"bad reject fault");
    endcase
    drive_data(1);
    issue_valid=1;
    #1ps;
    if (!issue_ready || dut.row_issue_valid !== 4'b0000 ||
        (fault==4 && dut.old_ps[0] !== 256'd0))
      $fatal(1,"TM4 reject accepted arithmetic fault=%0d",fault);
    @(posedge clk);
    @(negedge clk);
    issue_valid=0;
    issue_identity=config_identity[159:64];
    issue_version=4'd1;
    for (int timeout=0; timeout<50 && !done_valid; timeout++)
      @(negedge clk);
    if (!done_valid || !done_error || !protocol_failure ||
        accepted_stripes != 1 ||
        commits[0]!=1 || commits[1]!=1 ||
        commits[2]!=1 || commits[3]!=1)
      $fatal(1,"TM4 reject/drain fault=%0d",fault);
    for (int r=0; r<4; r++)
      if (result_free[r*6 +: 6] != 35 ||
          result_reserved[r*6 +: 6] != 0 ||
          result_returned[r*6 +: 6] != 0 ||
          trace_free[r*3 +: 3] != 4)
        $fatal(1,"TM4 reject debt fault=%0d row=%0d",fault,r);
  endtask

  task automatic stall_trace_reset_case;
    logic [191:0] held_tag;
    logic [255:0] held_ps;
    act_mode=1;
    limit=1;
    for (int r=0; r<4; r++) begin
      commits[r]=0;
      for (int lane=0; lane<8; lane++) running_ps[r][lane]=0;
    end
    start_config(256,2);
    issue_sequence=0;
    issue_group=0;
    issue_tile=0;
    issue_lane_mask=8'h03;
    issue_trace_mask=4'b0001;
    issue_trace_lane=0;
    commit_ready=4'b1110;
    drive_data(0);
    issue_valid=1;
    #1ps;
    if (!issue_ready) $fatal(1,"TM4 stall setup not ready");
    @(posedge clk);
    @(negedge clk);
    issue_valid=0;
    for (int timeout=0; timeout<100; timeout++) begin
      if (commit_valid[0] && commits[1]==1 &&
          commits[2]==1 && commits[3]==1) break;
      @(negedge clk);
    end
    if (!commit_valid[0] || commits[0]!=0 ||
        commits[1]!=1 || commits[2]!=1 || commits[3]!=1 ||
        trace_free[2:0]!=3)
      $fatal(1,"TM4 one-row commit stall did not isolate rows");
    held_tag=commit_tag[191:0];
    held_ps=commit_next_ps[255:0];
    repeat (5) begin
      @(negedge clk);
      if (!commit_valid[0] || commit_tag[191:0] !== held_tag ||
          commit_next_ps[255:0] !== held_ps || commits[0]!=0)
        $fatal(1,"TM4 blocked row payload not stable");
    end
    commit_ready=4'hf;
    for (int timeout=0; timeout<20 && commits[0]!=1; timeout++)
      @(negedge clk);
    if (commits[0]!=1) $fatal(1,"TM4 blocked row did not retire");
    for (int timeout=0; timeout<20 && !trace_valid[0]; timeout++)
      @(negedge clk);
    if (!trace_valid[0] || trace_tag[191:0] !== held_tag ||
        trace_payload[191:160] !== expected_ps[0][0][0])
      $fatal(1,"TM4 trace identity/payload mismatch");
    trace_ready[0]=1;
    @(negedge clk);
    trace_ready[0]=0;
    repeat (5) @(negedge clk);
    if (trace_free[2:0]!=3 ||
        result_free[5:0]!=35 || result_reserved[5:0]!=0 ||
        result_returned[5:0]!=0 || accepted_stripes!=1 || done_valid)
      $fatal(1,"TM4 trace ack debt lost before reset");
    rst_n=0;
    repeat (4) @(negedge clk);
    rst_n=1;
    issue_trace_mask=0;
    repeat (2) @(negedge clk);
    if (!config_ready || trace_free[2:0]!=4 ||
        result_free[5:0]!=35 || trace_valid[0] || commit_valid[0])
      $fatal(1,"TM4 trace reset did not clear debt");
  endtask

  task automatic inflight_reset_case;
    act_mode=0;
    limit=0;
    for (int r=0; r<4; r++) commits[r]=0;
    start_config(1024,3072);
    issue_sequence=0;
    issue_group=0;
    issue_tile=0;
    issue_lane_mask=8'hff;
    drive_data(0);
    issue_valid=1;
    #1ps;
    if (!issue_ready) $fatal(1,"TM4 reset setup not ready");
    @(posedge clk);
    @(negedge clk);
    issue_valid=0;
    if (result_free[5:0]!=34 || result_reserved[5:0]!=1)
      $fatal(1,"TM4 reset setup did not reserve Q35");
    rst_n=0;
    repeat (4) @(negedge clk);
    rst_n=1;
    repeat (50) begin
      @(negedge clk);
      if (commit_valid!=0 || trace_valid!=0 || done_valid ||
          protocol_failure || accepted_stripes!=0)
        $fatal(1,"TM4 stale pre-reset return observed");
    end
    if (!config_ready || result_free!=={4{6'd35}} ||
        result_reserved!=0 || result_returned!=0 ||
        trace_free!=={4{3'd4}})
      $fatal(1,"TM4 in-flight reset debt not cleared");
  endtask

  always @(posedge clk) begin
    if (rst_n) begin
      for (int r=0; r<4; r++) begin
        if (int'(result_free[r*6 +: 6]) +
            int'(result_reserved[r*6 +: 6]) +
            int'(result_returned[r*6 +: 6]) != 35)
          $fatal(1, "TM4 Q35 conservation row=%0d", r);
        if (commit_valid[r] && commit_ready[r]) begin
          logic [191:0] tag;
          int seq;
          tag = commit_tag[r*192 +: 192];
          seq = int'(tag[62:36]);
          if (seq < 0 || seq >= limit ||
              tag[159:64] !== config_identity[159:64] ||
              tag[167:164] !== 4'd1 || tag[27:26] !== 2'(r) ||
              {tag[161],tag[25:17]} !== commit_tile[r*10 +: 10] ||
              commit_tile[r*10 +: 10] !== (act_mode ? 10'd0 : 10'(seq)) ||
              commit_lane_mask[r*8 +: 8] !== (act_mode ? 8'h03 : 8'hff) ||
              commit_bad_mask[r*8 +: 8] !== 0)
            $fatal(1, "TM4 commit metadata row=%0d seq=%0d", r, seq);
          for (int lane=0; lane<8; lane++)
            if ((!act_mode || lane < 2) &&
                (commit_phase[r*24 + lane*3 +: 3] !== 3'd4 ||
                 commit_next_ps[r*256 + lane*32 +: 32] !==
                   expected_ps[seq][r][lane]))
              $fatal(1, "TM4 R0 row=%0d seq=%0d lane=%0d got=%h expected=%h",
                     r, seq, lane,
                     commit_next_ps[r*256 + lane*32 +: 32],
                     expected_ps[seq][r][lane]);
          commits[r]++;
        end
      end
    end
  end

  initial begin
    config_valid=0; issue_valid=0; config_k=0; config_n=0;
    config_rows=0; config_row0=0; config_identity=0;
    issue_identity=0; issue_version=0; issue_sequence=0;
    issue_group=0; issue_tile=0; issue_lane_mask=0;
    issue_trace_mask=0; issue_trace_lane=0;
    issue_a8=0; issue_sa=0; issue_w8=0; issue_sw=0;
    commit_ready=4'hf; trace_ready=0; trace_ack_valid=0;
    trace_ack_slot=0; trace_ack_tag=0; trace_ack_ok=4'hf;
    limit=0; act_mode=0;
    for (int r=0; r<4; r++) begin
      commits[r]=0;
      for (int lane=0; lane<8; lane++) running_ps[r][lane]=0;
    end
    repeat (12) @(negedge clk);
    rst_n=1;
    start_config(1024,3072);
    limit=256;
    for (int seq=0; seq<256; seq++) begin
      issue_sequence=27'(seq);
      issue_group=0;
      issue_tile=seq;
      issue_lane_mask=8'hff;
      drive_data(seq);
      issue_valid=1;
      #1ps;
      if (!issue_ready) $fatal(1, "TM4 four-row II1 stalled seq=%0d", seq);
      @(posedge clk);
      @(negedge clk);
    end
    issue_valid=0;
    for (int timeout=0; timeout<300; timeout++) begin
      if (commits[0]==256 && commits[1]==256 &&
          commits[2]==256 && commits[3]==256) break;
      @(negedge clk);
    end
    if (commits[0]!=256 || commits[1]!=256 ||
        commits[2]!=256 || commits[3]!=256 || done_valid)
      $fatal(1, "TM4 four-row drain/unfinished task");
    rst_n=0;
    repeat (4) @(negedge clk);
    rst_n=1;
    act_mode=1;
    for (int r=0; r<4; r++) begin
      commits[r]=0;
      for (int lane=0; lane<8; lane++) running_ps[r][lane]=0;
    end
    start_config(256,2);
    limit=8;
    for (int g=0; g<8; g++) begin
      issue_sequence=27'(g);
      issue_group=g;
      issue_tile=0;
      issue_lane_mask=8'h03;
      drive_data(g);
      issue_valid=1;
      #1ps;
      while (!issue_ready) begin
        @(negedge clk);
        #1ps;
      end
      @(posedge clk);
      @(negedge clk);
      issue_valid=0;
      for (int timeout=0; timeout<300; timeout++) begin
        if (commits[0]==g+1 && commits[1]==g+1 &&
            commits[2]==g+1 && commits[3]==g+1) break;
        @(negedge clk);
      end
      if (commits[0]!=g+1 || commits[1]!=g+1 ||
          commits[2]!=g+1 || commits[3]!=g+1)
        $fatal(1, "TM4 ACT feedback g=%0d", g);
    end
    for (int timeout=0; timeout<300 && !done_valid; timeout++)
      @(negedge clk);
    if (!done_valid || done_error || protocol_failure ||
        accepted_stripes != 8 || first_error_rank !== '1)
      $fatal(1, "TM4 ACT completion/identity");
    for (int fault=0; fault<5; fault++) reject_case(fault);
    stall_trace_reset_case();
    inflight_reset_case();
    $display("TM4TN8_MICROBENCH_PILOT_PASS qkv_four_row_stripes=256 act_four_row_groups=8 rejects=5 blocked_row=1 trace_ack_block=1 inflight_reset=1 commits=1080");
    $finish;
  end
endmodule
