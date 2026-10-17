`timescale 1ns/1ps
// Resident complete-matrix / legal row view controller. Cache endpoints are
// real full-A and full dual-W lease/read/return ports, never a C PS preload.
// The enclosing production 13BO caller/binding remains a separate dependency.
module tm4tn8_matrix_resident_v2 (
  input logic clk,rst_n,cancel,cfg_valid,
  output logic cfg_ready,cfg_reject,
  input logic cfg_owner_admitted,cfg_target_invalidated,
  input logic [15:0] cfg_K,cfg_N,
  input logic [2:0] cfg_rows,
  input logic [3:0] cfg_row_block_base,
  input logic [671:0] cfg_numeric_identity,
  input logic [95:0] cfg_linear_context,
  input logic [63:0] cfg_source_ref,cfg_a_ref,cfg_w_ref,cfg_ps_ref,cfg_dst_ref,
  input logic [3327:0] cfg_w_model_identity,
  input logic cfg_a_slot,cfg_w_slot,cfg_bias_kind,
  input logic [31:0] cfg_a_epoch,cfg_w_epoch,
  input logic [15:0] cfg_weight_key,
  input logic [1:0][63:0] cfg_bo_base,cfg_bo_span,cfg_region_base,cfg_region_span,
  input logic [63:0] cfg_row_stride_bytes,cfg_batch_stride_bytes,
  output logic owner_invalidate_valid,owner_retire_valid,owner_retire_success,
  output logic abort_parent,
  input logic owner_retire_ready,owner_retire_error,
  output logic [3:0] owner_retire_row_block_base,
  output logic [2:0] owner_retire_rows,
  output logic done_valid,
  input logic done_ready,
  output logic [15:0] done_status,
  output logic [63:0] done_first_error_rank,done_bad_element,command_cycles,
  output logic [31:0] actual_a_reads,actual_a_returns,actual_w_reads,actual_w_returns,
  output logic [31:0] actual_stripes,actual_ps_commits,actual_final_copies,
  output logic [1:0][31:0] actual_aw_count,actual_w_count,actual_b_count,
  output logic [1:0][63:0] m_axi_awaddr,
  output logic [1:0][7:0] m_axi_awlen,
  output logic [1:0][2:0] m_axi_awsize,
  output logic [1:0][1:0] m_axi_awburst,
  output logic [1:0] m_axi_awvalid,
  input logic [1:0] m_axi_awready,
  output logic [1:0][511:0] m_axi_wdata,
  output logic [1:0][63:0] m_axi_wstrb,
  output logic [1:0] m_axi_wlast,m_axi_wvalid,
  input logic [1:0] m_axi_wready,
  input logic [1:0][1:0] m_axi_bresp,
  input logic [1:0] m_axi_bvalid,
  output logic [1:0] m_axi_bready,
  output logic a_acquire_valid,
  input logic a_acquire_ready,a_acquire_done,a_acquire_error,
  output logic a_acquire_slot,
  output logic [31:0] a_acquire_slot_epoch,
  output logic [12:0] a_acquire_K,
  output logic [4:0] a_acquire_rows,
  output logic [671:0] a_acquire_numeric_identity,
  output logic [95:0] a_acquire_linear_context,
  output logic [63:0] a_acquire_a_ref,a_acquire_w_ref,a_acquire_dst_ref,
  output logic a_read_valid,
  input logic a_read_ready,a_read_error,
  output logic a_read_slot,
  output logic [31:0] a_read_slot_epoch,
  output logic [671:0] a_read_numeric_identity,
  output logic [95:0] a_read_linear_context,
  output logic [63:0] a_read_a_ref,
  output logic [3:0] a_read_row_block_base,
  output logic [2:0] a_read_rows,
  output logic [6:0] a_read_group,
  input logic a_ret_valid,
  output logic a_ret_ready,
  input logic a_ret_slot,
  input logic [31:0] a_ret_slot_epoch,
  input logic [671:0] a_ret_numeric_identity,
  input logic [95:0] a_ret_linear_context,
  input logic [63:0] a_ret_a_ref,
  input logic [3:0] a_ret_row_block_base,
  input logic [2:0] a_ret_rows,
  input logic [6:0] a_ret_group,
  input logic [3:0][255:0] a_ret_q,
  input logic [3:0][15:0] a_ret_scale,
  output logic a_release_valid,
  input logic a_release_ready,a_release_done,a_release_error,
  output logic a_release_slot,
  output logic [31:0] a_release_slot_epoch,
  output logic [671:0] a_release_numeric_identity,
  output logic [95:0] a_release_linear_context,
  output logic [63:0] a_release_a_ref,
  input logic a_read_debt_zero,
  output logic w_lease_valid,
  input logic w_lease_ready, w_lease_done, w_lease_error,
  output logic w_lease_slot,
  output logic [31:0] w_lease_epoch, w_lease_k, w_lease_n,
  output logic [15:0] w_lease_weight_key,
  output logic [3327:0] w_lease_model_identity,
  output logic [671:0] w_lease_numeric_identity,
  output logic [95:0] w_lease_task_context,
  output logic w_read_valid,
  input logic w_read_ready, w_read_error,
  output logic w_read_slot,
  output logic [31:0] w_read_epoch,
  output logic [15:0] w_read_tile,
  output logic [7:0] w_read_group,
  output logic w_read_pair,
  output logic [3327:0] w_read_model_identity,
  output logic [671:0] w_read_numeric_identity,
  output logic [95:0] w_read_task_context,
  input logic w_ret_valid,
  output logic w_ret_ready,
  input logic w_ret_slot, w_ret_pair,
  input logic [31:0] w_ret_epoch,
  input logic [15:0] w_ret_tile,
  input logic [7:0] w_ret_group,
  input logic [3327:0] w_ret_model_identity,
  input logic [671:0] w_ret_numeric_identity,
  input logic [95:0] w_ret_task_context,
  input logic [1:0][7:0][255:0] w_ret_q,
  input logic [1:0][7:0][15:0] w_ret_scale,
  input logic [1:0][7:0][31:0] w_ret_bias,
  input logic [1:0][7:0] w_ret_mask,
  output logic w_release_valid,
  input logic w_release_ready, w_release_done, w_release_error,
  output logic w_release_slot,
  output logic [31:0] w_release_epoch,
  output logic [671:0] w_release_numeric_identity,
  output logic [95:0] w_release_task_context
);
  typedef enum logic [3:0] {IDLE,ACQUIRE_A,LEASE_W,SETUP,READ_A,WAIT_A,
    STREAM,DRAIN,FLUSH,RELEASE_A,RELEASE_W,OWNER_RETIRE,REPORT} state_t;
  state_t state;
  logic [15:0] K,N,weight_key;
  logic [7:0] G,group_index;
  logic [9:0] T,request_tile,return_tile,block_start;
  logic [31:0] schedule_ordinal;
  logic [2:0] rows;
  logic [3:0] row_block_base;
  logic [671:0] numeric_id;
  logic [95:0] parent_context,view_context;
  logic [63:0] source_ref,a_ref,w_ref,ps_ref,dst_ref;
  logic [3327:0] model_id;
  logic a_slot,w_slot,bias_kind,qkv,configured,a_leased,w_leased;
  logic a_acquire_pending,w_lease_pending;
  // An accepted cache read is debt even before its held return becomes valid.
  logic [31:0] w_pending_reads;
  logic [31:0] a_epoch,w_epoch;
  logic [1:0][63:0] bo_base,bo_span,region_base,region_span;
  logic [63:0] row_stride,batch_stride;
  logic protocol_fault,numeric_fault,command_ok,a_return_ok,w_return_ok;
  logic [1023:0] resident_a;
  logic [127:0] resident_sa;
  logic [159:0] frontend_identity;
  logic [31:0] logical_sequence;
  logic [7:0] lane_mask;
  logic setup_fire,front_cfg_ready,adapter_cfg_ready,bias_cfg_ready;
  logic front_issue_valid,front_issue_ready,front_done,front_error,front_protocol;
  logic [26:0] front_accepted;
  logic [63:0] front_rank;
  logic [31:0] front_bad;
  logic [3:0] commit_valid,commit_ready,final_valid,final_ready;
  logic [767:0] commit_tag;
  logic [39:0] commit_tile;
  logic [31:0] commit_mask,commit_bad;
  logic [95:0] commit_phase;
  logic [1023:0] commit_ps;
  logic [23:0] result_free,result_reserved,result_returned;
  logic [11:0] trace_free;
  logic [415:0] adapter_packet,bias_packet,weight_bias_packet;
  logic adapter_valid,adapter_ready,adapter_debt,adapter_coverage,adapter_protocol;
  logic bias_input_valid,bias_ready,bias_loaded,bias_valid,bias_output_ready;
  logic bias_debt,bias_coverage,bias_protocol,bias_numerical;
  logic [63:0] bias_rank,bias_bad;
  logic [31:0] bias_detail,bias_committed,bias_native_issues,bias_native_returns,bias_helper_issues;
  logic [31:0] final_copied,final_retired;
  logic [1:0] writer_cfg_ready,writer_packet_ready,writer_flush_ready,writer_flush_done;
  logic [1:0] writer_debt,writer_coverage,writer_fault,flush_seen;
  logic [1:0][15:0] writer_status;
  logic [1:0][31:0] writer_elements;
  logic [1:0][63:0] writer_rank,writer_bad,writer_useful,writer_physical;
  logic packet_shard,datapath_retire,any_fault,all_writer_debt,all_writer_coverage;
  logic [3:0] final_skip_valid,final_skip_ready;
  logic [9:0] final_skip_tile;
  logic [7:0] final_skip_mask;
  logic stop_numerical_checks,cancel_publication;
  logic [255:0] restored_w_scale;

  function automatic logic shape_ok(input logic [15:0] k,input logic [15:0] n);
    return (k==1024 && (n==3072 || n==1024 || n==5248 || n==4096)) ||
      ((k==2624 || k==4096) && n==1024) || (k==256 && n==2);
  endfunction
  // Exact binary16 decoding; no multiplication/reassociation in scale restore.
  function automatic logic [31:0] half_to_f32(input logic [15:0] h);
    logic [4:0] e;logic [9:0] f;integer shift;
    e=h[14:10];f=h[9:0];shift=0;
    if(e==0) begin
      if(f==0)return {h[15],31'd0};
      while(!f[9])begin f=f<<1;shift=shift+1;end
      return {h[15],8'(112-shift),f[8:0],14'd0};
    end
    if(e==31)return {h[15],8'hff,h[9:0],13'd0};
    return {h[15],8'(int'(e)+112),h[9:0],13'd0};
  endfunction
  always_comb begin
    command_ok=cfg_owner_admitted && shape_ok(cfg_K,cfg_N) &&
      (cfg_rows==1 || cfg_rows==4) && cfg_linear_context[95:88]>=1 &&
      cfg_linear_context[95:88]<=16 &&
      5'(cfg_row_block_base)+5'(cfg_rows)<=cfg_linear_context[95:88] &&
      cfg_numeric_identity[63:0]!=0 && cfg_numeric_identity[127:64]!=0 &&
      cfg_numeric_identity[143:128]>=1 && cfg_numeric_identity[143:128]<=2 &&
      cfg_numeric_identity[159:144]>=64 && cfg_numeric_identity[159:144]<=1024 &&
      cfg_K==2624 && cfg_N==1024 && cfg_rows==4 &&
      cfg_linear_context[31:0]!=0 && cfg_a_epoch!=0 && cfg_w_epoch!=0 &&
      cfg_a_ref[39:32]==8'h22 && cfg_w_ref[39:32]==8'h23 && cfg_ps_ref[39:32]==8'h24 &&
      cfg_a_ref[47:40]==8'(cfg_a_slot) && cfg_w_ref[47:40]==8'(cfg_w_slot) &&
      cfg_a_ref[31:0]==cfg_a_epoch && cfg_w_ref[31:0]==cfg_w_epoch &&
      cfg_source_ref[63:56]==0 && cfg_a_ref[63:56]==0 && cfg_w_ref[63:56]==0 &&
      cfg_ps_ref[63:56]==0 && cfg_dst_ref[63:56]==0 &&
      cfg_w_model_identity[511:0]==cfg_numeric_identity[671:160];
    a_return_ok=a_ret_slot==a_slot && a_ret_slot_epoch==a_epoch &&
      a_ret_numeric_identity==numeric_id && a_ret_linear_context==parent_context &&
      a_ret_a_ref==a_ref && a_ret_row_block_base==row_block_base &&
      a_ret_rows==rows && a_ret_group==group_index[6:0];
    logical_sequence=32'(group_index)*32'(T)+32'(return_tile);
    schedule_ordinal=32'(block_start/10'd64)*32'(G)*32'd64+
      32'(group_index)*32'd64+32'(return_tile-block_start);
    lane_mask=return_tile==T-1 && N[2:0]!=0 ? 8'((1<<N[2:0])-1) : 8'hff;
    w_return_ok=w_ret_slot==w_slot && w_ret_epoch==w_epoch && !w_ret_pair &&
      w_ret_tile==16'(return_tile) && w_ret_group==group_index &&
      w_ret_model_identity==model_id && w_ret_numeric_identity==numeric_id &&
      w_ret_task_context==parent_context && w_ret_mask[0]==lane_mask &&
      logical_sequence<32'h08000000 && schedule_ordinal==actual_stripes;
    restored_w_scale=0;
    for(int lane=0;lane<8;lane++)
      restored_w_scale[lane*32+:32]=half_to_f32(w_ret_scale[0][lane]);
    frontend_identity=0;
    frontend_identity[159:64]={parent_context[31:0],a_ref[31:0],w_ref[31:0]};
    weight_bias_packet=0;
    weight_bias_packet[415:288]={dst_ref[31:0],w_ref[31:0],a_ref[31:0],parent_context[31:0]};
    weight_bias_packet[255:0]=bias_kind ? w_ret_bias[0] : 256'd0;
    weight_bias_packet[265:256]=return_tile;
    weight_bias_packet[273:266]=lane_mask;
    weight_bias_packet[274]=bias_kind;
    weight_bias_packet[275]=return_tile==T-1;
    final_valid=0;commit_ready=4'hf;
    for(int r=0;r<4;r++)
      if(commit_valid[r] && {commit_tag[r*192+160],commit_tag[r*192+11+:6]}==G-1 &&
         !protocol_fault && !cancel) begin
        final_valid[r]=1;commit_ready[r]=final_ready[r];
      end
  end
  assign cfg_ready=state==IDLE && !done_valid && !cancel;
  assign any_fault=cancel || protocol_fault || numeric_fault ||
      (configured && (front_protocol || adapter_protocol || bias_protocol || bias_numerical || (|writer_fault)));
  // Numerical failure still requires all later parent views for rank ordering.
  // Protocol/AXI failure stops the parent after safe physical drain.
  assign abort_parent=state!=IDLE && (cancel || protocol_fault ||
      (configured && (front_protocol || adapter_protocol || bias_protocol || (|writer_fault))));
  assign owner_invalidate_valid=state!=IDLE && state!=REPORT && any_fault;
  assign owner_retire_valid=state==OWNER_RETIRE;
  assign owner_retire_success=!any_fault && all_writer_coverage && adapter_coverage && bias_coverage;
  assign owner_retire_row_block_base=row_block_base;
  assign owner_retire_rows=rows;
  assign datapath_retire=state==OWNER_RETIRE && owner_retire_ready;
  assign setup_fire=state==SETUP && !cancel && !protocol_fault && front_cfg_ready && adapter_cfg_ready && bias_cfg_ready &&
      writer_cfg_ready[0] && (!qkv || writer_cfg_ready[1]);
  assign all_writer_debt=writer_debt[0] && (!qkv || writer_debt[1]);
  assign all_writer_coverage=writer_coverage[0] && (!qkv || writer_coverage[1]);
  assign packet_shard=qkv && bias_packet[262];
  assign stop_numerical_checks=cancel || protocol_fault ||
      (configured && (front_protocol || adapter_protocol || bias_protocol || (|writer_fault)));
  assign cancel_publication=stop_numerical_checks || cfg_target_invalidated ||
      numeric_fault || (configured && (front_rank!='1 || bias_numerical));
  assign front_issue_valid=(state==STREAM && !cancel && !protocol_fault && w_ret_valid && w_return_ok &&
      (group_index!=0 || bias_ready) && !w_read_error && !front_protocol &&
      !adapter_protocol && !bias_protocol && !(|writer_fault)) ||
      (state==DRAIN && protocol_fault && configured && !front_done && !front_protocol);
  assign bias_input_valid=state==STREAM && !cancel && !protocol_fault && group_index==0 && w_ret_valid &&
      w_return_ok && front_issue_ready;
  assign adapter_ready=stop_numerical_checks ? 1'b1 : bias_ready_for_ps;
  wire bias_ready_for_ps;
  assign bias_output_ready=cancel_publication ? 1'b1 : writer_packet_ready[packet_shard];
  assign a_acquire_valid=state==ACQUIRE_A && !cancel && !protocol_fault && !a_acquire_pending && !a_acquire_done;
  assign a_acquire_slot=a_slot;assign a_acquire_slot_epoch=a_epoch;
  assign a_acquire_K=K[12:0];assign a_acquire_rows=parent_context[95:88];
  assign a_acquire_numeric_identity=numeric_id;assign a_acquire_linear_context=parent_context;
  assign a_acquire_a_ref=a_ref;assign a_acquire_w_ref=w_ref;assign a_acquire_dst_ref=dst_ref;
  assign a_read_valid=state==READ_A && !cancel && !protocol_fault;
  assign a_read_slot=a_slot;assign a_read_slot_epoch=a_epoch;
  assign a_read_numeric_identity=numeric_id;assign a_read_linear_context=parent_context;
  assign a_read_a_ref=a_ref;assign a_read_row_block_base=row_block_base;
  assign a_read_rows=rows;assign a_read_group=group_index[6:0];
  assign a_ret_ready=state==WAIT_A || state==DRAIN;
  assign a_release_valid=state==RELEASE_A && a_leased && !a_release_done;
  assign a_release_slot=a_slot;assign a_release_slot_epoch=a_epoch;
  assign a_release_numeric_identity=numeric_id;assign a_release_linear_context=parent_context;
  assign a_release_a_ref=a_ref;
  assign w_lease_valid=state==LEASE_W && !cancel && !protocol_fault && !w_lease_pending && !w_lease_done;
  assign w_lease_slot=w_slot;assign w_lease_epoch=w_epoch;
  assign w_lease_k=K;assign w_lease_n=N;assign w_lease_weight_key=weight_key;
  assign w_lease_model_identity=model_id;assign w_lease_numeric_identity=numeric_id;
  assign w_lease_task_context=parent_context;
  assign w_read_valid=state==STREAM && !cancel && request_tile<block_start+10'd64 && !protocol_fault && !w_read_error &&
      !front_protocol && !adapter_protocol && !bias_protocol && !(|writer_fault) &&
      !(w_ret_valid && !w_return_ok);
  assign w_read_slot=w_slot;assign w_read_epoch=w_epoch;
  assign w_read_tile=16'(request_tile);assign w_read_group=group_index;assign w_read_pair=0;
  assign w_read_model_identity=model_id;assign w_read_numeric_identity=numeric_id;
  assign w_read_task_context=parent_context;
  assign w_ret_ready=state==DRAIN || (state==STREAM && !cancel && !protocol_fault &&
      (!w_return_ok || (front_issue_ready && (group_index!=0 || bias_ready))));
  assign w_release_valid=state==RELEASE_W && w_leased && !w_release_done;
  assign w_release_slot=w_slot;assign w_release_epoch=w_epoch;
  assign w_release_numeric_identity=numeric_id;assign w_release_task_context=parent_context;

  tm4tn8_sync_ps_front_v2 #(.KB2_BLOCKED_DOWN(1'b1)) frontend (
    .clk,.rst_n,.config_valid(setup_fire),.config_ready(front_cfg_ready),
    .config_k(K),.config_n(N),.config_rows(rows),.config_row0(16'(row_block_base)),
    .config_identity(frontend_identity),.issue_valid(front_issue_valid),.issue_ready(front_issue_ready),
    .issue_identity(state==DRAIN ? frontend_identity[159:64]^96'd1 : frontend_identity[159:64]),
    .issue_version(4'd1),.issue_sequence(logical_sequence[26:0]),
    .issue_group(group_index[6:0]),.issue_tile(return_tile),.issue_lane_mask(lane_mask),
    .issue_trace_mask(4'd0),.issue_trace_lane(12'd0),
    .issue_a8(resident_a),.issue_sa(resident_sa),.issue_w8(w_ret_q[0]),.issue_sw(restored_w_scale),
    .commit_valid,.commit_ready,.commit_tag,.commit_tile,.commit_lane_mask(commit_mask),
    .commit_bad_mask(commit_bad),.commit_phase,.commit_next_ps(commit_ps),
    .final_skip_valid,.final_skip_ready,.final_skip_tile,.final_skip_mask,
    .trace_valid(),.trace_ready(4'd0),.trace_slot(),.trace_tag(),.trace_payload(),
    .trace_ack_valid(4'd0),.trace_ack_slot(8'd0),.trace_ack_tag(768'd0),.trace_ack_ok(4'hf),
    .result_free,.result_reserved,.result_returned,.trace_free,.done_valid(front_done),
    .done_error(front_error),.protocol_failure(front_protocol),.first_error_rank(front_rank),
    .first_bad_element(front_bad),.accepted_stripes(front_accepted));
  tm4tn8_final_ps_adapter_v1 final_adapter (
    .clk,.rst_n,.cfg_valid(setup_fire),.cfg_ready(adapter_cfg_ready),.cfg_owner_admitted(a_leased && w_leased && !protocol_fault),
    .cfg_K(K),.cfg_N(N),.cfg_rows(rows),.cfg_G_count(G),.cfg_T_count(T),
    .cfg_numeric_identity(numeric_id),.cfg_linear_context(view_context),
    .cfg_source_ref(source_ref),.cfg_a_ref(a_ref),.cfg_w_ref(w_ref),.cfg_ps_ref(ps_ref),.cfg_dst_ref(dst_ref),
    .cfg_w_model_identity(model_id),.final_valid,.final_ready,.final_tag(commit_tag),
    .final_skip_valid,.final_skip_ready,.final_skip_tile,.final_skip_mask,
    .final_tile(commit_tile),.final_mask(commit_mask),.final_bad(commit_bad),.final_ps(commit_ps),
    .out_valid(adapter_valid),.out_ready(adapter_ready),.out_data(adapter_packet),
    .command_retire(datapath_retire),.debt_zero(adapter_debt),.coverage_complete(adapter_coverage),
    .protocol_error(adapter_protocol),.copied_packets(final_copied),.retired_packets(final_retired));
  tm4tn8_bias_output_v1 bias_output (
    .clk,.rst_n,.cfg_valid(setup_fire),.cfg_ready(bias_cfg_ready),.cfg_owner_admitted(a_leased && w_leased && !protocol_fault),
    .cfg_K(K),.cfg_N(N),.cfg_rows(rows),.cfg_row_block_base(row_block_base),.cfg_G_count(G),.cfg_T_count(T),
    .cfg_numeric_identity(numeric_id),.cfg_linear_context(view_context),
    .cfg_source_ref(source_ref),.cfg_a_ref(a_ref),.cfg_w_ref(w_ref),.cfg_ps_ref(ps_ref),.cfg_dst_ref(dst_ref),
    .cfg_w_model_identity(model_id),.bias_valid(bias_input_valid),.bias_ready,.bias_loaded,
    .bias_data(weight_bias_packet),.ps_valid(adapter_valid && !stop_numerical_checks),.ps_ready(bias_ready_for_ps),
    .ps_data(adapter_packet),.out_valid(bias_valid),.out_ready(bias_output_ready),.out_data(bias_packet),
    .command_retire(datapath_retire),.debt_zero(bias_debt),.coverage_complete(bias_coverage),
    .protocol_error(bias_protocol),.numerical_error(bias_numerical),.first_error_rank(bias_rank),
    .first_bad_element(bias_bad),.first_error_detail(bias_detail),.committed_elements(bias_committed),
    .native_lane_issues(bias_native_issues),.native_lane_returns(bias_native_returns),
    .helper_lane_issues(bias_helper_issues));
  for(genvar s=0;s<2;s++)begin:writers
    tm4tn8_axi512_writer_v1 #(.SHARD(s)) writer (
      .clk,.rst_n,.cfg_valid(setup_fire && (s==0 || qkv)),.cfg_ready(writer_cfg_ready[s]),
      .cfg_owner_admitted(a_leased && w_leased && !protocol_fault),.cfg_target_invalidated,
      .cfg_K(K),.cfg_N(N),.cfg_row0(view_context[87:72]),.cfg_rows(rows),
      .cfg_batch(parent_context[63:56]),.cfg_op(parent_context[39:32]),.cfg_G_count(G),.cfg_T_count(T),
      .cfg_numeric_identity(numeric_id),.cfg_linear_context(view_context),
      .cfg_source_ref(source_ref),.cfg_a_ref(a_ref),.cfg_w_ref(w_ref),.cfg_ps_ref(ps_ref),.cfg_dst_ref(dst_ref),
      .cfg_w_model_identity(model_id),.cfg_bo_base(bo_base),.cfg_bo_span(bo_span),
      .cfg_region_base(region_base),.cfg_region_span(region_span),
      .cfg_row_stride_bytes(row_stride),.cfg_batch_stride_bytes(batch_stride),
      .packet_valid(bias_valid && !cancel_publication && packet_shard==s),.packet_ready(writer_packet_ready[s]),
      .packet_data(bias_packet),.flush_valid(state==FLUSH && (s==0 || qkv) && !flush_seen[s]),
      .flush_ready(writer_flush_ready[s]),.flush_done(writer_flush_done[s]),.debt_zero(writer_debt[s]),
      .coverage_complete(writer_coverage[s]),.command_retire(datapath_retire),.cancel_publication,
      .fault(writer_fault[s]),.status(writer_status[s]),.first_error_rank(writer_rank[s]),
      .first_bad_element(writer_bad[s]),.aw_count(actual_aw_count[s]),.w_count(actual_w_count[s]),
      .b_count(actual_b_count[s]),.accepted_elements(writer_elements[s]),
      .useful_bytes(writer_useful[s]),.physical_bytes(writer_physical[s]),
      .m_axi_awaddr(m_axi_awaddr[s]),.m_axi_awlen(m_axi_awlen[s]),.m_axi_awsize(m_axi_awsize[s]),
      .m_axi_awburst(m_axi_awburst[s]),.m_axi_awvalid(m_axi_awvalid[s]),.m_axi_awready(m_axi_awready[s]),
      .m_axi_wdata(m_axi_wdata[s]),.m_axi_wstrb(m_axi_wstrb[s]),.m_axi_wlast(m_axi_wlast[s]),
      .m_axi_wvalid(m_axi_wvalid[s]),.m_axi_wready(m_axi_wready[s]),.m_axi_bresp(m_axi_bresp[s]),
      .m_axi_bvalid(m_axi_bvalid[s]),.m_axi_bready(m_axi_bready[s]));
  end
  assign actual_final_copies=final_copied;

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      state<=IDLE;done_valid<=0;done_status<=0;cfg_reject<=0;
      configured<=0;a_leased<=0;w_leased<=0;protocol_fault<=0;numeric_fault<=0;
      a_acquire_pending<=0;w_lease_pending<=0;
      w_pending_reads<=0;
      command_cycles<=0;actual_a_reads<=0;actual_a_returns<=0;actual_w_reads<=0;
      actual_w_returns<=0;actual_stripes<=0;actual_ps_commits<=0;flush_seen<=0;
      done_first_error_rank<='1;done_bad_element<='1;
    end else begin
      cfg_reject<=0;
      if(state!=IDLE && state!=REPORT)command_cycles<=command_cycles+1;
      if(cfg_valid && cfg_ready)begin
        cfg_reject<=!command_ok;done_status<=command_ok ? 0 : 7;
        protocol_fault<=!command_ok;numeric_fault<=0;configured<=0;a_leased<=0;w_leased<=0;
        a_acquire_pending<=0;w_lease_pending<=0;
        w_pending_reads<=0;
        K<=cfg_K;N<=cfg_N;G<=cfg_K/32;T<=(cfg_N+7)/8;rows<=cfg_rows;
        row_block_base<=cfg_row_block_base;numeric_id<=cfg_numeric_identity;
        parent_context<=cfg_linear_context;view_context<=cfg_linear_context;
        view_context[95:88]<=8'(cfg_rows);
        view_context[87:72]<=cfg_linear_context[87:72]+16'(cfg_row_block_base);
        source_ref<=cfg_source_ref;a_ref<=cfg_a_ref;w_ref<=cfg_w_ref;
        ps_ref<=cfg_ps_ref;dst_ref<=cfg_dst_ref;model_id<=cfg_w_model_identity;
        a_slot<=cfg_a_slot;w_slot<=cfg_w_slot;a_epoch<=cfg_a_epoch;w_epoch<=cfg_w_epoch;
        weight_key<=cfg_weight_key;bias_kind<=cfg_bias_kind;qkv<=cfg_linear_context[39:32]==8'h30;
        bo_base<=cfg_bo_base;bo_span<=cfg_bo_span;region_base<=cfg_region_base;region_span<=cfg_region_span;
        row_stride<=cfg_row_stride_bytes;batch_stride<=cfg_batch_stride_bytes;
        group_index<=0;request_tile<=0;return_tile<=0;block_start<=0;command_cycles<=1;
        actual_a_reads<=0;actual_a_returns<=0;actual_w_reads<=0;actual_w_returns<=0;
        actual_stripes<=0;actual_ps_commits<=0;flush_seen<=0;done_first_error_rank<='1;done_bad_element<='1;
        state<=command_ok ? ACQUIRE_A : REPORT;
        if(!command_ok)done_valid<=1;
      end else begin
        if(cancel && state!=IDLE && state!=REPORT)protocol_fault<=1;
        if(a_acquire_valid && a_acquire_ready)a_acquire_pending<=1;
        if(w_lease_valid && w_lease_ready)w_lease_pending<=1;
        if(a_acquire_done)a_acquire_pending<=0;
        if(w_lease_done)w_lease_pending<=0;
        if((w_ret_valid && w_ret_ready) || w_read_error)
          w_pending_reads<=w_pending_reads+32'(w_read_valid && w_read_ready)-
              32'(w_ret_valid && w_ret_ready)-32'(w_read_error);
        else if(w_read_valid && w_read_ready)w_pending_reads<=w_pending_reads+1;
        if(a_read_valid && a_read_ready)actual_a_reads<=actual_a_reads+1;
        if(w_read_valid && w_read_ready)begin actual_w_reads<=actual_w_reads+1;request_tile<=request_tile+1;end
        if(a_ret_valid && a_ret_ready)actual_a_returns<=actual_a_returns+1;
        if(w_ret_valid && w_ret_ready)actual_w_returns<=actual_w_returns+1;
        if(configured)actual_ps_commits<=actual_ps_commits+32'($countones(commit_valid & commit_ready));
        if(configured && (front_rank!='1 || bias_numerical))numeric_fault<=1;
        if(configured && bias_rank<front_rank && bias_rank<done_first_error_rank)begin
          done_first_error_rank<=bias_rank;done_bad_element<=bias_bad;
        end else if(configured && front_rank<done_first_error_rank)begin
          done_first_error_rank<=front_rank;done_bad_element<=64'(front_bad);
        end
        for(int s=0;s<2;s++)if(configured && writer_flush_done[s])flush_seen[s]<=1;
        if(configured && (front_protocol || adapter_protocol || bias_protocol || (|writer_fault)))protocol_fault<=1;
        if((cancel || protocol_fault || (configured && (front_protocol || adapter_protocol || bias_protocol || (|writer_fault)))) &&
           (state==SETUP || state==READ_A || state==WAIT_A || state==STREAM))begin
          state<=DRAIN;
        end else case(state)
          ACQUIRE_A:if(a_acquire_done)begin
            if(a_acquire_error)begin protocol_fault<=1;state<=RELEASE_A;end
            else begin a_leased<=1;state<=cancel || protocol_fault ? RELEASE_A : LEASE_W;end
          end else if((cancel || protocol_fault) && !a_acquire_pending)state<=RELEASE_A;
          LEASE_W:if(w_lease_done)begin
            if(w_lease_error)begin protocol_fault<=1;state<=RELEASE_A;end
            else begin w_leased<=1;state<=cancel || protocol_fault ? RELEASE_A : SETUP;end
          end else if((cancel || protocol_fault) && !w_lease_pending)state<=RELEASE_A;
          SETUP:if(setup_fire)begin configured<=1;state<=READ_A;end
          READ_A:if(a_read_valid && a_read_ready)state<=WAIT_A;
          WAIT_A:begin
            if(a_read_error)begin protocol_fault<=1;state<=DRAIN;end
            else if(a_ret_valid && a_ret_ready)begin
              if(!a_return_ok)begin protocol_fault<=1;state<=DRAIN;end
              else begin
                resident_a<=a_ret_q;
                for(int r=0;r<4;r++)resident_sa[r*32+:32]<=half_to_f32(a_ret_scale[r]);
                request_tile<=block_start;return_tile<=block_start;state<=STREAM;
              end
            end
          end
          STREAM:begin
            if(w_read_error || (w_ret_valid && w_ret_ready && !w_return_ok))begin
              protocol_fault<=1;state<=DRAIN;
            end else if(w_ret_valid && w_ret_ready)begin
              actual_stripes<=actual_stripes+1;return_tile<=return_tile+1;
              if(return_tile==block_start+10'd63)begin
                if(group_index==G-1)begin
                  if(block_start+10'd64==T)state<=DRAIN;
                  else begin block_start<=block_start+10'd64;group_index<=0;state<=READ_A;end
                end else begin group_index<=group_index+1;state<=READ_A;end
              end
            end
          end
          DRAIN:if((!configured || front_done) && !a_ret_valid && !w_ret_valid && w_pending_reads==0 && a_read_debt_zero &&
                    adapter_debt && bias_debt)state<=configured ? FLUSH : RELEASE_A;
          FLUSH:begin
            if(flush_seen[0] && (!qkv || flush_seen[1]) && all_writer_debt)state<=RELEASE_A;
          end
          RELEASE_A:if(!a_leased || a_release_done)begin
            if(a_release_done && a_release_error)protocol_fault<=1;
            a_leased<=0;state<=RELEASE_W;
          end
          RELEASE_W:if(!w_leased || w_release_done)begin
            if(w_release_done && w_release_error)protocol_fault<=1;
            w_leased<=0;state<=OWNER_RETIRE;
          end
          OWNER_RETIRE:if(owner_retire_ready)begin
            done_status<=owner_retire_error || protocol_fault ? 7 : numeric_fault || bias_numerical ? 15 : 0;
            done_valid<=1;state<=REPORT;
          end
          REPORT:if(done_valid && done_ready)begin done_valid<=0;state<=IDLE;end
          default:begin end
        endcase
      end
    end
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n && ((w_ret_valid && w_ret_ready) || w_read_error))begin
    assert(w_pending_reads+32'(w_read_valid && w_read_ready)>=
        32'(w_ret_valid && w_ret_ready)+32'(w_read_error))
      else $fatal(1,"matrix W return/error without accepted read debt");
  end
  always_ff @(posedge clk)if(rst_n && state==STREAM && w_ret_valid && w_ret_ready && w_return_ok &&
                           !w_read_error && !front_protocol && !adapter_protocol &&
                           !bias_protocol && !(|writer_fault))begin
    assert(front_issue_valid && front_issue_ready)else $fatal(1,"matrix W retirement without frontend E0");
    assert(actual_stripes==schedule_ordinal)else $fatal(1,"matrix blocked schedule ordinal mismatch");
  end
`endif
endmodule
