#pragma once

#include "laya_graph_action_protocol.h"
#include "laya_controller_transaction_hls.h"
#include "laya_generated_provenance_events.h"
#include "laya_producer_engine_client.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::lifecycle {

// One action, one local window cursor, and one normalized transaction in
// flight.  FullRuntime remains the sole logical owner/lease/ticket authority.
// This machine never calls the old synchronous full-family execute tree.
enum class Phase : uint8_t {
  IDLE, CLAIM, PREPARE_WINDOW, BEGIN_RESULT, PRODUCER_RESULT, END_RESULT,
  PUBLISH, OWNER_RESULT, CLEANUP, CLEANUP_RESULT,
  TX_WRITE, TX_READ, TX_VALIDATE, FINISH, COMPLETE, ISOLATED,
};

struct Machine {
  Phase phase = Phase::IDLE, after_transaction = Phase::IDLE;
  action::Request action;
  action::Completion completion;
  portal::ModelBinding model;
  full::FullOwnerSpec output;
  LayerNormTask task;
  provenance::Request scope;
  producer::Request producer_request;
  TaskDone logical_done;
  transaction::Request transaction;
  transaction::Completion response;
  transaction::RequestPacket request_packet{};
  transaction::CompletionPacket response_packet{};
  Check response_result = ok();
  unsigned beat = 0;
  uint8_t batch = 0;
  uint16_t row = 0;
  uint64_t action_high_water = 0;
  bool cancel_pending = false;
};

Check start(Machine&, full::FullRuntime&, const action::Request&);
void step(Machine&, full::FullRuntime&, const full::FullMemory&, bool cancel,
          hls::stream<ap_uint<512>>& transaction_request,
          hls::stream<ap_uint<512>>& transaction_completion);
// Call only for this completion's actual final consumer handshake.
Check completion_consumed(Machine&, const full::FullRuntime&);

} // namespace laya::lifecycle
#endif
