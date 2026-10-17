`timescale 1ns/1ps
// Synthesizable ACT production boundary; every intermediate is generated and leased.
module laya_act_production_v1 (

  input logic clk, rst_n,
  input logic load_valid,
  output logic load_ready,
  input logic load_slot,
  input logic [31:0] load_epoch, load_k, load_n,
  input logic [15:0] load_weight_key,
  input logic [3327:0] load_model_identity,
  input logic [1023:0] load_expected_aux_header,
  input logic [2:0][63:0] load_base,
  input logic [2:0][31:0] load_bytes,
  input logic [63:0] load_aux_base, load_bias_base,
  input logic [31:0] load_bias_bytes,
  output logic load_done, load_error, load_reject,
  output logic [31:0] load_scale_checks, load_bad_element,
  output logic [1:0][2:0] slot_state,
  output logic [1:0][31:0] slot_epoch, slot_readers,
  output logic [1:0][3:0][31:0] slot_coverage,
  input logic [3:0] commit_ready,

  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input logic [2:0] arready,
  input logic [2:0][511:0] rdata,
  input logic [2:0][1:0] rresp,
  input logic [2:0] rlast, rvalid,
  output logic [2:0] rready,
  output logic [63:0] aux_araddr,
  output logic [7:0] aux_arlen,
  output logic [2:0] aux_arsize,
  output logic [1:0] aux_arburst,
  output logic aux_arvalid,
  input logic aux_arready,
  input logic [127:0] aux_rdata,
  input logic [1:0] aux_rresp,
  input logic aux_rlast, aux_rvalid,
  output logic aux_rready,

  input logic start_valid,
  output logic start_ready,
  input logic [671:0] cfg_numeric_identity, cfg_source_identity,
  input logic [95:0] cfg_quant_context, cfg_linear_context,
  input logic [63:0] cfg_source_ref, cfg_a_ref, cfg_ps_ref, cfg_dst_ref,
  input logic [255:0] cfg_source_coverage,
  input logic cfg_source_published, cfg_a_slot, cfg_w_slot,
  input logic [31:0] cfg_w_epoch,
  input logic [63:0] cfg_output_base, cfg_output_span,
  input logic source_valid,
  output logic source_ready,
  input logic [511:0] source_lanes,
  input logic [671:0] source_numeric_identity,
  input logic [31:0] source_task_id, source_epoch,
  input logic [15:0] source_row, source_mask,
  input logic [6:0] source_group,
  input logic source_half,
  output logic done_valid,
  input logic done_ready,
  output logic [2:0] done_status,
  output logic [31:0] done_bad_element,
  output logic [1:0][2:0] a_state,
  output logic [1:0][31:0] a_epoch,
  output logic [1:0][7:0] a_coverage,
  output logic [63:0] command_cycles,
  output logic [63:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,
  output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,
  output logic m_axi_awvalid,
  input logic m_axi_awready,
  output logic [511:0] m_axi_wdata,
  output logic [63:0] m_axi_wstrb,
  output logic m_axi_wlast, m_axi_wvalid,
  input logic m_axi_wready,
  input logic [1:0] m_axi_bresp,
  input logic m_axi_bvalid,
  output logic m_axi_bready

);
  logic lease_valid;
  logic lease_ready, lease_done, lease_error;
  logic lease_slot;
  logic [31:0] lease_epoch, lease_k, lease_n;
  logic [15:0] lease_weight_key;
  logic [3327:0] lease_model_identity;
  logic [671:0] lease_numeric_identity;
  logic [95:0] lease_task_context;
  logic read_valid;
  logic read_ready, read_error;
  logic read_slot;
  logic [31:0] read_epoch;
  logic [15:0] read_tile;
  logic [7:0] read_group;
  logic read_pair;
  logic [3327:0] read_model_identity;
  logic [671:0] read_numeric_identity;
  logic [95:0] read_task_context;
  logic ret_valid;
  logic ret_ready;
  logic ret_slot, ret_pair;
  logic [31:0] ret_epoch;
  logic [15:0] ret_tile;
  logic [7:0] ret_group;
  logic [3327:0] ret_model_identity;
  logic [671:0] ret_numeric_identity;
  logic [95:0] ret_task_context;
  logic [1:0][7:0][255:0] ret_q;
  logic [1:0][7:0][15:0] ret_scale;
  logic [1:0][7:0][31:0] ret_bias;
  logic [1:0][7:0] ret_mask;
  logic release_valid;
  logic release_ready, release_done, release_error;
  logic release_slot;
  logic [31:0] release_epoch;
  logic [671:0] release_numeric_identity;
  logic [95:0] release_task_context;

  localparam logic [2:0] A_EMPTY=0,A_FILLING=1,A_READY=2,A_IN_USE=3,A_INVALID=4;
  typedef enum logic [3:0] {IDLE, QSTART, QUANT, WLEASE, WLEASE_WAIT,
    CONFIG, READ_W, RETURN_W, ISSUE, MAC_DRAIN, OUTPUT_DRAIN,
    RELEASE_W, RELEASE_WAIT, FINISHED} phase_t;
  phase_t phase;
  logic [671:0] numeric_id, a_numeric_id[0:1];
  logic [95:0] quant_ctx, linear_ctx, a_quant_ctx[0:1];
  logic [63:0] source_ref, a_ref, ps_ref, dst_ref, output_base, output_span;
  logic a_slot,w_slot;
  logic [31:0] w_epoch;
  logic [3327:0] run_model_identity;
  logic [255:0] a_q[0:1][0:7];
  logic [15:0] a_scale[0:1][0:7];
  logic [4:0] quant_commits;
  logic [6:0] group_index;
  logic [2047:0] w_q;
  logic [255:0] w_scale, w_bias;
  logic bias_sent, mac_configured, bias_configured, final_committed;
  logic command_ok, active, protocol_fault;
  logic q_start_ready,q_in_ready,q_out_valid,q_done;
  logic [6:0] q_out_group;
  logic q_out_half;
  logic [127:0] q_out;
  logic [15:0] q_scale,q_bad_col;
  logic [31:0] q_d,q_recip,q_accepted,q_covered,q_si,q_sr,q_ri,q_rr,q_ab,q_rb,q_mi,q_mr;
  logic [1:0] q_status;
  wire datapath_rst_n=rst_n;
  assign active=phase!=IDLE && phase!=FINISHED;
  assign start_ready=rst_n && phase==IDLE && !done_valid;
  always_comb begin
    command_ok=cfg_numeric_identity==cfg_source_identity &&
      cfg_numeric_identity[63:0]!=0 && cfg_numeric_identity[127:64]!=0 &&
      cfg_numeric_identity[143:128]==16'd1 && cfg_numeric_identity[159:144]==16'd128 &&
      cfg_source_published && (&cfg_source_coverage) &&
      cfg_source_ref[39:32]==8'd10 && cfg_source_ref[55:48]==8'd2 &&
      cfg_source_ref[31:0]!=0 && cfg_a_ref[39:32]==8'h22 &&
      cfg_a_ref[47:40]=={7'd0,cfg_a_slot} &&
      cfg_a_ref[31:0]==a_epoch[cfg_a_slot]+1 && a_epoch[cfg_a_slot]!=32'hffffffff &&
      (a_state[cfg_a_slot]==A_EMPTY || a_state[cfg_a_slot]==A_INVALID) &&
      cfg_ps_ref[39:32]==8'h24 && cfg_ps_ref[31:0]!=0 &&
      cfg_dst_ref[39:32]==8'd10 && cfg_dst_ref[55:48]==8'd4 && cfg_dst_ref[31:0]!=0 &&
      cfg_quant_context[31:0]!=0 && cfg_quant_context[39:32]==8'h20 &&
      cfg_quant_context[47:40]==8'd6 && cfg_quant_context[55:48]==8'hff &&
      cfg_quant_context[71:56]==16'h0200 && cfg_quant_context[95:72]==24'h010000 &&
      cfg_linear_context[31:0]>cfg_quant_context[31:0] &&
      cfg_linear_context[95:40]==cfg_quant_context[95:40] &&
      cfg_linear_context[39:32]==8'h37 && cfg_w_epoch!=0 &&
      cfg_output_base[1:0]==0 && cfg_output_span>=8;
  end
  quant16_stream_row quantizer(
    .clk,.rst(!datapath_rst_n),.start_valid(phase==QSTART),.start_ready(q_start_ready),
    .cfg_task_id(quant_ctx[31:0]),.cfg_source_epoch(source_ref[31:0]),
    .cfg_row(16'd0),.cfg_groups(8'd8),
    .in_valid(source_valid && phase==QUANT),.in_ready(q_in_ready),
    .in_lanes(source_lanes),.in_task_id(source_task_id),.in_source_epoch(source_epoch),
    .in_row(source_row),.in_group(source_group),.in_half(source_half),
    .in_mask(source_numeric_identity==numeric_id ? source_mask : 16'd0),
    .out_valid(q_out_valid),.out_ready(phase==QUANT),.out_group(q_out_group),
    .out_half(q_out_half),.out_q(q_out),.out_scale(q_scale),.out_d_full(q_d),
    .out_reciprocal(q_recip),.done_valid(q_done),.done_ready(phase==QUANT),
    .done_status(q_status),.first_bad_col(q_bad_col),.accepted_groups(q_accepted),
    .covered_groups(q_covered),.scale_issues(q_si),.scale_returns(q_sr),
    .recip_issues(q_ri),.recip_returns(q_rr),.amax_read_beats(q_ab),
    .replay_read_beats(q_rb),.mul_halves_issued(q_mi),.mul_halves_returned(q_mr));
  assign source_ready=phase==QUANT && q_in_ready;

  t4_dual_w_cache_v1 weight_cache(.load_cancel(1'b0),.*);
  assign lease_valid=phase==WLEASE;
  assign lease_slot=w_slot;
  assign lease_epoch=w_epoch;
  assign lease_k=256;
  assign lease_n=2;
  assign lease_weight_key=16'hff0c;
  assign lease_model_identity=run_model_identity;
  assign lease_numeric_identity=numeric_id;
  assign lease_task_context=linear_ctx;
  assign read_valid=phase==READ_W;
  assign read_slot=w_slot;
  assign read_epoch=w_epoch;
  assign read_tile=0;
  assign read_group={1'b0,group_index};
  assign read_pair=0;
  assign read_model_identity=run_model_identity;
  assign read_numeric_identity=numeric_id;
  assign read_task_context=linear_ctx;
  assign ret_ready=phase==RETURN_W;
  assign release_valid=phase==RELEASE_W;
  assign release_slot=w_slot;
  assign release_epoch=w_epoch;
  assign release_numeric_identity=numeric_id;
  assign release_task_context=linear_ctx;

  logic mac_cfg_ready,issue_ready;
  logic [159:0] short_identity;
  logic [3:0] commit_valid,commit_ready_mac,trace_valid;
  logic [767:0] commit_tag,trace_tag;
  logic [39:0] commit_tile;
  logic [31:0] commit_mask,commit_bad;
  logic [95:0] commit_phase;
  logic [1023:0] commit_ps,trace_payload;
  logic [7:0] trace_slot;
  logic [23:0] result_free,result_reserved,result_returned;
  logic [11:0] trace_free;
  logic mac_done,mac_error,mac_protocol;
  logic [63:0] mac_error_rank;
  logic [31:0] mac_bad;
  logic [26:0] accepted_stripes;
  function automatic logic [31:0] half_to_f32(input logic [15:0] h);
    logic [9:0] frac;
    logic [7:0] exp;
    integer shift;
    begin
      frac=h[9:0];exp=0;shift=0;
      if(h[14:10]==0) begin
        if(frac==0) half_to_f32={h[15],31'd0};
        else begin
          for(integer k=0;k<10;k++) if(!frac[9]) begin frac=frac<<1;shift=shift+1;end
          exp=8'(112-shift);
          half_to_f32={h[15],exp,frac[8:0],14'd0};
        end
      end else if(h[14:10]==31) half_to_f32={h[15],8'hff,h[9:0],13'd0};
      else begin exp=8'(h[14:10]+112);half_to_f32={h[15],exp,h[9:0],13'd0};end
    end
  endfunction
  logic [31:0] a_scale_f32;
  assign a_scale_f32=half_to_f32(a_scale[a_slot][group_index]);
  assign short_identity={linear_ctx[31:0],a_ref[31:0],w_epoch,64'd0};
  tm4tn8_microbench_v1 mac(
    .clk,.rst_n(datapath_rst_n),.config_valid(phase==CONFIG && !mac_configured),
    .config_ready(mac_cfg_ready),.config_k(16'd256),.config_n(16'd2),
    .config_rows(3'd1),.config_row0(16'd0),.config_identity(short_identity),
    .issue_valid(phase==ISSUE && bias_sent),.issue_ready,
    .issue_identity(short_identity[159:64]),.issue_version(4'd1),
    .issue_sequence({20'd0,group_index}),.issue_group(group_index),.issue_tile(10'd0),
    .issue_lane_mask(8'h03),.issue_trace_mask(4'd0),.issue_trace_lane(12'd0),
    .issue_a8({768'd0,a_q[a_slot][group_index]}),
    .issue_sa({96'd0,a_scale_f32}),
    .issue_w8(w_q),.issue_sw(w_scale),.commit_valid,.commit_ready(commit_ready_mac),
    .commit_tag,.commit_tile,.commit_lane_mask(commit_mask),.commit_bad_mask(commit_bad),
    .commit_phase,.commit_next_ps(commit_ps),.trace_valid,.trace_ready(4'hf),
    .trace_slot,.trace_tag,.trace_payload,.trace_ack_valid(4'd0),
    .trace_ack_slot(8'd0),.trace_ack_tag(768'd0),.trace_ack_ok(4'hf),
    .result_free,.result_reserved,.result_returned,.trace_free,.done_valid(mac_done),
    .done_error(mac_error),.protocol_failure(mac_protocol),.first_error_rank(mac_error_rank),
    .first_bad_element(mac_bad),.accepted_stripes);

  logic [255:0] bias_cfg;
  logic bias_cfg_ready,bias_loaded,bias_ready,tile_ready,bias_empty;
  logic [287:0] bias_data,out0_data,out1_data;
  logic out0_valid,out1_valid,writer_ready;
  logic bias_error,bias_protocol;
  logic [63:0] bias_error_rank,bias_bad;
  logic [31:0] bias_detail,bias_elements;
  logic [319:0] tile_data;
  assign bias_cfg={30'd0,1'b1,1'b0,32'd0,32'h37,32'd0,32'd0,32'd1,32'd2,32'd256};
  assign bias_data={14'd0,1'b1,8'h03,9'd0,w_bias};
  assign tile_data={37'd0,commit_bad[7:0],commit_mask[7:0],2'd0,9'd0,commit_ps[255:0]};
  assign commit_ready_mac={3'b111,((commit_tag[16:11]==6'd7) ? tile_ready : 1'b1)};
  tm1tn8_bias_output bias_output(
    .clk,.rst_n(datapath_rst_n),.cfg_tdata(bias_cfg),
    .cfg_tvalid(phase==CONFIG && !bias_configured),.cfg_tready(bias_cfg_ready),
    .bias_tdata(bias_data),.bias_tvalid(phase==ISSUE && group_index==0 && !bias_sent),
    .bias_tready(bias_ready),.bias_loaded,
    .tile_tdata(tile_data),.tile_tvalid(commit_valid[0] && commit_tag[16:11]==6'd7),
    .tile_tready(tile_ready),.out0_tdata(out0_data),.out0_tvalid(out0_valid),
    .out0_tready(writer_ready),.out1_tdata(out1_data),.out1_tvalid(out1_valid),
    .out1_tready(1'b0),.drain_empty(bias_empty),.command_done(phase==FINISHED),
    .numerical_error(bias_error),.first_error_rank(bias_error_rank),
    .first_bad_element(bias_bad),.first_error_detail(bias_detail),
    .protocol_error(bias_protocol),.committed_elements(bias_elements));
  logic writer_done,writer_debt_zero,writer_fault;
  logic [31:0] aw_count,w_count,b_count;
  logic [63:0] useful_bytes,physical_bytes;
  tm1tn8_axi512_writer writer(
    .clk,.rst_n(datapath_rst_n),.tile_valid(out0_valid),.tile_ready(writer_ready),
    .tile_f32(out0_data[255:0]),.tile_n0(out0_data[267:256]),
    .tile_row_local(out0_data[269:268]),.tile_row0(out0_data[279:270]),
    .tile_batch(out0_data[280]),.tile_lanes(out0_data[284:281]),.mode_qkv(1'b0),
    .rearm_valid(1'b0),.rearm_ready(),
    .flush_req(phase==OUTPUT_DRAIN),.flush_done(writer_done),.debt_zero(writer_debt_zero),
    .output_base,.output_span,.fault(writer_fault),.aw_count,.w_count,.b_count,
    .useful_bytes,.physical_bytes,.m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,
    .m_axi_awburst,.m_axi_awvalid,.m_axi_awready,.m_axi_wdata,.m_axi_wstrb,
    .m_axi_wlast,.m_axi_wvalid,.m_axi_wready,.m_axi_bresp,.m_axi_bvalid,.m_axi_bready);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      phase<=IDLE;done_valid<=0;done_status<=0;done_bad_element<='1;
      numeric_id<=0;quant_ctx<=0;linear_ctx<=0;source_ref<=0;a_ref<=0;ps_ref<=0;dst_ref<=0;
      a_slot<=0;w_slot<=0;w_epoch<=0;run_model_identity<=0;output_base<=0;output_span<=0;
      a_state<='0;a_epoch<='0;a_coverage<='0;quant_commits<=0;group_index<=0;
      mac_configured<=0;bias_configured<=0;bias_sent<=0;final_committed<=0;
      protocol_fault<=0;command_cycles<=0;w_q<=0;w_scale<=0;w_bias<=0;
      for(int s=0;s<2;s++) begin a_numeric_id[s]<=0;a_quant_ctx[s]<=0;end
    end else begin
      if(active) command_cycles<=command_cycles+1;
      if(start_valid && start_ready) begin
        done_status<=0;done_bad_element<='1;command_cycles<=0;
        if(!command_ok) begin done_status<=3;done_valid<=1;phase<=FINISHED;end
        else begin
          numeric_id<=cfg_numeric_identity;quant_ctx<=cfg_quant_context;linear_ctx<=cfg_linear_context;
          source_ref<=cfg_source_ref;a_ref<=cfg_a_ref;ps_ref<=cfg_ps_ref;dst_ref<=cfg_dst_ref;
          a_slot<=cfg_a_slot;w_slot<=cfg_w_slot;w_epoch<=cfg_w_epoch;
          run_model_identity<=load_model_identity;output_base<=cfg_output_base;output_span<=cfg_output_span;
          a_state[cfg_a_slot]<=A_FILLING;a_epoch[cfg_a_slot]<=cfg_a_ref[31:0];
          a_coverage[cfg_a_slot]<=0;a_numeric_id[cfg_a_slot]<=cfg_numeric_identity;
          a_quant_ctx[cfg_a_slot]<=cfg_quant_context;quant_commits<=0;group_index<=0;
          mac_configured<=0;bias_configured<=0;bias_sent<=0;final_committed<=0;
          protocol_fault<=0;phase<=QSTART;
        end
      end
      if(phase==QSTART && q_start_ready) phase<=QUANT;
      if(phase==QUANT && q_out_valid) begin
        if(q_out_group>=8 || {q_out_group,q_out_half}!={3'd0,quant_commits}) protocol_fault<=1;
        else begin
          a_q[a_slot][q_out_group][q_out_half*128 +:128]<=q_out;
          if(q_out_half) begin a_scale[a_slot][q_out_group]<=q_scale;a_coverage[a_slot][q_out_group]<=1;end
          quant_commits<=quant_commits+1;
        end
      end
      if(phase==QUANT && q_done) begin
        if(q_status!=0 || protocol_fault || quant_commits!=16 || a_coverage[a_slot]!=8'hff ||
           q_si!=q_sr || q_ri!=q_rr || q_mi!=q_mr) begin
          a_state[a_slot]<=A_INVALID;done_status<=q_status==1 ? 1 : 3;
          done_bad_element<=q_bad_col;done_valid<=1;phase<=FINISHED;
        end else begin a_state[a_slot]<=A_READY;phase<=WLEASE;end
      end
      if(phase==WLEASE && lease_ready) phase<=WLEASE_WAIT;
      if(phase==WLEASE_WAIT && lease_done) begin
        if(lease_error || a_state[a_slot]!=A_READY || a_numeric_id[a_slot]!=numeric_id ||
           a_quant_ctx[a_slot]!=quant_ctx) begin
          a_state[a_slot]<=A_INVALID;done_status<=3;done_valid<=1;phase<=FINISHED;
        end else begin a_state[a_slot]<=A_IN_USE;phase<=CONFIG;end
      end
      if(phase==CONFIG) begin
        if(!mac_configured && mac_cfg_ready) mac_configured<=1;
        if(!bias_configured && bias_cfg_ready) bias_configured<=1;
        if(mac_configured && bias_configured) phase<=READ_W;
      end
      if(phase==READ_W && read_ready) phase<=RETURN_W;
      if(phase==RETURN_W && ret_valid) begin
        if(ret_model_identity!=run_model_identity || ret_numeric_identity!=numeric_id ||
           ret_task_context!=linear_ctx || ret_epoch!=w_epoch || ret_slot!=w_slot ||
           ret_group!={1'b0,group_index} || ret_tile!=0 || ret_pair || ret_mask[0]!=8'h03)
          protocol_fault<=1;
        w_q<=ret_q[0];
        for(int lane=0;lane<8;lane++) w_scale[lane*32 +:32]<=half_to_f32(ret_scale[0][lane]);
        w_bias<=ret_bias[0];phase<=ISSUE;
      end
      if(phase==ISSUE && group_index==0 && !bias_sent && bias_ready) bias_sent<=1;
      if(phase==ISSUE && bias_sent && issue_ready) begin
        if(group_index==7) phase<=MAC_DRAIN;
        else begin group_index<=group_index+1;phase<=READ_W;end
      end
      if(commit_valid[0] && commit_ready_mac[0] && commit_tag[16:11]==7) final_committed<=1;
      if(phase==MAC_DRAIN && mac_done && bias_empty && final_committed) phase<=OUTPUT_DRAIN;
      if(phase==OUTPUT_DRAIN && writer_done && writer_debt_zero) begin
        done_status<=(mac_error || bias_error) ? 2 :
          (protocol_fault || mac_protocol || bias_protocol || writer_fault || aw_count!=b_count || w_count!=b_count) ? 3 : 0;
        if(mac_error) done_bad_element<=mac_bad;
        else if(bias_error) done_bad_element<=bias_bad[31:0];
        phase<=RELEASE_W;
      end
      if(phase==RELEASE_W && release_ready) phase<=RELEASE_WAIT;
      if(phase==RELEASE_WAIT && release_done) begin
        if(release_error) done_status<=3;
        a_state[a_slot]<=A_EMPTY;done_valid<=1;phase<=FINISHED;
      end
      if(phase==FINISHED && done_valid && done_ready) begin done_valid<=0;phase<=IDLE;end
    end
  end
endmodule
