#include "laya_graph_program_hls.h"
#include "laya_graph_program_state.h"

#ifdef LAYA_GRAPH_PROGRAM_HAS_HLS_STREAM
namespace {

using namespace laya;

template<std::size_t Bytes>
void store_word(std::array<uint8_t, Bytes>& packet, unsigned beat,
                const ap_uint<512>& word) {
#pragma HLS inline off
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    packet[beat * 64 + byte] =
        uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
}

template<std::size_t Bytes>
ap_uint<512> packet_word(const std::array<uint8_t, Bytes>& packet,
                         unsigned beat) {
#pragma HLS inline off
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  }
  return word;
}

program_wire::Result local_reject(Check failure) {
  program_wire::Result result;
  result.flags = program_wire::FRAME_COMPLETE |
      program_wire::SAFE_TERMINAL | program_wire::REQUEST_COMPLETE |
      program_wire::LOCAL_REJECT;
  result.result = failure;
  return result;
}

} // namespace

namespace laya::program_hls {
void step(State& owner, bool cancel, bool result_consumed,
    const program_pending::Key* issued_command_key,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion) {
#pragma HLS pipeline off
  auto& state = owner.phase;
  auto& beat = owner.beat;
  auto& graph = owner.graph;
  auto& command = owner.command;
  auto& pending_action = owner.pending_action;
  auto& result = owner.result;
  auto& result_consumed_pending = owner.result_consumed_pending;
  auto& command_packet = owner.command_packet;
  auto& result_packet = owner.result_packet;
  auto& action_packet = owner.action_packet;
  auto& completion_packet = owner.completion_packet;
  if (cancel && graph.action_active) program::request_cancel(graph);

  if (state == Phase::WAIT_RESULT_CONSUMED) {
    if (result_consumed_pending || result_consumed) {
      result_consumed_pending = false;
      owner.bound_command = false;
      state = Phase::READ_COMMAND;
    }
    return;
  }

  if (state == Phase::READ_COMMAND) {
    if (cancel && beat == 0 && !issued_command_key) return;
    if (issued_command_key && (!issued_command_key->session ||
        !issued_command_key->accepted_request || !issued_command_key->sequence ||
        !issued_command_key->handoff)) return;
    ap_uint<512> word;
    if (!accepted_command.read_nb(word)) return;
    if (beat == 0) {
      owner.bound_command = issued_command_key != nullptr;
      owner.key = issued_command_key ? *issued_command_key : program_pending::Key{};
    }
    store_word(command_packet, beat, word);
    ++beat;
    if (beat == program_wire::kCommandBeats) {
      beat = 0;
      state = Phase::DECODE_COMMAND;
    }
    return;
  }

  if (state == Phase::DECODE_COMMAND) {
    Check decoded = program_wire::decode(command_packet, command);
    if (!decoded) {
      result = local_reject(decoded);
      result_packet = program_wire::encode(result);
      state = Phase::WRITE_RESULT;
      return;
    }
    state = Phase::PREPARE_ACTION;
    return;
  }

  if (state == Phase::PREPARE_ACTION) {
    Check prepared = cancel ?
        Check{Status::E_PROTOCOL, laya::detail(7, 0, 14)} :
        program::begin(graph, command.identity);
    if (prepared)
      prepared = program::seed_slot(graph, command.source.slot,
                                    command.source.owner,
                                    command.source.version);
    if (prepared)
      prepared = program::prepare_norm(
          graph, command.source.slot, 1, Op::LN_ATTN, 2, 1,
          Buffer::NORM, 0, 0, 0, pending_action);
    if (!prepared) {
      result = local_reject(prepared);
      result.identity = command.identity;
      result.flags |= program_wire::BINDING_OK;
      result_packet = program_wire::encode(result);
      state = Phase::WRITE_RESULT;
      return;
    }
    action_packet = action::encode(pending_action);
    state = Phase::WRITE_ACTION;
    return;
  }

  if (state == Phase::WRITE_ACTION) {
    const ap_uint<512> word = packet_word(action_packet, beat);
    if (action_request.write_nb(word)) {
      ++beat;
      if (beat == action::kRequestBeats) {
        beat = 0;
        state = Phase::READ_COMPLETION;
      }
    }
    return;
  }

  if (state == Phase::READ_COMPLETION) {
    ap_uint<512> word;
    if (!action_completion.read_nb(word)) return;
    store_word(completion_packet, beat, word);
    ++beat;
    if (beat == action::kCompletionBeats) {
      beat = 0;
      state = Phase::ACCEPT_COMPLETION;
    }
    return;
  }

  if (state == Phase::ACCEPT_COMPLETION) {
    action::Completion completion;
    Check decoded = action::decode(completion_packet, completion);
    if (!decoded) {
      state = Phase::READ_COMPLETION;
      return;
    }
    Check accepted = program::accept_completion(graph, completion);
    if (graph.action_active) {
      state = Phase::READ_COMPLETION;
      return;
    }
    result = program_wire::Result{};
    result.entrypoint = command.entrypoint;
    result.pc = graph.pc;
    result.flags = program_wire::FRAME_COMPLETE | program_wire::BINDING_OK |
        program_wire::SAFE_TERMINAL | program_wire::REQUEST_COMPLETE;
    result.action_ordinal = pending_action.ordinal;
    result.identity = command.identity;
    result.result = accepted;
    if (accepted) {
      result.flags |= program_wire::SLOT_UPDATE_VALID;
      result.slot_delta = completion.slot_delta;
    }
    result_packet = program_wire::encode(result);
    state = Phase::WRITE_RESULT;
    return;
  }

  const ap_uint<512> word = packet_word(result_packet, beat);
  if (request_result.write_nb(word)) {
    ++beat;
    if (beat == program_wire::kResultBeats) {
      beat = 0;
      // The real FIFO consumer may retire the final beat in the cycle that
      // this producer finishes it.  Preserve that request-bound notification
      // until WAIT_RESULT_CONSUMED observes it; signals on earlier beats are
      // ignored so an old notification cannot release a later request.
      result_consumed_pending = result_consumed;
      state = Phase::WAIT_RESULT_CONSUMED;
    }
  }
}
bool observe_pending(const State& s, program_pending::Packet& out) {
  out = program_pending::Packet{};
  if (!s.bound_command || !s.graph.action_active ||
      (s.phase != Phase::WRITE_ACTION && s.phase != Phase::READ_COMPLETION &&
       s.phase != Phase::ACCEPT_COMPLETION)) return false;
  program_pending::Record r;
  r.key = s.key; r.command = s.command; r.action = s.graph.pending;
  if (!program_pending::validate(r)) return false;
  out = program_pending::encode(r); return true;
}
} // namespace laya::program_hls

extern "C" void laya_graph_program_sequencer(
    bool cancel, bool result_consumed,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion) {
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_none port=cancel
#pragma HLS interface ap_none port=result_consumed
#pragma HLS interface ap_fifo port=accepted_command
#pragma HLS interface ap_fifo port=request_result
#pragma HLS interface ap_fifo port=action_request
#pragma HLS interface ap_fifo port=action_completion
#pragma HLS pipeline off
  static laya::program_hls::State state;
  laya::program_hls::step(state, cancel, result_consumed, nullptr,
      accepted_command, request_result, action_request, action_completion);
}
#endif
