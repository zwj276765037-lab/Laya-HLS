`timescale 1ns/1ps
module tm1tn8_arithmetic_real_packed_tb;
  localparam int MAX_ISSUES=49152;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n, issue_valid, issue_ready, issue_trace;
  logic [159:0] issue_identity_tag, commit_tag, trace_tag, trace_ack_tag;
  logic [8:0] issue_tile, commit_tile;
  logic [7:0] issue_lane_mask, commit_lane_mask, commit_bad_mask;
  logic [2:0] issue_trace_lane;
  logic [5:0] issue_group;
  logic [1:0] issue_row;
  logic [255:0] issue_a8, issue_old_ps, issue_sw;
  logic [2047:0] issue_w8;
  logic [31:0] issue_sa;
  logic commit_valid, commit_ready, trace_valid, trace_ready;
  logic [23:0] commit_phase;
  logic [255:0] commit_next_ps, trace_payload;
  logic [1:0] trace_slot, trace_ack_slot;
  logic trace_ack_valid, trace_ack_ok;
  logic [5:0] result_free, result_reserved, result_returned;
  logic [2:0] trace_free;
  logic protocol_error;
  tm1tn8_arithmetic_pipeline_packed dut (.*);

  logic [255:0] va [0:MAX_ISSUES-1];
  logic [2047:0] vw [0:MAX_ISSUES-1];
  logic [31:0] vsa [0:MAX_ISSUES-1];
  logic [255:0] vsw [0:MAX_ISSUES-1];
  logic [7:0] vmask [0:MAX_ISSUES-1];
  logic [255:0] vdot [0:MAX_ISSUES-1];
  logic [255:0] vdotf [0:MAX_ISSUES-1];
  logic [255:0] vproduct [0:MAX_ISSUES-1];
  logic [255:0] vterm [0:MAX_ISSUES-1];
  logic [255:0] vps [0:MAX_ISSUES-1];
  logic [255:0] ps_by_tile [0:383];
  int last_commit_cycle [0:383];
  string vec_dir;
  int rows, G, T, total, commit_seen, accepted, cycle_count, prev_issue_cycle;
  int dot_checked, term_checked, ps_checked, bubbles;

  task automatic compare_lanes(input logic [255:0] actual,
                               input logic [255:0] expected,
                               input logic [7:0] mask,
                               input int seq, input string stage);
    for (int lane=0;lane<8;lane++)
      if (mask[lane] &&
          actual[lane*32 +: 32] !== expected[lane*32 +: 32])
        $fatal(1,"%s mismatch issue=%0d lane=%0d got=%h exp=%h",
               stage,seq,lane,actual[lane*32 +: 32],
               expected[lane*32 +: 32]);
  endtask

  always @(posedge clk) begin
    int seq, tile;
    if (rst_n) begin
      cycle_count++;
      if (commit_valid && commit_ready) begin
        seq=int'(commit_tag[62:36]);
        tile=int'(commit_tile);
        if (seq!=commit_seen || seq>=total ||
            tile!=seq%T || commit_lane_mask!==vmask[seq] ||
            commit_bad_mask!==0)
          $fatal(1,"commit order/mask issue=%0d expected=%0d",seq,commit_seen);
        compare_lanes(commit_next_ps,vps[seq],vmask[seq],seq,"PS");
        for (int lane=0;lane<8;lane++)
          if (vmask[seq][lane] &&
              commit_phase[lane*3 +: 3]!==3'd4)
            $fatal(1,"FP phase issue=%0d lane=%0d",seq,lane);
        ps_by_tile[tile]=commit_next_ps;
        last_commit_cycle[tile]=cycle_count;
        ps_checked+=8;
        commit_seen++;
      end
    end
  end

  always @(negedge clk) begin
    int seq;
    if (rst_n && dut.fp_restore.valid_c) begin
      seq=int'(dut.fp_restore.meta_c.tag[62:36]);
      if (seq<0 || seq>=total) $fatal(1,"bad FP converted tag");
      compare_lanes(dut.fp_restore.meta_c.dot,vdot[seq],vmask[seq],seq,"dot");
      compare_lanes(dut.fp_restore.dot_float_c,vdotf[seq],
                    vmask[seq],seq,"dotf");
      compare_lanes(dut.fp_restore.scale_product_c,vproduct[seq],
                    vmask[seq],seq,"product");
      dot_checked++;
    end
    if (rst_n && dut.fp_restore.valid_add) begin
      seq=int'(dut.fp_restore.tag_add[62:36]);
      if (seq<0 || seq>=total) $fatal(1,"bad FP term tag");
      compare_lanes(dut.fp_restore.term_add,vterm[seq],vmask[seq],seq,"term");
      term_checked++;
    end
  end

  initial begin : test
    int seq, row_limit, timeout, g, tile, r;
    logic [1:0] saved_slot;
    if (!$value$plusargs("VEC_DIR=%s",vec_dir) ||
        !$value$plusargs("ROWS=%d",rows) ||
        !$value$plusargs("G=%d",G) ||
        !$value$plusargs("T=%d",T))
      $fatal(1,"VEC_DIR/ROWS/G/T plusargs required");
    total=rows*G*T;
    if (total<1 || total>MAX_ISSUES || T>384 ||
        !((rows==1 && G==8 && T==1) ||
          ((rows==1 || rows==4) && G==32 && T==384)))
      $fatal(1,"unsupported real vector shape");
    $readmemh({vec_dir,"/a.hex"},va);
    $readmemh({vec_dir,"/w.hex"},vw);
    $readmemh({vec_dir,"/sa.hex"},vsa);
    $readmemh({vec_dir,"/sw.hex"},vsw);
    $readmemh({vec_dir,"/mask.hex"},vmask);
    $readmemh({vec_dir,"/dot.hex"},vdot);
    $readmemh({vec_dir,"/dotf.hex"},vdotf);
    $readmemh({vec_dir,"/product.hex"},vproduct);
    $readmemh({vec_dir,"/term.hex"},vterm);
    $readmemh({vec_dir,"/ps.hex"},vps);
    rst_n=0; issue_valid=0; issue_identity_tag=0; issue_tile=0;
    issue_lane_mask=0; issue_trace=0; issue_trace_lane=0;
    issue_group=0; issue_row=0; issue_a8=0; issue_w8=0;
    issue_old_ps=0; issue_sa=0; issue_sw=0;
    commit_ready=1; trace_ready=0; trace_ack_valid=0;
    trace_ack_slot=0; trace_ack_tag=0; trace_ack_ok=1;
    commit_seen=0; accepted=0;
    cycle_count=0; prev_issue_cycle=-1; dot_checked=0;
    term_checked=0; ps_checked=0; bubbles=0;
    for (int i=0;i<384;i++) begin
      ps_by_tile[i]=0;
      last_commit_cycle[i]=-1;
    end
    repeat (16) @(negedge clk);
    rst_n=1;
    for (r=0;r<rows;r++) begin
      if (r!=0) for (int i=0;i<T;i++) ps_by_tile[i]=0;
      for (g=0;g<G;g++) for (tile=0;tile<T;tile++) begin
        seq=(r*G+g)*T+tile;
        @(negedge clk);
        issue_valid=0;
        issue_tile=9'(tile);
        issue_lane_mask=vmask[seq];
        issue_trace=(r==0 && tile==0 && g<4);
        issue_trace_lane=0;
        issue_group=6'(g);
        issue_row=2'(r);
        issue_a8=va[seq]; issue_w8=vw[seq];
        issue_old_ps=ps_by_tile[tile];
        issue_sa=vsa[seq]; issue_sw=vsw[seq];
        issue_identity_tag=160'(seq)<<36;
        #1ps;
        while (T==1 && seq>0 &&
               (commit_seen<seq ||
                cycle_count<last_commit_cycle[tile]+1)) begin
          bubbles++;
          @(negedge clk);
          issue_old_ps=ps_by_tile[tile];
          #1ps;
        end
        issue_valid=1;
        #1ps;
        while (!issue_ready) begin
          bubbles++;
          @(negedge clk);
          issue_old_ps=ps_by_tile[tile];
          #1ps;
        end
        if (T==384 && prev_issue_cycle>=0 &&
            cycle_count-prev_issue_cycle!=1)
          $fatal(1,"QKV arithmetic issue II>1 at seq=%0d",seq);
        prev_issue_cycle=cycle_count;
        accepted++;
      end
      @(negedge clk); issue_valid=0;
      row_limit=(r+1)*G*T;
      timeout=0;
      while (commit_seen<row_limit) begin
        @(negedge clk);
        timeout++;
        if (timeout>200) $fatal(1,"row arithmetic drain timeout r=%0d",r);
      end
      prev_issue_cycle=-1;
    end
    for (int i=0;i<4;i++) begin
      timeout=0;
      while (!trace_valid) begin
        @(negedge clk);
        timeout++;
        if (timeout>30) $fatal(1,"real trace timeout");
      end
      seq=i*T;
      if (trace_slot!==2'(i) ||
          trace_tag[62:36]!==27'(seq) ||
          trace_payload[31:0]!==vdot[seq][31:0] ||
          trace_payload[63:32]!==vsa[seq] ||
          trace_payload[95:64]!==vsw[seq][31:0] ||
          trace_payload[127:96]!==vproduct[seq][31:0] ||
          trace_payload[159:128]!==vterm[seq][31:0] ||
          trace_payload[191:160]!==vps[seq][31:0] ||
          trace_payload[223:192]!==32'(i) ||
          trace_payload[255:224]!==1)
        $fatal(1,"real trace mismatch g=%0d",i);
      saved_slot=trace_slot;
      @(negedge clk); trace_ready=1;
      @(negedge clk); trace_ready=0;
      trace_ack_valid=1; trace_ack_slot=saved_slot;
      trace_ack_tag=trace_tag;
      @(negedge clk); trace_ack_valid=0;
    end
    repeat (3) @(negedge clk);
    if (accepted!=total || commit_seen!=total ||
        dot_checked!=total || term_checked!=total ||
        result_free!==35 || result_reserved!==0 ||
        result_returned!==0 || trace_free!==4 || protocol_error)
      $fatal(1,"real arithmetic coverage/debt accepted=%0d commit=%0d dot=%0d term=%0d",
             accepted,commit_seen,dot_checked,term_checked);
    $display("TM1TN8_ARITHMETIC_REAL_PACKED_PASS rows=%0d G=%0d T=%0d issues=%0d bubbles=%0d",
             rows,G,T,total,bubbles);
    $finish;
  end
endmodule
