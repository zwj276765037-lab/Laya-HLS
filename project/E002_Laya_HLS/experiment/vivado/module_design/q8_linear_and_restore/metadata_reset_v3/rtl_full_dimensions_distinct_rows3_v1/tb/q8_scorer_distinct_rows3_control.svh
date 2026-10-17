  // Source-only distinct_rows3 successor: cold LOAD, trace-on RUN, same-input trace-off RUN.
  // Backing pages and gold are produced only after a separate execution gate.
  localparam int PAGE_BYTES = 4096;
  localparam int OBS_BYTES = 131072;
  localparam int COMMANDS = 3;
  integer o_ap_accept [0:COMMANDS-1], o_ap_done [0:COMMANDS-1];
  integer o_issues [0:COMMANDS-1], o_retires [0:COMMANDS-1];
  integer o_sub_starts [0:COMMANDS-1][0:4], o_sub_dones [0:COMMANDS-1][0:4];
  localparam int MAX_COMMAND_CLOCKS = 7000000;
  localparam int MAX_TOTAL_CLOCKS = 16000000;
  localparam int PROGRESS_CLOCK_INTERVAL = 131072;
  localparam logic [63:0] DESC_BASE = 64'h1000000000;
  localparam logic [63:0] Q0_BASE = 64'h1100000000 + 64'd184156160;
  localparam logic [63:0] Q1_BASE = 64'h1200000000 + 64'd184156160;
  localparam logic [63:0] SCALE_BASE = 64'h1300000000 + 64'd23019520;
  localparam logic [63:0] AUX_BASE = 64'h1400000000;
  localparam logic [63:0] BIAS_BASE = AUX_BASE + 64'd1667776;
  localparam logic [63:0] ACT_BASE = 64'h1500000000;
  localparam logic [63:0] OUT_BASE = 64'h1600000000;
  localparam logic [63:0] OBS_BASE = 64'h1800000000;
  logic [7:0] init_descriptor [0:PAGE_BYTES-1];
  logic [7:0] init_w_q0 [0:524288-1], init_w_q1 [0:524288-1];
  logic [7:0] init_w_scale [0:65536-1];
  logic [7:0] init_aux [0:3*PAGE_BYTES-1];
  logic [7:0] init_activation [0:16*PAGE_BYTES-1];
  logic [7:0] init_out0 [0:16*PAGE_BYTES-1];
  logic [7:0] init_out1 [0:PAGE_BYTES-1];
  logic [7:0] init_observed [0:OBS_BYTES-1];
  logic [7:0] descriptor_image [0:COMMANDS*PAGE_BYTES-1];
  logic [7:0] expected_observed [0:COMMANDS*OBS_BYTES-1];
  logic [7:0] expected_out0 [0:COMMANDS*16*PAGE_BYTES-1];
  logic [7:0] expected_out1 [0:COMMANDS*PAGE_BYTES-1];
  logic [63:0] pointer_base [0:8];
  logic [6:0] pointer_offset [0:8];
  logic [63:0] before_read [0:8], before_useful [0:8];
  logic [31:0] before_aw [0:8], before_ar [0:8];
  integer cmd_idx, ptr_idx, total_cycles, command_cycles, reset_left;
  integer progress_fd;
  logic running, seen_done, sampled_ap_done;
  typedef enum logic [3:0] {
    BOOT, COLD_RESET, PTR_ZERO, PTR_ZERO_WAIT, PTR_WRITE, PTR_WRITE_WAIT,
    PTR_READBACK, PTR_READBACK_WAIT, CASE_LOAD, CASE_START, CASE_START_WAIT,
    CASE_WAIT_DONE, CSR_READ, CSR_READ_WAIT, CASE_CHECK, FINISH
  } state_t;
  state_t test_state = BOOT;

  function automatic logic [63:0] wanted_bytes(input int p, input int case_id);
    if (p==0) return 64'd512;
    if (case_id==0) begin
      case (p)
        1,2: return 64'd524288;
        3: return 64'd65536;
        4: return 64'd4224;
        8: return 64'd1024;
        default: return 0;
      endcase
    end
    case (p)
      5,6: return 64'd12288;
      8: return case_id==1 ? 64'd5312 : 64'd1024;
      default: return 0;
    endcase
  endfunction

  function automatic bit buses_drained();
    for (int p=0; p<9; p++) begin
      if (dut_write_pending[p] !== 1'b0 || dut_read_pending[p] !== 1'b0 ||
          ram_write_pending[p] !== 1'b0 || ram_read_pending[p] !== 1'b0 ||
          dut_aw_count[p] !== dut_b_count[p] ||
          dut_ar_count[p] !== dut_rlast_count[p] ||
          ram_aw_count[p] !== ram_b_count[p] ||
          ram_ar_count[p] !== ram_rlast_count[p]) return 0;
      for (int c=0; c<5; c++)
        if (accepted[p][c] !== delivered[p][c]) return 0;
    end
    return 1;
  endfunction

  task automatic set_read(input int p, input int slot,
                          input logic [63:0] first, input logic [63:0] length);
    read_lo[p][slot] = first;
    read_hi[p][slot] = first + length;
  endtask
  task automatic set_write(input int p, input int slot,
                           input logic [63:0] first, input logic [63:0] length);
    write_lo[p][slot] = first;
    write_hi[p][slot] = first + length;
  endtask
  task automatic windows(input int case_id);
    for (int p=0; p<9; p++) begin
      read_lo[p]='0; read_hi[p]='0;
      write_lo[p]='0; write_hi[p]='0;
    end
    set_read(0,0,DESC_BASE,512);
    set_write(8,0,OBS_BASE,1024);
    if (case_id==0) begin
      set_read(1,0,Q0_BASE,524288);
      set_read(2,0,Q1_BASE,524288);
      set_read(3,0,SCALE_BASE,65536);
      set_read(4,0,AUX_BASE,128);
      set_read(4,1,BIAS_BASE,4096);
    end else begin
      set_read(5,0,ACT_BASE,12288);
      set_write(6,0,OUT_BASE,12288);
      if (case_id==1) begin
        set_write(8,0,OBS_BASE,4096);
        set_write(8,1,OBS_BASE+66560,192);
        set_write(8,2,OBS_BASE+70656,1024);
      end
    end
  endtask

  task automatic dump_raw_pages(input int case_id);
    integer f_obs, f_out0, f_out1;
    f_obs=$fopen($sformatf("observed_cmd%0d.hex",case_id),"w");
    f_out0=$fopen($sformatf("out0_cmd%0d.hex",case_id),"w");
    f_out1=$fopen($sformatf("out1_cmd%0d.hex",case_id),"w");
    if (f_obs==0 || f_out0==0 || f_out1==0)
      $fatal(1,"Q8_SCORER_RAW_DUMP_OPEN cmd=%0d",case_id);
    for (int i=0;i<OBS_BYTES;i++)
      $fwrite(f_obs,"%02x\n",u_port_observed.u_mem.mem[i]);
    for (int i=0;i<16*PAGE_BYTES;i++)
      $fwrite(f_out0,"%02x\n",u_port_out0.u_mem.mem[i]);
    for (int i=0;i<PAGE_BYTES;i++)
      $fwrite(f_out1,"%02x\n",u_port_out1.u_mem.mem[i]);
    $fclose(f_obs); $fclose(f_out0); $fclose(f_out1);
    $display("Q8_SCORER_RAW_DUMP cmd=%0d observed_bytes=%0d out0_bytes=%0d out1_bytes=%0d",
             case_id,OBS_BYTES,16*PAGE_BYTES,PAGE_BYTES);
  endtask

  // A bounded, flushed progress trace lets a long first Scorer RUN be
  // inspected without sampling or changing any DUT signal.
  task automatic report_progress();
    string line;
    line=$sformatf("Q8_SCORER_PROGRESS cmd=%0d total_clock=%0d command_clock=%0d tb_state=%0d ap_accept_clock=%0d ap_done_clock=%0d issue=%0d retire=%0d sub_start=%0d,%0d,%0d,%0d,%0d sub_done=%0d,%0d,%0d,%0d,%0d q0_r=%0d q1_r=%0d scale_r=%0d aux_r=%0d act_r=%0d out0_w=%0d observed_w=%0d",
                   cmd_idx,total_cycles,command_cycles,test_state,
                   o_ap_accept[cmd_idx],o_ap_done[cmd_idx],
                   o_issues[cmd_idx],o_retires[cmd_idx],
                   o_sub_starts[cmd_idx][0],o_sub_starts[cmd_idx][1],
                   o_sub_starts[cmd_idx][2],o_sub_starts[cmd_idx][3],
                   o_sub_starts[cmd_idx][4],o_sub_dones[cmd_idx][0],
                   o_sub_dones[cmd_idx][1],o_sub_dones[cmd_idx][2],
                   o_sub_dones[cmd_idx][3],o_sub_dones[cmd_idx][4],
                   dut_read_bus_bytes[1]-before_read[1],
                   dut_read_bus_bytes[2]-before_read[2],
                   dut_read_bus_bytes[3]-before_read[3],
                   dut_read_bus_bytes[4]-before_read[4],
                   dut_read_bus_bytes[5]-before_read[5],
                   dut_write_useful_bytes[6]-before_useful[6],
                   dut_write_useful_bytes[8]-before_useful[8]);
    $display("%s",line);
    $fdisplay(progress_fd,"%s",line);
    $fflush(progress_fd);
  endtask

  initial begin
    pointer_base[0]=64'h1000000000;
    pointer_base[1]=64'h1100000000;
    pointer_base[2]=64'h1200000000;
    pointer_base[3]=64'h1300000000;
    pointer_base[4]=64'h1400000000;
    pointer_base[5]=64'h1500000000;
    pointer_base[6]=64'h1600000000;
    pointer_base[7]=64'h1700000000;
    pointer_base[8]=64'h1800000000;
    pointer_offset[0]=7'h10;
    pointer_offset[1]=7'h1c;
    pointer_offset[2]=7'h28;
    pointer_offset[3]=7'h34;
    pointer_offset[4]=7'h40;
    pointer_offset[5]=7'h4c;
    pointer_offset[6]=7'h58;
    pointer_offset[7]=7'h64;
    pointer_offset[8]=7'h70;
    $readmemh("init_descriptor.memh",init_descriptor);
    $readmemh("init_w_q0.memh",init_w_q0);
    $readmemh("init_w_q1.memh",init_w_q1);
    $readmemh("init_w_scale.memh",init_w_scale);
    $readmemh("init_aux.memh",init_aux);
    $readmemh("init_activation.memh",init_activation);
    $readmemh("init_out0.memh",init_out0);
    $readmemh("init_out1.memh",init_out1);
    $readmemh("init_observed.memh",init_observed);
    $readmemh("descriptor.memh",descriptor_image);
    $readmemh("expected_observed.memh",expected_observed);
    $readmemh("expected_out0.memh",expected_out0);
    $readmemh("expected_out1.memh",expected_out1);
    windows(0);
    for (int p=0;p<9;p++) begin
      hold_final_r[p]=0;
      hold_final_b[p]=0;
    end
    cmd_idx=0; ptr_idx=0; total_cycles=0; command_cycles=0;
    progress_fd=$fopen("progress.log","w");
    if (progress_fd==0) $fatal(1,"Q8_SCORER_PROGRESS_OPEN");
    reset_left=0; running=0; seen_done=0; sampled_ap_done=0;
    lite_cmd_valid_0=0; lite_cmd_valid_1=0;
    lite_cmd_write_0=0; lite_cmd_write_1=0;
    lite_cmd_addr_0=0; lite_cmd_addr_1=0;
    lite_cmd_wdata_0=0; lite_cmd_wdata_1=0;
  end

  always @(posedge clk) begin
    if (!resetn) sampled_ap_done <= 0;
    else sampled_ap_done <= dut.ap_done;
  end

  // Testbench controls and backing-memory writes occur only on negedges.
  always @(negedge clk) begin : drive_sequence
    logic [31:0] expected_pointer_word;
    logic [63:0] delta;
    if (total_cycles>=MAX_TOTAL_CLOCKS)
      $fatal(1,"Q8_SCORER_TOTAL_CLOCK_GUARD cmd=%0d",cmd_idx);
    total_cycles=total_cycles+1;
    if (running) begin
      command_cycles=command_cycles+1;
      if (command_cycles%PROGRESS_CLOCK_INTERVAL==0) report_progress();
      if (command_cycles>MAX_COMMAND_CLOCKS)
        $fatal(1,"Q8_SCORER_COMMAND_CLOCK_GUARD cmd=%0d",cmd_idx);
      if ($isunknown(sampled_ap_done))
        $fatal(1,"Q8_SCORER_DONE_UNKNOWN cmd=%0d",cmd_idx);
      if (sampled_ap_done && !seen_done) begin
        if (!buses_drained())
          $fatal(1,"Q8_SCORER_EARLY_DONE_WITH_AXI_DEBT cmd=%0d",cmd_idx);
        seen_done=1;
      end
    end
    lite_cmd_valid_0<=0;
    lite_cmd_valid_1<=0;
    case (test_state)
      BOOT: begin
        for (int i=0;i<PAGE_BYTES;i++) begin
          u_port_descriptor.u_mem.mem[i]=init_descriptor[i];
          u_port_out1.u_mem.mem[i]=init_out1[i];
        end
        for (int i=0;i<524288;i++) begin
          u_port_w_q0.u_mem.mem[i]=init_w_q0[i];
          u_port_w_q1.u_mem.mem[i]=init_w_q1[i];
        end
        for (int i=0;i<65536;i++) begin
          u_port_w_scale.u_mem.mem[i]=init_w_scale[i];
          u_port_activation.u_mem.mem[i]=init_activation[i];
          u_port_out0.u_mem.mem[i]=init_out0[i];
        end
        for (int i=0;i<3*PAGE_BYTES;i++) u_port_aux.u_mem.mem[i]=init_aux[i];
        for (int i=0;i<OBS_BYTES;i++)
          u_port_observed.u_mem.mem[i]=init_observed[i];
        reset_left=5;
        test_state<=COLD_RESET;
      end
      COLD_RESET: begin
        if (reset_left==0) begin resetn<=1; ptr_idx=0; test_state<=PTR_ZERO; end
        else reset_left=reset_left-1;
      end
      PTR_ZERO: if (lite_cmd_ready_1) begin
        lite_cmd_write_1<=0;
        lite_cmd_addr_1<=pointer_offset[ptr_idx/2]+7'((ptr_idx%2)*4);
        lite_cmd_wdata_1<=0;
        lite_cmd_valid_1<=1;
        test_state<=PTR_ZERO_WAIT;
      end
      PTR_ZERO_WAIT: if (lite_cmd_done_1) begin
        if (lite_cmd_rdata_1 !== 32'd0)
          $fatal(1,"Q8_SCORER_POINTER_NONZERO index=%0d got=%h",ptr_idx,lite_cmd_rdata_1);
        if (ptr_idx==17) begin ptr_idx=0; test_state<=PTR_WRITE; end
        else begin ptr_idx=ptr_idx+1; test_state<=PTR_ZERO; end
      end
      PTR_WRITE: if (lite_cmd_ready_1) begin
        expected_pointer_word=(ptr_idx%2)==0 ?
            pointer_base[ptr_idx/2][31:0] : pointer_base[ptr_idx/2][63:32];
        lite_cmd_write_1<=1;
        lite_cmd_addr_1<=pointer_offset[ptr_idx/2]+7'((ptr_idx%2)*4);
        lite_cmd_wdata_1<=expected_pointer_word;
        lite_cmd_valid_1<=1;
        test_state<=PTR_WRITE_WAIT;
      end
      PTR_WRITE_WAIT: if (lite_cmd_done_1) begin
        if (ptr_idx==17) begin ptr_idx=0; test_state<=PTR_READBACK; end
        else begin ptr_idx=ptr_idx+1; test_state<=PTR_WRITE; end
      end
      PTR_READBACK: if (lite_cmd_ready_1) begin
        lite_cmd_write_1<=0;
        lite_cmd_addr_1<=pointer_offset[ptr_idx/2]+7'((ptr_idx%2)*4);
        lite_cmd_wdata_1<=0;
        lite_cmd_valid_1<=1;
        test_state<=PTR_READBACK_WAIT;
      end
      PTR_READBACK_WAIT: if (lite_cmd_done_1) begin
        expected_pointer_word=(ptr_idx%2)==0 ?
            pointer_base[ptr_idx/2][31:0] : pointer_base[ptr_idx/2][63:32];
        if (lite_cmd_rdata_1 !== expected_pointer_word)
          $fatal(1,"Q8_SCORER_POINTER_READBACK index=%0d got=%h expected=%h",
                 ptr_idx,lite_cmd_rdata_1,expected_pointer_word);
        if (ptr_idx==17) test_state<=CASE_LOAD;
        else begin ptr_idx=ptr_idx+1; test_state<=PTR_READBACK; end
      end
      CASE_LOAD: begin
        if (!buses_drained()) $fatal(1,"Q8_SCORER_MUTATE_WITH_AXI_DEBT");
        observer_reset_command(cmd_idx);
        windows(cmd_idx);
        for (int i=0;i<PAGE_BYTES;i++) begin
          u_port_descriptor.u_mem.mem[i]=descriptor_image[cmd_idx*PAGE_BYTES+i];
          u_port_out1.u_mem.mem[i]=init_out1[i];
        end
        for (int i=0;i<16*PAGE_BYTES;i++)
          u_port_out0.u_mem.mem[i]=init_out0[i];
        for (int i=0;i<OBS_BYTES;i++)
          u_port_observed.u_mem.mem[i]=init_observed[i];
        for (int p=0;p<9;p++) begin
          before_read[p]=dut_read_bus_bytes[p];
          before_useful[p]=dut_write_useful_bytes[p];
          before_aw[p]=dut_aw_count[p];
          before_ar[p]=dut_ar_count[p];
        end
        command_cycles=0;
        test_state<=CASE_START;
      end
      CASE_START: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=1; lite_cmd_addr_0<=4'h0;
        lite_cmd_wdata_0<=32'h1; lite_cmd_valid_0<=1;
        running=1; seen_done=0;
        report_progress();
        test_state<=CASE_START_WAIT;
      end
      CASE_START_WAIT: if (lite_cmd_done_0) test_state<=CASE_WAIT_DONE;
      CASE_WAIT_DONE: if (seen_done) test_state<=CSR_READ;
      CSR_READ: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=0; lite_cmd_addr_0<=4'h0;
        lite_cmd_wdata_0<=0; lite_cmd_valid_0<=1;
        test_state<=CSR_READ_WAIT;
      end
      CSR_READ_WAIT: if (lite_cmd_done_0) begin
        if (lite_cmd_rdata_0[2:1] !== 2'b11)
          $fatal(1,"Q8_SCORER_CSR_DONE_IDLE cmd=%0d csr=%h",cmd_idx,lite_cmd_rdata_0);
        test_state<=CASE_CHECK;
      end
      CASE_CHECK: begin
        dump_raw_pages(cmd_idx);
        if (!buses_drained()) $fatal(1,"Q8_SCORER_CHECK_WITH_AXI_DEBT");
        for (int i=0;i<PAGE_BYTES;i++) begin
          if (u_port_descriptor.u_mem.mem[i] !== descriptor_image[cmd_idx*PAGE_BYTES+i] ||
              u_port_out1.u_mem.mem[i] !== expected_out1[cmd_idx*PAGE_BYTES+i])
            $fatal(1,"Q8_SCORER_DESCRIPTOR_OR_OUTPUT cmd=%0d byte=%0d",cmd_idx,i);
        end
        for (int i=0;i<16*PAGE_BYTES;i++)
          if (u_port_out0.u_mem.mem[i] !==
              expected_out0[cmd_idx*16*PAGE_BYTES+i])
            $fatal(1,"Q8_SCORER_OUT0 cmd=%0d byte=%0d",cmd_idx,i);
        for (int i=0;i<524288;i++)
          if (u_port_w_q0.u_mem.mem[i] !== init_w_q0[i] ||
              u_port_w_q1.u_mem.mem[i] !== init_w_q1[i])
            $fatal(1,"Q8_SCORER_MODEL_Q_MUTATED cmd=%0d byte=%0d",cmd_idx,i);
        for (int i=0;i<65536;i++)
          if (u_port_w_scale.u_mem.mem[i] !== init_w_scale[i] ||
              u_port_activation.u_mem.mem[i] !== init_activation[i])
            $fatal(1,"Q8_SCORER_MODEL_ACT_OR_GUARD cmd=%0d byte=%0d",cmd_idx,i);
        for (int i=0;i<3*PAGE_BYTES;i++)
          if (u_port_aux.u_mem.mem[i] !== init_aux[i])
            $fatal(1,"Q8_SCORER_AUX_MUTATED cmd=%0d byte=%0d",cmd_idx,i);
        for (int i=0;i<OBS_BYTES;i++)
          if (u_port_observed.u_mem.mem[i] !== expected_observed[cmd_idx*OBS_BYTES+i])
            $fatal(1,"Q8_SCORER_OBSERVED cmd=%0d byte=%0d got=%h expected=%h",
                   cmd_idx,i,u_port_observed.u_mem.mem[i],
                   expected_observed[cmd_idx*OBS_BYTES+i]);
        for (int p=0;p<9;p++) begin
          if (dut_aw_count[p]!==ram_aw_count[p] || dut_w_count[p]!==ram_w_count[p] ||
              dut_b_count[p]!==ram_b_count[p] || dut_ar_count[p]!==ram_ar_count[p] ||
              dut_r_count[p]!==ram_r_count[p] ||
              dut_rlast_count[p]!==ram_rlast_count[p] ||
              dut_read_bus_bytes[p]!==ram_read_bus_bytes[p] ||
              dut_write_bus_bytes[p]!==ram_write_bus_bytes[p] ||
              dut_write_useful_bytes[p]!==ram_write_useful_bytes[p])
            $fatal(1,"Q8_SCORER_ADAPTER_MISMATCH cmd=%0d port=%0d",cmd_idx,p);
          if (p==6 || p==7 || p==8) begin
            delta=dut_write_useful_bytes[p]-before_useful[p];
            if (wanted_bytes(p,cmd_idx)==0 && dut_aw_count[p]!=before_aw[p])
              $fatal(1,"Q8_SCORER_UNEXPECTED_WRITE cmd=%0d port=%0d",cmd_idx,p);
          end else begin
            delta=dut_read_bus_bytes[p]-before_read[p];
            if (wanted_bytes(p,cmd_idx)==0 && dut_ar_count[p]!=before_ar[p])
              $fatal(1,"Q8_SCORER_UNEXPECTED_READ cmd=%0d port=%0d",cmd_idx,p);
          end
          if (delta !== wanted_bytes(p,cmd_idx))
            $fatal(1,"Q8_SCORER_PORT_BYTE_COUNT cmd=%0d port=%0d got=%0d expected=%0d",
                   cmd_idx,p,delta,wanted_bytes(p,cmd_idx));
        end
        observer_dump(cmd_idx);
        $display("Q8_SCORER_COMMAND_PASS cmd=%0d cycles=%0d",cmd_idx,command_cycles);
        running=0;
        cmd_idx=cmd_idx+1;
        if (cmd_idx==COMMANDS) test_state<=FINISH;
        else test_state<=CASE_LOAD;
      end
      FINISH: begin
        $display("Q8_SCORER_DISTINCT_ROWS3_PASS commands=3 rows=3 K=1024 N=1024 total_clocks=%0d",total_cycles);
        $fclose(progress_fd);
        $finish;
      end
      default: $fatal(1,"Q8_SCORER_BAD_TB_STATE");
    endcase
  end
