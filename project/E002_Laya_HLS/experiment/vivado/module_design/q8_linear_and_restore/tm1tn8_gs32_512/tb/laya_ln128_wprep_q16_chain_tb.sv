`timescale 1ns/1ps
module laya_ln128_wprep_q16_chain_tb;
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
  logic stage_continue_valid=0,stage_continue_ready,stage_a16_ready;
  logic stage_release_fire=0;
  logic stage_input_done_ready=1;
  bit stage_done_hold=0;
  logic [4:0] stage_q_retired_rows;
  logic [2:0][63:0] cont_w_base;
  logic [2:0][31:0] cont_w_bytes;
  logic [63:0] state1_araddr;
  logic [7:0] state1_arlen;
  logic [2:0] state1_arsize;
  logic [1:0] state1_arburst;
  logic state1_arvalid,state1_arready,state1_rlast,state1_rvalid,state1_rready;
  logic [511:0] state1_rdata;
  logic [1:0] state1_rresp;
  logic wp_valid,wp_ready,wp_done_valid,wp_done_ready;
  logic [31:0] wp_id,wp_source_epoch,wp_epoch;
  logic [63:0] wp_request,wp_generation;
  logic [15:0] wp_key;
  logic [3327:0] wp_model;
  logic [671:0] wp_numeric;
  logic [1023:0] wp_header;
  logic [2:0][63:0] wp_base;
  logic [2:0][31:0] wp_bytes;
  logic [63:0] wp_aux_base,wp_bias_base;
  logic [31:0] wp_bias_bytes;
  logic [31:0] wp_done_id,wp_done_source_epoch,wp_done_epoch;
  logic [63:0] wp_done_request,wp_done_generation;
  logic [15:0] wp_done_key;
  logic [3327:0] wp_done_model;
  logic [671:0] wp_done_numeric;
  logic [3:0] wp_done_status;
  logic [7:0] wp_done_op;
  logic [15:0] wp_done_check_status;
  logic [31:0] wp_done_detail;
  logic [63:0] wp_done_bad64;
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
    .stage_input_done_ready,
    .stage_input_done_status(stage_result_status),
    .stage_retired_rows(stage_retired_rows),
    .stage_continue_valid,.stage_continue_ready,
    .stage_continue_request(64'd3),.stage_continue_generation(64'd1),
    .stage_continue_norm_epoch(32'd1),
    .stage_continue_next_base_id(32'd210),
    .stage_continue_a_epoch(32'd2),.stage_continue_w_epoch(32'd1),
    .stage_continue_w_key(16'h0001),.stage_continue_model(model_rom[0]),
    .stage_continue_numeric({model_rom[0][511:0],16'd128,16'd1,64'd1,64'd3}),
    .stage_continue_w_header(header_rom[0]),
    .stage_continue_w_base(cont_w_base),.stage_continue_w_bytes(cont_w_bytes),
    .stage_continue_w_aux_base(64'd0),
    .stage_continue_w_bias_base(64'd0),
    .stage_continue_w_bias_bytes(32'd0),
    .stage_w_valid(wp_valid),.stage_w_ready(wp_ready),
    .stage_w_id(wp_id),.stage_w_source_epoch(wp_source_epoch),
    .stage_w_epoch(wp_epoch),.stage_w_request(wp_request),
    .stage_w_generation(wp_generation),.stage_w_key(wp_key),
    .stage_w_model(wp_model),.stage_w_numeric(wp_numeric),
    .stage_w_header(wp_header),.stage_w_base(wp_base),
    .stage_w_bytes(wp_bytes),.stage_w_aux_base(wp_aux_base),
    .stage_w_bias_base(wp_bias_base),.stage_w_bias_bytes(wp_bias_bytes),
    .stage_w_done_valid(wp_done_valid),.stage_w_done_ready(wp_done_ready),
    .stage_w_done_id(wp_done_id),
    .stage_w_done_source_epoch(wp_done_source_epoch),
    .stage_w_done_epoch(wp_done_epoch),
    .stage_w_done_request(wp_done_request),
    .stage_w_done_generation(wp_done_generation),
    .stage_w_done_key(wp_done_key),.stage_w_done_model(wp_done_model),
    .stage_w_done_numeric(wp_done_numeric),
    .stage_w_done_status(wp_done_status),.stage_w_done_op(wp_done_op),
    .stage_w_done_check_status(wp_done_check_status),
    .stage_w_done_detail(wp_done_detail),
    .stage_w_done_bad64(wp_done_bad64),
    .stage_a16_ready,.stage_q_retired_rows,
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
    .state1_araddr,.state1_arlen,.state1_arsize,.state1_arburst,
    .state1_arvalid,.state1_arready,.state1_rdata,.state1_rresp,
    .state1_rlast,.state1_rvalid,.state1_rready,
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
    .stage_release_fire,
    .norm_written,.norm_stage_ready,
    .m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,.m_axi_awburst,
    .m_axi_awvalid,.m_axi_awready,.m_axi_wdata,.m_axi_wstrb,
    .m_axi_wlast,.m_axi_wvalid,.m_axi_wready,
    .m_axi_bresp,.m_axi_bvalid,.m_axi_bready
  );
  laya_rev21_w_peer w_peer(.*);
  always_comb active_row=int'(dut.stage_loop_row);

  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [63:0] w_cfg[0:12];
  logic [31:0] raw[0:131071],norm_gold[0:131071],gamma[0:1023];
  logic [31:0] norm_mem[0:131071];
  logic [255:0] qgold[0:127];
  logic [15:0] scalegold[0:127];
  // Build the expected bank image from accepted leaf responses, never from
  // the bank under test. Rows 4..15 are transport checks, not arithmetic gold.
  logic [31:0] q_from_leaf[0:4351];
  bit q_from_leaf_valid[0:4351];
  logic [255:0] q_rsp_bits_seen[0:511];
  logic [15:0] q_rsp_scale_seen[0:511];
  bit q_rsp_seen[0:511];
  string fixture;
  int cycle=0,source_ar_count=0,source_r_count=0;
  int gamma_ar_count=0,gamma_r_count=0,b_count=0,norm_total=0;
  logic [7:0] last_retired=0;
  int source_beat=0,source_left=0;
  int state1_ar_count=0,state1_r_count=0,state1_beat=0;
  int state1_left=0,state1_wordbase=0;
  bit state1_active=0;
  int q_row_seen=0,q_input_count=0,q_rsp_count=0,q_half_count=0,q_scale_count=0;
  int gamma_beat=0,gamma_left=0;
  bit source_active=0,gamma_active=0,write_aw=0,write_w=0;
  logic [63:0] write_addr=0;
  int b_delay=0;
  bit last_b_hold=0,last_b_released=1,last_b_barrier_seen=0;
  bit last_state1_hold=0,last_state1_released=1,last_state1_barrier_seen=0;
  always @(posedge clk) if(rst_n) begin
    cycle<=cycle+1;
    if(dut.bank_service.norm_valid)norm_total<=norm_total+1;
    if(dut.bank_service.qf_state==3'd3 && dut.bank_service.ln_x_ready)begin
      if(dut.bank_service.qf_row>=16 || dut.bank_service.qf_index>=1024 ||
         !dut.bank_service.lnq.x_valid ||
         dut.bank_service.lnq.x_bits!==
           norm_gold[int'(dut.bank_service.qf_row)*1024+
                     int'(dut.bank_service.qf_index)])
        $fatal(1,"CHAIN_Q_INPUT row=%0d index=%0d actual=%h expected=%h",
          dut.bank_service.qf_row,dut.bank_service.qf_index,
          dut.bank_service.lnq.x_bits,
          norm_gold[int'(dut.bank_service.qf_row)*1024+
                    int'(dut.bank_service.qf_index)]);
      q_input_count<=q_input_count+1;
    end
    if(dut.bank_service.q16_state==3'd2 && dut.bank_service.ln_rsp_valid)begin
      int response_index;
      int base_word;
      response_index=int'(dut.bank_service.q16_row[3:0])*32+
                     int'(dut.bank_service.q16_group);
      base_word=int'(dut.bank_service.q16_row[3:0])*272+
                int'(dut.bank_service.q16_group)*8;
      if(dut.bank_service.q16_row>=16 ||
         dut.bank_service.ln_rsp_group!={1'b0,dut.bank_service.q16_group} ||
         q_rsp_seen[response_index])
        $fatal(1,"CHAIN_Q_RESPONSE row=%0d group=%0d rsp=%0d",
          dut.bank_service.q16_row,dut.bank_service.q16_group,
          dut.bank_service.ln_rsp_group);
      q_rsp_seen[response_index]=1;
      q_rsp_bits_seen[response_index]=dut.bank_service.ln_rsp_q;
      q_rsp_scale_seen[response_index]=dut.bank_service.ln_rsp_scale;
      for(int lane=0;lane<8;lane++)begin
        q_from_leaf[base_word+lane]=dut.bank_service.ln_rsp_q[32*lane+:32];
        q_from_leaf_valid[base_word+lane]=1;
      end
      if(dut.bank_service.q16_group[0])begin
        int scale_word;
        scale_word=int'(dut.bank_service.q16_row[3:0])*272+256+
                   int'(dut.bank_service.q16_group[5:1]);
        if(!q_rsp_seen[response_index-1])
          $fatal(1,"CHAIN_Q_SCALE_EVEN_MISSING row=%0d group=%0d",
            dut.bank_service.q16_row,dut.bank_service.q16_group);
        q_from_leaf[scale_word]={dut.bank_service.ln_rsp_scale,
                                 q_rsp_scale_seen[response_index-1]};
        q_from_leaf_valid[scale_word]=1;
      end
      q_rsp_count<=q_rsp_count+1;
    end
    if(dut.bank_service.q16_state==3'd3)begin
      int write_index;
      write_index=int'(dut.bank_service.q16_row[3:0])*32+
                  int'(dut.bank_service.q16_group);
      if(!q_rsp_seen[write_index] ||
         dut.bank_service.q16_bits!==q_rsp_bits_seen[write_index] ||
         dut.bank_service.q16_word_base!==
           13'(int'(dut.bank_service.q16_row[3:0])*272+
               int'(dut.bank_service.q16_group)*8))
        $fatal(1,"CHAIN_Q_WRITE_SOURCE row=%0d group=%0d",
          dut.bank_service.q16_row,dut.bank_service.q16_group);
      q_half_count<=q_half_count+1;
    end
    if(dut.bank_service.q16_state==3'd4)begin
      int scale_index;
      scale_index=int'(dut.bank_service.q16_row[3:0])*32+
                  int'(dut.bank_service.q16_group);
      if(!q_rsp_seen[scale_index] || !q_rsp_seen[scale_index-1] ||
         dut.bank_service.q16_scale_even!==q_rsp_scale_seen[scale_index-1] ||
         dut.bank_service.q16_scale_current!==q_rsp_scale_seen[scale_index] ||
         dut.bank_service.q16_scale_word!==
           13'(int'(dut.bank_service.q16_row[3:0])*272+256+
               int'(dut.bank_service.q16_group[5:1])))
        $fatal(1,"CHAIN_SCALE_WRITE_SOURCE row=%0d group=%0d",
          dut.bank_service.q16_row,dut.bank_service.q16_group);
      q_scale_count<=q_scale_count+1;
    end
    if(stage_q_retired_rows!=q_row_seen)begin
      if(stage_q_retired_rows!=q_row_seen+1)
        $fatal(1,"CHAIN_Q_ROW_SKIP next=%0d prev=%0d",stage_q_retired_rows,q_row_seen);
      for(int w=272*q_row_seen;w<272*(q_row_seen+1);w++)begin
        if(!q_from_leaf_valid[w] ||
           dut.bank_service.final_bank[w%8][w/8]!==q_from_leaf[w])
          $fatal(1,"CHAIN_Q_LEAF_TO_BANK row=%0d word=%0d actual=%h expected=%h",
            q_row_seen,w,dut.bank_service.final_bank[w%8][w/8],
            q_from_leaf[w]);
      end
      q_row_seen<=stage_q_retired_rows;
    end
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
    state1_arready=!state1_active;
    state1_rvalid=state1_active &&
                  (!last_state1_hold || state1_r_count!=1023 ||
                   last_state1_released);
    state1_rresp=0;state1_rlast=state1_left==1;
    state1_rdata=0;
    for(int lane=0;lane<16;lane++)
      state1_rdata[32*lane+:32]=norm_mem[state1_wordbase+state1_beat*16+lane];
    rope_arready='0;rope_rdata='0;rope_rresp='0;
    rope_rlast='0;rope_rvalid='0;
    m_axi_awready='0;m_axi_wready='0;m_axi_bvalid='0;
    m_axi_bresp='0;
    m_axi_awready[2]=!write_aw;
    m_axi_wready[2]=write_aw && !write_w;
    m_axi_bvalid[2]=write_w && b_delay>=3 &&
                     (!last_b_hold || b_count!=8191 || last_b_released);
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
    if(state1_arvalid && state1_arready)begin
      state1_ar_count<=state1_ar_count+1;
      if(state1_active || w_peer.r_count[0]!=24576 ||
         state1_araddr!=cmd_dst_base[2]+(state1_r_count/64)*4096 ||
         state1_arlen!=8'd63 || state1_arsize!=3'd6 ||
         state1_arburst!=2'd1)
        $fatal(1,"CHAIN_STATE1_AR addr=%h r=%0d",state1_araddr,state1_r_count);
      state1_active<=1;state1_left<=64;state1_beat<=0;
      state1_wordbase<=int'((state1_araddr-cmd_dst_base[2])/4);
    end
    if(state1_rvalid && state1_rready)begin
      if(state1_left<=0 || state1_rlast!=(state1_left==1))
        $fatal(1,"CHAIN_STATE1_R_PROTOCOL");
      for(int lane=0;lane<16;lane++)
        if(state1_rdata[32*lane+:32]!==norm_gold[state1_wordbase+state1_beat*16+lane])
          $fatal(1,"CHAIN_STATE1_DATA idx=%0d",state1_wordbase+state1_beat*16+lane);
      state1_r_count<=state1_r_count+1;
      state1_beat<=state1_beat+1;state1_left<=state1_left-1;
      if(state1_rlast)state1_active<=0;
    end
    if(aux_arvalid && aux_arready) begin
      if(gamma_active || aux_araddr != cmd_rope_aux_base+128+(gamma_r_count%256)*16 ||
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


  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"STAGED_LN128_FIXTURE");
    $readmemh({fixture,"/model_identity.hex"},model_rom);
    $readmemh({fixture,"/expected_aux_header.hex"},header_rom);
    $readmemh({fixture,"/raw_s128.hex"},raw);
    $readmemh({fixture,"/norm_s128.hex"},norm_gold);
    $readmemh({fixture,"/gamma.hex"},gamma);
    $readmemh({fixture,"/q_rows4.hex"},qgold);
    $readmemh({fixture,"/scale_rows4.hex"},scalegold);
    $readmemh({fixture,"/qkv_config.hex"},w_cfg);
    for(int p=0;p<3;p++)begin
      cont_w_base[p]=w_cfg[3+p];cont_w_bytes[p]=w_cfg[6+p][31:0];
    end
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
    last_b_hold=$test$plusargs("CHAIN_LAST_B_HOLD");
    last_b_released=!last_b_hold;
    last_state1_hold=$test$plusargs("CHAIN_LAST_STATE1_R_HOLD");
    last_state1_released=!last_state1_hold;
    stage_done_hold=$test$plusargs("CHAIN_STAGE_DONE_HOLD");
    stage_input_done_ready=!stage_done_hold;
    $display("STAGED_LN_SIM_START");
    repeat(5)@(negedge clk);rst_n=1;
    @(negedge clk);cmd_valid=1;
    #1ps;if(!cmd_ready)$fatal(1,"STAGED_LN128_REQUEST_NOT_READY");
    @(negedge clk);cmd_valid=0;
    // Caller changes after acceptance; the sequencer must use its copy.
    cmd_id=0;cmd_w_epoch=0;cmd_weight_key=0;
    cmd_model_identity='1;cmd_numeric_identity='1;
    cmd_task_context='0;
    if(last_b_hold) fork
      begin
        wait(b_count==8191 && write_w && b_delay>=3);
        @(negedge clk);stage_continue_valid=1;
        repeat(3)begin
          #1ps;
          if(stage_continue_ready || norm_stage_ready ||
             m_axi_bvalid[2] || b_count!=8191 ||
             dut.stage_retired_rows!=8'd127 ||
             !dut.bank_link.gamma_token_valid)
            $fatal(1,"CHAIN_LAST_B_BARRIER_BAD B=%0d retired=%0d ready=%b",
                   b_count,dut.stage_retired_rows,stage_continue_ready);
          @(negedge clk);
        end
        stage_continue_valid=0;
        last_b_barrier_seen=1;
        last_b_released=1;
      end
    join_none
    if(last_state1_hold) fork
      begin
        wait(state1_r_count==1023 && state1_active && state1_left==1);
        repeat(3)begin
          @(negedge clk);
          #1ps;
          if(state1_rvalid || stage_q_retired_rows!=5'd15 ||
             q_input_count!=15360 || q_rsp_count!=480 ||
             state1_ar_count!=16 || state1_r_count!=1023 ||
             dut.stage_prep_state==3'd4)
            $fatal(1,"CHAIN_STATE1_LAST_R_BARRIER_BAD R=%0d q=%0d input=%0d",
                   state1_r_count,stage_q_retired_rows,q_input_count);
        end
        last_state1_barrier_seen=1;
        last_state1_released=1;
      end
    join_none
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
    if(last_b_hold && !last_b_barrier_seen)
      $fatal(1,"CHAIN_LAST_B_BARRIER_NOT_SEEN");
    for(int i=0;i<131072;i++)
      if(norm_mem[i]!==norm_gold[i])
        $fatal(1,"STAGED_LN128_GOLD idx=%0d",i);
    $display("CHAIN_LN128_PASS rows=128 norm=131072 B=8192 gammaR=256");
    if(stage_done_hold)begin
      @(negedge clk);stage_continue_valid=1;
      repeat(3)begin
        #1ps;
        if(!stage_result_valid || stage_result_status!=0 ||
           stage_continue_ready || dut.stage_loop_state!=5'd8 ||
           dut.stage_retired_rows!=8'd128 ||
           !dut.bank_link.gamma_token_valid ||
           state1_ar_count!=0 || q_input_count!=0)
          $fatal(1,"CHAIN_STAGE_DONE_HOLD_BAD state=%0d done=%b ready=%b",
                 dut.stage_loop_state,stage_result_valid,stage_continue_ready);
        @(negedge clk);
      end
      stage_continue_valid=0;
      stage_input_done_ready=1;
      @(negedge clk);
      #1ps;
      if(stage_result_valid || !stage_continue_ready ||
         dut.stage_loop_state!=5'd9)
        $fatal(1,"CHAIN_STAGE_DONE_RELEASE_BAD state=%0d ready=%b",
               dut.stage_loop_state,stage_continue_ready);
    end
    @(negedge clk);stage_continue_valid=1;
    #1ps;if(!stage_continue_ready)$fatal(1,"CHAIN_CONTINUE_NOT_READY");
    @(negedge clk);stage_continue_valid=0;
    if(last_b_hold || stage_done_hold)begin
      #1ps;
      if(dut.bank_link.gamma_token_valid ||
         dut.stage_loop_state!=5'd10 ||
         norm_written!=='1 || !norm_stage_ready || b_count!=8192 ||
         state1_ar_count!=0 || q_input_count!=0)
        $fatal(1,"CHAIN_LAST_B_RELEASE_BAD state=%0d gamma=%b B=%0d",
               dut.stage_loop_state,dut.bank_link.gamma_token_valid,b_count);
      if(last_b_hold)
        $display("CHAIN_LAST_B_CONTINUE_PASS B=8192 retired=128 gamma_retired=1 norm_held=131072");
      else
        $display("CHAIN_STAGE_DONE_CONSUME_PASS held=3 B=8192 retired=128 gamma_retired=1");
      $finish;
    end
    for(int guard=0;guard<40000000 && !stage_a16_ready &&
        !dut.stage_follow_error_valid;guard++)begin
      @(negedge clk);
      if(cycle%20000==0)$display("CHAIN_PROGRESS cycle=%0d phase=%0d q=%0d state1R=%0d W=%0d/%0d/%0d",
        cycle,dut.stage_loop_state,stage_q_retired_rows,state1_r_count,
        w_peer.r_count[0],w_peer.r_count[1],w_peer.r_count[2]);
    end
    if($test$plusargs("CHAIN_W_BUS_FAULT"))begin
      if(!dut.stage_follow_error_valid || stage_a16_ready ||
         dut.stage_final_status!=4'd7 ||
         dut.stage_done_op!=8'h80 ||
         dut.stage_done_check_status!=16'd7 ||
         dut.stage_done_detail!=32'h0780_0005 ||
         dut.stage_done_bad64!=64'hffff_ffff_ffff_ffff ||
         state1_ar_count!=0 || state1_r_count!=0 ||
         q_input_count!=0 || q_rsp_count!=0 ||
         stage_q_retired_rows!=0 || norm_written!=='1 ||
         !norm_stage_ready || w_peer.r_count[0]!=24576 ||
         w_peer.r_count[1]!=24576 || w_peer.r_count[2]!=3072 ||
         w_peer.aux_count!=8)
        $fatal(1,"CHAIN_W_BUS_ERROR_BOUNDARY status=%0d detail=%h state1AR=%0d q=%0d W=%0d/%0d/%0d",
          dut.stage_final_status,dut.stage_done_detail,state1_ar_count,
          stage_q_retired_rows,w_peer.r_count[0],w_peer.r_count[1],
          w_peer.r_count[2]);
      repeat(3)begin
        @(negedge clk);
        if(!dut.stage_follow_error_valid || stage_continue_ready ||
           state1_ar_count!=0 || state1_r_count!=0 ||
           q_input_count!=0 || stage_q_retired_rows!=0 ||
           dut.stage_done_check_status!=16'd7 ||
           dut.stage_done_detail!=32'h0780_0005)
          $fatal(1,"CHAIN_W_BUS_ERROR_NOT_HELD");
      end
      for(int i=0;i<131072;i++)
        if(norm_mem[i]!==norm_gold[i])
          $fatal(1,"CHAIN_W_BUS_ERROR_NORM_CHANGED idx=%0d",i);
      $display("CHAIN_W_BUS_ERROR_BOUNDARY_PASS norm=131072 state1AR=0 Q=0 W=24576/24576/3072");
      if($test$plusargs("CHAIN_W_ERROR_RECOVER"))begin
        @(negedge clk);stage_release_fire=1;
        @(negedge clk);stage_release_fire=0;
        #1ps;
        if(!cmd_ready || dut.stage_retired_rows!=0 ||
           dut.stage_loop_state!=5'd0 || !dut.writer_debt_zero)
          $fatal(1,"CHAIN_W_ERROR_DISCARD_BAD state=%0d debt=%b",
                 dut.stage_loop_state,dut.writer_debt_zero);
        cmd_id=300;cmd_state0_epoch=2;
        cmd_model_identity=model_rom[0];
        cmd_numeric_identity={model_rom[0][511:0],16'd128,16'd1,64'd2,64'd4};
        cmd_valid=1;
        @(negedge clk);cmd_valid=0;
        for(int guard=0;guard<300000 && dut.stage_retired_rows==0;guard++)
          @(negedge clk);
        if(dut.stage_retired_rows!=1 || b_count!=8256 ||
           source_r_count!=8256 || gamma_r_count!=512 ||
           norm_total!=132096 || stage_a16_ready ||
           state1_ar_count!=0 || q_input_count!=0)
          $fatal(1,"CHAIN_W_ERROR_RECOVERY_ROW0_BAD retired=%0d B=%0d src=%0d gamma=%0d norm=%0d",
                 dut.stage_retired_rows,b_count,source_r_count,
                 gamma_r_count,norm_total);
        for(int i=0;i<1024;i++)
          if(norm_mem[i]!==norm_gold[i])
            $fatal(1,"CHAIN_W_ERROR_RECOVERY_NORM idx=%0d",i);
        $display("CHAIN_W_ERROR_DISCARD_RECOVERY_PASS epoch=2 row0=1024 B=64 sourceR=64 gammaR=256");
      end
      $finish;
    end
    if(dut.stage_follow_error_valid)
      $fatal(1,"CHAIN_FOLLOW_ERROR status=%0d detail=%h q=%0d",
        dut.stage_final_status,dut.stage_done_detail,stage_q_retired_rows);
    if(last_state1_hold && !last_state1_barrier_seen)
      $fatal(1,"CHAIN_STATE1_LAST_R_BARRIER_NOT_SEEN");
    // The last retirement and its observer update are sampled on adjacent
    // rising edges. Let the monitor capture row 15 before final rescan.
    @(negedge clk);
    if(!stage_a16_ready || stage_q_retired_rows!=16 ||
       state1_r_count!=1024 || w_peer.r_count[0]!=24576 ||
       w_peer.r_count[1]!=24576 || w_peer.r_count[2]!=3072 ||
       w_peer.aux_count!=8 || w_peer.dut.load_scale_checks!=98304 ||
       dut.bank_service.q16_cover!==16'hffff ||
       q_input_count!=16384 || q_rsp_count!=512 ||
       q_half_count!=512 || q_scale_count!=256 || q_row_seen!=16)
      $fatal(1,"CHAIN_A16_BAD q=%0d seen=%0d state1R=%0d input=%0d rsp=%0d half=%0d scale=%0d cover=%h",
        stage_q_retired_rows,q_row_seen,state1_r_count,q_input_count,
        q_rsp_count,q_half_count,q_scale_count,dut.bank_service.q16_cover);
    for(int w=0;w<4352;w++)
      if(!q_from_leaf_valid[w] ||
         dut.bank_service.final_bank[w%8][w/8]!==q_from_leaf[w])
        $fatal(1,"CHAIN_Q_LEAF_HOLD w=%0d",w);
    for(int r=0;r<4;r++)begin
      for(int g=0;g<32;g++)for(int lane=0;lane<8;lane++)begin
        int w;
        w=272*r+8*g+lane;
        if(dut.bank_service.final_bank[w%8][w/8]!==qgold[32*r+g][32*lane+:32])
          $fatal(1,"CHAIN_Q_GOLD row=%0d group=%0d lane=%0d",r,g,lane);
      end
      for(int pair=0;pair<16;pair++)begin
        int w;
        w=272*r+256+pair;
        if(dut.bank_service.final_bank[w%8][w/8]!==
           {scalegold[32*r+2*pair+1],scalegold[32*r+2*pair]})
          $fatal(1,"CHAIN_SCALE_GOLD row=%0d pair=%0d",r,pair);
      end
    end
    for(int i=0;i<131072;i++)
      if(norm_mem[i]!==norm_gold[i])$fatal(1,"CHAIN_NORM_CHANGED idx=%0d",i);
    $display("CHAIN_A16_PASS q=16 state1R=1024 input_bits=16384 leaf_to_bank=4352 half=512 scale=256 words=4352 gold_rows=4 W=24576/24576/3072 AUX=8");
    if(last_state1_hold)
      $display("CHAIN_STATE1_LAST_R_HOLD_PASS blocked=3 state1R=1024 Q=16 bank=4352");
    $finish;
  end
endmodule

module laya_rev21_w_peer(
  input logic clk,rst_n,wp_valid,wp_done_ready,
  output logic wp_ready,wp_done_valid,
  input logic [31:0] wp_id,wp_source_epoch,wp_epoch,
  input logic [63:0] wp_request,wp_generation,
  input logic [15:0] wp_key,
  input logic [3327:0] wp_model,
  input logic [671:0] wp_numeric,
  input logic [1023:0] wp_header,
  input logic [2:0][63:0] wp_base,
  input logic [2:0][31:0] wp_bytes,
  input logic [63:0] wp_aux_base,wp_bias_base,
  input logic [31:0] wp_bias_bytes,
  output logic [31:0] wp_done_id,wp_done_source_epoch,wp_done_epoch,
  output logic [63:0] wp_done_request,wp_done_generation,
  output logic [15:0] wp_done_key,
  output logic [3327:0] wp_done_model,
  output logic [671:0] wp_done_numeric,
  output logic [3:0] wp_done_status,
  output logic [7:0] wp_done_op,
  output logic [15:0] wp_done_check_status,
  output logic [31:0] wp_done_detail,
  output logic [63:0] wp_done_bad64
);
  logic load_done,load_error,load_reject;
  logic load_protocol_error,load_numeric_error;
  logic [31:0] load_scale_checks,load_bad_element;
  logic [1:0][2:0] slot_state;
  logic [1:0][31:0] slot_epoch,slot_readers;
  logic [1:0][3:0][31:0] slot_coverage;
  logic [2:0][63:0] araddr;
  logic [2:0][7:0] arlen;
  logic [2:0][2:0] arsize;
  logic [2:0][1:0] arburst,rresp;
  logic [2:0] arvalid,arready,rlast,rvalid,rready;
  logic [2:0][511:0] rdata;
  logic [63:0] aux_araddr;
  logic [7:0] aux_arlen;
  logic [2:0] aux_arsize;
  logic [1:0] aux_arburst,aux_rresp;
  logic aux_arvalid,aux_arready,aux_rlast,aux_rvalid,aux_rready;
  logic [127:0] aux_rdata;
  laya_w_prep_service_v1 dut (
    .clk,
    .rst_n,
    .load_cancel('0),
    .load_valid('0),
    .load_slot('0),
    .load_epoch('0),
    .load_k('0),
    .load_n('0),
    .load_weight_key('0),
    .load_model_identity('0),
    .load_expected_aux_header('0),
    .load_base('0),
    .load_bytes('0),
    .load_aux_base('0),
    .load_bias_base('0),
    .load_bias_bytes('0),
    .commit_ready(4'hf),
    .arready,
    .rdata,
    .rresp,
    .rlast,
    .rvalid,
    .aux_arready,
    .aux_rdata,
    .aux_rresp,
    .aux_rlast,
    .aux_rvalid,
    .lease_valid('0),
    .lease_slot('0),
    .lease_epoch('0),
    .lease_k('0),
    .lease_n('0),
    .lease_weight_key('0),
    .lease_model_identity('0),
    .lease_numeric_identity('0),
    .lease_task_context('0),
    .read_valid('0),
    .read_slot('0),
    .read_epoch('0),
    .read_tile('0),
    .read_group('0),
    .read_pair('0),
    .read_model_identity('0),
    .read_numeric_identity('0),
    .read_task_context('0),
    .ret_ready('0),
    .release_valid('0),
    .release_slot('0),
    .release_epoch('0),
    .release_numeric_identity('0),
    .release_task_context('0),
    .wp_valid,
    .wp_id,
    .wp_source_epoch,
    .wp_epoch,
    .wp_request,
    .wp_generation,
    .wp_key,
    .wp_model,
    .wp_numeric,
    .wp_header,
    .wp_base,
    .wp_bytes,
    .wp_aux_base,
    .wp_bias_base,
    .wp_bias_bytes,
    .wp_done_ready,
    .load_ready(),
    .load_done,
    .load_error,
    .load_reject,
    .load_protocol_error,
    .load_numeric_error,
    .load_scale_checks,
    .load_bad_element,
    .slot_state,
    .slot_epoch,
    .slot_readers,
    .slot_coverage,
    .araddr,
    .arlen,
    .arsize,
    .arburst,
    .arvalid,
    .rready,
    .aux_araddr,
    .aux_arlen,
    .aux_arsize,
    .aux_arburst,
    .aux_arvalid,
    .aux_rready,
    .lease_ready(),
    .lease_done(),
    .lease_error(),
    .read_ready(),
    .read_error(),
    .ret_valid(),
    .ret_slot(),
    .ret_pair(),
    .ret_epoch(),
    .ret_tile(),
    .ret_group(),
    .ret_model_identity(),
    .ret_numeric_identity(),
    .ret_task_context(),
    .ret_q(),
    .ret_scale(),
    .ret_bias(),
    .ret_mask(),
    .release_ready(),
    .release_done(),
    .release_error(),
    .wp_ready,
    .wp_done_valid,
    .wp_done_id,
    .wp_done_source_epoch,
    .wp_done_epoch,
    .wp_done_request,
    .wp_done_generation,
    .wp_done_key,
    .wp_done_model,
    .wp_done_numeric,
    .wp_done_status,
    .wp_done_op,
    .wp_done_check_status,
    .wp_done_detail,
    .wp_done_bad64
  );
  logic [3327:0] model_rom[0:0];
  logic [1023:0] header_rom[0:0];
  logic [127:0] header_words[0:7];
  logic [63:0] cfg[0:12];
  logic [511:0] q0[0:24575],q1[0:24575],scales[0:3071];
  string fixture;
  int cycle=0,r_count[0:2],issued[0:2],beat[0:2],left[0:2];
  bit active[0:2];
  int aux_count=0,aux_beat=0,aux_left=0;
  bit aux_active=0;
  bit bus_fault,scale_fault;
  logic [4123:0] held_check;
  function automatic logic [511:0] payload(input int p,input int idx);
    case(p)0:return q0[idx];1:return q1[idx];default:return scales[idx];endcase
  endfunction
  always_comb begin
    for(int p=0;p<3;p++)begin
      arready[p]=!active[p] && cycle%5!=p;
      rvalid[p]=active[p] && cycle%7!=p;
      rdata[p]=payload(p,beat[p]);
      if(scale_fault && p==2 && beat[p]==0)rdata[p][15:0]=16'h7c00;
      rresp[p]=(bus_fault && p==0 && beat[p]==24575) ? 2'b10 : 0;
      rlast[p]=active[p] && left[p]==1;
    end
    aux_arready=!aux_active && cycle%3!=0;
    aux_rvalid=aux_active && cycle%5!=0;
    aux_rdata=header_words[aux_beat];
    aux_rresp=0;aux_rlast=aux_active && aux_left==1;
  end
  always @(posedge clk)begin
    int remain,page,beats;
    if(!rst_n)begin
      cycle<=0;aux_count<=0;aux_active<=0;aux_beat<=0;aux_left<=0;
      for(int p=0;p<3;p++)begin
        r_count[p]<=0;issued[p]<=0;beat[p]<=0;left[p]<=0;active[p]<=0;
      end
    end else begin
      cycle<=cycle+1;
      if(cycle>40000000)$fatal(1,"W_PREP_CYCLE_CAP");
      if(cycle%5000==0)$display("W_PREP_PROGRESS p0=%0d p1=%0d scale=%0d aux=%0d cycle=%0d",r_count[0],r_count[1],r_count[2],aux_count,cycle);
      for(int p=0;p<3;p++)begin
        if(arvalid[p] && arready[p])begin
          if(active[p] || araddr[p]!=wp_base[p]+issued[p] ||
             arsize[p]!=3'd6 || arburst[p]!=2'd1)
            $fatal(1,"W_PREP_AR p=%0d addr=%h",p,araddr[p]);
          remain=(int'(wp_bytes[p])-issued[p])/64;
          page=(4096-int'(araddr[p]%4096))/64;
          beats=remain<64 ? remain:64;
          if(beats>page)beats=page;
          if(beats<=0 || arlen[p]+1!=beats)$fatal(1,"W_PREP_AR_LEN p=%0d",p);
          active[p]<=1;beat[p]<=issued[p]/64;left[p]<=beats;
          issued[p]<=issued[p]+beats*64;
        end
        if(rvalid[p] && rready[p])begin
          if(!active[p] || left[p]<=0 || rlast[p]!=(left[p]==1))
            $fatal(1,"W_PREP_R p=%0d",p);
          beat[p]<=beat[p]+1;left[p]<=left[p]-1;
          r_count[p]<=r_count[p]+1;
          if(rlast[p])active[p]<=0;
        end
      end
      if(aux_arvalid && aux_arready)begin
        if(aux_active || aux_araddr!=wp_aux_base+aux_count*16 ||
           aux_arsize!=3'd4 || aux_arburst!=2'd1)
          $fatal(1,"W_PREP_AUX_AR addr=%h count=%0d",aux_araddr,aux_count);
        aux_active<=1;aux_beat<=aux_count;aux_left<=int'(aux_arlen)+1;
      end
      if(aux_rvalid && aux_rready)begin
        if(!aux_active || aux_left<=0 || aux_rlast!=(aux_left==1))
          $fatal(1,"W_PREP_AUX_R");
        aux_count<=aux_count+1;aux_beat<=aux_beat+1;
        aux_left<=aux_left-1;
        if(aux_rlast)aux_active<=0;
      end
    end
  end
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"CHAIN_W_FIXTURE");
    bus_fault=$test$plusargs("CHAIN_W_BUS_FAULT");scale_fault=0;
    $readmemh({fixture,"/aux_header.hex"},header_words);
    $readmemh({fixture,"/qkv_q0.hex"},q0);
    $readmemh({fixture,"/qkv_q1.hex"},q1);
    $readmemh({fixture,"/qkv_scale.hex"},scales);
  end
endmodule
