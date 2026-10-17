  localparam logic [63:0] DESC_BASE=64'h0000_0004_0000_0000;
  localparam logic [63:0] Q0_BASE=64'h0000_0005_0000_0000;
  localparam logic [63:0] Q1_BASE=64'h0000_0006_0000_0000;
  localparam logic [63:0] SCALE_BASE=64'h0000_0007_0000_0000;
  localparam logic [63:0] AUX_BASE=64'h0000_0008_0000_0000;
  localparam logic [63:0] ACT_BASE=64'h0000_0009_0000_0000;
  localparam logic [63:0] OBS_BASE=64'h0000_0001_0000_1000;
  localparam logic [63:0] OUT0_BASE=64'h0000_0002_0000_0000;
  localparam int REGISTER=0, LOAD1=1, RUN1=2, LOAD2=3, RUN2=4, REVOKE=5;
  int command_mode;
  logic run_mode;
  assign run_mode = command_mode == RUN1 || command_mode == RUN2;
  logic [31:0] register_desc[0:255], load1_desc[0:255],
               run1_desc[0:255], load2_desc[0:255],
               run2_desc[0:255], revoke_desc[0:255];
  logic [63:0] binding_words[0:17];
  logic [511:0] q0_words[0:31], scale_words[0:1], activation_words[0:15];
  logic [31:0] aux_header[0:31], bias_words[0:1];
  logic [31:0] a8q_gold[0:63], half_gold[0:3];
  logic [31:0] output_gold[0:1], trace_gold[0:63];
  logic [31:0] observed_words[0:32767];
  logic [255:0] vdot[0:7], vdotf[0:7], vproduct[0:7], vsw[0:7];
  logic [255:0] vterm[0:7], vps[0:7];
  logic [31:0] vsa[0:7];
  logic [7:0] vmask[0:7];
  int cycles, out_writes, trace_writes, observed_hls_writes;
  int dot_checked, term_checked, commits, quant_checked;
  int weight_bytes_checked, scale_values_checked, bias_values_checked;
  int model_last_r_hold_cycles;
  int binding_beats_checked;
  int load_segment_start, load_segment_end, run_segment_start;
  int first_issue_cycle, last_issue_cycle, last_commit_cycle;
  int last_output_b_cycle, issue_count;
  int source_empty_cycles, issue_stall_cycles, tile_busy_stall_cycles;
  int pipeline_stall_cycles, result_credit_stall_cycles;
  int trace_credit_stall_cycles, output_w_stall_cycles;
  int command_accept_cycle, command_done_cycle, prev_done_cycle;
  int negative_count;
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
        descriptor_read_address<DESC_BASE+1024 &&
        descriptor_read_address[1:0]==0) begin
      case (command_mode)
        REGISTER: descriptor_read_contents=register_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        LOAD1: descriptor_read_contents=load1_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        RUN1: descriptor_read_contents=run1_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        LOAD2: descriptor_read_contents=load2_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        RUN2: descriptor_read_contents=run2_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        REVOKE: descriptor_read_contents=revoke_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        default: descriptor_read_contents='x;
      endcase
    end
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
    if (cycles>4000000) $fatal(1,"session v2 ACT cycle timeout");
    if (dut.binding_context_TVALID && dut.binding_context_TREADY)
      binding_beats_checked++;
    if ((w_q0_memory.reading && w_q0_memory.r_delay!=0) ||
        (w_scale_memory.reading && w_scale_memory.r_delay!=0) ||
        (aux_memory.reading && aux_memory.r_delay!=0))
      model_last_r_hold_cycles++;
    // Passive timing and independent quant checks do not change stimulus.
    if (run_mode) begin
      if (dut.bridge.bias_tvalid && dut.bridge.bias_tready) begin
        if (dut.bridge.bias_tdata[273] !== 1'b1 ||
            dut.bridge.bias_tdata[272:265] !== 8'h03 ||
            dut.bridge.bias_tdata[264:256] !== 9'd0 ||
            dut.bridge.bias_tdata[31:0] !== bias_words[0] ||
            dut.bridge.bias_tdata[63:32] !== bias_words[1])
          $fatal(1,"ACT cached bias packet differs from package");
        bias_values_checked+=2;
      end
      if (dut.bridge.group_tvalid && dut.bridge.group_tready) begin
        int qrow,qgroup,qtile,qseq;
        qrow=int'(dut.bridge.group_tdata[2608:2607]);
        qgroup=int'(dut.bridge.group_tdata[2606:2601]);
        qtile=int'(dut.bridge.group_tdata[2600:2592]);
        qseq=qgroup;
        if (qrow!=0 || qgroup>=8 || qtile!=0 ||
            qseq!=quant_checked)
          $fatal(1,"ACT trace-off quant group order row=%0d g=%0d tile=%0d expected=%0d",
                 qrow,qgroup,qtile,quant_checked);
        for (int qword=0;qword<8;qword++)
          if (dut.bridge.group_tdata[qword*32 +: 32] !==
              a8q_gold[qgroup*8+qword])
            $fatal(1,"ACT trace-off quant q mismatch g=%0d word=%0d",
                   qgroup,qword);
        if (dut.bridge.group_tdata[2335:2304] !== vsa[qseq])
          $fatal(1,"ACT trace-off quant scale mismatch g=%0d got=%h exp=%h",
                 qgroup,dut.bridge.group_tdata[2335:2304],vsa[qseq]);
        for (int lane=0;lane<8;lane++) begin
          logic [255:0] expected_q;
          expected_q=q0_words[4*qgroup+lane/2][(lane%2)*256 +: 256];
          if (dut.bridge.group_tdata[256+lane*256 +: 256] !== expected_q)
            $fatal(1,"ACT cached q differs from package group=%0d lane=%0d",
                   qgroup,lane);
          if (dut.bridge.group_tdata[2336+lane*32 +: 32] !==
              vsw[qgroup][lane*32 +: 32])
            $fatal(1,"ACT cached scale differs from independent gold group=%0d lane=%0d",
                   qgroup,lane);
        end
        weight_bytes_checked+=256;
        scale_values_checked+=8;
        quant_checked++;
        if (first_issue_cycle<0) first_issue_cycle=cycles;
        last_issue_cycle=cycles;
        issue_count++;
      end else if (issue_count>0 && issue_count<8) begin
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
      if (m_axi_out0_WVALID && !m_axi_out0_WREADY)
        output_w_stall_cycles++;
      if (m_axi_out0_BVALID && m_axi_out0_BREADY)
        last_output_b_cycle=cycles;
    end
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
      last_commit_cycle=cycles;
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
      if (!TRACE_ON || !run_mode || trace_writes>=64 ||
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
    @(negedge ap_clk);
    if (!command_ready) $fatal(1,"ACT command ready lost before launch");
    command_start=1;
    binding_beats_checked=0;
    command_accept_cycle=cycles+1;
    @(negedge ap_clk); command_start=0;
    wait(command_done);
    command_done_cycle=cycles;
    if (binding_beats_checked!=18)
      $fatal(1,"actual wrapper binding consumed %0d beats",binding_beats_checked);
    if (!dut.hls_axi_debt_zero || !dut.bridge_debt_zero ||
        !descriptor_debt_zero || !w_q0_debt_zero || !w_q1_debt_zero ||
        !w_scale_debt_zero || !aux_debt_zero || !activation_debt_zero ||
        !observed_debt_zero || !out0_debt_zero || !out1_debt_zero ||
        !trace_debt_zero)
      $fatal(1,"ACT first command_done before all physical/adaptor debt zero");
    @(negedge ap_clk);
    if (command_fault) $fatal(1,"joint DMA ACT command fault");
  endtask

  task automatic clear_observed;
    observed_hls_writes=0;
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
  endtask

  task automatic reset_session;
    command_mode=REGISTER;
    command_start=0;
    ap_rst_n=0;
    w_q0_base=Q0_BASE;
    model_bo_cookie[64 +: 64]=binding_words[8];
    context_cookie={binding_words[1],binding_words[0]};
    model_generation=binding_words[2];
    repeat(16) @(negedge ap_clk);
    ap_rst_n=1;
    clear_observed();
  endtask

  task automatic register_fresh;
    reset_session();
    command_mode=REGISTER;
    launch();
    check_header(2,1,1,0);
    if (aux_r_count!=32 || w_q0_r_count!=0 ||
        w_scale_r_count!=0 || activation_r_count!=0)
      $fatal(1,"negative setup REGISTER physical scope");
  endtask

  task automatic reject_without_task(input string label,
                                     input bit expected_binding_match,
                                     input int expected_status,
                                     input int expected_reject,
                                     input int expected_owner,
                                     input int expected_session_state,
                                     input bit invalidate_cache=0);
    int descriptor_before, q_before, scale_before, aux_before;
    int activation_before, out_before, trace_before;
    logic [31:0] old_last_task, old_w_epoch, old_w_max, old_w_loads;
    logic [31:0] old_highwater_lo, old_highwater_hi;
    logic [31:0] old_w_state, old_w_generation, old_w_profile;
    descriptor_before=descriptor_r_count;
    q_before=w_q0_r_count;
    scale_before=w_scale_r_count;
    aux_before=aux_r_count;
    activation_before=activation_r_count;
    out_before=out0_w_count;
    trace_before=trace_w_count;
    old_last_task=observed_words[8];
    old_w_epoch=observed_words[29];
    old_w_state=observed_words[40];
    old_w_max=observed_words[44];
    old_w_loads=observed_words[48];
    old_highwater_lo=observed_words[150];
    old_highwater_hi=observed_words[151];
    old_w_generation=observed_words[152];
    old_w_profile=observed_words[154];
    if (observed_words[0]!==32'h324f3851) begin
      // reset_session clears the observed BO; the device state is empty.
      old_last_task=0;old_w_epoch=0;old_w_state=6;
      old_w_max=0;old_w_loads=0;
      old_highwater_lo=0;old_highwater_hi=0;
      old_w_generation=0;old_w_profile=0;
    end
    if (invalidate_cache) begin
      old_w_epoch=0;old_w_state=6;old_w_generation=0;old_w_profile=0;
    end
    clear_observed();
    launch();
    if (observed_hls_writes!=256 ||
        observed_words[3]!=32'(expected_status) ||
        observed_words[8]!==old_last_task || observed_words[9]!=0 ||
        observed_words[29]!==old_w_epoch || observed_words[40]!==old_w_state ||
        observed_words[44]!==old_w_max || observed_words[48]!==old_w_loads ||
        observed_words[123]!=32'(expected_session_state) ||
        observed_words[124]!=32'(expected_session_state==1 ? 1 : 0) ||
        observed_words[125]!=0 ||
        observed_words[150]!==old_highwater_lo ||
        observed_words[151]!==old_highwater_hi ||
        observed_words[152]!==old_w_generation ||
        observed_words[154]!==old_w_profile ||
        observed_words[155]!=32'(expected_owner) ||
        observed_words[156]!=32'(expected_reject) ||
        observed_words[126]!=0 ||
        observed_words[127]!=32'(expected_binding_match) ||
        descriptor_r_count!=descriptor_before+256 ||
        w_q0_r_count!=q_before || w_scale_r_count!=scale_before ||
        aux_r_count!=aux_before || activation_r_count!=activation_before ||
        out0_w_count!=out_before || trace_w_count!=trace_before)
      $fatal(1,"negative %s rejection mismatch status=%0d task=%0d admission=%0d binding=%0d owner=%0d reject=%0d session=%0d last=%0d w_epoch=%0d w_state=%0d w_max=%0d w_loads=%0d highwater=%0d observed_w=%0d desc_r=%0d/%0d q_r=%0d/%0d scale_r=%0d/%0d aux_r=%0d/%0d act_r=%0d/%0d out_w=%0d/%0d trace_w=%0d/%0d",
             label,observed_words[3],observed_words[9],observed_words[126],
             observed_words[127],observed_words[155],observed_words[156],
             observed_words[123],observed_words[8],observed_words[29],
             observed_words[40],observed_words[44],observed_words[48],
             observed_words[150],observed_hls_writes,descriptor_r_count,
             descriptor_before+256,w_q0_r_count,q_before,w_scale_r_count,
             scale_before,aux_r_count,aux_before,activation_r_count,
             activation_before,out0_w_count,out_before,trace_w_count,trace_before);
    $display("TM1TN8_SESSION_DMA_V2_REJECT_PASS case=%s status=%0d session_reject=%0d owner=%0d state=%0d w_epoch=%0d highwater=%0d",
             label,observed_words[3],observed_words[156],observed_words[155],
             observed_words[123],observed_words[29],observed_words[150]);
    negative_count++;
  endtask

  task automatic check_rebuild_run(input string label);
    check_header(1,1,2,0);
    if (observed_words[8]!=3 || observed_words[9]!=3 ||
        observed_words[29]!=1 || observed_words[30]!=1 ||
        observed_words[31]!=1 || observed_words[40]!=2 ||
        observed_words[44]!=1 || observed_words[48]!=1 ||
        observed_words[123]!=1 || observed_words[124]!=2 ||
        observed_words[150]!=2 || observed_words[152]!=2 ||
        observed_words[155]!=0 || out_writes!=1 ||
        trace_writes!=(TRACE_ON ? 64 : 0) || quant_checked!=8 ||
        dot_checked!=8 || term_checked!=8 || commits!=8 ||
        weight_bytes_checked!=2048 || scale_values_checked!=64 ||
        bias_values_checked!=2)
      $fatal(1,"closure generation2 RUN mismatch case=%s",label);
    for (int i=256;i<32768;i++) begin
      logic [31:0] expected;
      expected=32'hd15ea5ed;
      if (TRACE_ON && i<320) expected=a8q_gold[i-256];
      else if (TRACE_ON && i>=16640 && i<16644) expected=half_gold[i-16640];
      else if (TRACE_ON && i>=17664 && i<17728) expected=trace_gold[i-17664];
      if (observed_words[i]!==expected)
        $fatal(1,"closure rebuilt observed mismatch case=%s word=%0d",label,i);
    end
    $display("TM1TN8_SESSION_DMA_V2_CLOSURE_REBUILD_PASS case=%s generation=2 q_bytes=%0d scale_values=%0d bias_values=%0d output_writes=%0d trace_writes=%0d",
             label,weight_bytes_checked,scale_values_checked,bias_values_checked,
             out_writes,trace_writes);
  endtask

  task automatic rebuild_generation_two(input string label);
    int q_before,scale_before,aux_before,act_before,out_before,trace_before;
    q_before=w_q0_r_count;scale_before=w_scale_r_count;aux_before=aux_r_count;
    act_before=activation_r_count;out_before=out0_b_count;trace_before=trace_b_count;
    register_desc[66]=2;load1_desc[66]=2;run1_desc[66]=2;
    model_generation=2;
    command_mode=REGISTER;
    clear_observed();launch();check_header(2,1,1,0);
    if (observed_words[8]!=0 || observed_words[29]!=0 ||
        observed_words[44]!=0 || observed_words[48]!=0 ||
        observed_words[124]!=2 || observed_words[150]!=2 ||
        aux_r_count!=aux_before+32 || w_q0_r_count!=q_before ||
        w_scale_r_count!=scale_before || activation_r_count!=act_before)
      $fatal(1,"closure generation2 REGISTER mismatch case=%s",label);
    command_mode=LOAD1;
    clear_observed();launch();check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
    if (observed_words[8]!=1 || observed_words[9]!=1 ||
        observed_words[29]!=1 || observed_words[40]!=2 ||
        observed_words[44]!=1 || observed_words[48]!=1 ||
        observed_words[124]!=2 || observed_words[150]!=2 ||
        observed_words[152]!=2 || w_q0_r_count!=q_before+32 ||
        w_scale_r_count!=scale_before+2 || aux_r_count!=aux_before+66 ||
        activation_r_count!=act_before)
      $fatal(1,"closure generation2 LOAD mismatch case=%s",label);
    command_mode=RUN1;clear_run_checks();clear_observed();launch();
    check_rebuild_run(label);
    if (activation_r_count!=act_before+16 || out0_b_count!=out_before+1 ||
        trace_b_count!=trace_before+(TRACE_ON ? 64 : 0))
      $fatal(1,"closure generation2 physical retirement mismatch case=%s",label);
    register_desc[66]=1;load1_desc[66]=1;run1_desc[66]=1;
    model_generation=binding_words[2];
  endtask

  task automatic closure_suite;
    int invalidations,rebuilds;
    invalidations=0;rebuilds=0;
    for (int c=0;c<2;c++) begin
      $display("CLOSURE_STEP case=%0d before_register",c);
      register_fresh();
      $display("CLOSURE_STEP case=%0d after_register",c);
      command_mode=LOAD1;clear_observed();launch();
      $display("CLOSURE_STEP case=%0d after_load",c);
      check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
      if (observed_words[8]!=1 || observed_words[29]!=1 ||
          observed_words[40]!=2 || observed_words[44]!=1 ||
          observed_words[48]!=1 || observed_words[150]!=1 ||
          observed_words[152]!=1)
        $fatal(1,"closure must start from real W READY case=%0d",c);
      if (c==0) w_q0_base=Q0_BASE+4096;
      else model_bo_cookie[64 +: 64]=binding_words[8]+1;
      command_mode=RUN1;
      if (c==0)
        reject_without_task("ready_actual_base_changed",0,7,4,2,2,1);
      else
        reject_without_task("ready_actual_cookie_changed",0,7,4,2,2,1);
      if (observed_words[8]!=1 || observed_words[44]!=1 ||
          observed_words[48]!=1 || observed_words[150]!=1)
        $fatal(1,"READY invalidation lost consumed task/epoch/highwater");
      invalidations++;
      w_q0_base=Q0_BASE;model_bo_cookie[64 +: 64]=binding_words[8];
      command_mode=RUN1;reject_without_task("ready_invalidated_old_run",1,7,1,2,2);
      command_mode=LOAD1;reject_without_task("ready_invalidated_old_load",1,7,1,2,2);
      command_mode=REGISTER;reject_without_task("ready_invalidated_same_generation",1,7,7,2,2);
      if (c==0) rebuild_generation_two("ready_base_change");
      else rebuild_generation_two("ready_cookie_change");
      rebuilds++;
    end
    register_fresh();
    command_mode=LOAD1;clear_observed();launch();
    check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
    if (observed_words[40]!=2 || observed_words[29]!=1)
      $fatal(1,"closure reset setup must be W READY");
    reset_session();
    command_mode=LOAD1;reject_without_task("closure_reset_old_load",1,7,1,2,0);
    rebuild_generation_two("reset_rebuild");
    rebuilds++;
    $display("TM1TN8_SESSION_DMA_V2_CLOSURE_PASS profile=%0d reject=%0d invalidated_ready=%0d rebuild_runs=%0d",
             register_desc[64],negative_count,invalidations,rebuilds);
    $display("TM1TN8_SESSION_DMA_V2_ACT_PASS profile=%0d closure_only=1",register_desc[64]);
  endtask

  task automatic clear_run_checks;
    out_writes=0;trace_writes=0;dot_checked=0;term_checked=0;
    commits=0;quant_checked=0;
    weight_bytes_checked=0;scale_values_checked=0;bias_values_checked=0;
    first_issue_cycle=-1;last_issue_cycle=-1;last_commit_cycle=-1;
    last_output_b_cycle=-1;issue_count=0;
    source_empty_cycles=0;issue_stall_cycles=0;tile_busy_stall_cycles=0;
    pipeline_stall_cycles=0;result_credit_stall_cycles=0;
    trace_credit_stall_cycles=0;output_w_stall_cycles=0;
  endtask

  task automatic numeric_load_failure(input string label,
                                      input int expected_bad,
                                      input int expected_scale_checks);
    command_mode=LOAD1;
    clear_observed();
    launch();
    if (observed_words[3]!=6 || observed_words[5]!=32'(expected_bad) ||
        observed_words[6]!=0 || observed_words[8]!=1 ||
        observed_words[9]!=1 || observed_words[29]!=0 ||
        observed_words[40]!=6 || observed_words[44]!=1 ||
        observed_words[48]!=0 || observed_words[123]!=2 ||
        observed_words[124]!=0 || observed_words[126]!=2 ||
        observed_words[127]!=1 || observed_words[148]!=32'(expected_scale_checks) ||
        observed_words[150]!=1 || observed_words[152]!=0 ||
        observed_words[155]!=2 || observed_words[156]!=0 ||
        observed_words[120]!=1 || observed_words[121]!=1 ||
        descriptor_r_count!=512 || w_q0_r_count!=32 ||
        w_scale_r_count!=2 || aux_r_count!=66 ||
        activation_r_count!=0 || out0_w_count!=0 || trace_w_count!=0)
      $fatal(1,"numeric LOAD failure mismatch case=%s status=%0d bad=%0d owner=%0d scale=%0d",
             label,observed_words[3],observed_words[5],
             observed_words[155],observed_words[148]);
    $display("TM1TN8_SESSION_DMA_V2_NUMERIC_REJECT_PASS case=%s bad=%0d scale_checks=%0d w_epoch=%0d",
             label,observed_words[5],observed_words[148],observed_words[29]);
    negative_count++;
  endtask

  task automatic bad_header_register;
    logic [31:0] old_header, old_generation;
    old_header=aux_header[0];
    old_generation=register_desc[66];
    aux_header[0]=old_header^32'h1;
    reset_session();
    command_mode=REGISTER;
    launch();
    if (observed_words[3]!=2 || observed_words[9]!=0 ||
        observed_words[29]!=0 || observed_words[40]!=6 ||
        observed_words[123]!=2 || observed_words[124]!=0 ||
        observed_words[126]!=1 || observed_words[127]!=1 ||
        observed_words[150]!=1 || observed_words[152]!=0 ||
        observed_words[155]!=2 || observed_words[156]!=0 ||
        descriptor_r_count!=256 || aux_r_count!=32 ||
        w_q0_r_count!=0 || w_scale_r_count!=0 ||
        activation_r_count!=0 || out0_w_count!=0 || trace_w_count!=0)
      $fatal(1,"bad AUX header REGISTER scope/state mismatch status=%0d state=%0d owner=%0d",
             observed_words[3],observed_words[123],observed_words[155]);
    $display("TM1TN8_SESSION_DMA_V2_REGISTER_REJECT_PASS case=bad_aux_header state=2 highwater=1");
    negative_count++;
    aux_header[0]=old_header;
    reject_without_task("bad_header_same_generation",1,7,7,2,2);
    register_desc[66]=old_generation+1;
    model_generation=binding_words[2]+1;
    clear_observed();
    launch();
    check_header(2,1,1,0);
    if (observed_words[150]!=2 || aux_r_count!=64)
      $fatal(1,"bad-header new-generation REGISTER recovery mismatch");
    $display("TM1TN8_SESSION_DMA_V2_RECOVERY_PASS case=bad_aux_header generation=2");
    register_desc[66]=old_generation;
    model_generation=binding_words[2];
  endtask

  task automatic activation_failure_recovery;
    logic [31:0] old_activation;
    logic [31:0] old_task,old_dst_epoch,old_w_epoch,old_ps_epoch,old_quant_task;
    register_fresh();
    command_mode=LOAD1;
    clear_observed();
    launch();
    check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
    old_activation=activation_words[0][31:0];
    activation_words[0][31:0]=32'h7f800000;
    command_mode=RUN1;
    clear_run_checks();
    clear_observed();
    launch();
    if (observed_words[3]!=6 || observed_words[5]!=0 ||
        observed_words[6]!=0 || observed_words[8]!=2 ||
        observed_words[9]!=2 || observed_words[29]!=1 ||
        observed_words[30]!=1 || observed_words[31]!=0 ||
        observed_words[40]!=2 || observed_words[41]!=6 ||
        observed_words[44]!=1 || observed_words[45]!=1 ||
        observed_words[48]!=1 || observed_words[116]!=2 ||
        observed_words[117]!=6 || observed_words[119]!=0 ||
        observed_words[121]!=2 || observed_words[123]!=1 ||
        observed_words[126]!=2 || observed_words[127]!=1 ||
        observed_words[150]!=1 || observed_words[152]!=1 ||
        observed_words[155]!=3 || observed_words[156]!=0 ||
        descriptor_r_count!=768 || activation_r_count!=16 ||
        observed_hls_writes!=256 || out0_w_count!=0 || trace_w_count!=0 ||
        quant_checked!=0 || dot_checked!=0 || term_checked!=0 || commits!=0)
      $fatal(1,"bad activation RUN scope/state mismatch status=%0d bad=%0d a8=%0d w=%0d owner=%0d",
             observed_words[3],observed_words[5],observed_words[30],
             observed_words[29],observed_words[155]);
    $display("TM1TN8_SESSION_DMA_V2_NUMERIC_REJECT_PASS case=bad_activation bad=0 a8_epoch=1 w_epoch=1");
    negative_count++;
    activation_words[0][31:0]=old_activation;
    old_task=run2_desc[8];old_dst_epoch=run2_desc[27];
    old_w_epoch=run2_desc[29];old_ps_epoch=run2_desc[30];
    old_quant_task=run2_desc[31];
    run2_desc[8]=4;run2_desc[27]=1;run2_desc[29]=1;
    run2_desc[30]=1;run2_desc[31]=3;
    command_mode=RUN2;
    clear_run_checks();
    clear_observed();
    launch();
    check_header(1,1,2,0);
    if (observed_words[8]!=4 || observed_words[9]!=4 ||
        observed_words[29]!=1 || observed_words[30]!=2 ||
        observed_words[31]!=1 || observed_words[40]!=2 ||
        observed_words[48]!=1 || observed_words[116]!=3 ||
        observed_words[117]!=0 || observed_words[123]!=1 ||
        observed_words[150]!=1 || observed_words[152]!=1 ||
        observed_words[155]!=0 || descriptor_r_count!=1024 ||
        activation_r_count!=32 || out0_b_count!=1 ||
        trace_b_count!=(TRACE_ON ? 64 : 0) ||
        out_writes!=1 || trace_writes!=(TRACE_ON ? 64 : 0) ||
        quant_checked!=8 || dot_checked!=8 || term_checked!=8 || commits!=8 ||
        weight_bytes_checked!=2048 || scale_values_checked!=64 ||
        bias_values_checked!=2)
      $fatal(1,"valid RUN after activation failure did not recover");
    for (int i=256;i<32768;i++) begin
      logic [31:0] expected;
      expected=32'hd15ea5ed;
      if (TRACE_ON && i>=256 && i<320) expected=a8q_gold[i-256];
      else if (TRACE_ON && i>=16640 && i<16644)
        expected=half_gold[i-16640];
      else if (TRACE_ON && i>=17664 && i<17728)
        expected=trace_gold[i-17664];
      if (observed_words[i]!==expected)
        $fatal(1,"activation recovery observed BO mismatch word=%0d",i);
    end
    $display("TM1TN8_SESSION_DMA_V2_RECOVERY_PASS case=bad_activation quant_task=3 run_task=4 a8_epoch=2");
    run2_desc[8]=old_task;run2_desc[27]=old_dst_epoch;
    run2_desc[29]=old_w_epoch;run2_desc[30]=old_ps_epoch;
    run2_desc[31]=old_quant_task;
  endtask

  task automatic recover_failed_load(input string label);
    logic [31:0] old_register_generation, old_load_generation;
    command_mode=REGISTER;
    reject_without_task("failed_load_same_generation",1,7,7,2,2);
    old_register_generation=register_desc[66];
    old_load_generation=load1_desc[66];
    register_desc[66]=old_register_generation+1;
    load1_desc[66]=old_load_generation+1;
    model_generation=binding_words[2]+1;
    command_mode=REGISTER;
    clear_observed();
    launch();
    check_header(2,1,1,0);
    if (observed_words[150]!=2 || aux_r_count!=98)
      $fatal(1,"new-generation REGISTER after %s failed",label);
    command_mode=LOAD1;
    clear_observed();
    launch();
    check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
    if (observed_words[8]!=1 || observed_words[9]!=1 ||
        observed_words[29]!=1 || observed_words[40]!=2 ||
        observed_words[44]!=1 || observed_words[48]!=1 ||
        observed_words[123]!=1 || observed_words[150]!=2 ||
        observed_words[152]!=2 || observed_words[155]!=0 ||
        w_q0_r_count!=64 || w_scale_r_count!=4 || aux_r_count!=132)
      $fatal(1,"valid LOAD after %s did not recover",label);
    $display("TM1TN8_SESSION_DMA_V2_RECOVERY_PASS case=%s generation=2 w_epoch=1",
             label);
    register_desc[66]=old_register_generation;
    load1_desc[66]=old_load_generation;
    model_generation=binding_words[2];
  endtask

  task automatic check_header(input int expected_command, input int expected_state,
                              input int expected_admission, input int expected_scale_checks);
    if (observed_hls_writes!=256+((run_mode && TRACE_ON) ? 68 : 0) ||
        observed_words[0]!==32'h324f3851 ||
        observed_words[1]!==2 || observed_words[2]!==32'(expected_command) ||
        observed_words[3]!==0 || observed_words[122]!==register_desc[64] ||
        observed_words[123]!==32'(expected_state) ||
        observed_words[126]!==32'(expected_admission) ||
        observed_words[127]!==1 ||
        observed_words[148]!==32'(expected_scale_checks) ||
        observed_words[149]!==0 || observed_words[157]!==1024 ||
        observed_words[158]!==18)
      $fatal(1,"v2 header command=%0d status=%h state=%h admission=%h checks=%h",
             expected_command,observed_words[3],observed_words[123],
             observed_words[126],observed_words[148]);
    for (int i=0;i<8;i++)
      if (observed_words[140+i]!==register_desc[88+i])
        $fatal(1,"compiled build SHA mismatch word=%0d",i);
  endtask

  initial begin : test
    if (!$value$plusargs("INPUT_DIR=%s",input_dir) ||
        !$value$plusargs("VEC_DIR=%s",vec_dir))
      $fatal(1,"INPUT_DIR/VEC_DIR plusargs required");
    $readmemh({input_dir,"/register.hex"},register_desc);
    $readmemh({input_dir,"/load1.hex"},load1_desc);
    $readmemh({input_dir,"/run1.hex"},run1_desc);
    $readmemh({input_dir,"/load2.hex"},load2_desc);
    $readmemh({input_dir,"/run2.hex"},run2_desc);
    $readmemh({input_dir,"/revoke.hex"},revoke_desc);
    $readmemh({input_dir,"/binding.hex"},binding_words);
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
    $readmemh({vec_dir,"/sw.hex"},vsw);
    $readmemh({vec_dir,"/sa.hex"},vsa);
    ap_clk=0; ap_rst_n=0; command_mode=REGISTER;
    command_start=0; descriptor_base=DESC_BASE;
    w_q0_base=Q0_BASE; w_q1_base=Q1_BASE;
    w_scale_base=SCALE_BASE; aux_base=AUX_BASE;
    activation_base=ACT_BASE;
    observed_base=OBS_BASE; observed_span=131072;
    context_cookie={binding_words[1],binding_words[0]};
    model_generation=binding_words[2];
    embedding_base=binding_words[3];
    for (int i=0;i<5;i++) begin
      model_bo_bytes[i*64 +: 64]=binding_words[4+3*i];
      model_bo_cookie[i*64 +: 64]=binding_words[5+3*i];
    end
    if (binding_words[6]!==Q0_BASE || binding_words[9]!==Q1_BASE ||
        binding_words[12]!==SCALE_BASE || binding_words[15]!==AUX_BASE)
      $fatal(1,"binding source differs from actual latched model pointer");
    cycles=0; out_writes=0; trace_writes=0; observed_hls_writes=0;
    dot_checked=0; term_checked=0; commits=0; quant_checked=0;
    weight_bytes_checked=0;scale_values_checked=0;bias_values_checked=0;
    model_last_r_hold_cycles=0;
    binding_beats_checked=0;
    load_segment_start=0;load_segment_end=0;run_segment_start=0;
    first_issue_cycle=-1;last_issue_cycle=-1;last_commit_cycle=-1;
    last_output_b_cycle=-1;issue_count=0;
    source_empty_cycles=0;issue_stall_cycles=0;tile_busy_stall_cycles=0;
    pipeline_stall_cycles=0;result_credit_stall_cycles=0;
    trace_credit_stall_cycles=0;output_w_stall_cycles=0;
    command_accept_cycle=-1;command_done_cycle=-1;prev_done_cycle=-1;
    negative_count=0;
    clear_observed();
    repeat(16) @(negedge ap_clk);
    ap_rst_n=1;
    if ($test$plusargs("CLOSURE_ONLY")) begin
      closure_suite();
      $finish;
    end
    launch();
    check_header(2,1,1,0);
    if (aux_r_count!=32 || w_q0_r_count!=0 || w_scale_r_count!=0 ||
        descriptor_r_count!=256 || observed_words[9]!=0)
      $fatal(1,"REGISTER physical scope/task");

    for (int load_idx=0;load_idx<2;load_idx++) begin
      command_mode=load_idx==0 ? LOAD1 : LOAD2;
      clear_observed();
      load_segment_start=cycles;
      model_last_r_hold_cycles=0;
      launch();
      load_segment_end=cycles;
      check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
      if (descriptor_r_count!=32'(512+512*load_idx) ||
          w_q0_r_count!=32'(32*(load_idx+1)) ||
          w_scale_r_count!=32'(2*(load_idx+1)) ||
          aux_r_count!=32'(32+34*(load_idx+1)) ||
          activation_r_count!=32'(16*load_idx) ||
          observed_words[9]!=32'(1+3*load_idx) ||
          observed_words[40]!=2 || observed_words[152]!=model_generation[31:0] ||
          model_last_r_hold_cycles==0)
        $fatal(1,"LOAD%0d physical scope/status",load_idx+1);
      command_mode=load_idx==0 ? RUN1 : RUN2;
      out_writes=0;trace_writes=0;dot_checked=0;term_checked=0;
      commits=0;quant_checked=0;
      weight_bytes_checked=0;scale_values_checked=0;bias_values_checked=0;
      first_issue_cycle=-1;last_issue_cycle=-1;last_commit_cycle=-1;
      last_output_b_cycle=-1;issue_count=0;
      source_empty_cycles=0;issue_stall_cycles=0;tile_busy_stall_cycles=0;
      pipeline_stall_cycles=0;result_credit_stall_cycles=0;
      trace_credit_stall_cycles=0;output_w_stall_cycles=0;
      clear_observed();
      run_segment_start=cycles;
      launch();
      check_header(1,1,2,0);
      if (descriptor_r_count!=32'(768+512*load_idx) ||
          activation_r_count!=32'(16*(load_idx+1)) ||
          out0_b_count!=32'(load_idx+1) || out1_b_count!=0 ||
          trace_b_count!=32'((load_idx+1)*(TRACE_ON ? 64 : 0)) ||
          out_writes!=1 || trace_writes!=(TRACE_ON ? 64 : 0) ||
          dot_checked!=8 || term_checked!=8 || commits!=8 || quant_checked!=8 ||
          weight_bytes_checked!=2048 || scale_values_checked!=64 ||
          bias_values_checked!=2 ||
          observed_words[7]!=32'(3+3*load_idx) ||
          observed_words[9]!=32'(3+3*load_idx) ||
          observed_words[12]!=2 || observed_words[29]!=32'(1+load_idx) ||
          observed_words[31]!=32'(1+load_idx) ||
          observed_words[48]!=32'(1+load_idx) ||
          observed_words[49]!=0)
        $fatal(1,"RUN%0d physical/numeric/owner scope",load_idx+1);
      for (int i=256;i<32768;i++) begin
        logic [31:0] expected;
        expected=32'hd15ea5ed;
        if (TRACE_ON && i>=256 && i<320) expected=a8q_gold[i-256];
        else if (TRACE_ON && i>=16640 && i<16644)
          expected=half_gold[i-16640];
        else if (TRACE_ON && i>=17664 && i<17728)
          expected=trace_gold[i-17664];
        if (observed_words[i]!==expected)
          $fatal(1,"observed BO/sentinel mismatch word=%0d",i);
      end
      $display("TM1TN8_SESSION_DMA_V2_ACT_RUN_PASS profile=%0d run=%0d load_cycles=%0d run_cycles=%0d scale_checks=%0d q_bytes=%0d scale_values=%0d bias_values=%0d quant_groups=%0d dot_groups=%0d term_groups=%0d ps_groups=%0d out_writes=%0d trace_writes=%0d",
               register_desc[64],load_idx+1,load_segment_end-load_segment_start,
               cycles-run_segment_start,register_desc[64]==0 ? 64 : 0,
               weight_bytes_checked,scale_values_checked,bias_values_checked,
               quant_checked,dot_checked,term_checked,commits,out_writes,trace_writes);
    end
    command_mode=REVOKE;
    clear_observed();
    launch();
    check_header(3,0,1,0);
    if (descriptor_r_count!=1536 || observed_words[40]!=6 ||
        observed_words[124]!=0 || observed_words[125]!=0)
      $fatal(1,"REVOKE must clear W and ACTIVE generation");
    // A previously legal LOAD cannot consume an epoch or model bytes after REVOKE.
    command_mode=LOAD1;
    clear_observed();
    launch();
    if (observed_words[3]!=7 || observed_words[123]!=0 ||
        observed_words[126]!=0 || observed_words[156]!=1 ||
        w_q0_r_count!=64 || w_scale_r_count!=4 ||
        aux_r_count!=100 || activation_r_count!=32)
      $fatal(1,"post-REVOKE stale LOAD was not rejected before model DMA");
    negative_count++;
    command_mode=RUN1;
    reject_without_task("post_revoke_run",1,7,1,2,0);
    reset_session();
    command_mode=LOAD1;
    reject_without_task("post_reset_old_load",1,7,1,2,0);
    register_fresh();
    command_mode=REGISTER;
    reject_without_task("active_repeat_register",1,7,7,2,1);
    for (int case_id=0;case_id<10;case_id++) begin
      int old_value;
      register_fresh();
      command_mode=LOAD1;
      case (case_id)
        0: begin old_value=load1_desc[0]; load1_desc[0]=32'h31533851; end
        1: begin old_value=load1_desc[3]; load1_desc[3]=32'h2; end
        2: begin old_value=load1_desc[64]; load1_desc[64]=1-old_value; end
        3: begin old_value=load1_desc[66]; load1_desc[66]=old_value+1; end
        4: begin old_value=load1_desc[68]; load1_desc[68]=old_value^32'h1; end
        5: begin old_value=load1_desc[32]; load1_desc[32]=old_value^32'h1; end
        6: begin old_value=load1_desc[88]; load1_desc[88]=old_value^32'h1; end
        7: begin old_value=load1_desc[124]; load1_desc[124]=old_value-1; end
        8: begin old_value=0; w_q0_base=Q0_BASE+4096; end
        9: begin old_value=0; model_bo_cookie[64 +: 64]=binding_words[8]+1; end
      endcase
      case (case_id)
        0: reject_without_task("old_magic",1,1,0,1,1);
        1: reject_without_task("reserved_flags",1,1,0,1,1);
        2: reject_without_task("wrong_profile",1,7,6,2,1);
        3: reject_without_task("wrong_generation",0,7,2,2,1);
        4: reject_without_task("wrong_context",0,7,3,2,1);
        5: reject_without_task("wrong_tag",1,2,0,1,1);
        6: reject_without_task("wrong_build_digest",1,2,5,1,1);
        7: reject_without_task("wrong_bo_allocation_size",0,2,5,1,1);
        8: reject_without_task("actual_bo_base_changed",0,7,4,2,2);
        9: reject_without_task("actual_bo_cookie_changed",0,7,4,2,2);
      endcase
      case (case_id)
        0: load1_desc[0]=old_value;
        1: load1_desc[3]=old_value;
        2: load1_desc[64]=old_value;
        3: load1_desc[66]=old_value;
        4: load1_desc[68]=old_value;
        5: load1_desc[32]=old_value;
        6: load1_desc[88]=old_value;
        7: load1_desc[124]=old_value;
        8: w_q0_base=Q0_BASE;
        9: model_bo_cookie[64 +: 64]=binding_words[8];
      endcase
      if (case_id<8) begin
        command_mode=LOAD1;
        clear_observed();
        launch();
        check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
        if (observed_words[8]!=1 || observed_words[9]!=1 ||
            observed_words[29]!=1 || observed_words[40]!=2 ||
            observed_words[44]!=1 || observed_words[48]!=1 ||
            observed_words[123]!=1 || observed_words[150]!=1 ||
            observed_words[152]!=1 || observed_words[155]!=0 ||
            w_q0_r_count!=32 || w_scale_r_count!=2 || aux_r_count!=66)
          $fatal(1,"descriptor-only rejection case=%0d did not permit legal LOAD retry",case_id);
        $display("TM1TN8_SESSION_DMA_V2_RECOVERY_PASS case=descriptor_only_%0d w_epoch=1",case_id);
      end else begin
        command_mode=LOAD1;
        reject_without_task("invalidated_slot_cannot_load",1,7,1,2,2);
      end
    end
    bad_header_register();
    if (register_desc[64]==0) begin
      logic [15:0] old_scale;
      register_fresh();
      old_scale=scale_words[0][32 +: 16];
      scale_words[0][32 +: 16]=16'h7c00;
      numeric_load_failure("strict_padded_scale",16,17);
      scale_words[0][32 +: 16]=old_scale;
      recover_failed_load("strict_padded_scale");
    end
    register_fresh();
    begin
      logic [31:0] old_bias;
      old_bias=bias_words[0];
      bias_words[0]=32'h7f800000;
      numeric_load_failure("bad_bias",0,register_desc[64]==0 ? 64 : 0);
      bias_words[0]=old_bias;
    end
    recover_failed_load("bad_bias");
    activation_failure_recovery();
    $display("TM1TN8_SESSION_DMA_V2_ACT_PASS profile=%0d register=1 loads=2 runs=2 revoke=1 reject=%0d",
             register_desc[64],negative_count);
    $finish;
  end
endmodule
