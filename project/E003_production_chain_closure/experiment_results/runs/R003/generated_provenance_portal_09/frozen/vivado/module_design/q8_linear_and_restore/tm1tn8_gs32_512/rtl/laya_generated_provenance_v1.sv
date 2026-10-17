`timescale 1ns/1ps
// Fixed 16/8-beat LPV1/LPA1 transport.  The receiver owns persistent ledger
// state; cancellation only clears private framing after that domain is safe.
module laya_generated_provenance_v1 (
  input  logic clk,rst_n,cancel,
  input  logic [511:0] provenance_cmd_din,
  input  logic provenance_cmd_write,
  output logic provenance_cmd_full_n,
  output logic [511:0] provenance_rsp_dout,
  output logic provenance_rsp_empty_n,
  input  logic provenance_rsp_read,
  output logic service_request_valid,
  input  logic service_request_ready,
  output logic [8191:0] service_request,
  output logic service_cancel,
  input  logic service_response_valid,
  output logic service_response_ready,
  input  logic [4095:0] service_response,
  input  logic service_scope_active,
  input  logic service_domain_drained,
  output logic busy,cancel_pending,protocol_error,
  output logic [63:0] last_event_seq,
  output logic [31:0] accepted_requests,retired_responses,
  output logic [1:0] command_fifo_occupancy,response_fifo_occupancy
);
  import laya_generated_provenance_layout_v1::*;
  import laya_model_identity_13bo_generated_v1::*;
  typedef enum logic [2:0] {COLLECT,CHECK,ISSUE,WAIT_SERVICE,SEND,WAIT_CALLER} state_t;
  state_t state;
  logic [4:0] ingress_count,collect_count;
  logic [3:0] send_count,caller_count;
  logic [63:0] active_seq;
  logic header_seen,header_trusted;
  logic [4095:0] response;
  logic cmd_push,cmd_ready,cmd_valid,rsp_push,rsp_ready,rsp_valid,rsp_pop;
  logic [511:0] cmd_data,rsp_data;
  logic transport_abort,fifo_rst_n;

  assign provenance_cmd_full_n=cmd_ready && ingress_count<REQUEST_BEATS &&
      state==COLLECT && !cancel;
  assign cmd_push=provenance_cmd_write && provenance_cmd_full_n;
  laya_private_fifo2_v1 command_fifo(.clk,.rst_n(fifo_rst_n),
    .in_valid(cmd_push),.in_ready(cmd_ready),.in_data(provenance_cmd_din),
    .out_valid(cmd_valid),.out_ready(state==COLLECT),.out_data(cmd_data),
    .occupancy(command_fifo_occupancy));

  assign rsp_push=state==SEND && send_count<RESPONSE_BEATS;
  assign rsp_data=response[send_count[2:0]*512+:512];
  assign rsp_pop=provenance_rsp_empty_n && provenance_rsp_read;
  assign provenance_rsp_empty_n=rsp_valid && !transport_abort;
  laya_private_fifo2_v1 response_fifo(.clk,.rst_n(fifo_rst_n),
    .in_valid(rsp_push),.in_ready(rsp_ready),.in_data(rsp_data),
    .out_valid(rsp_valid),.out_ready(provenance_rsp_read && !transport_abort),
    .out_data(provenance_rsp_dout),.occupancy(response_fifo_occupancy));

  assign busy=state!=COLLECT || ingress_count!=0;
  assign service_request_valid=state==ISSUE && !cancel_pending && !cancel;
  assign service_cancel=cancel_pending || cancel;
  assign service_response_ready=state==WAIT_SERVICE;
  assign transport_abort=cancel && service_domain_drained;
  assign fifo_rst_n=rst_n && !transport_abort;

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=COLLECT;ingress_count<=0;collect_count<=0;
      send_count<=0;caller_count<=0;active_seq<=0;
      header_seen<=0;header_trusted<=0;service_request<=0;response<=0;
      cancel_pending<=0;protocol_error<=0;last_event_seq<=0;
      accepted_requests<=0;retired_responses<=0;
    end else if(transport_abort)begin
      state<=COLLECT;ingress_count<=0;collect_count<=0;
      send_count<=0;caller_count<=0;cancel_pending<=0;
      if(header_seen && header_trusted && active_seq>last_event_seq)
        last_event_seq<=active_seq;
      header_seen<=0;header_trusted<=0;active_seq<=0;
    end else begin
      if(cmd_push)begin
        ingress_count<=ingress_count+1'b1;
        if(ingress_count==0)begin
          header_seen<=1;header_trusted<=request_header_ok(provenance_cmd_din);
          active_seq<=provenance_cmd_din[EVENT_SEQ*8+:64];
        end
      end
      if(cancel && (busy || service_scope_active))cancel_pending<=1;
      if(cmd_valid && state==COLLECT)begin
        service_request[collect_count*512+:512]<=cmd_data;
        collect_count<=collect_count+1'b1;
        if(collect_count==REQUEST_BEATS-1)state<=CHECK;
      end
      if(rsp_pop)begin
        caller_count<=caller_count+1'b1;
        if(caller_count==RESPONSE_BEATS-1)begin
          state<=COLLECT;ingress_count<=0;collect_count<=0;
          send_count<=0;caller_count<=0;
          if(header_seen && header_trusted && active_seq>last_event_seq)
            last_event_seq<=active_seq;
          header_seen<=0;header_trusted<=0;active_seq<=0;
          cancel_pending<=0;retired_responses<=retired_responses+1'b1;
        end
      end
      case(state)
        COLLECT:;
        CHECK:begin
          if(!request_frame_ok(service_request))begin
            response<=rejected_response(service_request,E_ABI,32'h04000016,
                service_scope_active &&
                service_request[ACTION*8+:16]==END_EVENT);
            state<=SEND;
          end else if(!l13m_structure_ok(
              service_request[MODEL_IDENTITY*8+:3328]))begin
            response<=rejected_response(service_request,E_ABI,32'h04000014,
                service_scope_active &&
                service_request[ACTION*8+:16]==END_EVENT);
            state<=SEND;
          end else if(!l13m_canonical_ok(
              service_request[MODEL_IDENTITY*8+:3328]) ||
              !l13m_numeric_tags_ok(
                service_request[MODEL_IDENTITY*8+:3328],
                service_request[IDENTITY*8+:672]))begin
            response<=rejected_response(service_request,E_MODEL,32'h04000004,
                service_scope_active &&
                service_request[ACTION*8+:16]==END_EVENT);
            state<=SEND;
          end else if(service_request[EVENT_SEQ*8+:64]<=last_event_seq ||
                      cancel_pending || cancel)begin
            response<=rejected_response(service_request,E_PROTOCOL,
                32'h04000017,service_scope_active &&
                service_request[ACTION*8+:16]==END_EVENT);
            state<=SEND;
          end else state<=ISSUE;
        end
        ISSUE:begin
          if(cancel_pending || cancel)begin
            response<=rejected_response(service_request,E_PROTOCOL,
                32'h04000017,service_scope_active &&
                service_request[ACTION*8+:16]==END_EVENT);
            state<=SEND;
          end else if(service_request_valid && service_request_ready)begin
            accepted_requests<=accepted_requests+1'b1;state<=WAIT_SERVICE;
          end
        end
        WAIT_SERVICE:begin
          if(service_response_valid && service_response_ready)begin
            if(!response_binding_ok(service_response,service_request))begin
              response<=rejected_response(service_request,E_PROTOCOL,
                  32'h04000017,service_scope_active &&
                  service_request[ACTION*8+:16]==END_EVENT);
              protocol_error<=1;
            end else response<=service_response;
            state<=SEND;
          end
        end
        SEND:if(rsp_push && rsp_ready)begin
          send_count<=send_count+1'b1;
          if(send_count==RESPONSE_BEATS-1)state<=WAIT_CALLER;
        end
        WAIT_CALLER:;
        default:state<=COLLECT;
      endcase
    end
  end
endmodule
