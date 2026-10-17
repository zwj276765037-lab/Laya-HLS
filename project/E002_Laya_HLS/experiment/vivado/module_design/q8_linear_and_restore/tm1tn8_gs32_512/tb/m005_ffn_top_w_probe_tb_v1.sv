// KB0 observation-only derivative of resident_regression_02 frozen TB.
// DUT/model/gold/stimulus are unchanged except real done response consumption.
`timescale 1ns/1ps
// Four-row same-runtime real GATE AXI -> quant -> shared dualA -> KB1 Down.
`default_nettype none
module m005_ffn_top_tb_v1;
  logic [31:0] accepted_events;
  logic [31:0] accepted_requests;
  logic [5:0] active_owners;
  logic  adapter_pending_zero;
  logic  base_configured;
  logic [63:0] destination_axi_awaddr;
  logic [1:0] destination_axi_awburst;
  logic [7:0] destination_axi_awlen;
  logic  destination_axi_awready;
  logic [2:0] destination_axi_awsize;
  logic  destination_axi_awvalid;
  logic  destination_axi_bready;
  logic [1:0] destination_axi_bresp;
  logic  destination_axi_bvalid;
  logic [511:0] destination_axi_wdata;
  logic  destination_axi_wlast;
  logic  destination_axi_wready;
  logic [63:0] destination_axi_wstrb;
  logic  destination_axi_wvalid;
  logic [31:0] forwarded_aw;
  logic [31:0] forwarded_w;
  logic  job_active;
  logic [63:0] last_event_seq;
  logic  ledger_domain_drained;
  logic  ledger_protocol_error;
  logic  ledger_scope_active;
  logic  monitor_coverage_complete;
  logic  monitor_drained;
  logic [63:0] monitor_observed0;
  logic  monitor_scope_active;
  logic [15:0] monitor_status;
  logic [511:0] producer_completion_din;
  logic  producer_completion_full_n;
  logic  producer_completion_write;
  logic [511:0] producer_request_dout;
  logic  producer_request_empty_n;
  logic  producer_request_read;
  logic [511:0] provenance_cmd_din;
  logic  provenance_cmd_full_n;
  logic  provenance_cmd_write;
  logic [511:0] provenance_rsp_dout;
  logic  provenance_rsp_empty_n;
  logic  provenance_rsp_read;
  logic [5:0] published_owners;
  logic [31:0] retired_b;
  logic [31:0] retired_responses;
  logic [31:0] semantic_rejections;
  logic  shell_protocol_error;
  logic [63:0] source_axi_araddr;
  logic [1:0] source_axi_arburst;
  logic [7:0] source_axi_arlen;
  logic  source_axi_arready;
  logic [2:0] source_axi_arsize;
  logic  source_axi_arvalid;
  logic [511:0] source_axi_rdata;
  logic  source_axi_rlast;
  logic  source_axi_rready;
  logic [1:0] source_axi_rresp;
  logic  source_axi_rvalid;
  logic [31:0] source_outstanding_beats;
  logic [31:0] terminal_tasks;
  logic  quant_axi_accounting_error;
  logic  quant_axi_burst_in_flight;
  logic [8:0] quant_axi_beats_remaining;
  logic clk;
  logic rst_n;
  logic cfg_valid;
  logic cfg_ready;
  logic cfg_reject;
  logic cfg_owner_admitted;
  logic cfg_target_invalidated;
  logic [15:0] cfg_K;
  logic [15:0] cfg_N;
  logic [2:0] cfg_rows;
  logic [3:0] cfg_row_block_base;
  logic [671:0] cfg_numeric_identity;
  logic [95:0] cfg_linear_context;
  logic [63:0] cfg_source_ref;
  logic [63:0] cfg_a_ref;
  logic [63:0] cfg_w_ref;
  logic [63:0] cfg_ps_ref;
  logic [63:0] cfg_dst_ref;
  logic [3327:0] cfg_w_model_identity;
  logic cfg_a_slot;
  logic cfg_w_slot;
  logic cfg_bias_kind;
  logic [31:0] cfg_a_epoch;
  logic [31:0] cfg_w_epoch;
  logic [15:0] cfg_weight_key;
  logic [1:0][63:0] cfg_bo_base;
  logic [1:0][63:0] cfg_bo_span;
  logic [1:0][63:0] cfg_region_base;
  logic [1:0][63:0] cfg_region_span;
  logic [63:0] cfg_row_stride_bytes;
  logic [63:0] cfg_batch_stride_bytes;
  logic owner_invalidate_valid;
  logic owner_retire_valid;
  logic owner_retire_success;
  logic owner_retire_ready;
  logic owner_retire_error;
  logic [3:0] owner_retire_row_block_base;
  logic [2:0] owner_retire_rows;
  logic done_valid;
  logic done_ready;
  logic [15:0] done_status;
  logic [63:0] done_first_error_rank;
  logic [63:0] done_bad_element;
  logic [63:0] command_cycles;
  logic [31:0] actual_a_reads;
  logic [31:0] actual_a_returns;
  logic [31:0] actual_w_reads;
  logic [31:0] actual_w_returns;
  logic [31:0] actual_stripes;
  logic [31:0] actual_ps_commits;
  logic [31:0] actual_final_copies;
  logic [1:0][31:0] actual_aw_count;
  logic [1:0][31:0] actual_w_count;
  logic [1:0][31:0] actual_b_count;
  logic [1:0][63:0] m_axi_awaddr;
  logic [1:0][7:0] m_axi_awlen;
  logic [1:0][2:0] m_axi_awsize;
  logic [1:0][1:0] m_axi_awburst;
  logic [1:0] m_axi_awvalid;
  logic [1:0] m_axi_awready;
  logic [1:0][511:0] m_axi_wdata;
  logic [1:0][63:0] m_axi_wstrb;
  logic [1:0] m_axi_wlast;
  logic [1:0] m_axi_wvalid;
  logic [1:0] m_axi_wready;
  logic [1:0][1:0] m_axi_bresp;
  logic [1:0] m_axi_bvalid;
  logic [1:0] m_axi_bready;
  logic a_acquire_valid;
  logic a_acquire_ready;
  logic a_acquire_done;
  logic a_acquire_error;
  logic a_acquire_slot;
  logic [31:0] a_acquire_slot_epoch;
  logic [12:0] a_acquire_K;
  logic [4:0] a_acquire_rows;
  logic [671:0] a_acquire_numeric_identity;
  logic [95:0] a_acquire_linear_context;
  logic [63:0] a_acquire_a_ref;
  logic [63:0] a_acquire_w_ref;
  logic [63:0] a_acquire_dst_ref;
  logic a_read_valid;
  logic a_read_ready;
  logic a_read_error;
  logic a_read_slot;
  logic [31:0] a_read_slot_epoch;
  logic [671:0] a_read_numeric_identity;
  logic [95:0] a_read_linear_context;
  logic [63:0] a_read_a_ref;
  logic [3:0] a_read_row_block_base;
  logic [2:0] a_read_rows;
  logic [6:0] a_read_group;
  logic a_ret_valid;
  logic a_ret_ready;
  logic a_ret_slot;
  logic [31:0] a_ret_slot_epoch;
  logic [671:0] a_ret_numeric_identity;
  logic [95:0] a_ret_linear_context;
  logic [63:0] a_ret_a_ref;
  logic [3:0] a_ret_row_block_base;
  logic [2:0] a_ret_rows;
  logic [6:0] a_ret_group;
  logic [3:0][255:0] a_ret_q;
  logic [3:0][15:0] a_ret_scale;
  logic a_release_valid;
  logic a_release_ready;
  logic a_release_done;
  logic a_release_error;
  logic a_release_slot;
  logic [31:0] a_release_slot_epoch;
  logic [671:0] a_release_numeric_identity;
  logic [95:0] a_release_linear_context;
  logic [63:0] a_release_a_ref;
  logic a_read_debt_zero;
  logic w_lease_valid;
  logic w_lease_ready;
  logic w_lease_done;
  logic w_lease_error;
  logic w_lease_slot;
  logic [31:0] w_lease_epoch;
  logic [31:0] w_lease_k;
  logic [31:0] w_lease_n;
  logic [15:0] w_lease_weight_key;
  logic [3327:0] w_lease_model_identity;
  logic [671:0] w_lease_numeric_identity;
  logic [95:0] w_lease_task_context;
  logic w_read_valid;
  logic w_read_ready;
  logic w_read_error;
  logic w_read_slot;
  logic [31:0] w_read_epoch;
  logic [15:0] w_read_tile;
  logic [7:0] w_read_group;
  logic w_read_pair;
  logic [3327:0] w_read_model_identity;
  logic [671:0] w_read_numeric_identity;
  logic [95:0] w_read_task_context;
  logic w_ret_valid;
  logic w_ret_ready;
  logic w_ret_slot;
  logic w_ret_pair;
  logic [31:0] w_ret_epoch;
  logic [15:0] w_ret_tile;
  logic [7:0] w_ret_group;
  logic [3327:0] w_ret_model_identity;
  logic [671:0] w_ret_numeric_identity;
  logic [95:0] w_ret_task_context;
  logic [1:0][7:0][255:0] w_ret_q;
  logic [1:0][7:0][15:0] w_ret_scale;
  logic [1:0][7:0][31:0] w_ret_bias;
  logic [1:0][7:0] w_ret_mask;
  logic w_release_valid;
  logic w_release_ready;
  logic w_release_done;
  logic w_release_error;
  logic w_release_slot;
  logic [31:0] w_release_epoch;
  logic [671:0] w_release_numeric_identity;
  logic [95:0] w_release_task_context;
  logic fa_fill_valid;
  logic fa_fill_ready;
  logic fa_fill_reject;
  logic fa_fill_owner_admitted;
  logic fa_fill_source_published;
  logic fa_fill_slot;
  logic [31:0] fa_fill_slot_epoch;
  logic [12:0] fa_fill_K;
  logic [4:0] fa_fill_rows;
  logic [671:0] fa_fill_numeric_identity;
  logic [95:0] fa_fill_producer_context;
  logic [95:0] fa_fill_quant_context;
  logic [95:0] fa_fill_linear_context;
  logic [63:0] fa_fill_source_ref;
  logic [63:0] fa_fill_a_ref;
  logic [63:0] fa_fill_w_ref;
  logic [63:0] fa_fill_dst_ref;
  logic fa_commit_valid;
  logic fa_commit_ready;
  logic fa_commit_error;
  logic [671:0] fa_commit_numeric_identity;
  logic [95:0] fa_commit_quant_context;
  logic [63:0] fa_commit_a_ref;
  logic [3:0] fa_commit_row;
  logic [6:0] fa_commit_group;
  logic fa_commit_half;
  logic [127:0] fa_commit_q;
  logic [15:0] fa_commit_scale;
  logic fa_row_done_valid;
  logic fa_row_done_ready;
  logic [3:0] fa_row_done_row;
  logic [1:0] fa_row_done_status;
  logic [15:0] fa_row_done_bad_col;
  logic fa_row_done_debt_zero;
  logic fa_finish_valid;
  logic fa_finish_ready;
  logic fa_fill_done;
  logic fa_fill_error;
  logic fa_publish_valid;
  logic fa_finish_debt_zero;
  logic [63:0] fa_fill_bad_element;
  logic [1:0][2:0] fa_slot_state;
  logic [1:0][31:0] fa_slot_epoch;
  logic [1:0][15:0] fa_slot_rows_done;
  logic [31:0] fa_physical_half_commits;
  logic [31:0] fa_physical_scale_commits;
  logic fa_fill_valid;
  logic fa_fill_ready;
  logic fa_fill_reject;
  logic fa_fill_owner_admitted;
  logic fa_fill_source_published;
  logic fa_fill_slot;
  logic [31:0] fa_fill_slot_epoch;
  logic [12:0] fa_fill_K;
  logic [4:0] fa_fill_rows;
  logic [671:0] fa_fill_numeric_identity;
  logic [95:0] fa_fill_producer_context;
  logic [95:0] fa_fill_quant_context;
  logic [95:0] fa_fill_linear_context;
  logic [63:0] fa_fill_source_ref;
  logic [63:0] fa_fill_a_ref;
  logic [63:0] fa_fill_w_ref;
  logic [63:0] fa_fill_dst_ref;
  logic fa_commit_valid;
  logic fa_commit_ready;
  logic fa_commit_error;
  logic [671:0] fa_commit_numeric_identity;
  logic [95:0] fa_commit_quant_context;
  logic [63:0] fa_commit_a_ref;
  logic [3:0] fa_commit_row;
  logic [6:0] fa_commit_group;
  logic fa_commit_half;
  logic [127:0] fa_commit_q;
  logic [15:0] fa_commit_scale;
  logic fa_row_done_valid;
  logic fa_row_done_ready;
  logic [3:0] fa_row_done_row;
  logic [1:0] fa_row_done_status;
  logic [15:0] fa_row_done_bad_col;
  logic fa_row_done_debt_zero;
  logic fa_finish_valid;
  logic fa_finish_ready;
  logic fa_fill_done;
  logic fa_fill_error;
  logic fa_publish_valid;
  logic fa_finish_debt_zero;
  logic [63:0] fa_fill_bad_element;
  logic wc_load_valid;
  logic wc_load_ready;
  logic wc_request_valid=0,wc_request_ready,wc_request_reject;
  logic wc_load_slot;
  logic [31:0] wc_load_epoch;
  logic [31:0] wc_load_k;
  logic [31:0] wc_load_n;
  logic [15:0] wc_load_weight_key;
  logic [3327:0] wc_load_model_identity;
  logic [1023:0] wc_load_expected_aux_header;
  logic [2:0][63:0] wc_load_base;
  logic [2:0][31:0] wc_load_bytes;
  logic [63:0] wc_load_aux_base;
  logic [63:0] wc_load_bias_base;
  logic [31:0] wc_load_bias_bytes;
  logic wc_load_done;
  logic wc_load_error;
  logic wc_load_reject;
  logic [31:0] wc_load_scale_checks;
  logic [31:0] wc_load_bad_element;
  logic [1:0][2:0] wc_slot_state;
  logic [1:0][31:0] wc_slot_epoch;
  logic [1:0][31:0] wc_slot_readers;
  logic [1:0][3:0][31:0] wc_slot_coverage;
  logic [3:0] wc_commit_ready;
  logic [2:0][63:0] wc_araddr;
  logic [2:0][7:0] wc_arlen;
  logic [2:0][2:0] wc_arsize;
  logic [2:0][1:0] wc_arburst;
  logic [2:0] wc_arvalid;
  logic [2:0] wc_arready;
  logic [2:0][511:0] wc_rdata;
  logic [2:0][1:0] wc_rresp;
  logic [2:0] wc_rlast;
  logic [2:0] wc_rvalid;
  logic [2:0] wc_rready;
  logic [63:0] wc_aux_araddr;
  logic [7:0] wc_aux_arlen;
  logic [2:0] wc_aux_arsize;
  logic [1:0] wc_aux_arburst;
  logic wc_aux_arvalid;
  logic wc_aux_arready;
  logic [127:0] wc_aux_rdata;
  logic [1:0] wc_aux_rresp;
  logic wc_aux_rlast;
  logic wc_aux_rvalid;
  logic wc_aux_rready;
  logic ledger_claim_valid;
  logic ledger_claim_ready;
  logic ledger_claim_reject;
  logic ledger_retire_debt_zero;
  logic [2:0] ledger_ps_state;
  logic [2:0] ledger_dst_state;
  logic ledger_parent_complete;
  logic ledger_parent_error;
  logic [15:0] ledger_checked_rows;
  logic [15:0] ledger_covered_rows;
  logic [31:0] ledger_claims;
  logic [31:0] ledger_view_retirements;
  logic [31:0] ledger_parent_publications;
  // All ten hardware leaves share this synthesis boundary.
  laya_ffn_representative_top_v1 top(
    .accepted_events(accepted_events),
    .accepted_requests(accepted_requests),
    .active_owners(active_owners),
    .actual_a_reads(actual_a_reads),
    .actual_a_returns(actual_a_returns),
    .actual_aw_count(actual_aw_count),
    .actual_b_count(actual_b_count),
    .actual_final_copies(actual_final_copies),
    .actual_ps_commits(actual_ps_commits),
    .actual_stripes(actual_stripes),
    .actual_w_count(actual_w_count),
    .actual_w_reads(actual_w_reads),
    .actual_w_returns(actual_w_returns),
    .adapter_pending_zero(adapter_pending_zero),
    .base_configured(base_configured),
    .cfg_K(cfg_K),
    .cfg_N(cfg_N),
    .cfg_a_epoch(cfg_a_epoch),
    .cfg_a_ref(cfg_a_ref),
    .cfg_a_slot(cfg_a_slot),
    .cfg_batch_stride_bytes(cfg_batch_stride_bytes),
    .cfg_bias_kind(cfg_bias_kind),
    .cfg_bo_base(cfg_bo_base),
    .cfg_bo_span(cfg_bo_span),
    .cfg_dst_ref(cfg_dst_ref),
    .cfg_linear_context(cfg_linear_context),
    .cfg_numeric_identity(cfg_numeric_identity),
    .cfg_owner_admitted(cfg_owner_admitted),
    .cfg_ps_ref(cfg_ps_ref),
    .cfg_ready(cfg_ready),
    .cfg_region_base(cfg_region_base),
    .cfg_region_span(cfg_region_span),
    .cfg_reject(cfg_reject),
    .cfg_row_block_base(cfg_row_block_base),
    .cfg_row_stride_bytes(cfg_row_stride_bytes),
    .cfg_rows(cfg_rows),
    .cfg_source_ref(cfg_source_ref),
    .cfg_valid(cfg_valid),
    .cfg_w_epoch(cfg_w_epoch),
    .cfg_w_model_identity(cfg_w_model_identity),
    .cfg_w_ref(cfg_w_ref),
    .cfg_w_slot(cfg_w_slot),
    .cfg_weight_key(cfg_weight_key),
    .clk(clk),
    .command_cycles(command_cycles),
    .destination_axi_awaddr(destination_axi_awaddr),
    .destination_axi_awburst(destination_axi_awburst),
    .destination_axi_awlen(destination_axi_awlen),
    .destination_axi_awready(destination_axi_awready),
    .destination_axi_awsize(destination_axi_awsize),
    .destination_axi_awvalid(destination_axi_awvalid),
    .destination_axi_bready(destination_axi_bready),
    .destination_axi_bresp(destination_axi_bresp),
    .destination_axi_bvalid(destination_axi_bvalid),
    .destination_axi_wdata(destination_axi_wdata),
    .destination_axi_wlast(destination_axi_wlast),
    .destination_axi_wready(destination_axi_wready),
    .destination_axi_wstrb(destination_axi_wstrb),
    .destination_axi_wvalid(destination_axi_wvalid),
    .done_bad_element(done_bad_element),
    .done_first_error_rank(done_first_error_rank),
    .done_ready(done_ready),
    .done_status(done_status),
    .done_valid(done_valid),
    .fa_commit_a_ref(fa_commit_a_ref),
    .fa_commit_error(fa_commit_error),
    .fa_commit_group(fa_commit_group),
    .fa_commit_half(fa_commit_half),
    .fa_commit_numeric_identity(fa_commit_numeric_identity),
    .fa_commit_q(fa_commit_q),
    .fa_commit_quant_context(fa_commit_quant_context),
    .fa_commit_ready(fa_commit_ready),
    .fa_commit_row(fa_commit_row),
    .fa_commit_scale(fa_commit_scale),
    .fa_commit_valid(fa_commit_valid),
    .fa_fill_K(fa_fill_K),
    .fa_fill_a_ref(fa_fill_a_ref),
    .fa_fill_bad_element(fa_fill_bad_element),
    .fa_fill_done(fa_fill_done),
    .fa_fill_dst_ref(fa_fill_dst_ref),
    .fa_fill_error(fa_fill_error),
    .fa_fill_linear_context(fa_fill_linear_context),
    .fa_fill_numeric_identity(fa_fill_numeric_identity),
    .fa_fill_owner_admitted(fa_fill_owner_admitted),
    .fa_fill_producer_context(fa_fill_producer_context),
    .fa_fill_quant_context(fa_fill_quant_context),
    .fa_fill_ready(fa_fill_ready),
    .fa_fill_reject(fa_fill_reject),
    .fa_fill_rows(fa_fill_rows),
    .fa_fill_slot(fa_fill_slot),
    .fa_fill_slot_epoch(fa_fill_slot_epoch),
    .fa_fill_source_published(fa_fill_source_published),
    .fa_fill_source_ref(fa_fill_source_ref),
    .fa_fill_valid(fa_fill_valid),
    .fa_fill_w_ref(fa_fill_w_ref),
    .fa_finish_debt_zero(fa_finish_debt_zero),
    .fa_finish_ready(fa_finish_ready),
    .fa_finish_valid(fa_finish_valid),
    .fa_physical_half_commits(fa_physical_half_commits),
    .fa_physical_scale_commits(fa_physical_scale_commits),
    .fa_publish_valid(fa_publish_valid),
    .fa_row_done_bad_col(fa_row_done_bad_col),
    .fa_row_done_debt_zero(fa_row_done_debt_zero),
    .fa_row_done_ready(fa_row_done_ready),
    .fa_row_done_row(fa_row_done_row),
    .fa_row_done_status(fa_row_done_status),
    .fa_row_done_valid(fa_row_done_valid),
    .fa_slot_epoch(fa_slot_epoch),
    .fa_slot_rows_done(fa_slot_rows_done),
    .fa_slot_state(fa_slot_state),
    .ffn_done_consumed(ffn_done_consumed),
    .ffn_down_araddr(ffn_down_araddr),
    .ffn_down_arlen(ffn_down_arlen),
    .ffn_down_arready(ffn_down_arready),
    .ffn_down_arsize(ffn_down_arsize),
    .ffn_down_arvalid(ffn_down_arvalid),
    .ffn_down_aw(ffn_down_aw),
    .ffn_down_b(ffn_down_b),
    .ffn_down_candidate_ready(ffn_down_candidate_ready),
    .ffn_down_candidate_reject(ffn_down_candidate_reject),
    .ffn_down_rdata(ffn_down_rdata),
    .ffn_down_rlast(ffn_down_rlast),
    .ffn_down_rready(ffn_down_rready),
    .ffn_down_rresp(ffn_down_rresp),
    .ffn_down_rvalid(ffn_down_rvalid),
    .ffn_down_w(ffn_down_w),
    .ffn_handoff_error(ffn_handoff_error),
    .ffn_hidden_published(ffn_hidden_published),
    .ffn_hidden_reserved(ffn_hidden_reserved),
    .ffn_matrix_cfg_valid(ffn_matrix_cfg_valid),
    .ffn_res_accepted(ffn_res_accepted),
    .ffn_res_awaddr(ffn_res_awaddr),
    .ffn_res_awlen(ffn_res_awlen),
    .ffn_res_awready(ffn_res_awready),
    .ffn_res_awsize(ffn_res_awsize),
    .ffn_res_awvalid(ffn_res_awvalid),
    .ffn_res_bready(ffn_res_bready),
    .ffn_res_bresp(ffn_res_bresp),
    .ffn_res_bvalid(ffn_res_bvalid),
    .ffn_res_consumed(ffn_res_consumed),
    .ffn_res_dst_ref(ffn_res_dst_ref),
    .ffn_res_rsp_context(ffn_res_rsp_context),
    .ffn_res_rsp_ready(ffn_res_rsp_ready),
    .ffn_res_rsp_status(ffn_res_rsp_status),
    .ffn_res_rsp_valid(ffn_res_rsp_valid),
    .ffn_res_src0_ref(ffn_res_src0_ref),
    .ffn_res_src1_ref(ffn_res_src1_ref),
    .ffn_res_task_context(ffn_res_task_context),
    .ffn_res_wdata(ffn_res_wdata),
    .ffn_res_wlast(ffn_res_wlast),
    .ffn_res_wready(ffn_res_wready),
    .ffn_res_wstrb(ffn_res_wstrb),
    .ffn_res_wvalid(ffn_res_wvalid),
    .ffn_skip_araddr(ffn_skip_araddr),
    .ffn_skip_arlen(ffn_skip_arlen),
    .ffn_skip_arready(ffn_skip_arready),
    .ffn_skip_arsize(ffn_skip_arsize),
    .ffn_skip_arvalid(ffn_skip_arvalid),
    .ffn_skip_rdata(ffn_skip_rdata),
    .ffn_skip_rlast(ffn_skip_rlast),
    .ffn_skip_rready(ffn_skip_rready),
    .ffn_skip_rresp(ffn_skip_rresp),
    .ffn_skip_rvalid(ffn_skip_rvalid),
    .ffn_tmp_reserved(ffn_tmp_reserved),
    .forwarded_aw(forwarded_aw),
    .forwarded_w(forwarded_w),
    .g_accepted_words(g_accepted_words),
    .g_aw_count(g_aw_count),
    .g_b_count(g_b_count),
    .g_cfg_a_ref(g_cfg_a_ref),
    .g_cfg_a_slot(g_cfg_a_slot),
    .g_cfg_a_slot_epoch(g_cfg_a_slot_epoch),
    .g_cfg_bo_base(g_cfg_bo_base),
    .g_cfg_bo_span(g_cfg_bo_span),
    .g_cfg_down_dst_ref(g_cfg_down_dst_ref),
    .g_cfg_gate_ref(g_cfg_gate_ref),
    .g_cfg_linear_context(g_cfg_linear_context),
    .g_cfg_numeric_identity(g_cfg_numeric_identity),
    .g_cfg_owner_admitted(g_cfg_owner_admitted),
    .g_cfg_producer_context(g_cfg_producer_context),
    .g_cfg_quant_context(g_cfg_quant_context),
    .g_cfg_ready(g_cfg_ready),
    .g_cfg_region_base(g_cfg_region_base),
    .g_cfg_region_span(g_cfg_region_span),
    .g_cfg_reject(g_cfg_reject),
    .g_cfg_rows(g_cfg_rows),
    .g_cfg_valid(g_cfg_valid),
    .g_cfg_w_ref(g_cfg_w_ref),
    .g_cfg_wi_ref(g_cfg_wi_ref),
    .g_done_bad_element(g_done_bad_element),
    .g_done_ready(g_done_ready),
    .g_done_status(g_done_status),
    .g_done_valid(g_done_valid),
    .g_gate_owner_state(g_gate_owner_state),
    .g_m_axi_araddr(g_m_axi_araddr),
    .g_m_axi_arburst(g_m_axi_arburst),
    .g_m_axi_arlen(g_m_axi_arlen),
    .g_m_axi_arready(g_m_axi_arready),
    .g_m_axi_arsize(g_m_axi_arsize),
    .g_m_axi_arvalid(g_m_axi_arvalid),
    .g_m_axi_awaddr(g_m_axi_awaddr),
    .g_m_axi_awburst(g_m_axi_awburst),
    .g_m_axi_awlen(g_m_axi_awlen),
    .g_m_axi_awready(g_m_axi_awready),
    .g_m_axi_awsize(g_m_axi_awsize),
    .g_m_axi_awvalid(g_m_axi_awvalid),
    .g_m_axi_bready(g_m_axi_bready),
    .g_m_axi_bresp(g_m_axi_bresp),
    .g_m_axi_bvalid(g_m_axi_bvalid),
    .g_m_axi_rdata(g_m_axi_rdata),
    .g_m_axi_rlast(g_m_axi_rlast),
    .g_m_axi_rready(g_m_axi_rready),
    .g_m_axi_rresp(g_m_axi_rresp),
    .g_m_axi_rvalid(g_m_axi_rvalid),
    .g_m_axi_wdata(g_m_axi_wdata),
    .g_m_axi_wlast(g_m_axi_wlast),
    .g_m_axi_wready(g_m_axi_wready),
    .g_m_axi_wstrb(g_m_axi_wstrb),
    .g_m_axi_wvalid(g_m_axi_wvalid),
    .g_mul_halves_issued(g_mul_halves_issued),
    .g_mul_halves_returned(g_mul_halves_returned),
    .g_physical_bytes(g_physical_bytes),
    .g_quant_command_cycles(g_quant_command_cycles),
    .g_quant_input_beats(g_quant_input_beats),
    .g_quant_rows(g_quant_rows),
    .g_quant_starts(g_quant_starts),
    .g_recip_issues(g_recip_issues),
    .g_recip_returns(g_recip_returns),
    .g_scale_issues(g_scale_issues),
    .g_scale_returns(g_scale_returns),
    .g_source_ar_count(g_source_ar_count),
    .g_source_complete_rows(g_source_complete_rows),
    .g_source_r_count(g_source_r_count),
    .g_useful_bytes(g_useful_bytes),
    .g_w_count(g_w_count),
    .job_active(job_active),
    .last_event_seq(last_event_seq),
    .ledger_checked_rows(ledger_checked_rows),
    .ledger_claims(ledger_claims),
    .ledger_covered_rows(ledger_covered_rows),
    .ledger_domain_drained(ledger_domain_drained),
    .ledger_parent_complete(ledger_parent_complete),
    .ledger_parent_error(ledger_parent_error),
    .ledger_protocol_error(ledger_protocol_error),
    .ledger_ps_state(ledger_ps_state),
    .ledger_scope_active(ledger_scope_active),
    .ledger_view_retirements(ledger_view_retirements),
    .ln_admission_error(ln_admission_error),
    .ln_candidate_done_ready(ln_candidate_done_ready),
    .ln_candidate_ready(ln_candidate_ready),
    .ln_candidate_reject(ln_candidate_reject),
    .ln_candidate_valid(ln_candidate_valid),
    .ln_lease_pending(ln_lease_pending),
    .ln_query_command(ln_query_command),
    .ln_query_valid(ln_query_valid),
    .ln_source_query_command(ln_source_query_command),
    .ln_source_release_command(ln_source_release_command),
    .ln_source_release_drained(ln_source_release_drained),
    .ln_source_release_valid(ln_source_release_valid),
    .m_axi_awaddr(m_axi_awaddr),
    .m_axi_awburst(m_axi_awburst),
    .m_axi_awlen(m_axi_awlen),
    .m_axi_awready(m_axi_awready),
    .m_axi_awsize(m_axi_awsize),
    .m_axi_awvalid(m_axi_awvalid),
    .m_axi_bready(m_axi_bready),
    .m_axi_bresp(m_axi_bresp),
    .m_axi_bvalid(m_axi_bvalid),
    .m_axi_wdata(m_axi_wdata),
    .m_axi_wlast(m_axi_wlast),
    .m_axi_wready(m_axi_wready),
    .m_axi_wstrb(m_axi_wstrb),
    .m_axi_wvalid(m_axi_wvalid),
    .monitor_coverage_complete(monitor_coverage_complete),
    .monitor_drained(monitor_drained),
    .monitor_observed0(monitor_observed0),
    .monitor_scope_active(monitor_scope_active),
    .monitor_status(monitor_status),
    .prefill_select(prefill_select),
    .producer_completion_din(producer_completion_din),
    .producer_completion_full_n(producer_completion_full_n),
    .producer_completion_write(producer_completion_write),
    .producer_request_dout(producer_request_dout),
    .producer_request_empty_n(producer_request_empty_n),
    .producer_request_read(producer_request_read),
    .provenance_cmd_din(provenance_cmd_din),
    .provenance_cmd_full_n(provenance_cmd_full_n),
    .provenance_cmd_write(provenance_cmd_write),
    .provenance_rsp_dout(provenance_rsp_dout),
    .provenance_rsp_empty_n(provenance_rsp_empty_n),
    .provenance_rsp_read(provenance_rsp_read),
    .published_owners(published_owners),
    .quant_axi_accounting_error(quant_axi_accounting_error),
    .quant_axi_beats_remaining(quant_axi_beats_remaining),
    .quant_axi_burst_in_flight(quant_axi_burst_in_flight),
    .retired_b(retired_b),
    .retired_responses(retired_responses),
    .rst_n(rst_n),
    .semantic_rejections(semantic_rejections),
    .shell_protocol_error(shell_protocol_error),
    .source_axi_araddr(source_axi_araddr),
    .source_axi_arburst(source_axi_arburst),
    .source_axi_arlen(source_axi_arlen),
    .source_axi_arready(source_axi_arready),
    .source_axi_arsize(source_axi_arsize),
    .source_axi_arvalid(source_axi_arvalid),
    .source_axi_rdata(source_axi_rdata),
    .source_axi_rlast(source_axi_rlast),
    .source_axi_rready(source_axi_rready),
    .source_axi_rresp(source_axi_rresp),
    .source_axi_rvalid(source_axi_rvalid),
    .source_lease_active(ln_source_lease_active),
    .source_outstanding_beats(source_outstanding_beats),
    .source_quant_done_bad_element(source_quant_done_bad_element),
    .source_quant_done_status(source_quant_done_status),
    .source_query_granted(ln_query_granted),
    .source_query_ready(ln_query_ready),
    .source_release_ready(ln_source_release_ready),
    .stage(stage[0]),
    .terminal_tasks(terminal_tasks),
    .wc_araddr(wc_araddr),
    .wc_arburst(wc_arburst),
    .wc_arlen(wc_arlen),
    .wc_arready(wc_arready),
    .wc_arsize(wc_arsize),
    .wc_arvalid(wc_arvalid),
    .wc_aux_araddr(wc_aux_araddr),
    .wc_aux_arburst(wc_aux_arburst),
    .wc_aux_arlen(wc_aux_arlen),
    .wc_aux_arready(wc_aux_arready),
    .wc_aux_arsize(wc_aux_arsize),
    .wc_aux_arvalid(wc_aux_arvalid),
    .wc_aux_rdata(wc_aux_rdata),
    .wc_aux_rlast(wc_aux_rlast),
    .wc_aux_rready(wc_aux_rready),
    .wc_aux_rresp(wc_aux_rresp),
    .wc_aux_rvalid(wc_aux_rvalid),
    .wc_commit_ready(wc_commit_ready),
    .wc_load_aux_base(wc_load_aux_base),
    .wc_load_bad_element(wc_load_bad_element),
    .wc_load_base(wc_load_base),
    .wc_load_bias_base(wc_load_bias_base),
    .wc_load_bias_bytes(wc_load_bias_bytes),
    .wc_load_bytes(wc_load_bytes),
    .wc_load_done(wc_load_done),
    .wc_load_epoch(wc_load_epoch),
    .wc_load_error(wc_load_error),
    .wc_load_expected_aux_header(wc_load_expected_aux_header),
    .wc_load_k(wc_load_k),
    .wc_load_model_identity(wc_load_model_identity),
    .wc_load_n(wc_load_n),
    .wc_load_reject(wc_load_reject),
    .wc_load_scale_checks(wc_load_scale_checks),
    .wc_load_slot(wc_load_slot),
    .wc_load_weight_key(wc_load_weight_key),
    .wc_rdata(wc_rdata),
    .wc_request_ready(wc_request_ready),
    .wc_request_reject(wc_request_reject),
    .wc_request_valid(wc_request_valid),
    .wc_rlast(wc_rlast),
    .wc_rready(wc_rready),
    .wc_rresp(wc_rresp),
    .wc_rvalid(wc_rvalid),
    .wc_slot_coverage(wc_slot_coverage),
    .wc_slot_epoch(wc_slot_epoch),
    .wc_slot_readers(wc_slot_readers),
    .wc_slot_state(wc_slot_state),
    .wi_ar_count(wi_ar_count),
    .wi_araddr(wi_araddr),
    .wi_arburst(wi_arburst),
    .wi_arlen(wi_arlen),
    .wi_arready(wi_arready),
    .wi_arsize(wi_arsize),
    .wi_arvalid(wi_arvalid),
    .wi_cfg_ready(wi_cfg_ready),
    .wi_cfg_reject(wi_cfg_reject),
    .wi_cfg_valid(wi_cfg_valid),
    .wi_complete_rows(wi_complete_rows),
    .wi_r_count(wi_r_count),
    .wi_rdata(wi_rdata),
    .wi_reader_active(wi_reader_active),
    .wi_rlast(wi_rlast),
    .wi_rready(wi_rready),
    .wi_rresp(wi_rresp),
    .wi_rvalid(wi_rvalid)
  );
  assign a_acquire_K=top.a_acquire_K;
  assign a_acquire_a_ref=top.a_acquire_a_ref;
  assign a_acquire_done=top.a_acquire_done;
  assign a_acquire_dst_ref=top.a_acquire_dst_ref;
  assign a_acquire_error=top.a_acquire_error;
  assign a_acquire_linear_context=top.a_acquire_linear_context;
  assign a_acquire_numeric_identity=top.a_acquire_numeric_identity;
  assign a_acquire_ready=top.a_acquire_ready;
  assign a_acquire_rows=top.a_acquire_rows;
  assign a_acquire_slot=top.a_acquire_slot;
  assign a_acquire_slot_epoch=top.a_acquire_slot_epoch;
  assign a_acquire_valid=top.a_acquire_valid;
  assign a_acquire_w_ref=top.a_acquire_w_ref;
  assign a_read_a_ref=top.a_read_a_ref;
  assign a_read_debt_zero=top.a_read_debt_zero;
  assign a_read_error=top.a_read_error;
  assign a_read_group=top.a_read_group;
  assign a_read_linear_context=top.a_read_linear_context;
  assign a_read_numeric_identity=top.a_read_numeric_identity;
  assign a_read_ready=top.a_read_ready;
  assign a_read_row_block_base=top.a_read_row_block_base;
  assign a_read_rows=top.a_read_rows;
  assign a_read_slot=top.a_read_slot;
  assign a_read_slot_epoch=top.a_read_slot_epoch;
  assign a_read_valid=top.a_read_valid;
  assign a_release_a_ref=top.a_release_a_ref;
  assign a_release_done=top.a_release_done;
  assign a_release_error=top.a_release_error;
  assign a_release_linear_context=top.a_release_linear_context;
  assign a_release_numeric_identity=top.a_release_numeric_identity;
  assign a_release_ready=top.a_release_ready;
  assign a_release_slot=top.a_release_slot;
  assign a_release_slot_epoch=top.a_release_slot_epoch;
  assign a_release_valid=top.a_release_valid;
  assign a_ret_a_ref=top.a_ret_a_ref;
  assign a_ret_group=top.a_ret_group;
  assign a_ret_linear_context=top.a_ret_linear_context;
  assign a_ret_numeric_identity=top.a_ret_numeric_identity;
  assign a_ret_q=top.a_ret_q;
  assign a_ret_ready=top.a_ret_ready;
  assign a_ret_row_block_base=top.a_ret_row_block_base;
  assign a_ret_rows=top.a_ret_rows;
  assign a_ret_scale=top.a_ret_scale;
  assign a_ret_slot=top.a_ret_slot;
  assign a_ret_slot_epoch=top.a_ret_slot_epoch;
  assign a_ret_valid=top.a_ret_valid;
  assign bridge_can_accept=top.bridge_can_accept;
  assign cfg_target_invalidated=top.cfg_target_invalidated;
  assign ffn_add_done_count=top.ffn_add_done_count;
  assign ffn_add_start_count=top.ffn_add_start_count;
  assign ffn_down_ar_count=top.ffn_down_ar_count;
  assign ffn_down_r_count=top.ffn_down_r_count;
  assign ffn_dst_published=top.ffn_dst_published;
  assign ffn_res_aw_count=top.ffn_res_aw_count;
  assign ffn_res_b_count=top.ffn_res_b_count;
  assign ffn_res_build_tag=top.ffn_res_build_tag;
  assign ffn_res_cfg_ready=top.ffn_res_cfg_ready;
  assign ffn_res_cfg_valid=top.ffn_res_cfg_valid;
  assign ffn_res_generation=top.ffn_res_generation;
  assign ffn_res_layout_tag=top.ffn_res_layout_tag;
  assign ffn_res_local_context=top.ffn_res_local_context;
  assign ffn_res_model_tag=top.ffn_res_model_tag;
  assign ffn_res_numeric_tag=top.ffn_res_numeric_tag;
  assign ffn_res_request=top.ffn_res_request;
  assign ffn_res_w_count=top.ffn_res_w_count;
  assign ffn_skip_ar_count=top.ffn_skip_ar_count;
  assign ffn_skip_r_count=top.ffn_skip_r_count;
  assign ffn_source_locked=top.ffn_source_locked;
  assign g_quant_task_debt_zero=top.g_quant_task_debt_zero;
  assign g_wi_data=top.g_wi_data;
  assign g_wi_index=top.g_wi_index;
  assign g_wi_numeric_identity=top.g_wi_numeric_identity;
  assign g_wi_read_debt_zero=top.g_wi_read_debt_zero;
  assign g_wi_ready=top.g_wi_ready;
  assign g_wi_row=top.g_wi_row;
  assign g_wi_row_bad_element=top.g_wi_row_bad_element;
  assign g_wi_row_done_ready=top.g_wi_row_done_ready;
  assign g_wi_row_done_status=top.g_wi_row_done_status;
  assign g_wi_row_done_valid=top.g_wi_row_done_valid;
  assign g_wi_source_ref=top.g_wi_source_ref;
  assign g_wi_status=top.g_wi_status;
  assign g_wi_valid=top.g_wi_valid;
  assign ledger_claim_ready=top.ledger_claim_ready;
  assign ledger_claim_reject=top.ledger_claim_reject;
  assign ledger_dst_state=top.ledger_dst_state;
  assign ledger_parent_publications=top.ledger_parent_publications;
  assign ln_ext_K=top.ln_ext_K;
  assign ln_ext_a_ref=top.ln_ext_a_ref;
  assign ln_ext_a_slot=top.ln_ext_a_slot;
  assign ln_ext_a_slot_epoch=top.ln_ext_a_slot_epoch;
  assign ln_ext_batch_stride=top.ln_ext_batch_stride;
  assign ln_ext_bo_base=top.ln_ext_bo_base;
  assign ln_ext_bo_span=top.ln_ext_bo_span;
  assign ln_ext_dst_ref=top.ln_ext_dst_ref;
  assign ln_ext_linear_context=top.ln_ext_linear_context;
  assign ln_ext_numeric_identity=top.ln_ext_numeric_identity;
  assign ln_ext_producer_context=top.ln_ext_producer_context;
  assign ln_ext_quant_context=top.ln_ext_quant_context;
  assign ln_ext_region_base=top.ln_ext_region_base;
  assign ln_ext_region_span=top.ln_ext_region_span;
  assign ln_ext_row_stride=top.ln_ext_row_stride;
  assign ln_ext_rows=top.ln_ext_rows;
  assign ln_ext_source_published=top.ln_ext_source_published;
  assign ln_ext_source_ref=top.ln_ext_source_ref;
  assign ln_ext_w_ref=top.ln_ext_w_ref;
  assign ln_physical_r_debt_zero=top.ln_physical_r_debt_zero;
  assign owner_invalidate_valid=top.owner_invalidate_valid;
  assign owner_retire_error=top.owner_retire_error;
  assign owner_retire_ready=top.owner_retire_ready;
  assign owner_retire_row_block_base=top.owner_retire_row_block_base;
  assign owner_retire_rows=top.owner_retire_rows;
  assign owner_retire_success=top.owner_retire_success;
  assign owner_retire_valid=top.owner_retire_valid;
  assign source_quant_done_ready=top.source_quant_done_ready;
  assign source_quant_done_valid=top.source_quant_done_valid;
  assign source_quant_owner_admitted=top.source_quant_owner_admitted;
  assign source_quant_ready=top.source_quant_ready;
  assign source_quant_reject=top.source_quant_reject;
  assign source_quant_valid=top.source_quant_valid;
  assign w_lease_done=top.w_lease_done;
  assign w_lease_epoch=top.w_lease_epoch;
  assign w_lease_error=top.w_lease_error;
  assign w_lease_k=top.w_lease_k;
  assign w_lease_model_identity=top.w_lease_model_identity;
  assign w_lease_n=top.w_lease_n;
  assign w_lease_numeric_identity=top.w_lease_numeric_identity;
  assign w_lease_ready=top.w_lease_ready;
  assign w_lease_slot=top.w_lease_slot;
  assign w_lease_task_context=top.w_lease_task_context;
  assign w_lease_valid=top.w_lease_valid;
  assign w_lease_weight_key=top.w_lease_weight_key;
  assign w_read_epoch=top.w_read_epoch;
  assign w_read_error=top.w_read_error;
  assign w_read_group=top.w_read_group;
  assign w_read_model_identity=top.w_read_model_identity;
  assign w_read_numeric_identity=top.w_read_numeric_identity;
  assign w_read_pair=top.w_read_pair;
  assign w_read_ready=top.w_read_ready;
  assign w_read_slot=top.w_read_slot;
  assign w_read_task_context=top.w_read_task_context;
  assign w_read_tile=top.w_read_tile;
  assign w_read_valid=top.w_read_valid;
  assign w_release_done=top.w_release_done;
  assign w_release_epoch=top.w_release_epoch;
  assign w_release_error=top.w_release_error;
  assign w_release_numeric_identity=top.w_release_numeric_identity;
  assign w_release_ready=top.w_release_ready;
  assign w_release_slot=top.w_release_slot;
  assign w_release_task_context=top.w_release_task_context;
  assign w_release_valid=top.w_release_valid;
  assign w_ret_bias=top.w_ret_bias;
  assign w_ret_epoch=top.w_ret_epoch;
  assign w_ret_group=top.w_ret_group;
  assign w_ret_mask=top.w_ret_mask;
  assign w_ret_model_identity=top.w_ret_model_identity;
  assign w_ret_numeric_identity=top.w_ret_numeric_identity;
  assign w_ret_pair=top.w_ret_pair;
  assign w_ret_q=top.w_ret_q;
  assign w_ret_ready=top.w_ret_ready;
  assign w_ret_scale=top.w_ret_scale;
  assign w_ret_slot=top.w_ret_slot;
  assign w_ret_task_context=top.w_ret_task_context;
  assign w_ret_tile=top.w_ret_tile;
  assign w_ret_valid=top.w_ret_valid;
  assign wc_load_ready=top.wc_load_ready;
  assign wc_load_valid=top.wc_load_valid;

  logic  g_cfg_valid;
  logic  g_cfg_ready;
  logic  g_cfg_reject;
  logic  g_cfg_owner_admitted;
  logic [671:0] g_cfg_numeric_identity;
  logic [95:0] g_cfg_producer_context;
  logic [95:0] g_cfg_quant_context;
  logic [95:0] g_cfg_linear_context;
  logic [63:0] g_cfg_wi_ref;
  logic [63:0] g_cfg_gate_ref;
  logic [63:0] g_cfg_a_ref;
  logic [63:0] g_cfg_w_ref;
  logic [63:0] g_cfg_down_dst_ref;
  logic [4:0] g_cfg_rows;
  localparam logic [12:0] GATE_K=13'd2624;
  logic  g_cfg_a_slot;
  logic [31:0] g_cfg_a_slot_epoch;
  logic [63:0] g_cfg_bo_base;
  logic [63:0] g_cfg_bo_span;
  logic [63:0] g_cfg_region_base;
  logic [63:0] g_cfg_region_span;
  logic  g_wi_valid;
  logic  g_wi_ready;
  logic [31:0] g_wi_data;
  logic [31:0] g_wi_status;
  logic [671:0] g_wi_numeric_identity;
  logic [63:0] g_wi_source_ref;
  logic [15:0] g_wi_row;
  logic [12:0] g_wi_index;
  logic  g_wi_row_done_valid;
  logic  g_wi_row_done_ready;
  logic [31:0] g_wi_row_done_status;
  logic [63:0] g_wi_row_bad_element;
  logic  g_wi_read_debt_zero;
  logic  g_done_valid;
  logic  g_done_ready;
  logic [31:0] g_done_status;
  logic [63:0] g_done_bad_element;
  logic [2:0] g_gate_owner_state;
  logic [31:0] g_aw_count;
  logic [31:0] g_w_count;
  logic [31:0] g_b_count;
  logic [31:0] g_accepted_words;
  logic [63:0] g_useful_bytes;
  logic [63:0] g_physical_bytes;
  logic [31:0] g_source_ar_count;
  logic [31:0] g_source_r_count;
  logic [31:0] g_source_complete_rows;
  logic [31:0] g_quant_starts;
  logic [31:0] g_quant_input_beats;
  logic [31:0] g_quant_rows;
  logic [31:0] g_scale_issues;
  logic [31:0] g_scale_returns;
  logic [31:0] g_recip_issues;
  logic [31:0] g_recip_returns;
  logic [31:0] g_mul_halves_issued;
  logic [31:0] g_mul_halves_returned;
  logic [63:0] g_quant_command_cycles;
  logic [63:0] g_m_axi_awaddr;
  logic [7:0] g_m_axi_awlen;
  logic [2:0] g_m_axi_awsize;
  logic [1:0] g_m_axi_awburst;
  logic  g_m_axi_awvalid;
  logic  g_m_axi_awready;
  logic [511:0] g_m_axi_wdata;
  logic [63:0] g_m_axi_wstrb;
  logic  g_m_axi_wlast;
  logic  g_m_axi_wvalid;
  logic  g_m_axi_wready;
  logic [1:0] g_m_axi_bresp;
  logic  g_m_axi_bvalid;
  logic  g_m_axi_bready;
  logic [63:0] g_m_axi_araddr;
  logic [7:0] g_m_axi_arlen;
  logic [2:0] g_m_axi_arsize;
  logic [1:0] g_m_axi_arburst;
  logic  g_m_axi_arvalid;
  logic  g_m_axi_arready;
  logic [511:0] g_m_axi_rdata;
  logic [1:0] g_m_axi_rresp;
  logic  g_m_axi_rlast;
  logic  g_m_axi_rvalid;
  logic  g_m_axi_rready;
  localparam logic [63:0] DDR_BASE=64'h100000000;
  localparam logic [63:0] STATE1_BASE=64'h310000000;
  localparam logic [63:0] TMP_BASE=64'h310800000;
  localparam int SOURCE_OFFSET=327680;
  localparam int SOURCE_BYTES=16384;
  localparam int DDR_BYTES=393216;
  logic [7:0] ddr[0:DDR_BYTES-1];
  bit ddr_written[0:DDR_BYTES-1];
  // Two disjoint sparse windows behind one STATE1 address decoder. The TMP
  // window is written by the matrix AXI port and read by the residual AXI
  // port; no gold copy or second input array is used for that handoff.
  logic [7:0] state1_tmp[0:65535],state1_hidden[0:65535];
  bit state1_tmp_written[0:65535],state1_hidden_written[0:65535];
  logic matrix_cfg_valid,ffn_matrix_cfg_valid;
  logic ffn_down_candidate_ready,ffn_down_candidate_reject;
  logic ffn_res_cfg_valid,ffn_res_cfg_ready;
  logic [31:0] ffn_res_request,ffn_res_generation;
  logic [95:0] ffn_res_task_context;
  logic [415:0] ffn_res_local_context,ffn_res_rsp_context;
  logic [127:0] ffn_res_model_tag,ffn_res_numeric_tag;
  logic [127:0] ffn_res_layout_tag,ffn_res_build_tag;
  logic [63:0] ffn_res_src0_ref,ffn_res_src1_ref,ffn_res_dst_ref;
  logic ffn_res_rsp_valid,ffn_res_rsp_ready=0;
  logic [7:0] ffn_res_rsp_status;
  logic ffn_source_locked,ffn_dst_published,ffn_tmp_reserved;
  logic ffn_hidden_reserved,ffn_hidden_published,ffn_handoff_error;
  logic ffn_done_consumed,ffn_res_accepted,ffn_res_consumed;
  logic [15:0] ffn_down_aw,ffn_down_w,ffn_down_b;
  logic [15:0] ffn_skip_ar_count,ffn_skip_r_count;
  logic [15:0] ffn_down_ar_count,ffn_down_r_count;
  logic [15:0] ffn_add_start_count,ffn_add_done_count;
  logic [15:0] ffn_res_aw_count,ffn_res_w_count,ffn_res_b_count;
  logic ffn_skip_arvalid,ffn_skip_arready,ffn_skip_rvalid,ffn_skip_rready;
  logic [63:0] ffn_skip_araddr;
  logic [7:0] ffn_skip_arlen;
  logic [2:0] ffn_skip_arsize;
  logic [511:0] ffn_skip_rdata;
  logic [1:0] ffn_skip_rresp;
  logic ffn_skip_rlast;
  logic ffn_down_arvalid,ffn_down_arready,ffn_down_rvalid,ffn_down_rready;
  logic [63:0] ffn_down_araddr;
  logic [7:0] ffn_down_arlen;
  logic [2:0] ffn_down_arsize;
  logic [511:0] ffn_down_rdata;
  logic [1:0] ffn_down_rresp;
  logic ffn_down_rlast;
  logic ffn_res_awvalid,ffn_res_awready,ffn_res_wvalid,ffn_res_wready;
  logic [63:0] ffn_res_awaddr,ffn_res_wstrb;
  logic [7:0] ffn_res_awlen;
  logic [2:0] ffn_res_awsize;
  logic [511:0] ffn_res_wdata;
  logic ffn_res_wlast,ffn_res_bvalid,ffn_res_bready;
  logic [1:0] ffn_res_bresp;
  logic [31:0] ffn_gold[0:4095],ffn_skip_gold[0:4095];
  integer ffn0_down_claim_edge=-1,ffn0_owner_retire_edge=-1;
  integer ffn0_done_consume_edge=-1,ffn0_res_cfg_edge=-1;
  integer ffn0_res_rsp_edge=-1,ffn0_local_publish_edge=-1;
  integer ffn0_tmp_lock_edge=-1,ffn0_tmp_unlock_edge=-1;
  integer ffn0_hidden_ticket_edge=-1,ffn0_hidden_release_edge=-1;
  integer ffn0_first_skip_ar=-1,ffn0_last_skip_ar=-1;
  integer ffn0_first_skip_r=-1,ffn0_last_skip_r=-1;
  integer ffn0_first_tmp_ar=-1,ffn0_last_tmp_ar=-1;
  integer ffn0_first_tmp_r=-1,ffn0_last_tmp_r=-1;
  integer ffn0_first_hidden_aw=-1,ffn0_last_hidden_aw=-1;
  integer ffn0_first_hidden_w=-1,ffn0_last_hidden_w=-1;
  integer ffn0_first_hidden_b=-1,ffn0_last_hidden_b=-1;
  integer ffn0_phase_cycles[0:4],ffn0_phase_total=0;
  integer ffn0_add_accept_edge=-1,ffn0_add_latency_samples=0;
  integer ffn0_add_latency_hist[0:255];
  logic ffn0_add_inflight=0,ffn0_prev_tmp_lock=0;
  logic ffn0_prev_hidden_ticket=0,ffn0_prev_local_publish=0;
  initial begin
    for(int i=0;i<5;i++)ffn0_phase_cycles[i]=0;
    for(int i=0;i<256;i++)ffn0_add_latency_hist[i]=0;
  end
  always @(posedge clk) if(rst_n)begin : ffn0_boundary_observer
    integer phase_index,latency;
    phase_index=!ln_published ? 0 : stage==0 ? 1 :
      !ffn_done_consumed ? 2 : !ffn_res_consumed ? 3 : 4;
    ffn0_phase_cycles[phase_index]++;
    ffn0_phase_total++;
    if(stage==1 && matrix_cfg_valid && cfg_ready &&
       ledger_claim_ready && cfg_owner_admitted)begin
      if(cfg_bo_base[0]!==STATE1_BASE || cfg_bo_span[0]!==64'd16919104 ||
         cfg_region_base[0]!==TMP_BASE || cfg_region_span[0]!==64'd8388608 ||
         cfg_row_stride_bytes!==64'd4096 || cfg_batch_stride_bytes!==64'd4194304)
        $fatal(1,"FFN4 Down claim descriptor changed");
      if(ffn0_down_claim_edge<0)begin
        ffn0_down_claim_edge=cycle;
        $display("FFN4_DOWN_BIND cycle=%0d bo=%h/%h region=%h/%h row=%0d batch=%0d",
          cycle,cfg_bo_base[0],cfg_bo_span[0],cfg_region_base[0],cfg_region_span[0],
          cfg_row_stride_bytes,cfg_batch_stride_bytes);
      end
    end
    if(stage==1 && owner_retire_valid && owner_retire_ready &&
       ffn0_owner_retire_edge<0)ffn0_owner_retire_edge=cycle;
    if(stage==1 && done_valid && done_ready && ffn0_done_consume_edge<0)
      ffn0_done_consume_edge=cycle;
    if(ffn_res_cfg_valid && ffn_res_cfg_ready && ffn0_res_cfg_edge<0)
      ffn0_res_cfg_edge=cycle;
    if(ffn_res_rsp_valid && ffn_res_rsp_ready && ffn0_res_rsp_edge<0)
      ffn0_res_rsp_edge=cycle;
    if(ffn_hidden_published && !ffn0_prev_local_publish)
      ffn0_local_publish_edge=cycle;
    if(ffn_tmp_reserved && !ffn0_prev_tmp_lock)ffn0_tmp_lock_edge=cycle;
    if(!ffn_tmp_reserved && ffn0_prev_tmp_lock)ffn0_tmp_unlock_edge=cycle;
    if(ffn_hidden_reserved && !ffn0_prev_hidden_ticket)
      ffn0_hidden_ticket_edge=cycle;
    if(!ffn_hidden_reserved && ffn0_prev_hidden_ticket)
      ffn0_hidden_release_edge=cycle;
    ffn0_prev_tmp_lock=ffn_tmp_reserved;
    ffn0_prev_hidden_ticket=ffn_hidden_reserved;
    ffn0_prev_local_publish=ffn_hidden_published;
    if(ffn_skip_arvalid && ffn_skip_arready)begin
      if(ffn0_first_skip_ar<0)ffn0_first_skip_ar=cycle;
      ffn0_last_skip_ar=cycle;
    end
    if(ffn_skip_rvalid && ffn_skip_rready)begin
      if(ffn0_first_skip_r<0)ffn0_first_skip_r=cycle;
      ffn0_last_skip_r=cycle;
    end
    if(ffn_down_arvalid && ffn_down_arready)begin
      if(ffn0_first_tmp_ar<0)ffn0_first_tmp_ar=cycle;
      ffn0_last_tmp_ar=cycle;
    end
    if(ffn_down_rvalid && ffn_down_rready)begin
      if(ffn0_first_tmp_r<0)ffn0_first_tmp_r=cycle;
      ffn0_last_tmp_r=cycle;
    end
    if(ffn_res_awvalid && ffn_res_awready)begin
      if(ffn0_first_hidden_aw<0)ffn0_first_hidden_aw=cycle;
      ffn0_last_hidden_aw=cycle;
    end
    if(ffn_res_wvalid && ffn_res_wready)begin
      if(ffn0_first_hidden_w<0)ffn0_first_hidden_w=cycle;
      ffn0_last_hidden_w=cycle;
    end
    if(ffn_res_bvalid && ffn_res_bready)begin
      if(ffn0_first_hidden_b<0)ffn0_first_hidden_b=cycle;
      ffn0_last_hidden_b=cycle;
    end
    if(top.ffn_residual.slot_accepted)begin
      if(ffn0_add_inflight)$fatal(1,"FFN0 additive slot overlapped");
      ffn0_add_inflight=1;
      ffn0_add_accept_edge=cycle;
    end
    if(top.ffn_residual.slot_returned)begin
      latency=cycle-ffn0_add_accept_edge;
      if(!ffn0_add_inflight || latency<0 || latency>255)
        $fatal(1,"FFN0 additive return without bounded accept");
      ffn0_add_latency_hist[latency]++;
      ffn0_add_latency_samples++;
      ffn0_add_inflight=0;
    end
  end
  localparam logic [63:0] LN_NORM_BASE=64'h300800000;
  string ln_fixture,bound_fixture,ffn_fixture;
  logic [511:0] ln_query_beats[0:15];
  logic [8191:0] ln_query_command;
  logic ln_candidate_valid=0,ln_candidate_ready,ln_candidate_reject;
  logic ln_published,ln_owner_released,ln_source_lease_active;
  logic ln_query_valid,ln_query_ready,ln_query_granted;
  logic [8191:0] ln_source_query_command,ln_source_release_command;
  logic ln_source_release_valid,ln_source_release_ready,ln_source_release_drained;
  logic ln_lease_pending,ln_admission_error,bridge_can_accept;
  logic [63:0] ln_shared_read_addr,ln_ext_bo_base,ln_ext_bo_span;
  logic [63:0] ln_ext_region_base,ln_ext_region_span;
  logic [63:0] ln_ext_row_stride,ln_ext_batch_stride;
  logic [511:0] ln_shared_read_data;
  logic [63:0] ln_shared_read_written;
  logic ln_ext_source_published,ln_ext_a_slot;
  logic [31:0] ln_ext_a_slot_epoch;
  logic [671:0] ln_ext_numeric_identity;
  logic [95:0] ln_ext_producer_context,ln_ext_quant_context,ln_ext_linear_context;
  logic [63:0] ln_ext_source_ref,ln_ext_a_ref,ln_ext_w_ref,ln_ext_dst_ref;
  logic [12:0] ln_ext_K;
  logic [4:0] ln_ext_rows;
  logic ln_physical_r_debt_zero;
  logic g_quant_task_debt_zero;
  // Wi's DDR descriptor remains bound after the matrix slot is reused for
  // Down's STATE1/TMP descriptor. Both Wi writer and reader use this record.
  localparam logic [63:0] WI_BO_BASE=DDR_BASE, WI_BO_SPAN=64'h2000000;
  localparam logic [63:0] WI_REGION_BASE=DDR_BASE+64'd4096;
  localparam logic [63:0] WI_REGION_SPAN=64'h1000000;
  localparam logic [63:0] WI_ROW_STRIDE=64'd20992;
  localparam logic [63:0] WI_BATCH_STRIDE=64'd21495808;
  logic [63:0] wi_region_base=WI_REGION_BASE;
  logic wi_writer_bound=0;
  logic [15:0] wi_matrix_n_held=0;
  logic [63:0] wi_writer_bo_base,wi_writer_bo_span,wi_writer_region_base;
  logic [63:0] wi_writer_region_span,wi_writer_row_stride,wi_writer_batch_stride;
  integer stage=0; // 0: Wi resident, 1: G/quant/Down
  logic prefill_select=1'b0,wi_cfg_valid,wi_cfg_ready,wi_cfg_reject,wi_reader_active;
  logic source_quant_valid,source_quant_ready,source_quant_reject;
  logic source_quant_owner_admitted;
  logic source_quant_done_valid,source_quant_done_ready;
  logic [2:0] source_quant_done_status;
  logic [63:0] source_quant_done_bad_element;
  logic [95:0] source_producer_context,source_quant_context;
  integer source_quant_accept_edge=-1,source_a_publish_edge=-1;
  integer source_first_ar=-1,source_last_ar=-1,source_first_r=-1,source_last_r=-1;
  integer source_ar_count=0,source_ar_beats=0,source_r_beats=0,source_quant_halves=0;
  logic [31:0] wi_ar_count,wi_r_count,wi_complete_rows;
  logic [63:0] wi_araddr;
  logic [7:0] wi_arlen;
  logic [2:0] wi_arsize;
  logic [1:0] wi_arburst;
  logic wi_arvalid,wi_arready,wi_rvalid,wi_rready,wi_rlast;
  logic [511:0] wi_rdata;
  logic [1:0] wi_rresp;
  // wi_reader lives in top.
  // producer lives in top.
  // w_binding lives in top.
  // wcache lives in top.
  // ledger lives in top.

  initial clk=0;always #5 clk=~clk;
  logic [255:0] aq[0:327];logic [15:0] asc[0:327];logic [31:0] outgold[0:20991];
  logic [511:0] wq0[0:41983],wq1[0:41983],wsc[0:5247];
  logic [3327:0] model[0:0];logic [1023:0] header[0:0];logic [127:0] auxwords[0:7];logic [63:0] config_words[0:12];
  logic [2047:0] vw[0:20991];logic [1023:0] vps[0:20991];
  string afixture,wfixture,streams,gfixture,wi_afixture,wi_wfixture,wi_streams;integer pilot;
  integer cycle=0,q_index[0:2],q_left[0:2],q_bytes[0:2],q_beats[0:2],q_bursts[0:2];
  logic prefix=0;
  // FFN1: passive pre-NBA handshake/retirement counters. No DUT input uses them.
  localparam integer FFN1_FAMILIES=35;
  logic [FFN1_FAMILIES-1:0][2:0] ffn1_event_inc;
  logic [FFN1_FAMILIES-1:0][63:0] ffn1_counts;
  logic [63:0] ffn1_work,ffn1_printed_work=0;
  integer ffn1_prev_ln_iter=0;
  logic [2:0] ffn1_ln_delta=0;
  logic ffn1_prev_a_pub=0,ffn1_prev_wload_done=0;
  logic ffn1_prev_dst_pub=0,ffn1_prev_source_lock=0;
  ffn1_progress_observer_v1 #(.FAMILIES(FFN1_FAMILIES))
    ffn1_observer(.clk,.rst_n,.event_inc(ffn1_event_inc),
                  .counts(ffn1_counts),.work(ffn1_work));
  // The generated LN cursor monitor updates on posedge with blocking
  // assignments. Sample its cumulative value on negedge to avoid a race
  // between simulator active processes; retire the delta next posedge.
  always @(negedge clk) if(rst_n)begin : ffn1_ln_progress_sample
    integer delta;
    delta=ln_source.semantic_progress_count-ffn1_prev_ln_iter;
    if(delta<0 || delta>7)
      $fatal(1,"FFN1 LN iteration counter invalid delta=%0d",delta);
    ffn1_ln_delta<=delta[2:0];
    ffn1_prev_ln_iter<=ln_source.semantic_progress_count;
  end
  always_comb begin
    ffn1_event_inc='0;
    ffn1_event_inc[0] = {2'b00, (ln_source.source_axi_arvalid && ln_source.source_axi_arready)};
    ffn1_event_inc[1] = {2'b00, (ln_source.source_axi_rvalid && ln_source.source_axi_rready)};
    ffn1_event_inc[2] = ffn1_ln_delta[2:0];
    ffn1_event_inc[3] = {2'b00, (ln_source.destination_axi_awvalid && ln_source.destination_axi_awready)} +
      {2'b00, (ln_source.destination_axi_wvalid && ln_source.destination_axi_wready)} +
      {2'b00, (ln_source.destination_axi_bvalid && ln_source.destination_axi_bready)};
    ffn1_event_inc[4] = {2'b00, (ln_source.producer_completion_write && ln_source.producer_completion_full_n)} +
      {2'b00, (ln_source.provenance_rsp_read && ln_source.provenance_rsp_empty_n)};
    ffn1_event_inc[5] = {2'b00, (ln_query_valid && ln_query_ready && ln_query_granted)} +
      {2'b00, (ln_source_release_valid && ln_source_release_ready && ln_source_release_drained)};
    ffn1_event_inc[6] = {2'b00, (stage==0 && g_m_axi_arvalid && g_m_axi_arready)} +
      {2'b00, (stage==0 && g_m_axi_rvalid && g_m_axi_rready)};
    ffn1_event_inc[7] = {2'b00, (top.producer.quant_task.q_out_valid && top.producer.quant_task.q_out_ready)} +
      {2'b00, (top.producer.quant_task.q_done_valid && top.producer.quant_task.q_done_ready)};
    ffn1_event_inc[8] = {2'b00, (fa_commit_valid && fa_commit_ready)} +
      {2'b00, (top.producer.quant_task.a_publish && !ffn1_prev_a_pub)};
    ffn1_event_inc[9] = {2'b00, (wc_arvalid[0] && wc_arready[0])};
    ffn1_event_inc[10] = {2'b00, (wc_rvalid[0] && wc_rready[0])};
    ffn1_event_inc[11] = {2'b00, (wc_arvalid[1] && wc_arready[1])};
    ffn1_event_inc[12] = {2'b00, (wc_rvalid[1] && wc_rready[1])};
    ffn1_event_inc[13] = {2'b00, (wc_arvalid[2] && wc_arready[2])};
    ffn1_event_inc[14] = {2'b00, (wc_rvalid[2] && wc_rready[2])};
    ffn1_event_inc[15] = {2'b00, (wc_aux_arvalid && wc_aux_arready)} +
      {2'b00, (wc_aux_rvalid && wc_aux_rready)};
    ffn1_event_inc[16] = {2'b00, (wc_load_valid && wc_load_ready)} +
      {2'b00, (wc_load_done && !ffn1_prev_wload_done)} +
      {2'b00, (w_lease_valid && w_lease_ready)} +
      {2'b00, (w_release_valid && w_release_ready)};
    ffn1_event_inc[17] = {2'b00, (a_read_valid && a_read_ready)} +
      {2'b00, (a_ret_valid && a_ret_ready)};
    ffn1_event_inc[18] = {2'b00, (w_read_valid && w_read_ready)} +
      {2'b00, (w_ret_valid && w_ret_ready)};
    ffn1_event_inc[19] = {2'b00, (top.dut.front_issue_valid && top.dut.front_issue_ready)} +
      {2'b00, (|(top.dut.commit_valid & top.dut.commit_ready))};
    ffn1_event_inc[20] = {2'b00, (m_axi_awvalid[0] && m_axi_awready[0])} +
      {2'b00, (m_axi_wvalid[0] && m_axi_wready[0])} +
      {2'b00, (m_axi_bvalid[0] && m_axi_bready[0])};
    ffn1_event_inc[21] = {2'b00, (owner_retire_valid && owner_retire_ready)} +
      {2'b00, (done_valid && done_ready)};
    ffn1_event_inc[22] = {2'b00, (wi_arvalid && wi_arready)} +
      {2'b00, (wi_rvalid && wi_rready)};
    ffn1_event_inc[23] = {2'b00, (g_wi_valid && g_wi_ready)} +
      {2'b00, (g_wi_row_done_valid && g_wi_row_done_ready)};
    ffn1_event_inc[24] = {2'b00, (top.producer.vector_row.arithmetic_accept)};
    ffn1_event_inc[25] = {2'b00, (top.producer.vector_row.core_commit && top.producer.vector_row.core_return_legal)};
    ffn1_event_inc[26] = {2'b00, (top.producer.v_valid && top.producer.v_ready)};
    ffn1_event_inc[27] = {2'b00, (g_m_axi_awvalid && g_m_axi_awready)} +
      {2'b00, (g_m_axi_wvalid && g_m_axi_wready)} +
      {2'b00, (g_m_axi_bvalid && g_m_axi_bready)};
    ffn1_event_inc[28] = {2'b00, (stage==1 && g_m_axi_arvalid && g_m_axi_arready)} +
      {2'b00, (stage==1 && g_m_axi_rvalid && g_m_axi_rready)};
    ffn1_event_inc[29] = {2'b00, (stage==1 && top.producer.quant_task.q_out_valid && top.producer.quant_task.q_out_ready)} +
      {2'b00, (stage==1 && top.producer.quant_task.q_done_valid && top.producer.quant_task.q_done_ready)};
    ffn1_event_inc[30] = {2'b00, (ffn_res_cfg_valid && ffn_res_cfg_ready)};
    ffn1_event_inc[31] = {2'b00, (ffn_skip_arvalid && ffn_skip_arready)} +
      {2'b00, (ffn_skip_rvalid && ffn_skip_rready)} +
      {2'b00, (ffn_down_arvalid && ffn_down_arready)} +
      {2'b00, (ffn_down_rvalid && ffn_down_rready)};
    ffn1_event_inc[32] = {2'b00, (top.ffn_residual.slot_accepted)} +
      {2'b00, (top.ffn_residual.slot_returned)} +
      {2'b00, (top.ffn_residual.slot_consumed)};
    ffn1_event_inc[33] = {2'b00, (ffn_res_awvalid && ffn_res_awready)} +
      {2'b00, (ffn_res_wvalid && ffn_res_wready)} +
      {2'b00, (ffn_res_bvalid && ffn_res_bready)};
    ffn1_event_inc[34] = {2'b00, (ffn_res_rsp_valid && ffn_res_rsp_ready)} +
      {2'b00, (ffn_dst_published && !ffn1_prev_dst_pub)} +
      {2'b00, (!ffn_source_locked && ffn1_prev_source_lock)};
  end
  always @(posedge clk) if(rst_n)begin : ffn1_progress_print
    if(ffn_res_cfg_valid)begin
      if(ffn_res_dst_ref!==64'h0000010100000002 ||
         ffn_res_local_context[224+:64]!==ffn_res_dst_ref ||
         top.ffn_residual.cfg_dst_role!==8'd1 ||
         top.ffn_residual.cfg_dst_bank!==8'd1 ||
         top.ffn_residual.cfg_dst_epoch!==32'd2 ||
         top.ffn_residual.cfg_dst_base!==STATE1_BASE ||
         top.ffn_residual.cfg_dst_capacity!==32'd16919104 ||
         top.ffn_residual.cfg_dst_bytes!==32'd16384)
        $fatal(1,"FFN1 fixed HIDDEN destination wiring mismatch");
      if(ffn_res_cfg_ready)
        $display("FFN1_FIXED_DST_ACCEPT cycle=%0d ref=%h base=%h capacity=%0d bytes=%0d",
          cycle,ffn_res_dst_ref,top.ffn_residual.cfg_dst_base,
          top.ffn_residual.cfg_dst_capacity,top.ffn_residual.cfg_dst_bytes);
    end
    ffn1_prev_a_pub<=top.producer.quant_task.a_publish;
    ffn1_prev_wload_done<=wc_load_done;
    ffn1_prev_dst_pub<=ffn_dst_published;
    ffn1_prev_source_lock<=ffn_source_locked;
    if(cycle%2048==0 && ffn1_work>ffn1_printed_work)begin
      ffn1_printed_work=ffn1_work;
      $display("FFN1_PROGRESS work=%0d lnar=%0d lnr=%0d lnit=%0d lnwr=%0d lnport=%0d qowner=%0d qread=%0d qmath=%0d afill=%0d w0ar=%0d w0r=%0d w1ar=%0d w1r=%0d wsar=%0d wsr=%0d aux=%0d wpub=%0d ma=%0d mw=%0d mps=%0d mwr=%0d mret=%0d wiread=%0d wicons=%0d giss=%0d gret=%0d gemit=%0d gwr=%0d gqread=%0d gqmath=%0d rcfg=%0d rsrc=%0d radd=%0d rwr=%0d rdone=%0d",
        ffn1_work,
        ffn1_counts[0],
        ffn1_counts[1],
        ffn1_counts[2],
        ffn1_counts[3],
        ffn1_counts[4],
        ffn1_counts[5],
        ffn1_counts[6],
        ffn1_counts[7],
        ffn1_counts[8],
        ffn1_counts[9],
        ffn1_counts[10],
        ffn1_counts[11],
        ffn1_counts[12],
        ffn1_counts[13],
        ffn1_counts[14],
        ffn1_counts[15],
        ffn1_counts[16],
        ffn1_counts[17],
        ffn1_counts[18],
        ffn1_counts[19],
        ffn1_counts[20],
        ffn1_counts[21],
        ffn1_counts[22],
        ffn1_counts[23],
        ffn1_counts[24],
        ffn1_counts[25],
        ffn1_counts[26],
        ffn1_counts[27],
        ffn1_counts[28],
        ffn1_counts[29],
        ffn1_counts[30],
        ffn1_counts[31],
        ffn1_counts[32],
        ffn1_counts[33],
        ffn1_counts[34]);
    end
    if(prefix && ln_source.source_ar_count>=1 &&
       ln_source.source_r_count>=64)begin
      $display("FFN0_PREFIX_PILOT_PASS cycle=%0d source_AR=%0d source_R=%0d work=%0d",
        cycle,ln_source.source_ar_count,ln_source.source_r_count,ffn1_work);
      $finish;
    end
  end
  logic q_active[0:2];integer aux_index=0,aux_left=0,aux_bytes=0;logic aux_active=0;
  integer ps_checks[0:3],a_checks=0,w_checks=0,output_words=0,output_beats=0,bretired=0,held_b=0;
  logic output_seen[0:20991];logic aw_seen=0,w_seen=0,stored=0;integer bdelay=0;
  logic [63:0] aw_addr,wd_strb;logic [511:0] wd_data;
  // All edge timestamps below use this monitor's pre-NBA posedge sample.
  // Exclusive state bins cover [cfg_accept_edge, first_done_valid_edge).
  // Wait/activity counters overlap; they are never added as a latency total.
  integer measure_a_start=-1,measure_a_publish=-1,measure_w_start=-1,measure_w_publish=-1;
  integer measure_cfg=-1,measure_done=-1,measure_consume=-1,measure_legacy_hold_end=-1;
  integer measure_first_issue=-1,measure_last_issue=-1,measure_first_launch=-1,measure_last_launch=-1;
  integer measure_first_ps=-1,measure_last_ps=-1,measure_first_aw=-1,measure_last_aw=-1;
  integer measure_first_w=-1,measure_last_w=-1,measure_first_b=-1,measure_last_b=-1;
  integer measure_state[0:12],measure_state_sum=0,measure_consumes=0,measure_done_hold=0;
  integer measure_a_request_wait=0,measure_a_return_wait=0,measure_a_return_blocked=0;
  integer measure_w_request_wait=0,measure_w_return_wait=0,measure_w_return_blocked=0;
  integer measure_front_wait=0,measure_compute_active=0,measure_launches=0,measure_ps_cycles=0;
  integer measure_ps_blocked=0,measure_writer_packet_wait=0,measure_writer_tx=0,measure_writer_wait_b=0;
  integer measure_aw_wait=0,measure_w_wait=0,measure_b_backpressure=0;
  integer measure_tb_aw_gate=0,measure_tb_w_gate=0,measure_aw=0,measure_w=0,measure_b=0;
  integer measure_useful_bytes=0,measure_physical_bytes=0,expected_output_beats=1312;
  integer measure_w_ar_wait[0:2],measure_w_r_gap[0:2],measure_w_r_blocked[0:2];
  integer measure_aux_ar_wait=0,measure_aux_r_gap=0,measure_aux_r_blocked=0;
  logic [15:0] measure_done_status;logic [63:0] measure_done_rank,measure_done_bad;
  task automatic measurement_report(input string mode);
    integer sum;
    sum=0;for(int st=0;st<13;st++)sum+=measure_state[st];
    if(sum!=measure_state_sum)$fatal(1,"Down measurement state accounting");
    if(mode=="full" && (measure_cfg<0 || measure_done<0 || measure_consume<0 ||
       sum!=measure_done-measure_cfg || measure_consumes!=1 ||
       measure_aw!=expected_output_beats || measure_w!=expected_output_beats || measure_b!=expected_output_beats ||
       measure_useful_bytes!=(stage==0 ? 83968 : 16384) || measure_physical_bytes!=expected_output_beats*64))
      $fatal(1,"Down measurement complete coverage");
    $display("DOWN_MEASURE_BOUNDARIES mode=%s sample=pre_NBA_posedge A_fill_accept=%0d A_publish_post_NBA=%0d W_load_accept=%0d W_publish_post_NBA=%0d cfg_accept=%0d first_issue=%0d last_issue=%0d first_launch=%0d last_launch=%0d first_PS=%0d last_PS=%0d first_AW=%0d last_AW=%0d first_W=%0d last_W=%0d first_B=%0d last_B=%0d first_done_valid=%0d actual_done_consume=%0d legacy_hold_end=%0d finish=%0d",mode,measure_a_start,measure_a_publish,measure_w_start,measure_w_publish,measure_cfg,measure_first_issue,measure_last_issue,measure_first_launch,measure_last_launch,measure_first_ps,measure_last_ps,measure_first_aw,measure_last_aw,measure_first_w,measure_last_w,measure_first_b,measure_last_b,measure_done,measure_consume,measure_legacy_hold_end,cycle);
    $display("DOWN_MEASURE_STATES mode=%s exclusive=1 start_inclusive_cfg_accept=1 end_exclusive_first_done=1 cycles=%0d s0=%0d s1=%0d s2=%0d s3=%0d s4=%0d s5=%0d s6=%0d s7=%0d s8=%0d s9=%0d s10=%0d s11=%0d s12=%0d",mode,sum,measure_state[0],measure_state[1],measure_state[2],measure_state[3],measure_state[4],measure_state[5],measure_state[6],measure_state[7],measure_state[8],measure_state[9],measure_state[10],measure_state[11],measure_state[12]);
    $display("DOWN_MEASURE_OVERLAP mode=%s exclusive=0 A_request_not_ready=%0d A_WAIT_no_return=%0d A_return_not_ready=%0d W_request_not_ready=%0d W_pending_no_return=%0d W_return_not_ready=%0d front_issue_not_ready=%0d configured_front_not_done=%0d launch_edges=%0d PS_commit_edges=%0d PS_commit_not_ready=%0d writer_packet_not_ready=%0d writer_tx_valid=%0d writer_AW_W_sent_no_B=%0d AW_not_ready=%0d W_not_ready=%0d B_not_ready=%0d",mode,measure_a_request_wait,measure_a_return_wait,measure_a_return_blocked,measure_w_request_wait,measure_w_return_wait,measure_w_return_blocked,measure_front_wait,measure_compute_active,measure_launches,measure_ps_cycles,measure_ps_blocked,measure_writer_packet_wait,measure_writer_tx,measure_writer_wait_b,measure_aw_wait,measure_w_wait,measure_b_backpressure);
    $display("DOWN_MEASURE_FRONT mode=%s exclusive=0 native_dependency_stall=%0d native_credit_stall=%0d native_space_stall=%0d native_launch_stall=%0d native_commit_stall=%0d",mode,top.dut.frontend.busy_stall_count,top.dut.frontend.credit_stall_count,top.dut.frontend.front_stall_count,top.dut.frontend.launch_stall_count,top.dut.frontend.commit_stall_count);
    $display("DOWN_MEASURE_LOAD mode=%s exclusive=0 q0_AR_not_ready=%0d q1_AR_not_ready=%0d scale_AR_not_ready=%0d q0_active_R_gap=%0d q1_active_R_gap=%0d scale_active_R_gap=%0d q0_R_not_ready=%0d q1_R_not_ready=%0d scale_R_not_ready=%0d AUX_AR_not_ready=%0d AUX_active_R_gap=%0d AUX_R_not_ready=%0d q0_R=%0d q1_R=%0d scale_R=%0d",mode,measure_w_ar_wait[0],measure_w_ar_wait[1],measure_w_ar_wait[2],measure_w_r_gap[0],measure_w_r_gap[1],measure_w_r_gap[2],measure_w_r_blocked[0],measure_w_r_blocked[1],measure_w_r_blocked[2],measure_aux_ar_wait,measure_aux_r_gap,measure_aux_r_blocked,q_beats[0],q_beats[1],q_beats[2]);
    $display("DOWN_MEASURE_OUTPUT mode=%s exclusive=0 expected_output_beats=%0d actual_AW=%0d actual_W=%0d actual_B=%0d useful_strobe_bytes=%0d physical_W_bytes=%0d TB_periodic_AW_gate=%0d TB_periodic_W_gate=%0d TB_B_delay_decrements=%0d done_not_ready_edges=%0d actual_done_consumes=%0d DUT_command_cycles=%0d",mode,expected_output_beats,measure_aw,measure_w,measure_b,measure_useful_bytes,measure_physical_bytes,measure_tb_aw_gate,measure_tb_w_gate,held_b,measure_done_hold,measure_consumes,command_cycles);
  endtask
  task automatic tick;@(posedge clk);#1;endtask
  assign matrix_cfg_valid=stage==0 ? cfg_valid : ffn_matrix_cfg_valid;
  assign ledger_claim_valid=matrix_cfg_valid;
  assign ledger_retire_debt_zero=a_read_debt_zero && !a_ret_valid && !w_ret_valid &&
      wc_slot_readers[0]==0 && fa_slot_state[0]==0 &&
      actual_aw_count[0]==actual_b_count[0] && actual_w_count[0]==actual_b_count[0];
  always_comb begin
    wc_commit_ready=4'hf;
    for(int pp=0;pp<3;pp++)begin
      wc_arready[pp]=rst_n && !q_active[pp] && cycle%3!=pp;
      wc_rvalid[pp]=rst_n && q_active[pp] && cycle%5!=pp;
      wc_rdata[pp]=0;
      if(q_active[pp])case(pp)
        0:wc_rdata[pp]=wq0[q_index[pp]];
        1:wc_rdata[pp]=wq1[q_index[pp]];
        2:wc_rdata[pp]=wsc[q_index[pp]];
      endcase
      wc_rresp[pp]=0;wc_rlast[pp]=q_active[pp] && q_left[pp]==1;
    end
    wc_aux_arready=rst_n && !aux_active && cycle%3!=0;
    wc_aux_rvalid=rst_n && aux_active && cycle%5!=0;
    wc_aux_rdata=aux_active ? auxwords[aux_index] : 0;
    wc_aux_rresp=0;wc_aux_rlast=aux_active && aux_left==1;
  end
  always @(negedge clk)begin
    m_axi_awready=0;m_axi_wready=0;
    m_axi_awready[0]=rst_n && !aw_seen && cycle%7!=0;
    m_axi_wready[0]=rst_n && !w_seen && cycle%11!=0;
    if(bdelay>0)begin bdelay--;held_b++;if(bdelay==0)begin m_axi_bvalid[0]=1;m_axi_bresp[0]=0;end end
  end
  always @(posedge clk)begin : endpoint_monitor
    integer n,page,remaining,seq,g,t,idx,rr,col,word;
    cycle++;
    // M005: a clock-only witness around the AT063 stop point.  The guard
    // deliberately ignores this line as semantic work.
    if(cycle>=358880 && cycle<=358884)
      $display("M005_DOWN_CLOCK edge=posedge cycle=%0d time=%0t cfg_valid=%b matrix_valid=%b ledger_ready=%b ledger_admitted=%b",
        cycle,$time,cfg_valid,ffn_matrix_cfg_valid,ledger_claim_ready,cfg_owner_admitted);
    if(cycle>40000000)$fatal(1,"resident cycle cap state=%0d stripes=%0d",top.dut.state,actual_stripes);
    if(!rst_n)begin
      aux_active<=0;aux_index<=0;aux_left<=0;aux_bytes<=0;
      for(int pp=0;pp<3;pp++)begin q_active[pp]<=0;q_index[pp]<=0;q_left[pp]<=0;q_bytes[pp]<=0;q_beats[pp]<=0;q_bursts[pp]<=0;end
      aw_seen=0;w_seen=0;stored=0;bdelay=0;m_axi_bvalid<=0;
    end else begin
      if(g_cfg_valid && g_cfg_ready && !g_cfg_reject && measure_a_start<0)measure_a_start=cycle;
      if(wc_load_valid && wc_load_ready && measure_w_start<0)measure_w_start=cycle;
      if(cfg_valid && cfg_ready)begin
        if(measure_cfg>=0)$fatal(1,"matrix measurement duplicate cfg in stage");
        measure_cfg=cycle;
        if(stage==0)begin
          if(wi_writer_bound || cfg_N!==16'd5248 ||
             cfg_bo_base[0]!==WI_BO_BASE ||
             cfg_bo_span[0]!==WI_BO_SPAN || cfg_region_base[0]!==WI_REGION_BASE ||
             cfg_region_span[0]!==WI_REGION_SPAN ||
             cfg_row_stride_bytes!==WI_ROW_STRIDE ||
             cfg_batch_stride_bytes!==WI_BATCH_STRIDE)
            $fatal(1,"FFN4 Wi writer descriptor changed");
          wi_writer_bound=1;
          wi_matrix_n_held=cfg_N;
          wi_writer_bo_base=cfg_bo_base[0];wi_writer_bo_span=cfg_bo_span[0];
          wi_writer_region_base=cfg_region_base[0];
          wi_writer_region_span=cfg_region_span[0];
          wi_writer_row_stride=cfg_row_stride_bytes;
          wi_writer_batch_stride=cfg_batch_stride_bytes;
          $display("FFN4_WI_WRITER_BIND cycle=%0d bo=%h/%h region=%h/%h row=%0d batch=%0d",
            cycle,wi_writer_bo_base,wi_writer_bo_span,wi_writer_region_base,
            wi_writer_region_span,wi_writer_row_stride,wi_writer_batch_stride);
        end
      end
      if(done_valid)begin
        if(measure_done<0)begin
          measure_done=cycle;measure_done_status=done_status;
          measure_done_rank=done_first_error_rank;measure_done_bad=done_bad_element;
        end
        if(done_status!==measure_done_status || done_first_error_rank!==measure_done_rank ||
           done_bad_element!==measure_done_bad)$fatal(1,"Down held response payload changed");
        if(done_ready)begin
          measure_consumes++;measure_consume=cycle;
          if(measure_consumes!=1)$fatal(1,"Down duplicate actual consume");
        end else measure_done_hold++;
      end
      if(measure_cfg>=0 && measure_done<0)begin
        if(int'(top.dut.state)<0 || int'(top.dut.state)>12)$fatal(1,"Down measurement state range");
        measure_state[int'(top.dut.state)]++;measure_state_sum++;
        if(a_read_valid && !a_read_ready)measure_a_request_wait++;
        if(top.dut.state==5 && !a_ret_valid)measure_a_return_wait++;
        if(a_ret_valid && !a_ret_ready)measure_a_return_blocked++;
        if(w_read_valid && !w_read_ready)measure_w_request_wait++;
        if(top.dut.state==6 && top.dut.w_pending_reads!=0 && !w_ret_valid)measure_w_return_wait++;
        if(w_ret_valid && !w_ret_ready)measure_w_return_blocked++;
        if(top.dut.front_issue_valid && !top.dut.front_issue_ready)measure_front_wait++;
        if(top.dut.configured && !top.dut.front_done)measure_compute_active++;
        if(top.dut.front_issue_valid && top.dut.front_issue_ready)begin
          if(measure_first_issue<0)measure_first_issue=cycle;measure_last_issue=cycle;
        end
        if(top.dut.frontend.launch)begin
          measure_launches++;if(measure_first_launch<0)measure_first_launch=cycle;measure_last_launch=cycle;
        end
        if(|(top.dut.commit_valid & top.dut.commit_ready))begin
          measure_ps_cycles++;if(measure_first_ps<0)measure_first_ps=cycle;measure_last_ps=cycle;
        end
        if(|(top.dut.commit_valid & ~top.dut.commit_ready))measure_ps_blocked++;
        if(top.dut.writers[0].writer.packet_valid && !top.dut.writers[0].writer.packet_ready)measure_writer_packet_wait++;
        if(top.dut.writers[0].writer.tx_valid)measure_writer_tx++;
        if(top.dut.writers[0].writer.tx_valid && top.dut.writers[0].writer.tx_aw_sent &&
           top.dut.writers[0].writer.tx_w_sent && !m_axi_bvalid[0])measure_writer_wait_b++;
        if(m_axi_awvalid[0] && !m_axi_awready[0])begin
          measure_aw_wait++;if(!aw_seen)measure_tb_aw_gate++;
        end
        if(m_axi_wvalid[0] && !m_axi_wready[0])begin
          measure_w_wait++;if(!w_seen)measure_tb_w_gate++;
        end
        if(m_axi_bvalid[0] && !m_axi_bready[0])measure_b_backpressure++;
      end
      if(measure_w_start>=0 && measure_w_publish<0)begin
        for(int pp=0;pp<3;pp++)begin
          if(wc_arvalid[pp] && !wc_arready[pp])measure_w_ar_wait[pp]++;
          if(q_active[pp] && !wc_rvalid[pp])measure_w_r_gap[pp]++;
          if(wc_rvalid[pp] && !wc_rready[pp])measure_w_r_blocked[pp]++;
        end
        if(wc_aux_arvalid && !wc_aux_arready)measure_aux_ar_wait++;
        if(aux_active && !wc_aux_rvalid)measure_aux_r_gap++;
        if(wc_aux_rvalid && !wc_aux_rready)measure_aux_r_blocked++;
      end
      if(m_axi_awvalid[0] && m_axi_awready[0])begin
        measure_aw++;if(measure_first_aw<0)measure_first_aw=cycle;measure_last_aw=cycle;
      end
      if(m_axi_wvalid[0] && m_axi_wready[0])begin
        measure_w++;measure_physical_bytes+=64;
        for(int byte_lane=0;byte_lane<64;byte_lane++)if(m_axi_wstrb[0][byte_lane])measure_useful_bytes++;
        if(measure_first_w<0)measure_first_w=cycle;measure_last_w=cycle;
      end
      if(m_axi_bvalid[0] && m_axi_bready[0])begin
        measure_b++;if(measure_first_b<0)measure_first_b=cycle;measure_last_b=cycle;
      end
      for(int pp=0;pp<3;pp++)begin
        if(wc_arvalid[pp] && wc_arready[pp])begin
          if(q_active[pp] || wc_araddr[pp]!=wc_load_base[pp]+q_bytes[pp] || wc_arsize[pp]!=6 || wc_arburst[pp]!=1)$fatal(1,"resident physical W AR identity p=%0d",pp);
          remaining=(wc_load_bytes[pp]-q_bytes[pp])/64;page=(4096-int'(wc_araddr[pp]%4096))/64;n=remaining<64?remaining:64;if(n>page)n=page;
          if(n<1 || int'(wc_arlen[pp])+1!=n)$fatal(1,"resident W AR boundary");
          q_active[pp]<=1;q_index[pp]<=q_bytes[pp]/64;q_left[pp]<=n;q_bytes[pp]<=q_bytes[pp]+n*64;q_bursts[pp]<=q_bursts[pp]+1;
        end
        if(wc_rvalid[pp] && wc_rready[pp])begin
          if(!q_active[pp] || q_left[pp]<1 || wc_rlast[pp]!=(q_left[pp]==1))$fatal(1,"resident W R debt");
          q_index[pp]<=q_index[pp]+1;q_left[pp]<=q_left[pp]-1;q_beats[pp]<=q_beats[pp]+1;if(wc_rlast[pp])q_active[pp]<=0;
          if(pp==0 && (q_beats[0]+1)%512==0)
            $display("MATRIX_PROGRESS cycle=%0d stage=%0d W_q0_R=%0d W_q1_R=%0d W_scale_R=%0d",cycle,stage,q_beats[0]+1,q_beats[1],q_beats[2]);
        end
      end
      if(pilot && stage==0 && q_beats[0]>=1024 && q_beats[1]>=1024 && q_beats[2]>=128)begin
        if(fa_slot_state[0]!=2 || fa_physical_half_commits!=256 || fa_physical_scale_commits!=128)
          $fatal(1,"WIGQD pilot Wi A publication lost");
        $display("QWIGQD0_PILOT_PASS cycle=%0d source_Q_R=%0d source_A_published=1 W_q0_R=%0d W_q1_R=%0d W_scale_R=%0d Wi_output=NOT_RUN G=NOT_RUN Down=NOT_RUN",cycle,source_r_beats,q_beats[0],q_beats[1],q_beats[2]);
        $finish;
      end
      if(wc_aux_arvalid && wc_aux_arready)begin
        if(aux_active || wc_aux_araddr!=wc_load_aux_base+aux_bytes || wc_aux_arsize!=4 || wc_aux_arburst!=1)$fatal(1,"resident physical AUX AR");
        aux_active<=1;aux_index<=aux_bytes/16;aux_left<=int'(wc_aux_arlen)+1;aux_bytes<=aux_bytes+(int'(wc_aux_arlen)+1)*16;
      end
      if(wc_aux_rvalid && wc_aux_rready)begin aux_index<=aux_index+1;aux_left<=aux_left-1;if(wc_aux_rlast)aux_active<=0;end
      if(a_ret_valid && a_ret_ready && top.dut.state==5)begin
        if(a_ret_group!=a_checks || a_ret_row_block_base!=0 || a_ret_rows!=4 || a_ret_numeric_identity!==cfg_numeric_identity || a_ret_linear_context!==cfg_linear_context)$fatal(1,"resident full A return identity");
        for(int r=0;r<4;r++)begin
          int expected_index;
          expected_index=r*(stage==0 ? 32 : 82)+int'(a_ret_group);
          if(a_ret_q[r]!==aq[expected_index] || a_ret_scale[r]!==asc[expected_index])
            $fatal(1,"resident full A actual bank q/scale stage=%0d",stage);
        end
        a_checks++;
      end
      if(w_ret_valid && w_ret_ready && top.dut.state==6)begin
        seq=w_checks;g=seq/(stage==0 ? 656 : 128);t=seq%(stage==0 ? 656 : 128);
        if(w_ret_q[0]!==vw[seq] || w_ret_tile!=t || w_ret_group!=g || w_ret_model_identity!==cfg_w_model_identity || w_ret_numeric_identity!==cfg_numeric_identity || w_ret_task_context!==cfg_linear_context || w_ret_mask[0]!=8'hff)$fatal(1,"resident full W actual bank return seq=%0d tile=%0d group=%0d",seq,w_ret_tile,w_ret_group);
        w_checks++;
      end
      for(int r=0;r<4;r++)if(top.dut.commit_valid[r] && top.dut.commit_ready[r])begin
        seq=int'(top.dut.commit_tag[r*192+36+:27]);
        if(seq!=ps_checks[r] || top.dut.commit_bad[r*8+:8]!=0 || top.dut.commit_ps[r*256+:256]!==vps[seq][r*256+:256])$fatal(1,"resident PS independent gold row=%0d seq=%0d",r,seq);
        ps_checks[r]++;
        if(r==0 && ps_checks[r]%128==0)$display("MATRIX_PROGRESS cycle=%0d stripes=%0d ps0=%0d outputs=%0d",cycle,actual_stripes,ps_checks[0],output_words);
      end
      if(|m_axi_awvalid[1] || |m_axi_wvalid[1])$fatal(1,"Down shard1 issued");
      if(m_axi_awvalid[0] && m_axi_awready[0])begin
        if(aw_seen || m_axi_awlen[0]!=0 || m_axi_awsize[0]!=6 || m_axi_awburst[0]!=1)$fatal(1,"resident output AW");
        aw_seen=1;aw_addr=m_axi_awaddr[0];
      end
      if(m_axi_wvalid[0] && m_axi_wready[0])begin
        if(w_seen || !m_axi_wlast[0])$fatal(1,"resident output W");
        w_seen=1;wd_data=m_axi_wdata[0];wd_strb=m_axi_wstrb[0];
      end
      if(aw_seen && w_seen && !stored)begin
        if(aw_addr<cfg_region_base[0] || aw_addr>=cfg_region_base[0]+(stage==0 ? 83968 : 16384) || aw_addr[5:0]!=0)
          $fatal(1,"resident physical output address stage=%0d addr=%h",stage,aw_addr);
        idx=int'((aw_addr-cfg_region_base[0])/4);
        for(int lane=0;lane<16;lane++)begin
          if(wd_strb[lane*4+:4]!=0 && wd_strb[lane*4+:4]!=4'hf)$fatal(1,"resident output word strobe");
          if(wd_strb[lane*4+:4]==4'hf)begin
            if(idx+lane>=(stage==0 ? 20992 : 4096) || output_seen[idx+lane] || wd_data[lane*32+:32]!==outgold[idx+lane])$fatal(1,"resident final output gold index=%0d got=%h gold=%h",idx+lane,wd_data[lane*32+:32],outgold[idx+lane]);
            output_seen[idx+lane]=1;output_words++;
          end
        end
        for(int lane=0;lane<64;lane++)if(wd_strb[lane])begin
          if(stage==0)begin
            if(aw_addr+64>DDR_BASE+DDR_BYTES || aw_addr<DDR_BASE)
              $fatal(1,"Wi DDR write outside BO");
            ddr[int'(aw_addr-DDR_BASE)+lane]=wd_data[lane*8+:8];
            ddr_written[int'(aw_addr-DDR_BASE)+lane]=1;
          end else begin
            if(aw_addr<TMP_BASE || aw_addr+64>TMP_BASE+16384 ||
               state1_tmp_written[int'(aw_addr-TMP_BASE)+lane])
              $fatal(1,"Down TMP write outside or duplicate addr=%h",aw_addr+lane);
            state1_tmp[int'(aw_addr-TMP_BASE)+lane]=wd_data[lane*8+:8];
            state1_tmp_written[int'(aw_addr-TMP_BASE)+lane]=1;
          end
        end
        output_beats++;stored=1;bdelay=17+(output_beats%3);
      end
      if(m_axi_bvalid[0] && m_axi_bready[0])begin m_axi_bvalid[0]<=0;aw_seen=0;w_seen=0;stored=0;bretired++;end
      if((owner_retire_valid || done_valid || ledger_parent_publications>stage) &&
         (aw_seen || w_seen || bdelay!=0 || m_axi_bvalid[0] || output_words!=(stage==0 ? 20992 : 4096) || bretired!=output_beats))$fatal(1,"resident published before actual last B/debt zero");
      if(top.dut.protocol_fault || top.dut.numeric_fault || top.dut.front_protocol || top.dut.adapter_protocol || top.dut.bias_protocol || top.dut.bias_numerical || (|top.dut.writer_fault))$fatal(1,"resident normal fault state=%0d front=%b adapter=%b bias=%b writers=%b stripes=%0d",top.dut.state,top.dut.front_protocol,top.dut.adapter_protocol,top.dut.bias_protocol,top.dut.writer_fault,actual_stripes);
    end
  end

  logic [31:0] wi_fixture[0:20991],gate_gold[0:10495],d_gold[0:327],recip_gold[0:327];
  logic gate_written[0:2623];

  integer g_write_beats=0,g_read_beats=0,g_quant_halves=0,g_held_b=0;
  integer g_bdelay=0,g_rdelay=0,g_rleft=0,g_rindex=0;
  integer wi_accepted=0,wi_rows_retired=0;
  integer wi_reader_first_ar=-1,wi_reader_last_ar=-1,wi_reader_first_r=-1,wi_reader_last_r=-1;
  integer wi_reader_row_edge[0:3];
  integer gate_first_aw=-1,gate_last_aw=-1,gate_first_w=-1,gate_last_w=-1;
  integer gate_first_b=-1,gate_last_b=-1,quant_first_r=-1,quant_last_r=-1;
  integer g_cfg_edge=-1,quant_a_publish_edge=-1;
  // WIGQD1: passive, bounded observation of accepted work. These counters
  // never drive the DUT or memory response policy.
  integer obs_g_cfg=0,obs_wi_cfg=0,obs_wi_ar=0,obs_wi_r=0,obs_wi_scalar=0;
  integer obs_wi_row=0,obs_g_issue=0,obs_g_return=0,obs_g_emit=0;
  integer obs_gate_aw=0,obs_gate_w=0,obs_gate_b=0,obs_q_ar=0,obs_q_r=0;
  integer obs_q_half=0,obs_q_row=0,obs_a_publish=0,obs_g_cfg_cycle=-1;
  task automatic obs_diag(input string tag);
    $display("WIGQD_DIAG tag=%s cycle=%0d stage=%0d gphase=%0d rstate=%0d rrow=%0d rword=%0d rbeat=%0d rhold=%0b rpend=%0b vcfg=%0b/%0b var=%0b/%0b vr=%0b/%0b vw=%0b/%0b vrow=%0b/%0b debt=%0b grow=%0d gissued=%0d greturned=%0d gcredit=%0d gw=%0d gb=%0d qphase=%0d qar=%0d qr=%0d qhalf=%0d astate=%0d aepoch=%0d",
      tag,cycle,stage,top.producer.phase,top.wi_reader.state,top.wi_reader.row_local,
      top.wi_reader.word_count,top.wi_reader.beat_index,top.wi_reader.beat_valid,
      top.wi_reader.physical_pending,wi_cfg_valid,wi_cfg_ready,wi_arvalid,
      wi_arready,wi_rvalid,wi_rready,g_wi_valid,g_wi_ready,
      g_wi_row_done_valid,g_wi_row_done_ready,g_wi_read_debt_zero,
      wi_rows_retired,top.producer.vector_row.issued,top.producer.vector_row.returned,
      top.producer.vector_row.credits,g_w_count,g_b_count,
      top.producer.quant_task.phase,g_source_ar_count,g_source_r_count,
      g_quant_halves,fa_slot_state[0],fa_slot_epoch[0]);
  endtask
  always @(posedge clk) if(rst_n && stage==1)begin : wigqd1_observation
    if(g_cfg_valid && g_cfg_ready && g_cfg_owner_admitted)begin
      obs_g_cfg++;
      if(obs_g_cfg>1)$fatal(1,"WIGQD1 duplicate legal G cfg");
      obs_g_cfg_cycle=cycle;
      $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=g_cfg n=%0d",cycle,obs_g_cfg);
      obs_diag("g_cfg_edge");
    end
    if(wi_cfg_valid && wi_cfg_ready)begin
      obs_wi_cfg++;
      if(obs_wi_cfg>1)$fatal(1,"WIGQD1 duplicate Wi reader cfg");
      if(!wi_writer_bound || WI_BO_BASE!==wi_writer_bo_base ||
         WI_BO_SPAN!==wi_writer_bo_span ||
         WI_REGION_BASE!==wi_writer_region_base ||
         WI_REGION_SPAN!==wi_writer_region_span ||
         WI_ROW_STRIDE!==wi_writer_row_stride ||
         WI_BATCH_STRIDE!==wi_writer_batch_stride ||
         cfg_bo_base[0]!==STATE1_BASE || cfg_region_base[0]!==TMP_BASE ||
         g_cfg_numeric_identity!==cfg_numeric_identity ||
         g_cfg_wi_ref!==64'h0000000600000001 ||
         g_cfg_producer_context[39:32]!==8'h60 ||
         g_cfg_producer_context[47:40]!==8'd2 ||
         g_cfg_producer_context[95:88]!==8'd4)
        $fatal(1,"FFN4 Wi reader bound descriptor or identity changed");
      $display("FFN4_WI_READER_BIND cycle=%0d bo=%h/%h region=%h/%h row=%0d batch=%0d down_bo=%h",
        cycle,WI_BO_BASE,WI_BO_SPAN,WI_REGION_BASE,WI_REGION_SPAN,
        WI_ROW_STRIDE,WI_BATCH_STRIDE,cfg_bo_base[0]);
      $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=wi_cfg n=%0d",cycle,obs_wi_cfg);
      obs_diag("wi_cfg_edge");
    end
    if(wi_arvalid && wi_arready)begin
      obs_wi_ar++;
      if(obs_wi_ar>1312)$fatal(1,"WIGQD1 excess Wi AR");
      if(obs_wi_ar==1 || obs_wi_ar%4==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=wi_ar n=%0d",cycle,obs_wi_ar);
    end
    if(wi_rvalid && wi_rready)begin
      obs_wi_r++;
      if(obs_wi_r>1312)$fatal(1,"WIGQD1 excess Wi R");
      if(obs_wi_r==1 || obs_wi_r%64==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=wi_r n=%0d",cycle,obs_wi_r);
    end
    if(g_wi_valid && g_wi_ready)begin
      obs_wi_scalar++;
      if(obs_wi_scalar>20992)$fatal(1,"WIGQD1 excess Wi scalar");
      if(obs_wi_scalar==1 || obs_wi_scalar%512==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=wi_scalar n=%0d",cycle,obs_wi_scalar);
    end
    if(g_wi_row_done_valid && g_wi_row_done_ready)begin
      obs_wi_row++;
      if(obs_wi_row>4)$fatal(1,"WIGQD1 excess Wi row");
      $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=wi_row n=%0d",cycle,obs_wi_row);
      obs_diag("wi_row_edge");
    end
    if(top.producer.vector_row.arithmetic_accept)begin
      obs_g_issue++;
      if(obs_g_issue>10496)$fatal(1,"WIGQD1 excess G issue");
      if(obs_g_issue==1 || obs_g_issue%256==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=g_issue n=%0d",cycle,obs_g_issue);
    end
    if(top.producer.vector_row.core_commit && top.producer.vector_row.core_return_legal)begin
      obs_g_return++;
      if(obs_g_return>10496)$fatal(1,"WIGQD1 excess G return");
      if(obs_g_return==1 || obs_g_return%256==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=g_return n=%0d",cycle,obs_g_return);
    end
    if(top.producer.v_valid && top.producer.v_ready)begin
      obs_g_emit++;
      if(obs_g_emit>10496)$fatal(1,"WIGQD1 excess G emit");
      if(obs_g_emit==1 || obs_g_emit%512==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=g_emit n=%0d",cycle,obs_g_emit);
    end
    if(g_m_axi_awvalid && g_m_axi_awready)begin
      obs_gate_aw++;
      if(obs_gate_aw>656)$fatal(1,"WIGQD1 excess GATE AW");
      if(obs_gate_aw==1 || obs_gate_aw%32==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=gate_aw n=%0d",cycle,obs_gate_aw);
    end
    if(g_m_axi_wvalid && g_m_axi_wready)begin
      obs_gate_w++;
      if(obs_gate_w>656)$fatal(1,"WIGQD1 excess GATE W");
      if(obs_gate_w==1 || obs_gate_w%32==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=gate_w n=%0d",cycle,obs_gate_w);
    end
    if(g_m_axi_bvalid && g_m_axi_bready)begin
      obs_gate_b++;
      if(obs_gate_b>656)$fatal(1,"WIGQD1 excess GATE B");
      if(obs_gate_b==1 || obs_gate_b%32==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=gate_b n=%0d",cycle,obs_gate_b);
    end
    if(g_m_axi_arvalid && g_m_axi_arready)begin
      obs_q_ar++;
      if(obs_q_ar>656)$fatal(1,"WIGQD1 excess quant AR");
      if(obs_q_ar==1 || obs_q_ar%4==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=q_ar n=%0d",cycle,obs_q_ar);
    end
    if(g_m_axi_rvalid && g_m_axi_rready)begin
      obs_q_r++;
      if(obs_q_r>656)$fatal(1,"WIGQD1 excess quant R");
      if(obs_q_r==1 || obs_q_r%32==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=q_r n=%0d",cycle,obs_q_r);
    end
    if(top.producer.quant_task.q_out_valid && top.producer.quant_task.q_out_ready)begin
      obs_q_half++;
      if(obs_q_half>656)$fatal(1,"WIGQD1 excess quant half");
      if(obs_q_half==1 || obs_q_half%32==0)
        $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=q_half n=%0d",cycle,obs_q_half);
    end
    if(top.producer.quant_task.q_done_valid && top.producer.quant_task.q_done_ready)begin
      obs_q_row++;
      if(obs_q_row>4)$fatal(1,"WIGQD1 excess quant row");
      $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=q_row n=%0d",cycle,obs_q_row);
    end
    if(top.producer.quant_task.a_publish)begin
      obs_a_publish++;
      if(obs_a_publish>1)$fatal(1,"WIGQD1 duplicate A publish");
      $display("MATRIX_PROGRESS cycle=%0d stage=1 kind=a_publish n=%0d",cycle,obs_a_publish);
    end
    if(obs_g_cfg_cycle>=0 &&
       (cycle-obs_g_cfg_cycle==1 || cycle-obs_g_cfg_cycle==64 ||
        cycle-obs_g_cfg_cycle==4096 || cycle-obs_g_cfg_cycle==16384 ||
        cycle-obs_g_cfg_cycle==32768 || cycle-obs_g_cfg_cycle==65536))
      obs_diag("fixed_sample");
  end
  logic g_aw_seen=0,g_w_seen=0,g_stored=0,g_read_active=0,g_read_source=0;
  logic ln_candidate_done_ready=0;
  assign ln_shared_read_addr=LN_NORM_BASE+64'(g_rindex)*64;

  laya_ffn0_source_stage_host_v1 ln_source(
    .clk,.rst_n,.source_query_valid(ln_query_valid),
    .source_query_ready(ln_query_ready),.source_query_granted(ln_query_granted),
    .source_query_command(ln_source_query_command),
    .source_release_valid(ln_source_release_valid),
    .source_release_ready(ln_source_release_ready),
    .source_release_command(ln_source_release_command),
    .source_release_drained(ln_source_release_drained),
    .source_lease_active(ln_source_lease_active),
    .ln_published,.ln_owner_released,
    .shared_read_addr(ln_shared_read_addr),.shared_read_data(ln_shared_read_data),
    .shared_read_written(ln_shared_read_written),
    .skip_arvalid(ffn_skip_arvalid),.skip_arready(ffn_skip_arready),
    .skip_araddr(ffn_skip_araddr),.skip_arlen(ffn_skip_arlen),
    .skip_arsize(ffn_skip_arsize),.skip_rvalid(ffn_skip_rvalid),
    .skip_rready(ffn_skip_rready),.skip_rdata(ffn_skip_rdata),
    .skip_rresp(ffn_skip_rresp),.skip_rlast(ffn_skip_rlast),
    .accepted_events(accepted_events),
    .accepted_requests(accepted_requests),
    .active_owners(active_owners),
    .adapter_pending_zero(adapter_pending_zero),
    .base_configured(base_configured),
    .destination_axi_awaddr(destination_axi_awaddr),
    .destination_axi_awburst(destination_axi_awburst),
    .destination_axi_awlen(destination_axi_awlen),
    .destination_axi_awready(destination_axi_awready),
    .destination_axi_awsize(destination_axi_awsize),
    .destination_axi_awvalid(destination_axi_awvalid),
    .destination_axi_bready(destination_axi_bready),
    .destination_axi_bresp(destination_axi_bresp),
    .destination_axi_bvalid(destination_axi_bvalid),
    .destination_axi_wdata(destination_axi_wdata),
    .destination_axi_wlast(destination_axi_wlast),
    .destination_axi_wready(destination_axi_wready),
    .destination_axi_wstrb(destination_axi_wstrb),
    .destination_axi_wvalid(destination_axi_wvalid),
    .forwarded_aw(forwarded_aw),
    .forwarded_w(forwarded_w),
    .job_active(job_active),
    .last_event_seq(last_event_seq),
    .ledger_domain_drained(ledger_domain_drained),
    .ledger_protocol_error(ledger_protocol_error),
    .ledger_scope_active(ledger_scope_active),
    .monitor_coverage_complete(monitor_coverage_complete),
    .monitor_drained(monitor_drained),
    .monitor_observed0(monitor_observed0),
    .monitor_scope_active(monitor_scope_active),
    .monitor_status(monitor_status),
    .producer_completion_din(producer_completion_din),
    .producer_completion_full_n(producer_completion_full_n),
    .producer_completion_write(producer_completion_write),
    .producer_request_dout(producer_request_dout),
    .producer_request_empty_n(producer_request_empty_n),
    .producer_request_read(producer_request_read),
    .provenance_cmd_din(provenance_cmd_din),
    .provenance_cmd_full_n(provenance_cmd_full_n),
    .provenance_cmd_write(provenance_cmd_write),
    .provenance_rsp_dout(provenance_rsp_dout),
    .provenance_rsp_empty_n(provenance_rsp_empty_n),
    .provenance_rsp_read(provenance_rsp_read),
    .published_owners(published_owners),
    .retired_b(retired_b),
    .retired_responses(retired_responses),
    .semantic_rejections(semantic_rejections),
    .shell_protocol_error(shell_protocol_error),
    .source_axi_araddr(source_axi_araddr),
    .source_axi_arburst(source_axi_arburst),
    .source_axi_arlen(source_axi_arlen),
    .source_axi_arready(source_axi_arready),
    .source_axi_arsize(source_axi_arsize),
    .source_axi_arvalid(source_axi_arvalid),
    .source_axi_rdata(source_axi_rdata),
    .source_axi_rlast(source_axi_rlast),
    .source_axi_rready(source_axi_rready),
    .source_axi_rresp(source_axi_rresp),
    .source_axi_rvalid(source_axi_rvalid),
    .source_outstanding_beats(source_outstanding_beats),
    .terminal_tasks(terminal_tasks));
  // ln_q_admit lives in top.
  // ffn_handoff lives in top.
  // ffn_residual lives in top.
  integer ffn_down_read_index=0,ffn_down_read_count=0;
  logic ffn_down_read_pending=0;
  integer ffn_res_write_beats=0,ffn_res_bdelay=0;
  logic ffn_res_aw_seen=0,ffn_res_w_seen=0,ffn_res_stored=0;
  logic [63:0] ffn_res_awaddr_hold;
  logic [511:0] ffn_res_wdata_hold;
  logic [63:0] ffn_res_wstrb_hold;
  always @(negedge clk)begin
    ffn_down_arready=rst_n && !ffn_down_read_pending && !ffn_down_rvalid &&
                     cycle%5!=0;
    if(ffn_down_read_pending && !ffn_down_rvalid)begin
      for(int lane=0;lane<64;lane++)begin
        if(!state1_tmp_written[ffn_down_read_index*64+lane])
          $fatal(1,"FFN0 residual read unwritten TMP byte=%0d",
                 ffn_down_read_index*64+lane);
        ffn_down_rdata[lane*8+:8]=state1_tmp[ffn_down_read_index*64+lane];
      end
      ffn_down_rvalid=1;ffn_down_rresp=0;ffn_down_rlast=1;
    end
    ffn_res_awready=rst_n && !ffn_res_aw_seen && !ffn_res_bvalid &&
                    cycle%7!=0;
    ffn_res_wready=rst_n && !ffn_res_w_seen && !ffn_res_bvalid &&
                   cycle%11!=0;
    if(ffn_res_bdelay>0)begin
      ffn_res_bdelay--;
      if(ffn_res_bdelay==0)begin ffn_res_bvalid=1;ffn_res_bresp=0;end
    end
  end
  always @(posedge clk)begin
    if(!rst_n)begin
      ffn_down_read_pending=0;ffn_down_rvalid<=0;
      ffn_down_read_index=0;ffn_down_read_count=0;
      ffn_res_aw_seen=0;ffn_res_w_seen=0;ffn_res_stored=0;
      ffn_res_bvalid<=0;ffn_res_bdelay=0;ffn_res_write_beats=0;
    end else begin
      if(!ffn_done_consumed &&
         (ffn_skip_arvalid || ffn_down_arvalid || ffn_res_awvalid ||
          ffn_res_wvalid))
        $fatal(1,"FFN0 residual AXI before Down actual done consumption");
      if(ffn_down_arvalid && ffn_down_arready)begin
        if(!ffn_tmp_reserved || ffn_down_read_pending ||
           ffn_down_arlen!=0 || ffn_down_arsize!=6 ||
           ffn_down_araddr!=TMP_BASE+64'(ffn_down_read_count)*64 ||
           ffn_down_read_count>=256)
          $fatal(1,"FFN0 Down read AR identity addr=%h",ffn_down_araddr);
        ffn_down_read_pending=1;
        ffn_down_read_index=int'((ffn_down_araddr-TMP_BASE)>>6);
      end
      if(ffn_down_rvalid && ffn_down_rready)begin
        if(!ffn_down_read_pending || ffn_down_rresp!=0 || !ffn_down_rlast)
          $fatal(1,"FFN0 Down read R identity");
        ffn_down_rvalid<=0;ffn_down_read_pending=0;
        ffn_down_read_count++;
      end
      if(ffn_res_awvalid && ffn_res_awready)begin
        if(ffn_res_aw_seen || ffn_res_awlen!=0 || ffn_res_awsize!=6 ||
           ffn_res_awaddr!=STATE1_BASE+64'(ffn_res_write_beats)*64 ||
           ffn_res_write_beats>=256)
          $fatal(1,"FFN0 residual AW identity addr=%h",ffn_res_awaddr);
        ffn_res_aw_seen=1;ffn_res_awaddr_hold=ffn_res_awaddr;
      end
      if(ffn_res_wvalid && ffn_res_wready)begin
        if(ffn_res_w_seen || !ffn_res_wlast || ffn_res_wstrb!=='1)
          $fatal(1,"FFN0 residual W identity");
        ffn_res_w_seen=1;ffn_res_wdata_hold=ffn_res_wdata;
        ffn_res_wstrb_hold=ffn_res_wstrb;
      end
      if(ffn_res_aw_seen && ffn_res_w_seen && !ffn_res_stored)begin
        for(int lane=0;lane<64;lane++)begin
          if(!ffn_res_wstrb_hold[lane] ||
             state1_hidden_written[int'(ffn_res_awaddr_hold-STATE1_BASE)+lane])
            $fatal(1,"FFN0 residual duplicate/partial HIDDEN byte=%0d",
                   int'(ffn_res_awaddr_hold-STATE1_BASE)+lane);
          state1_hidden[int'(ffn_res_awaddr_hold-STATE1_BASE)+lane]=
            ffn_res_wdata_hold[lane*8+:8];
          state1_hidden_written[int'(ffn_res_awaddr_hold-STATE1_BASE)+lane]=1;
        end
        ffn_res_stored=1;ffn_res_bdelay=12+(ffn_res_write_beats%3);
      end
      if(ffn_res_bvalid && ffn_res_bready)begin
        if(!ffn_res_stored)$fatal(1,"FFN0 residual B without real write");
        ffn_res_bvalid<=0;ffn_res_aw_seen=0;ffn_res_w_seen=0;
        ffn_res_stored=0;ffn_res_write_beats++;
      end
    end
  end
  logic [63:0] g_aw_addr,g_first_addr;
  logic [511:0] g_w_data;
  integer wi_rleft=0,wi_rindex=0,wi_rdelay=0,wi_read_beats=0;
  logic wi_read_active=0;
  always @(negedge clk)begin
    wi_arready=rst_n && !wi_read_active && !wi_rvalid && cycle%5!=0;
    if(wi_read_active && !wi_rvalid)begin
      if(wi_rdelay>0)wi_rdelay--;
      else begin
        for(int lane=0;lane<64;lane++)begin
          if(wi_rindex*64+lane>=DDR_BYTES || !ddr_written[wi_rindex*64+lane])
            $fatal(1,"WIGQD Wi reader accessed unwritten byte addr=%h",DDR_BASE+wi_rindex*64+lane);
          wi_rdata[lane*8+:8]=ddr[wi_rindex*64+lane];
        end
        wi_rvalid=1;wi_rresp=0;wi_rlast=wi_rleft==1;
      end
    end
  end
  always @(posedge clk)begin
    if(!rst_n)begin wi_read_active=0;wi_rvalid<=0;wi_rleft=0;wi_rindex=0;wi_rdelay=0;end
    else begin
      if(wi_arvalid && wi_arready)begin
        if(wi_read_active || wi_arsize!=6 || wi_arburst!=1 ||
           wi_araddr<wi_region_base || wi_araddr+64'(wi_arlen+1)*64>wi_region_base+83968 ||
           wi_araddr[11:0]+(int'(wi_arlen)+1)*64>4096)
          $fatal(1,"WIGQD Wi reader AR bounds");
        wi_read_active=1;wi_rindex=int'((wi_araddr-DDR_BASE)>>6);
        wi_rleft=int'(wi_arlen)+1;wi_rdelay=3;
        if(wi_reader_first_ar<0)wi_reader_first_ar=cycle;
        wi_reader_last_ar=cycle;
      end
      if(wi_rvalid && wi_rready)begin
        wi_rvalid<=0;wi_rindex++;wi_rleft--;wi_read_beats++;
        wi_rdelay=1+(wi_read_beats%4);
        if(wi_rleft==0)wi_read_active=0;
        if(wi_reader_first_r<0)wi_reader_first_r=cycle;
        wi_reader_last_r=cycle;
      end
    end
  end
  always @(negedge clk)begin
    g_m_axi_awready=rst_n && !g_aw_seen && cycle%7!=0;
    g_m_axi_wready=rst_n && !g_w_seen && cycle%11!=0;
    g_m_axi_arready=rst_n && !g_read_active && !g_m_axi_rvalid && cycle%5!=0;
    if(g_bdelay>0)begin
      g_bdelay--;g_held_b++;
      if(g_bdelay==0)begin g_m_axi_bvalid=1;g_m_axi_bresp=0;end
    end
    if(g_read_active && !g_m_axi_rvalid)begin
      if(g_rdelay>0)g_rdelay--;
      else begin
        if(!g_read_source && !gate_written[g_rindex])
          $fatal(1,"GQD0 quant read unwritten GATE beat=%0d",g_rindex);
        g_m_axi_rvalid=1;
        if(g_read_source)begin
          if(ln_shared_read_written!==64'hffffffffffffffff)
            $fatal(1,"Q read before actual LN store addr=%h",ln_shared_read_addr);
          g_m_axi_rdata=ln_shared_read_data;
        end else for(int lane=0;lane<64;lane++)begin
          if(!ddr_written[int'(g_first_addr-DDR_BASE)+g_rindex*64+lane])
            $fatal(1,"GQD0 quant read unwritten GATE byte");
          g_m_axi_rdata[lane*8+:8]=ddr[int'(g_first_addr-DDR_BASE)+g_rindex*64+lane];
        end
        g_m_axi_rresp=0;g_m_axi_rlast=g_rleft==1;
      end
    end
  end
  always @(posedge clk)begin
    if(!rst_n)begin
      g_aw_seen=0;g_w_seen=0;g_stored=0;g_read_active=0;
      g_bdelay=0;g_rdelay=0;g_rleft=0;g_read_source=0;
      g_m_axi_bvalid<=0;g_m_axi_rvalid<=0;
      for(int i=0;i<2624;i++)gate_written[i]=0;
    end else begin
      if(g_cfg_valid && g_cfg_ready && g_cfg_owner_admitted && g_cfg_edge<0)g_cfg_edge=cycle;
      if(top.producer.quant_task.a_publish)begin
        if(stage==0 && source_a_publish_edge<0)source_a_publish_edge=cycle;
        if(stage==1 && quant_a_publish_edge<0)quant_a_publish_edge=cycle;
      end
      if(g_wi_valid && g_wi_ready)begin
        if(stage!=1 || wi_accepted>=20992 || g_wi_numeric_identity!==g_cfg_numeric_identity ||
           g_wi_source_ref!==g_cfg_wi_ref || g_wi_status!=0 ||
           g_wi_row!=16'(wi_accepted/5248) || g_wi_index!=13'(wi_accepted%5248) ||
           g_wi_data!==wi_fixture[wi_accepted])
          $fatal(1,"WIGQD real Wi reader scalar mismatch index=%0d",wi_accepted);
        wi_accepted++;
      end
      if(g_wi_row_done_valid && g_wi_row_done_ready)begin
        if(wi_rows_retired>=4 || wi_accepted!=(wi_rows_retired+1)*5248 ||
           !g_wi_read_debt_zero || g_wi_row_done_status!=0)
          $fatal(1,"WIGQD Wi reader row barrier row=%0d",wi_rows_retired);
        wi_reader_row_edge[wi_rows_retired]=cycle;
        wi_rows_retired++;
      end
      if(g_m_axi_awvalid && g_m_axi_awready)begin
        if(g_aw_seen || g_m_axi_awsize!=6 || g_m_axi_awlen!=0 || g_m_axi_awburst!=1)
          $fatal(1,"GQD0 GATE AW");
        g_aw_seen=1;g_aw_addr=g_m_axi_awaddr;
        if(gate_first_aw<0)gate_first_aw=cycle;gate_last_aw=cycle;
      end
      if(g_m_axi_wvalid && g_m_axi_wready)begin
        if(g_w_seen || g_m_axi_wstrb!==64'hffffffffffffffff || !g_m_axi_wlast)
          $fatal(1,"GQD0 GATE W");
        g_w_seen=1;g_w_data=g_m_axi_wdata;
        if(gate_first_w<0)gate_first_w=cycle;gate_last_w=cycle;
      end
      if(g_aw_seen && g_w_seen && !g_stored)begin
        int index;
        if(g_aw_addr!==g_first_addr+64'(g_write_beats)*64)
          $fatal(1,"GQD0 GATE physical address");
        index=int'((g_aw_addr-g_first_addr)>>6);
        for(int lane=0;lane<16;lane++)
          if(g_w_data[lane*32+:32]!==gate_gold[index*16+lane])
            $fatal(1,"GQD0 GATE gold row=%0d col=%0d",index/164,(index%164)*16+lane);
        for(int lane=0;lane<64;lane++)begin
          ddr[int'(g_aw_addr-DDR_BASE)+lane]=g_w_data[lane*8+:8];
          ddr_written[int'(g_aw_addr-DDR_BASE)+lane]=1;
        end
        gate_written[index]=1;
        g_stored=1;g_write_beats++;g_bdelay=17+(index%3);
      end
      if(g_m_axi_bvalid && g_m_axi_bready)begin
        g_m_axi_bvalid<=0;g_aw_seen=0;g_w_seen=0;g_stored=0;
        if(gate_first_b<0)gate_first_b=cycle;gate_last_b=cycle;
      end
      if(g_m_axi_arvalid && g_m_axi_arready)begin
        if(g_m_axi_arsize!=6 || g_m_axi_arburst!=1 ||
           g_m_axi_araddr[11:0]+(int'(g_m_axi_arlen)+1)*64>4096)
          $fatal(1,"quant AR format/4KiB boundary");
        if(top.producer.ext_quant_active)begin
          if(stage!=0 || !ln_source_lease_active ||
             g_m_axi_araddr<LN_NORM_BASE ||
             g_m_axi_araddr+64'(g_m_axi_arlen+1)*64>LN_NORM_BASE+SOURCE_BYTES)
            $fatal(1,"source quant AR readonly bounds");
          g_read_source=1;
          g_rindex=int'((g_m_axi_araddr-LN_NORM_BASE)>>6);
          source_ar_count++;
          source_ar_beats+=int'(g_m_axi_arlen)+1;
          if(source_first_ar<0)source_first_ar=cycle;
          source_last_ar=cycle;
        end else begin
          if(g_gate_owner_state!=3 || g_aw_count!=656 || g_b_count!=656 ||
             g_m_axi_araddr<g_first_addr ||
             g_m_axi_araddr+64'(g_m_axi_arlen+1)*64>g_first_addr+4*10496)
            $fatal(1,"GQD0 quant AR publication/bounds");
          g_read_source=0;
          g_rindex=int'((g_m_axi_araddr-g_first_addr)>>6);
        end
        g_read_active=1;
        g_rleft=int'(g_m_axi_arlen)+1;g_rdelay=3;
      end
      if(g_m_axi_rvalid && g_m_axi_rready)begin
        g_m_axi_rvalid<=0;g_rindex++;g_rleft--;g_read_beats++;
        g_rdelay=1+(g_read_beats%4);
        if(g_rleft==0)g_read_active=0;
        if(g_read_source)begin
          source_r_beats++;
          if(source_first_r<0)source_first_r=cycle;
          source_last_r=cycle;
        end else begin
          if(quant_first_r<0)quant_first_r=cycle;quant_last_r=cycle;
        end
      end
      if(top.producer.quant_task.q_out_valid && top.producer.quant_task.q_out_ready)begin
        int g,h;
        g=int'(top.producer.quant_task.active_row)*(stage==0 ? 32 : 82)+int'(top.producer.quant_task.q_out_group);
        h=top.producer.quant_task.q_out_half;
        if(stage==0)begin
          if(top.producer.quant_task.q_out!==aq[g][h*128+:128] ||
             (h && top.producer.quant_task.q_scale!==asc[g]))
            $fatal(1,"source quant gold group=%0d half=%0d",g,h);
          source_quant_halves++;
        end else if(top.producer.quant_task.q_out!==aq[g][h*128+:128] ||
           top.producer.quant_task.q_d!==d_gold[g] ||
           top.producer.quant_task.q_recip!==recip_gold[g] ||
           (h && top.producer.quant_task.q_scale!==asc[g]))
          $fatal(1,"GQD0 quant gold group=%0d half=%0d",g,h);
        if(stage==1)g_quant_halves++;
      end
    end
  end

  initial begin : run
    cfg_K=0;
    cfg_N=0;
    cfg_a_epoch=0;
    cfg_a_ref=0;
    cfg_a_slot=0;
    cfg_batch_stride_bytes=0;
    cfg_bias_kind=0;
    cfg_bo_base=0;
    cfg_bo_span=0;
    cfg_dst_ref=0;
    cfg_linear_context=0;
    cfg_numeric_identity=0;
    cfg_ps_ref=0;
    cfg_region_base=0;
    cfg_region_span=0;
    cfg_row_block_base=0;
    cfg_row_stride_bytes=0;
    cfg_rows=0;
    cfg_source_ref=0;
    cfg_valid=0;
    cfg_w_epoch=0;
    cfg_w_model_identity=0;
    cfg_w_ref=0;
    cfg_w_slot=0;
    cfg_weight_key=0;
    done_ready=0;
    fa_commit_a_ref=0;
    fa_commit_group=0;
    fa_commit_half=0;
    fa_commit_numeric_identity=0;
    fa_commit_q=0;
    fa_commit_quant_context=0;
    fa_commit_row=0;
    fa_commit_scale=0;
    fa_commit_valid=0;
    fa_fill_K=0;
    fa_fill_a_ref=0;
    fa_fill_dst_ref=0;
    fa_fill_linear_context=0;
    fa_fill_numeric_identity=0;
    fa_fill_owner_admitted=0;
    fa_fill_producer_context=0;
    fa_fill_quant_context=0;
    fa_fill_rows=0;
    fa_fill_slot=0;
    fa_fill_slot_epoch=0;
    fa_fill_source_published=0;
    fa_fill_source_ref=0;
    fa_fill_valid=0;
    fa_fill_w_ref=0;
    fa_finish_debt_zero=0;
    fa_finish_valid=0;
    fa_row_done_bad_col=0;
    fa_row_done_debt_zero=0;
    fa_row_done_row=0;
    fa_row_done_status=0;
    fa_row_done_valid=0;
    m_axi_awready=0;
    m_axi_bresp=0;
    m_axi_bvalid=0;
    m_axi_wready=0;

    g_cfg_valid=0;g_cfg_owner_admitted=0;g_cfg_numeric_identity=0;
    g_cfg_producer_context=0;g_cfg_quant_context=0;g_cfg_linear_context=0;
    g_cfg_wi_ref=0;g_cfg_gate_ref=0;g_cfg_a_ref=0;g_cfg_w_ref=0;
    g_cfg_down_dst_ref=0;g_cfg_rows=0;g_cfg_a_slot=0;g_cfg_a_slot_epoch=0;
    g_cfg_bo_base=0;g_cfg_bo_span=0;g_cfg_region_base=0;g_cfg_region_span=0;
    wi_cfg_valid=0;wi_rdata=0;wi_rresp=0;wi_rlast=0;wi_rvalid=0;
    g_done_ready=0;g_m_axi_awready=0;g_m_axi_wready=0;
    g_m_axi_bresp=0;g_m_axi_bvalid=0;g_m_axi_arready=0;
    g_m_axi_rdata=0;g_m_axi_rresp=0;g_m_axi_rlast=0;g_m_axi_rvalid=0;
    ln_candidate_valid=0;ln_candidate_done_ready=0;

    rst_n=0;
    wc_load_aux_base=0;
    wc_load_base=0;
    wc_load_bias_base=0;
    wc_load_bias_bytes=0;
    wc_load_bytes=0;
    wc_load_epoch=0;
    wc_load_expected_aux_header=0;
    wc_load_k=0;
    wc_load_model_identity=0;
    wc_load_n=0;
    wc_load_slot=0;
    wc_request_valid=0;
    wc_load_weight_key=0;

    for(int r=0;r<4;r++)ps_checks[r]=0;
    for(int i=0;i<20992;i++)output_seen[i]=0;
    for(int i=0;i<DDR_BYTES;i++)begin ddr[i]=8'ha5;ddr_written[i]=0;end
    for(int i=0;i<65536;i++)begin
      state1_tmp[i]=8'ha5;state1_hidden[i]=8'ha5;
      state1_tmp_written[i]=0;state1_hidden_written[i]=0;
    end
    for(int st=0;st<13;st++)measure_state[st]=0;
    for(int pp=0;pp<3;pp++)begin measure_w_ar_wait[pp]=0;measure_w_r_gap[pp]=0;measure_w_r_blocked[pp]=0;end
    if(!$value$plusargs("AFIXTURE=%s",afixture) || !$value$plusargs("WFIXTURE=%s",wfixture) ||
       !$value$plusargs("STREAMS=%s",streams) || !$value$plusargs("GFIXTURE=%s",gfixture) ||
       !$value$plusargs("WI_AFIXTURE=%s",wi_afixture) ||
       !$value$plusargs("WI_WFIXTURE=%s",wi_wfixture) ||
       !$value$plusargs("WI_STREAMS=%s",wi_streams) ||
       !$value$plusargs("LN_FIXTURE=%s",ln_fixture) ||
       !$value$plusargs("BOUND_FIXTURE=%s",bound_fixture) ||
       !$value$plusargs("FFN_FIXTURE=%s",ffn_fixture))
      $fatal(1,"WIGQD fixture arguments");
    pilot=$test$plusargs("PILOT");
    prefix=$test$plusargs("PREFIX");
    $readmemh({ln_fixture,"/source_query.hex"},ln_query_beats);
    for(int beat=0;beat<16;beat++)
      ln_query_command[beat*512+:512]=ln_query_beats[beat];
    ln_query_command[laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+32+:8]=8'h32;
    ln_query_command[laya_compute_portal_layout_v1::FUTURE_DST_REF*8+:64]=64'h0000000600000001;
    if(!laya_compute_portal_layout_v1::command_frame_ok(ln_query_command))
      $fatal(1,"LNQ0 same-source Wi Q command malformed");
    $readmemh({gfixture,"/wi.mem"},wi_fixture);
    $readmemh({gfixture,"/gate.mem"},gate_gold);
    $readmemh({gfixture,"/d.mem"},d_gold);
    $readmemh({gfixture,"/recip.mem"},recip_gold);
    $readmemh({wi_afixture,"/q.mem"},aq);
    $readmemh({wi_afixture,"/scale.mem"},asc);
    $readmemh({gfixture,"/wi.mem"},outgold);
    $readmemh({bound_fixture,"/model_identity.hex"},model);
    $readmemh({bound_fixture,"/expected_aux_header.hex"},header);
    $readmemh({bound_fixture,"/aux_header.hex"},auxwords);
    $readmemh({ffn_fixture,"/final.mem"},ffn_gold);
    $readmemh({ffn_fixture,"/skip.mem"},ffn_skip_gold);
    $readmemh({wi_wfixture,"/wi_config.hex"},config_words);
    $readmemh({wi_wfixture,"/wi_q0.hex"},wq0);
    $readmemh({wi_wfixture,"/wi_q1.hex"},wq1);
    $readmemh({wi_wfixture,"/wi_scale.hex"},wsc);
    $readmemh({wi_streams,"/w8.mem"},vw);
    $readmemh({wi_streams,"/ps.mem"},vps);
    cfg_K=1024;cfg_N=5248;cfg_rows=4;cfg_row_block_base=0;
    cfg_numeric_identity=ln_query_command[laya_compute_portal_layout_v1::IDENTITY*8+:672];
    cfg_linear_context=ln_query_command[laya_compute_portal_layout_v1::LINEAR_CONTEXT*8+:96];
    cfg_source_ref=ln_query_command[laya_compute_portal_layout_v1::SOURCE_REF*8+:64];
    cfg_a_ref=ln_query_command[laya_compute_portal_layout_v1::A_REF*8+:64];
    cfg_w_ref=ln_query_command[laya_compute_portal_layout_v1::W_REF*8+:64];
    cfg_ps_ref=ln_query_command[laya_compute_portal_layout_v1::PS_REF*8+:64];
    cfg_dst_ref=ln_query_command[laya_compute_portal_layout_v1::FUTURE_DST_REF*8+:64];
    cfg_w_model_identity=model[0];cfg_a_slot=0;cfg_w_slot=0;cfg_a_epoch=1;cfg_w_epoch=1;
    cfg_weight_key=3;cfg_bias_kind=0;
    cfg_bo_base[0]=WI_BO_BASE;cfg_bo_span[0]=WI_BO_SPAN;
    cfg_region_base[0]=WI_REGION_BASE;cfg_region_span[0]=WI_REGION_SPAN;
    cfg_row_stride_bytes=WI_ROW_STRIDE;cfg_batch_stride_bytes=WI_BATCH_STRIDE;
    repeat(6)tick();@(negedge clk);rst_n=1;
    $display("FFN0_SIM_START");
    repeat(16)tick();
    if($test$plusargs("W_PROBE"))begin
      wc_load_slot=0;wc_load_epoch=1;wc_load_k=1024;wc_load_n=5248;
      wc_load_weight_key=3;wc_load_model_identity=model[0];
      wc_load_expected_aux_header=header[0];
      wc_load_aux_base=64'h400000000;wc_load_bias_base=0;wc_load_bias_bytes=0;
      for(int pp=0;pp<3;pp++)begin
        wc_load_base[pp]=64'h500000000+64'(pp)*64'h10000000+config_words[3+pp];
        wc_load_bytes[pp]=32'(config_words[6+pp]);
      end
      @(negedge clk);wc_request_valid=1;
      @(posedge clk);while(!wc_request_ready)@(posedge clk);#1;
      if(wc_request_reject || wc_load_reject)
        $fatal(1,"M005 W probe binding rejected");
      @(negedge clk);wc_request_valid=0;
      while(q_beats[0]<128 || q_beats[1]<128 || q_beats[2]<32)begin
        tick();
        if(cycle%16==0)
          $display("M005_W_PROBE_STATE cycle=%0d ar=%b ready=%b rvalid=%b rready=%b active=%b%b%b left=%0d,%0d,%0d q=%0d,%0d,%0d aux=%0d/%0d wstate=%0d error=%b reject=%b",
            cycle,wc_arvalid,wc_arready,wc_rvalid,wc_rready,
            q_active[0],q_active[1],q_active[2],
            q_left[0],q_left[1],q_left[2],
            q_beats[0],q_beats[1],q_beats[2],
            aux_active,aux_left,wc_slot_state[0],wc_load_error,wc_load_reject);
        if(cycle>3000)$fatal(1,"M005 W probe bounded stop");
      end
      $display("M005_W_PROBE_PASS cycle=%0d W_R=%0d,%0d,%0d",cycle,
        q_beats[0],q_beats[1],q_beats[2]);
      $finish;
    end
    // The first request is deliberately early. A real hub without a
    // published LN window must grant neither lease nor external Q AXI.
    @(negedge clk);ln_candidate_valid=1;
    repeat(3)begin
      tick();if(ln_lease_pending || source_ar_count!=0 || g_quant_starts!=0)
        $fatal(1,"LN Q escaped before publication");
    end
    @(negedge clk);ln_candidate_valid=0;
    while(!ln_published)tick();
    // The monitor's live coverage signal is scoped to the active write.
    // The END-time witness below was sampled while that scope was still
    // active; PUBLISH must instead leave the scope closed and owner visible.
    $display("LNQ1_WITNESS_PUBLISH_SAMPLE tb_cycle=%0d source_cycle=%0d end_sample=%0d end_ack=%0d publish_ack=%0d live_scope=%0d live_coverage=%0d live_drained=%0d destination_B=%0d owner=%0d/%0d end_status=%0d publish_status=%0d",
      cycle,ln_source.cycles,ln_source.coverage_witness_cycle,
      ln_source.end_response_witness_cycle,
      ln_source.publish_response_witness_cycle,
      ln_source.monitor_scope_active,ln_source.monitor_coverage_complete,
      ln_source.monitor_drained,ln_source.destination_b_count,
      ln_source.active_owners,ln_source.published_owners,
      ln_source.end_response_witness[
        laya_generated_provenance_layout_v1::RESPONSE_STATUS*8+:16],
      ln_source.publish_response_witness[
        laya_generated_provenance_layout_v1::RESPONSE_STATUS*8+:16]);
    if(!ln_source.coverage_witness_valid ||
       !ln_source.coverage_witness_complete ||
       !ln_source.coverage_witness_scope_active ||
       ln_source.coverage_witness_status!==0 ||
       ln_source.coverage_witness_bytes!=16384 ||
       ln_source.coverage_witness_cycle<0)
      $fatal(1,"LN END-time coverage witness missing or invalid");
    if(ln_source.coverage_witness_source_ar!=4 ||
       ln_source.coverage_witness_source_r!=256 ||
       ln_source.coverage_witness_destination_aw!=4 ||
       ln_source.coverage_witness_destination_w!=256 ||
       ln_source.coverage_witness_destination_b!=4 ||
       ln_source.coverage_witness_store_bytes!=16384 ||
       ln_source.destination_b_count!=4)
      $fatal(1,"LN physical store/read counters at coverage or publication");
    if(!ln_source.end_response_witness_valid ||
       !ln_source.publish_response_witness_valid ||
       ln_source.end_response_witness_cycle<=ln_source.coverage_witness_cycle ||
       ln_source.publish_response_witness_cycle<=ln_source.end_response_witness_cycle ||
       ln_source.end_response_witness[
         laya_generated_provenance_layout_v1::ACTION*8+:16]!==
         laya_generated_provenance_layout_v1::END_EVENT ||
       ln_source.publish_response_witness[
         laya_generated_provenance_layout_v1::ACTION*8+:16]!==
         laya_generated_provenance_layout_v1::PUBLISH ||
       ln_source.end_response_witness[
         laya_generated_provenance_layout_v1::RESPONSE_STATUS*8+:16]!==0 ||
       ln_source.publish_response_witness[
         laya_generated_provenance_layout_v1::RESPONSE_STATUS*8+:16]!==0)
      $fatal(1,"LN END/PUBLISH response witness missing or invalid");
    if(ln_source.coverage_witness_packet[
         laya_generated_provenance_layout_v1::IDENTITY*8+:672] !==
       ln_source.provenance_packet[
         laya_generated_provenance_layout_v1::IDENTITY*8+:672] ||
       ln_source.coverage_witness_packet[
         laya_generated_provenance_layout_v1::MODEL_IDENTITY*8+:3328] !==
       ln_source.provenance_packet[
         laya_generated_provenance_layout_v1::MODEL_IDENTITY*8+:3328] ||
       ln_source.coverage_witness_packet[
         laya_generated_provenance_layout_v1::DESCRIPTOR0*8+:1024] !==
       ln_source.provenance_packet[
         laya_generated_provenance_layout_v1::DESCRIPTOR0*8+:1024] ||
       ln_source.end_response_witness[
         laya_generated_provenance_layout_v1::RESPONSE_IDENTITY*8+:672] !==
       ln_source.coverage_witness_packet[
         laya_generated_provenance_layout_v1::IDENTITY*8+:672] ||
       ln_source.publish_response_witness[
         laya_generated_provenance_layout_v1::RESPONSE_IDENTITY*8+:672] !==
       ln_source.coverage_witness_packet[
         laya_generated_provenance_layout_v1::IDENTITY*8+:672])
      $fatal(1,"LN END/PUBLISH complete owner identity changed");
    if(ln_source.monitor_scope_active ||
       !ln_source.monitor_drained ||
       ln_source.published_owners!=1 ||
       ln_source.active_owners!=1)
      $fatal(1,"LN owner not durably published after physical drain");
    // Both producers hold valid. G wins the first idle slot and is safely
    // rejected before any arithmetic, AXI, or A-cache work is admitted.
    ln_candidate_valid=1;g_cfg_valid=1;g_cfg_owner_admitted=0;
    #1;if(!g_cfg_ready || source_quant_ready || ln_query_valid ||
           top.producer.ext_quant_active)
      $fatal(1,"QAR0 dual-valid G priority");
    tick();
    if(!g_cfg_reject || top.producer.ext_quant_active || g_aw_count!=0 ||
       g_quant_starts!=0 || fa_physical_half_commits!=0)
      $fatal(1,"QAR0 first G rejection altered source Q");
    $display("MATRIX_PROGRESS cycle=%0d QAR0_dual_valid_G_reject=1 ext_held=1",cycle);
    @(negedge clk);g_cfg_valid=0;
    @(posedge clk);while(!ln_candidate_ready)@(posedge clk);
    if(!ln_query_granted || !source_quant_ready || !ln_query_valid)
      $fatal(1,"LN Q grant/bridge acceptance edge mismatch");
    source_quant_accept_edge=cycle;
    @(negedge clk);ln_candidate_valid=0;g_cfg_valid=1;
    #1;if(g_cfg_ready)$fatal(1,"QAR0 G preempted active external Q");
    $display("MATRIX_PROGRESS cycle=%0d source_quant_accepted=1",cycle);
    while(!source_quant_done_valid)tick();
    if(source_quant_reject || source_quant_done_status!=0 || fa_slot_state[0]!=2 ||
       fa_slot_epoch[0]!=1 || fa_slot_rows_done[0]!=16'hf ||
       fa_physical_half_commits!=256 || fa_physical_scale_commits!=128 ||
       source_quant_halves!=256 || source_r_beats!=256 || source_ar_beats!=256 ||
       g_source_complete_rows!=4 || g_quant_starts!=4 || g_quant_rows!=4 ||
       source_a_publish_edge<0 || source_first_ar<0 || source_first_r<0 ||
       !top.producer.quant_task_debt_zero)
      $fatal(1,"source quant physical publication/debt");
    repeat(7)begin tick();if(!source_quant_done_valid || fa_slot_state[0]!=2 || g_cfg_ready || g_cfg_reject)
      $fatal(1,"source quant held response");end
    @(negedge clk);ln_candidate_done_ready=1;tick();
    @(negedge clk);ln_candidate_done_ready=0;tick();
    if(!g_cfg_reject || source_quant_reject || source_quant_done_valid ||
       g_aw_count!=0 || g_quant_starts!=4)
      $fatal(1,"QAR0 waiting G rejection after external Q retirement");
    @(negedge clk);g_cfg_valid=0;tick();
    if(g_cfg_reject)$fatal(1,"QAR0 duplicate G rejection");
    while(ln_lease_pending)tick();
    while(!ln_owner_released)tick();
    if(source_quant_done_valid || top.producer.ext_quant_active || g_read_active ||
       g_m_axi_rvalid || !top.producer.quant_task_debt_zero ||
       ln_source_lease_active || ln_admission_error)
      $fatal(1,"source quant response/debt consume");
    measure_a_publish=source_a_publish_edge;
    $display("MATRIX_PROGRESS cycle=%0d source_A_published=%0d AR_beats=%0d R=%0d halves=%0d scales=%0d",cycle,source_a_publish_edge,source_ar_beats,source_r_beats,fa_physical_half_commits,fa_physical_scale_commits);
    wc_load_slot=0;wc_load_epoch=1;wc_load_k=1024;wc_load_n=5248;wc_load_weight_key=3;wc_load_model_identity=model[0];wc_load_expected_aux_header=header[0];wc_load_aux_base=64'h400000000;wc_load_bias_base=0;wc_load_bias_bytes=0;
    for(int pp=0;pp<3;pp++)begin wc_load_base[pp]=64'h500000000+64'(pp)*64'h10000000+config_words[3+pp];wc_load_bytes[pp]=32'(config_words[6+pp]);end
    // First show that the live adapter rejects a wrong physical q1 base
    // without presenting any load to the original strict W cache.
    @(negedge clk);wc_load_base[1]=wc_load_base[1]+64;
    wc_request_valid=1;#1;
    if(wc_load_valid)$fatal(1,"wrong W base reached cache");
    @(posedge clk);while(!wc_request_ready)@(posedge clk);#1;
    if(!wc_request_reject || wc_load_valid)$fatal(1,"wrong W binding not rejected");
    @(negedge clk);wc_request_valid=0;wc_load_base[1]=wc_load_base[1]-64;
    tick();
    @(negedge clk);wc_request_valid=1;
    @(posedge clk);while(!wc_request_ready)@(posedge clk);#1;
    @(negedge clk);wc_request_valid=0;
    while(!wc_load_done)tick();if(wc_load_error || wc_load_reject || wc_slot_state[0]!=2 || wc_load_scale_checks!=167936)$fatal(1,"resident physical W strict load checks=%0d error=%b reject=%b state=%0d",wc_load_scale_checks,wc_load_error,wc_load_reject,wc_slot_state[0]);
    for(int pp=0;pp<3;pp++)if(q_active[pp] || q_beats[pp]*64!=wc_load_bytes[pp])$fatal(1,"actual W final R coverage");
    measure_w_publish=cycle;
    $display("MATRIX_PROGRESS cycle=%0d physical_W_published=1 W_R=%0d,%0d,%0d scale_checks=%0d",cycle,q_beats[0],q_beats[1],q_beats[2],wc_load_scale_checks);
    @(negedge clk);cfg_valid=1;#1;if(!cfg_ready || !ledger_claim_ready || !cfg_owner_admitted)$fatal(1,"matrix owner claim not admitted");tick();if(cfg_reject || ledger_claim_reject)$fatal(1,"resident command rejected");@(negedge clk);cfg_valid=0;
    while(!done_valid)tick();
    if(done_status!=0 || actual_stripes!=20992 || actual_ps_commits!=83968 || actual_final_copies!=2624 || a_checks!=32 || w_checks!=20992 || output_words!=20992 || actual_a_reads!=32 || actual_a_returns!=32 || actual_w_reads!=20992 || actual_w_returns!=20992 || ledger_ps_state!=2 || ledger_dst_state!=2 || ledger_checked_rows!=16'hf || ledger_covered_rows!=16'hf || ledger_parent_publications!=1 || fa_slot_state[0]!=0 || wc_slot_readers[0]!=0 || wc_slot_state[0]!=2)$fatal(1,"resident final closure status=%0d stripes=%0d ps=%0d copies=%0d A=%0d W=%0d output=%0d ledger=%0d/%0d",done_status,actual_stripes,actual_ps_commits,actual_final_copies,a_checks,w_checks,output_words,ledger_ps_state,ledger_dst_state);
    for(int r=0;r<4;r++)if(ps_checks[r]!=20992)$fatal(1,"resident full PS coverage");
    repeat(7)begin tick();if(!done_valid || ledger_dst_state!=2)$fatal(1,"resident held response");end
    measure_legacy_hold_end=cycle;
    // Preserve the seven held cycles above, then consume once at a real edge.
    @(negedge clk);done_ready=1;tick();
    if(measure_consumes!=1 || done_valid || top.dut.state!=0 || ledger_dst_state!=2 ||
       ledger_parent_publications!=1 || !ledger_retire_debt_zero)
      $fatal(1,"Down response consume/deassert/debt closure");
    @(negedge clk);done_ready=0;tick();
    if(done_valid || measure_consumes!=1 || ledger_dst_state!=2 || ledger_parent_publications!=1)
      $fatal(1,"Down response after consume");
    measurement_report("full");
    if(aw_seen || w_seen || bdelay || m_axi_bvalid[0] ||
       output_beats!=1312 || bretired!=1312 || ledger_parent_publications!=1 ||
       fa_slot_state[0]!=0 || wc_slot_readers[0]!=0 || !a_read_debt_zero)
      $fatal(1,"Wi to G switch with physical or cache debt");
    for(int i=0;i<83968;i++)begin
      if(!ddr_written[4096+i] || ddr[4096+i]!==wi_fixture[i/4][(i%4)*8+:8])
        $fatal(1,"Wi DDR readback byte=%0d",i);
    end
    $display("WIGQD_WI_COMPLETE cycle=%0d Wi_AW=%0d Wi_B=%0d",cycle,actual_aw_count[0],actual_b_count[0]);
    @(negedge clk);stage=1;prefill_select=0;
    a_checks=0;w_checks=0;output_words=0;expected_output_beats=256;
    for(int r=0;r<4;r++)ps_checks[r]=0;
    for(int i=0;i<4096;i++)output_seen[i]=0;
    for(int pp=0;pp<3;pp++)begin
      if(q_active[pp])$fatal(1,"W reader active at Wi->Down switch");
      q_index[pp]=0;q_left[pp]=0;q_bytes[pp]=0;q_beats[pp]=0;q_bursts[pp]=0;
    end
    if(aux_active)$fatal(1,"AUX reader active at switch");
    aux_index=0;aux_left=0;aux_bytes=0;
    measure_cfg=-1;measure_done=-1;measure_consume=-1;measure_consumes=0;
    measure_done_hold=0;measure_state_sum=0;measure_aw=0;measure_w=0;measure_b=0;
    measure_useful_bytes=0;measure_physical_bytes=0;measure_w_start=-1;measure_w_publish=-1;
    measure_a_start=-1;measure_a_publish=-1;measure_legacy_hold_end=-1;
    measure_first_issue=-1;measure_last_issue=-1;measure_first_launch=-1;measure_last_launch=-1;
    measure_first_ps=-1;measure_last_ps=-1;measure_first_aw=-1;measure_last_aw=-1;
    measure_first_w=-1;measure_last_w=-1;measure_first_b=-1;measure_last_b=-1;
    measure_a_request_wait=0;measure_a_return_wait=0;measure_a_return_blocked=0;
    measure_w_request_wait=0;measure_w_return_wait=0;measure_w_return_blocked=0;
    measure_front_wait=0;measure_compute_active=0;measure_launches=0;measure_ps_cycles=0;
    measure_ps_blocked=0;measure_writer_packet_wait=0;measure_writer_tx=0;measure_writer_wait_b=0;
    measure_aw_wait=0;measure_w_wait=0;measure_b_backpressure=0;
    measure_tb_aw_gate=0;measure_tb_w_gate=0;
    for(int pp=0;pp<3;pp++)begin
      measure_w_ar_wait[pp]=0;measure_w_r_gap[pp]=0;measure_w_r_blocked[pp]=0;
    end
    measure_aux_ar_wait=0;measure_aux_r_gap=0;measure_aux_r_blocked=0;
    for(int st=0;st<13;st++)measure_state[st]=0;
    $readmemh({afixture,"/q.mem"},aq);$readmemh({afixture,"/scale.mem"},asc);
    $readmemh({afixture,"/output.mem"},outgold);
    $readmemh({bound_fixture,"/model_identity.hex"},model);
    $readmemh({bound_fixture,"/expected_aux_header.hex"},header);
    $readmemh({bound_fixture,"/aux_header.hex"},auxwords);
    $readmemh({wfixture,"/down_config.hex"},config_words);
    $readmemh({wfixture,"/down_q0.hex"},wq0);$readmemh({wfixture,"/down_q1.hex"},wq1);
    $readmemh({wfixture,"/down_scale.hex"},wsc);
    $readmemh({streams,"/w8.mem"},vw);$readmemh({streams,"/ps.mem"},vps);
    cfg_K=2624;cfg_N=1024;
    cfg_linear_context[31:0]=32'hac000006;cfg_linear_context[39:32]=8'h33;
    cfg_source_ref=64'h0000000700000001;
    cfg_a_ref=64'h0000002200000002;cfg_w_ref=64'h0000002300000002;
    cfg_ps_ref=64'h0000002400000002;cfg_dst_ref=64'h0000000300000001;
    cfg_w_model_identity=model[0];cfg_a_epoch=2;cfg_w_epoch=2;cfg_weight_key=4;
    cfg_bo_base[0]=STATE1_BASE;cfg_bo_span[0]=64'd16919104;
    cfg_region_base[0]=TMP_BASE;cfg_region_span[0]=64'd8388608;
    cfg_row_stride_bytes=4096;
    cfg_batch_stride_bytes=4194304;
    @(negedge clk);
    g_cfg_numeric_identity=cfg_numeric_identity;
    g_cfg_producer_context=cfg_linear_context;
    g_cfg_producer_context[31:0]=32'hac000004;
    g_cfg_producer_context[39:32]=8'h60;
    g_cfg_quant_context=cfg_linear_context;
    g_cfg_quant_context[31:0]=32'hac000005;
    g_cfg_quant_context[39:32]=8'h20;
    g_cfg_linear_context=cfg_linear_context;
    g_cfg_wi_ref=64'h0000000600000001;
    g_cfg_gate_ref=cfg_source_ref;
    g_cfg_a_ref=cfg_a_ref;g_cfg_w_ref=cfg_w_ref;g_cfg_down_dst_ref=cfg_dst_ref;
    g_cfg_rows=4;g_cfg_a_slot=cfg_a_slot;g_cfg_a_slot_epoch=cfg_a_epoch;
    g_cfg_bo_base=64'h100000000;g_cfg_bo_span=64'h3000000;
    g_cfg_region_base=DDR_BASE+64'h20000;g_cfg_region_span=64'h1000000;
    g_first_addr=g_cfg_region_base;
    // The original outer admission rejection remains a zero-issue check.
    g_cfg_owner_admitted=0;g_cfg_valid=1;
    @(posedge clk);while(!g_cfg_ready)@(posedge clk);#1;
    if(!g_cfg_reject || g_aw_count!=0 || top.producer.vector_row.issued!=0 || g_quant_starts!=4)
      $fatal(1,"GQD0 rejected G admission issued work");
    @(negedge clk);g_cfg_valid=0;g_cfg_owner_admitted=1;tick();
    @(negedge clk);g_cfg_valid=1;tick();
    if(g_cfg_reject)$fatal(1,"GQD0 legal G command rejected");
    if(top.ffn_handoff.gate_k_held !== GATE_K ||
       top.ffn_handoff.gate_rows_held !== 3'd4)
      $fatal(1,"M005 G accepted K/rows mismatch K=%0d rows=%0d",
             top.ffn_handoff.gate_k_held,top.ffn_handoff.gate_rows_held);
    $display("M005_G_ACCEPT cycle=%0d K=%0d rows=%0d Wi_N_held=%0d",
             cycle,top.ffn_handoff.gate_k_held,top.ffn_handoff.gate_rows_held,
             wi_matrix_n_held);
    @(negedge clk);g_cfg_valid=0;
    // The next external command waits throughout the real G/quant task.
    // Its owner admission is false, so post-G selection is a zero-work reject.
    ln_candidate_valid=1;
    #1;if(ln_candidate_ready || ln_query_valid || source_quant_ready)
      $fatal(1,"QAR0 replay Q preempted G or acquired source");
    $display("MATRIX_PROGRESS cycle=%0d GQD0_cfg_accepted=1",cycle);
    // The physical reader owns all Wi scalar/status/row signals.
    @(negedge clk);wi_cfg_valid=1;
    @(posedge clk);while(!wi_cfg_ready)@(posedge clk);#1;
    if(wi_cfg_reject)$fatal(1,"WIGQD Wi reader cfg rejected");
    @(negedge clk);wi_cfg_valid=0;
    if(pilot)begin
      while(wi_complete_rows<1 || g_b_count<164)tick();
      if(wi_r_count<328 || g_w_count<164)$fatal(1,"WIGQD pilot physical first row");
      $display("WIGQD0_PILOT_PASS cycle=%0d Wi_AW=1312 Wi_reader_R=%0d GATE_B=%0d Down=NOT_RUN",cycle,wi_r_count,g_b_count);
      $finish;
    end
    while(!g_done_valid)tick();
    $display("QWIGQD0_G_COUNTERS cycle=%0d starts=%0d rows=%0d input_beats=%0d half=%0d scale=%0d complete_rows=%0d source_R=%0d gate_W=%0d gate_R=%0d source_R_TB=%0d g_half=%0d debt=%0b",
      cycle,g_quant_starts,g_quant_rows,g_quant_input_beats,fa_physical_half_commits,
      fa_physical_scale_commits,g_source_complete_rows,g_source_r_count,
      g_write_beats,g_read_beats,source_r_beats,g_quant_halves,top.producer.quant_task_debt_zero);
    if(g_done_status!=0 || g_gate_owner_state!=0 || fa_slot_state[0]!=2 ||
       fa_slot_rows_done[0]!=16'hf || g_quant_starts!=4 || g_quant_rows!=4 ||
       g_quant_input_beats!=656 || fa_physical_half_commits!=656 ||
       fa_physical_scale_commits!=328 || g_source_complete_rows!=4 ||
       g_source_r_count!=656 || g_write_beats!=656 ||
       g_read_beats-source_r_beats!=656 ||
       g_quant_halves!=656)
      $fatal(1,"GQD0 bridge completion/physical debt");
    repeat(7)begin tick();if(!g_done_valid || fa_slot_state[0]!=2 || source_quant_ready || source_quant_reject)
      $fatal(1,"GQD0 held bridge response");end
    @(negedge clk);g_done_ready=1;tick();
    @(negedge clk);g_done_ready=0;tick();
    if(!ln_candidate_reject || source_quant_done_valid ||
       fa_slot_state[0]!=2 || fa_slot_epoch[0]!=2 ||
       g_source_r_count!=656 || g_b_count!=656)
      $fatal(1,"QAR0 waiting external reject after G retirement");
    @(negedge clk);ln_candidate_valid=0;tick();
    if(ln_candidate_reject || top.producer.ext_quant_active)
      $fatal(1,"QAR0 external rejection not released");
    if(g_done_valid || fa_slot_state[0]!=2 || wi_reader_active || wi_r_count!=1312 ||
       wi_complete_rows!=4 || wi_accepted!=20992 || wi_rows_retired!=4)
      $fatal(1,"GQD0 bridge/Wi reader consume");
    measure_a_publish=cycle;
    $display("MATRIX_PROGRESS cycle=%0d GQD0_A_ready=1 gate_AW=%0d gate_W=%0d gate_B=%0d gate_AR=%0d gate_R=%0d quant_groups=%0d",cycle,g_aw_count,g_w_count,g_b_count,g_source_ar_count,g_source_r_count,fa_physical_scale_commits);
    wc_load_slot=0;wc_load_epoch=2;wc_load_k=2624;wc_load_n=1024;wc_load_weight_key=4;wc_load_model_identity=model[0];wc_load_expected_aux_header=header[0];wc_load_aux_base=64'h400000000;wc_load_bias_base=0;wc_load_bias_bytes=0;
    for(int pp=0;pp<3;pp++)begin wc_load_base[pp]=64'h500000000+64'(pp)*64'h10000000+config_words[3+pp];wc_load_bytes[pp]=32'(config_words[6+pp]);end
    @(negedge clk);wc_request_valid=1;
    @(posedge clk);while(!wc_request_ready)@(posedge clk);#1;
    @(negedge clk);wc_request_valid=0;
    while(!wc_load_done)tick();if(wc_load_error || wc_load_reject || wc_slot_state[0]!=2 || wc_load_scale_checks!=83968)$fatal(1,"resident physical W strict load checks=%0d error=%b reject=%b state=%0d",wc_load_scale_checks,wc_load_error,wc_load_reject,wc_slot_state[0]);
    for(int pp=0;pp<3;pp++)if(q_active[pp] || q_beats[pp]*64!=wc_load_bytes[pp])$fatal(1,"actual W final R coverage");
    measure_w_publish=cycle;
    $display("MATRIX_PROGRESS cycle=%0d physical_W_published=1 W_R=%0d,%0d,%0d scale_checks=%0d",cycle,q_beats[0],q_beats[1],q_beats[2],wc_load_scale_checks);
    $display("M005_DOWN_ENTRY_WAIT cycle=%0d time=%0t",cycle,$time);
    @(negedge clk);
    $display("M005_DOWN_ENTRY_NEGEDGE cycle=%0d time=%0t",cycle,$time);
    cfg_valid=1;
    $display("M005_DOWN_VALID_SET cycle=%0d time=%0t",cycle,$time);
    #1;
    $display("M005_DOWN_ENTRY_SAMPLE cycle=%0d time=%0t cfg_valid=%b cfg_ready=%b ledger_ready=%b ledger_admitted=%b candidate_ready=%b matrix_valid=%b handoff_error=%b static_ok=%b G_K_held=%0d Wi_N_held=%0d Down_K=%0d",
      cycle,$time,cfg_valid,cfg_ready,ledger_claim_ready,cfg_owner_admitted,
      ffn_down_candidate_ready,ffn_matrix_cfg_valid,ffn_handoff_error,
      top.ffn_handoff.static_ok,top.ffn_handoff.gate_k_held,wi_matrix_n_held,cfg_K);
    if(top.ffn_handoff.gate_k_held !== GATE_K ||
       wi_matrix_n_held !== 16'd5248 || cfg_K !== 16'd2624)
      $fatal(1,"M005 Wi/G/Down width binding mismatch");
    if(cfg_ready!==1'b1 || ledger_claim_ready!==1'b1 ||
       cfg_owner_admitted!==1'b1 || ffn_down_candidate_ready!==1'b1 ||
       ffn_matrix_cfg_valid!==1'b1 || ffn_handoff_error!==1'b0)
      $fatal(1,"FFN0 Down candidate/owner claim not admitted");
    tick();
    $display("M005_DOWN_ENTRY_POST cycle=%0d time=%0t cfg_reject=%b ledger_reject=%b candidate_reject=%b tmp_reserved=%b hidden_reserved=%b",
      cycle,$time,cfg_reject,ledger_claim_reject,ffn_down_candidate_reject,
      ffn_tmp_reserved,ffn_hidden_reserved);
    if(cfg_reject || ledger_claim_reject || ffn_down_candidate_reject ||
       !ffn_tmp_reserved || !ffn_hidden_reserved)
      $fatal(1,"FFN0 Down command rejected or ticket not reserved");
    @(negedge clk);cfg_valid=0;
    if(pilot)begin
      while(ps_checks[0]<256 || ps_checks[1]<256 || ps_checks[2]<256 || ps_checks[3]<256)tick();
      measurement_report("pilot");
      $display("TM4_MATRIX_RESIDENT_PILOT_PASS cycles=%0d physical_A_half_commits=%0d physical_W_R=%0d A_reads=%0d W_reads=%0d real_stripes=%0d actual_PS_gold_checks=%0d output_final_B=NOT_RUN",cycle,fa_physical_half_commits,q_beats[0]+q_beats[1]+q_beats[2],a_checks,w_checks,actual_stripes,ps_checks[0]+ps_checks[1]+ps_checks[2]+ps_checks[3]);$finish;
    end
    while(!done_valid)tick();
    if(done_status!=0 || actual_stripes!=10496 || actual_ps_commits!=41984 || actual_final_copies!=512 || a_checks!=82 || w_checks!=10496 || output_words!=4096 || actual_a_reads!=82 || actual_a_returns!=82 || actual_w_reads!=10496 || actual_w_returns!=10496 || ledger_ps_state!=2 || ledger_dst_state!=2 || ledger_checked_rows!=16'hf || ledger_covered_rows!=16'hf || ledger_parent_publications!=2 || fa_slot_state[0]!=0 || wc_slot_readers[0]!=0 || wc_slot_state[0]!=2)$fatal(1,"resident final closure status=%0d stripes=%0d ps=%0d copies=%0d A=%0d W=%0d output=%0d ledger=%0d/%0d",done_status,actual_stripes,actual_ps_commits,actual_final_copies,a_checks,w_checks,output_words,ledger_ps_state,ledger_dst_state);
    for(int r=0;r<4;r++)if(ps_checks[r]!=10496)$fatal(1,"resident full PS coverage");
    repeat(7)begin tick();if(!done_valid || ledger_dst_state!=2)$fatal(1,"resident held response");end
    measure_legacy_hold_end=cycle;
    // Preserve the seven held cycles above, then consume once at a real edge.
    @(negedge clk);done_ready=1;tick();
    if(measure_consumes!=1 || done_valid || top.dut.state!=0 || ledger_dst_state!=2 ||
       ledger_parent_publications!=2 || !ledger_retire_debt_zero)
      $fatal(1,"Down response consume/deassert/debt closure");
    @(negedge clk);done_ready=0;tick();
    if(done_valid || measure_consumes!=1 || ledger_dst_state!=2 || ledger_parent_publications!=2)
      $fatal(1,"Down response after consume");
    for(int i=0;i<DDR_BYTES;i++)begin : final_ddr_readback
      logic expected_written;
      expected_written=(i>=4096 && i<4096+83968) ||
                       (i>=131072 && i<131072+41984);
      if(ddr_written[i]!==expected_written)
        $fatal(1,"WIGQD DDR coverage/guard address=%h",DDR_BASE+i);
      if(!expected_written && ddr[i]!==8'ha5)
        $fatal(1,"WIGQD DDR sentinel address=%h",DDR_BASE+i);
      if(i>=4096 && i<4096+83968 &&
         ddr[i]!==wi_fixture[(i-4096)/4][((i-4096)%4)*8+:8])
        $fatal(1,"WIGQD Wi DDR final readback byte=%0d",i-4096);
      if(i>=131072 && i<131072+41984 &&
         ddr[i]!==gate_gold[(i-131072)/4][((i-131072)%4)*8+:8])
        $fatal(1,"WIGQD GATE DDR final readback byte=%0d",i-131072);
    end
    for(int i=0;i<65536;i++)begin
      if(i<16384)begin
        if(!state1_tmp_written[i] ||
           state1_tmp[i]!==outgold[i/4][(i%4)*8+:8])
          $fatal(1,"FFN0 Down TMP actual store byte=%0d",i);
      end else if(state1_tmp_written[i] || state1_tmp[i]!==8'ha5)
        $fatal(1,"FFN0 TMP neighbor changed byte=%0d",i);
    end
    if(wi_ar_count==0 || wi_r_count!=1312 || g_aw_count!=656 ||
       g_b_count!=656 || g_read_beats-source_r_beats!=656 || actual_aw_count[0]!=256 ||
       actual_b_count[0]!=256 || g_cfg_edge<0 || quant_a_publish_edge<0 ||
       wi_reader_first_ar<0 || wi_reader_first_r<0 || gate_first_aw<0 ||
       gate_first_w<0 || gate_first_b<0 || quant_first_r<0)
      $fatal(1,"WIGQD final physical transaction coverage");
    $display("WIGQD_BOUNDARIES sample=posedge Wi_reader_AR=%0d/%0d Wi_reader_R=%0d/%0d Wi_row_done=%0d,%0d,%0d,%0d G_cfg=%0d GATE_AW=%0d/%0d GATE_W=%0d/%0d GATE_B=%0d/%0d quant_R=%0d/%0d A_publish=%0d finish=%0d",
      wi_reader_first_ar,wi_reader_last_ar,wi_reader_first_r,wi_reader_last_r,
      wi_reader_row_edge[0],wi_reader_row_edge[1],wi_reader_row_edge[2],wi_reader_row_edge[3],
      g_cfg_edge,gate_first_aw,gate_last_aw,gate_first_w,gate_last_w,gate_first_b,gate_last_b,
      quant_first_r,quant_last_r,quant_a_publish_edge,cycle);
    measurement_report("full");
    if(!ln_owner_released || ln_lease_pending || ln_admission_error ||
       ln_source.source_ar_count!=4 || ln_source.source_r_count!=256 ||
       ln_source.destination_aw_count!=4 ||
       ln_source.destination_w_count!=256 ||
       ln_source.destination_b_count!=4)
      $fatal(1,"LNQ0 final source/lease debt not closed");
    $display("FFN0_PREFIX_PASS source_Q_accept=%0d source_AR=%0d source_AR_beats=%0d source_R=%0d source_A_publish=%0d gate_W=%0d gate_R=%0d gate_A_publish=%0d Down_AW=%0d Down_W=%0d Down_B=%0d cycle=%0d",source_quant_accept_edge,source_ar_count,source_ar_beats,source_r_beats,source_a_publish_edge,g_write_beats,g_read_beats-source_r_beats,quant_a_publish_edge,actual_aw_count[0],actual_w_count[0],actual_b_count[0],cycle);
    if(!ffn_done_consumed || !ffn_tmp_reserved || !ffn_hidden_reserved ||
       ffn_handoff_error || ffn_down_aw!=256 || ffn_down_w!=256 ||
       ffn_down_b!=256)
      $fatal(1,"FFN0 Down-to-residual retirement gate did not retain ticket");
    while(!ffn_res_rsp_valid)tick();
    if(ffn_res_rsp_status!=0 || !ffn_dst_published ||
       ffn_res_rsp_context!==ffn_res_local_context ||
       ffn_skip_ar_count!=256 || ffn_skip_r_count!=256 ||
       ffn_down_ar_count!=256 || ffn_down_r_count!=256 ||
       ffn_add_start_count!=4096 || ffn_add_done_count!=4096 ||
       ffn_res_aw_count!=256 || ffn_res_w_count!=256 ||
       ffn_res_b_count!=256 || ffn_down_read_count!=256)
      $fatal(1,"FFN0 residual response, arithmetic, or physical debt");
    repeat(7)begin
      tick();
      if(!ffn_res_rsp_valid || ffn_res_rsp_status!=0 ||
         ffn_res_rsp_context!==ffn_res_local_context)
        $fatal(1,"FFN0 residual held response changed");
    end
    @(negedge clk);ffn_res_rsp_ready=1;tick();
    @(negedge clk);ffn_res_rsp_ready=0;tick();
    if(!ffn_res_consumed || !ffn_hidden_published ||
       ffn_tmp_reserved || ffn_hidden_reserved || ffn_handoff_error ||
       ffn_res_rsp_valid || ffn_source_locked)
      $fatal(1,"FFN0 residual actual consume/release");
    for(int i=0;i<16384;i++)begin
      if(i<4096)begin
        if(ln_source.source_mem[i]!==ffn_skip_gold[i] ||
           ln_source.destination_mem[i]!==ln_source.gold_mem[i])
          $fatal(1,"FFN0 skip/NORM identity word=%0d",i);
      end else begin
        if(ln_source.source_mem[i]!==32'ha5a5a5a5 ||
           ln_source.destination_mem[i]!==32'ha5a5a5a5 ||
           ln_source.destination_written[i])
          $fatal(1,"FFN0 source/NORM neighbor changed word=%0d",i);
      end
    end
    for(int i=0;i<65536;i++)begin
      if(i<16384)begin
        if(!state1_tmp_written[i] || !state1_hidden_written[i] ||
           state1_tmp[i]!==outgold[i/4][(i%4)*8+:8] ||
           state1_hidden[i]!==ffn_gold[i/4][(i%4)*8+:8])
          $fatal(1,"FFN0 STATE1 actual TMP/HIDDEN byte=%0d",i);
      end else if(state1_tmp_written[i] || state1_hidden_written[i] ||
                  state1_tmp[i]!==8'ha5 || state1_hidden[i]!==8'ha5)
        $fatal(1,"FFN0 STATE1 neighbor changed byte=%0d",i);
    end
    begin : final_ffn0_measurement
      integer sum,latency_sum;
      sum=0;latency_sum=0;
      for(int k=0;k<5;k++)sum+=ffn0_phase_cycles[k];
      for(int k=0;k<256;k++)begin
        latency_sum+=ffn0_add_latency_hist[k];
        if(ffn0_add_latency_hist[k]!=0)
          $display("FFN0_ADD_LATENCY cycles=%0d count=%0d",
                   k,ffn0_add_latency_hist[k]);
      end
      if(sum!=ffn0_phase_total || ffn0_phase_cycles[0]==0 ||
         ffn0_phase_cycles[1]==0 || ffn0_phase_cycles[2]==0 ||
         ffn0_phase_cycles[3]==0 || latency_sum!=4096 ||
         ffn0_add_latency_samples!=4096 || ffn0_add_inflight ||
         ffn0_down_claim_edge<0 || ffn0_owner_retire_edge<0 ||
         ffn0_done_consume_edge<0 || ffn0_res_cfg_edge<0 ||
         ffn0_res_rsp_edge<0 || ffn0_local_publish_edge<0 ||
         ffn0_tmp_lock_edge<0 || ffn0_tmp_unlock_edge<0 ||
         ffn0_hidden_ticket_edge<0 || ffn0_hidden_release_edge<0 ||
         ffn0_first_skip_ar<0 || ffn0_first_skip_r<0 ||
         ffn0_first_tmp_ar<0 || ffn0_first_tmp_r<0 ||
         ffn0_first_hidden_aw<0 || ffn0_first_hidden_w<0 ||
         ffn0_first_hidden_b<0)
        $fatal(1,"FFN0 boundary/phase/latency coverage incomplete");
      $display("FFN0_BOUNDARIES sample=pre_NBA_posedge Down_claim=%0d last_Down_B=%0d owner_retire=%0d done_consume=%0d residual_cfg=%0d TMP_lock=%0d/%0d HIDDEN_ticket=%0d/%0d residual_rsp_consume=%0d local_publish=%0d skip_AR=%0d/%0d skip_R=%0d/%0d TMP_AR=%0d/%0d TMP_R=%0d/%0d HIDDEN_AW=%0d/%0d HIDDEN_W=%0d/%0d HIDDEN_B=%0d/%0d",
        ffn0_down_claim_edge,measure_last_b,ffn0_owner_retire_edge,
        ffn0_done_consume_edge,ffn0_res_cfg_edge,
        ffn0_tmp_lock_edge,ffn0_tmp_unlock_edge,
        ffn0_hidden_ticket_edge,ffn0_hidden_release_edge,
        ffn0_res_rsp_edge,ffn0_local_publish_edge,
        ffn0_first_skip_ar,ffn0_last_skip_ar,
        ffn0_first_skip_r,ffn0_last_skip_r,
        ffn0_first_tmp_ar,ffn0_last_tmp_ar,
        ffn0_first_tmp_r,ffn0_last_tmp_r,
        ffn0_first_hidden_aw,ffn0_last_hidden_aw,
        ffn0_first_hidden_w,ffn0_last_hidden_w,
        ffn0_first_hidden_b,ffn0_last_hidden_b);
      $display("FFN0_PHASE_CYCLES exclusive=1 total=%0d LN_prefix=%0d Wi_and_first_Q=%0d G_and_Down=%0d residual=%0d closure=%0d",
        sum,ffn0_phase_cycles[0],ffn0_phase_cycles[1],
        ffn0_phase_cycles[2],ffn0_phase_cycles[3],ffn0_phase_cycles[4]);
    end
    $display("FFN0_CHAIN_PASS cycle=%0d LN_R=%0d Q_R=%0d Wi_R=%0d GATE_R=%0d Down_B=%0d skip_AR/R=%0d/%0d TMP_AR/R=%0d/%0d FADD=%0d/%0d HIDDEN_AW/W/B=%0d/%0d/%0d DDR_bytes=393216 local_windows_bytes=262144",
      cycle,ln_source.source_r_count,source_r_beats,wi_r_count,
      g_read_beats-source_r_beats,actual_b_count[0],
      ffn_skip_ar_count,ffn_skip_r_count,ffn_down_ar_count,
      ffn_down_r_count,ffn_add_start_count,ffn_add_done_count,
      ffn_res_aw_count,ffn_res_w_count,ffn_res_b_count);
    $finish;
  end
endmodule

`default_nettype wire
