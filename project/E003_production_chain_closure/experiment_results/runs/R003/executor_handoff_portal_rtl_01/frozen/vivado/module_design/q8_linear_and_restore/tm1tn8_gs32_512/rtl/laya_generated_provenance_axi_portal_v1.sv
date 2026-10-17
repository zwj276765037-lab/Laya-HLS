`timescale 1ns/1ps
// First physical integration of the persistent provenance portal with one
// protected generated AXI512 write port.  The role/base are supplied by the
// outer 13-BO owner domain; the original Host ABI is unchanged.
module laya_generated_provenance_axi_portal_v1 #(
  parameter int MONITORED_ROLE=6,
  parameter bit ENABLE_BOOTSTRAP_SNAPSHOT=0,
  parameter bit ENABLE_BOOTSTRAP_SOURCE_GUARD=0,
  parameter bit ENABLE_EXECUTOR_CHECKPOINT=0,
  // The external full-key shell owns start/grant/rearm. In this mode the
  // transport's completed query selects a route only; it is not authority.
  parameter bit MANAGED_EXECUTOR_HANDOFF=0
) (
  input  logic clk,rst_n,cancel,
  input  logic [511:0] provenance_cmd_din,
  input  logic provenance_cmd_write,
  output logic provenance_cmd_full_n,
  output logic [511:0] provenance_rsp_dout,
  output logic provenance_rsp_empty_n,
  input  logic provenance_rsp_read,
  // Internal v2 diagnostic transport and successor dispatch to the same LPV FIFO.
  input logic [511:0] checkpoint_command_din,
  input logic checkpoint_command_write,
  output logic checkpoint_command_full_n,
  output logic [511:0] checkpoint_response_dout,
  output logic checkpoint_response_empty_n,
  input logic checkpoint_response_read,
  input logic [511:0] executor_provenance_cmd_din,
  input logic executor_provenance_cmd_write,
  output logic executor_provenance_cmd_full_n,
  output logic checkpoint_dispatch_held,checkpoint_handoff_complete,
  output logic checkpoint_handoff_pulse,checkpoint_authority_valid,
  output logic checkpoint_protocol_error,
  output logic [31:0] checkpoint_accepted_queries,checkpoint_consumed_responses,
  output logic [63:0] checkpoint_sequence_high_water,checkpoint_handoff_high_water,
  output logic [1:0] checkpoint_command_occupancy,checkpoint_response_occupancy,
  input  logic [63:0] monitored_bo_base,
  input  logic adapter_pending_zero,
  input  logic source_query_valid,
  output logic source_query_ready,
  input  logic [8191:0] source_query_command,
  output logic source_query_granted,
  input  logic source_release_valid,
  output logic source_release_ready,
  input  logic [8191:0] source_release_command,
  input  logic source_release_drained,
  output logic source_lease_active,
  // Read-only successful BEGIN snapshot; publication authority remains in hub.
  output logic [8191:0] accepted_begin_packet,
  input logic snapshot_request_valid,
  output logic snapshot_request_ready,
  input logic [6143:0] snapshot_request,
  output logic snapshot_response_valid,
  input logic snapshot_response_ready,
  output logic [6143:0] snapshot_response,
  input logic snapshot_base_valid,
  input logic [63:0] snapshot_base_epoch,snapshot_base_address,snapshot_base_capacity,
  output logic [63:0] snapshot_sequence_high_water,
  input logic bootstrap_source_guard_active,
  input logic [6143:0] bootstrap_source_guard_key,
  output logic bootstrap_source_guard_match,
  output logic bootstrap_physical_safe,

  input  logic [63:0] s_axi_awaddr,
  input  logic [7:0] s_axi_awlen,
  input  logic [2:0] s_axi_awsize,
  input  logic [1:0] s_axi_awburst,
  input  logic s_axi_awvalid,
  output logic s_axi_awready,
  input  logic [511:0] s_axi_wdata,
  input  logic [63:0] s_axi_wstrb,
  input  logic s_axi_wlast,
  input  logic s_axi_wvalid,
  output logic s_axi_wready,
  output logic [1:0] s_axi_bresp,
  output logic s_axi_bvalid,
  input  logic s_axi_bready,

  output logic [63:0] m_axi_awaddr,
  output logic [7:0] m_axi_awlen,
  output logic [2:0] m_axi_awsize,
  output logic [1:0] m_axi_awburst,
  output logic m_axi_awvalid,
  input  logic m_axi_awready,
  output logic [511:0] m_axi_wdata,
  output logic [63:0] m_axi_wstrb,
  output logic m_axi_wlast,
  output logic m_axi_wvalid,
  input  logic m_axi_wready,
  input  logic [1:0] m_axi_bresp,
  input  logic m_axi_bvalid,
  output logic m_axi_bready,

  output logic transport_busy,cancel_pending,protocol_error,
  output logic scope_active,domain_drained,monitor_scope_active,
  output logic monitor_drained,monitor_coverage_complete,
  output logic [15:0] monitor_status,
  output logic [63:0] monitor_observed0,monitor_observed1,
  output logic [63:0] last_event_seq,
  output logic [5:0] active_owners,published_owners,
  output logic [31:0] accepted_requests,retired_responses,
  output logic [31:0] accepted_events,semantic_rejections,terminal_tasks,
  output logic [31:0] forwarded_aw,forwarded_w,retired_b,
  output logic [31:0] rejected_transactions,
  output logic [1:0] command_fifo_occupancy,response_fifo_occupancy
);
  import laya_generated_provenance_layout_v1::*;
  logic request_valid,request_ready,service_cancel;
  logic [8191:0] request,accepted_request;
  logic response_valid,response_ready;
  logic [4095:0] response;
  logic transport_protocol_error,hub_cancel_pending;
  logic physical_observation_valid,physical_observation_ready;
  logic [15:0] physical_status;
  logic [31:0] physical_error_detail,monitor_error_detail;
  logic [63:0] physical_bad_element,monitor_bad_element;
  logic [63:0] physical_observed0,physical_observed1;
  logic physical_drained,physical_coverage_complete;
  logic begin_valid,begin_ready,begin_supported,end_commit;
  logic begin_reserved,begin_block;
  logic owner_coverage_complete,monitor_protocol_error;
  logic end_issued_bytes_observed;
  logic [15:0] request_action;

  assign request_action=request[ACTION*8+:16];
  // END may reach the private FIFO while stores accepted by HLS are still
  // emerging at the AXI pins.  Do not present a drain observation to the hub
  // until the physical WSTRB count has caught up with END's issued-byte
  // commitment.  AW/W/B debt and adapter_pending_zero remain independent
  // requirements in monitor_drained.
  assign end_issued_bytes_observed=
      monitor_observed0==request[ISSUED0*8+:64] &&
      monitor_observed1==request[ISSUED1*8+:64];
  assign physical_observation_valid=request_valid &&
      ((request_action==END_EVENT && monitor_scope_active && monitor_drained &&
        end_issued_bytes_observed) ||
       (request_action==PUBLISH && !monitor_scope_active && monitor_drained) ||
       ((request_action==RELEASE || request_action==INVALIDATE) &&
        !monitor_scope_active && monitor_drained));
  assign physical_status=request_action==END_EVENT ? monitor_status : 0;
  assign physical_error_detail=request_action==END_EVENT ? monitor_error_detail : 0;
  assign physical_bad_element=request_action==END_EVENT ? monitor_bad_element :
                                  64'hffffffffffffffff;
  assign physical_observed0=request_action==END_EVENT ? monitor_observed0 : 0;
  assign physical_observed1=request_action==END_EVENT ? monitor_observed1 : 0;
  assign physical_drained=monitor_drained;
  assign physical_coverage_complete=request_action==END_EVENT ?
      monitor_coverage_complete : request_action==PUBLISH ?
      owner_coverage_complete : 1'b1;
  assign protocol_error=transport_protocol_error || monitor_protocol_error;
  assign begin_block=begin_reserved ||
      (request_valid && request_action==BEGIN_EVENT);

  logic [511:0] selected_cmd;
  logic selected_write,selected_full_n;
  logic checkpoint_request_valid,checkpoint_request_ready;
  logic [8191:0] checkpoint_request,checkpoint_response;
  logic checkpoint_response_valid,checkpoint_response_ready;
  logic checkpoint_exclusion;
  logic checkpoint_base_seen,checkpoint_base_history_complete;
  logic [63:0] checkpoint_history_epoch,checkpoint_history_address,checkpoint_history_capacity;
  // Historical Ref equivalence is meaningful only within this locked base.
  // A lifecycle change after any predecessor ingress cannot reuse old arrays.
  always_ff @(posedge clk)begin
    if(!rst_n)begin
      checkpoint_base_seen<=0;checkpoint_base_history_complete<=0;
      checkpoint_history_epoch<=0;checkpoint_history_address<=0;checkpoint_history_capacity<=0;
    end else if(ENABLE_EXECUTOR_CHECKPOINT)begin
      if(!checkpoint_base_seen && provenance_cmd_write && provenance_cmd_full_n)begin
        checkpoint_base_seen<=1;
        checkpoint_base_history_complete<=snapshot_base_valid && snapshot_base_address==monitored_bo_base;
        checkpoint_history_epoch<=snapshot_base_epoch;
        checkpoint_history_address<=snapshot_base_address;
        checkpoint_history_capacity<=snapshot_base_capacity;
      end
      if(checkpoint_base_seen &&
         (!snapshot_base_valid || snapshot_base_epoch!=checkpoint_history_epoch ||
          snapshot_base_address!=checkpoint_history_address || snapshot_base_capacity!=checkpoint_history_capacity ||
          monitored_bo_base!=checkpoint_history_address))checkpoint_base_history_complete<=0;
    end
  end
  assign checkpoint_exclusion=ENABLE_EXECUTOR_CHECKPOINT &&
    checkpoint_dispatch_held && !(MANAGED_EXECUTOR_HANDOFF ?
      checkpoint_handoff_complete : checkpoint_authority_valid);
  assign selected_cmd=ENABLE_EXECUTOR_CHECKPOINT && checkpoint_dispatch_held ?
    executor_provenance_cmd_din : provenance_cmd_din;
  assign selected_write=ENABLE_EXECUTOR_CHECKPOINT && checkpoint_dispatch_held ?
    executor_provenance_cmd_write && (MANAGED_EXECUTOR_HANDOFF ?
      checkpoint_handoff_complete : checkpoint_authority_valid) : provenance_cmd_write;
  assign provenance_cmd_full_n=selected_full_n &&
    (!ENABLE_EXECUTOR_CHECKPOINT || !checkpoint_dispatch_held);
  assign executor_provenance_cmd_full_n=ENABLE_EXECUTOR_CHECKPOINT &&
    (MANAGED_EXECUTOR_HANDOFF ? checkpoint_handoff_complete : checkpoint_authority_valid) && selected_full_n;
  generate if(ENABLE_EXECUTOR_CHECKPOINT)begin : checkpoint_enabled
    laya_executor_checkpoint_transport_v2 checkpoint_transport(
      .clk,.rst_n,.cancel,.command_din(checkpoint_command_din),
      .command_write(checkpoint_command_write),.command_full_n(checkpoint_command_full_n),
      .response_dout(checkpoint_response_dout),.response_empty_n(checkpoint_response_empty_n),
      .response_read(checkpoint_response_read),.request_valid(checkpoint_request_valid),
      .request_ready(checkpoint_request_ready),.request(checkpoint_request),
      .hub_response_valid(checkpoint_response_valid),
      .hub_response_ready(checkpoint_response_ready),.hub_response(checkpoint_response),
      // Do not acquire on the same edge as any new predecessor FIFO write.
      // Old half-frames/END/response/final-B all retain their original progress.
      .acquisition_safe(bootstrap_physical_safe && command_fifo_occupancy==0 &&
                        response_fifo_occupancy==0 && !provenance_cmd_write),
      .base_valid(snapshot_base_valid && checkpoint_base_history_complete &&
                  monitored_bo_base==snapshot_base_address),.base_epoch(snapshot_base_epoch),
      .base_address(snapshot_base_address),.base_capacity(snapshot_base_capacity),
      .dispatch_held(checkpoint_dispatch_held),.handoff_complete(checkpoint_handoff_complete),
      .handoff_pulse(checkpoint_handoff_pulse),.authority_valid(checkpoint_authority_valid),
      .protocol_error(checkpoint_protocol_error),
      .accepted_queries(checkpoint_accepted_queries),.consumed_responses(checkpoint_consumed_responses),
      .command_occupancy(checkpoint_command_occupancy),.response_occupancy(checkpoint_response_occupancy));
  end else begin : checkpoint_disabled
    assign checkpoint_command_full_n=0;
    assign checkpoint_response_dout=0;assign checkpoint_response_empty_n=0;
    assign checkpoint_dispatch_held=0;assign checkpoint_handoff_complete=0;
    assign checkpoint_handoff_pulse=0;assign checkpoint_authority_valid=0;
    assign checkpoint_protocol_error=0;
    assign checkpoint_accepted_queries=0;assign checkpoint_consumed_responses=0;
    assign checkpoint_command_occupancy=0;assign checkpoint_response_occupancy=0;
    assign checkpoint_request_valid=0;assign checkpoint_request=0;
    assign checkpoint_response_ready=0;
  end endgenerate

  laya_generated_provenance_v1 transport(
    .clk,.rst_n,.cancel,
    .provenance_cmd_din(selected_cmd),.provenance_cmd_write(selected_write),
    .provenance_cmd_full_n(selected_full_n),
    .provenance_rsp_dout,.provenance_rsp_empty_n,.provenance_rsp_read,
    .service_request_valid(request_valid),.service_request_ready(request_ready),
    .service_request(request),.service_cancel,
    .service_response_valid(response_valid),
    .service_response_ready(response_ready),.service_response(response),
    .service_scope_active(scope_active),.service_domain_drained(domain_drained),
    .busy(transport_busy),.cancel_pending,.protocol_error(transport_protocol_error),
    .last_event_seq,.accepted_requests,.retired_responses,
    .command_fifo_occupancy,.response_fifo_occupancy
  );

  // Exclusion/cancel ownership is not part of this fence: it is held until
  // the fence plus real action consumption permit release. No circular wait.
  assign bootstrap_physical_safe=!transport_busy && !request_valid &&
      !response_valid && !scope_active && !monitor_scope_active &&
      monitor_drained && adapter_pending_zero && !source_lease_active &&
      !protocol_error;

  laya_generated_provenance_hub_v1 #(
    .ENABLE_BOOTSTRAP_SNAPSHOT(ENABLE_BOOTSTRAP_SNAPSHOT),
    .ENABLE_BOOTSTRAP_SOURCE_GUARD(ENABLE_BOOTSTRAP_SOURCE_GUARD),
    .ENABLE_EXECUTOR_CHECKPOINT(ENABLE_EXECUTOR_CHECKPOINT)) hub(
    .clk,.rst_n,.request_valid,.request_ready,.request,
    .cancel(service_cancel),
    .begin_external_ready(begin_ready),
    .begin_external_supported(begin_supported),
    .physical_observation_valid,.physical_observation_ready,
    .physical_status,.physical_error_detail,.physical_bad_element,
    .physical_observed_store_bytes0(physical_observed0),
    .physical_observed_store_bytes1(physical_observed1),
    .physical_drained,.physical_coverage_complete,
    .source_query_valid(source_query_valid &&
                        (!ENABLE_EXECUTOR_CHECKPOINT || !checkpoint_dispatch_held ||
                         (MANAGED_EXECUTOR_HANDOFF && checkpoint_handoff_complete))),
    .source_query_ready,.source_query_command,
    .source_query_granted,.source_release_valid,.source_release_ready,
    .source_release_command,.source_release_drained,.source_lease_active,
    .snapshot_request_valid,.snapshot_request_ready,.snapshot_request,
    .snapshot_response_valid,.snapshot_response_ready,.snapshot_response,
    .snapshot_physical_quiescent(bootstrap_physical_safe),.snapshot_base_valid,
    .snapshot_base_epoch,.snapshot_base_address,.snapshot_base_capacity,
    .snapshot_sequence_high_water,
    .checkpoint_request_valid,.checkpoint_request_ready,.checkpoint_request,
    .checkpoint_response_valid,.checkpoint_response_ready,.checkpoint_response,
    .checkpoint_dispatch_held(checkpoint_exclusion),
    .checkpoint_physical_quiescent(bootstrap_physical_safe && checkpoint_base_seen &&
                                   checkpoint_base_history_complete),
    .checkpoint_lpv_floor(last_event_seq),
    .checkpoint_sequence_high_water,.checkpoint_handoff_high_water,
    .bootstrap_source_guard_active,
    .bootstrap_source_guard_key,.bootstrap_source_guard_match,
    .response_valid,.response_ready,.response,
    .scope_active,.domain_drained,.cancel_pending(hub_cancel_pending),
    .active_owners,.published_owners,
    .accepted_events,.semantic_rejections,.terminal_tasks
  );

  assign begin_valid=response_valid && response_ready &&
      response[ACTION*8+:16]==BEGIN_EVENT &&
      response[RESPONSE_STATUS*8+:16]==0;
  assign end_commit=response_valid && response_ready &&
      response[ACTION*8+:16]==END_EVENT &&
      !response[RESPONSE_FLAGS*8+1];

  laya_generated_store_monitor_v1 #(.MONITORED_ROLE(MONITORED_ROLE)) monitor(
    .clk,.rst_n,.cancel,.begin_valid,.begin_ready,.begin_block,
    .candidate_packet(request),.begin_packet(accepted_request),
    .bo_base(monitored_bo_base),.end_commit,
    .adapter_pending_zero,.begin_supported,
    .scope_active(monitor_scope_active),.physical_drained(monitor_drained),
    .coverage_complete(monitor_coverage_complete),
    .physical_status(monitor_status),
    .physical_error_detail(monitor_error_detail),
    .physical_bad_element(monitor_bad_element),
    .observed_store_bytes0(monitor_observed0),
    .observed_store_bytes1(monitor_observed1),
    .forwarded_aw,.forwarded_w,.retired_b,.rejected_transactions,
    .s_axi_awaddr,.s_axi_awlen,.s_axi_awsize,.s_axi_awburst,
    .s_axi_awvalid,.s_axi_awready,.s_axi_wdata,.s_axi_wstrb,.s_axi_wlast,
    .s_axi_wvalid,.s_axi_wready,.s_axi_bresp,.s_axi_bvalid,.s_axi_bready,
    .m_axi_awaddr,.m_axi_awlen,.m_axi_awsize,.m_axi_awburst,
    .m_axi_awvalid,.m_axi_awready,.m_axi_wdata,.m_axi_wstrb,.m_axi_wlast,
    .m_axi_wvalid,.m_axi_wready,.m_axi_bresp,.m_axi_bvalid,.m_axi_bready
  );

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      accepted_request<=0;accepted_begin_packet<=0;owner_coverage_complete<=0;
      monitor_protocol_error<=0;begin_reserved<=0;
    end else begin
      if(request_valid && request_ready)begin
        accepted_request<=request;
        if(request_action==BEGIN_EVENT)begin_reserved<=1;
      end
      if(response_valid && response_ready &&
         response[ACTION*8+:16]==BEGIN_EVENT)
        begin_reserved<=0;
      if(begin_valid)accepted_begin_packet<=accepted_request;
      if(begin_valid && !begin_ready)
        monitor_protocol_error<=1;
      if(response_valid && response_ready)begin
        if(response[ACTION*8+:16]==CLAIM &&
           response[RESPONSE_STATUS*8+:16]==0)
          owner_coverage_complete<=0;
        if(response[ACTION*8+:16]==END_EVENT &&
           !response[RESPONSE_FLAGS*8+1])
          owner_coverage_complete<=response[RESPONSE_STATUS*8+:16]==0;
        if((response[ACTION*8+:16]==RELEASE ||
            response[ACTION*8+:16]==INVALIDATE) &&
           response[RESPONSE_STATUS*8+:16]==0)
          owner_coverage_complete<=0;
      end
    end
  end
endmodule
