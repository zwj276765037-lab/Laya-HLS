  localparam logic [63:0] DESC_BASE=64'h0000_0004_0000_0000;
  localparam logic [63:0] Q0_BASE=64'h0000_0005_0000_0000;
  localparam logic [63:0] Q1_BASE=64'h0000_0006_0000_0000;
  localparam logic [63:0] SCALE_BASE=64'h0000_0007_0000_0000;
  localparam logic [63:0] AUX_BASE=64'h0000_0008_0000_0000;
  localparam logic [63:0] ACT_BASE=64'h0000_0009_0000_0000;
  localparam logic [63:0] OBS_BASE=64'h0000_0001_0000_1000;
  localparam logic [63:0] OUT0_BASE=64'h0000_0002_0000_0000;
  logic run_mode;
  logic [31:0] load_desc[0:127], run_desc[0:127];
  logic [511:0] q0_words[0:31], scale_words[0:1], activation_words[0:15];
  logic [31:0] aux_header[0:31], bias_words[0:1];
  logic [31:0] a8q_gold[0:63], half_gold[0:3];
  logic [31:0] output_gold[0:1], trace_gold[0:63];
  logic [31:0] observed_words[0:32767];
  logic [255:0] vdot[0:7], vdotf[0:7], vproduct[0:7];
  logic [255:0] vterm[0:7], vps[0:7];
  logic [7:0] vmask[0:7];
  int cycles, out_writes, trace_writes, observed_hls_writes;
  int dot_checked, term_checked, commits;
  string input_dir, vec_dir;

  task automatic compare_lanes(input logic [255:0] actual,
                               input logic [255:0] expected,
                               input logic [7:0] mask,
                               input int seq, input string stage);
    for (int lane=0;lane<8;lane++)
      if (mask[lane] && actual[lane*32 +: 32] !== expected[lane*32 +: 32])
        $fatal(1,"ACT DMA %s mismatch issue=%0d lane=%0d got=%h exp=%h",
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
        w_q0_read_address<Q0_BASE+Q0_OFFSET+2048 &&
        w_q0_read_address[5:0]==0)
      w_q0_read_contents=q0_words[int'((w_q0_read_address-Q0_BASE-Q0_OFFSET)>>6)];
    w_q1_read_contents='x;
    w_scale_read_contents='x;
    if (w_scale_read_address>=SCALE_BASE+SCALE_OFFSET &&
        w_scale_read_address<SCALE_BASE+SCALE_OFFSET+128 &&
        w_scale_read_address[5:0]==0)
      w_scale_read_contents=scale_words[int'((w_scale_read_address-SCALE_BASE-SCALE_OFFSET)>>6)];
    aux_read_contents='x;
    if (aux_read_address>=AUX_BASE && aux_read_address<AUX_BASE+128 &&
        aux_read_address[1:0]==0)
      aux_read_contents=aux_header[int'((aux_read_address-AUX_BASE)>>2)];
    else if (aux_read_address>=AUX_BASE+BIAS_OFFSET &&
             aux_read_address<AUX_BASE+BIAS_OFFSET+8 &&
             aux_read_address[1:0]==0)
      aux_read_contents=bias_words[int'((aux_read_address-AUX_BASE-BIAS_OFFSET)>>2)];
    activation_read_contents='x;
    if (activation_read_address>=ACT_BASE &&
        activation_read_address<ACT_BASE+1024 &&
        activation_read_address[5:0]==0)
      activation_read_contents=activation_words[int'((activation_read_address-ACT_BASE)>>6)];
    observed_read_contents='x;
    out0_read_contents='x;
    out1_read_contents='x;
    trace_read_contents='x;
  end

  always @(posedge ap_clk) if (ap_rst_n) begin
    int address_word, seq;
    cycles <= cycles+1;
    if (cycles>4000000) $fatal(1,"joint DMA ACT cycle timeout");
    if (m_axi_gmem_descriptor_AWVALID || m_axi_gmem_w_q0_AWVALID ||
        m_axi_gmem_w_q1_AWVALID || m_axi_gmem_w_scale_AWVALID ||
        m_axi_gmem_aux_AWVALID || m_axi_gmem_activation_AWVALID ||
        m_axi_gmem_w_q1_ARVALID || m_axi_gmem_observed_ARVALID)
      $fatal(1,"unexpected source write or inactive AXI read");
    if (m_axi_gmem_descriptor_RVALID && m_axi_gmem_descriptor_RREADY &&
        (^descriptor_read_contents===1'bx))
      $fatal(1,"descriptor read outside valid BO");
    if (m_axi_gmem_w_q0_RVALID && m_axi_gmem_w_q0_RREADY &&
        (^w_q0_read_contents===1'bx))
      $fatal(1,"q0 read outside actual package window");
    if (m_axi_gmem_w_scale_RVALID && m_axi_gmem_w_scale_RREADY &&
        (^w_scale_read_contents===1'bx))
      $fatal(1,"scale read outside actual package window");
    if (m_axi_gmem_aux_RVALID && m_axi_gmem_aux_RREADY &&
        (^aux_read_contents===1'bx))
      $fatal(1,"aux read outside actual header/bias window");
    if (m_axi_gmem_activation_RVALID && m_axi_gmem_activation_RREADY &&
        (^activation_read_contents===1'bx))
      $fatal(1,"activation read outside independent source slice");
    if (run_mode && dut.bridge.ps_controller.arithmetic.commit_valid &&
        dut.bridge.ps_controller.arithmetic.commit_ready) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.commit_tag[62:36]);
      if (seq!=commits || seq>=8 ||
          dut.bridge.ps_controller.arithmetic.commit_bad_mask!==0 ||
          dut.bridge.ps_controller.arithmetic.commit_lane_mask!==8'h03)
        $fatal(1,"ACT DMA PS commit tag=%0d expected=%0d",seq,commits);
      compare_lanes(dut.bridge.ps_controller.arithmetic.commit_next_ps,
                    vps[seq],vmask[seq],seq,"PS");
      commits <= commits+1;
    end
    if (m_axi_gmem_observed_WVALID && m_axi_gmem_observed_WREADY) begin
      if (observed_write_address<OBS_BASE ||
          observed_write_address>=OBS_BASE+131072 ||
          observed_write_address[1:0]!=0 ||
          m_axi_gmem_observed_WSTRB!==4'hf)
        $fatal(1,"HLS observed write bounds/strb");
      address_word=int'((observed_write_address-OBS_BASE)>>2);
      if (address_word>=256 &&
          !(run_mode &&
            ((address_word>=256 && address_word<320) ||
             (address_word>=16640 && address_word<16644))))
        $fatal(1,"HLS observed writer overlapped protected region word=%0d",
               address_word);
      observed_words[address_word] <= m_axi_gmem_observed_WDATA;
      observed_hls_writes <= observed_hls_writes+1;
    end
    if (m_axi_observed_trace_WVALID && m_axi_observed_trace_WREADY) begin
      if (!run_mode || trace_writes>=64 ||
          trace_write_address !== OBS_BASE+70656+64'(trace_writes)*4 ||
          m_axi_observed_trace_WSTRB!==4'hf ||
          m_axi_observed_trace_WDATA!==trace_gold[trace_writes])
        $fatal(1,"physical ACT trace word=%0d addr=%h",trace_writes,
               trace_write_address);
      observed_words[17664+trace_writes] <= m_axi_observed_trace_WDATA;
      trace_writes <= trace_writes+1;
    end
    if (m_axi_out0_WVALID && m_axi_out0_WREADY) begin
      if (!run_mode || out_writes!=0 ||
          out0_write_address!==OUT0_BASE ||
          m_axi_out0_WSTRB!==64'h0000_0000_0000_00ff ||
          m_axi_out0_WDATA[31:0]!==output_gold[0] ||
          m_axi_out0_WDATA[63:32]!==output_gold[1])
        $fatal(1,"physical ACT 8-byte output/WSTRB");
      out_writes <= out_writes+1;
    end
    if (m_axi_out1_AWVALID || m_axi_out1_WVALID)
      $fatal(1,"ACT out1 touched");
    if (command_done && (!dut.hls_axi_debt_zero ||
                         !dut.bridge_debt_zero ||
                         !descriptor_debt_zero || !w_q0_debt_zero ||
                         !w_q1_debt_zero || !w_scale_debt_zero ||
                         !aux_debt_zero || !activation_debt_zero ||
                         !observed_debt_zero || !out0_debt_zero ||
                         !out1_debt_zero || !trace_debt_zero))
      $fatal(1,"first command_done before physical/adaptor debt zero");
  end

  always @(negedge ap_clk) if (ap_rst_n && run_mode) begin
    int seq;
    if (dut.bridge.ps_controller.arithmetic.fp_restore.valid_c) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.fp_restore.meta_c.tag[62:36]);
      if (seq<0 || seq>=8) $fatal(1,"ACT converted tag range");
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
      if (seq<0 || seq>=8) $fatal(1,"ACT term tag range");
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
    if (command_fault) $fatal(1,"joint DMA ACT command fault");
  endtask

  initial begin : test
    if (!$value$plusargs("INPUT_DIR=%s",input_dir) ||
        !$value$plusargs("VEC_DIR=%s",vec_dir))
      $fatal(1,"INPUT_DIR/VEC_DIR plusargs required");
    $readmemh({input_dir,"/desc_load.hex"},load_desc);
    $readmemh({input_dir,"/desc_run.hex"},run_desc);
    $readmemh({input_dir,"/q0.hex"},q0_words);
    $readmemh({input_dir,"/scale.hex"},scale_words);
    $readmemh({input_dir,"/aux_header.hex"},aux_header);
    $readmemh({input_dir,"/bias.hex"},bias_words);
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
    cycles=0; out_writes=0; trace_writes=0; observed_hls_writes=0;
    dot_checked=0; term_checked=0; commits=0;
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
    repeat(16) @(negedge ap_clk);
    ap_rst_n=1;
    launch();
    if (w_q0_r_count!=32 || w_scale_r_count!=2 || aux_r_count!=34 ||
        descriptor_r_count!=128 || activation_r_count!=0 ||
        observed_hls_writes!=256 || out_writes!=0 || trace_writes!=0 ||
        observed_words[3]!=0 || observed_words[9]!=1 ||
        observed_words[40]!=2)
      $fatal(1,"actual ACT LOAD_W physical coverage/status");
    run_mode=1;
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
    launch();
    if (w_q0_r_count!=32 || w_scale_r_count!=2 || aux_r_count!=34 ||
        descriptor_r_count!=256 || activation_r_count!=16 ||
        observed_hls_writes!=580 || observed_b_count==0 ||
        out0_b_count!=1 || out1_b_count!=0 || trace_b_count!=64 ||
        out_writes!=1 || trace_writes!=64 ||
        dot_checked!=8 || term_checked!=8 || commits!=8 ||
        observed_words[3]!=0 || observed_words[9]!=3 ||
        observed_words[12]!=2 || observed_words[63]!=8)
      $fatal(1,"actual ACT RUN physical coverage/status");
    for (int i=0;i<32768;i++) begin
      logic [31:0] expected;
      expected=32'hd15ea5ed;
      if (i<256) continue;
      if (i>=256 && i<320) expected=a8q_gold[i-256];
      else if (i>=16640 && i<16644) expected=half_gold[i-16640];
      else if (i>=17664 && i<17728) expected=trace_gold[i-17664];
      if (observed_words[i]!==expected)
        $fatal(1,"observed BO/sentinel mismatch word=%0d got=%h exp=%h",
               i,observed_words[i],expected);
    end
    $display("TM1TN8_JOINT_DMA_ACT_PASS q0R=%0d scaleR=%0d inputR=%0d dot=%0d term=%0d commits=%0d traceB=%0d outB=%0d obsB=%0d",
             w_q0_r_count,w_scale_r_count,activation_r_count,
             dot_checked,term_checked,commits,
             trace_b_count,out0_b_count,observed_b_count);
    $finish;
  end
endmodule
