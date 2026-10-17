`timescale 1ns/1ps
module laya_generated_provenance_portal_v1 (
  input  logic clk,rst_n,cancel,
  input  logic [511:0] provenance_cmd_din,
  input  logic provenance_cmd_write,
  output logic provenance_cmd_full_n,
  output logic [511:0] provenance_rsp_dout,
  output logic provenance_rsp_empty_n,
  input  logic provenance_rsp_read,
  input  logic physical_observation_valid,
  output logic physical_observation_ready,
  input  logic [15:0] physical_status,
  input  logic [31:0] physical_error_detail,
  input  logic [63:0] physical_bad_element,
  input  logic [63:0] physical_observed_store_bytes0,
  input  logic [63:0] physical_observed_store_bytes1,
  input  logic physical_drained,
  input  logic physical_coverage_complete,
  input  logic source_query_valid,
  output logic source_query_ready,
  input  logic [8191:0] source_query_command,
  output logic source_query_granted,
  input  logic source_release_valid,
  output logic source_release_ready,
  input  logic [8191:0] source_release_command,
  input  logic source_release_drained,
  output logic source_lease_active,
  output logic transport_busy,cancel_pending,protocol_error,
  output logic scope_active,domain_drained,
  output logic [63:0] last_event_seq,
  output logic [5:0] active_owners,published_owners,
  output logic [31:0] accepted_requests,retired_responses,
  output logic [31:0] accepted_events,semantic_rejections,terminal_tasks,
  output logic [1:0] command_fifo_occupancy,response_fifo_occupancy
);
  logic request_valid,request_ready,service_cancel;
  logic [8191:0] request;
  logic response_valid,response_ready;
  logic [4095:0] response;

  laya_generated_provenance_v1 transport(
    .clk,.rst_n,.cancel,
    .provenance_cmd_din,.provenance_cmd_write,.provenance_cmd_full_n,
    .provenance_rsp_dout,.provenance_rsp_empty_n,.provenance_rsp_read,
    .service_request_valid(request_valid),.service_request_ready(request_ready),
    .service_request(request),.service_cancel,
    .service_response_valid(response_valid),
    .service_response_ready(response_ready),.service_response(response),
    .service_scope_active(scope_active),.service_domain_drained(domain_drained),
    .busy(transport_busy),.cancel_pending,.protocol_error,.last_event_seq,
    .accepted_requests,.retired_responses,
    .command_fifo_occupancy,.response_fifo_occupancy
  );

  laya_generated_provenance_hub_v1 hub(
    .clk,.rst_n,.request_valid,.request_ready,.request,
    .cancel(service_cancel),
    .begin_external_ready(1'b1),.begin_external_supported(1'b1),
    .physical_observation_valid,.physical_observation_ready,
    .physical_status,.physical_error_detail,.physical_bad_element,
    .physical_observed_store_bytes0,.physical_observed_store_bytes1,
    .physical_drained,.physical_coverage_complete,
    .source_query_valid,.source_query_ready,.source_query_command,
    .source_query_granted,.source_release_valid,.source_release_ready,
    .source_release_command,.source_release_drained,.source_lease_active,
    .response_valid,.response_ready,.response,
    .scope_active,.domain_drained,.cancel_pending(),
    .active_owners,.published_owners,
    .accepted_events,.semantic_rejections,.terminal_tasks
  );
endmodule
