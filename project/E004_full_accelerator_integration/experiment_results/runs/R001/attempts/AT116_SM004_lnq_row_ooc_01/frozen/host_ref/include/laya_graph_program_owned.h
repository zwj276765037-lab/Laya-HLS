#pragma once
#ifndef AP_INT_MAX_W
#define AP_INT_MAX_W 8192
#endif
#include "laya_graph_program_state.h"
#include "laya_executor_handoff_protocol.h"

#ifdef LAYA_GRAPH_PROGRAM_HAS_HLS_STREAM
namespace laya::program_owned {
// FIRST-only program owner. The whole actual GRANTED record remains installed
// through old command/action/result cleanup; no live input replaces its key.
struct State {
  program_hls::State program;
  handoff::Message owner;
  handoff::Packet owner_packet{};
  bool installed = false, echoed = false, revoked = false;
  bool pending_sent = false, isolated = false, finished = false;
  bool completion_receipt_active = false;
  unsigned completion_receipt_beat = 0;
  action::CompletionPacket completion_receipt{};
  uint64_t owner_reads = 0, owner_receipts = 0, pending_writes = 0;
  uint64_t completion_receipt_writes = 0;
};
void step(State&, bool cancel, bool result_consumed,
    hls::stream<ap_uint<8192>>& program_owner,
    hls::stream<ap_uint<8192>>& program_owner_receipt,
    hls::stream<ap_uint<8192>>& program_pending,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion,
    hls::stream<ap_uint<512>>& action_completion_receipt);
} // namespace laya::program_owned

extern "C" void laya_graph_program_owned_sequencer(
    bool cancel, bool result_consumed, bool& isolated,
    hls::stream<ap_uint<8192>>& program_owner,
    hls::stream<ap_uint<8192>>& program_owner_receipt,
    hls::stream<ap_uint<8192>>& program_pending,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion,
    hls::stream<ap_uint<512>>& action_completion_receipt);
#endif
