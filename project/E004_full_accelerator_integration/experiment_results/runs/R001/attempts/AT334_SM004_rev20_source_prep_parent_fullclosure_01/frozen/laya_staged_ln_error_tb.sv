`timescale 1ns/1ps
module laya_staged_ln_error_tb;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,cmd_valid=0,cmd_ready,cmd_cold=1,cmd_mode=1;
  logic [6:0] cmd_row=0;
  logic result_mode;
  logic [6:0] result_row;
  logic [31:0] cmd_id=0,cmd_w_epoch=1,cmd_down_w_epoch=0;
  logic [15:0] cmd_weight_key=16'h0001,cmd_down_weight_key=0;
  logic [3327:0] cmd_model_identity=0;
  logic [671:0] cmd_numeric_identity=0;
  logic [95:0] cmd_task_context=0;
  logic [1023:0] cmd_expected_aux_header=0,cmd_down_expected_aux_header=0;
  logic [2:0][63:0] cmd_load_base='0,cmd_down_load_base='0;
  logic [2:0][31:0] cmd_load_bytes='0,cmd_down_load_bytes='0;
  logic [63:0] cmd_aux_base=0,cmd_bias_base=0,cmd_down_aux_base=0,cmd_down_bias_base=0;
  logic [31:0] cmd_bias_bytes=0,cmd_down_bias_bytes=0;
  logic x_valid,x_ready,gamma_valid,gamma_ready;
  logic [31:0] x_bits,gamma_bits;
  logic row_valid,rd_valid=0,rd_ready,rsp_valid,rsp_ready=0;
  logic [9:0] rd_tile=0,rsp_tile;
  logic [255:0] rsp_bits;
  logic row_release_valid=0,row_release_ready,done_valid,done_ready=0;
  logic [3:0] done_status,done_phase;
  logic [31:0] done_bad_element,mean_bits,variance_bits,inverse_bits;
  logic [31:0] actual_w_reads,actual_w_returns,actual_stripes,actual_ps_commits;
  logic [2:0][63:0] araddr;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst;
  logic [2:0] arvalid,arready;
  logic [2:0][511:0] rdata;
  logic [2:0][1:0] rresp;
  logic [2:0] rlast,rvalid,rready;
  logic [63:0] aux_araddr;
  logic [7:0] aux_arlen;
  logic [2:0] aux_arsize;
  logic [1:0] aux_arburst;
  logic aux_arvalid,aux_arready;
  logic [127:0] aux_rdata;
  logic [1:0] aux_rresp;
  logic aux_rlast,aux_rvalid,aux_rready;
  logic cmd_tensor_begin=0;
  logic [31:0] cmd_tensor_epoch=1,done_id;
  logic [2:0][31:0] cmd_dst_epoch;
  logic [2:0][63:0] cmd_dst_base,cmd_dst_span;
  logic cmd_source_hidden_bank=0;
  logic tensor_release_valid=0,tensor_release_ready,tensor_release_discard=0;
  logic [31:0] tensor_release_epoch=0,tensor_epoch;
  logic [63:0] tensor_release_request=0,tensor_release_generation=0;
  logic tensor_raw_valid,tensor_failed;
  logic [127:0] row_written;
  logic [63:0] tensor_request,tensor_generation;
  logic [3327:0] tensor_model_identity;
  logic [671:0] tensor_numeric_identity;
  logic [2:0][31:0] tensor_dst_epoch;
  logic [2:0][63:0] tensor_dst_base,tensor_dst_span;
  logic [2:0][63:0] m_axi_awaddr;
  logic [2:0][7:0] m_axi_awlen;
  logic [2:0][2:0] m_axi_awsize;
  logic [2:0][1:0] m_axi_awburst;
  logic [2:0] m_axi_awvalid,m_axi_awready;
  logic [2:0][511:0] m_axi_wdata;
  logic [2:0][63:0] m_axi_wstrb;
  logic [2:0] m_axi_wlast,m_axi_wvalid,m_axi_wready;
  logic [2:0][1:0] m_axi_bresp;
  logic [2:0] m_axi_bvalid,m_axi_bready;
  logic [2:0][31:0] scratch_aw_count,scratch_w_count,scratch_b_count;
  logic [9:0] scratch_rsp_count;
  logic [5:0] scratch_flush_count;
  logic [1:0] scratch_error_dst,scratch_error_bresp;
  logic [31:0] scratch_error_ordinal;
  logic cmd_rope_enable=1;
  logic [63:0] cmd_rope_aux_base=0,cmd_rope_aux_span=64'd1142528;
  logic tensor_rope_enable,tensor_final_valid;
  logic [127:0] row_final;
  logic [2:0][31:0] tensor_final_dst_epoch;
  logic done_rope_check_valid,done_rope_plane;
  logic [127:0] done_rope_check;
  logic [3:0] done_rope_head;
  logic [1:0][63:0] rope_araddr;
  logic [1:0][7:0] rope_arlen;
  logic [1:0][2:0] rope_arsize;
  logic [1:0][1:0] rope_arburst;
  logic [1:0] rope_arvalid,rope_arready,rope_rlast,rope_rvalid,rope_rready;
  logic [1:0][511:0] rope_rdata;
  logic [1:0][1:0] rope_rresp;
  logic cmd_input_from_state0=0;
  logic [63:0] cmd_state0_base=64'h20000000;
  logic [63:0] cmd_state0_span=64'd8388608;
  logic [31:0] cmd_state0_epoch=1;
  logic [63:0] state0_araddr;
  logic [7:0] state0_arlen;
  logic [2:0] state0_arsize;
  logic [1:0] state0_arburst;
  logic state0_arvalid,state0_arready;
  logic [511:0] state0_rdata;
  logic [1:0] state0_rresp;
  logic state0_rlast,state0_rvalid,state0_rready;
  logic cmd_staged_ln=1;
  wire [127:0] norm_written;
  wire norm_stage_ready;
  wire [7:0] done_op;
  wire [15:0] done_check_status;
  wire [31:0] done_detail;
  wire [63:0] done_bad64;
  logic cmd_stage_discard_norm=0;
  wire stage_store_fault;
  laya_qkv_scratch_row_v1 dut(.*);

  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [31:0] raw[0:2047],norm_gold[0:2047],gamma[0:1023];
  logic [31:0] norm_mem[0:2047];
  string fixture,testcase;
  bit bad_raw_last=0,bad_last_b=0;
  logic [31:0] saved_gamma7,saved_raw0;
  int active_row=0,cycle=0,source_ar_count=0,source_r_count=0;
  int gamma_ar_count=0,gamma_r_count=0,b_count=0,norm_total=0;
  int source_beat=0,source_left=0;
  int gamma_beat=0,gamma_left=0;
  bit source_active=0,gamma_active=0,write_aw=0,write_w=0;
  logic [63:0] write_addr=0;
  int b_delay=0;
  always @(posedge clk) if(rst_n) begin
    cycle<=cycle+1;
    if(dut.core.norm_valid)norm_total<=norm_total+1;
    if(cycle%5000==0)
      $display("STAGED_LN_PROGRESS gamma=%0d raw=%0d norm=%0d B=%0d state=%0d core=%0d",
        gamma_r_count,source_r_count,norm_total,
        b_count,dut.state,dut.core.state);
    if(cycle>700000)$fatal(1,"STAGED_LN_TIMEOUT state=%0d row=%0d",dut.state,active_row);
  end

  always_comb begin
    arready='0;rdata='0;rresp='0;rlast='0;rvalid='0;
    aux_arready=!gamma_active;
    aux_rvalid=gamma_active;
    aux_rresp=0;aux_rlast=gamma_left==1;
    aux_rdata=0;
    for(int lane=0;lane<4;lane++)
      aux_rdata[32*lane+:32]=gamma[gamma_beat*4+lane];
    state0_arready=!source_active;
    state0_rvalid=source_active;
    state0_rresp=(bad_raw_last && source_beat==63) ? 2'd2 : 2'd0;
    state0_rlast=source_left==1;
    state0_rdata=0;
    for(int lane=0;lane<16;lane++)
      state0_rdata[32*lane+:32]=raw[active_row*1024+source_beat*16+lane];
    rope_arready='0;rope_rdata='0;rope_rresp='0;
    rope_rlast='0;rope_rvalid='0;
    m_axi_awready='0;m_axi_wready='0;m_axi_bvalid='0;
    m_axi_bresp='0;
    m_axi_bresp[2]=(bad_last_b && b_count==63) ? 2'd2 : 2'd0;
    m_axi_awready[2]=!write_aw;
    m_axi_wready[2]=write_aw && !write_w;
    m_axi_bvalid[2]=write_w && b_delay>=3;
  end
  always @(posedge clk) if(rst_n) begin
    if(|arvalid || |rope_arvalid || |rope_rready ||
       |m_axi_awvalid[1:0] || |m_axi_wvalid[1:0])
      $fatal(1,"STAGED_LN_FORBIDDEN_SERVICE");
    if(state0_arvalid && state0_arready) begin
      if(source_active || state0_araddr != cmd_state0_base+active_row*4096 ||
          state0_arsize!=3'd6 ||
          state0_arburst!=2'd1 || state0_arlen!=8'd63)
        $fatal(1,"STAGED_LN_SOURCE_AR addr=%h len=%0d",state0_araddr,state0_arlen);
      source_active<=1;source_beat<=0;source_left<=64;
      source_ar_count<=source_ar_count+1;
    end
    if(state0_rvalid && state0_rready) begin
      source_r_count<=source_r_count+1;
      if(source_left==1)source_active<=0;
      source_left<=source_left-1;
      source_beat<=source_beat+1;
    end
    if(aux_arvalid && aux_arready) begin
      if(gamma_active || aux_araddr != cmd_rope_aux_base+128+
          (gamma_r_count%256)*16 ||
         aux_arsize!=3'd4 || aux_arburst!=2'd1)
        $fatal(1,"STAGED_LN_GAMMA_AR addr=%h",aux_araddr);
      gamma_active<=1;
      gamma_beat<=gamma_r_count%256;
      gamma_left<=int'(aux_arlen)+1;
      gamma_ar_count<=gamma_ar_count+1;
    end
    if(aux_rvalid && aux_rready) begin
      gamma_r_count<=gamma_r_count+1;
      if(gamma_left==1)gamma_active<=0;
      gamma_left<=gamma_left-1;
      gamma_beat<=gamma_beat+1;
    end
    if(m_axi_awvalid[2] && m_axi_awready[2]) begin
      if(write_aw || m_axi_awaddr[2] != cmd_dst_base[2]+active_row*4096+
          (b_count%64)*64 || m_axi_awlen[2]!=0 ||
          m_axi_awsize[2]!=3'd6 || m_axi_awburst[2]!=2'd1)
        $fatal(1,"STAGED_LN_AW addr=%h b=%0d",m_axi_awaddr[2],b_count);
      write_aw<=1;write_addr<=m_axi_awaddr[2];
    end
    if(m_axi_wvalid[2] && m_axi_wready[2]) begin
      if(!write_aw || m_axi_wstrb[2]!==64'hffff_ffff_ffff_ffff ||
         !m_axi_wlast[2] || write_addr !=
          cmd_dst_base[2]+active_row*4096+(b_count%64)*64)
        $fatal(1,"STAGED_LN_W_PROTOCOL b=%0d",b_count);
      for(int lane=0;lane<16;lane++) begin
        if(m_axi_wdata[2][lane*32+:32]!==norm_gold[active_row*1024+
              (b_count%64)*16+lane])
          $fatal(1,"STAGED_LN_NORM_GOLD row=%0d b=%0d lane=%0d",
                 active_row,b_count,lane);
        norm_mem[active_row*1024+(b_count%64)*16+lane]
          <=m_axi_wdata[2][lane*32+:32];
      end
      write_w<=1;b_delay<=0;
    end
    if(write_w)b_delay<=b_delay+1;
    if(m_axi_bvalid[2] && m_axi_bready[2]) begin
      write_aw<=0;write_w<=0;b_delay<=0;b_count<=b_count+1;
    end
  end

  task automatic run_row(input int row);
    int old_b,old_r;
    active_row=row;old_b=b_count;old_r=source_r_count;
    @(negedge clk);
    cmd_id=32'(81+row);cmd_row=7'(row);cmd_cold=(row==0);
    cmd_tensor_begin=(row==0);
    cmd_task_context={8'd1,16'(row),8'd128,32'h01000001,32'd81};
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"STAGED_LN_CMD_READY row=%0d",row);
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<700000 && !done_valid;guard++)@(negedge clk);
    if(!done_valid || done_status!=0 || done_check_status!=0 ||
       done_op!=8'h10 || done_bad64!=64'hffff_ffff_ffff_ffff ||
       b_count!=old_b+64 || source_r_count!=old_r+64 ||
       !norm_written[row] || row_written!=0 || row_final!=0 ||
       tensor_raw_valid || tensor_final_valid || norm_stage_ready ||
       tensor_failed || x_ready || gamma_ready)
      $fatal(1,"STAGED_LN_ROW_DONE row=%0d status=%0d phase=%0d b=%0d r=%0d norm=%h core=%0d",
        row,done_status,done_phase,b_count-old_b,source_r_count-old_r,
        norm_written,dut.core.state);
    repeat(3)begin
      @(negedge clk);
      if(!done_valid || done_status!=0)$fatal(1,"STAGED_LN_DONE_HOLD");
    end
    done_ready=1;
    @(negedge clk);done_ready=0;
    if(!norm_written[row] || row_written!=0 || row_final!=0 ||
       tensor_raw_valid || tensor_final_valid || norm_stage_ready ||
       tensor_failed)$fatal(1,"STAGED_LN_ROW_RETIRE row=%0d",row);
    $display("STAGED_LN_ROW_PASS row=%0d B=%0d sourceR=%0d cycle=%0d",
             row,b_count-old_b,source_r_count-old_r,cycle);
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"STAGED_LN_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/raw_row0.hex"},raw,0,1023);
    $readmemh({fixture,"/raw_row1.hex"},raw,1024,2047);
    $readmemh({fixture,"/norm_row0.hex"},norm_gold,0,1023);
    $readmemh({fixture,"/norm_row1.hex"},norm_gold,1024,2047);
    $readmemh({fixture,"/gamma.hex"},gamma);
    cmd_model_identity=model_rom[0];
    cmd_numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3};
    cmd_expected_aux_header=header_rom[0];
    cmd_load_base[0]=64'h3800000;cmd_load_base[1]=64'h3800000;
    cmd_load_base[2]=64'h700000;
    cmd_load_bytes[0]=32'd1572864;cmd_load_bytes[1]=32'd1572864;
    cmd_load_bytes[2]=32'd196608;
    cmd_tensor_epoch=1;cmd_dst_epoch='{default:32'd1};
    cmd_dst_base='{default:64'h10000000};
    cmd_dst_span[0]=64'd12582912;cmd_dst_span[1]=64'd12582912;
    cmd_dst_span[2]=64'd8388608;
    cmd_rope_aux_base=64'h40000000;
    cmd_state0_base=64'h20000000;
    cmd_input_from_state0=1;cmd_staged_ln=1;
    x_valid=0;gamma_valid=0;x_bits=0;gamma_bits=0;
    $display("STAGED_LN_SIM_START");
    repeat(5)@(negedge clk);rst_n=1;
    if(!$value$plusargs("CASE=%s",testcase))$fatal(1,"STAGED_LN_ERROR_CASE");
    saved_gamma7=gamma[7];saved_raw0=raw[0];
    if(testcase=="gamma_bad")gamma[7]=32'h7fc00000;
    else if(testcase=="raw_last_rerr")bad_raw_last=1;
    else if(testcase=="last_b_err" || testcase=="last_b_drain")
      bad_last_b=1;
    else if(testcase=="ln_bad")raw[0]=32'h7fc00000;
    else $fatal(1,"STAGED_LN_UNKNOWN_CASE %s",testcase);
    active_row=0;
    @(negedge clk);
    cmd_id=81;cmd_row=0;cmd_cold=1;cmd_tensor_begin=1;
    cmd_task_context={8'd1,16'd0,8'd128,32'h01000001,32'd81};
    cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"STAGED_LN_BAD_CMD_NOT_READY");
    @(negedge clk);cmd_valid=0;
    for(int guard=0;guard<700000 && !done_valid;guard++)@(negedge clk);
    if(!done_valid)$fatal(1,"STAGED_LN_BAD_NO_DONE case=%s state=%0d",testcase,dut.state);
    if(done_op!=8'h10 || done_bad_element!=32'hffffffff && testcase!="ln_bad" ||
       norm_written!=0 || norm_stage_ready || row_written!=0 ||
       row_final!=0 || tensor_final_valid || !tensor_failed ||
       (testcase=="gamma_bad" &&
          (done_status!=6 || done_phase!=14 || done_check_status!=6 ||
           done_detail!=32'h0710_000f || done_bad64!='1 ||
           source_r_count!=0 || b_count!=0 || gamma_r_count!=256)) ||
       (testcase=="raw_last_rerr" &&
          (done_status!=7 || done_phase!=14 || done_check_status!=7 ||
           done_detail!=32'h0710_0005 || done_bad64!='1 ||
           source_r_count!=64 || b_count!=0 || gamma_r_count!=256)) ||
       ((testcase=="last_b_err" || testcase=="last_b_drain") &&
          (done_status!=7 || done_phase!=12 || done_check_status!=7 ||
           done_detail!=32'h0710_0005 || done_bad64!='1 ||
           source_r_count!=64 || b_count!=64 || gamma_r_count!=256)) ||
       (testcase=="ln_bad" &&
          (done_status!=6 || done_phase!=14 || done_check_status!=6 ||
           done_detail!=32'h0710_000f || done_bad64!=0 ||
           source_r_count!=64 || b_count!=0 || gamma_r_count!=256)))
      $fatal(1,"STAGED_LN_BAD_DIAG case=%s status=%0d phase=%0d op=%h check=%0d detail=%h bad64=%h source=%0d gamma=%0d B=%0d",
        testcase,done_status,done_phase,done_op,done_check_status,done_detail,
        done_bad64,source_r_count,gamma_r_count,b_count);
    repeat(3)begin
      @(negedge clk);
      if(!done_valid)$fatal(1,"STAGED_LN_BAD_DONE_HOLD case=%s",testcase);
    end
    done_ready=1;
    @(negedge clk);done_ready=0;
    if(!tensor_failed || norm_written!=0)$fatal(1,"STAGED_LN_BAD_NOT_STICKY");
    gamma[7]=saved_gamma7;raw[0]=saved_raw0;
    bad_raw_last=0;bad_last_b=0;
    if(testcase=="last_b_drain")begin
      if(!stage_store_fault)$fatal(1,"STAGED_LN_STORE_FAULT_TOKEN_MISSING");
      active_row=1;
      @(negedge clk);
      cmd_id=82;cmd_row=1;cmd_tensor_begin=0;
      cmd_stage_discard_norm=1;
      cmd_task_context={8'd1,16'd1,8'd128,32'h01000001,32'd81};
      cmd_valid=1;
      #1ps;if(!cmd_ready)$fatal(1,"STAGED_LN_DRAIN_CMD_NOT_READY");
      @(negedge clk);cmd_valid=0;
      for(int guard=0;guard<700000 && !done_valid;guard++)@(negedge clk);
      if(!done_valid || done_status!=0 || done_check_status!=0 ||
         done_op!=8'h10 || done_bad64!='1 || !stage_store_fault ||
         norm_written!=0 || !tensor_failed || b_count!=64 ||
         source_r_count!=128 || gamma_r_count!=256 || norm_total!=2048)
        $fatal(1,"STAGED_LN_DRAIN_ROW_BAD status=%0d B=%0d sourceR=%0d norm=%0d",
          done_status,b_count,source_r_count,norm_total);
      done_ready=1;
      @(negedge clk);done_ready=0;
      cmd_stage_discard_norm=0;
      $display("STAGED_LN_STORE_DRAIN_ROW_PASS row=1 B_still=64 norm=2048");
    end
    tensor_release_epoch=1;
    tensor_release_request=tensor_request;
    tensor_release_generation=tensor_generation;
    tensor_release_discard=1;tensor_release_valid=1;
    #1ps;if(!tensor_release_ready)
      $fatal(1,"STAGED_LN_DISCARD_NOT_READY case=%s token=%b gamma=%b core_ready=%b",
        testcase,dut.core_prep_token_valid,dut.core_gamma_token_valid,
        dut.core_cmd_ready);
    @(negedge clk);tensor_release_valid=0;tensor_release_discard=0;
    if(tensor_failed || norm_written!=0 || dut.tensor_active ||
       dut.last_released_epoch!=2)
      $fatal(1,"STAGED_LN_DISCARD_FAILED case=%s epoch=%0d",testcase,
        dut.last_released_epoch);
    cmd_tensor_epoch=3;cmd_state0_epoch=3;
    cmd_dst_epoch='{default:32'd3};
    run_row(0);
    if(b_count!=((testcase=="last_b_err" ||
                  testcase=="last_b_drain") ? 128 : 64) ||
       source_r_count!=(testcase=="gamma_bad" ? 64 :
                        (testcase=="last_b_drain" ? 192 : 128)) ||
       gamma_r_count!=512 || !norm_written[0] || tensor_failed)
      $fatal(1,"STAGED_LN_RECOVERY_COUNTS case=%s B=%0d R=%0d G=%0d",
        testcase,b_count,source_r_count,gamma_r_count);
    for(int i=0;i<1024;i++)
      if(norm_mem[i]!==norm_gold[i])
        $fatal(1,"STAGED_LN_RECOVERY_GOLD case=%s idx=%0d",testcase,i);
    $display("STAGED_LN_ERROR_RECOVERY_PASS case=%s bad_status=%0d recovery_B=64",
             testcase,testcase=="gamma_bad" || testcase=="ln_bad" ? 6 : 7);
    $finish;
  end
endmodule
