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
  logic [7:0] vmask[0:ISSUES-1];
  int cycles, out0_writes, out1_writes, trace_writes;
  int observed_hls_writes, dot_checked, term_checked, commits;
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
    @(negedge ap_clk); command_start=1;
    @(negedge ap_clk); command_start=0;
    wait(command_done);
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
    ap_clk=0; ap_rst_n=0; run_mode=0;
    command_start=0; descriptor_base=DESC_BASE;
    w_q0_base=Q0_BASE; w_q1_base=Q1_BASE;
    w_scale_base=SCALE_BASE; aux_base=AUX_BASE;
    activation_base=ACT_BASE;
    observed_base=OBS_BASE; observed_span=131072;
    cycles=0; out0_writes=0; out1_writes=0;
    trace_writes=0; observed_hls_writes=0;
    dot_checked=0; term_checked=0; commits=0;
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
    repeat(16) @(negedge ap_clk);
    ap_rst_n=1;
    launch();
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
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
    launch();
    if (w_q0_r_count!=24576 || w_q1_r_count!=24576 ||
        w_scale_r_count!=3072 || aux_r_count!=32 ||
        descriptor_r_count!=256 || activation_r_count!=ROWS*64 ||
        observed_hls_writes!=512+(TRACE_ON ? ROWS*272 : 0) ||
        observed_b_count==0 ||
        out0_b_count!=ROWS*96 || out1_b_count!=ROWS*96 ||
        trace_b_count!=(TRACE_ON ? 256 : 0) ||
        out0_writes!=ROWS*96 || out1_writes!=ROWS*96 ||
        trace_writes!=(TRACE_ON ? 256 : 0) ||
        dot_checked!=ISSUES || term_checked!=ISSUES || commits!=ISSUES ||
        observed_words[3]!=0 || observed_words[9]!=3 ||
        observed_words[12]!=ROWS*3072 ||
        observed_words[63]!=(TRACE_ON ? 32 : 0)) begin
      $display("QKV RUN counters q0R=%0d q1R=%0d scaleR=%0d auxR=%0d descR=%0d actR=%0d obsW=%0d obsB=%0d out0/1B=%0d/%0d traceB=%0d out0/1W=%0d/%0d traceW=%0d dot=%0d term=%0d commits=%0d hdr3/9/12/63=%h/%h/%h/%h",
               w_q0_r_count,w_q1_r_count,w_scale_r_count,aux_r_count,
               descriptor_r_count,activation_r_count,observed_hls_writes,
               observed_b_count,out0_b_count,out1_b_count,trace_b_count,
               out0_writes,out1_writes,trace_writes,
               dot_checked,term_checked,commits,observed_words[3],
               observed_words[9],observed_words[12],observed_words[63]);
      $fatal(1,"QKV actual RUN coverage/status");
    end
    for (int i=256;i<32768;i++) begin
      logic [31:0] expected;
      expected=32'hd15ea5ed;
      if (i<256+ROWS*256) expected=a8q_gold[i-256];
      else if (i>=16640 && i<16640+ROWS*16)
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
    $finish;
  end
endmodule
