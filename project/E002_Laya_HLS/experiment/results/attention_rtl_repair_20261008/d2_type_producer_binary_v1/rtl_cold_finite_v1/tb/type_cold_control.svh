  // Cold-only controller. RUN_CLOCK_LIMIT and selected terminal holds stay
  // disabled until the generated-FSM/AXI progress certificate is reviewed.
  // The $fatal is intentional: compiling this source cannot authorize a run.
  localparam int RUN_CLOCK_LIMIT = 0;
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
  logic start_seen=0, first_done_seen=0;
  integer r_hold_count=0, b_hold_count=0;

  for (genvar p=0; p<7; p++) begin : unproven_terminal_holds
    assign hold_final_r[p]=1'b0;
    assign hold_final_b[p]=1'b0;
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
    if (resetn) begin
      clocks <= clocks+1;
      if (RUN_CLOCK_LIMIT > 0 && clocks > RUN_CLOCK_LIMIT)
        $fatal(1,"TYPE_COLD_WATCHDOG case=%s clocks=%0d",CASE_NAME,clocks);
      for (int p=0;p<7;p++) begin
        if (r_hold_applied[p]) r_hold_count <= r_hold_count+1;
        if (b_hold_applied[p]) b_hold_count <= b_hold_count+1;
      end
      if (dut.ap_start && dut.ap_ready && !start_seen) begin
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
        $display("TYPE_COLD_FIRST_DONE case=%s cycle=%0d",CASE_NAME,clocks);
      end
    end
  end

  initial begin : one_cold_request
    logic [31:0] readback;
    lite_cmd_valid_0=0; lite_cmd_valid_1=0;
    lite_cmd_write_0=0; lite_cmd_write_1=0;
    lite_cmd_addr_0='0; lite_cmd_addr_1='0;
    lite_cmd_wdata_0='0; lite_cmd_wdata_1='0;
    if (RUN_CLOCK_LIMIT == 0)
      $fatal(1,"TYPE_COLD_RUNTIME_HELD_NO_FSM_AXI_BOUND");
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
    wait (first_done_seen);
    if (!start_seen || first_done_cycle <= start_cycle)
      $fatal(1,"TYPE_COLD_START_DONE_ORDER");
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
