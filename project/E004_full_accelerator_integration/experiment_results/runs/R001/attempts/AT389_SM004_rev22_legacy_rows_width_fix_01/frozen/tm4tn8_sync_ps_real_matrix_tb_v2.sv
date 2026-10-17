`timescale 1ns/1ps

// Full accepted-matrix replay of already quantized independent fixture data.
// The test observes every row/lane FP stage and every committed group PS.
module tm4tn8_sync_ps_real_matrix_tb_v2 #(parameter integer PACKED=0);
  localparam int MAX_STRIPES=21504;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n, config_valid, config_ready, issue_valid, issue_ready;
  logic [15:0] config_k, config_n, config_row0;
  logic [4:0] config_rows;
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
  wire abort_valid=1'b0;
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
  tm4tn8_sync_ps_front_v2 #(.PACKED(PACKED != 0)) dut (
    .*,.config_step16(1'b0),.issue_block(2'd0),
    .step_valid(1'b0),.step_ready(),.step_tile(10'd0),
    .step_block(2'd0),.step_done_valid(),.step_done_ready(1'b0),
    .step_done_tile(),.step_done_block(),.step_done_accepted(),
    .step_done_row_retired(),.step_done_terminal(),
    .step_done_error(),.step_done_protocol(),
    .step_done_first_rank(),.step_done_bad());

  logic [1023:0] va [0:MAX_STRIPES-1];
  logic [127:0] vsa [0:MAX_STRIPES-1];
  logic [2047:0] vw [0:MAX_STRIPES-1];
  logic [255:0] vsw [0:MAX_STRIPES-1];
  logic [1023:0] vdot [0:MAX_STRIPES-1];
  logic [1023:0] vdotf [0:MAX_STRIPES-1];
  logic [1023:0] vproduct [0:MAX_STRIPES-1];
  logic [1023:0] vterm [0:MAX_STRIPES-1];
  logic [1023:0] vps [0:MAX_STRIPES-1];
  logic [1023:0] vtrace [0:MAX_STRIPES-1];
  string stream_dir;
  int rows, K, N, G, T, total, cycles, accepted, stalls;
  int commits [0:3], converted [0:3], terms [0:3], traces [0:3];
  int last_commit_seq [0:3], last_commit_tick [0:3];
  int feedback_count, feedback_min, feedback_max, feedback_sum;

  function automatic logic [7:0] lane_mask(input int seq);
    if (seq%T == T-1 && N%8 != 0) return 8'((1 << (N%8))-1);
    return 8'hff;
  endfunction

  task automatic compare_lanes(input logic [255:0] actual,
                               input logic [255:0] expected,
                               input logic [7:0] mask,
                               input int seq, input int row,
                               input string stage);
    for (int lane=0;lane<8;lane++)
      if (mask[lane] &&
          actual[lane*32 +: 32] !== expected[lane*32 +: 32])
        $fatal(1,"TM4 real %s row=%0d seq=%0d lane=%0d got=%h expected=%h",
               stage,row,seq,lane,actual[lane*32 +: 32],
               expected[lane*32 +: 32]);
  endtask

  always @(posedge clk) begin
    int seq, group, tile;
    if (!rst_n) begin
      cycles=0;
      trace_ack_valid <= 0;
      trace_ack_slot <= 0;
      trace_ack_tag <= 0;
    end else begin
      cycles++;
      if (cycles > 40000000) $fatal(1,"TM4 real 40M cycle cap");
      trace_ack_valid <= trace_valid & trace_ready;
      trace_ack_slot <= trace_slot;
      trace_ack_tag <= trace_tag;
      for (int r=0;r<4;r++) begin
        if (int'(result_free[r*6 +: 6]) +
            int'(result_reserved[r*6 +: 6]) +
            int'(result_returned[r*6 +: 6]) != 35)
          $fatal(1,"TM4 real Q35 conservation row=%0d",r);
        if (commit_valid[r] && commit_ready[r]) begin
          seq=int'(commit_tag[r*192+36 +: 27]);
          group=seq/T;
          tile=seq%T;
          if (r>=rows || seq<0 || seq>=total ||
              seq!==commits[r] ||
              commit_tag[r*192+64 +: 96] !== config_identity[159:64] ||
              commit_tag[r*192+164 +: 4] !== 4'd1 ||
              commit_tag[r*192+26 +: 2] !== 2'(r) ||
              {commit_tag[r*192+160],commit_tag[r*192+11 +: 6]} !== 7'(group) ||
              {commit_tag[r*192+161],commit_tag[r*192+17 +: 9]} !== 10'(tile) ||
              commit_tile[r*10 +: 10] !== 10'(tile) ||
              commit_lane_mask[r*8 +: 8] !== lane_mask(seq) ||
              commit_bad_mask[r*8 +: 8] !== 8'd0)
            $fatal(1,"TM4 real commit tag/order row=%0d seq=%0d expected=%0d",
                   r,seq,commits[r]);
          compare_lanes(commit_next_ps[r*256 +: 256],
                        vps[seq][r*256 +: 256],lane_mask(seq),seq,r,"PS");
          for (int lane=0;lane<8;lane++)
            if (commit_lane_mask[r*8+lane] &&
                commit_phase[r*24+lane*3 +: 3] !== 3'd4)
              $fatal(1,"TM4 real FP phase row=%0d seq=%0d lane=%0d",
                     r,seq,lane);
          last_commit_seq[r]=seq;
          last_commit_tick[r]=int'($time/10);
          commits[r]++;
          if (r==0 && commits[r]%256==0)
            $display("TM4_REAL_PROGRESS cycles=%0d row0_commits=%0d/%0d",
                     cycles,commits[r],total);
        end
        if (trace_valid[r] && trace_ready[r]) begin
          seq=int'(trace_tag[r*192+36 +: 27]);
          if (r>=rows || seq<0 || seq>=total || seq%T!=0 ||
              trace_tag[r*192+7] !== 1'b1 ||
              trace_payload[r*256 +: 256] !==
                  vtrace[seq][r*256 +: 256])
            $fatal(1,"TM4 real trace row=%0d seq=%0d",r,seq);
          traces[r]++;
        end
      end
      if (cycles%1000000==0)
        $display("TM4_REAL_PROGRESS cycles=%0d accepted=%0d commits=%0d,%0d,%0d,%0d",
                 cycles,accepted,commits[0],commits[1],commits[2],commits[3]);
    end
  end

  for (genvar r=0;r<4;r++) begin : numeric_monitor
    always @(negedge clk) begin
      int seq;
      if (rst_n && r<rows &&
          dut.row[r].arithmetic.fp_restore.valid_c) begin
        seq=int'(dut.row[r].arithmetic.fp_restore.meta_c.tag[62:36]);
        if (seq<0 || seq>=total || seq!==converted[r])
          $fatal(1,"TM4 real converted tag/order row=%0d seq=%0d",r,seq);
        compare_lanes(dut.row[r].arithmetic.fp_restore.meta_c.dot,
                      vdot[seq][r*256 +: 256],lane_mask(seq),seq,r,"dot");
        compare_lanes(dut.row[r].arithmetic.fp_restore.dot_float_c,
                      vdotf[seq][r*256 +: 256],lane_mask(seq),seq,r,"dotf");
        compare_lanes(dut.row[r].arithmetic.fp_restore.scale_product_c,
                      vproduct[seq][r*256 +: 256],lane_mask(seq),seq,r,"scale product");
        converted[r]++;
      end
      if (rst_n && r<rows &&
          dut.row[r].arithmetic.fp_restore.valid_add) begin
        seq=int'(dut.row[r].arithmetic.fp_restore.tag_add[62:36]);
        if (seq<0 || seq>=total || seq!==terms[r])
          $fatal(1,"TM4 real term tag/order row=%0d seq=%0d",r,seq);
        compare_lanes(dut.row[r].arithmetic.fp_restore.term_add,
                      vterm[seq][r*256 +: 256],lane_mask(seq),seq,r,"term");
        terms[r]++;
      end
    end
  end

  initial begin : test
    int seq, group, tile, lane, timeout, feedback_gap;
    if (!$value$plusargs("TM4_STREAM_DIR=%s",stream_dir) ||
        !$value$plusargs("ROWS=%d",rows) ||
        !$value$plusargs("K=%d",K) ||
        !$value$plusargs("N=%d",N))
      $fatal(1,"TM4_STREAM_DIR/ROWS/K/N required");
    G=K/32; T=(N+7)/8; total=G*T;
    if (total<1 || total>MAX_STRIPES || 
        !((rows==1 && K==256 && N==2) ||
          (rows==4 && ((K==1024 && (N==3072 || N==5248)) ||
                       (K==2624 && N==1024)))))
      $fatal(1,"unsupported TM4 real shape");
    $readmemh({stream_dir,"/a8.mem"},va,0,total-1);
    $readmemh({stream_dir,"/sa.mem"},vsa,0,total-1);
    $readmemh({stream_dir,"/w8.mem"},vw,0,total-1);
    $readmemh({stream_dir,"/sw.mem"},vsw,0,total-1);
    $readmemh({stream_dir,"/dot.mem"},vdot,0,total-1);
    $readmemh({stream_dir,"/dotf.mem"},vdotf,0,total-1);
    $readmemh({stream_dir,"/product.mem"},vproduct,0,total-1);
    $readmemh({stream_dir,"/term.mem"},vterm,0,total-1);
    $readmemh({stream_dir,"/ps.mem"},vps,0,total-1);
    $readmemh({stream_dir,"/trace.mem"},vtrace,0,total-1);
    $display("TM4_REAL_INPUTS_READY rows=%0d K=%0d N=%0d stripes=%0d",
             rows,K,N,total);
    rst_n=0; config_valid=0; issue_valid=0;
    config_k=0; config_n=0; config_rows=0; config_row0=0;
    config_identity=0; issue_identity=0; issue_version=0;
    issue_sequence=0; issue_group=0; issue_tile=0;
    issue_lane_mask=0; issue_trace_mask=0; issue_trace_lane=0;
    issue_a8=0; issue_sa=0; issue_w8=0; issue_sw=0;
    commit_ready=4'hf; trace_ready=4'hf; trace_ack_ok=4'hf;
    accepted=0; stalls=0;
    feedback_count=0; feedback_min=32'h7fffffff;
    feedback_max=0; feedback_sum=0;
    for (int r=0;r<4;r++) begin
      commits[r]=0; converted[r]=0; terms[r]=0; traces[r]=0;
      last_commit_seq[r]=-1; last_commit_tick[r]=-1;
    end
    repeat (12) @(negedge clk);
    rst_n=1;
    @(negedge clk);
    config_k=16'(K); config_n=16'(N); config_rows=3'(rows);
    config_row0=0;
    config_identity={32'hf190_d171,32'h781a_09ce,
                     32'h61b2_819d,32'h0f80_0000,32'h9cd2_8100};
    issue_identity=config_identity[159:64];
    issue_version=4'd1;
    config_valid=1;
    #1ps;
    if (!config_ready) $fatal(1,"TM4 real config not ready");
    @(posedge clk);
    @(negedge clk);
    config_valid=0;
    for (seq=0;seq<total;seq++) begin
      group=seq/T; tile=seq%T;
      issue_sequence=27'(seq);
      issue_group=7'(group);
      issue_tile=10'(tile);
      issue_lane_mask=lane_mask(seq);
      issue_trace_mask=(tile==0 ? (rows==1 ? 4'h1 : 4'hf) : 4'h0);
      lane=group%(N==2 ? 2 : 8);
      for (int r=0;r<4;r++) issue_trace_lane[r*3 +: 3]=3'(lane);
      issue_a8=va[seq]; issue_sa=vsa[seq];
      issue_w8=vw[seq]; issue_sw=vsw[seq];
      issue_valid=1;
      #1ps;
      while (!issue_ready) begin
        stalls++;
        if (stalls>40000000) $fatal(1,"TM4 real issue stalled");
        @(negedge clk);
        #1ps;
      end
      @(posedge clk);
      if (rows==1 && T==1 && seq>0) begin
        if (last_commit_seq[0] != seq-1)
          $fatal(1,"TM4 ACT issue preceded prior PS commit seq=%0d prior=%0d",
                 seq,last_commit_seq[0]);
        feedback_gap=int'($time/10)-last_commit_tick[0];
        if (feedback_gap<1)
          $fatal(1,"TM4 ACT feedback guard violated seq=%0d commit-to-issue=%0d",
                 seq,feedback_gap);
        feedback_count++;
        feedback_sum+=feedback_gap;
        if (feedback_gap<feedback_min) feedback_min=feedback_gap;
        if (feedback_gap>feedback_max) feedback_max=feedback_gap;
      end
      accepted++;
      @(negedge clk);
    end
    issue_valid=0;
    timeout=0;
    while (!done_valid) begin
      @(negedge clk);
      timeout++;
      if (timeout>2000) $fatal(1,"TM4 real final drain timeout");
    end
    if (done_error || protocol_failure || first_error_rank !== '1 ||
        first_bad_element !== '1 || accepted_stripes!=total)
      $fatal(1,"TM4 real task terminal failure accepted=%0d/%0d",
             accepted_stripes,total);
    for (int r=0;r<4;r++) begin
      if ((r<rows && (commits[r]!=total || converted[r]!=total ||
                      terms[r]!=total || traces[r]!=G)) ||
          (r>=rows && (commits[r]!=0 || converted[r]!=0 ||
                       terms[r]!=0 || traces[r]!=0)) ||
          result_free[r*6 +: 6] != 35 ||
          result_reserved[r*6 +: 6] != 0 ||
          result_returned[r*6 +: 6] != 0 ||
          trace_free[r*3 +: 3] != 4)
        $fatal(1,"TM4 real coverage/debt row=%0d commits=%0d converted=%0d terms=%0d traces=%0d",
               r,commits[r],converted[r],terms[r],traces[r]);
    end
    if (rows==1 && T==1) begin
      if (feedback_count != G-1)
        $fatal(1,"TM4 ACT feedback coverage got=%0d expected=%0d",
               feedback_count,G-1);
      $display("TM4_ACT_FEEDBACK commit_to_next_sync_read_samples=%0d min=%0d max=%0d sum=%0d clocks stalls=%0d",
               feedback_count,feedback_min,feedback_max,feedback_sum,stalls);
    end
    $display("TM4_SYNC_ACTUAL_EDGES headers=%0d reads=%0d copies=%0d launches=%0d skips=%0d commits=%0d busy_stalls=%0d credit_stalls=%0d front_stalls=%0d launch_stalls=%0d commit_stalls=%0d",dut.header_accepted_count,dut.read_request_count,dut.read_copy_count,dut.launch_stripes_count,dut.skip_rows_count,dut.commit_rows_count,dut.busy_stall_count,dut.credit_stall_count,dut.front_stall_count,dut.launch_stall_count,dut.commit_stall_count);
    $display("TM4TN8_SYNC_REAL_MATRIX_PASS rows=%0d K=%0d N=%0d stripes=%0d group_records=%0d stalls=%0d candidate=%0d",
             rows,K,N,total,rows*G*N,stalls,PACKED);
    $finish;
  end
endmodule

module tm4tn8_real_matrix_packed_tb;
  tm4tn8_sync_ps_real_matrix_tb_v2 #(.PACKED(1)) test();
endmodule
