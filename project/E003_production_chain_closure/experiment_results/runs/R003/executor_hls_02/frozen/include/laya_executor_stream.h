#pragma once

#include "laya_executor_actor.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::executor_stream {

// Each receipt is the complete original wire packet echoed by the real
// downstream consumer after its final read and successful codec validation.
// No write-side pulse or FIFO-empty observation creates a consumption fact.
template<unsigned Bytes> struct Frame {
  std::array<uint8_t, Bytes> packet{};
  unsigned beat = 0;
  bool complete = false;
};

struct Transport {
  handoff::Packet control_packet{};
  unsigned control_beat = 0;
  bool control_active = false;
  handoff::Message last_consumed_control;
  bool last_consumed_control_valid = false;
  bool last_control_response_consumed = false;
  Frame<handoff::kBytes> control_receipt, response;
  Frame<program_wire::kResultBytes> host_receipt;
  Frame<action::kCompletionBytes> action_receipt;
  handoff::Packet response_receipt{};
  bool response_receipt_valid = false;
  // False is a rejected-frame notification and never a release/authority
  // fact. Both fields remain stable alongside the complete packet.
  bool response_receipt_accepted = false;
  bool transport_error = false;
  // This finite hardware-baseline wrapper admits FIRST once. Later admission
  // belongs to the separately bound CLOSE/rearm path, never to the old IDLE.
  bool first_admitted = false;
  bool require_program_owner = false;
  bool program_owner_valid = false, program_owner_sent = false;
  bool program_owner_confirmed = false, program_pending_valid = false;
  handoff::Packet program_owner{};
  program_pending::Packet program_pending{};
  uint64_t control_writes = 0, control_receipt_reads = 0;
  uint64_t response_reads = 0, host_receipt_reads = 0;
  uint64_t action_receipt_reads = 0, action_receipts = 0;
  uint64_t control_receipts = 0, response_frames = 0, host_receipts = 0;
  uint64_t rejected_control_receipts = 0, rejected_responses = 0;
  uint64_t rejected_host_receipts = 0;
  uint64_t rejected_action_receipts = 0;
  uint64_t revoked_grant_receipts = 0;
};

// Whole-record ready means the unique shell has accepted and verified the
// complete accepted response receipt against its retained response. Rejected
// notifications are consumed without changing any shell ownership. The receipt and
// valid remain stable until that handshake, including during revocation.
void step(executor::State&, Transport&, const full::FullMemory&,
    const executor::Inputs& live, bool response_receipt_ready,
    hls::stream<ap_uint<512>>& control_request,
    hls::stream<ap_uint<512>>& control_request_receipt,
    hls::stream<ap_uint<512>>& control_response,
    hls::stream<ap_uint<512>>& host_result_receipt,
    hls::stream<ap_uint<512>>& checkpoint_request,
    hls::stream<ap_uint<512>>& checkpoint_response,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& program_result,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion,
    hls::stream<ap_uint<512>>& transaction_request,
    hls::stream<ap_uint<512>>& transaction_completion,
    hls::stream<ap_uint<512>>& action_completion_receipt);

} // namespace laya::executor_stream
#endif
