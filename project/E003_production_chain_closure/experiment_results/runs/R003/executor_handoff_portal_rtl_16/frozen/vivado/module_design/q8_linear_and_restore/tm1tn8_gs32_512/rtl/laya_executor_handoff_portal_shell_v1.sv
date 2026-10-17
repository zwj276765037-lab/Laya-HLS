`timescale 1ns/1ps
// Single STATE0 managed handoff connection. Real FIFO/monitor/hub fences and
// both LPV ingress gates live here, not in a testbench. The wide control ready
// means the complete frame has been accepted by its matching consumer.
// This module does not yet implement request CLOSE/new-admission or source AR.
module laya_executor_handoff_portal_shell_v1 #(
  parameter int MONITORED_ROLE=6,
  parameter bit ENABLE_BOOTSTRAP_SNAPSHOT=0,
  parameter bit ENABLE_BOOTSTRAP_SOURCE_GUARD=0
)(
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
  output logic checkpoint_ingress_started,checkpoint_query_accepted,checkpoint_query_drained,
  output logic [8191:0] checkpoint_query_request,
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
  output logic [1:0] command_fifo_occupancy,response_fifo_occupancy,
  input logic [63:0] current_session,current_request,
  input logic [767:0] current_identity,
  input logic control_valid,
  output logic control_ready,
  input logic [8191:0] control,
  output logic response_valid,
  input logic response_ready,
  output logic [8191:0] response,
  input logic predecessor_done_valid,
  output logic predecessor_done_ready,
  input logic [8191:0] predecessor_done_key,
  output logic stop_predecessor,locks_owned,
  output logic [8191:0] pending_key,
  output logic query_permit,query_ingress_owned,import_pending,
  output logic executor_owns_dispatch,authority_valid,revoked,local_committed,
  output logic [63:0] sequence_high_water,handoff_high_water,
  output logic [31:0] control_rejections,grants,closed_aborts,
  output logic [3:0] phase
);
  logic checkpoint_start_permit,checkpoint_owner_revoked,checkpoint_executor_route;
  logic [8191:0] checkpoint_owner_key,checkpoint_closed_key;
  logic checkpoint_closed_valid,old_channels_drained;
  logic predecessor_ready,executor_ready,writer_awready,writer_wready;
  logic lease_query_ready,lease_query_granted,bootstrap_query_ready;
  logic writer_route,lease_query_route;
  assign checkpoint_start_permit=query_permit && !control_valid;
  assign checkpoint_owner_revoked=revoked;
  assign checkpoint_executor_route=executor_owns_dispatch;
  assign checkpoint_owner_key=pending_key;
  assign checkpoint_closed_key=response;
  assign checkpoint_closed_valid=response_valid && response_ready &&
    response[8*8+:8]==6 && checkpoint_query_drained;
  assign provenance_cmd_full_n=predecessor_ready && !locks_owned;
  assign executor_provenance_cmd_full_n=executor_ready && executor_owns_dispatch;
  // Locks are taken only after the old single writer has truly drained.
  // Revocation retains the active writer route for the old matched work.
  assign writer_route=!locks_owned || executor_owns_dispatch;
  assign s_axi_awready=writer_awready && writer_route;
  assign s_axi_wready=writer_wready && writer_route;
  assign lease_query_route=!locks_owned || authority_valid;
  assign source_query_ready=lease_query_ready && lease_query_route;
  assign source_query_granted=lease_query_granted && lease_query_route;
  assign snapshot_request_ready=bootstrap_query_ready && !locks_owned;
  assign old_channels_drained=bootstrap_physical_safe && !transport_busy &&
    command_fifo_occupancy==0 && response_fifo_occupancy==0 &&
    checkpoint_command_occupancy==0 && checkpoint_response_occupancy==0 &&
    !(provenance_cmd_write && !locks_owned) &&
    !(executor_provenance_cmd_write && executor_owns_dispatch);
  laya_executor_handoff_shell_v1 shell(
    .clk,.rst_n,.cancel,.current_session,.current_request,.current_identity,
    .base_valid(snapshot_base_valid),.base_epoch(snapshot_base_epoch),
    .base_address(snapshot_base_address),.base_capacity(snapshot_base_capacity),
    .control_valid,.control_ready,.control,.response_valid,.response_ready,.response,
    .stop_predecessor,.locks_owned,.pending_key,
    .predecessor_done_valid,.predecessor_done_ready,.predecessor_done_key,
    .old_channels_drained,.physical_safe(bootstrap_physical_safe),
    .protection_valid(locks_owned),.query_ingress_started(checkpoint_ingress_started),
    .query_ingress_owned,.query_accepted(checkpoint_query_accepted),
    .query_request(checkpoint_query_request),
    .query_response_pop(checkpoint_response_empty_n && checkpoint_response_read),
    .query_response_word(checkpoint_response_dout),.query_permit,.import_pending,
    .executor_owns_dispatch,.authority_valid,.revoked,.local_committed,
    .sequence_high_water,.handoff_high_water,.control_rejections,.grants,.closed_aborts,.phase,
    .terminal_seal_valid(1'b0),.terminal_seal_record(8192'b0),
    .terminal_seal_ready(),.terminal_seal_accepted(),
    .request_work_done_valid(1'b0),.request_work_done_record(8192'b0),
    .host_result_consumed_valid(1'b0),.host_result_consumed_record(8192'b0),
    .closed_consumer_valid(1'b0),.closed_consumer_record(8192'b0),
    .request_closed(),.last_closed_record(),.closed_requests());
  laya_generated_provenance_axi_portal_v1 #(
    .MONITORED_ROLE(MONITORED_ROLE),.ENABLE_EXECUTOR_CHECKPOINT(1),.MANAGED_EXECUTOR_HANDOFF(1),
    .ENABLE_BOOTSTRAP_SNAPSHOT(ENABLE_BOOTSTRAP_SNAPSHOT),
    .ENABLE_BOOTSTRAP_SOURCE_GUARD(ENABLE_BOOTSTRAP_SOURCE_GUARD)) portal(
    .provenance_cmd_write(provenance_cmd_write && !locks_owned),
    .provenance_cmd_full_n(predecessor_ready),
    .executor_provenance_cmd_write(executor_provenance_cmd_write && executor_owns_dispatch),
    .executor_provenance_cmd_full_n(executor_ready),
    .s_axi_awvalid(s_axi_awvalid && writer_route),.s_axi_awready(writer_awready),
    .s_axi_wvalid(s_axi_wvalid && writer_route),.s_axi_wready(writer_wready),
    .source_query_valid(source_query_valid && lease_query_route),
    .source_query_ready(lease_query_ready),.source_query_granted(lease_query_granted),
    .snapshot_request_valid(snapshot_request_valid && !locks_owned),
    .snapshot_request_ready(bootstrap_query_ready),.*);
endmodule
