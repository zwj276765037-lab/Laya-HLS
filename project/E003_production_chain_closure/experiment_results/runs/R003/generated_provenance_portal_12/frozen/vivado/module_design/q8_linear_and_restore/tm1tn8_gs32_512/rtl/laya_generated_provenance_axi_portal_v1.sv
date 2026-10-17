`timescale 1ns/1ps
// First physical integration of the persistent provenance portal with one
// protected generated AXI512 write port.  The role/base are supplied by the
// outer 13-BO owner domain; the original Host ABI is unchanged.
module laya_generated_provenance_axi_portal_v1 #(
  parameter int MONITORED_ROLE=6
) (
  input  logic clk,rst_n,cancel,
  input  logic [511:0] provenance_cmd_din,
  input  logic provenance_cmd_write,
  output logic provenance_cmd_full_n,
  output logic [511:0] provenance_rsp_dout,
  output logic provenance_rsp_empty_n,
  input  logic provenance_rsp_read,
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
  logic [15:0] request_action;

  assign request_action=request[ACTION*8+:16];
  assign physical_observation_valid=request_valid &&
      ((request_action==END_EVENT && monitor_scope_active && monitor_drained) ||
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

  laya_generated_provenance_v1 transport(
    .clk,.rst_n,.cancel,
    .provenance_cmd_din,.provenance_cmd_write,.provenance_cmd_full_n,
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

  laya_generated_provenance_hub_v1 hub(
    .clk,.rst_n,.request_valid,.request_ready,.request,
    .cancel(service_cancel),
    .begin_external_ready(begin_ready),
    .begin_external_supported(begin_supported),
    .physical_observation_valid,.physical_observation_ready,
    .physical_status,.physical_error_detail,.physical_bad_element,
    .physical_observed_store_bytes0(physical_observed0),
    .physical_observed_store_bytes1(physical_observed1),
    .physical_drained,.physical_coverage_complete,
    .source_query_valid,.source_query_ready,.source_query_command,
    .source_query_granted,.source_release_valid,.source_release_ready,
    .source_release_command,.source_release_drained,.source_lease_active,
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
      accepted_request<=0;owner_coverage_complete<=0;
      monitor_protocol_error<=0;begin_reserved<=0;
    end else begin
      if(request_valid && request_ready)begin
        accepted_request<=request;
        if(request_action==BEGIN_EVENT)begin_reserved<=1;
      end
      if(response_valid && response_ready &&
         response[ACTION*8+:16]==BEGIN_EVENT)
        begin_reserved<=0;
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
