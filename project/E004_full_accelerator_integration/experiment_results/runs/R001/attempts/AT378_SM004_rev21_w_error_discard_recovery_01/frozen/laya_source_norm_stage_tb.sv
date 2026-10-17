`timescale 1ns/1ps
module laya_source_norm_stage_tb;
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
  wire [31:0] request_done_id;
  wire [6:0] request_done_row;
  wire request_done_rope_check_valid, request_done_rope_plane;
  wire [127:0] request_done_rope_check;
  wire [3:0] request_done_rope_head;
  int active_row;
  laya_lnq_bank_link_v1 bank_link();
  wire [7:0] stage_retired_rows;
  wire stage_result_valid;
  wire [3:0] stage_result_status;
  assign done_valid=1'b0;
  assign tensor_final_valid=1'b0;
  assign tensor_raw_valid=1'b0;
  assign tensor_failed=1'b0;
  assign row_written='0;
  assign row_final='0;
  // Idle fixed clients; the production service drives all staged bank ports.
  assign bank_link.bank_idle=1'b1;
  assign bank_link.prep_begin_allow=1'b1;
  assign bank_link.ln_cmd_valid='0;
  assign bank_link.ln_source_mode='0;
  assign bank_link.ln_gamma_kind='0;
  assign bank_link.ln_cmd_row='0;
  assign bank_link.ln_only_ready='0;
  assign bank_link.staged_ln_cmd_valid='0;
  assign bank_link.staged_ln_row='0;
  assign bank_link.staged_ln_rd_valid='0;
  assign bank_link.staged_ln_rd_tile='0;
  assign bank_link.staged_ln_release_valid='0;
  assign bank_link.staged_ln_release_discard='0;
  assign bank_link.staged_ln_done_ready='0;
  assign bank_link.ln_x_valid='0;
  assign bank_link.ln_x_bits='0;
  assign bank_link.ln_gamma_valid='0;
  assign bank_link.ln_gamma_bits='0;
  assign bank_link.ln_rd_valid='0;
  assign bank_link.ln_rd_group='0;
  assign bank_link.ln_rsp_ready='0;
  assign bank_link.ln_release_valid='0;
  assign bank_link.ln_done_ready='0;
  assign bank_link.q16_fill_cmd_valid='0;
  assign bank_link.q16_fill_done_ready='0;
  assign bank_link.q16_retire_success='0;
  assign bank_link.q16_window_begin='0;
  assign bank_link.q16_row='0;
  assign bank_link.q16_epoch='0;
  assign bank_link.q16_model='0;
  assign bank_link.q16_numeric='0;
  assign bank_link.a_window_release_valid='0;
  assign bank_link.a_window_discard='0;
  assign bank_link.prep_begin_idle='0;
  assign bank_link.prep_begin_valid='0;
  assign bank_link.prep_kind='0;
  assign bank_link.prep_id='0;
  assign bank_link.prep_row='0;
  assign bank_link.prep_epoch='0;
  assign bank_link.prep_model_identity='0;
  assign bank_link.prep_numeric_identity='0;
  assign bank_link.prep_gamma_aux_base='0;
  assign bank_link.prep_gamma_aux_span='0;
  assign bank_link.prep_write_valid='0;
  assign bank_link.prep_write_index='0;
  assign bank_link.prep_write_bits='0;
  assign bank_link.prep_commit_valid='0;
  assign bank_link.prep_abort_valid='0;
  assign bank_link.prep_consume='0;
  assign bank_link.match_id='0;
  assign bank_link.match_row='0;
  assign bank_link.match_epoch='0;
  assign bank_link.match_model_identity='0;
  assign bank_link.match_numeric_identity='0;
  assign bank_link.match_kind='0;
  assign bank_link.match_gamma_aux_base='0;
  assign bank_link.match_gamma_aux_span='0;
  assign bank_link.norm_store_valid='0;
  assign bank_link.norm_store_index='0;
  assign bank_link.norm_store_bits='0;
  assign bank_link.ps_store_valid='0;
  assign bank_link.ps_store_tile='0;
  assign bank_link.ps_store_bits='0;
  assign bank_link.g_store_valid='0;
  assign bank_link.g_store_index='0;
  assign bank_link.g_store_bits='0;
  assign bank_link.res_store_valid='0;
  assign bank_link.res_store_index='0;
  assign bank_link.res_store_bits='0;
  assign bank_link.feed_start='0;
  assign bank_link.feed_active='0;
  assign bank_link.result_reset='0;
  assign bank_link.result_accept='0;
  assign bank_link.result_physical_addr='0;
  assign bank_link.result_logical_tile='0;
  assign bank_link.result_rsp_ready='0;
  assign bank_link.g_x_read_valid='0;
  assign bank_link.g_x_read_tile='0;
  assign bank_link.g_gate_read_valid='0;
  assign bank_link.g_gate_read_tile='0;
  assign bank_link.qd_read_valid='0;
  assign bank_link.qd_read_word='0;
  assign bank_link.res_read_valid='0;
  assign bank_link.res_read_index='0;
  laya_source_norm_service_v1 dut (
    .clk,.rst_n,.bank_link,.reader_cancel(1'b0),
    .stage_input_start(cmd_valid),.stage_input_ready(cmd_ready),
    .stage_input_staged(1'b1),.stage_input_first(1'b1),
    .stage_input_id(cmd_id),.stage_input_epoch(cmd_state0_epoch),
    .stage_input_row(7'd0),.stage_input_model(cmd_model_identity),
    .stage_input_numeric(cmd_numeric_identity),
    .stage_input_source_addr(cmd_state0_base),
    .stage_input_source_span(cmd_state0_span),
    .stage_input_aux_base(cmd_rope_aux_base),
    .stage_input_aux_span(cmd_rope_aux_span),
    .stage_input_dest_base(cmd_dst_base[2]),
    .stage_input_dest_span(cmd_dst_span[2]),
    .stage_input_done_valid(stage_result_valid),
    .stage_input_done_ready(1'b1),
    .stage_input_done_status(stage_result_status),
    .stage_retired_rows(stage_retired_rows),
    .stage_continue_valid(1'b0),.stage_continue_ready(),
    .stage_continue_request(64'd0),.stage_continue_generation(64'd0),
    .stage_continue_norm_epoch(32'd0),
    .stage_continue_next_base_id(32'd0),
    .stage_continue_a_epoch(32'd0),.stage_continue_w_epoch(32'd0),
    .stage_continue_w_key(16'd0),.stage_continue_model('0),
    .stage_continue_numeric('0),.stage_continue_w_header('0),
    .stage_continue_w_base('0),.stage_continue_w_bytes('0),
    .stage_continue_w_aux_base(64'd0),
    .stage_continue_w_bias_base(64'd0),
    .stage_continue_w_bias_bytes(32'd0),
    .stage_w_valid(),.stage_w_ready(1'b0),
    .stage_w_id(),.stage_w_source_epoch(),.stage_w_epoch(),
    .stage_w_request(),.stage_w_generation(),.stage_w_key(),
    .stage_w_model(),.stage_w_numeric(),.stage_w_header(),
    .stage_w_base(),.stage_w_bytes(),.stage_w_aux_base(),
    .stage_w_bias_base(),.stage_w_bias_bytes(),
    .stage_w_done_valid(1'b0),.stage_w_done_ready(),
    .stage_w_done_id(32'd0),.stage_w_done_source_epoch(32'd0),
    .stage_w_done_epoch(32'd0),.stage_w_done_request(64'd0),
    .stage_w_done_generation(64'd0),.stage_w_done_key(16'd0),
    .stage_w_done_model('0),.stage_w_done_numeric('0),
    .stage_w_done_status(4'd0),.stage_w_done_op(8'd0),
    .stage_w_done_check_status(16'd0),
    .stage_w_done_detail(32'd0),.stage_w_done_bad64(64'd0),
    .stage_a16_ready(),.stage_q_retired_rows(),
    .stage_follow_error_valid(),
    .stage_store_start(1'b0),.stage_store_row(7'd0),
    .stage_store_base(64'd0),.stage_store_span(64'd0),
    .stage_store_discard(1'b0),.stage_store_identity_bad(1'b0),
    .stage_store_rd_ready(1'b0),.stage_store_rsp_valid(1'b0),
    .stage_store_rsp_tile(10'd0),.stage_store_rsp_bits(256'd0),
    .stage_store_release_ready(1'b0),.stage_store_done_ready(1'b0),
    .scratch_reader_load_valid(1'b0),
    .scratch_reader_load_base(64'd0),
    .scratch_reader_load_bytes(32'd0),
    .scratch_reader_load_epoch(32'd0),
    .source_load_active(1'b0),.rope_route(2'd0),
    .state0_araddr,.state0_arlen,.state0_arsize,.state0_arburst,
    .state0_arvalid,.state0_arready,.state0_rdata,.state0_rresp,
    .state0_rlast,.state0_rvalid,.state0_rready,
    .state1_araddr(),.state1_arlen(),.state1_arsize(),
    .state1_arburst(),.state1_arvalid(),.state1_arready(1'b0),
    .state1_rdata('0),.state1_rresp(2'b00),
    .state1_rlast(1'b0),.state1_rvalid(1'b0),.state1_rready(),
    .rope_araddr,.rope_arlen,.rope_arsize,.rope_arburst,.rope_arvalid,
    .rope_arready,.rope_rdata,.rope_rresp,.rope_rlast,.rope_rvalid,
    .rope_rready,
    .scratch_reader_out_ready(1'b0),
    .table_reader_load_valid(1'b0),
    .table_reader_load_base(64'd0),
    .table_reader_load_bytes(32'd0),
    .table_reader_load_epoch(32'd0),
    .rope_aux_owner(1'b0),
    .core_aux_araddr(64'd0),.core_aux_arlen(8'd0),
    .core_aux_arsize(3'd0),.core_aux_arburst(2'd0),
    .core_aux_arvalid(1'b0),.core_aux_rready(1'b0),
    .aux_araddr,.aux_arlen,.aux_arsize,.aux_arburst,
    .aux_arvalid,.aux_arready,.aux_rdata,.aux_rresp,
    .aux_rlast,.aux_rvalid,.aux_rready,
    .table_reader_out_ready(1'b0),
    .writer_tile_valid(1'b0),.writer_tile_f32(256'd0),
    .writer_tile_n0(12'd0),.writer_rearm_valid(1'b0),
    .writer_flush_req(1'b0),.segment_begin_valid(1'b0),
    .segment_begin_route(2'd0),.segment_begin_base(64'd0),
    .segment_begin_span(64'd0),
    .stage_row_accept(1'b0),.stage_tensor_begin(1'b0),
    .stage_row(7'd0),.stage_row_discard(1'b0),
    .stage_row_done_fire(1'b0),.stage_row_done_status(4'd0),
    .stage_release_fire(1'b0),
    .norm_written,.norm_stage_ready,
    .m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,.m_axi_awburst,
    .m_axi_awvalid,.m_axi_awready,.m_axi_wdata,.m_axi_wstrb,
    .m_axi_wlast,.m_axi_wvalid,.m_axi_wready,
    .m_axi_bresp,.m_axi_bvalid,.m_axi_bready
  );
  always_comb active_row=int'(dut.stage_loop_row);

  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [31:0] raw[0:131071],norm_gold[0:131071],gamma[0:1023];
  logic [31:0] norm_mem[0:131071];
  string fixture;
  int cycle=0,source_ar_count=0,source_r_count=0;
  int gamma_ar_count=0,gamma_r_count=0,b_count=0,norm_total=0;
  logic [7:0] last_retired=0;
  int source_beat=0,source_left=0;
  int gamma_beat=0,gamma_left=0;
  bit source_active=0,gamma_active=0,write_aw=0,write_w=0;
  logic [63:0] write_addr=0;
  int b_delay=0;
  always @(posedge clk) if(rst_n) begin
    cycle<=cycle+1;
    if(dut.bank_service.norm_valid)norm_total<=norm_total+1;
    if(dut.stage_retired_rows!=last_retired)begin
      $display("STAGED_LN_ROW_RETIRED row=%0d B=%0d sourceR=%0d cycle=%0d",
        dut.stage_retired_rows-1'b1,
        b_count,source_r_count,cycle);
      last_retired<=dut.stage_retired_rows;
    end
    if(cycle%5000==0)
      $display("STAGED_LN_PROGRESS gamma=%0d raw=%0d norm=%0d B=%0d state=%0d core=%0d",
        gamma_r_count,source_r_count,norm_total,
        b_count,dut.stage_loop_state,
        dut.bank_service.staged_state);
    if(cycle>40000000)$fatal(1,"STAGED_LN_TIMEOUT state=%0d row=%0d",dut.stage_loop_state,active_row);
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
    state0_rresp=0;state0_rlast=source_left==1;
    state0_rdata=0;
    for(int lane=0;lane<16;lane++)
      state0_rdata[32*lane+:32]=raw[active_row*1024+source_beat*16+lane];
    rope_arready='0;rope_rdata='0;rope_rresp='0;
    rope_rlast='0;rope_rvalid='0;
    m_axi_awready='0;m_axi_wready='0;m_axi_bvalid='0;
    m_axi_bresp='0;
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
      if(gamma_active || aux_araddr != cmd_rope_aux_base+128+gamma_r_count*16 ||
         aux_arsize!=3'd4 || aux_arburst!=2'd1)
        $fatal(1,"STAGED_LN_GAMMA_AR addr=%h",aux_araddr);
      gamma_active<=1;
      gamma_beat<=gamma_r_count;
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


  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"STAGED_LN128_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/raw_s128.hex"},raw);
    $readmemh({fixture,"/norm_s128.hex"},norm_gold);
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
    cmd_task_context[31:0]=81;
    cmd_input_from_state0=1;cmd_staged_ln=1;
    cmd_id=81;x_valid=0;gamma_valid=0;x_bits=0;gamma_bits=0;
    $display("STAGED_LN_SIM_START");
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"STAGED_LN128_REQUEST_NOT_READY");
    @(negedge clk);cmd_valid=0;
    // Caller changes after acceptance; the sequencer must use its copy.
    cmd_id=0;cmd_w_epoch=0;cmd_weight_key=0;
    cmd_model_identity='1;cmd_numeric_identity='1;
    cmd_task_context='0;
    for(int guard=0;guard<40000000 && !norm_stage_ready;guard++)begin
      @(negedge clk);
      if((stage_result_valid && stage_result_status!=0) ||
         tensor_final_valid || tensor_raw_valid ||
         row_written!=0 || row_final!=0 || tensor_failed)
        $fatal(1,"STAGED_LN128_EARLY_COMPLETION row=%0d status=%0d",
               dut.stage_retired_rows,
               done_status);
      if($test$plusargs("PREFIX_16") && stage_retired_rows==8'd16)begin
        if(norm_written[15:0]!==16'hffff || norm_written[127:16]!=0 ||
           norm_stage_ready || b_count!=1024 || source_r_count!=1024 ||
           gamma_r_count!=256 || norm_total!=16384)
          $fatal(1,"STAGED_LN_16_PREFIX_BAD B=%0d sourceR=%0d norm=%0d",
                 b_count,source_r_count,norm_total);
        for(int i=0;i<16384;i++)
          if(norm_mem[i]!==norm_gold[i])
            $fatal(1,"STAGED_LN_16_PREFIX_GOLD idx=%0d",i);
        $display("STAGED_LN_16_PREFIX_PASS norm=16384 B=1024 sourceR=1024 gammaR=256");
        $finish;
      end
      if($test$plusargs("PREFIX_ROW0") &&
         dut.stage_retired_rows==8'd1)begin
        if(norm_written[0]!==1'b1 || norm_written[127:1]!=0 ||
           norm_stage_ready || b_count!=64 || source_r_count!=64 ||
           gamma_r_count!=256 || norm_total!=1024)
          $fatal(1,"STAGED_LN_ROW0_PREFIX_BAD B=%0d sourceR=%0d norm=%0d",
                 b_count,source_r_count,norm_total);
        for(int i=0;i<1024;i++)
          if(norm_mem[i]!==norm_gold[i])
            $fatal(1,"STAGED_LN_ROW0_PREFIX_GOLD idx=%0d",i);
        $display("STAGED_LN_ROW0_PREFIX_PASS norm=1024 B=64 sourceR=64 gammaR=256");
        $finish;
      end
    end
    if(!norm_stage_ready ||
       dut.stage_retired_rows!=8'd128 ||
       norm_written!=='1 || b_count!=8192 || source_r_count!=8192 ||
       gamma_r_count!=256 || row_written!=0 || row_final!=0 ||
       tensor_final_valid || tensor_raw_valid || done_valid)
      $fatal(1,"STAGED_LN128_FINAL_BAD retired=%0d b=%0d sourceR=%0d",
             dut.stage_retired_rows,
             b_count,source_r_count);
    for(int i=0;i<131072;i++)
      if(norm_mem[i]!==norm_gold[i])
        $fatal(1,"STAGED_LN128_GOLD idx=%0d",i);
    $display("STAGED_LN128_REAL_PASS rows=128 norm=131072 B=8192 gammaR=256");
    $finish;
  end
endmodule
