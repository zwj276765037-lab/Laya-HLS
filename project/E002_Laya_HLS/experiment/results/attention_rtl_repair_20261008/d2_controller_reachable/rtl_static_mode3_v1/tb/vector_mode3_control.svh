  // One cold production Controller mode3 request. All AXI protocol checking
  // is performed by the immutable bounded endpoint's two passive monitors.
  localparam int PAGE_BYTES = 4096;
  localparam logic [63:0] STATE1_RAW = 64'h00000035010229c0;
  localparam logic [63:0] STATE1_MASKED = 64'h0000003501022840;
  logic [7:0] init_src0_input[0:PAGE_BYTES-1];
  logic [7:0] init_src1_input[0:PAGE_BYTES-1];
  logic [7:0] init_io[0:8*PAGE_BYTES-1];
  logic [7:0] init_aux[0:PAGE_BYTES-1];
  logic [7:0] init_state0[0:PAGE_BYTES-1];
  logic [7:0] init_state1[0:PAGE_BYTES-1];
  logic [7:0] init_observed[0:PAGE_BYTES-1];
  logic [7:0] expected_state1[0:PAGE_BYTES-1];
  logic [7:0] expected_observed[0:PAGE_BYTES-1];
  logic [63:0] pointer_base[0:6];
  logic [6:0] pointer_offset[0:6];
  integer total_cycles=0, accepted_cycle=0, done_cycle=0;
  integer dut_limit=0, total_limit=0;
  bit images_loaded=0, start_seen=0, done_seen=0;
  bit raw_final_aw=0, raw_final_w=0;
  logic [63:0] final_aw_addr=0;
  logic [7:0] final_aw_len=0;
  logic [2:0] final_aw_size=0;
  logic [3:0] final_w_strb=0;
  logic final_w_last=0;
  integer r_special_count=0, b_special_count=0;
  integer r_hold_cycles=0, b_hold_cycles=0;

  // The sample is the value presented to the receiver on this positive edge.
  // Queue assertions below wait one precision step for the passive monitors
  // to account for those same physical handshakes.
  clocking mode3_cb @(posedge clk);
    default input #1step;
    input ap_start = dut.ap_start;
    input ap_done = dut.ap_done;
    input ap_ready = dut.ap_ready;
    input state1 = dut.ap_CS_fsm_state1;
    input state_awvalid = u_port_state1.e_awvalid;
    input state_awready = u_port_state1.e_awready;
    input state_awaddr = u_port_state1.e_awaddr;
    input state_awlen = u_port_state1.e_awlen;
    input state_awsize = u_port_state1.e_awsize;
    input state_wvalid = u_port_state1.e_wvalid;
    input state_wready = u_port_state1.e_wready;
    input state_wstrb = u_port_state1.e_wstrb;
    input state_wlast = u_port_state1.e_wlast;
    input state_aw_count = ram_aw_count[5];
    input state_w_count = ram_w_count[5];
    input final_r_handshake = r_hold_applied[5];
    input final_b_handshake = b_hold_applied[5];
    input final_r_wait = r_special_wait_cycles[5];
    input final_b_wait = b_special_wait_cycles[5];
  endclocking

  initial begin
    pointer_base[0]=64'h0000003000000000; pointer_offset[0]=7'h10;
    pointer_base[1]=64'h0000003100000000; pointer_offset[1]=7'h1c;
    pointer_base[2]=64'h0000003200000000; pointer_offset[2]=7'h28;
    pointer_base[3]=64'h0000003300000000; pointer_offset[3]=7'h34;
    pointer_base[4]=64'h0000003400000000; pointer_offset[4]=7'h40;
    pointer_base[5]=64'h0000003500000000; pointer_offset[5]=7'h4c;
    pointer_base[6]=64'h0000003600000000; pointer_offset[6]=7'h58;
    lite_cmd_valid_0=0; lite_cmd_valid_1=0;
    lite_cmd_write_0=0; lite_cmd_write_1=0;
    lite_cmd_addr_0=0; lite_cmd_addr_1=0;
    lite_cmd_wdata_0=0; lite_cmd_wdata_1=0;
    $readmemh("init_src0_input.memh",init_src0_input);
    $readmemh("init_src1_input.memh",init_src1_input);
    $readmemh("init_io.memh",init_io);
    $readmemh("init_aux.memh",init_aux);
    $readmemh("init_state0.memh",init_state0);
    $readmemh("init_state1.memh",init_state1);
    $readmemh("init_observed.memh",init_observed);
    $readmemh("expected_state1.memh",expected_state1);
    $readmemh("expected_observed.memh",expected_observed);
    if (!$value$plusargs("MODE3_DUT_LIMIT=%d",dut_limit) ||
        !$value$plusargs("MODE3_TOTAL_LIMIT=%d",total_limit) ||
        dut_limit<1 || total_limit<dut_limit)
      $fatal(1,"D2_MODE3_LIMIT_ARGUMENTS");
  end

  // The final selected raw word is AR16 (LEN0/SIZE2), byte offsets 60..63.
  // The final masked write is physical AW/W128, byte63 with one-hot strobe 8.
  // No response VALID is retracted: the accepted delay stage withholds its
  // first presentation for >=16 cycles, then holds it stable until handshake.
  for (genvar p=0;p<7;p++) begin : selected_hold
    if (p==5) begin
      assign hold_final_r[p] = resetn && u_port_state1.e_rvalid &&
          ram_ar_count[5]==32'd16 && ram_r_count[5]==32'd15 &&
          u_port_state1.ram_mon.ar_used>0 &&
          u_port_state1.ram_mon.ar_address[u_port_state1.ram_mon.ar_head]==STATE1_RAW+64'd60 &&
          u_port_state1.ram_mon.ar_length[u_port_state1.ram_mon.ar_head]==8'd0 &&
          u_port_state1.ram_mon.ar_size[u_port_state1.ram_mon.ar_head]==3'd2;
      assign hold_final_b[p] = resetn && u_port_state1.e_bvalid &&
          ram_aw_count[5]==32'd128 && ram_w_count[5]==32'd128 &&
          ram_b_count[5]==32'd127 && raw_final_aw && raw_final_w;
    end else begin
      assign hold_final_r[p]=1'b0;
      assign hold_final_b[p]=1'b0;
    end
  end

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

  task automatic dump_outputs();
    integer f;
    f=$fopen("state1_raw.hex","w");
    if (f==0) $fatal(1,"D2_MODE3_DUMP_OPEN state1_raw.hex");
    for (int i=0;i<PAGE_BYTES;i++)
      $fwrite(f,"%02x",u_port_state1.u_mem.mem[i]);
    $fwrite(f,"\n"); $fclose(f);
    f=$fopen("observed_raw.hex","w");
    if (f==0) $fatal(1,"D2_MODE3_DUMP_OPEN observed_raw.hex");
    for (int i=0;i<PAGE_BYTES;i++)
      $fwrite(f,"%02x",u_port_observed.u_mem.mem[i]);
    $fwrite(f,"\n"); $fclose(f);
  endtask

  task automatic print_port_summary();
    for (int p=0;p<7;p++) begin
      $display("D2_MODE3_PORT port=%0d side=dut ar=%0d r=%0d rlast=%0d aw=%0d w=%0d b=%0d read_bus=%0d write_bus=%0d write_useful=%0d wr_pending=%b rd_pending=%b",
        p,dut_ar_count[p],dut_r_count[p],dut_rlast_count[p],dut_aw_count[p],
        dut_w_count[p],dut_b_count[p],dut_read_bus_bytes[p],
        dut_write_bus_bytes[p],dut_write_useful_bytes[p],
        dut_write_pending[p],dut_read_pending[p]);
      $display("D2_MODE3_PORT port=%0d side=ram ar=%0d r=%0d rlast=%0d aw=%0d w=%0d b=%0d read_bus=%0d write_bus=%0d write_useful=%0d wr_pending=%b rd_pending=%b",
        p,ram_ar_count[p],ram_r_count[p],ram_rlast_count[p],ram_aw_count[p],
        ram_w_count[p],ram_b_count[p],ram_read_bus_bytes[p],
        ram_write_bus_bytes[p],ram_write_useful_bytes[p],
        ram_write_pending[p],ram_read_pending[p]);
      for (int c=0;c<5;c++)
        $display("D2_MODE3_ADAPTER port=%0d channel=%0d accepted=%0d delivered=%0d debt=%0d",
          p,c,accepted[p][c],delivered[p][c],accepted[p][c]-delivered[p][c]);
    end
    $display("D2_MODE3_HOLDS raw_r_count=%0d raw_r_cycles=%0d masked_b_count=%0d masked_b_cycles=%0d final_aw=%h len=%0d size=%0d final_w_strb=%h final_w_last=%b",
      r_special_count,r_hold_cycles,b_special_count,b_hold_cycles,
      final_aw_addr,final_aw_len,final_aw_size,final_w_strb,final_w_last);
  endtask

  task automatic scan_pages();
    for (int i=0;i<PAGE_BYTES;i++) begin
      if (u_port_src0_input.u_mem.mem[i] !== init_src0_input[i])
        $fatal(1,"D2_MODE3_SOURCE0_MISMATCH byte=%0d",i);
      if (u_port_src1_input.u_mem.mem[i] !== init_src1_input[i])
        $fatal(1,"D2_MODE3_SOURCE1_MISMATCH byte=%0d",i);
      if (u_port_aux.u_mem.mem[i] !== init_aux[i])
        $fatal(1,"D2_MODE3_AUX_MISMATCH byte=%0d",i);
      if (u_port_state0.u_mem.mem[i] !== init_state0[i])
        $fatal(1,"D2_MODE3_STATE0_MISMATCH byte=%0d",i);
      if (u_port_state1.u_mem.mem[i] !== expected_state1[i])
        $fatal(1,"D2_MODE3_STATE1_MISMATCH byte=%0d",i);
      if (u_port_observed.u_mem.mem[i] !== expected_observed[i])
        $fatal(1,"D2_MODE3_OBSERVED_MISMATCH byte=%0d",i);
    end
    for (int i=0;i<8*PAGE_BYTES;i++)
      if (u_port_io.u_mem.mem[i] !== init_io[i])
        $fatal(1,"D2_MODE3_IO_MISMATCH byte=%0d",i);
  endtask

  // Read and write transactions use the accepted two-bank AXI-Lite master.
  // Commands are driven after a positive edge, so the master takes them on
  // the next negative edge without a testbench/master scheduling race.
  task automatic lite_command(input int bank, input bit write_en,
                              input logic [6:0] addr,
                              input logic [31:0] value,
                              output logic [31:0] result);
    int age;
    age=0;
    while (!(bank==0 ? lite_cmd_ready_0 : lite_cmd_ready_1)) begin
      @(posedge clk); #1ps;
      if (++age>256) $fatal(1,"D2_MODE3_LITE_READY_TIMEOUT bank=%0d",bank);
    end
    if (bank==0) begin
      lite_cmd_write_0=write_en; lite_cmd_addr_0=addr[4:0];
      lite_cmd_wdata_0=value; lite_cmd_valid_0=1;
    end else begin
      lite_cmd_write_1=write_en; lite_cmd_addr_1=addr;
      lite_cmd_wdata_1=value; lite_cmd_valid_1=1;
    end
    @(posedge clk); #1ps;
    if (bank==0) lite_cmd_valid_0=0;
    else lite_cmd_valid_1=0;
    age=0;
    while (!(bank==0 ? lite_cmd_done_0 : lite_cmd_done_1)) begin
      @(posedge clk); #1ps;
      if (++age>256) $fatal(1,"D2_MODE3_LITE_DONE_TIMEOUT bank=%0d",bank);
    end
    result=bank==0 ? lite_cmd_rdata_0 : lite_cmd_rdata_1;
    @(posedge clk); #1ps;
  endtask

  always @(mode3_cb) begin : edge_observe
    bit take_start, take_done;
    take_start=resetn && mode3_cb.ap_start && mode3_cb.state1;
    take_done=resetn && mode3_cb.ap_done;
    if (resetn) begin
      total_cycles=total_cycles+1;
      if (take_start) begin
        if (start_seen || done_seen)
          $fatal(1,"D2_MODE3_MULTIPLE_AP_ACCEPT");
        start_seen=1;
        accepted_cycle=total_cycles;
        $display("D2_MODE3_AP_ACCEPT cycle=%0d state1=1",accepted_cycle);
      end
      if (mode3_cb.state_awvalid && mode3_cb.state_awready &&
          mode3_cb.state_aw_count==32'd127) begin
        final_aw_addr=mode3_cb.state_awaddr;
        final_aw_len=mode3_cb.state_awlen;
        final_aw_size=mode3_cb.state_awsize;
        raw_final_aw=(final_aw_addr==STATE1_MASKED+64'd60 &&
                      final_aw_len==0 && final_aw_size==2);
      end
      if (mode3_cb.state_wvalid && mode3_cb.state_wready &&
          mode3_cb.state_w_count==32'd127) begin
        final_w_strb=mode3_cb.state_wstrb;
        final_w_last=mode3_cb.state_wlast;
        raw_final_w=(final_w_strb==4'h8 && final_w_last);
      end
      if (mode3_cb.final_r_handshake) begin
        r_special_count++;
        r_hold_cycles=mode3_cb.final_r_wait;
      end
      if (mode3_cb.final_b_handshake) begin
        b_special_count++;
        b_hold_cycles=mode3_cb.final_b_wait;
      end
      #1ps;
      if (take_done && !done_seen) begin
        if (!images_loaded || !start_seen) begin
          dump_outputs();
          $fatal(1,"D2_MODE3_DONE_WITHOUT_START");
        end
        done_seen=1;
        done_cycle=total_cycles;
        // Save the unmodified endpoint bytes before any completion assertion.
        dump_outputs();
        print_port_summary();
        $display("D2_MODE3_FIRST_DONE accepted_to_done=%0d total_cycle=%0d ap_ready=%b physical_and_adapter_drained=%b",
          done_cycle-accepted_cycle,done_cycle,mode3_cb.ap_ready,buses_drained());
        if (!buses_drained()) $fatal(1,"D2_MODE3_FIRST_DONE_DEBT");
        if (mode3_cb.ap_ready !== 1'b1)
          $fatal(1,"D2_MODE3_FIRST_DONE_NOT_TERMINAL_READY");
      end
      if (start_seen && !done_seen && total_cycles-accepted_cycle>dut_limit) begin
        if (images_loaded) dump_outputs();
        print_port_summary();
        $fatal(1,"D2_MODE3_DUT_WATCHDOG cycles=%0d limit=%0d",
          total_cycles-accepted_cycle,dut_limit);
      end
      if (total_cycles>total_limit) begin
        if (images_loaded) dump_outputs();
        print_port_summary();
        $fatal(1,"D2_MODE3_TOTAL_WATCHDOG cycles=%0d limit=%0d",total_cycles,total_limit);
      end
      if (start_seen && !done_seen && total_cycles%4096==0)
        $display("D2_MODE3_PROGRESS total=%0d dut=%0d io_ar=%0d state1_aw=%0d state1_r=%0d observed_b=%0d",
          total_cycles,total_cycles-accepted_cycle,dut_ar_count[2],
          dut_aw_count[5],dut_r_count[5],dut_b_count[6]);
    end
  end

  initial begin : one_cold_request
    logic [31:0] value;
    logic [31:0] expected_word;
    repeat (4) @(posedge clk);
    #1ps;
    for (int i=0;i<PAGE_BYTES;i++) begin
      u_port_src0_input.u_mem.mem[i]=init_src0_input[i];
      u_port_src1_input.u_mem.mem[i]=init_src1_input[i];
      u_port_aux.u_mem.mem[i]=init_aux[i];
      u_port_state0.u_mem.mem[i]=init_state0[i];
      u_port_state1.u_mem.mem[i]=init_state1[i];
      u_port_observed.u_mem.mem[i]=init_observed[i];
    end
    for (int i=0;i<8*PAGE_BYTES;i++)
      u_port_io.u_mem.mem[i]=init_io[i];
    images_loaded=1;
    repeat (5) @(posedge clk);
    #1ps; resetn=1;
    lite_command(0,0,7'h10,0,value);
    if (value !== 0) $fatal(1,"D2_MODE3_MODE_RESET got=%h",value);
    lite_command(0,0,7'h00,0,value);
    if (value[7:0] !== 8'h04)
      $fatal(1,"D2_MODE3_CONTROL_RESET got=%h",value);
    for (int i=0;i<7;i++) begin
      lite_command(1,0,pointer_offset[i],0,value);
      if (value !== 0) $fatal(1,"D2_MODE3_POINTER_RESET port=%0d lo=%h",i,value);
      lite_command(1,0,pointer_offset[i]+7'd4,0,value);
      if (value !== 0) $fatal(1,"D2_MODE3_POINTER_RESET port=%0d hi=%h",i,value);
    end
    lite_command(0,1,7'h10,32'd3,value);
    lite_command(0,0,7'h10,0,value);
    if (value !== 32'd3)
      $fatal(1,"D2_MODE3_MODE_READBACK got=%h",value);
    for (int i=0;i<7;i++) begin
      lite_command(1,1,pointer_offset[i],pointer_base[i][31:0],value);
      lite_command(1,1,pointer_offset[i]+7'd4,pointer_base[i][63:32],value);
      lite_command(1,0,pointer_offset[i],0,value);
      if (value !== pointer_base[i][31:0])
        $fatal(1,"D2_MODE3_POINTER_READBACK port=%0d lo=%h",i,value);
      lite_command(1,0,pointer_offset[i]+7'd4,0,value);
      if (value !== pointer_base[i][63:32])
        $fatal(1,"D2_MODE3_POINTER_READBACK port=%0d hi=%h",i,value);
    end
    $display("D2_MODE3_POINTERS_READY seven_64bit=7 mode=3");
    if (!buses_drained()) $fatal(1,"D2_MODE3_PRESTART_DEBT");
    lite_command(0,1,7'h00,32'd1,value); // auto_restart bit7 stays clear
    while (!done_seen) begin @(posedge clk); #1ps; end
    lite_command(0,0,7'h00,0,value);
    if (value[2:1] !== 2'b11) begin
      dump_outputs(); print_port_summary();
      $fatal(1,"D2_MODE3_CSR_DONE_IDLE got=%h",value);
    end
    if (!buses_drained()) begin
      dump_outputs(); print_port_summary();
      $fatal(1,"D2_MODE3_CSR_DEBT");
    end
    if (r_special_count!=1 || r_hold_cycles<16 ||
        b_special_count!=1 || b_hold_cycles<16 ||
        !raw_final_aw || !raw_final_w) begin
      dump_outputs(); print_port_summary();
      $fatal(1,"D2_MODE3_TERMINAL_HOLDS");
    end
    // Repeat dumps after the CSR read; a checker binds their exact bytes.
    dump_outputs();
    scan_pages();
    for (int p=0;p<7;p++)
      if (dut_aw_count[p] !== ram_aw_count[p] ||
          dut_w_count[p] !== ram_w_count[p] ||
          dut_b_count[p] !== ram_b_count[p] ||
          dut_ar_count[p] !== ram_ar_count[p] ||
          dut_r_count[p] !== ram_r_count[p] ||
          dut_rlast_count[p] !== ram_rlast_count[p] ||
          dut_read_bus_bytes[p] !== ram_read_bus_bytes[p] ||
          dut_write_bus_bytes[p] !== ram_write_bus_bytes[p] ||
          dut_write_useful_bytes[p] !== ram_write_useful_bytes[p])
        $fatal(1,"D2_MODE3_ADAPTER_TOTAL_MISMATCH port=%0d",p);
    $display("D2_MODE3_STATIC_MODE3_PASS candidates=16 mapped_pages=14 dut_cycles=%0d total_cycles=%0d",
      done_cycle-accepted_cycle,total_cycles);
    $finish;
  end
