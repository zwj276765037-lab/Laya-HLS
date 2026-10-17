`timescale 1ns/1ps

// One physical GATE writer backed by the persistent v2 tensor ledger. A GEGLU
// window returns after its real last B and ledger retirement. Tensor READY is
// independent and appears only after every planned window has retired.
module geglu_gate_tensor_store_v2(
  input logic clk,rst_n,cancel,
  input logic claim_valid,
  output logic claim_ready,claim_admitted,claim_rejected,
  input logic claim_plan_admitted,
  input logic [671:0] claim_numeric_identity,
  input logic [95:0] claim_producer_context,claim_quant_context,claim_linear_context,
  input logic [63:0] claim_source_ref,claim_gate_ref,claim_a_ref,claim_w_ref,claim_ps_ref,claim_dst_ref,
  input logic [7:0] claim_gate_region,claim_dst_region,
  input logic [327:0] claim_output_binding,
  input logic [63:0] claim_bo_base,claim_bo_span,claim_region_base,claim_region_span,
  input logic row_success,
  input logic [15:0] row_success_row,
  input logic v_valid,
  output logic v_ready,
  input logic [31:0] v_data,v_status,v_frame_tag,
  input logic [15:0] v_row,
  input logic [12:0] v_col,
  input logic v_last,
  output logic row_write_done_valid,
  input logic row_write_done_ready,
  output logic [31:0] row_write_status,row_write_task_id,row_write_dst_epoch,
  output logic [15:0] row_write_row,
  output logic [63:0] row_write_bad_element,
  output logic row_write_debt_zero,
  input logic service_done_valid,
  output logic service_done_ready,
  input logic [31:0] service_done_status,
  input logic [63:0] service_done_bad_element,
  input logic service_read_debt_zero,service_arithmetic_debt_zero,
  output logic producer_done_valid,
  input logic producer_done_ready,
  output logic [31:0] producer_done_status,producer_done_task_id,producer_done_dst_epoch,
  output logic [63:0] producer_done_bad_element,
  output logic [15:0] producer_done_covered_rows,
  output logic producer_done_write_debt_zero,
  output logic tensor_published,cancel_done,writer_busy,
  output logic [2:0] gate_owner_state,
  output logic [7:0] next_window,
  output logic [127:0] valid_windows,covered_windows,consumed_windows,
  output logic [2047:0] covered_rows,
  input logic gate_acquire_valid,
  output logic gate_acquire_ready,gate_acquire_done,gate_acquire_error,
  input logic [671:0] gate_acquire_numeric_identity,
  input logic [63:0] gate_acquire_ref,
  input logic [6:0] gate_acquire_window,
  input logic [551:0] gate_acquire_binding,
  input logic gate_release_valid,
  output logic gate_release_ready,gate_release_done,gate_release_error,
  input logic [671:0] gate_release_numeric_identity,
  input logic [63:0] gate_release_ref,
  input logic [6:0] gate_release_window,
  input logic [551:0] gate_release_binding,
  input logic gate_release_read_debt_zero,
  input logic tensor_release_valid,
  output logic tensor_release_ready,tensor_release_done,tensor_release_error,
  input logic [671:0] tensor_release_numeric_identity,
  input logic [63:0] tensor_release_ref,
  input logic tensor_release_debt_zero,
  output logic [31:0] aw_count,w_count,b_count,accepted_words,
  output logic [63:0] useful_bytes,physical_bytes,
  output logic [63:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,
  output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,
  output logic m_axi_awvalid,
  input logic m_axi_awready,
  output logic [511:0] m_axi_wdata,
  output logic [63:0] m_axi_wstrb,
  output logic m_axi_wlast,m_axi_wvalid,
  input logic m_axi_wready,
  input logic [1:0] m_axi_bresp,
  input logic m_axi_bvalid,
  output logic m_axi_bready
);
  logic ledger_claim_valid,ledger_claim_ready,writer_cfg_valid,writer_cfg_ready,writer_cfg_reject;
  logic writer_done_valid,writer_done_ready,writer_done_write_debt_zero;
  logic [31:0] writer_done_status,writer_done_task_id,writer_done_dst_epoch;
  logic [63:0] writer_done_bad_element;
  logic [15:0] writer_done_covered_rows;
  logic window_retire_valid,window_retire_ready,window_retire_error;
  logic cancel_pending;
  wire cancel_active=cancel_pending || cancel;

  assign claim_ready=ledger_claim_ready && writer_cfg_ready && !cancel;
  assign ledger_claim_valid=claim_valid && writer_cfg_ready && !cancel;
  assign writer_cfg_valid=claim_valid && claim_ready && claim_admitted;
  assign producer_done_valid=writer_done_valid && window_retire_ready;
  assign producer_done_status=cancel_active && writer_done_status==0 ? 32'd7 : writer_done_status;
  assign producer_done_task_id=writer_done_task_id;
  assign producer_done_dst_epoch=writer_done_dst_epoch;
  assign producer_done_bad_element=writer_done_bad_element;
  assign producer_done_covered_rows=writer_done_covered_rows;
  assign producer_done_write_debt_zero=writer_done_write_debt_zero;
  assign writer_done_ready=producer_done_ready && window_retire_ready;
  assign window_retire_valid=writer_done_valid && producer_done_ready;

  geglu_gate_window_writer_v2 writer(
    .clk,.rst_n,.cfg_valid(writer_cfg_valid),.cfg_ready(writer_cfg_ready),
    .cfg_reject(writer_cfg_reject),.busy(writer_busy),.cfg_owner_admitted(claim_admitted),
    .cfg_numeric_identity(claim_numeric_identity),.cfg_producer_context(claim_producer_context),
    .cfg_source_ref(claim_source_ref),.cfg_gate_ref(claim_gate_ref),
    .cfg_rows(5'(claim_producer_context[95:88])),.cfg_bo_base(claim_bo_base),
    .cfg_bo_span(claim_bo_span),.cfg_region_base(claim_region_base),
    .cfg_region_span(claim_region_span),.row_success,.row_success_row,.v_valid,.v_ready,
    .v_data,.v_status,.v_frame_tag,.v_row,.v_col,.v_last,.row_write_done_valid,
    .row_write_done_ready,.row_write_status,.row_write_task_id,.row_write_dst_epoch,
    .row_write_row,.row_write_bad_element,.row_write_debt_zero,.service_done_valid,
    .service_done_ready,.service_done_status,.service_done_bad_element,
    .service_read_debt_zero,.service_arithmetic_debt_zero,
    .window_done_valid(writer_done_valid),.window_done_ready(writer_done_ready),
    .window_done_status(writer_done_status),.window_done_task_id(writer_done_task_id),
    .window_done_dst_epoch(writer_done_dst_epoch),
    .window_done_bad_element(writer_done_bad_element),
    .window_done_covered_rows(writer_done_covered_rows),
    .window_done_write_debt_zero(writer_done_write_debt_zero),
    .aw_count,.w_count,.b_count,.accepted_words,.useful_bytes,.physical_bytes,
    .m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,.m_axi_awburst,.m_axi_awvalid,
    .m_axi_awready,.m_axi_wdata,.m_axi_wstrb,.m_axi_wlast,.m_axi_wvalid,
    .m_axi_wready,.m_axi_bresp,.m_axi_bvalid,.m_axi_bready);

  geglu_gate_tensor_ledger_v2 ledger(
    .clk,.rst_n,.cancel,.claim_valid(ledger_claim_valid),.claim_ready(ledger_claim_ready),
    .claim_admitted,.claim_rejected,.claim_plan_admitted,.claim_numeric_identity,
    .claim_producer_context,.claim_quant_context,.claim_linear_context,.claim_source_ref,
    .claim_gate_ref,.claim_a_ref,.claim_w_ref,.claim_ps_ref,.claim_dst_ref,
    .claim_gate_region,.claim_dst_region,.claim_output_binding,.window_retire_valid,
    .window_retire_ready,.window_retire_error,
    .window_retire_success(writer_done_status==0 && !cancel_active),
    .window_write_debt_zero(writer_done_write_debt_zero),.tensor_published,.cancel_done,
    .gate_owner_state,.next_window,.valid_windows,.covered_windows,.consumed_windows,
    .covered_rows,.gate_acquire_valid,.gate_acquire_ready,.gate_acquire_done,
    .gate_acquire_error,.gate_acquire_numeric_identity,.gate_acquire_ref,
    .gate_acquire_window,.gate_acquire_binding,.gate_release_valid,.gate_release_ready,
    .gate_release_done,.gate_release_error,.gate_release_numeric_identity,
    .gate_release_ref,.gate_release_window,.gate_release_binding,
    .gate_release_read_debt_zero,.tensor_release_valid,.tensor_release_ready,
    .tensor_release_done,.tensor_release_error,.tensor_release_numeric_identity,
    .tensor_release_ref,.tensor_release_debt_zero);

  always_ff @(posedge clk)begin
    if(!rst_n)cancel_pending<=0;
    else begin
      if(cancel && writer_busy)cancel_pending<=1;
      if(writer_done_valid && writer_done_ready)cancel_pending<=0;
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    assert(!(writer_cfg_reject && writer_cfg_valid))
      else $fatal(1,"non-atomic GATE tensor writer admission");
    if(producer_done_valid && producer_done_status==0)
      assert(producer_done_write_debt_zero && aw_count==w_count && w_count==b_count)
        else $fatal(1,"GATE producer completed before physical B retirement");
  end
`endif
endmodule
