#pragma once
#include "laya_graph_program_hls.h"
#include "laya_graph_program_sequencer.h"
#include "laya_program_pending_protocol.h"
#ifdef LAYA_GRAPH_PROGRAM_HAS_HLS_STREAM
namespace laya::program_hls {
enum class Phase : uint8_t {
  READ_COMMAND, DECODE_COMMAND, PREPARE_ACTION, WRITE_ACTION, READ_COMPLETION,
  ACCEPT_COMPLETION, WRITE_RESULT, WAIT_RESULT_CONSUMED,
};
struct State {
  Phase phase = Phase::READ_COMMAND;
  unsigned beat = 0;
  program::State graph;
  program_wire::Command command;
  action::Request pending_action;
  program_wire::Result result;
  bool result_consumed_pending = false, bound_command = false;
  program_pending::Key key;
  program_wire::CommandPacket command_packet{};
  program_wire::ResultPacket result_packet{};
  action::RequestPacket action_packet{};
  action::CompletionPacket completion_packet{};
};
// Synthesis uses an explicit validity value and the complete key. Pointer
// nullness must not determine ownership in a synthesized call hierarchy.
void step(State&, bool cancel, bool result_consumed, bool has_issued_key,
          const program_pending::Key& issued_command_key,
          hls::stream<ap_uint<512>>&, hls::stream<ap_uint<512>>&,
          hls::stream<ap_uint<512>>&, hls::stream<ap_uint<512>>&);
// A bound key is presented only for an already-issued old command. It allows
// its first/remaining beats to drain after revoke without authorizing an action.
void step(State&, bool cancel, bool result_consumed,
          const program_pending::Key* issued_command_key,
          hls::stream<ap_uint<512>>&, hls::stream<ap_uint<512>>&,
          hls::stream<ap_uint<512>>&, hls::stream<ap_uint<512>>&);
bool observe_pending(const State&, program_pending::Packet&);
} // namespace laya::program_hls
#endif
