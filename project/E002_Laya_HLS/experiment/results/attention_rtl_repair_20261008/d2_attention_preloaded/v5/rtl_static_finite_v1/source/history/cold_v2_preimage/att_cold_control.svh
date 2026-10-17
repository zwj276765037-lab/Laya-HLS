  import "DPI-C" function void phase_probe_stage(input string label,
      input longint sim_time_ps, input longint clock_count,
      input longint value0, input longint value1);
  localparam int PAGE_BYTES=4096;
  localparam int QKV_BYTES=96*PAGE_BYTES;
  localparam int OUT_BYTES=64*PAGE_BYTES;
  localparam int RUN_CLOCK_LIMIT=2000000;
  localparam int OTHER_CLOCK_LIMIT=200000;
  localparam int TOTAL_CLOCK_LIMIT=2700000;
  logic [7:0] init_descriptor[0:PAGE_BYTES-1];
  logic [7:0] descriptor_run[0:PAGE_BYTES-1];
  logic [7:0] init_io[0:8*PAGE_BYTES-1];
  logic [7:0] init_aux[0:PAGE_BYTES-1];
  logic [7:0] init_qkv0[0:QKV_BYTES-1], init_qkv1[0:QKV_BYTES-1];
  logic [7:0] run_qkv0[0:QKV_BYTES-1], run_qkv1[0:QKV_BYTES-1];
  logic [7:0] init_att_out[0:OUT_BYTES-1];
  logic [7:0] init_observed[0:PAGE_BYTES-1];
  logic [7:0] saved_av[0:255];
  logic [63:0] pointer_base[0:6];
  logic [6:0] pointer_offset[0:6];
  logic [63:0] before_read[0:6], before_write[0:6], before_useful[0:6];
  logic [31:0] before_aw[0:6], before_w[0:6], before_ar[0:6], before_r[0:6], before_b[0:6];
  // Channel order: AR, R, RLAST, AW, W, B. Byte order: read bus, write bus, useful write.
  logic [31:0] before_dut_chan[0:6][0:5], before_ram_chan[0:6][0:5];
  logic [63:0] before_dut_bytes[0:6][0:2], before_ram_bytes[0:6][0:2];
  logic [31:0] before_accepted[0:6][0:4], before_delivered[0:6][0:4];
  integer total_cycles=0, command_cycles=0, reset_left=0, ptr_idx=0, cmd_idx=0;
  integer obs_file, out_file;
  logic running=0, seen_done=0, sampled_ap_done=0;
  integer case_start_cycle=0, case_done_cycle=0, case_csr_cycle=0;
  logic case_start_seen=0, case_done_seen=0;
  logic [31:0] case_csr_word=0;
  logic r_hold_reg=0, b_hold_reg=0;
  logic [31:0] r_special_count=0, b_special_count=0;
  logic [31:0] before_r_special=0, before_b_special=0;
  logic [31:0] r_selected_index=0, b_selected_index=0;
  logic [31:0] r_selected_beat=0, r_hold_wait_latched=0, b_hold_wait_latched=0;
  logic [63:0] r_selected_addr=0, b_selected_addr=0, attout_last_aw_addr=0;
  logic r_selected_last=0;
  localparam int OUT_SAMPLE=4;
  typedef struct packed {
    logic [31:0] ordinal;
    logic [63:0] addr;
    logic [7:0] len;
    logic [2:0] size;
  } out_aw_sample_t;
  typedef struct packed {
    logic [31:0] ordinal;
    logic [3:0] strb;
    logic last;
  } out_w_sample_t;
  typedef struct packed {
    logic [31:0] ordinal;
    logic [63:0] last_aw_addr;
  } out_b_sample_t;
  out_aw_sample_t out_aw_first[0:OUT_SAMPLE-1], out_aw_tail[0:OUT_SAMPLE-1];
  out_w_sample_t out_w_first[0:OUT_SAMPLE-1], out_w_tail[0:OUT_SAMPLE-1];
  out_b_sample_t out_b_first[0:OUT_SAMPLE-1], out_b_tail[0:OUT_SAMPLE-1];
  integer out_aw_seen=0, out_w_seen=0, out_b_seen=0;
  integer out_aw_shape_bad=0, out_w_shape_bad=0;
  typedef enum logic [4:0] {
    BOOT, COLD_RESET, PTR_ZERO, PTR_ZERO_WAIT, PTR_WRITE, PTR_WRITE_WAIT,
    PTR_READBACK, PTR_READBACK_WAIT, CMD_RESET_READ, CMD_RESET_WAIT,
    CASE_LOAD, COMMAND_WRITE, COMMAND_WRITE_WAIT, COMMAND_READBACK,
    COMMAND_READBACK_WAIT, CASE_START,
    CASE_START_WAIT, CASE_WAIT_DONE, CSR_READ, CSR_READ_WAIT, CASE_CHECK,
    FINISH
  } test_state_t;
  test_state_t test_state=BOOT;

  initial begin
    $readmemh("init_descriptor.memh",init_descriptor);
    $readmemh("descriptor_run.memh",descriptor_run);
    $readmemh("init_io.memh",init_io);
    $readmemh("init_aux.memh",init_aux);
    $readmemh("init_qkv0.memh",init_qkv0);
    $readmemh("init_qkv1.memh",init_qkv1);
    $readmemh("run_qkv0.memh",run_qkv0);
    $readmemh("run_qkv1.memh",run_qkv1);
    $readmemh("init_att_out.memh",init_att_out);
    $readmemh("init_observed.memh",init_observed);
    pointer_base[0]=64'h0000002000000000; pointer_offset[0]=7'h10;
    pointer_base[1]=64'h0000002100000000; pointer_offset[1]=7'h1c;
    pointer_base[2]=64'h0000002200000000; pointer_offset[2]=7'h28;
    pointer_base[3]=64'h0000002300000000; pointer_offset[3]=7'h34;
    pointer_base[4]=64'h0000002400000000; pointer_offset[4]=7'h40;
    pointer_base[5]=64'h0000002500000000; pointer_offset[5]=7'h4c;
    pointer_base[6]=64'h0000002600000000; pointer_offset[6]=7'h58;
    lite_cmd_valid_0=0; lite_cmd_valid_1=0;
    lite_cmd_write_0=0; lite_cmd_write_1=0;
    lite_cmd_addr_0=0; lite_cmd_addr_1=0;
    lite_cmd_wdata_0=0; lite_cmd_wdata_1=0;
  end
  for (genvar p=0;p<7;p++) begin : hold_controls
    if (p==3) assign hold_final_r[p]=r_hold_reg;
    else assign hold_final_r[p]=1'b0;
    if (p==5) assign hold_final_b[p]=b_hold_reg;
    else assign hold_final_b[p]=1'b0;
  end
  always @(posedge clk) begin
    out_aw_sample_t aw_event;
    out_w_sample_t w_event;
    out_b_sample_t b_event;
    if (!resetn) begin
      sampled_ap_done <= 0;
      r_special_count <= 0;
      b_special_count <= 0;
      out_aw_seen=0; out_w_seen=0; out_b_seen=0;
      out_aw_shape_bad=0; out_w_shape_bad=0;
    end else begin
      sampled_ap_done <= dut.ap_done;
      if (r_hold_applied[3]) begin
        if (r_special_wait_cycles[3]<16)
          $fatal(1,"ATT_COLD_R_HOLD_SHORT cycles=%0d",r_special_wait_cycles[3]);
        r_hold_wait_latched <= r_special_wait_cycles[3];
        r_special_count <= r_special_count+1;
      end
      if (b_hold_applied[5]) begin
        if (b_special_wait_cycles[5]<16)
          $fatal(1,"ATT_COLD_B_HOLD_SHORT cycles=%0d",b_special_wait_cycles[5]);
        b_hold_wait_latched <= b_special_wait_cycles[5];
        b_special_count <= b_special_count+1;
      end
      if (m_axi_att_out_AWVALID && m_axi_att_out_AWREADY)
        attout_last_aw_addr <= m_axi_att_out_AWADDR;
      if (running && m_axi_att_out_AWVALID && m_axi_att_out_AWREADY) begin
        out_aw_seen=out_aw_seen+1;
        aw_event.ordinal=32'(out_aw_seen);
        aw_event.addr=m_axi_att_out_AWADDR;
        aw_event.len=m_axi_att_out_AWLEN;
        aw_event.size=m_axi_att_out_AWSIZE;
        if (out_aw_seen<=OUT_SAMPLE) out_aw_first[out_aw_seen-1]=aw_event;
        out_aw_tail[(out_aw_seen-1)%OUT_SAMPLE]=aw_event;
        if (m_axi_att_out_AWLEN !== 8'd0 || m_axi_att_out_AWSIZE !== 3'd2 ||
            m_axi_att_out_AWADDR !== pointer_base[5]+64'(4*((out_aw_seen-1)/4)))
          out_aw_shape_bad=out_aw_shape_bad+1;
      end
      if (running && m_axi_att_out_WVALID && m_axi_att_out_WREADY) begin
        out_w_seen=out_w_seen+1;
        w_event.ordinal=32'(out_w_seen);
        w_event.strb=m_axi_att_out_WSTRB;
        w_event.last=m_axi_att_out_WLAST;
        if (out_w_seen<=OUT_SAMPLE) out_w_first[out_w_seen-1]=w_event;
        out_w_tail[(out_w_seen-1)%OUT_SAMPLE]=w_event;
        if (m_axi_att_out_WSTRB !== (4'b0001 << ((out_w_seen-1)%4)) ||
            m_axi_att_out_WLAST !== 1'b1)
          out_w_shape_bad=out_w_shape_bad+1;
      end
      if (running && m_axi_att_out_BVALID && m_axi_att_out_BREADY) begin
        out_b_seen=out_b_seen+1;
        b_event.ordinal=32'(out_b_seen);
        b_event.last_aw_addr=attout_last_aw_addr;
        if (out_b_seen<=OUT_SAMPLE) out_b_first[out_b_seen-1]=b_event;
        out_b_tail[(out_b_seen-1)%OUT_SAMPLE]=b_event;
      end
    end
  end
  function automatic logic [31:0] obs_word(input int word_index);
    int k;
    k=word_index*4;
    return {u_port_observed.u_mem.mem[k+3],u_port_observed.u_mem.mem[k+2],
            u_port_observed.u_mem.mem[k+1],u_port_observed.u_mem.mem[k]};
  endfunction
  function automatic bit buses_drained();
    for (int p=0;p<7;p++) begin
      if (dut_write_pending[p] !== 1'b0 || dut_read_pending[p] !== 1'b0 ||
          ram_write_pending[p] !== 1'b0 || ram_read_pending[p] !== 1'b0 ||
          dut_aw_count[p] !== dut_b_count[p] ||
          dut_ar_count[p] !== dut_rlast_count[p] ||
          ram_aw_count[p] !== ram_b_count[p] ||
          ram_ar_count[p] !== ram_rlast_count[p]) return 0;
      for (int c=0;c<5;c++)
        if (accepted[p][c] !== delivered[p][c]) return 0;
    end
    return 1;
  endfunction
  // A one bit means the original hold predicate is true or unknown. Case
  // comparison makes every logged failure bit itself known (0 or 1).
  function automatic logic [10:0] hold_failure_bits();
    logic [10:0] bad;
    bad[0]=(r_special_count-before_r_special !== 32'd1);
    bad[1]=(b_special_count-before_b_special !== 32'd1);
    bad[2]=((r_selected_index==32'd0) !== 1'b0) || $isunknown(r_selected_index);
    bad[3]=((b_selected_index==32'd0) !== 1'b0) || $isunknown(b_selected_index);
    bad[4]=((r_hold_wait_latched<32'd16) !== 1'b0) || $isunknown(r_hold_wait_latched);
    bad[5]=((b_hold_wait_latched<32'd16) !== 1'b0) || $isunknown(b_hold_wait_latched);
    bad[6]=(r_selected_last !== 1'b1);
    bad[7]=((r_selected_addr<pointer_base[3]) !== 1'b0) || $isunknown(r_selected_addr);
    bad[8]=((r_selected_addr>=pointer_base[3]+64'd12582912) !== 1'b0) || $isunknown(r_selected_addr);
    bad[9]=(b_selected_index !== 32'd256);
    bad[10]=(b_selected_addr !== pointer_base[5]+64'd252);
    return bad;
  endfunction
  task automatic print_out_samples(input int command_index);
    $display("ATT_COLD_OUT_SHAPE cmd=%0d aw=%0d w=%0d b=%0d aw_bad=%0d w_bad=%0d expected_awlen=0 expected_awsize=2 expected_wstrb=1_shift_byte_lane expected_aw_addr=base_plus_4_floor_i_over_4",
      command_index,out_aw_seen,out_w_seen,out_b_seen,out_aw_shape_bad,out_w_shape_bad);
    for (int i=0;i<OUT_SAMPLE && i<out_aw_seen;i++)
      $display("ATT_COLD_OUT_EVENT cmd=%0d channel=AW sample=first txn=%0d addr=%h awlen=%0d awsize=%0d",
        command_index,out_aw_first[i].ordinal,out_aw_first[i].addr,out_aw_first[i].len,out_aw_first[i].size);
    if (out_aw_seen>OUT_SAMPLE)
      for (int i=out_aw_seen-OUT_SAMPLE;i<out_aw_seen;i++)
        $display("ATT_COLD_OUT_EVENT cmd=%0d channel=AW sample=last txn=%0d addr=%h awlen=%0d awsize=%0d",
          command_index,out_aw_tail[i%OUT_SAMPLE].ordinal,out_aw_tail[i%OUT_SAMPLE].addr,
          out_aw_tail[i%OUT_SAMPLE].len,out_aw_tail[i%OUT_SAMPLE].size);
    for (int i=0;i<OUT_SAMPLE && i<out_w_seen;i++)
      $display("ATT_COLD_OUT_EVENT cmd=%0d channel=W sample=first txn=%0d wstrb=%h wlast=%0b",
        command_index,out_w_first[i].ordinal,out_w_first[i].strb,out_w_first[i].last);
    if (out_w_seen>OUT_SAMPLE)
      for (int i=out_w_seen-OUT_SAMPLE;i<out_w_seen;i++)
        $display("ATT_COLD_OUT_EVENT cmd=%0d channel=W sample=last txn=%0d wstrb=%h wlast=%0b",
          command_index,out_w_tail[i%OUT_SAMPLE].ordinal,out_w_tail[i%OUT_SAMPLE].strb,
          out_w_tail[i%OUT_SAMPLE].last);
    for (int i=0;i<OUT_SAMPLE && i<out_b_seen;i++)
      $display("ATT_COLD_OUT_EVENT cmd=%0d channel=B sample=first txn=%0d last_aw_addr=%h",
        command_index,out_b_first[i].ordinal,out_b_first[i].last_aw_addr);
    if (out_b_seen>OUT_SAMPLE)
      for (int i=out_b_seen-OUT_SAMPLE;i<out_b_seen;i++)
        $display("ATT_COLD_OUT_EVENT cmd=%0d channel=B sample=last txn=%0d last_aw_addr=%h",
          command_index,out_b_tail[i%OUT_SAMPLE].ordinal,out_b_tail[i%OUT_SAMPLE].last_aw_addr);
  endtask
  task automatic print_case_diagnostics(input int command_index);
    logic [10:0] bad;
    logic [31:0] chan[0:5], prior_chan[0:5];
    logic [63:0] bytes_now[0:2], bytes_before[0:2];
    string side_name;
    $display("ATT_COLD_CASE_SCOPE cmd=%0d command=%0d state=%0d running=%0b start_seen=%0b start_cycle=%0d done_seen=%0b done_cycle=%0d csr_cycle=%0d csr=%h command_cycles=%0d total_cycles=%0d seen_done=%0b sampled_ap_done=%0b live_ap_start=%0b live_ap_done=%0b live_ap_idle=%0b live_ap_ready=%0b",
      command_index,(command_index>=2),test_state,running,case_start_seen,
      case_start_cycle,case_done_seen,case_done_cycle,case_csr_cycle,
      case_csr_word,command_cycles,total_cycles,seen_done,sampled_ap_done,
      dut.ap_start,dut.ap_done,dut.ap_idle,dut.ap_ready);
    for (int p=0;p<7;p++) begin
      for (int side=0;side<2;side++) begin
        if (side==0) begin
          side_name="dut";
          chan[0]=dut_ar_count[p]; chan[1]=dut_r_count[p]; chan[2]=dut_rlast_count[p];
          chan[3]=dut_aw_count[p]; chan[4]=dut_w_count[p]; chan[5]=dut_b_count[p];
          bytes_now[0]=dut_read_bus_bytes[p]; bytes_now[1]=dut_write_bus_bytes[p];
          bytes_now[2]=dut_write_useful_bytes[p];
          for (int c=0;c<6;c++) prior_chan[c]=before_dut_chan[p][c];
          for (int c=0;c<3;c++) bytes_before[c]=before_dut_bytes[p][c];
        end else begin
          side_name="ram";
          chan[0]=ram_ar_count[p]; chan[1]=ram_r_count[p]; chan[2]=ram_rlast_count[p];
          chan[3]=ram_aw_count[p]; chan[4]=ram_w_count[p]; chan[5]=ram_b_count[p];
          bytes_now[0]=ram_read_bus_bytes[p]; bytes_now[1]=ram_write_bus_bytes[p];
          bytes_now[2]=ram_write_useful_bytes[p];
          for (int c=0;c<6;c++) prior_chan[c]=before_ram_chan[p][c];
          for (int c=0;c<3;c++) bytes_before[c]=before_ram_bytes[p][c];
        end
        $display("ATT_COLD_CASE_PORT cmd=%0d port=%0d side=%s scope=total ar=%0d r=%0d rlast=%0d aw=%0d w=%0d b=%0d read_bus=%0d write_bus=%0d write_useful=%0d",
          command_index,p,side_name,chan[0],chan[1],chan[2],chan[3],chan[4],chan[5],
          bytes_now[0],bytes_now[1],bytes_now[2]);
        $display("ATT_COLD_CASE_PORT cmd=%0d port=%0d side=%s scope=command ar=%0d r=%0d rlast=%0d aw=%0d w=%0d b=%0d read_bus=%0d write_bus=%0d write_useful=%0d",
          command_index,p,side_name,chan[0]-prior_chan[0],chan[1]-prior_chan[1],
          chan[2]-prior_chan[2],chan[3]-prior_chan[3],chan[4]-prior_chan[4],
          chan[5]-prior_chan[5],bytes_now[0]-bytes_before[0],
          bytes_now[1]-bytes_before[1],bytes_now[2]-bytes_before[2]);
      end
      $display("ATT_COLD_CASE_OUTSTANDING cmd=%0d port=%0d dut_wr_pending=%0b dut_rd_pending=%0b ram_wr_pending=%0b ram_rd_pending=%0b dut_aw_minus_b=%0d dut_ar_minus_rlast=%0d ram_aw_minus_b=%0d ram_ar_minus_rlast=%0d",
        command_index,p,dut_write_pending[p],dut_read_pending[p],
        ram_write_pending[p],ram_read_pending[p],
        dut_aw_count[p]-dut_b_count[p],dut_ar_count[p]-dut_rlast_count[p],
        ram_aw_count[p]-ram_b_count[p],ram_ar_count[p]-ram_rlast_count[p]);
      for (int c=0;c<5;c++) begin
        $display("ATT_COLD_CASE_ADAPTER cmd=%0d port=%0d channel=%0d total_accepted=%0d total_delivered=%0d total_debt=%0d command_accepted=%0d command_delivered=%0d command_debt=%0d",
          command_index,p,c,accepted[p][c],delivered[p][c],
          accepted[p][c]-delivered[p][c],accepted[p][c]-before_accepted[p][c],
          delivered[p][c]-before_delivered[p][c],
          (accepted[p][c]-before_accepted[p][c])-(delivered[p][c]-before_delivered[p][c]));
      end
    end
    bad=hold_failure_bits();
    $display("ATT_COLD_CASE_HOLD cmd=%0d r_count_before=%0d r_count_now=%0d r_count_delta=%0d r_index=%0d r_beat=%0d r_addr=%h r_last=%b r_wait_latched=%0d r_wait_live=%0d r_hold_reg=%b b_count_before=%0d b_count_now=%0d b_count_delta=%0d b_index=%0d b_addr=%h b_wait_latched=%0d b_wait_live=%0d b_hold_reg=%b last_aw=%h expected_last_b_index=256 expected_last_b_addr=%h",
      command_index,before_r_special,r_special_count,r_special_count-before_r_special,
      r_selected_index,r_selected_beat,r_selected_addr,r_selected_last,
      r_hold_wait_latched,r_special_wait_cycles[3],r_hold_reg,before_b_special,
      b_special_count,b_special_count-before_b_special,b_selected_index,
      b_selected_addr,b_hold_wait_latched,b_special_wait_cycles[5],
      b_hold_reg,attout_last_aw_addr,pointer_base[5]+64'd252);
    $display("ATT_COLD_CASE_HOLD_PRED cmd=%0d r_count_bad=%0b b_count_bad=%0b r_index_zero_or_unknown=%0b b_index_zero_or_unknown=%0b r_wait_short_or_unknown=%0b b_wait_short_or_unknown=%0b r_last_bad=%0b r_addr_low_or_unknown=%0b r_addr_high_or_unknown=%0b b_index_bad=%0b b_addr_bad=%0b any_bad=%0b",
      command_index,bad[0],bad[1],bad[2],bad[3],bad[4],bad[5],
      bad[6],bad[7],bad[8],bad[9],bad[10],(|bad));
    print_out_samples(command_index);
  endtask
  task automatic scan_input_and_outputs(input int command_index);
    logic [7:0] expected;
    logic [31:0] output_word;
    for (int i=0;i<PAGE_BYTES;i++) begin
      expected=(command_index<2) ? init_descriptor[i] : descriptor_run[i];
      if (u_port_descriptor.u_mem.mem[i] !== expected ||
          u_port_aux.u_mem.mem[i] !== init_aux[i])
        $fatal(1,"ATT_COLD_DESCRIPTOR_OR_AUX_CHANGED cmd=%0d byte=%0d",command_index,i);
    end
    for (int i=0;i<8*PAGE_BYTES;i++)
      if (u_port_io.u_mem.mem[i] !== init_io[i])
        $fatal(1,"ATT_COLD_IO_CHANGED cmd=%0d byte=%0d",command_index,i);
    for (int i=0;i<QKV_BYTES;i++) begin
      expected=(command_index<2) ? init_qkv0[i] : run_qkv0[i];
      if (u_port_qkv0.u_mem.mem[i] !== expected)
        $fatal(1,"ATT_COLD_QKV0_CHANGED cmd=%0d mapped_byte=%0d",command_index,i);
      expected=(command_index<2) ? init_qkv1[i] : run_qkv1[i];
      if (u_port_qkv1.u_mem.mem[i] !== expected)
        $fatal(1,"ATT_COLD_QKV1_CHANGED cmd=%0d mapped_byte=%0d",command_index,i);
    end
    for (int i=0;i<OUT_BYTES;i++) begin
      if (command_index<2 || i>=256) expected=8'ha5;
      else if (command_index==2) begin
        output_word=obs_word(144+i/4);
        expected=8'(output_word >> (8*(i%4)));
      end
      else expected=saved_av[i];
      if (u_port_att_out.u_mem.mem[i] !== expected)
        $fatal(1,"ATT_COLD_ATT_OUT_MISMATCH cmd=%0d byte=%0d",command_index,i);
      if (command_index==2 && i<256)
        saved_av[i]=u_port_att_out.u_mem.mem[i];
    end
    for (int i=1024;i<PAGE_BYTES;i++)
      if (u_port_observed.u_mem.mem[i] !== 8'ha5)
        $fatal(1,"ATT_COLD_OBSERVED_PAGE_TAIL cmd=%0d byte=%0d",command_index,i);
    for (int w=208;w<224;w++)
      if (obs_word(w) !== 32'hdeadbeef)
        $fatal(1,"ATT_COLD_OBSERVED_NUMERIC_TAIL cmd=%0d word=%0d",command_index,w);
    for (int w=238;w<256;w++)
      if (obs_word(w) !== 32'hdeadbeef)
        $fatal(1,"ATT_COLD_OBSERVED_RESERVED_TAIL cmd=%0d word=%0d",command_index,w);
    if (command_index!=2)
      for (int w=16;w<208;w++)
        if (obs_word(w) !== 32'hdeadbeef)
          $fatal(1,"ATT_COLD_UNEXPECTED_NUMERIC cmd=%0d word=%0d",command_index,w);
    if (command_index==2)
      for (int w=16;w<208;w++)
        if ($isunknown(obs_word(w)))
          $fatal(1,"ATT_COLD_UNKNOWN_NUMERIC word=%0d",w);
    for (int p=0;p<7;p++) begin
      if (dut_aw_count[p] !== ram_aw_count[p] ||
          dut_w_count[p] !== ram_w_count[p] ||
          dut_b_count[p] !== ram_b_count[p] ||
          dut_ar_count[p] !== ram_ar_count[p] ||
          dut_r_count[p] !== ram_r_count[p] ||
          dut_rlast_count[p] !== ram_rlast_count[p] ||
          dut_read_bus_bytes[p] !== ram_read_bus_bytes[p] ||
          dut_write_bus_bytes[p] !== ram_write_bus_bytes[p] ||
          dut_write_useful_bytes[p] !== ram_write_useful_bytes[p])
        $fatal(1,"ATT_COLD_ADAPTER_MISMATCH cmd=%0d port=%0d",command_index,p);
      if (p<=4 && dut_aw_count[p]!=before_aw[p])
        $fatal(1,"ATT_COLD_INPUT_WRITE cmd=%0d port=%0d",command_index,p);
      if (p==6 && dut_ar_count[p]!=before_ar[p])
        $fatal(1,"ATT_COLD_OUTPUT_READ cmd=%0d port=%0d",command_index,p);
      if (p==4 && (dut_ar_count[p]!=before_ar[p] ||
                   ram_r_count[p]!=before_r[p]))
        $fatal(1,"ATT_COLD_QKV1_TRANSACTION cmd=%0d ar=%0d r=%0d",
          command_index,dut_ar_count[p]-before_ar[p],ram_r_count[p]-before_r[p]);
    end
    if (command_index<2 || command_index==3)
      for (int p=3;p<=5;p++) begin
        if (p<=4 && dut_ar_count[p]!=before_ar[p])
          $fatal(1,"ATT_COLD_REJECT_QKV_READ cmd=%0d port=%0d",command_index,p);
        if (p==5 && dut_aw_count[p]!=before_aw[p])
          $fatal(1,"ATT_COLD_REJECT_OUTPUT_WRITE cmd=%0d",command_index);
        if (p==5 && dut_ar_count[p]!=before_ar[p])
          $fatal(1,"ATT_COLD_REJECT_OUTPUT_READ cmd=%0d",command_index);
      end
    if (command_index==2) begin
      if (out_aw_seen != 256 || out_w_seen != 256 || out_b_seen != 256 ||
          out_aw_shape_bad != 0 || out_w_shape_bad != 0)
        $fatal(1,"ATT_COLD_ATT_OUT_PHYSICAL_SHAPE aw=%0d w=%0d b=%0d aw_bad=%0d w_bad=%0d",
          out_aw_seen,out_w_seen,out_b_seen,out_aw_shape_bad,out_w_shape_bad);
      if (ram_r_count[3]-before_r[3] !== 32'd8256 ||
          dut_read_bus_bytes[3]-before_read[3] !== 64'd33024 ||
          dut_ar_count[3]-before_ar[3] !== 32'd8256)
        $fatal(1,"ATT_COLD_QKV0_READ_COVERAGE bus_bytes=%0d ar=%0d r=%0d",
          dut_read_bus_bytes[3]-before_read[3],
          dut_ar_count[3]-before_ar[3],ram_r_count[3]-before_r[3]);
      if (dut_read_bus_bytes[5]-before_read[5] !== 64'd256 ||
          dut_ar_count[5]-before_ar[5] !== 32'd64 ||
          ram_r_count[5]-before_r[5] !== 32'd64)
        $fatal(1,"ATT_COLD_ATT_OUT_READ_COVERAGE bus_bytes=%0d ar=%0d r=%0d",
          dut_read_bus_bytes[5]-before_read[5],
          dut_ar_count[5]-before_ar[5],ram_r_count[5]-before_r[5]);
      if (dut_aw_count[5]-before_aw[5] !== 32'd256 ||
          ram_w_count[5]-before_w[5] !== 32'd256 ||
          ram_b_count[5]-before_b[5] !== 32'd256 ||
          dut_write_bus_bytes[5]-before_write[5] !== 64'd1024 ||
          dut_write_useful_bytes[5]-before_useful[5] !== 64'd256)
        $fatal(1,"ATT_COLD_ATT_OUT_WRITE_COVERAGE aw=%0d w=%0d b=%0d bus=%0d useful=%0d",
          dut_aw_count[5]-before_aw[5],ram_w_count[5]-before_w[5],
          ram_b_count[5]-before_b[5],dut_write_bus_bytes[5]-before_write[5],
          dut_write_useful_bytes[5]-before_useful[5]);
      $display("ATT_COLD_QKV0_READ_COVERAGE bus_bytes=%0d ar=%0d r=%0d",
        dut_read_bus_bytes[3]-before_read[3],
        dut_ar_count[3]-before_ar[3],ram_r_count[3]-before_r[3]);
      $display("ATT_COLD_ATT_OUT_READ_COVERAGE bus_bytes=%0d ar=%0d r=%0d",
        dut_read_bus_bytes[5]-before_read[5],
        dut_ar_count[5]-before_ar[5],ram_r_count[5]-before_r[5]);
      $display("ATT_COLD_ATT_OUT_WRITE_COVERAGE aw=%0d w=%0d b=%0d bus=%0d useful=%0d",
        dut_aw_count[5]-before_aw[5],ram_w_count[5]-before_w[5],
        ram_b_count[5]-before_b[5],dut_write_bus_bytes[5]-before_write[5],
        dut_write_useful_bytes[5]-before_useful[5]);
    end
  endtask
  task automatic check_status(input int command_index);
    logic [31:0] expected[0:29];
    int word_index;
    // Slots 0..15 map observed[0..15], slots 16..29 map observed[224..237].
    // Every omitted assignment below is an exact expected zero.
    for (int i=0;i<30;i++) expected[i]=0;
    case (command_index)
      0: begin // accepted BEGIN: FILL pair, no task or cleanup
        expected[2]=1; expected[4]=1; expected[5]=1;
        expected[11]=2; expected[12]=5; expected[14]=5; expected[15]=1;
        expected[16]=1; expected[18]=301; expected[19]=1;
        expected[20]=1; expected[21]=1;
      end
      1: begin // pending BEGIN: report() retains the existing pair
        expected[0]=7; expected[1]=32'hd2000004;
        expected[2]=1; expected[4]=1; expected[5]=1;
        expected[11]=2; expected[12]=5; expected[14]=5; expected[15]=1;
        expected[16]=1; expected[18]=301; expected[19]=1;
        expected[20]=1; expected[21]=1;
      end
      2: begin // RUN: four tasks, six claims, READY pair; cleanup succeeds
        expected[2]=13; expected[3]=4; expected[4]=1; expected[5]=1;
        expected[6]=32768; expected[7]=5; expected[8]=32'h04080009;
        expected[9]=4; expected[11]=6;
        expected[12]=5; expected[14]=5; expected[15]=1;
        expected[16]=1; expected[18]=301; expected[19]=1;
        expected[20]=2; expected[21]=2; expected[22]=3072;
        expected[23]=1; expected[24]=1;
        expected[27]=64; expected[28]=64; expected[29]=64;
      end
      3: begin // replay: no pending pair, numeric elements and owner snapshots zero
        expected[0]=7; expected[1]=32'hd2010005;
        expected[2]=3; expected[3]=4; expected[9]=4; expected[11]=6;
        expected[16]=1; expected[18]=301; expected[19]=1;
        expected[22]=3072; expected[23]=1; expected[24]=1;
      end
      default: $fatal(1,"ATT_COLD_BAD_COMMAND_INDEX index=%0d",command_index);
    endcase
    for (int i=0;i<30;i++) begin
      word_index=(i<16) ? i : i+208;
      if (obs_word(word_index) !== expected[i])
        $fatal(1,"ATT_COLD_STATUS_WORD cmd=%0d word=%0d got=%h expected=%h",
          command_index,word_index,obs_word(word_index),expected[i]);
    end
    if (command_index==2) begin
      if (|hold_failure_bits())
        $fatal(1,"ATT_COLD_SPECIAL_HOLD_MISSING r=%0d b=%0d",r_special_count-before_r_special,b_special_count-before_b_special);
      $display("ATT_COLD_SPECIAL_HOLD r_index=%0d r_burst_beat=%0d r_addr=%h r_last=%0d r_wait=%0d b_index=%0d b_addr=%h b_wait=%0d",
        r_selected_index,r_selected_beat,r_selected_addr,r_selected_last,
        r_hold_wait_latched,b_selected_index,b_selected_addr,b_hold_wait_latched);
    end
  endtask
  task automatic dump_bytes(input int command_index);
    string path;
    path=$sformatf("observed_%0d.hex",command_index);
    obs_file=$fopen(path,"w");
    if (obs_file==0) $fatal(1,"ATT_COLD_DUMP_OPEN %s",path);
    for (int i=0;i<PAGE_BYTES;i++) $fwrite(obs_file,"%02x",u_port_observed.u_mem.mem[i]);
    $fwrite(obs_file,"\n"); $fclose(obs_file);
    path=$sformatf("att_out_%0d.hex",command_index);
    out_file=$fopen(path,"w");
    if (out_file==0) $fatal(1,"ATT_COLD_DUMP_OPEN %s",path);
    for (int i=0;i<OUT_BYTES;i++) $fwrite(out_file,"%02x",u_port_att_out.u_mem.mem[i]);
    $fwrite(out_file,"\n"); $fclose(out_file);
  endtask
  always @(negedge clk) begin : test_sequence
    logic [31:0] expected_pointer_word;
    string phase_hint;
    total_cycles=total_cycles+1;
    if ((total_cycles % 100000)==0) begin
      if (!running) phase_hint="setup_or_between_commands";
      else if (cmd_idx<2) phase_hint="begin_or_pending_rejection";
      else if (cmd_idx==3) phase_hint="replay_rejection";
      else if (ram_r_count[3]-before_r[3]<32'd8192)
        phase_hint="receipt_coverage_or_load_kv";
      else if (ram_r_count[3]-before_r[3]<32'd8256)
        phase_hint="qk_reads_or_later";
      else phase_hint="softmax_av_or_report";
      $display("ATT_COLD_PROGRESS cycle=%0d cmd=%0d cmd_cycle=%0d state=%0d phase_hint=%s done=%0d",
        total_cycles,cmd_idx,command_cycles,test_state,phase_hint,seen_done);
      for (int p=0;p<7;p++)
        $display("ATT_COLD_PROGRESS_PORT cycle=%0d port=%0d dut_ar=%0d dut_r=%0d dut_aw=%0d dut_b=%0d ram_ar=%0d ram_r=%0d ram_aw=%0d ram_b=%0d",
          total_cycles,p,dut_ar_count[p],dut_r_count[p],dut_aw_count[p],dut_b_count[p],
          ram_ar_count[p],ram_r_count[p],ram_aw_count[p],ram_b_count[p]);
      phase_probe_stage("att_cold_progress",longint'($realtime*1000.0),
        longint'(total_cycles),longint'(cmd_idx),longint'(command_cycles));
    end
    if (total_cycles>TOTAL_CLOCK_LIMIT)
      $fatal(1,"ATT_COLD_TOTAL_WATCHDOG cmd=%0d state=%0d",cmd_idx,test_state);
    if (!resetn) begin r_hold_reg<=0; b_hold_reg<=0; end
    else begin
      r_hold_reg <= cmd_idx==2 && running && r_special_count==before_r_special &&
                    u_port_qkv0.e_rvalid && u_port_qkv0.e_rlast;
      b_hold_reg <= cmd_idx==2 && running && b_special_count==before_b_special &&
                    dut_write_useful_bytes[5]-before_useful[5]==64'd256 &&
                    ram_aw_count[5]-ram_b_count[5]==1 && u_port_att_out.e_bvalid;
      if (cmd_idx==2 && running && r_special_count==before_r_special &&
          u_port_qkv0.e_rvalid && u_port_qkv0.e_rlast && r_selected_index==0)
        begin
          r_selected_index=ram_r_count[3]-before_r[3]+1;
          r_selected_beat=u_port_qkv0.ram_mon.ar_beat[u_port_qkv0.ram_mon.ar_head];
          r_selected_addr=u_port_qkv0.ram_mon.ar_address[u_port_qkv0.ram_mon.ar_head]+
              (64'(r_selected_beat) << u_port_qkv0.ram_mon.ar_size[u_port_qkv0.ram_mon.ar_head]);
          r_selected_last=u_port_qkv0.e_rlast;
        end
      if (cmd_idx==2 && running && b_special_count==before_b_special &&
          dut_write_useful_bytes[5]-before_useful[5]==64'd256 &&
          ram_aw_count[5]-ram_b_count[5]==1 && u_port_att_out.e_bvalid && b_selected_index==0)
        begin
          b_selected_index=ram_b_count[5]-before_b[5]+1;
          b_selected_addr=attout_last_aw_addr;
        end
    end
    if (running) begin
      command_cycles=command_cycles+1;
      if (command_cycles>(cmd_idx==2 ? RUN_CLOCK_LIMIT : OTHER_CLOCK_LIMIT))
        $fatal(1,"ATT_COLD_COMMAND_WATCHDOG cmd=%0d cycles=%0d state=%0d",cmd_idx,command_cycles,test_state);
      if ($isunknown(sampled_ap_done)) $fatal(1,"ATT_COLD_DONE_UNKNOWN cmd=%0d",cmd_idx);
      if (sampled_ap_done && !seen_done) begin
        if (!buses_drained()) begin
          dump_bytes(cmd_idx);
          print_case_diagnostics(cmd_idx);
          $fatal(1,"ATT_COLD_EARLY_DONE_DEBT cmd=%0d",cmd_idx);
        end
        seen_done=1;
        case_done_seen=1;
        case_done_cycle=total_cycles;
        $display("ATT_COLD_AP_DONE cmd=%0d cycle=%0d",cmd_idx,command_cycles);
      end
    end
    lite_cmd_valid_0<=0;
    lite_cmd_valid_1<=0;
    case (test_state)
      BOOT: begin
        for (int i=0;i<PAGE_BYTES;i++) begin
          u_port_descriptor.u_mem.mem[i]=init_descriptor[i];
          u_port_aux.u_mem.mem[i]=init_aux[i];
          u_port_observed.u_mem.mem[i]=init_observed[i];
        end
        for (int i=0;i<8*PAGE_BYTES;i++) u_port_io.u_mem.mem[i]=init_io[i];
        for (int i=0;i<QKV_BYTES;i++) begin
          u_port_qkv0.u_mem.mem[i]=init_qkv0[i];
          u_port_qkv1.u_mem.mem[i]=init_qkv1[i];
        end
        for (int i=0;i<OUT_BYTES;i++) u_port_att_out.u_mem.mem[i]=init_att_out[i];
        reset_left=5;
        $display("ATT_COLD_BOOT mapped_pages=267 qkv_initial=A5");
        test_state<=COLD_RESET;
      end
      COLD_RESET: begin
        if (reset_left==0) begin resetn<=1; ptr_idx=0; test_state<=PTR_ZERO; end
        else reset_left=reset_left-1;
      end
      PTR_ZERO: if (lite_cmd_ready_1) begin
        lite_cmd_write_1<=0;
        lite_cmd_addr_1<=pointer_offset[ptr_idx/2]+7'((ptr_idx%2)*4);
        lite_cmd_valid_1<=1;
        test_state<=PTR_ZERO_WAIT;
      end
      PTR_ZERO_WAIT: if (lite_cmd_done_1) begin
        if (lite_cmd_rdata_1 !== 0)
          $fatal(1,"ATT_COLD_POINTER_RESET idx=%0d got=%h",ptr_idx,lite_cmd_rdata_1);
        if (ptr_idx==13) begin ptr_idx=0; test_state<=PTR_WRITE; end
        else begin ptr_idx=ptr_idx+1; test_state<=PTR_ZERO; end
      end
      PTR_WRITE: if (lite_cmd_ready_1) begin
        expected_pointer_word=(ptr_idx%2)==0 ? pointer_base[ptr_idx/2][31:0] : pointer_base[ptr_idx/2][63:32];
        lite_cmd_write_1<=1;
        lite_cmd_addr_1<=pointer_offset[ptr_idx/2]+7'((ptr_idx%2)*4);
        lite_cmd_wdata_1<=expected_pointer_word;
        lite_cmd_valid_1<=1;
        test_state<=PTR_WRITE_WAIT;
      end
      PTR_WRITE_WAIT: if (lite_cmd_done_1) begin
        if (ptr_idx==13) begin ptr_idx=0; test_state<=PTR_READBACK; end
        else begin ptr_idx=ptr_idx+1; test_state<=PTR_WRITE; end
      end
      PTR_READBACK: if (lite_cmd_ready_1) begin
        lite_cmd_write_1<=0;
        lite_cmd_addr_1<=pointer_offset[ptr_idx/2]+7'((ptr_idx%2)*4);
        lite_cmd_valid_1<=1;
        test_state<=PTR_READBACK_WAIT;
      end
      PTR_READBACK_WAIT: if (lite_cmd_done_1) begin
        expected_pointer_word=(ptr_idx%2)==0 ? pointer_base[ptr_idx/2][31:0] : pointer_base[ptr_idx/2][63:32];
        if (lite_cmd_rdata_1 !== expected_pointer_word)
          $fatal(1,"ATT_COLD_POINTER_READBACK idx=%0d got=%h expected=%h",ptr_idx,lite_cmd_rdata_1,expected_pointer_word);
        if (ptr_idx==13) test_state<=CMD_RESET_READ;
        else begin ptr_idx=ptr_idx+1; test_state<=PTR_READBACK; end
      end
      CMD_RESET_READ: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=0; lite_cmd_addr_0<=5'h10; lite_cmd_valid_0<=1;
        test_state<=CMD_RESET_WAIT;
      end
      CMD_RESET_WAIT: if (lite_cmd_done_0) begin
        if (lite_cmd_rdata_0!==0) $fatal(1,"ATT_COLD_COMMAND_RESET got=%h",lite_cmd_rdata_0);
        $display("ATT_COLD_POINTERS_READY seven_64bit=7");
        test_state<=CASE_LOAD;
      end
      CASE_LOAD: begin
        if (!buses_drained()) $fatal(1,"ATT_COLD_MUTATE_WITH_AXI cmd=%0d",cmd_idx);
        for (int i=0;i<PAGE_BYTES;i++) begin
          u_port_descriptor.u_mem.mem[i]=(cmd_idx<2) ? init_descriptor[i] : descriptor_run[i];
          u_port_observed.u_mem.mem[i]=init_observed[i];
        end
        if (cmd_idx==2) begin
          for (int i=0;i<QKV_BYTES;i++) begin
            if (u_port_qkv0.u_mem.mem[i] !== 8'ha5 ||
                u_port_qkv1.u_mem.mem[i] !== 8'ha5)
              $fatal(1,"ATT_COLD_PRE_RUN_QKV_NOT_A5 mapped_byte=%0d",i);
            u_port_qkv0.u_mem.mem[i]=run_qkv0[i];
            u_port_qkv1.u_mem.mem[i]=run_qkv1[i];
          end
          $display("ATT_COLD_HOST_FILL mapped_qkv_pages=192 verified_full_host_before_materialization=25165824");
        end
        for (int p=0;p<7;p++) begin
          before_read[p]=dut_read_bus_bytes[p]; before_write[p]=dut_write_bus_bytes[p];
          before_useful[p]=dut_write_useful_bytes[p];
          before_aw[p]=dut_aw_count[p]; before_w[p]=ram_w_count[p];
          before_ar[p]=dut_ar_count[p];
          before_r[p]=ram_r_count[p]; before_b[p]=ram_b_count[p];
          before_dut_chan[p][0]=dut_ar_count[p];
          before_dut_chan[p][1]=dut_r_count[p];
          before_dut_chan[p][2]=dut_rlast_count[p];
          before_dut_chan[p][3]=dut_aw_count[p];
          before_dut_chan[p][4]=dut_w_count[p];
          before_dut_chan[p][5]=dut_b_count[p];
          before_ram_chan[p][0]=ram_ar_count[p];
          before_ram_chan[p][1]=ram_r_count[p];
          before_ram_chan[p][2]=ram_rlast_count[p];
          before_ram_chan[p][3]=ram_aw_count[p];
          before_ram_chan[p][4]=ram_w_count[p];
          before_ram_chan[p][5]=ram_b_count[p];
          before_dut_bytes[p][0]=dut_read_bus_bytes[p];
          before_dut_bytes[p][1]=dut_write_bus_bytes[p];
          before_dut_bytes[p][2]=dut_write_useful_bytes[p];
          before_ram_bytes[p][0]=ram_read_bus_bytes[p];
          before_ram_bytes[p][1]=ram_write_bus_bytes[p];
          before_ram_bytes[p][2]=ram_write_useful_bytes[p];
          for (int c=0;c<5;c++) begin
            before_accepted[p][c]=accepted[p][c];
            before_delivered[p][c]=delivered[p][c];
          end
        end
        before_r_special=r_special_count; before_b_special=b_special_count;
        r_selected_index=0; b_selected_index=0;
        r_selected_beat=0; r_selected_addr=0; r_selected_last=0;
        b_selected_addr=0; r_hold_wait_latched=0; b_hold_wait_latched=0;
        out_aw_seen=0; out_w_seen=0; out_b_seen=0;
        out_aw_shape_bad=0; out_w_shape_bad=0;
        case_start_seen=0; case_done_seen=0;
        case_start_cycle=0; case_done_cycle=0; case_csr_cycle=0;
        case_csr_word=0;
        command_cycles=0;
        test_state<=COMMAND_WRITE;
      end
      COMMAND_WRITE: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=1; lite_cmd_addr_0<=5'h10;
        lite_cmd_wdata_0<=cmd_idx>=2 ? 32'd1 : 32'd0;
        lite_cmd_valid_0<=1;
        test_state<=COMMAND_WRITE_WAIT;
      end
      COMMAND_WRITE_WAIT: if (lite_cmd_done_0) test_state<=COMMAND_READBACK;
      COMMAND_READBACK: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=0; lite_cmd_addr_0<=5'h10; lite_cmd_valid_0<=1;
        test_state<=COMMAND_READBACK_WAIT;
      end
      COMMAND_READBACK_WAIT: if (lite_cmd_done_0) begin
        if (lite_cmd_rdata_0 !== (cmd_idx>=2 ? 32'd1 : 32'd0))
          $fatal(1,"ATT_COLD_COMMAND_READBACK cmd=%0d got=%h",cmd_idx,lite_cmd_rdata_0);
        test_state<=CASE_START;
      end
      CASE_START: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=1; lite_cmd_addr_0<=5'h00; lite_cmd_wdata_0<=1;
        lite_cmd_valid_0<=1;
        running=1; seen_done=0;
        case_start_seen=1; case_start_cycle=total_cycles;
        $display("ATT_COLD_START cmd=%0d command=%0d",cmd_idx,cmd_idx>=2);
        test_state<=CASE_START_WAIT;
      end
      CASE_START_WAIT: if (lite_cmd_done_0) test_state<=CASE_WAIT_DONE;
      CASE_WAIT_DONE: if (seen_done) test_state<=CSR_READ;
      CSR_READ: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=0; lite_cmd_addr_0<=5'h00; lite_cmd_valid_0<=1;
        test_state<=CSR_READ_WAIT;
      end
      CSR_READ_WAIT: if (lite_cmd_done_0) begin
        case_csr_word=lite_cmd_rdata_0;
        case_csr_cycle=total_cycles;
        if (lite_cmd_rdata_0[2:1] !== 2'b11 || !buses_drained()) begin
          dump_bytes(cmd_idx);
          print_case_diagnostics(cmd_idx);
        end
        if (lite_cmd_rdata_0[2:1] !== 2'b11)
          $fatal(1,"ATT_COLD_CSR_DONE_IDLE cmd=%0d csr=%h",cmd_idx,lite_cmd_rdata_0);
        if (!buses_drained()) $fatal(1,"ATT_COLD_CSR_DONE_DEBT cmd=%0d",cmd_idx);
        test_state<=CASE_CHECK;
      end
      CASE_CHECK: begin
        dump_bytes(cmd_idx);
        print_case_diagnostics(cmd_idx);
        if (!buses_drained()) $fatal(1,"ATT_COLD_CHECK_WITH_AXI cmd=%0d",cmd_idx);
        check_status(cmd_idx);
        scan_input_and_outputs(cmd_idx);
        $display("ATT_COLD_COMMAND_PASS cmd=%0d cycles=%0d",cmd_idx,command_cycles);
        running=0;
        if (cmd_idx==3) test_state<=FINISH;
        else begin cmd_idx=cmd_idx+1; test_state<=CASE_LOAD; end
      end
      FINISH: begin
        $display("ATT_COLD_STATIC_BASE_H0_R0_PASS commands=4");
        $finish;
      end
      default: $fatal(1,"ATT_COLD_BAD_TEST_STATE state=%0d",test_state);
    endcase
  end
