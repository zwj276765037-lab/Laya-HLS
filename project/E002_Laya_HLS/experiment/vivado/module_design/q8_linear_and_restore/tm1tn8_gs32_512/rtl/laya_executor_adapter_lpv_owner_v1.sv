`timescale 1ns/1ps
// One actual adapter transaction owns A/route from its first LTX1 pop through
// its final LTC1 pop. This module buffers raw generated LPV1 bytes, not a
// reconstruction of LTX1. It grants no hub operation, publication or retirement.
module laya_executor_adapter_lpv_owner_v1 (
  input logic clk,rst_n,cancel,
  input logic installed_owner_valid,owner_revoked,
  input logic [8191:0] installed_owner,
  // The wrapper must gate the real first LTX1 pop with txn_start_ready.
  // txn_start is that actual pop, not request-valid or a sampled idle flag.
  input logic txn_start,txn_route,
  input logic [8191:0] txn_owner,
  output logic txn_start_ready,
  // Only the actual final LTC1 caller pop supplies txn_done. No LPV final
  // write/pop substitutes for it. A remains installed in the external owner.
  input logic txn_done,
  output logic txn_owned,txn_revoked,txn_drained,protocol_error,

  input logic [511:0] adapter_cmd_din,
  input logic adapter_cmd_write,
  output logic adapter_cmd_full_n,
  output logic [511:0] portal_cmd_din,
  output logic portal_cmd_write,
  input logic portal_cmd_full_n,
  input logic [511:0] portal_rsp_dout,
  input logic portal_rsp_empty_n,
  output logic portal_rsp_read,
  output logic [511:0] adapter_rsp_dout,
  output logic adapter_rsp_empty_n,
  input logic adapter_rsp_read,

  output logic lpv_candidate_valid,lpv_candidate_route,
  output logic [8191:0] lpv_candidate_owner,
  output logic lpv_pending_valid,lpv_pending_route,
  output logic [8191:0] lpv_pending_owner,lpv_pending_packet,
  output logic lpv_response_route,
  output logic [8191:0] lpv_response_owner,
  output logic [4:0] command_captured,command_sent,
  output logic [3:0] response_received,response_consumed,
  output logic [1:0] response_occupancy,
  output logic [31:0] transactions_started,transactions_released,invalid_done
);
  import laya_generated_provenance_layout_v1::*;
  logic [8191:0] retained_owner,packet;
  logic retained_route;
  logic cmd_capture,cmd_send,rsp_push,rsp_push_ready,rsp_pop,rsp_valid;
  logic no_lpv_done,lpv_done,response_empty_after_pop;

  assign txn_start_ready=rst_n && !txn_owned && !txn_revoked &&
    !protocol_error && !cancel && !owner_revoked && installed_owner_valid &&
    admission_record_ok(txn_owner) && txn_owner==installed_owner &&
    response_occupancy==0 && !adapter_cmd_write && !portal_rsp_empty_n;
  assign adapter_cmd_full_n=rst_n && txn_owned && command_captured<16;
  assign cmd_capture=adapter_cmd_write && adapter_cmd_full_n;
  // A partial frame is never presented to the portal. After collection, every
  // byte and owner/route remains immutable until the actual transaction end.
  assign portal_cmd_write=rst_n && txn_owned && command_captured==16 && command_sent<16;
  assign portal_cmd_din=packet[command_sent[3:0]*512+:512];
  assign cmd_send=portal_cmd_write && portal_cmd_full_n;

  assign rsp_push=txn_owned && command_sent==16 && response_received<8 && portal_rsp_empty_n;
  assign portal_rsp_read=rst_n && rsp_push && rsp_push_ready;
  assign adapter_rsp_empty_n=rsp_valid && txn_owned;
  assign rsp_pop=adapter_rsp_empty_n && adapter_rsp_read;
  laya_private_fifo2_v1 response_fifo(
    .clk,.rst_n,.in_valid(rsp_push),.in_ready(rsp_push_ready),.in_data(portal_rsp_dout),
    .out_valid(rsp_valid),.out_ready(rsp_pop),.out_data(adapter_rsp_dout),
    .occupancy(response_occupancy));

  assign lpv_candidate_valid=txn_owned;
  assign lpv_candidate_route=retained_route;
  assign lpv_candidate_owner=retained_owner;
  assign lpv_pending_valid=txn_owned && command_captured==16;
  assign lpv_pending_route=retained_route;
  assign lpv_pending_owner=retained_owner;
  assign lpv_pending_packet=packet;
  assign lpv_response_route=retained_route;
  assign lpv_response_owner=retained_owner;
  // These are old-adapter transport facts, never the monitor's producer fence.
  assign txn_drained=!txn_owned && response_occupancy==0 &&
    !adapter_cmd_write && !portal_rsp_empty_n;
  assign response_empty_after_pop=response_occupancy==0 ||
    (response_occupancy==1 && rsp_pop && !portal_rsp_read);
  assign no_lpv_done=command_captured==0 && command_sent==0 &&
    response_received==0 && response_consumed==0 && response_occupancy==0 &&
    !adapter_cmd_write && !portal_rsp_empty_n;
  assign lpv_done=command_captured==16 && command_sent==16 && response_received==8 &&
    (response_consumed==8 || (response_consumed==7 && rsp_pop)) &&
    response_empty_after_pop && !adapter_cmd_write && !portal_rsp_empty_n;

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      txn_owned<=0;txn_revoked<=0;protocol_error<=0;
      retained_owner<=0;retained_route<=0;packet<=0;
      command_captured<=0;command_sent<=0;
      response_received<=0;response_consumed<=0;
      transactions_started<=0;transactions_released<=0;invalid_done<=0;
    end else begin
      if(txn_start && txn_start_ready)begin
        txn_owned<=1;retained_owner<=txn_owner;retained_route<=txn_route;
        packet<=0;transactions_started<=transactions_started+1'b1;
      end
      // Current candidate inputs can change while an old transaction exists.
      // Only actual installed-domain changes revoke it; none rebind old bytes.
      if(txn_owned && (cancel || owner_revoked || !installed_owner_valid ||
          installed_owner!=retained_owner))txn_revoked<=1;
      if(cmd_capture)begin
        packet[command_captured[3:0]*512+:512]<=adapter_cmd_din;
        command_captured<=command_captured+1'b1;
      end
      if(cmd_send)command_sent<=command_sent+1'b1;
      if(portal_rsp_read)response_received<=response_received+1'b1;
      if(rsp_pop)response_consumed<=response_consumed+1'b1;
      if(txn_done)begin
        if(txn_owned && (no_lpv_done || lpv_done))begin
          txn_owned<=0;transactions_released<=transactions_released+1'b1;
          command_captured<=0;command_sent<=0;
          response_received<=0;response_consumed<=0;
          // No FIFO reset, no A lifecycle release, no revoke/error clearing.
          // Retained bytes remain available for diagnosis until a new start.
        end else begin
          protocol_error<=1;invalid_done<=invalid_done+1'b1;
        end
      end
    end
  end
endmodule
