  localparam logic [63:0] DESC_BASE=64'h0000_0004_0000_0000;
  localparam logic [63:0] Q0_BASE=64'h0000_0005_0000_0000;
  localparam logic [63:0] Q1_BASE=64'h0000_0006_0000_0000;
  localparam logic [63:0] SCALE_BASE=64'h0000_0007_0000_0000;
  localparam logic [63:0] AUX_BASE=64'h0000_0008_0000_0000;
  localparam logic [63:0] ACT_BASE=64'h0000_0009_0000_0000;
  localparam logic [63:0] OBS_BASE=64'h0000_0001_0000_1000;
  localparam logic [63:0] OUT0_BASE=64'h0000_0002_0000_0000;
  localparam logic [63:0] OUT1_BASE=64'h0000_0003_0000_0000;
  localparam int ISSUES=ROWS*12288;
  logic run_mode;
  logic [31:0] load_desc[0:127], run_desc[0:127];
  logic [511:0] q0_words[0:24575], q1_words[0:24575];
  logic [511:0] scale_words[0:3071], activation_words[0:ROWS*64-1];
  logic [31:0] aux_header[0:31], a8q_gold[0:ROWS*256-1];
  logic [31:0] half_gold[0:ROWS*16-1], output_gold[0:ROWS*3072-1];
  logic [31:0] trace_gold[0:255], observed_words[0:32767];
  logic [255:0] vdot[0:ISSUES-1], vdotf[0:ISSUES-1];
  logic [255:0] vproduct[0:ISSUES-1], vterm[0:ISSUES-1];
  logic [255:0] vps[0:ISSUES-1];
  logic [31:0] vsa[0:ISSUES-1];
  logic [7:0] vmask[0:ISSUES-1];
  int cycles, out0_writes, out1_writes, trace_writes;
  int observed_hls_writes, dot_checked, term_checked, commits;
  int quant_checked;
  int load_segment_start, load_segment_end, run_segment_start;
  int first_issue_cycle, last_issue_cycle, last_commit_cycle;
  int last_output_b_cycle, last_trace_b_cycle, issue_count;
  int source_empty_cycles, issue_stall_cycles, tile_busy_stall_cycles;
  int pipeline_stall_cycles, result_credit_stall_cycles;
  int trace_credit_stall_cycles, output_w_stall_cycles;
  int issue_cycle_by_seq[0:ISSUES-1];
  int commit_f_min, commit_f_max, commit_f_count, commit_f_missing;
  int commit_f_hist[0:6];
  longint unsigned commit_f_sum;
  int first_tile_cycle, first_b0_cycle, last_b0_cycle;
  int first_b1_cycle, last_b1_cycle, b0_at_run, b1_at_run;
  int first_nonlast_issue, last_nonlast_issue, nonlast_issue_count;
  int first_row_issue[0:ROWS-1], last_row_b[0:ROWS-1];
  int q_occupancy_max;
  int command_accept_cycle, command_done_cycle, prev_done_cycle;
  string input_dir, vec_dir;

  function automatic logic [63:0] expected_addr(input int shard, beat);
    int row, local_beat, head_in_shard, plane, local_head, d;
    logic [63:0] relative;
    row=beat/96;
    local_beat=beat%96;
    head_in_shard=local_beat/4;
    plane=head_in_shard/8;
    local_head=head_in_shard%8;
    d=(local_beat%4)*16;
    relative=64'((((plane*2)*8+local_head)*1024+row)*64+d)*4;
    return (shard ? OUT1_BASE : OUT0_BASE)+relative;
  endfunction
  function automatic int expected_n(input int shard, beat, lane);
    int local_beat, head_in_shard, plane, local_head, d;
    local_beat=beat%96;
    head_in_shard=local_beat/4;
    plane=head_in_shard/8;
    local_head=head_in_shard%8;
    d=(local_beat%4)*16;
    return plane*1024+(local_head*2+shard)*64+d+lane;
  endfunction
  task automatic compare_lanes(input logic [255:0] actual,
                               input logic [255:0] expected,
                               input logic [7:0] mask,
                               input int seq, input string stage);
    for (int lane=0;lane<8;lane++)
      if (mask[lane] && actual[lane*32 +: 32] !== expected[lane*32 +: 32])
        $fatal(1,"QKV DMA %s mismatch issue=%0d lane=%0d got=%h exp=%h",
               stage,seq,lane,actual[lane*32 +: 32],
               expected[lane*32 +: 32]);
  endtask

  always #3.333 ap_clk=~ap_clk;
  always_comb begin
    descriptor_read_contents='x;
    if (descriptor_read_address>=DESC_BASE &&
        descriptor_read_address<DESC_BASE+512 &&
        descriptor_read_address[1:0]==0)
      descriptor_read_contents=run_mode ?
          run_desc[int'((descriptor_read_address-DESC_BASE)>>2)] :
          load_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
    w_q0_read_contents='x;
    if (w_q0_read_address>=Q0_BASE+Q0_OFFSET &&
        w_q0_read_address<Q0_BASE+Q0_OFFSET+1572864 &&
        w_q0_read_address[5:0]==0)
      w_q0_read_contents=q0_words[int'((w_q0_read_address-Q0_BASE-Q0_OFFSET)>>6)];
    w_q1_read_contents='x;
    if (w_q1_read_address>=Q1_BASE+Q1_OFFSET &&
        w_q1_read_address<Q1_BASE+Q1_OFFSET+1572864 &&
        w_q1_read_address[5:0]==0)
      w_q1_read_contents=q1_words[int'((w_q1_read_address-Q1_BASE-Q1_OFFSET)>>6)];
    w_scale_read_contents='x;
    if (w_scale_read_address>=SCALE_BASE+SCALE_OFFSET &&
        w_scale_read_address<SCALE_BASE+SCALE_OFFSET+196608 &&
        w_scale_read_address[5:0]==0)
      w_scale_read_contents=scale_words[int'((w_scale_read_address-SCALE_BASE-SCALE_OFFSET)>>6)];
    aux_read_contents='x;
    if (aux_read_address>=AUX_BASE && aux_read_address<AUX_BASE+128 &&
        aux_read_address[1:0]==0)
      aux_read_contents=aux_header[int'((aux_read_address-AUX_BASE)>>2)];
    activation_read_contents='x;
    if (activation_read_address>=ACT_BASE &&
        activation_read_address<ACT_BASE+ROWS*4096 &&
        activation_read_address[5:0]==0)
      activation_read_contents=activation_words[int'((activation_read_address-ACT_BASE)>>6)];
    observed_read_contents='x;
    out0_read_contents='x;
    out1_read_contents='x;
    trace_read_contents='x;
  end

  always @(posedge ap_clk) if (ap_rst_n) begin
    int address_word, row, n, seq;
    cycles <= cycles+1;
    if (cycles>40000000) $fatal(1,"joint DMA QKV cycle timeout");
    if (cycles!=0 && cycles%10000==0)
      $display("TM1TN8_JOINT_DMA_QKV_PROGRESS cycles=%0d q0R=%0d q1R=%0d inputR=%0d commits=%0d outB=%0d traceB=%0d",
               cycles,w_q0_r_count,w_q1_r_count,activation_r_count,
               commits,out0_b_count+out1_b_count,trace_b_count);
    // Passive timing only. These counters never alter stimulus or PASS.
    if (run_mode) begin
      if (dut.bridge.group_tvalid && dut.bridge.group_tready) begin
        int qrow,qgroup,qtile,qseq;
        qrow=int'(dut.bridge.group_tdata[2608:2607]);
        qgroup=int'(dut.bridge.group_tdata[2606:2601]);
        qtile=int'(dut.bridge.group_tdata[2600:2592]);
        qseq=(qrow*32+qgroup)*384+qtile;
        if (qrow>=ROWS || qgroup>=32 || qtile>=384 ||
            qseq!=quant_checked || qseq>=ISSUES)
          $fatal(1,"QKV trace-off quant group order row=%0d g=%0d tile=%0d seq=%0d expected=%0d",
                 qrow,qgroup,qtile,qseq,quant_checked);
        for (int qword=0;qword<8;qword++)
          if (dut.bridge.group_tdata[qword*32 +: 32] !==
              a8q_gold[(qrow*32+qgroup)*8+qword])
            $fatal(1,"QKV trace-off quant q mismatch seq=%0d word=%0d",
                   qseq,qword);
        if (dut.bridge.group_tdata[2335:2304] !== vsa[qseq])
          $fatal(1,"QKV trace-off quant scale mismatch seq=%0d got=%h exp=%h",
                 qseq,dut.bridge.group_tdata[2335:2304],vsa[qseq]);
        quant_checked++;
        issue_cycle_by_seq[qseq]=cycles;
        if (first_issue_cycle<0) first_issue_cycle=cycles;
        last_issue_cycle=cycles;
        issue_count=issue_count+1;
        if (qgroup<31) begin
          if (first_nonlast_issue<0) first_nonlast_issue=cycles;
          last_nonlast_issue=cycles;
          nonlast_issue_count++;
        end
        if (first_row_issue[qrow]<0) first_row_issue[qrow]=cycles;
      end else if (issue_count>0 && issue_count<ISSUES) begin
        if (!dut.bridge.group_tvalid) source_empty_cycles++;
        else begin
          issue_stall_cycles++;
          if (dut.bridge.ps_controller.tile_busy[
                  dut.bridge.ps_controller.in_tile])
            tile_busy_stall_cycles++;
          else begin
            pipeline_stall_cycles++;
            if (dut.bridge.result_free==0) result_credit_stall_cycles++;
            if (dut.bridge.trace_free==0) trace_credit_stall_cycles++;
          end
        end
      end
      if ((m_axi_out0_WVALID && !m_axi_out0_WREADY) ||
          (m_axi_out1_WVALID && !m_axi_out1_WREADY))
        output_w_stall_cycles++;
      if (35-int'(dut.bridge.result_free)>q_occupancy_max)
        q_occupancy_max=35-int'(dut.bridge.result_free);
      if (first_tile_cycle<0 &&
          ((dut.bridge.writers.tile0_tvalid &&
            dut.bridge.writers.tile0_tready) ||
           (dut.bridge.writers.tile1_tvalid &&
            dut.bridge.writers.tile1_tready)))
        first_tile_cycle=cycles;
      if (m_axi_out0_BVALID && m_axi_out0_BREADY) begin
        int brow;
        brow=(int'(out0_b_count)-b0_at_run)/96;
        if (brow<0 || brow>=ROWS) $fatal(1,"out0 B row range");
        if (first_b0_cycle<0) first_b0_cycle=cycles;
        last_b0_cycle=cycles;
        last_row_b[brow]=cycles;
      end
      if (m_axi_out1_BVALID && m_axi_out1_BREADY) begin
        int brow;
        brow=(int'(out1_b_count)-b1_at_run)/96;
        if (brow<0 || brow>=ROWS) $fatal(1,"out1 B row range");
        if (first_b1_cycle<0) first_b1_cycle=cycles;
        last_b1_cycle=cycles;
        last_row_b[brow]=cycles;
      end
      if ((m_axi_out0_BVALID && m_axi_out0_BREADY) ||
          (m_axi_out1_BVALID && m_axi_out1_BREADY))
        last_output_b_cycle=cycles;
      if (m_axi_observed_trace_BVALID && m_axi_observed_trace_BREADY)
        last_trace_b_cycle=cycles;
    end
    if (m_axi_gmem_descriptor_AWVALID || m_axi_gmem_w_q0_AWVALID ||
        m_axi_gmem_w_q1_AWVALID || m_axi_gmem_w_scale_AWVALID ||
        m_axi_gmem_aux_AWVALID || m_axi_gmem_activation_AWVALID ||
        m_axi_gmem_observed_ARVALID)
      $fatal(1,"unexpected QKV source write or observed read");
    if (m_axi_gmem_descriptor_RVALID && m_axi_gmem_descriptor_RREADY &&
        (^descriptor_read_contents===1'bx))
      $fatal(1,"QKV descriptor read outside BO");
    if (m_axi_gmem_w_q0_RVALID && m_axi_gmem_w_q0_RREADY &&
        (^w_q0_read_contents===1'bx))
      $fatal(1,"QKV q0 read outside actual package window");
    if (m_axi_gmem_w_q1_RVALID && m_axi_gmem_w_q1_RREADY &&
        (^w_q1_read_contents===1'bx))
      $fatal(1,"QKV q1 read outside actual package window");
    if (m_axi_gmem_w_scale_RVALID && m_axi_gmem_w_scale_RREADY &&
        (^w_scale_read_contents===1'bx))
      $fatal(1,"QKV scale read outside actual package window");
    if (m_axi_gmem_aux_RVALID && m_axi_gmem_aux_RREADY &&
        (^aux_read_contents===1'bx))
      $fatal(1,"QKV aux read outside header window");
    if (m_axi_gmem_activation_RVALID && m_axi_gmem_activation_RREADY &&
        (^activation_read_contents===1'bx))
      $fatal(1,"QKV activation read outside independent source slice");
    if (run_mode && dut.bridge.ps_controller.arithmetic.commit_valid &&
        dut.bridge.ps_controller.arithmetic.commit_ready) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.commit_tag[62:36]);
      if (seq!=commits || seq>=ISSUES ||
          dut.bridge.ps_controller.arithmetic.commit_bad_mask!==0 ||
          dut.bridge.ps_controller.arithmetic.commit_lane_mask!==8'hff)
        $fatal(1,"QKV DMA PS commit tag=%0d expected=%0d",seq,commits);
      compare_lanes(dut.bridge.ps_controller.arithmetic.commit_next_ps,
                    vps[seq],vmask[seq],seq,"PS");
      commits <= commits+1;
      last_commit_cycle=cycles;
      if (issue_cycle_by_seq[seq]>=0) begin
        int latency;
        latency=cycles-issue_cycle_by_seq[seq];
        if (latency<commit_f_min) commit_f_min=latency;
        if (latency>commit_f_max) commit_f_max=latency;
        commit_f_sum+=latency;
        commit_f_count++;
        if (latency<32) commit_f_hist[0]++;
        else if (latency<64) commit_f_hist[1]++;
        else if (latency<128) commit_f_hist[2]++;
        else if (latency<256) commit_f_hist[3]++;
        else if (latency<512) commit_f_hist[4]++;
        else if (latency<1024) commit_f_hist[5]++;
        else commit_f_hist[6]++;
      end else commit_f_missing++;
    end
    if (m_axi_gmem_observed_WVALID && m_axi_gmem_observed_WREADY) begin
      if (observed_write_address<OBS_BASE ||
          observed_write_address>=OBS_BASE+131072 ||
          observed_write_address[1:0]!=0 ||
          m_axi_gmem_observed_WSTRB!==4'hf)
        $fatal(1,"QKV HLS observed write bounds/strb");
      address_word=int'((observed_write_address-OBS_BASE)>>2);
      if (address_word>=256 &&
          !(run_mode &&
            ((address_word<256+ROWS*256) ||
             (address_word>=16640 && address_word<16640+ROWS*16))))
        $fatal(1,"QKV HLS observed protected word=%0d",address_word);
      observed_words[address_word] <= m_axi_gmem_observed_WDATA;
      observed_hls_writes <= observed_hls_writes+1;
    end
    if (m_axi_observed_trace_WVALID && m_axi_observed_trace_WREADY) begin
      if (!TRACE_ON || !run_mode || trace_writes>=256 ||
          trace_write_address !== OBS_BASE+70656+64'(trace_writes)*4 ||
          m_axi_observed_trace_WSTRB!==4'hf ||
          m_axi_observed_trace_WDATA!==trace_gold[trace_writes])
        $fatal(1,"QKV physical trace word=%0d addr=%h",trace_writes,
               trace_write_address);
      observed_words[17664+trace_writes] <= m_axi_observed_trace_WDATA;
      trace_writes <= trace_writes+1;
    end
    if (m_axi_out0_WVALID && m_axi_out0_WREADY) begin
      if (!run_mode || out0_writes>=ROWS*96 ||
          out0_write_address!==expected_addr(0,out0_writes) ||
          m_axi_out0_WSTRB!=='1 || !m_axi_out0_WLAST)
        $fatal(1,"QKV physical out0 address/strb beat=%0d got_addr=%h exp_addr=%h got_strb=%h exp_strb=%h last=%b n0=%0d row0=%0d row_local=%0d word_idx=%0d useful=%0d physical=%0d aw/w/b=%0d/%0d/%0d",
               out0_writes,out0_write_address,expected_addr(0,out0_writes),
               m_axi_out0_WSTRB,64'hffff_ffff_ffff_ffff,m_axi_out0_WLAST,
               dut.bridge.writers.writer0.held_n0,
               dut.bridge.writers.writer0.held_row0,
               dut.bridge.writers.writer0.held_row_local,
               dut.bridge.writers.writer0.held_pending,
               dut.bridge.writers.writer0.useful_bytes,
               dut.bridge.writers.writer0.physical_bytes,
               out0_aw_count,out0_w_count,out0_b_count);
      row=out0_writes/96;
      for (int lane=0;lane<16;lane++) begin
        n=expected_n(0,out0_writes,lane);
        if (m_axi_out0_WDATA[lane*32 +: 32]!==output_gold[row*3072+n])
          $fatal(1,"QKV physical out0 data row=%0d n=%0d",row,n);
      end
      out0_writes <= out0_writes+1;
    end
    if (m_axi_out1_WVALID && m_axi_out1_WREADY) begin
      if (!run_mode || out1_writes>=ROWS*96 ||
          out1_write_address!==expected_addr(1,out1_writes) ||
          m_axi_out1_WSTRB!=='1 || !m_axi_out1_WLAST)
        $fatal(1,"QKV physical out1 address/strb beat=%0d got_addr=%h exp_addr=%h got_strb=%h exp_strb=%h last=%b n0=%0d row0=%0d row_local=%0d word_idx=%0d useful=%0d physical=%0d aw/w/b=%0d/%0d/%0d",
               out1_writes,out1_write_address,expected_addr(1,out1_writes),
               m_axi_out1_WSTRB,64'hffff_ffff_ffff_ffff,m_axi_out1_WLAST,
               dut.bridge.writers.writer1.held_n0,
               dut.bridge.writers.writer1.held_row0,
               dut.bridge.writers.writer1.held_row_local,
               dut.bridge.writers.writer1.held_pending,
               dut.bridge.writers.writer1.useful_bytes,
               dut.bridge.writers.writer1.physical_bytes,
               out1_aw_count,out1_w_count,out1_b_count);
      row=out1_writes/96;
      for (int lane=0;lane<16;lane++) begin
        n=expected_n(1,out1_writes,lane);
        if (m_axi_out1_WDATA[lane*32 +: 32]!==output_gold[row*3072+n])
          $fatal(1,"QKV physical out1 data row=%0d n=%0d",row,n);
      end
      out1_writes <= out1_writes+1;
    end
    if (command_done && (!dut.hls_axi_debt_zero ||
                         !dut.bridge_debt_zero ||
                         !descriptor_debt_zero || !w_q0_debt_zero ||
                         !w_q1_debt_zero || !w_scale_debt_zero ||
                         !aux_debt_zero || !activation_debt_zero ||
                         !observed_debt_zero || !out0_debt_zero ||
                         !out1_debt_zero || !trace_debt_zero))
      $fatal(1,"QKV first command_done before all physical/adaptor debt zero");
  end

  always @(negedge ap_clk) if (ap_rst_n && run_mode) begin
    int seq;
    if (dut.bridge.ps_controller.arithmetic.fp_restore.valid_c) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.fp_restore.meta_c.tag[62:36]);
      if (seq<0 || seq>=ISSUES) $fatal(1,"QKV converted tag range");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.meta_c.dot,
                    vdot[seq],vmask[seq],seq,"dot");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.dot_float_c,
                    vdotf[seq],vmask[seq],seq,"dotf");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.scale_product_c,
                    vproduct[seq],vmask[seq],seq,"scale product");
      dot_checked++;
    end
    if (dut.bridge.ps_controller.arithmetic.fp_restore.valid_add) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.fp_restore.tag_add[62:36]);
      if (seq<0 || seq>=ISSUES) $fatal(1,"QKV term tag range");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.term_add,
                    vterm[seq],vmask[seq],seq,"term");
      term_checked++;
    end
  end

  task automatic launch;
    wait(command_ready);
    @(negedge ap_clk);
    if (!command_ready) $fatal(1,"QKV command ready lost before launch");
    command_start=1;
    command_accept_cycle=cycles+1;
    @(negedge ap_clk); command_start=0;
    wait(command_done);
    command_done_cycle=cycles;
    if (!dut.hls_axi_debt_zero || !dut.bridge_debt_zero ||
        !descriptor_debt_zero || !w_q0_debt_zero || !w_q1_debt_zero ||
        !w_scale_debt_zero || !aux_debt_zero || !activation_debt_zero ||
        !observed_debt_zero || !out0_debt_zero || !out1_debt_zero ||
        !trace_debt_zero)
      $fatal(1,"QKV first command_done before all physical/adaptor debt zero");
    @(negedge ap_clk);
    if (command_fault) $fatal(1,"joint DMA QKV command fault");
  endtask

  initial begin : test
    if (!$value$plusargs("INPUT_DIR=%s",input_dir) ||
        !$value$plusargs("VEC_DIR=%s",vec_dir))
      $fatal(1,"INPUT_DIR/VEC_DIR plusargs required");
    $readmemh({input_dir,"/desc_load.hex"},load_desc);
    $readmemh({input_dir,"/desc_run.hex"},run_desc);
    if (!TRACE_ON) begin
      run_desc[3]=0;
      run_desc[60]=0;
      run_desc[61]=0;
    end
    $readmemh({input_dir,"/q0.hex"},q0_words);
    $readmemh({input_dir,"/q1.hex"},q1_words);
    $readmemh({input_dir,"/scale.hex"},scale_words);
    $readmemh({input_dir,"/aux_header.hex"},aux_header);
    $readmemh({input_dir,"/activation.hex"},activation_words);
    $readmemh({input_dir,"/a8q.hex"},a8q_gold);
    $readmemh({input_dir,"/a8half.hex"},half_gold);
    $readmemh({input_dir,"/output.hex"},output_gold);
    $readmemh({input_dir,"/trace.hex"},trace_gold);
    $readmemh({vec_dir,"/mask.hex"},vmask);
    $readmemh({vec_dir,"/dot.hex"},vdot);
    $readmemh({vec_dir,"/dotf.hex"},vdotf);
    $readmemh({vec_dir,"/product.hex"},vproduct);
    $readmemh({vec_dir,"/term.hex"},vterm);
    $readmemh({vec_dir,"/ps.hex"},vps);
    $readmemh({vec_dir,"/sa.hex"},vsa);
    ap_clk=0; ap_rst_n=0; run_mode=0;
    prev_done_cycle=-1;
    command_start=0; descriptor_base=DESC_BASE;
    w_q0_base=Q0_BASE; w_q1_base=Q1_BASE;
    w_scale_base=SCALE_BASE; aux_base=AUX_BASE;
    activation_base=ACT_BASE;
    observed_base=OBS_BASE; observed_span=131072;
    cycles=0; out0_writes=0; out1_writes=0;
    trace_writes=0; observed_hls_writes=0;
    dot_checked=0; term_checked=0; commits=0; quant_checked=0;
    load_segment_start=0;load_segment_end=0;run_segment_start=0;
    first_issue_cycle=-1;last_issue_cycle=-1;last_commit_cycle=-1;
    last_output_b_cycle=-1;last_trace_b_cycle=-1;issue_count=0;
    source_empty_cycles=0;issue_stall_cycles=0;tile_busy_stall_cycles=0;
    pipeline_stall_cycles=0;result_credit_stall_cycles=0;
    trace_credit_stall_cycles=0;output_w_stall_cycles=0;
    first_tile_cycle=-1;first_b0_cycle=-1;last_b0_cycle=-1;
    first_b1_cycle=-1;last_b1_cycle=-1;
    first_nonlast_issue=-1;last_nonlast_issue=-1;
    nonlast_issue_count=0;q_occupancy_max=0;
    command_accept_cycle=-1;command_done_cycle=-1;
    for (int r=0;r<ROWS;r++) begin
      first_row_issue[r]=-1;last_row_b[r]=-1;
    end
    commit_f_min=32'h7fff_ffff;commit_f_max=0;
    commit_f_count=0;commit_f_missing=0;commit_f_sum=0;
    for (int i=0;i<ISSUES;i++) issue_cycle_by_seq[i]=-1;
    for (int i=0;i<7;i++) commit_f_hist[i]=0;
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
    repeat(16) @(negedge ap_clk);
    ap_rst_n=1;
    load_segment_start=cycles;
    launch();
    load_segment_end=cycles;
    if (w_q0_r_count!=24576 || w_q1_r_count!=24576 ||
        w_scale_r_count!=3072 || aux_r_count!=32 ||
        descriptor_r_count!=128 || activation_r_count!=0 ||
        observed_hls_writes!=256 ||
        out0_writes!=0 || out1_writes!=0 || trace_writes!=0 ||
        observed_words[3]!=0 || observed_words[9]!=1)
      $fatal(1,"QKV actual LOAD_W physical coverage/status");
    $display("TM1TN8_JOINT_DMA_QKV_LOAD_PASS cycles=%0d q0R=%0d q1R=%0d scaleR=%0d",
             cycles,w_q0_r_count,w_q1_r_count,w_scale_r_count);
    run_mode=1;
    for (int run_idx=0;run_idx<RUN_COUNT;run_idx++) begin
    run_desc[8]=32'(3+2*run_idx);
    run_desc[31]=32'(2+2*run_idx);
    run_desc[27]=32'(1+run_idx);
    run_desc[30]=32'(1+run_idx);
    out0_writes=0;out1_writes=0;trace_writes=0;
    observed_hls_writes=0;
    dot_checked=0;term_checked=0;commits=0;quant_checked=0;
    first_issue_cycle=-1;last_issue_cycle=-1;last_commit_cycle=-1;
    last_output_b_cycle=-1;last_trace_b_cycle=-1;issue_count=0;
    source_empty_cycles=0;issue_stall_cycles=0;tile_busy_stall_cycles=0;
    pipeline_stall_cycles=0;result_credit_stall_cycles=0;
    trace_credit_stall_cycles=0;output_w_stall_cycles=0;
    first_tile_cycle=-1;first_b0_cycle=-1;last_b0_cycle=-1;
    first_b1_cycle=-1;last_b1_cycle=-1;
    first_nonlast_issue=-1;last_nonlast_issue=-1;
    nonlast_issue_count=0;q_occupancy_max=0;
    command_accept_cycle=-1;command_done_cycle=-1;
    b0_at_run=int'(out0_b_count);b1_at_run=int'(out1_b_count);
    for (int r=0;r<ROWS;r++) begin
      first_row_issue[r]=-1;last_row_b[r]=-1;
    end
    commit_f_min=32'h7fff_ffff;commit_f_max=0;
    commit_f_count=0;commit_f_missing=0;commit_f_sum=0;
    for (int i=0;i<ISSUES;i++) issue_cycle_by_seq[i]=-1;
    for (int i=0;i<7;i++) commit_f_hist[i]=0;
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
    run_segment_start=cycles;
    launch();
    if (w_q0_r_count!=24576 || w_q1_r_count!=24576 ||
        w_scale_r_count!=3072 || aux_r_count!=32 ||
        descriptor_r_count!=32'(256+128*run_idx) ||
        activation_r_count!=32'((run_idx+1)*ROWS*64) ||
        observed_hls_writes!=256+(TRACE_ON ? ROWS*272 : 0) ||
        observed_b_count==0 ||
        out0_b_count!=32'((run_idx+1)*ROWS*96) ||
        out1_b_count!=32'((run_idx+1)*ROWS*96) ||
        trace_b_count!=32'((run_idx+1)*(TRACE_ON ? 256 : 0)) ||
        out0_writes!=ROWS*96 || out1_writes!=ROWS*96 ||
        trace_writes!=(TRACE_ON ? 256 : 0) ||
        dot_checked!=ISSUES || term_checked!=ISSUES || commits!=ISSUES ||
        quant_checked!=ISSUES ||
        observed_words[3]!=0 ||
        observed_words[7]!=32'(3+2*run_idx) ||
        observed_words[8]!=32'(3+2*run_idx) ||
        observed_words[9]!=32'(3+2*run_idx) ||
        observed_words[12]!=ROWS*3072 ||
        observed_words[63]!=(TRACE_ON ? 32 : 0) ||
        observed_words[29]!=1 || observed_words[30]!=32'(1+run_idx) ||
        observed_words[31]!=32'(1+run_idx) ||
        observed_words[34]!=1 || observed_words[38]!=32'(1+run_idx) ||
        observed_words[48]!=1 || observed_words[49]!=32'(run_idx)) begin
      $display("QKV RUN counters q0R=%0d q1R=%0d scaleR=%0d auxR=%0d descR=%0d actR=%0d obsW=%0d obsB=%0d out0/1B=%0d/%0d traceB=%0d out0/1W=%0d/%0d traceW=%0d dot=%0d term=%0d commits=%0d hdr3/9/12/63=%h/%h/%h/%h",
               w_q0_r_count,w_q1_r_count,w_scale_r_count,aux_r_count,
               descriptor_r_count,activation_r_count,observed_hls_writes,
               observed_b_count,out0_b_count,out1_b_count,trace_b_count,
               out0_writes,out1_writes,trace_writes,
               dot_checked,term_checked,commits,observed_words[3],
               observed_words[9],observed_words[12],observed_words[63]);
      $fatal(1,"QKV actual RUN coverage/status");
    end
    if (!TRACE_ON) begin
      for (int i=58;i<=63;i++)
        if (observed_words[i]!==32'b0)
          $fatal(1,"QKV trace-off header word=%0d got=%h exp=00000000",
                 i,observed_words[i]);
      if (trace_aw_count!=0 || trace_w_count!=0 || trace_b_count!=0)
        $fatal(1,"QKV trace-off physical activity AW/W/B=%0d/%0d/%0d",
               trace_aw_count,trace_w_count,trace_b_count);
    end
    for (int i=256;i<32768;i++) begin
      logic [31:0] expected;
      expected=32'hd15ea5ed;
      if (TRACE_ON && i<256+ROWS*256) expected=a8q_gold[i-256];
      else if (TRACE_ON && i>=16640 && i<16640+ROWS*16)
        expected=half_gold[i-16640];
      else if (TRACE_ON && i>=17664 && i<17920)
        expected=trace_gold[i-17664];
      if (observed_words[i]!==expected)
        $fatal(1,"QKV observed BO/sentinel mismatch word=%0d got=%h exp=%h",
               i,observed_words[i],expected);
    end
    $display("TM1TN8_JOINT_DMA_QKV_PASS rows=%0d q0R=%0d q1R=%0d inputR=%0d dot=%0d term=%0d commits=%0d traceB=%0d outB=%0d obsB=%0d cycles=%0d",
             ROWS,w_q0_r_count,w_q1_r_count,activation_r_count,
             dot_checked,term_checked,commits,trace_b_count,
             out0_b_count+out1_b_count,observed_b_count,cycles);
    $display("TM1TN8_JOINT_DMA_QKV_STAGE run=%0d trace=%0d load_tb_cycles=%0d run_tb_cycles=%0d first_issue_from_run=%0d issue_span=%0d issue_count=%0d issue_gap=%0d source_empty=%0d issue_stall=%0d tile_busy_stall=%0d pipeline_stall=%0d result_credit_stall=%0d trace_credit_stall=%0d output_w_stall=%0d last_commit_from_run=%0d last_output_b_from_run=%0d post_last_issue_to_end=%0d mac_per_run_tb_cycle=%f mac_per_issue_span=%f",
             run_idx+1,TRACE_ON,load_segment_end-load_segment_start,
             cycles-run_segment_start,first_issue_cycle-run_segment_start,
             last_issue_cycle-first_issue_cycle+1,issue_count,
             last_issue_cycle-first_issue_cycle+1-issue_count,
             source_empty_cycles,issue_stall_cycles,tile_busy_stall_cycles,
             pipeline_stall_cycles,result_credit_stall_cycles,
             trace_credit_stall_cycles,output_w_stall_cycles,
             last_commit_cycle-run_segment_start,
             last_output_b_cycle-run_segment_start,
             cycles-last_issue_cycle,
             $itor(ROWS*3145728)/$itor(cycles-run_segment_start),
             $itor(ROWS*3145728)/
                 $itor(last_issue_cycle-first_issue_cycle+1));
    $display("TM1TN8_JOINT_DMA_QKV_COMMIT_F count=%0d missing=%0d min=%0d max=%0d mean=%f bins_lt32/64/128/256/512/1024/ge1024=%0d/%0d/%0d/%0d/%0d/%0d/%0d",
             commit_f_count,commit_f_missing,commit_f_min,commit_f_max,
             $itor(commit_f_sum)/$itor(commit_f_count),
             commit_f_hist[0],commit_f_hist[1],commit_f_hist[2],
             commit_f_hist[3],commit_f_hist[4],commit_f_hist[5],
             commit_f_hist[6]);
    if (command_accept_cycle<0 || command_done_cycle<command_accept_cycle ||
        first_tile_cycle<0 || first_b0_cycle<0 || first_b1_cycle<0 ||
        nonlast_issue_count!=ROWS*31*384 || q_occupancy_max>35)
      $fatal(1,"QKV service event coverage accept=%0d done=%0d first_tile=%0d b0=%0d b1=%0d nonlast=%0d expected=%0d qmax=%0d",
             command_accept_cycle,command_done_cycle,first_tile_cycle,
             first_b0_cycle,first_b1_cycle,nonlast_issue_count,
             ROWS*31*384,q_occupancy_max);
    $display("TM1TN8_JOINT_DMA_QKV_SERVICE run=%0d accept=%0d done=%0d done_interval=%0d control_gap=%0d first_tile=%0d first_b0=%0d first_b1=%0d out0_b_interval=%f out1_b_interval=%f nonlast_issue_count=%0d nonlast_issue_interval=%f q_occupancy_max=%0d",
             run_idx+1,command_accept_cycle,command_done_cycle,
             prev_done_cycle<0 ? -1 : command_done_cycle-prev_done_cycle,
             prev_done_cycle<0 ? -1 : command_accept_cycle-prev_done_cycle,
             first_tile_cycle,first_b0_cycle,first_b1_cycle,
             $itor(last_b0_cycle-first_b0_cycle)/$itor(ROWS*96-1),
             $itor(last_b1_cycle-first_b1_cycle)/$itor(ROWS*96-1),
             nonlast_issue_count,
             $itor(last_nonlast_issue-first_nonlast_issue)/
                 $itor(nonlast_issue_count-1),q_occupancy_max);
    for (int r=0;r<ROWS;r++) begin
      if (first_row_issue[r]<0 || last_row_b[r]<0)
        $fatal(1,"QKV row service event missing row=%0d",r);
      $display("TM1TN8_JOINT_DMA_QKV_ROW run=%0d row=%0d first_issue=%0d last_output_b=%0d next_row_overlap=%0d",
               run_idx+1,r,first_row_issue[r],last_row_b[r],
               r+1<ROWS ? last_row_b[r]-first_row_issue[r+1] : 0);
    end
    prev_done_cycle=command_done_cycle;
    end
    $finish;
  end
endmodule
