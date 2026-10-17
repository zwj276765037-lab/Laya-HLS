  localparam int MAX_COMMANDS = 24;
  localparam int PAGE_BYTES = 4096;
  localparam int OBS_BYTES = 32*PAGE_BYTES;
  logic [7:0] init_descriptor [0:4095], init_w_q0 [0:4095];
  logic [7:0] init_w_q1 [0:4095], init_w_scale [0:4095];
  logic [7:0] init_aux [0:8191], init_activation [0:4095];
  logic [7:0] init_out0 [0:4095], init_out1 [0:4095];
  logic [7:0] init_observed [0:OBS_BYTES-1];
  logic [7:0] descriptor_image [0:MAX_COMMANDS*PAGE_BYTES-1];
  logic [7:0] expected_header [0:MAX_COMMANDS*1024-1];
  logic [7:0] expected_observed [0:MAX_COMMANDS*OBS_BYTES-1];
  logic [7:0] expected_out0 [0:MAX_COMMANDS*PAGE_BYTES-1];
  logic [7:0] expected_out1 [0:MAX_COMMANDS*PAGE_BYTES-1];
  logic [7:0] activation_image [0:MAX_COMMANDS*PAGE_BYTES-1];
  logic [7:0] aux0_image [0:MAX_COMMANDS*PAGE_BYTES-1];
  logic [7:0] aux1_image [0:MAX_COMMANDS*PAGE_BYTES-1];
  logic [7:0] scale_image [0:MAX_COMMANDS*PAGE_BYTES-1];
  logic [63:0] expected_useful [0:MAX_COMMANDS*9-1];
  logic [7:0] warm_reset_before [0:MAX_COMMANDS-1];
  logic [63:0] pointer_base [0:8];
  logic [6:0] pointer_offset [0:8];
  integer mode_code, command_count;
  integer cmd_idx, ptr_idx, reset_left, total_cycles, command_cycles;
  logic running, seen_done;
  logic [7:0] reset_sample [0:3];
  logic [63:0] before_read [0:8], before_useful [0:8];
  logic [31:0] before_aw [0:8], before_ar [0:8];
  logic [31:0] before_r [0:8], before_b [0:8];
  logic [31:0] r_special_count=0, b_special_count=0;
  logic [31:0] before_r_special, before_b_special;
  logic sampled_ap_done=0;
  logic r_hold_reg=0,b_hold_reg=0;
  logic [31:0] r_selected_index=0,b_selected_index=0;
  logic [14:0] wq_written_addr [0:15];
  logic [8:0] aq_written_addr [0:15];
  logic [12:0] fp_written_addr [0:15];
  integer wq_nonzero_writes=0, aq_nonzero_writes=0, fp_nonzero_writes=0;
  logic [14:0] wq_retained_addr;
  logic [8:0] aq_retained_addr;
  logic [12:0] fp_retained_addr;
  logic [255:0] wq_retained_data, aq_retained_data;
  logic [31:0] fp_retained_data;
  typedef enum logic [4:0] {
    BOOT, COLD_RESET, PTR_ZERO, PTR_ZERO_WAIT, PTR_WRITE,
    PTR_WRITE_WAIT, PTR_READBACK, PTR_READBACK_WAIT,
    CASE_LOAD, CASE_START, CASE_START_WAIT, CASE_WAIT_DONE,
    CSR_READ, CSR_READ_WAIT, CASE_CHECK, RESET_SAMPLE,
    RESET_LOW, FINISH
  } test_state_t;
  test_state_t test_state=BOOT;

  initial begin
    if (!$value$plusargs("MODE=%d",mode_code) ||
        !$value$plusargs("CASE_COUNT=%d",command_count))
      $fatal(1,"Q8_STATIC_MISSING_MODE");
    if (!((mode_code==0 && command_count==9) ||
          (mode_code==1 && command_count==3) ||
          (mode_code==2 && command_count==24)))
      $fatal(1,"Q8_STATIC_MODE_COUNT_MISMATCH mode=%0d count=%0d",
             mode_code,command_count);
    pointer_base[0]=64'h0000001000000000;
    pointer_base[1]=64'h0000001100000000;
    pointer_base[2]=64'h0000001200000000;
    pointer_base[3]=64'h0000001300000000;
    pointer_base[4]=64'h0000001400000000;
    pointer_base[5]=64'h0000001500000000;
    pointer_base[6]=64'h0000001600000000;
    pointer_base[7]=64'h0000001700000000;
    pointer_base[8]=64'h0000001800000000;
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
    $readmemh("expected_header.memh",expected_header);
    $readmemh("expected_observed.memh",expected_observed);
    $readmemh("expected_out0.memh",expected_out0);
    $readmemh("expected_out1.memh",expected_out1);
    $readmemh("activation.memh",activation_image);
    $readmemh("aux0.memh",aux0_image);
    $readmemh("aux1.memh",aux1_image);
    $readmemh("scale.memh",scale_image);
    $readmemh("expected_useful.memh",expected_useful);
    $readmemh("warm_reset.memh",warm_reset_before);
    cmd_idx=0;
    ptr_idx=0;
    reset_left=0;
    total_cycles=0;
    command_cycles=0;
    running=0;
    seen_done=0;
    lite_cmd_valid_0=0;
    lite_cmd_valid_1=0;
    lite_cmd_write_0=0;
    lite_cmd_write_1=0;
    lite_cmd_addr_0=0;
    lite_cmd_addr_1=0;
    lite_cmd_wdata_0=0;
    lite_cmd_wdata_1=0;
  end

  for (genvar p=0; p<9; p++) begin : hold_controls
    if (p==5) assign hold_final_r[p]=r_hold_reg;
    else assign hold_final_r[p]=1'b0;
    if (p==6) assign hold_final_b[p]=b_hold_reg;
    else assign hold_final_b[p]=1'b0;
  end
  always @(posedge clk) begin
    if (!resetn) begin
      r_special_count <= 0;
      b_special_count <= 0;
      sampled_ap_done <= 0;
    end else begin
      sampled_ap_done <= dut.ap_done;
      if (r_hold_applied[5]) begin
        if (r_special_wait_cycles[5]<16)
          $fatal(1,"Q8_STATIC_R_HOLD_TOO_SHORT cycles=%0d",r_special_wait_cycles[5]);
        r_special_count <= r_special_count+1;
      end
      if (b_hold_applied[6]) begin
        if (b_special_wait_cycles[6]<16)
          $fatal(1,"Q8_STATIC_B_HOLD_TOO_SHORT cycles=%0d",b_special_wait_cycles[6]);
        b_special_count <= b_special_count+1;
      end
    end
  end
  // These are read-only taps on actual generated write ports.  Candidate
  // addresses are selected only from successful nonzero RAM write events.
  // The RAM contents themselves are sampled later, before warm reset.
  always @(posedge clk) begin
    if (!resetn) begin
      wq_nonzero_writes<=0;
      aq_nonzero_writes<=0;
      fp_nonzero_writes<=0;
    end else begin
      if (dut.wq_U.ce1 && dut.wq_U.we1 &&
          !$isunknown(dut.wq_U.d1) && dut.wq_U.d1!=0) begin
        wq_written_addr[wq_nonzero_writes%16]<=dut.wq_U.address1;
        wq_nonzero_writes<=wq_nonzero_writes+1;
      end
      if (dut.aq_U.ce1 && dut.aq_U.we1 &&
          !$isunknown(dut.aq_U.d1) && dut.aq_U.d1!=0) begin
        aq_written_addr[aq_nonzero_writes%16]<=dut.aq_U.address1;
        aq_nonzero_writes<=aq_nonzero_writes+1;
      end
      if (dut.fp_U.ce1 && dut.fp_U.we1 &&
          !$isunknown(dut.fp_U.d1) && dut.fp_U.d1!=0) begin
        fp_written_addr[fp_nonzero_writes%16]<=dut.fp_U.address1;
        fp_nonzero_writes<=fp_nonzero_writes+1;
      end
    end
  end

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

  // All testbench controls and backing-memory mutations are negedge-only.
  // The monitor/adapter/endpoint sample wire handshakes on posedge.
  always @(negedge clk) begin : test_sequence
    logic [31:0] expected_pointer_word;
    logic [63:0] delta;
    if (total_cycles>=250000)
      $fatal(1,"Q8_STATIC_TOTAL_CLOCK_BOUND mode=%0d",mode_code);
    total_cycles=total_cycles+1;
    // Freeze the special-beat choice a half-cycle before the adapter samples
    // it.  ram_* counters are stable after the preceding positive edge.
    if (!resetn) begin
      r_hold_reg<=0;
      b_hold_reg<=0;
    end else begin
      r_hold_reg <= mode_code==0 && cmd_idx==3 && running &&
          r_special_count==before_r_special &&
          ram_r_count[5]-before_r[5]==15 &&
          ram_read_bus_bytes[5]-before_read[5]==64'd960 &&
          u_port_activation.e_rvalid && u_port_activation.e_rlast;
      b_hold_reg <= mode_code==0 && cmd_idx==3 && running &&
          b_special_count==before_b_special &&
          ram_write_useful_bytes[6]-before_useful[6]==64'd8 &&
          ram_aw_count[6]-ram_b_count[6]==1 &&
          u_port_out0.e_bvalid;
      if (mode_code==0 && cmd_idx==3 && running &&
          ram_r_count[5]-before_r[5]==15 &&
          ram_read_bus_bytes[5]-before_read[5]==64'd960 &&
          u_port_activation.e_rvalid && u_port_activation.e_rlast &&
          r_selected_index==0)
        r_selected_index=16;
      if (mode_code==0 && cmd_idx==3 && running &&
          ram_write_useful_bytes[6]-before_useful[6]==64'd8 &&
          ram_aw_count[6]-ram_b_count[6]==1 &&
          u_port_out0.e_bvalid && b_selected_index==0)
        b_selected_index=ram_b_count[6]-before_b[6]+1;
    end
    if (running) begin
      command_cycles=command_cycles+1;
      if (command_cycles>20000)
        $fatal(1,"Q8_STATIC_COMMAND_CLOCK_BOUND mode=%0d cmd=%0d",mode_code,cmd_idx);
      if ($isunknown(sampled_ap_done))
        $fatal(1,"Q8_STATIC_DONE_UNKNOWN cmd=%0d",cmd_idx);
      if (sampled_ap_done && !seen_done) begin
        if (!buses_drained())
          $fatal(1,"Q8_STATIC_EARLY_DONE_UNRETIRED cmd=%0d",cmd_idx);
        seen_done=1;
      end
    end
    lite_cmd_valid_0<=0;
    lite_cmd_valid_1<=0;
    case (test_state)
      BOOT: begin
        for (int i=0;i<4096;i++) begin
          u_port_descriptor.u_mem.mem[i]=init_descriptor[i];
          u_port_w_q0.u_mem.mem[i]=init_w_q0[i];
          u_port_w_q1.u_mem.mem[i]=init_w_q1[i];
          u_port_w_scale.u_mem.mem[i]=init_w_scale[i];
          u_port_activation.u_mem.mem[i]=init_activation[i];
          u_port_out0.u_mem.mem[i]=init_out0[i];
          u_port_out1.u_mem.mem[i]=init_out1[i];
        end
        for (int i=0;i<8192;i++) u_port_aux.u_mem.mem[i]=init_aux[i];
        for (int i=0;i<OBS_BYTES;i++)
          u_port_observed.u_mem.mem[i]=init_observed[i];
        reset_left=5;
        test_state<=COLD_RESET;
      end
      COLD_RESET: begin
        if (reset_left==0) begin
          resetn<=1;
          ptr_idx=0;
          test_state<=PTR_ZERO;
        end else reset_left=reset_left-1;
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
          $fatal(1,"Q8_STATIC_POINTER_NOT_RESET index=%0d got=%h",
                 ptr_idx,lite_cmd_rdata_1);
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
          $fatal(1,"Q8_STATIC_POINTER_READBACK index=%0d got=%h expected=%h",
                 ptr_idx,lite_cmd_rdata_1,expected_pointer_word);
        if (ptr_idx==17) test_state<=CASE_LOAD;
        else begin ptr_idx=ptr_idx+1; test_state<=PTR_READBACK; end
      end
      CASE_LOAD: begin
        if (!buses_drained())
          $fatal(1,"Q8_STATIC_MUTATE_WITH_ACTIVE_AXI cmd=%0d",cmd_idx);
        for (int i=0;i<PAGE_BYTES;i++) begin
          u_port_descriptor.u_mem.mem[i]=descriptor_image[cmd_idx*PAGE_BYTES+i];
          u_port_activation.u_mem.mem[i]=activation_image[cmd_idx*PAGE_BYTES+i];
          u_port_w_scale.u_mem.mem[i]=scale_image[cmd_idx*PAGE_BYTES+i];
          u_port_aux.u_mem.mem[i]=aux0_image[cmd_idx*PAGE_BYTES+i];
          u_port_aux.u_mem.mem[PAGE_BYTES+i]=aux1_image[cmd_idx*PAGE_BYTES+i];
          u_port_out0.u_mem.mem[i]=init_out0[i];
          u_port_out1.u_mem.mem[i]=init_out1[i];
        end
        for (int i=0;i<OBS_BYTES;i++)
          u_port_observed.u_mem.mem[i]=init_observed[i];
        for (int p=0;p<9;p++) begin
          before_read[p]=dut_read_bus_bytes[p];
          before_useful[p]=dut_write_useful_bytes[p];
          before_aw[p]=dut_aw_count[p];
          before_ar[p]=dut_ar_count[p];
          before_r[p]=ram_r_count[p];
          before_b[p]=ram_b_count[p];
        end
        before_r_special=r_special_count;
        before_b_special=b_special_count;
        r_selected_index=0;
        b_selected_index=0;
        command_cycles=0;
        test_state<=CASE_START;
      end
      CASE_START: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=1;
        lite_cmd_addr_0<=4'h0;
        lite_cmd_wdata_0<=32'h1;
        lite_cmd_valid_0<=1;
        running=1;
        seen_done=0;
        test_state<=CASE_START_WAIT;
      end
      CASE_START_WAIT: if (lite_cmd_done_0) test_state<=CASE_WAIT_DONE;
      CASE_WAIT_DONE: if (seen_done) test_state<=CSR_READ;
      CSR_READ: if (lite_cmd_ready_0) begin
        lite_cmd_write_0<=0;
        lite_cmd_addr_0<=4'h0;
        lite_cmd_wdata_0<=0;
        lite_cmd_valid_0<=1;
        test_state<=CSR_READ_WAIT;
      end
      CSR_READ_WAIT: if (lite_cmd_done_0) begin
        if (lite_cmd_rdata_0[2:1] !== 2'b11)
          $fatal(1,"Q8_STATIC_CSR_DONE_IDLE cmd=%0d csr=%h",
                 cmd_idx,lite_cmd_rdata_0);
        test_state<=CASE_CHECK;
      end
      CASE_CHECK: begin
        if (!buses_drained())
          $fatal(1,"Q8_STATIC_CHECK_WITH_ACTIVE_AXI cmd=%0d",cmd_idx);
        for (int i=0;i<PAGE_BYTES;i++) begin
          if (u_port_descriptor.u_mem.mem[i] !== descriptor_image[cmd_idx*PAGE_BYTES+i] ||
              u_port_w_q0.u_mem.mem[i] !== init_w_q0[i] ||
              u_port_w_q1.u_mem.mem[i] !== init_w_q1[i] ||
              u_port_w_scale.u_mem.mem[i] !== scale_image[cmd_idx*PAGE_BYTES+i] ||
              u_port_aux.u_mem.mem[i] !== aux0_image[cmd_idx*PAGE_BYTES+i] ||
              u_port_aux.u_mem.mem[PAGE_BYTES+i] !== aux1_image[cmd_idx*PAGE_BYTES+i] ||
              u_port_activation.u_mem.mem[i] !== activation_image[cmd_idx*PAGE_BYTES+i])
            $fatal(1,"Q8_STATIC_INPUT_PAGE_CHANGED cmd=%0d byte=%0d",cmd_idx,i);
        end
        for (int i=0;i<1024;i++)
          if (u_port_observed.u_mem.mem[i] !== expected_header[cmd_idx*1024+i])
            $fatal(1,"Q8_STATIC_HEADER_MISMATCH cmd=%0d byte=%0d got=%h expected=%h",
                   cmd_idx,i,u_port_observed.u_mem.mem[i],expected_header[cmd_idx*1024+i]);
        for (int i=0;i<OBS_BYTES;i++)
          if (u_port_observed.u_mem.mem[i] !==
              expected_observed[cmd_idx*OBS_BYTES+i])
            $fatal(1,"Q8_STATIC_OBSERVED_MISMATCH cmd=%0d byte=%0d got=%h expected=%h",
                   cmd_idx,i,u_port_observed.u_mem.mem[i],
                   expected_observed[cmd_idx*OBS_BYTES+i]);
        for (int i=0;i<PAGE_BYTES;i++) begin
          if (u_port_out0.u_mem.mem[i] !== expected_out0[cmd_idx*PAGE_BYTES+i])
            $fatal(1,"Q8_STATIC_OUT0_MISMATCH cmd=%0d byte=%0d",cmd_idx,i);
          if (u_port_out1.u_mem.mem[i] !== expected_out1[cmd_idx*PAGE_BYTES+i])
            $fatal(1,"Q8_STATIC_OUT1_MISMATCH cmd=%0d byte=%0d",cmd_idx,i);
        end
        for (int p=0;p<9;p++) begin
          if (dut_aw_count[p]!==ram_aw_count[p] ||
              dut_w_count[p]!==ram_w_count[p] ||
              dut_b_count[p]!==ram_b_count[p] ||
              dut_ar_count[p]!==ram_ar_count[p] ||
              dut_r_count[p]!==ram_r_count[p] ||
              dut_rlast_count[p]!==ram_rlast_count[p] ||
              dut_read_bus_bytes[p]!==ram_read_bus_bytes[p] ||
              dut_write_bus_bytes[p]!==ram_write_bus_bytes[p] ||
              dut_write_useful_bytes[p]!==ram_write_useful_bytes[p])
            $fatal(1,"Q8_STATIC_ADAPTER_MISMATCH cmd=%0d port=%0d",cmd_idx,p);
          if (p==6 || p==7 || p==8) begin
            delta=dut_write_useful_bytes[p]-before_useful[p];
            if (expected_useful[cmd_idx*9+p]==0 &&
                dut_aw_count[p]!=before_aw[p])
              $fatal(1,"Q8_STATIC_UNEXPECTED_WRITE cmd=%0d port=%0d",cmd_idx,p);
          end else begin
            delta=dut_read_bus_bytes[p]-before_read[p];
            if (expected_useful[cmd_idx*9+p]==0 &&
                dut_ar_count[p]!=before_ar[p])
              $fatal(1,"Q8_STATIC_UNEXPECTED_READ cmd=%0d port=%0d",cmd_idx,p);
          end
          if (delta !== expected_useful[cmd_idx*9+p])
            $fatal(1,"Q8_STATIC_PORT_BYTE_COUNT cmd=%0d port=%0d got=%0d expected=%0d",
                   cmd_idx,p,delta,expected_useful[cmd_idx*9+p]);
        end
        if (mode_code==0 && cmd_idx==3 &&
            (r_special_count-before_r_special!=1 ||
             b_special_count-before_b_special!=1 ||
             r_selected_index!=16 ||
             b_selected_index!=(ram_b_count[6]-before_b[6])))
          $fatal(1,"Q8_STATIC_SPECIAL_HOLD_MISSING r=%0d b=%0d r_index=%0d b_index=%0d",
                 r_special_count-before_r_special,b_special_count-before_b_special,
                 r_selected_index,b_selected_index);
        if (mode_code==0 && cmd_idx==3)
          $display("Q8_STATIC_SPECIAL_HOLD_EVIDENCE r_index=%0d r_wait=%0d b_index=%0d b_wait=%0d",
                   r_selected_index,r_special_wait_cycles[5],
                   b_selected_index,b_special_wait_cycles[6]);
        $display("Q8_STATIC_COMMAND_PASS mode=%0d cmd=%0d cycles=%0d",
                 mode_code,cmd_idx,command_cycles);
        running=0;
        cmd_idx=cmd_idx+1;
        if (cmd_idx==command_count) test_state<=FINISH;
        else if (warm_reset_before[cmd_idx]!==0) test_state<=RESET_SAMPLE;
        else test_state<=CASE_LOAD;
      end
      RESET_SAMPLE: begin
        if (!buses_drained()) $fatal(1,"Q8_STATIC_WARM_RESET_ACTIVE_AXI");
        if (wq_nonzero_writes==0 || aq_nonzero_writes==0 || fp_nonzero_writes==0)
          $fatal(1,"Q8_STATIC_INTERNAL_WRITE_PROVENANCE_MISSING wq=%0d aq=%0d fp=%0d",
                 wq_nonzero_writes,aq_nonzero_writes,fp_nonzero_writes);
        wq_retained_data='0;
        aq_retained_data='0;
        fp_retained_data='0;
        for (int j=0;j<16;j++) begin
          if (j<wq_nonzero_writes && wq_retained_data=='0 &&
              !$isunknown(dut.wq_U.ram[wq_written_addr[j]]) &&
              dut.wq_U.ram[wq_written_addr[j]]!='0) begin
            wq_retained_addr=wq_written_addr[j];
            wq_retained_data=dut.wq_U.ram[wq_written_addr[j]];
          end
          if (j<aq_nonzero_writes && aq_retained_data=='0 &&
              !$isunknown(dut.aq_U.ram[aq_written_addr[j]]) &&
              dut.aq_U.ram[aq_written_addr[j]]!='0) begin
            aq_retained_addr=aq_written_addr[j];
            aq_retained_data=dut.aq_U.ram[aq_written_addr[j]];
          end
          if (j<fp_nonzero_writes && fp_retained_data=='0 &&
              !$isunknown(dut.fp_U.ram[fp_written_addr[j]]) &&
              dut.fp_U.ram[fp_written_addr[j]]!='0) begin
            fp_retained_addr=fp_written_addr[j];
            fp_retained_data=dut.fp_U.ram[fp_written_addr[j]];
          end
        end
        if (wq_retained_data=='0 || aq_retained_data=='0 || fp_retained_data=='0)
          $fatal(1,"Q8_STATIC_INTERNAL_NONZERO_SAMPLE_MISSING");
        reset_sample[0]=u_port_observed.u_mem.mem[0];
        reset_sample[1]=u_port_observed.u_mem.mem[4];
        reset_sample[2]=u_port_observed.u_mem.mem[511];
        reset_sample[3]=u_port_observed.u_mem.mem[1023];
        resetn<=0;
        reset_left=5;
        test_state<=RESET_LOW;
      end
      RESET_LOW: begin
        if (reset_left==0) begin
          if (dut.wq_U.ram[wq_retained_addr] !== wq_retained_data ||
              dut.aq_U.ram[aq_retained_addr] !== aq_retained_data ||
              dut.fp_U.ram[fp_retained_addr] !== fp_retained_data)
            $fatal(1,"Q8_STATIC_WARM_RESET_CLEARED_INTERNAL_PAYLOAD");
          if (u_port_observed.u_mem.mem[0] !== reset_sample[0] ||
              u_port_observed.u_mem.mem[4] !== reset_sample[1] ||
              u_port_observed.u_mem.mem[511] !== reset_sample[2] ||
              u_port_observed.u_mem.mem[1023] !== reset_sample[3])
            $fatal(1,"Q8_STATIC_WARM_RESET_CLEARED_PAYLOAD");
          $display("Q8_STATIC_WARM_RESET_RETAINED wq_addr=%h wq_data=%h aq_addr=%h aq_data=%h fp_input_addr=%h fp_input_data=%h",
                   wq_retained_addr,wq_retained_data,
                   aq_retained_addr,aq_retained_data,
                   fp_retained_addr,fp_retained_data);
          resetn<=1;
          ptr_idx=0;
          test_state<=PTR_ZERO;
        end else reset_left=reset_left-1;
      end
      FINISH: begin
        if (mode_code==0) $display("Q8_ACT_STATIC_LEGAL_PASS commands=9");
        else if (mode_code==1) $display("Q8_ACT_STATIC_FAULT_LOAD_PASS commands=3");
        else $display("Q8_ACT_STATIC_IDENTITY_RESET_PASS commands=24");
        $finish;
      end
      default: $fatal(1,"Q8_STATIC_BAD_STATE");
    endcase
  end
