// KB0 observation-only derivative of resident_regression_02 frozen TB.
// DUT/model/gold/stimulus are unchanged except real done response consumption.
`timescale 1ns/1ps
// Local physical-cache test with immutable prequantized A input. No G/quant/13BO binding proof.
module tm4tn8_wi_resident_tb_v1;
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
  logic wc_load_valid;
  logic wc_load_ready;
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
  tm4tn8_matrix_resident_v2 dut (
    .cancel(1'b0),
    .clk(clk),
    .rst_n(rst_n),
    .cfg_valid(cfg_valid),
    .cfg_ready(cfg_ready),
    .cfg_reject(cfg_reject),
    .cfg_owner_admitted(cfg_owner_admitted),
    .cfg_target_invalidated(cfg_target_invalidated),
    .cfg_K(cfg_K),
    .cfg_N(cfg_N),
    .cfg_rows(cfg_rows),
    .cfg_row_block_base(cfg_row_block_base),
    .cfg_numeric_identity(cfg_numeric_identity),
    .cfg_linear_context(cfg_linear_context),
    .cfg_source_ref(cfg_source_ref),
    .cfg_a_ref(cfg_a_ref),
    .cfg_w_ref(cfg_w_ref),
    .cfg_ps_ref(cfg_ps_ref),
    .cfg_dst_ref(cfg_dst_ref),
    .cfg_w_model_identity(cfg_w_model_identity),
    .cfg_a_slot(cfg_a_slot),
    .cfg_w_slot(cfg_w_slot),
    .cfg_bias_kind(cfg_bias_kind),
    .cfg_a_epoch(cfg_a_epoch),
    .cfg_w_epoch(cfg_w_epoch),
    .cfg_weight_key(cfg_weight_key),
    .cfg_bo_base(cfg_bo_base),
    .cfg_bo_span(cfg_bo_span),
    .cfg_region_base(cfg_region_base),
    .cfg_region_span(cfg_region_span),
    .cfg_row_stride_bytes(cfg_row_stride_bytes),
    .cfg_batch_stride_bytes(cfg_batch_stride_bytes),
    .owner_invalidate_valid(owner_invalidate_valid),
    .owner_retire_valid(owner_retire_valid),
    .owner_retire_success(owner_retire_success),
    .owner_retire_ready(owner_retire_ready),
    .owner_retire_error(owner_retire_error),
    .owner_retire_row_block_base(owner_retire_row_block_base),
    .owner_retire_rows(owner_retire_rows),
    .done_valid(done_valid),
    .done_ready(done_ready),
    .done_status(done_status),
    .done_first_error_rank(done_first_error_rank),
    .done_bad_element(done_bad_element),
    .command_cycles(command_cycles),
    .actual_a_reads(actual_a_reads),
    .actual_a_returns(actual_a_returns),
    .actual_w_reads(actual_w_reads),
    .actual_w_returns(actual_w_returns),
    .actual_stripes(actual_stripes),
    .actual_ps_commits(actual_ps_commits),
    .actual_final_copies(actual_final_copies),
    .actual_aw_count(actual_aw_count),
    .actual_w_count(actual_w_count),
    .actual_b_count(actual_b_count),
    .m_axi_awaddr(m_axi_awaddr),
    .m_axi_awlen(m_axi_awlen),
    .m_axi_awsize(m_axi_awsize),
    .m_axi_awburst(m_axi_awburst),
    .m_axi_awvalid(m_axi_awvalid),
    .m_axi_awready(m_axi_awready),
    .m_axi_wdata(m_axi_wdata),
    .m_axi_wstrb(m_axi_wstrb),
    .m_axi_wlast(m_axi_wlast),
    .m_axi_wvalid(m_axi_wvalid),
    .m_axi_wready(m_axi_wready),
    .m_axi_bresp(m_axi_bresp),
    .m_axi_bvalid(m_axi_bvalid),
    .m_axi_bready(m_axi_bready),
    .a_acquire_valid(a_acquire_valid),
    .a_acquire_ready(a_acquire_ready),
    .a_acquire_done(a_acquire_done),
    .a_acquire_error(a_acquire_error),
    .a_acquire_slot(a_acquire_slot),
    .a_acquire_slot_epoch(a_acquire_slot_epoch),
    .a_acquire_K(a_acquire_K),
    .a_acquire_rows(a_acquire_rows),
    .a_acquire_numeric_identity(a_acquire_numeric_identity),
    .a_acquire_linear_context(a_acquire_linear_context),
    .a_acquire_a_ref(a_acquire_a_ref),
    .a_acquire_w_ref(a_acquire_w_ref),
    .a_acquire_dst_ref(a_acquire_dst_ref),
    .a_read_valid(a_read_valid),
    .a_read_ready(a_read_ready),
    .a_read_error(a_read_error),
    .a_read_slot(a_read_slot),
    .a_read_slot_epoch(a_read_slot_epoch),
    .a_read_numeric_identity(a_read_numeric_identity),
    .a_read_linear_context(a_read_linear_context),
    .a_read_a_ref(a_read_a_ref),
    .a_read_row_block_base(a_read_row_block_base),
    .a_read_rows(a_read_rows),
    .a_read_group(a_read_group),
    .a_ret_valid(a_ret_valid),
    .a_ret_ready(a_ret_ready),
    .a_ret_slot(a_ret_slot),
    .a_ret_slot_epoch(a_ret_slot_epoch),
    .a_ret_numeric_identity(a_ret_numeric_identity),
    .a_ret_linear_context(a_ret_linear_context),
    .a_ret_a_ref(a_ret_a_ref),
    .a_ret_row_block_base(a_ret_row_block_base),
    .a_ret_rows(a_ret_rows),
    .a_ret_group(a_ret_group),
    .a_ret_q(a_ret_q),
    .a_ret_scale(a_ret_scale),
    .a_release_valid(a_release_valid),
    .a_release_ready(a_release_ready),
    .a_release_done(a_release_done),
    .a_release_error(a_release_error),
    .a_release_slot(a_release_slot),
    .a_release_slot_epoch(a_release_slot_epoch),
    .a_release_numeric_identity(a_release_numeric_identity),
    .a_release_linear_context(a_release_linear_context),
    .a_release_a_ref(a_release_a_ref),
    .a_read_debt_zero(a_read_debt_zero),
    .w_lease_valid(w_lease_valid),
    .w_lease_ready(w_lease_ready),
    .w_lease_done(w_lease_done),
    .w_lease_error(w_lease_error),
    .w_lease_slot(w_lease_slot),
    .w_lease_epoch(w_lease_epoch),
    .w_lease_k(w_lease_k),
    .w_lease_n(w_lease_n),
    .w_lease_weight_key(w_lease_weight_key),
    .w_lease_model_identity(w_lease_model_identity),
    .w_lease_numeric_identity(w_lease_numeric_identity),
    .w_lease_task_context(w_lease_task_context),
    .w_read_valid(w_read_valid),
    .w_read_ready(w_read_ready),
    .w_read_error(w_read_error),
    .w_read_slot(w_read_slot),
    .w_read_epoch(w_read_epoch),
    .w_read_tile(w_read_tile),
    .w_read_group(w_read_group),
    .w_read_pair(w_read_pair),
    .w_read_model_identity(w_read_model_identity),
    .w_read_numeric_identity(w_read_numeric_identity),
    .w_read_task_context(w_read_task_context),
    .w_ret_valid(w_ret_valid),
    .w_ret_ready(w_ret_ready),
    .w_ret_slot(w_ret_slot),
    .w_ret_pair(w_ret_pair),
    .w_ret_epoch(w_ret_epoch),
    .w_ret_tile(w_ret_tile),
    .w_ret_group(w_ret_group),
    .w_ret_model_identity(w_ret_model_identity),
    .w_ret_numeric_identity(w_ret_numeric_identity),
    .w_ret_task_context(w_ret_task_context),
    .w_ret_q(w_ret_q),
    .w_ret_scale(w_ret_scale),
    .w_ret_bias(w_ret_bias),
    .w_ret_mask(w_ret_mask),
    .w_release_valid(w_release_valid),
    .w_release_ready(w_release_ready),
    .w_release_done(w_release_done),
    .w_release_error(w_release_error),
    .w_release_slot(w_release_slot),
    .w_release_epoch(w_release_epoch),
    .w_release_numeric_identity(w_release_numeric_identity),
    .w_release_task_context(w_release_task_context)
  );
  quant_dual_a_v1 astore (
    .clk(clk),
    .rst_n(rst_n),
    .fill_valid(fa_fill_valid),
    .fill_ready(fa_fill_ready),
    .fill_reject(fa_fill_reject),
    .fill_owner_admitted(fa_fill_owner_admitted),
    .fill_source_published(fa_fill_source_published),
    .fill_slot(fa_fill_slot),
    .fill_slot_epoch(fa_fill_slot_epoch),
    .fill_K(fa_fill_K),
    .fill_rows(fa_fill_rows),
    .fill_numeric_identity(fa_fill_numeric_identity),
    .fill_producer_context(fa_fill_producer_context),
    .fill_quant_context(fa_fill_quant_context),
    .fill_linear_context(fa_fill_linear_context),
    .fill_source_ref(fa_fill_source_ref),
    .fill_a_ref(fa_fill_a_ref),
    .fill_w_ref(fa_fill_w_ref),
    .fill_dst_ref(fa_fill_dst_ref),
    .commit_valid(fa_commit_valid),
    .commit_ready(fa_commit_ready),
    .commit_error(fa_commit_error),
    .commit_numeric_identity(fa_commit_numeric_identity),
    .commit_quant_context(fa_commit_quant_context),
    .commit_a_ref(fa_commit_a_ref),
    .commit_row(fa_commit_row),
    .commit_group(fa_commit_group),
    .commit_half(fa_commit_half),
    .commit_q(fa_commit_q),
    .commit_scale(fa_commit_scale),
    .row_done_valid(fa_row_done_valid),
    .row_done_ready(fa_row_done_ready),
    .row_done_row(fa_row_done_row),
    .row_done_status(fa_row_done_status),
    .row_done_bad_col(fa_row_done_bad_col),
    .row_done_debt_zero(fa_row_done_debt_zero),
    .finish_valid(fa_finish_valid),
    .finish_ready(fa_finish_ready),
    .fill_done(fa_fill_done),
    .fill_error(fa_fill_error),
    .publish_valid(fa_publish_valid),
    .finish_debt_zero(fa_finish_debt_zero),
    .fill_bad_element(fa_fill_bad_element),
    .slot_state(fa_slot_state),
    .slot_epoch(fa_slot_epoch),
    .slot_rows_done(fa_slot_rows_done),
    .physical_half_commits(fa_physical_half_commits),
    .physical_scale_commits(fa_physical_scale_commits),
    .acquire_valid(a_acquire_valid),
    .acquire_ready(a_acquire_ready),
    .acquire_done(a_acquire_done),
    .acquire_error(a_acquire_error),
    .acquire_slot(a_acquire_slot),
    .acquire_slot_epoch(a_acquire_slot_epoch),
    .acquire_K(a_acquire_K),
    .acquire_rows(a_acquire_rows),
    .acquire_numeric_identity(a_acquire_numeric_identity),
    .acquire_linear_context(a_acquire_linear_context),
    .acquire_a_ref(a_acquire_a_ref),
    .acquire_w_ref(a_acquire_w_ref),
    .acquire_dst_ref(a_acquire_dst_ref),
    .read_valid(a_read_valid),
    .read_ready(a_read_ready),
    .read_error(a_read_error),
    .read_slot(a_read_slot),
    .read_slot_epoch(a_read_slot_epoch),
    .read_numeric_identity(a_read_numeric_identity),
    .read_linear_context(a_read_linear_context),
    .read_a_ref(a_read_a_ref),
    .read_row_block_base(a_read_row_block_base),
    .read_rows(a_read_rows),
    .read_group(a_read_group),
    .ret_valid(a_ret_valid),
    .ret_ready(a_ret_ready),
    .ret_slot(a_ret_slot),
    .ret_slot_epoch(a_ret_slot_epoch),
    .ret_numeric_identity(a_ret_numeric_identity),
    .ret_linear_context(a_ret_linear_context),
    .ret_a_ref(a_ret_a_ref),
    .ret_row_block_base(a_ret_row_block_base),
    .ret_rows(a_ret_rows),
    .ret_group(a_ret_group),
    .ret_q(a_ret_q),
    .ret_scale(a_ret_scale),
    .release_valid(a_release_valid),
    .release_ready(a_release_ready),
    .release_done(a_release_done),
    .release_error(a_release_error),
    .release_slot(a_release_slot),
    .release_slot_epoch(a_release_slot_epoch),
    .release_numeric_identity(a_release_numeric_identity),
    .release_linear_context(a_release_linear_context),
    .release_a_ref(a_release_a_ref),
    .read_debt_zero(a_read_debt_zero)
  );
  t4_dual_w_cache_v1 wcache (
    .clk(clk),
    .rst_n(rst_n),
    .load_cancel(1'b0),
    .load_valid(wc_load_valid),
    .load_ready(wc_load_ready),
    .load_slot(wc_load_slot),
    .load_epoch(wc_load_epoch),
    .load_k(wc_load_k),
    .load_n(wc_load_n),
    .load_weight_key(wc_load_weight_key),
    .load_model_identity(wc_load_model_identity),
    .load_expected_aux_header(wc_load_expected_aux_header),
    .load_base(wc_load_base),
    .load_bytes(wc_load_bytes),
    .load_aux_base(wc_load_aux_base),
    .load_bias_base(wc_load_bias_base),
    .load_bias_bytes(wc_load_bias_bytes),
    .load_done(wc_load_done),
    .load_error(wc_load_error),
    .load_reject(wc_load_reject),
    .load_scale_checks(wc_load_scale_checks),
    .load_bad_element(wc_load_bad_element),
    .slot_state(wc_slot_state),
    .slot_epoch(wc_slot_epoch),
    .slot_readers(wc_slot_readers),
    .slot_coverage(wc_slot_coverage),
    .commit_ready(wc_commit_ready),
    .araddr(wc_araddr),
    .arlen(wc_arlen),
    .arsize(wc_arsize),
    .arburst(wc_arburst),
    .arvalid(wc_arvalid),
    .arready(wc_arready),
    .rdata(wc_rdata),
    .rresp(wc_rresp),
    .rlast(wc_rlast),
    .rvalid(wc_rvalid),
    .rready(wc_rready),
    .aux_araddr(wc_aux_araddr),
    .aux_arlen(wc_aux_arlen),
    .aux_arsize(wc_aux_arsize),
    .aux_arburst(wc_aux_arburst),
    .aux_arvalid(wc_aux_arvalid),
    .aux_arready(wc_aux_arready),
    .aux_rdata(wc_aux_rdata),
    .aux_rresp(wc_aux_rresp),
    .aux_rlast(wc_aux_rlast),
    .aux_rvalid(wc_aux_rvalid),
    .aux_rready(wc_aux_rready),
    .lease_valid(w_lease_valid),
    .lease_ready(w_lease_ready),
    .lease_done(w_lease_done),
    .lease_error(w_lease_error),
    .lease_slot(w_lease_slot),
    .lease_epoch(w_lease_epoch),
    .lease_k(w_lease_k),
    .lease_n(w_lease_n),
    .lease_weight_key(w_lease_weight_key),
    .lease_model_identity(w_lease_model_identity),
    .lease_numeric_identity(w_lease_numeric_identity),
    .lease_task_context(w_lease_task_context),
    .read_valid(w_read_valid),
    .read_ready(w_read_ready),
    .read_error(w_read_error),
    .read_slot(w_read_slot),
    .read_epoch(w_read_epoch),
    .read_tile(w_read_tile),
    .read_group(w_read_group),
    .read_pair(w_read_pair),
    .read_model_identity(w_read_model_identity),
    .read_numeric_identity(w_read_numeric_identity),
    .read_task_context(w_read_task_context),
    .ret_valid(w_ret_valid),
    .ret_ready(w_ret_ready),
    .ret_slot(w_ret_slot),
    .ret_pair(w_ret_pair),
    .ret_epoch(w_ret_epoch),
    .ret_tile(w_ret_tile),
    .ret_group(w_ret_group),
    .ret_model_identity(w_ret_model_identity),
    .ret_numeric_identity(w_ret_numeric_identity),
    .ret_task_context(w_ret_task_context),
    .ret_q(w_ret_q),
    .ret_scale(w_ret_scale),
    .ret_bias(w_ret_bias),
    .ret_mask(w_ret_mask),
    .release_valid(w_release_valid),
    .release_ready(w_release_ready),
    .release_done(w_release_done),
    .release_error(w_release_error),
    .release_slot(w_release_slot),
    .release_epoch(w_release_epoch),
    .release_numeric_identity(w_release_numeric_identity),
    .release_task_context(w_release_task_context)
  );
  tm4tn8_matrix_owner_ledger_v2 ledger (
    .clk(clk),
    .rst_n(rst_n),
    .claim_valid(ledger_claim_valid),
    .claim_ready(ledger_claim_ready),
    .claim_admitted(cfg_owner_admitted),
    .claim_reject(ledger_claim_reject),
    .claim_K(cfg_K),
    .claim_N(cfg_N),
    .claim_rows(cfg_rows),
    .claim_row_block_base(cfg_row_block_base),
    .claim_numeric_identity(cfg_numeric_identity),
    .claim_parent_context(cfg_linear_context),
    .claim_source_ref(cfg_source_ref),
    .claim_a_ref(cfg_a_ref),
    .claim_w_ref(cfg_w_ref),
    .claim_ps_ref(cfg_ps_ref),
    .claim_dst_ref(cfg_dst_ref),
    .claim_model_identity(cfg_w_model_identity),
    .invalidate_valid(owner_invalidate_valid),
    .retire_valid(owner_retire_valid),
    .retire_ready(owner_retire_ready),
    .retire_error(owner_retire_error),
    .retire_success(owner_retire_success),
    .retire_debt_zero(ledger_retire_debt_zero),
    .retire_row_block_base(owner_retire_row_block_base),
    .retire_rows(owner_retire_rows),
    .ps_state(ledger_ps_state),
    .dst_state(ledger_dst_state),
    .target_invalidated(cfg_target_invalidated),
    .parent_complete(ledger_parent_complete),
    .parent_error(ledger_parent_error),
    .checked_rows(ledger_checked_rows),
    .covered_rows(ledger_covered_rows),
    .claims(ledger_claims),
    .view_retirements(ledger_view_retirements),
    .parent_publications(ledger_parent_publications)
  );

  initial clk=0;always #5 clk=~clk;
  logic [255:0] aq[0:127];logic [15:0] asc[0:127];logic [31:0] outgold[0:20991];
  logic [511:0] wq0[0:41983],wq1[0:41983],wsc[0:5247];
  logic [3327:0] model[0:0];logic [1023:0] header[0:0];logic [127:0] auxwords[0:7];logic [63:0] config_words[0:12];
  logic [2047:0] vw[0:20991];logic [1023:0] vps[0:20991];
  string afixture,wfixture,streams;integer pilot;
  integer cycle=0,q_index[0:2],q_left[0:2],q_bytes[0:2],q_beats[0:2],q_bursts[0:2];
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
       measure_useful_bytes!=83968 || measure_physical_bytes!=expected_output_beats*64))
      $fatal(1,"Down measurement complete coverage");
    $display("WI_MEASURE_BOUNDARIES mode=%s sample=pre_NBA_posedge A_fill_accept=%0d A_publish_post_NBA=%0d W_load_accept=%0d W_publish_post_NBA=%0d cfg_accept=%0d first_issue=%0d last_issue=%0d first_launch=%0d last_launch=%0d first_PS=%0d last_PS=%0d first_AW=%0d last_AW=%0d first_W=%0d last_W=%0d first_B=%0d last_B=%0d first_done_valid=%0d actual_done_consume=%0d legacy_hold_end=%0d finish=%0d",mode,measure_a_start,measure_a_publish,measure_w_start,measure_w_publish,measure_cfg,measure_first_issue,measure_last_issue,measure_first_launch,measure_last_launch,measure_first_ps,measure_last_ps,measure_first_aw,measure_last_aw,measure_first_w,measure_last_w,measure_first_b,measure_last_b,measure_done,measure_consume,measure_legacy_hold_end,cycle);
    $display("WI_MEASURE_STATES mode=%s exclusive=1 start_inclusive_cfg_accept=1 end_exclusive_first_done=1 cycles=%0d s0=%0d s1=%0d s2=%0d s3=%0d s4=%0d s5=%0d s6=%0d s7=%0d s8=%0d s9=%0d s10=%0d s11=%0d s12=%0d",mode,sum,measure_state[0],measure_state[1],measure_state[2],measure_state[3],measure_state[4],measure_state[5],measure_state[6],measure_state[7],measure_state[8],measure_state[9],measure_state[10],measure_state[11],measure_state[12]);
    $display("WI_MEASURE_OVERLAP mode=%s exclusive=0 A_request_not_ready=%0d A_WAIT_no_return=%0d A_return_not_ready=%0d W_request_not_ready=%0d W_pending_no_return=%0d W_return_not_ready=%0d front_issue_not_ready=%0d configured_front_not_done=%0d launch_edges=%0d PS_commit_edges=%0d PS_commit_not_ready=%0d writer_packet_not_ready=%0d writer_tx_valid=%0d writer_AW_W_sent_no_B=%0d AW_not_ready=%0d W_not_ready=%0d B_not_ready=%0d",mode,measure_a_request_wait,measure_a_return_wait,measure_a_return_blocked,measure_w_request_wait,measure_w_return_wait,measure_w_return_blocked,measure_front_wait,measure_compute_active,measure_launches,measure_ps_cycles,measure_ps_blocked,measure_writer_packet_wait,measure_writer_tx,measure_writer_wait_b,measure_aw_wait,measure_w_wait,measure_b_backpressure);
    $display("WI_MEASURE_FRONT mode=%s exclusive=0 native_dependency_stall=%0d native_credit_stall=%0d native_space_stall=%0d native_launch_stall=%0d native_commit_stall=%0d",mode,dut.frontend.busy_stall_count,dut.frontend.credit_stall_count,dut.frontend.front_stall_count,dut.frontend.launch_stall_count,dut.frontend.commit_stall_count);
    $display("WI_MEASURE_LOAD mode=%s exclusive=0 q0_AR_not_ready=%0d q1_AR_not_ready=%0d scale_AR_not_ready=%0d q0_active_R_gap=%0d q1_active_R_gap=%0d scale_active_R_gap=%0d q0_R_not_ready=%0d q1_R_not_ready=%0d scale_R_not_ready=%0d AUX_AR_not_ready=%0d AUX_active_R_gap=%0d AUX_R_not_ready=%0d q0_R=%0d q1_R=%0d scale_R=%0d",mode,measure_w_ar_wait[0],measure_w_ar_wait[1],measure_w_ar_wait[2],measure_w_r_gap[0],measure_w_r_gap[1],measure_w_r_gap[2],measure_w_r_blocked[0],measure_w_r_blocked[1],measure_w_r_blocked[2],measure_aux_ar_wait,measure_aux_r_gap,measure_aux_r_blocked,q_beats[0],q_beats[1],q_beats[2]);
    $display("WI_MEASURE_OUTPUT mode=%s exclusive=0 expected_output_beats=%0d actual_AW=%0d actual_W=%0d actual_B=%0d useful_strobe_bytes=%0d physical_W_bytes=%0d TB_periodic_AW_gate=%0d TB_periodic_W_gate=%0d TB_B_delay_decrements=%0d done_not_ready_edges=%0d actual_done_consumes=%0d DUT_command_cycles=%0d",mode,expected_output_beats,measure_aw,measure_w,measure_b,measure_useful_bytes,measure_physical_bytes,measure_tb_aw_gate,measure_tb_w_gate,held_b,measure_done_hold,measure_consumes,command_cycles);
  endtask
  task automatic tick;@(posedge clk);#1;endtask
  assign ledger_claim_valid=cfg_valid;
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
    if(cycle>40000000)$fatal(1,"resident cycle cap state=%0d stripes=%0d",dut.state,actual_stripes);
    if(!rst_n)begin
      aux_active<=0;aux_index<=0;aux_left<=0;aux_bytes<=0;
      for(int pp=0;pp<3;pp++)begin q_active[pp]<=0;q_index[pp]<=0;q_left[pp]<=0;q_bytes[pp]<=0;q_beats[pp]<=0;q_bursts[pp]<=0;end
      aw_seen=0;w_seen=0;stored=0;bdelay=0;m_axi_bvalid<=0;
    end else begin
      if(fa_fill_valid && fa_fill_ready && measure_a_start<0)measure_a_start=cycle;
      if(wc_load_valid && wc_load_ready && measure_w_start<0)measure_w_start=cycle;
      if(cfg_valid && cfg_ready)begin
        if(measure_cfg>=0)$fatal(1,"Down measurement duplicate cfg");
        measure_cfg=cycle;
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
        if(int'(dut.state)<0 || int'(dut.state)>12)$fatal(1,"Down measurement state range");
        measure_state[int'(dut.state)]++;measure_state_sum++;
        if(a_read_valid && !a_read_ready)measure_a_request_wait++;
        if(dut.state==5 && !a_ret_valid)measure_a_return_wait++;
        if(a_ret_valid && !a_ret_ready)measure_a_return_blocked++;
        if(w_read_valid && !w_read_ready)measure_w_request_wait++;
        if(dut.state==6 && dut.w_pending_reads!=0 && !w_ret_valid)measure_w_return_wait++;
        if(w_ret_valid && !w_ret_ready)measure_w_return_blocked++;
        if(dut.front_issue_valid && !dut.front_issue_ready)measure_front_wait++;
        if(dut.configured && !dut.front_done)measure_compute_active++;
        if(dut.front_issue_valid && dut.front_issue_ready)begin
          if(measure_first_issue<0)measure_first_issue=cycle;measure_last_issue=cycle;
        end
        if(dut.frontend.launch)begin
          measure_launches++;if(measure_first_launch<0)measure_first_launch=cycle;measure_last_launch=cycle;
        end
        if(|(dut.commit_valid & dut.commit_ready))begin
          measure_ps_cycles++;if(measure_first_ps<0)measure_first_ps=cycle;measure_last_ps=cycle;
        end
        if(|(dut.commit_valid & ~dut.commit_ready))measure_ps_blocked++;
        if(dut.writers[0].writer.packet_valid && !dut.writers[0].writer.packet_ready)measure_writer_packet_wait++;
        if(dut.writers[0].writer.tx_valid)measure_writer_tx++;
        if(dut.writers[0].writer.tx_valid && dut.writers[0].writer.tx_aw_sent &&
           dut.writers[0].writer.tx_w_sent && !m_axi_bvalid[0])measure_writer_wait_b++;
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
          q_index[pp]<=q_index[pp]+1;q_left[pp]<=q_left[pp]-1;q_beats[pp]<=q_beats[pp]+1;if(pp==0 && (q_beats[0]+1)%512==0)$display("MATRIX_PROGRESS cycle=%0d Wi_W_q0_R=%0d q1_R=%0d scale_R=%0d",cycle,q_beats[0]+1,q_beats[1],q_beats[2]);if(wc_rlast[pp])q_active[pp]<=0;
        end
      end
      if(pilot && q_beats[0]>=1024 && q_beats[1]>=1024 && q_beats[2]>=128)begin
        if(fa_slot_state[0]!=2 || fa_physical_half_commits!=256 || fa_physical_scale_commits!=128)$fatal(1,"WI pilot A publication lost");
        $display("WI_RESIDENT_PILOT_PASS cycle=%0d physical_A_halves=%0d physical_A_scales=%0d W_q0_R=%0d W_q1_R=%0d W_scale_R=%0d W_ready=NOT_RUN PS=NOT_RUN output_B=NOT_RUN",cycle,fa_physical_half_commits,fa_physical_scale_commits,q_beats[0],q_beats[1],q_beats[2]);
        measurement_report("pilot");$finish;
      end
      if(wc_aux_arvalid && wc_aux_arready)begin
        if(aux_active || wc_aux_araddr!=wc_load_aux_base+aux_bytes || wc_aux_arsize!=4 || wc_aux_arburst!=1)$fatal(1,"resident physical AUX AR");
        aux_active<=1;aux_index<=aux_bytes/16;aux_left<=int'(wc_aux_arlen)+1;aux_bytes<=aux_bytes+(int'(wc_aux_arlen)+1)*16;
      end
      if(wc_aux_rvalid && wc_aux_rready)begin aux_index<=aux_index+1;aux_left<=aux_left-1;if(wc_aux_rlast)aux_active<=0;end
      if(a_ret_valid && a_ret_ready && dut.state==5)begin
        if(a_ret_group!=a_checks || a_ret_row_block_base!=0 || a_ret_rows!=4 || a_ret_numeric_identity!==cfg_numeric_identity || a_ret_linear_context!==cfg_linear_context)$fatal(1,"resident full A return identity");
        for(int r=0;r<4;r++)if(a_ret_q[r]!==aq[r*32+int'(a_ret_group)] || a_ret_scale[r]!==asc[r*32+int'(a_ret_group)])$fatal(1,"resident full A actual bank q/scale");
        a_checks++;
      end
      if(w_ret_valid && w_ret_ready && dut.state==6)begin
        seq=w_checks;g=seq/656;t=seq%656;
        if(w_ret_q[0]!==vw[seq] || w_ret_tile!=t || w_ret_group!=g || w_ret_model_identity!==cfg_w_model_identity || w_ret_numeric_identity!==cfg_numeric_identity || w_ret_task_context!==cfg_linear_context || w_ret_mask[0]!=8'hff)$fatal(1,"resident full W actual bank return seq=%0d tile=%0d group=%0d",seq,w_ret_tile,w_ret_group);
        w_checks++;
      end
      for(int r=0;r<4;r++)if(dut.commit_valid[r] && dut.commit_ready[r])begin
        seq=int'(dut.commit_tag[r*192+36+:27]);
        if(seq!=ps_checks[r] || dut.commit_bad[r*8+:8]!=0 || dut.commit_ps[r*256+:256]!==vps[seq][r*256+:256])$fatal(1,"resident PS independent gold row=%0d seq=%0d",r,seq);
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
        if(aw_addr<cfg_region_base[0] || aw_addr>=cfg_region_base[0]+83968 || aw_addr[5:0]!=0)$fatal(1,"resident physical output address");
        idx=int'((aw_addr-cfg_region_base[0])/4);
        for(int lane=0;lane<16;lane++)begin
          if(wd_strb[lane*4+:4]!=0 && wd_strb[lane*4+:4]!=4'hf)$fatal(1,"resident output word strobe");
          if(wd_strb[lane*4+:4]==4'hf)begin
            if(idx+lane>=20992 || output_seen[idx+lane] || wd_data[lane*32+:32]!==outgold[idx+lane])$fatal(1,"resident final output gold index=%0d got=%h gold=%h",idx+lane,wd_data[lane*32+:32],outgold[idx+lane]);
            output_seen[idx+lane]=1;output_words++;
          end
        end
        output_beats++;stored=1;bdelay=17+(output_beats%3);
      end
      if(m_axi_bvalid[0] && m_axi_bready[0])begin m_axi_bvalid[0]<=0;aw_seen=0;w_seen=0;stored=0;bretired++;end
      if((owner_retire_valid || done_valid || ledger_parent_publications!=0) &&
         (aw_seen || w_seen || bdelay!=0 || m_axi_bvalid[0] || output_words!=20992 || bretired!=output_beats))$fatal(1,"resident published before actual last B/debt zero");
      if(dut.protocol_fault || dut.numeric_fault || dut.front_protocol || dut.adapter_protocol || dut.bias_protocol || dut.bias_numerical || (|dut.writer_fault))$fatal(1,"resident normal fault state=%0d front=%b adapter=%b bias=%b writers=%b stripes=%0d",dut.state,dut.front_protocol,dut.adapter_protocol,dut.bias_protocol,dut.writer_fault,actual_stripes);
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
    wc_load_valid=0;
    wc_load_weight_key=0;

    for(int r=0;r<4;r++)ps_checks[r]=0;for(int i=0;i<20992;i++)output_seen[i]=0;
    for(int st=0;st<13;st++)measure_state[st]=0;
    for(int pp=0;pp<3;pp++)begin measure_w_ar_wait[pp]=0;measure_w_r_gap[pp]=0;measure_w_r_blocked[pp]=0;end
    if(!$value$plusargs("AFIXTURE=%s",afixture) || !$value$plusargs("WFIXTURE=%s",wfixture) || !$value$plusargs("STREAMS=%s",streams))$fatal(1,"resident input fixture arguments");
    pilot=$test$plusargs("PILOT");
    if(!$value$plusargs("EXPECTED_OUTPUT_BEATS=%d",expected_output_beats))expected_output_beats=1312;
    if(expected_output_beats!=1312)$fatal(1,"Wi declared physical beat coverage");
    $readmemh({afixture,"/q.mem"},aq);$readmemh({afixture,"/scale.mem"},asc);$readmemh({afixture,"/output.mem"},outgold);
    $readmemh({wfixture,"/model_identity.hex"},model);$readmemh({wfixture,"/expected_aux_header.hex"},header);$readmemh({wfixture,"/aux_header.hex"},auxwords);$readmemh({wfixture,"/wi_config.hex"},config_words);
    $readmemh({wfixture,"/wi_q0.hex"},wq0);$readmemh({wfixture,"/wi_q1.hex"},wq1);$readmemh({wfixture,"/wi_scale.hex"},wsc);
    $readmemh({streams,"/w8.mem"},vw);$readmemh({streams,"/ps.mem"},vps);
    cfg_K=1024;cfg_N=5248;cfg_rows=4;cfg_row_block_base=0;cfg_numeric_identity=0;
    cfg_numeric_identity[63:0]=64'h100000001;cfg_numeric_identity[127:64]=64'h200000001;cfg_numeric_identity[143:128]=2;cfg_numeric_identity[159:144]=128;cfg_numeric_identity[671:160]=model[0][511:0];
    cfg_linear_context=0;cfg_linear_context[31:0]=32'hac000003;cfg_linear_context[39:32]=8'h32;cfg_linear_context[47:40]=2;cfg_linear_context[87:72]=0;cfg_linear_context[95:88]=4;
    cfg_source_ref=64'h0000000200000001;cfg_a_ref=64'h0000002200000001;cfg_w_ref=64'h0000002300000001;cfg_ps_ref=64'h0000002400000001;cfg_dst_ref=64'h0000000600000001;
    cfg_w_model_identity=model[0];cfg_a_slot=0;cfg_w_slot=0;cfg_a_epoch=1;cfg_w_epoch=1;cfg_weight_key=3;cfg_bias_kind=0;
    cfg_bo_base[0]=64'h100000000;cfg_bo_span[0]=64'h2000000;cfg_region_base[0]=cfg_bo_base[0]+4096;cfg_region_span[0]=64'h1000000;cfg_row_stride_bytes=20992;cfg_batch_stride_bytes=21495808;
    repeat(6)tick();@(negedge clk);rst_n=1;repeat(16)tick();
    @(negedge clk);
    fa_fill_owner_admitted=1;fa_fill_source_published=1;fa_fill_slot=0;fa_fill_slot_epoch=1;fa_fill_K=1024;fa_fill_rows=4;fa_fill_numeric_identity=cfg_numeric_identity;fa_fill_producer_context=cfg_linear_context;fa_fill_producer_context[39:32]=8'h60;fa_fill_producer_context[31:0]=32'hac000001;
    fa_fill_quant_context=cfg_linear_context;fa_fill_quant_context[39:32]=8'h61;fa_fill_quant_context[31:0]=32'hac000002;fa_fill_linear_context=cfg_linear_context;fa_fill_source_ref=cfg_source_ref;fa_fill_a_ref=cfg_a_ref;fa_fill_w_ref=cfg_w_ref;fa_fill_dst_ref=cfg_dst_ref;
    fa_fill_valid=1;tick();if(fa_fill_reject)$fatal(1,"physical A fixture fill rejected");@(negedge clk);fa_fill_valid=0;
    for(int r=0;r<4;r++)begin
      for(int g=0;g<32;g++)for(int h=0;h<2;h++)begin
        @(negedge clk);fa_commit_valid=1;fa_commit_numeric_identity=cfg_numeric_identity;fa_commit_quant_context=fa_fill_quant_context;fa_commit_a_ref=cfg_a_ref;fa_commit_row=4'(r);fa_commit_group=7'(g);fa_commit_half=1'(h);fa_commit_q=aq[r*32+g][h*128+:128];fa_commit_scale=h?asc[r*32+g]:16'd0;
        @(posedge clk);while(!fa_commit_ready)@(posedge clk);#1;if(fa_commit_error)$fatal(1,"physical A fixture group commit");
      end
      @(negedge clk);fa_commit_valid=0;fa_row_done_valid=1;fa_row_done_row=4'(r);fa_row_done_status=0;fa_row_done_bad_col=0;fa_row_done_debt_zero=1;tick();@(negedge clk);fa_row_done_valid=0;
    end
    @(negedge clk);fa_finish_valid=1;fa_finish_debt_zero=1;tick();if(!fa_fill_done || fa_fill_error || !fa_publish_valid || fa_slot_state[0]!=2 || fa_physical_half_commits!=256 || fa_physical_scale_commits!=128)$fatal(1,"actual complete A publication");@(negedge clk);fa_finish_valid=0;
    measure_a_publish=cycle;
    $display("MATRIX_PROGRESS cycle=%0d physical_A_published=1 halves=%0d scales=%0d",cycle,fa_physical_half_commits,fa_physical_scale_commits);
    wc_load_slot=0;wc_load_epoch=1;wc_load_k=1024;wc_load_n=5248;wc_load_weight_key=3;wc_load_model_identity=model[0];wc_load_expected_aux_header=header[0];wc_load_aux_base=64'h400000000;wc_load_bias_base=0;wc_load_bias_bytes=0;
    for(int pp=0;pp<3;pp++)begin wc_load_base[pp]=64'h500000000+64'(pp)*64'h10000000+config_words[3+pp];wc_load_bytes[pp]=32'(config_words[6+pp]);end
    @(negedge clk);wc_load_valid=1;@(posedge clk);while(!wc_load_ready)@(posedge clk);#1;@(negedge clk);wc_load_valid=0;
    while(!wc_load_done)tick();if(wc_load_error || wc_load_reject || wc_slot_state[0]!=2 || wc_load_scale_checks!=167936)$fatal(1,"resident physical W strict load checks=%0d error=%b reject=%b state=%0d",wc_load_scale_checks,wc_load_error,wc_load_reject,wc_slot_state[0]);
    for(int pp=0;pp<3;pp++)if(q_active[pp] || q_beats[pp]*64!=wc_load_bytes[pp])$fatal(1,"actual W final R coverage");
    measure_w_publish=cycle;
    $display("MATRIX_PROGRESS cycle=%0d physical_W_published=1 W_R=%0d,%0d,%0d scale_checks=%0d",cycle,q_beats[0],q_beats[1],q_beats[2],wc_load_scale_checks);
    @(negedge clk);cfg_valid=1;#1;if(!cfg_ready || !ledger_claim_ready || !cfg_owner_admitted)$fatal(1,"matrix owner claim not admitted");tick();if(cfg_reject || ledger_claim_reject)$fatal(1,"resident command rejected");@(negedge clk);cfg_valid=0;
    if(pilot)begin
      while(ps_checks[0]<256 || ps_checks[1]<256 || ps_checks[2]<256 || ps_checks[3]<256)tick();
      measurement_report("pilot");
      $display("WI_RESIDENT_PILOT_PASS cycles=%0d physical_A_half_commits=%0d physical_W_R=%0d A_reads=%0d W_reads=%0d real_stripes=%0d actual_PS_gold_checks=%0d output_final_B=NOT_RUN",cycle,fa_physical_half_commits,q_beats[0]+q_beats[1]+q_beats[2],a_checks,w_checks,actual_stripes,ps_checks[0]+ps_checks[1]+ps_checks[2]+ps_checks[3]);$finish;
    end
    while(!done_valid)tick();
    if(done_status!=0 || actual_stripes!=20992 || actual_ps_commits!=83968 || actual_final_copies!=2624 || a_checks!=32 || w_checks!=20992 || output_words!=20992 || actual_a_reads!=32 || actual_a_returns!=32 || actual_w_reads!=20992 || actual_w_returns!=20992 || ledger_ps_state!=2 || ledger_dst_state!=2 || ledger_checked_rows!=16'hf || ledger_covered_rows!=16'hf || ledger_parent_publications!=1 || fa_slot_state[0]!=0 || wc_slot_readers[0]!=0 || wc_slot_state[0]!=2)$fatal(1,"resident final closure status=%0d stripes=%0d ps=%0d copies=%0d A=%0d W=%0d output=%0d ledger=%0d/%0d",done_status,actual_stripes,actual_ps_commits,actual_final_copies,a_checks,w_checks,output_words,ledger_ps_state,ledger_dst_state);
    for(int r=0;r<4;r++)if(ps_checks[r]!=20992)$fatal(1,"resident full PS coverage");
    repeat(7)begin tick();if(!done_valid || ledger_dst_state!=2)$fatal(1,"resident held response");end
    measure_legacy_hold_end=cycle;
    // Preserve the seven held cycles above, then consume once at a real edge.
    @(negedge clk);done_ready=1;tick();
    if(measure_consumes!=1 || done_valid || dut.state!=0 || ledger_dst_state!=2 ||
       ledger_parent_publications!=1 || !ledger_retire_debt_zero)
      $fatal(1,"Down response consume/deassert/debt closure");
    @(negedge clk);done_ready=0;tick();
    if(done_valid || measure_consumes!=1 || ledger_dst_state!=2 || ledger_parent_publications!=1)
      $fatal(1,"Down response after consume");
    measurement_report("full");
    $display("WI_RESIDENT_FULL_PASS rows=4 K=1024 N=5248 real_stripes=%0d PS_lane_groups=671744 final_packets=%0d real_output_words=%0d actual_AW=%0d actual_W=%0d actual_B=%0d held_B=%0d full_A_physical=1 W_strict_physical=1 A_fixture_prequantized=1 final_B_publication=1 local_owner_ledger=1 cycles=%0d",actual_stripes,actual_final_copies,output_words,actual_aw_count[0],actual_w_count[0],actual_b_count[0],held_b,cycle);$finish;
  end
endmodule
