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
  integer total_cycles=0, command_cycles=0, reset_left=0, ptr_idx=0, cmd_idx=0;
  integer obs_file, out_file;
  logic running=0, seen_done=0, sampled_ap_done=0;
  logic r_hold_reg=0, b_hold_reg=0;
  logic [31:0] r_special_count=0, b_special_count=0;
  logic [31:0] before_r_special=0, before_b_special=0;
  logic [31:0] r_selected_index=0, b_selected_index=0;
  logic [31:0] r_selected_beat=0, r_hold_wait_latched=0, b_hold_wait_latched=0;
  logic [63:0] r_selected_addr=0, b_selected_addr=0, attout_last_aw_addr=0;
  logic r_selected_last=0;
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
    if (!resetn) begin
      sampled_ap_done <= 0;
      r_special_count <= 0;
      b_special_count <= 0;
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
      if (dut_aw_count[5]-before_aw[5] !== 32'd64 ||
          ram_w_count[5]-before_w[5] !== 32'd64 ||
          ram_b_count[5]-before_b[5] !== 32'd64 ||
          dut_write_bus_bytes[5]-before_write[5] !== 64'd256 ||
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
      if (r_special_count-before_r_special!=1 ||
          b_special_count-before_b_special!=1 ||
          r_selected_index==0 || b_selected_index==0 ||
          r_hold_wait_latched<16 || b_hold_wait_latched<16 ||
          !r_selected_last ||
          r_selected_addr<pointer_base[3] ||
          r_selected_addr>=pointer_base[3]+64'd12582912 ||
          b_selected_index!==32'd64 ||
          b_selected_addr!==pointer_base[5]+64'd252)
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
    if (command_index>=2) begin
      path=$sformatf("att_out_%0d.hex",command_index);
      out_file=$fopen(path,"w");
      if (out_file==0) $fatal(1,"ATT_COLD_DUMP_OPEN %s",path);
      for (int i=0;i<OUT_BYTES;i++) $fwrite(out_file,"%02x",u_port_att_out.u_mem.mem[i]);
      $fwrite(out_file,"\n"); $fclose(out_file);
    end
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
        if (!buses_drained())
          $fatal(1,"ATT_COLD_EARLY_DONE_DEBT cmd=%0d",cmd_idx);
        seen_done=1;
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
        end
        before_r_special=r_special_count; before_b_special=b_special_count;
        r_selected_index=0; b_selected_index=0;
        r_selected_beat=0; r_selected_addr=0; r_selected_last=0;
        b_selected_addr=0; r_hold_wait_latched=0; b_hold_wait_latched=0;
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
        if (lite_cmd_rdata_0[2:1] !== 2'b11)
          $fatal(1,"ATT_COLD_CSR_DONE_IDLE cmd=%0d csr=%h",cmd_idx,lite_cmd_rdata_0);
        if (!buses_drained()) $fatal(1,"ATT_COLD_CSR_DONE_DEBT cmd=%0d",cmd_idx);
        test_state<=CASE_CHECK;
      end
      CASE_CHECK: begin
        if (!buses_drained()) $fatal(1,"ATT_COLD_CHECK_WITH_AXI cmd=%0d",cmd_idx);
        check_status(cmd_idx);
        scan_input_and_outputs(cmd_idx);
        dump_bytes(cmd_idx);
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
