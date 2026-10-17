`timescale 1ns/1ps

// Focused synchronous pilot: measured 256 four-row stripes, then ACT
// four-row feedback/tail. All R0 expected values are independent signed dots
// with exact F32 scale=1; this is not full real-matrix coverage.
module tm4tn8_sync_ps_pilot_tb_v2;
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
  logic abort_valid=1'b0;
  logic abort_ready;
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
  logic [3:0] final_skip_valid;
  wire [3:0] final_skip_ready=4'hf;
  logic [9:0] final_skip_tile;
  logic [7:0] final_skip_mask;
  tm4tn8_sync_ps_front_v2 #(.PACKED(0)) dut (
    .*,.config_step16(1'b0),.issue_block(2'd0),
    .step_valid(1'b0),.step_ready(),.step_tile(10'd0),
    .step_block(2'd0),.step_done_valid(),.step_done_ready(1'b0),
    .step_done_tile(),.step_done_block(),.step_done_accepted(),
    .step_done_row_retired(),.step_done_terminal(),
    .step_done_error(),.step_done_protocol(),
    .step_done_first_rank(),.step_done_bad());

  logic [31:0] expected_ps [0:255][0:3][0:7];
  integer signed running_ps [0:3][0:7];
  integer signed av, wv;
  longint signed dot;
  shortreal expected_f32;
  int commits [0:3];
  int limit;
  bit act_mode;
  integer cycle_number=0,read_edge[0:255],copy_edge[0:255];

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
    if (!issue_ready || dut.row_issue_valid !== 4'b0000)
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

  task automatic abort_edges_case;
    act_mode=1;limit=8;
    for(int r=0;r<4;r++)begin
      commits[r]=0;
      for(int lane=0;lane<8;lane++)running_ps[r][lane]=0;
    end
    start_config(256,2);
    issue_sequence=0;issue_group=0;issue_tile=0;
    issue_lane_mask=8'h03;issue_trace_mask=0;drive_data(0);
    issue_valid=1;abort_valid=1;
    #1ps;
    if(!abort_ready || issue_ready || dut.accepted || dut.launch)
      $fatal(1,"PS abort did not outrank same-cycle issue");
    @(negedge clk);issue_valid=0;abort_valid=0;
    for(int wait_count=0;wait_count<20 && !done_valid;wait_count++)@(negedge clk);
    if(!done_valid || !done_error || protocol_failure ||
       accepted_stripes!=0 || !dut.external_abort ||
       result_free!=={4{6'd35}} || result_reserved!=0 || result_returned!=0)
      $fatal(1,"PS abort/issue retirement failed");
    $display("SYNC_PS_ABORT_ISSUE_PASS cycle=%0d",cycle_number);

    start_config(256,2);
    issue_sequence=0;issue_group=0;issue_tile=0;
    drive_data(0);issue_valid=1;
    #1ps;if(!issue_ready)$fatal(1,"PS abort launch setup not ready");
    @(negedge clk);issue_valid=0;
    for(int wait_count=0;wait_count<10 && !dut.head_ready;wait_count++)
      @(negedge clk);
    if(!dut.head_ready || dut.entry_count!=1 || dut.launch_stripes_count!=0)
      $fatal(1,"PS abort launch setup not queued");
    abort_valid=1;
    #1ps;
    if(!abort_ready || dut.launch || dut.row_issue_valid!=0)
      $fatal(1,"PS abort did not outrank same-cycle launch");
    @(negedge clk);abort_valid=0;
    for(int wait_count=0;wait_count<20 && !done_valid;wait_count++)@(negedge clk);
    if(!done_valid || !done_error || protocol_failure ||
       accepted_stripes!=1 || dut.launch_stripes_count!=0 ||
       result_free!=={4{6'd35}} || result_reserved!=0 || result_returned!=0)
      $fatal(1,"PS abort/launch retirement failed");
    $display("SYNC_PS_ABORT_LAUNCH_PASS cycle=%0d",cycle_number);

    for(int r=0;r<4;r++)begin
      commits[r]=0;
      for(int lane=0;lane<8;lane++)running_ps[r][lane]=0;
    end
    start_config(256,2);
    for(int g=0;g<8;g++)begin
      issue_sequence=27'(g);issue_group=7'(g);issue_tile=0;
      drive_data(g);issue_valid=1;
      #1ps;
      while(!issue_ready)begin @(negedge clk);#1ps;end
      @(negedge clk);issue_valid=0;
      for(int wait_count=0;wait_count<300 && commits[0]<g+1;wait_count++)
        @(negedge clk);
      if(commits[0]!=g+1 || commits[1]!=g+1 ||
         commits[2]!=g+1 || commits[3]!=g+1)
        $fatal(1,"PS abort final setup group=%0d",g);
    end
    if(done_valid || accepted_stripes!=8 || !dut.all_credits_free ||
       dut.state!=2'd1)$fatal(1,"PS abort final edge not exposed");
    abort_valid=1;
    #1ps;if(!abort_ready)$fatal(1,"PS final-edge abort not ready");
    @(negedge clk);abort_valid=0;
    if(!done_valid || !done_error || protocol_failure || !dut.external_abort ||
       accepted_stripes!=8 || result_free!=={4{6'd35}} ||
       result_reserved!=0 || result_returned!=0)
      $fatal(1,"PS final-edge abort lost to success");
    $display("SYNC_PS_ABORT_FINAL_PASS cycle=%0d",cycle_number);
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

  logic bank_done;
  tm4tn8_sync_banks_tb_v2 bank_test(.clk,.done(bank_done));

  integer launch_edge[0:255],last_read[0:655],last_commit[0:3][0:655];
  integer min_read_gap=1000000,max_read_gap=0,last_read_edge=-1;
  integer min_feedback=1000000;
  always @(posedge clk) begin
    cycle_number++;
    if(!rst_n) begin
      last_read_edge=-1;
      for(int t=0;t<656;t++)begin
        last_read[t]=-1;
        for(int r=0;r<4;r++)last_commit[r][t]=-1;
      end
    end else begin
      if(dut.accepted) begin
        if(issue_group==0 && !act_mode) begin
          read_edge[issue_sequence]=cycle_number;
          if(last_read_edge>=0) begin
            if(cycle_number-last_read_edge<min_read_gap)min_read_gap=cycle_number-last_read_edge;
            if(cycle_number-last_read_edge>max_read_gap)max_read_gap=cycle_number-last_read_edge;
          end
          last_read_edge=cycle_number;
        end
        if(issue_group>0)for(int r=0;r<4;r++)begin
          if(cycle_number<last_commit[r][issue_tile]+1)$fatal(1,"sync PS read before C+1");
          if(cycle_number-last_read[issue_tile]<min_feedback)min_feedback=cycle_number-last_read[issue_tile];
        end
        last_read[issue_tile]=cycle_number;
      end
      if(dut.read_pending && !act_mode && limit==256)begin
        int seq;seq=int'(dut.entry_identity[dut.read_entry][62:36]);
        copy_edge[seq]=cycle_number;
        if(cycle_number!=read_edge[seq]+1)$fatal(1,"sync PS E1 copy seq=%0d",seq);
      end
      if(dut.launch && !act_mode && limit==256)begin
        int seq;seq=int'(dut.entry_identity[dut.head][62:36]);
        launch_edge[seq]=cycle_number;
        if(cycle_number<copy_edge[seq]+1)$fatal(1,"sync PS launch before E2 seq=%0d",seq);
      end
      for(int r=0;r<4;r++)if(commit_valid[r] && commit_ready[r])
        last_commit[r][commit_tile[r*10+:10]]=cycle_number;
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
    if($test$plusargs("ABORT_EDGES"))begin
      abort_edges_case();
      $display("SYNC_PS_ABORT_EDGES_PASS issue=1 launch=1 final=1");
      $finish;
    end
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
      while (!issue_ready) begin @(negedge clk); #1ps; end
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
    wait(bank_done);
    $display("SYNC_PS_EDGE_COUNTS largeT_min_gap=%0d largeT_max_gap=%0d F_PS_min=%0d entries=2 physical_Q35=35",min_read_gap,max_read_gap,min_feedback);
    $display("TM4TN8_SYNC_PS_PILOT_PASS qkv_four_row_stripes=256 act_four_row_groups=8 rejects=5 blocked_row=1 trace_ack_block=1 inflight_reset=1 commits=1080");
    $finish;
  end
endmodule
