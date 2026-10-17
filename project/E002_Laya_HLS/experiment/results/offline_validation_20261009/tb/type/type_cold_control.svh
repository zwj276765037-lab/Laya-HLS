  // Cold-only controller. The wall-time guard is the primary resource bound;
  // this cycle watchdog also stops a stalled design with a distinct error.
  localparam int RUN_CLOCK_LIMIT = 80000000;
  localparam int PAGE_BYTES = 4096;
  logic [7:0] init_hidden_input [0:64*PAGE_BYTES-1];
  logic [7:0] init_embedding [0:PAGE_BYTES-1];
  logic [7:0] init_io [0:8*PAGE_BYTES-1];
  logic [7:0] init_aux [0:PAGE_BYTES-1];
  logic [7:0] init_state0 [0:67*PAGE_BYTES-1];
  logic [7:0] init_state1 [0:64*PAGE_BYTES-1];
  logic [7:0] init_observed [0:PAGE_BYTES-1];
  logic [63:0] pointer_base [0:6];
  logic [6:0] pointer_offset [0:6];
  integer clocks=0;
  integer start_cycle=-1, first_done_cycle=-1;
  logic start_seen=0, first_done_seen=0, terminal_checked=0;
  integer r_hold_count=0, b_hold_count=0;
  bit trace_only=0;
  integer selected_r_ordinal=0;
  integer selected_state1_b_ordinal=0;
  integer selected_observed_b_ordinal=0;
  logic [63:0] selected_state1_aw_addr=0;
  logic [63:0] selected_observed_aw_addr=0;
  logic [63:0] last_state1_aw_addr=0, last_observed_aw_addr=0;
  logic [7:0] last_state1_aw_len=0, last_observed_aw_len=0;
  logic [2:0] last_state1_aw_size=0, last_observed_aw_size=0;
  localparam logic [63:0] TYPE_ROW_START = 64'h0000000500000000 +
      64'd16908288 + TYPE_ID * 64'd4096;
  localparam logic [63:0] TYPE_ROW_END = TYPE_ROW_START + 64'd4096;
  localparam logic [63:0] STATE1_BASE = 64'h0000000600000000;
  localparam logic [63:0] OBSERVED_BASE = 64'h0000000700000000;
  logic row_r_pending_stable;
  logic [63:0] row_r_beat_addr_stable;
  integer last_state0_r_logged=0;
  integer last_r_hold_logged=0;

  type_r_hold_selector #(.TYPE_ROW_END(TYPE_ROW_END)) u_type_r_hold_selector (
    .clk(clk),.resetn(resetn),.selected_r_ordinal(selected_r_ordinal),
    .arvalid(u_port_state0.e_arvalid),.arready(u_port_state0.e_arready),
    .araddr(u_port_state0.e_araddr),.arlen(u_port_state0.e_arlen),
    .arsize(u_port_state0.e_arsize),
    .rvalid(u_port_state0.e_rvalid),.rready(u_port_state0.e_rready),
    .rlast(u_port_state0.e_rlast),.hold_final_r(hold_final_r[4]),
    .row_pending_stable(row_r_pending_stable),
    .row_beat_addr_stable(row_r_beat_addr_stable));

  // Both the local address queue and the endpoint monitor's accepted record
  // have settled by the negative edge before the next R adapter sample.
  always @(negedge clk) begin
    if (!resetn) begin
      last_state0_r_logged=0;
      last_r_hold_logged=0;
    end else begin
      if (!trace_only && ram_r_count[4]+32'd1==selected_r_ordinal &&
          u_port_state0.e_rvalid)
        $display("TYPE_COLD_R_SELECTOR case=%s next_ordinal=%0d stable_addr=%h pending=%b rlast=%b",
                 CASE_NAME,ram_r_count[4]+32'd1,
                 row_r_beat_addr_stable,row_r_pending_stable,
                 u_port_state0.e_rlast);
      if (ram_r_count[4] != last_state0_r_logged) begin
        last_state0_r_logged=ram_r_count[4];
        if (ram_accepted_r_record[4][118] &&
            ram_accepted_r_record[4][85:22] >= TYPE_ROW_END - 64'd64 &&
            ram_accepted_r_record[4][85:22] < TYPE_ROW_END)
          $display("TYPE_COLD_TYPE_ROW_R case=%s beat_addr=%h ar_addr=%h ar_len=%0d ar_size=%0d beat=%0d r_count=%0d rlast=%b record=%h",
                   CASE_NAME,ram_accepted_r_record[4][85:22],
                   ram_accepted_r_record[4][85:22] -
                     ({56'd0,ram_accepted_r_record[4][21:14]} <<
                      ram_accepted_r_record[4][5:3]),
                   ram_accepted_r_record[4][13:6],
                   ram_accepted_r_record[4][5:3],
                   ram_accepted_r_record[4][21:14],
                   ram_accepted_r_record[4][117:86],
                   ram_accepted_r_record[4][0],ram_accepted_r_record[4]);
      end
      if (!trace_only && r_hold_count != last_r_hold_logged) begin
        last_r_hold_logged=r_hold_count;
        if (ram_accepted_r_record[4][118] !== 1'b1 ||
            ram_accepted_r_record[4][85:22] !== TYPE_ROW_END - 64'd4 ||
            ram_accepted_r_record[4][117:86] !== selected_r_ordinal ||
            ram_accepted_r_record[4][0] !== 1'b1)
          $fatal(1,"TYPE_COLD_HELD_R_IDENTITY case=%s record=%h",
                 CASE_NAME,ram_accepted_r_record[4]);
        $display("TYPE_COLD_HELD_TYPE_ROW_R case=%s r_ordinal=%0d beat_addr=%h record=%h",
                 CASE_NAME,ram_accepted_r_record[4][117:86],
                 ram_accepted_r_record[4][85:22],ram_accepted_r_record[4]);
      end
    end
  end

  for (genvar p=0; p<7; p++) begin : selected_terminal_holds
    if (p!=4) assign hold_final_r[p]=1'b0;
    if (p==5) begin
      assign hold_final_b[p]=resetn && selected_state1_b_ordinal>0 &&
          u_port_state1.e_bvalid &&
          ram_b_count[p]+32'd1==selected_state1_b_ordinal &&
          last_state1_aw_addr==selected_state1_aw_addr;
    end else if (p==6) begin
      assign hold_final_b[p]=resetn && selected_observed_b_ordinal>0 &&
          u_port_observed.e_bvalid &&
          ram_b_count[p]+32'd1==selected_observed_b_ordinal &&
          last_observed_aw_addr==selected_observed_aw_addr;
    end else assign hold_final_b[p]=1'b0;
  end

  function automatic bit buses_drained();
    for (int p=0; p<7; p++) begin
      if (dut_write_pending[p] !== 1'b0 || dut_read_pending[p] !== 1'b0 ||
          ram_write_pending[p] !== 1'b0 || ram_read_pending[p] !== 1'b0 ||
          dut_aw_count[p] !== dut_b_count[p] ||
          ram_aw_count[p] !== ram_b_count[p] ||
          dut_ar_count[p] !== dut_rlast_count[p] ||
          ram_ar_count[p] !== ram_rlast_count[p]) return 0;
      for (int c=0; c<5; c++)
        if (accepted[p][c] !== delivered[p][c]) return 0;
    end
    return 1;
  endfunction

  function automatic logic [31:0] observed_word(input int index);
    int k;
    k=4*index;
    return {u_port_observed.u_mem.mem[k+3],u_port_observed.u_mem.mem[k+2],
            u_port_observed.u_mem.mem[k+1],u_port_observed.u_mem.mem[k]};
  endfunction

  task automatic pointer_write(input logic [6:0] addr,
                               input logic [31:0] data);
    wait (lite_cmd_ready_1);
    @(posedge clk); #1ps;
    lite_cmd_addr_1=addr;
    lite_cmd_wdata_1=data;
    lite_cmd_write_1=1'b1;
    lite_cmd_valid_1=1'b1;
    @(posedge clk); #1ps;
    lite_cmd_valid_1=1'b0;
    wait (lite_cmd_done_1);
    @(posedge clk); #1ps;
  endtask

  task automatic pointer_read(input logic [6:0] addr,
                              output logic [31:0] data);
    wait (lite_cmd_ready_1);
    @(posedge clk); #1ps;
    lite_cmd_addr_1=addr;
    lite_cmd_wdata_1='0;
    lite_cmd_write_1=1'b0;
    lite_cmd_valid_1=1'b1;
    @(posedge clk); #1ps;
    lite_cmd_valid_1=1'b0;
    wait (lite_cmd_done_1);
    data=lite_cmd_rdata_1;
    @(posedge clk); #1ps;
  endtask

  task automatic control_start();
    wait (lite_cmd_ready_0);
    @(posedge clk); #1ps;
    lite_cmd_addr_0=4'h0;
    lite_cmd_wdata_0=32'h1;
    lite_cmd_write_0=1'b1;
    lite_cmd_valid_0=1'b1;
    @(posedge clk); #1ps;
    lite_cmd_valid_0=1'b0;
    wait (lite_cmd_done_0);
    @(posedge clk); #1ps;
  endtask

  task automatic dump_mapped_pages();
    integer fd;
    fd=$fopen("dump_hidden_input.hex","w");
    if (!fd) $fatal(1,"TYPE_DUMP_OPEN hidden_input");
    for (int i=0;i<64*PAGE_BYTES;i++)
      $fwrite(fd,"%02x",u_port_hidden_input.u_mem.mem[i]);
    $fwrite(fd,"\n"); $fclose(fd);
    fd=$fopen("dump_embedding.hex","w");
    if (!fd) $fatal(1,"TYPE_DUMP_OPEN embedding");
    for (int i=0;i<PAGE_BYTES;i++)
      $fwrite(fd,"%02x",u_port_embedding.u_mem.mem[i]);
    $fwrite(fd,"\n"); $fclose(fd);
    fd=$fopen("dump_io.hex","w");
    if (!fd) $fatal(1,"TYPE_DUMP_OPEN io");
    for (int i=0;i<8*PAGE_BYTES;i++)
      $fwrite(fd,"%02x",u_port_io.u_mem.mem[i]);
    $fwrite(fd,"\n"); $fclose(fd);
    fd=$fopen("dump_aux.hex","w");
    if (!fd) $fatal(1,"TYPE_DUMP_OPEN aux");
    for (int i=0;i<PAGE_BYTES;i++)
      $fwrite(fd,"%02x",u_port_aux.u_mem.mem[i]);
    $fwrite(fd,"\n"); $fclose(fd);
    fd=$fopen("dump_state0.hex","w");
    if (!fd) $fatal(1,"TYPE_DUMP_OPEN state0");
    for (int i=0;i<67*PAGE_BYTES;i++)
      $fwrite(fd,"%02x",u_port_state0.u_mem.mem[i]);
    $fwrite(fd,"\n"); $fclose(fd);
    fd=$fopen("dump_state1.hex","w");
    if (!fd) $fatal(1,"TYPE_DUMP_OPEN state1");
    for (int i=0;i<64*PAGE_BYTES;i++)
      $fwrite(fd,"%02x",u_port_state1.u_mem.mem[i]);
    $fwrite(fd,"\n"); $fclose(fd);
    fd=$fopen("dump_observed.hex","w");
    if (!fd) $fatal(1,"TYPE_DUMP_OPEN observed");
    for (int i=0;i<PAGE_BYTES;i++)
      $fwrite(fd,"%02x",u_port_observed.u_mem.mem[i]);
    $fwrite(fd,"\n"); $fclose(fd);
  endtask

  always @(posedge clk) begin
    int r_hits;
    int b_hits;
    r_hits=0;
    b_hits=0;
    if (resetn) begin
      clocks <= clocks+1;
      if (clocks > RUN_CLOCK_LIMIT)
        $fatal(1,"TYPE_COLD_WATCHDOG case=%s clocks=%0d",CASE_NAME,clocks);
      if (clocks != 0 && clocks % 131072 == 0)
        $display("TYPE_COLD_PROGRESS case=%s clocks=%0d fsm=%h ingest_row=%0d type_fsm=%h vector_fsm=%h ap_start=%b ap_done=%b ap_idle=%b ap_ready=%b state0_aw=%0d state0_ar=%0d state0_r=%0d state1_aw=%0d state1_b=%0d observed_aw=%0d observed_b=%0d observed0=%h observed2=%h observed13=%h",
                 CASE_NAME,clocks,dut.ap_CS_fsm,
                 dut.grp_p_anonymous_namespace_ingest_hidden_fu_871.row_fu_184,
                 dut.grp_p_anonymous_namespace_type_add_fu_1007.ap_CS_fsm,
                 dut.grp_p_anonymous_namespace_type_add_fu_1007.grp_p_anonymous_namespace_vector_impl_fu_938.ap_CS_fsm,
                 dut.ap_start,dut.ap_done,dut.ap_idle,dut.ap_ready,ram_aw_count[4],
                 ram_ar_count[4],ram_r_count[4],ram_aw_count[5],
                 ram_b_count[5],ram_aw_count[6],ram_b_count[6],
                 observed_word(0),observed_word(2),observed_word(13));
      if (m_axi_state1_AWVALID && m_axi_state1_AWREADY) begin
        last_state1_aw_addr <= m_axi_state1_AWADDR;
        last_state1_aw_len <= m_axi_state1_AWLEN;
        last_state1_aw_size <= m_axi_state1_AWSIZE;
      end
      if (m_axi_observed_AWVALID && m_axi_observed_AWREADY) begin
        last_observed_aw_addr <= m_axi_observed_AWADDR;
        last_observed_aw_len <= m_axi_observed_AWLEN;
        last_observed_aw_size <= m_axi_observed_AWSIZE;
      end
      if (u_port_state1.e_bvalid && u_port_state1.e_bready &&
          last_state1_aw_addr >= STATE1_BASE + 64'd262080 &&
          last_state1_aw_addr < STATE1_BASE + 64'd262144)
        $display("TYPE_COLD_STATE1_TAIL_B case=%s b_ordinal=%0d aw_count=%0d last_aw=%h len=%0d",
                 CASE_NAME,ram_b_count[5]+1,ram_aw_count[5],
                 last_state1_aw_addr,last_state1_aw_len);
      if (u_port_observed.e_bvalid && u_port_observed.e_bready &&
          last_observed_aw_addr >= OBSERVED_BASE &&
          last_observed_aw_addr < OBSERVED_BASE + 64'd128)
        $display("TYPE_COLD_OBSERVED_B case=%s b_ordinal=%0d aw_count=%0d last_aw=%h len=%0d",
                 CASE_NAME,ram_b_count[6]+1,ram_aw_count[6],
                 last_observed_aw_addr,last_observed_aw_len);
      for (int p=0;p<7;p++) begin
        if (r_hold_applied[p]) begin
          if (r_special_wait_cycles[p] < 16)
            $fatal(1,"TYPE_COLD_R_HOLD_SHORT case=%s port=%0d cycles=%0d",
                   CASE_NAME,p,r_special_wait_cycles[p]);
          $display("TYPE_COLD_R_HOLD case=%s port=%0d wait=%0d record=%h",
                   CASE_NAME,p,r_special_wait_cycles[p],ram_accepted_r_record[p]);
          r_hits++;
        end
        if (b_hold_applied[p]) begin
          if (b_special_wait_cycles[p] < 16)
            $fatal(1,"TYPE_COLD_B_HOLD_SHORT case=%s port=%0d cycles=%0d",
                   CASE_NAME,p,b_special_wait_cycles[p]);
          $display("TYPE_COLD_B_HOLD case=%s port=%0d wait=%0d",
                   CASE_NAME,p,b_special_wait_cycles[p]);
          b_hits++;
        end
      end
      r_hold_count <= r_hold_count+r_hits;
      b_hold_count <= b_hold_count+b_hits;
      // The generated HLS FSM accepts ap_start in state1; ap_ready is asserted
      // only in its terminal state37, so it cannot witness start acceptance.
      if (dut.ap_start && dut.ap_CS_fsm_state1 && !start_seen) begin
        start_seen <= 1'b1;
        start_cycle <= clocks;
        $display("TYPE_COLD_AP_START case=%s cycle=%0d",CASE_NAME,clocks);
      end
      if (dut.ap_done && !first_done_seen) begin
        first_done_seen <= 1'b1;
        first_done_cycle <= clocks;
        #1ps;
        if (!buses_drained())
          $fatal(1,"TYPE_COLD_EARLY_DONE_DEBT case=%s cycle=%0d",CASE_NAME,clocks);
        $display("TYPE_COLD_TERMINAL_TRACE case=%s state0_ar=%0d state0_r=%0d state1_aw=%0d state1_b=%0d state1_last_aw=%h len=%0d size=%0d observed_aw=%0d observed_b=%0d observed_last_aw=%h len=%0d size=%0d r_hold=%0d b_hold=%0d",
                 CASE_NAME,ram_ar_count[4],ram_r_count[4],ram_aw_count[5],
                 ram_b_count[5],last_state1_aw_addr,last_state1_aw_len,
                 last_state1_aw_size,
                 ram_aw_count[6],ram_b_count[6],last_observed_aw_addr,
                 last_observed_aw_len,last_observed_aw_size,
                 r_hold_count,b_hold_count);
        if (!trace_only &&
            (u_type_r_hold_selector.accepted_r_count_local != ram_r_count[4] ||
             ram_ar_count[4] != selected_r_ordinal ||
             ram_r_count[4] != selected_r_ordinal ||
             ram_b_count[5] != selected_state1_b_ordinal ||
             ram_b_count[6] != selected_observed_b_ordinal ||
             last_state1_aw_addr != selected_state1_aw_addr ||
             last_observed_aw_addr != selected_observed_aw_addr ||
             last_state1_aw_addr + (({56'd0,last_state1_aw_len}+64'd1) << last_state1_aw_size) !=
                 STATE1_BASE + 64'd262144 ||
             last_observed_aw_addr + (({56'd0,last_observed_aw_len}+64'd1) << last_observed_aw_size) !=
                 OBSERVED_BASE + 64'd128))
          $fatal(1,"TYPE_COLD_TERMINAL_B_IDENTITY case=%s",CASE_NAME);
        $display("TYPE_COLD_FIRST_DONE case=%s cycle=%0d",CASE_NAME,clocks);
        terminal_checked <= 1'b1;
      end
    end
  end

  initial begin : one_cold_request
    logic [31:0] readback;
    lite_cmd_valid_0=0; lite_cmd_valid_1=0;
    lite_cmd_write_0=0; lite_cmd_write_1=0;
    lite_cmd_addr_0='0; lite_cmd_addr_1='0;
    lite_cmd_wdata_0='0; lite_cmd_wdata_1='0;
    trace_only = $test$plusargs("TYPE_TRACE_ONLY");
    if (!trace_only) begin
      if (!$value$plusargs("TYPE_R_ORDINAL=%d",selected_r_ordinal) ||
          !$value$plusargs("TYPE_STATE1_B_ORDINAL=%d",selected_state1_b_ordinal) ||
          !$value$plusargs("TYPE_OBSERVED_B_ORDINAL=%d",selected_observed_b_ordinal) ||
          !$value$plusargs("TYPE_STATE1_AW_ADDR=%h",selected_state1_aw_addr) ||
          !$value$plusargs("TYPE_OBSERVED_AW_ADDR=%h",selected_observed_aw_addr) ||
          selected_r_ordinal<1 || selected_state1_b_ordinal<1 ||
          selected_observed_b_ordinal<1 || selected_state1_aw_addr==0 ||
          selected_observed_aw_addr==0)
        $fatal(1,"TYPE_COLD_TERMINAL_SELECTOR_ARGUMENTS case=%s",CASE_NAME);
    end
    $readmemh("init_hidden_input.memh",init_hidden_input);
    $readmemh("init_embedding.memh",init_embedding);
    $readmemh("init_io.memh",init_io);
    $readmemh("init_aux.memh",init_aux);
    $readmemh("init_state0.memh",init_state0);
    $readmemh("init_state1.memh",init_state1);
    $readmemh("init_observed.memh",init_observed);
    pointer_base[0]=64'h0000000100000000; pointer_offset[0]=7'h10;
    pointer_base[1]=64'h0000000200000000; pointer_offset[1]=7'h1c;
    pointer_base[2]=64'h0000000300000000; pointer_offset[2]=7'h28;
    pointer_base[3]=64'h0000000400000000; pointer_offset[3]=7'h34;
    pointer_base[4]=64'h0000000500000000; pointer_offset[4]=7'h40;
    pointer_base[5]=64'h0000000600000000; pointer_offset[5]=7'h4c;
    pointer_base[6]=64'h0000000700000000; pointer_offset[6]=7'h58;
    // Let each endpoint's own time-zero initialization complete before copy.
    #1ns;
    for (int i=0;i<64*PAGE_BYTES;i++)
      u_port_hidden_input.u_mem.mem[i]=init_hidden_input[i];
    for (int i=0;i<PAGE_BYTES;i++) begin
      u_port_embedding.u_mem.mem[i]=init_embedding[i];
      u_port_aux.u_mem.mem[i]=init_aux[i];
      u_port_observed.u_mem.mem[i]=init_observed[i];
    end
    for (int i=0;i<8*PAGE_BYTES;i++) u_port_io.u_mem.mem[i]=init_io[i];
    for (int i=0;i<67*PAGE_BYTES;i++) u_port_state0.u_mem.mem[i]=init_state0[i];
    for (int i=0;i<64*PAGE_BYTES;i++) u_port_state1.u_mem.mem[i]=init_state1[i];
    repeat (10) @(posedge clk);
    #1ps; resetn=1'b1;
    for (int p=0;p<7;p++) begin
      pointer_write(pointer_offset[p],pointer_base[p][31:0]);
      pointer_write(pointer_offset[p]+7'd4,pointer_base[p][63:32]);
      pointer_read(pointer_offset[p],readback);
      if (readback !== pointer_base[p][31:0])
        $fatal(1,"TYPE_COLD_POINTER_LOW port=%0d",p);
      pointer_read(pointer_offset[p]+7'd4,readback);
      if (readback !== pointer_base[p][63:32])
        $fatal(1,"TYPE_COLD_POINTER_HIGH port=%0d",p);
    end
    control_start();
    wait (terminal_checked);
    if (!start_seen || first_done_cycle <= start_cycle)
      $fatal(1,"TYPE_COLD_START_DONE_ORDER");
    if (trace_only) begin
      dump_mapped_pages();
      $fatal(1,"TYPE_COLD_TRACE_ONLY_NO_ACCEPTANCE case=%s",CASE_NAME);
    end
    if (r_hold_count < 1 || b_hold_count < 2)
      $fatal(1,"TYPE_COLD_TERMINAL_HOLDS_UNPROVEN");
    if (observed_word(0) !== 32'd0 || observed_word(2) !== 32'd5 ||
        observed_word(3) !== 32'd5 || observed_word(4) !== 32'd5 ||
        observed_word(5) !== 32'd3 || observed_word(13) !== TYPE_ID)
      $fatal(1,"TYPE_COLD_OBSERVED_TASK_STATUS");
    dump_mapped_pages();
    $display("TYPE_COLD_STATIC_TB_DONE case=%s start=%0d first_done=%0d mapped_pages=206",
             CASE_NAME,start_cycle,first_done_cycle);
    $finish;
  end
