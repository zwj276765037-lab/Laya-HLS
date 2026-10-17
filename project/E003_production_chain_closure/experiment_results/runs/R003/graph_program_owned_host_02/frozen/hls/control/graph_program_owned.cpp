#include "laya_graph_program_owned.h"

#ifdef LAYA_GRAPH_PROGRAM_HAS_HLS_STREAM
namespace laya::program_owned {
namespace {
template<std::size_t N> ap_uint<N * 8> wide(const std::array<uint8_t, N>& p) {
#pragma HLS inline off
  ap_uint<N * 8> word = 0;
  for (unsigned b = 0; b < N; ++b) {
#pragma HLS unroll off
    word.range(b * 8 + 7, b * 8) = p[b];
  }
  return word;
}
program_wire::Command expected_command(const handoff::Message& owner) {
  program_wire::Command c;
  c.identity = owner.binding.source.identity;
  c.flags = program_wire::SOURCE_READY_PROOF;
  const auto& d = owner.binding.source.source;
  c.source = {0, d.target_ref.epoch,
      {d.target_ref, d.target_region, d.stage, d.layer, d.batch, d.row_space,
       d.row0, d.rows, d.width, d.content}};
  return c;
}
} // namespace
void step(State& s, bool cancel, bool result_consumed,
    hls::stream<ap_uint<8192>>& program_owner,
    hls::stream<ap_uint<8192>>& program_owner_receipt,
    hls::stream<ap_uint<8192>>& program_pending,
    hls::stream<ap_uint<512>>& accepted_command,
    hls::stream<ap_uint<512>>& request_result,
    hls::stream<ap_uint<512>>& action_request,
    hls::stream<ap_uint<512>>& action_completion,
    hls::stream<ap_uint<512>>& action_completion_receipt) {
#pragma HLS pipeline off
  if (cancel) s.revoked = true;
  if (s.isolated || s.finished) return;
  if (!s.installed) {
    ap_uint<8192> word;
    if (!program_owner.read_nb(word)) return;
    ++s.owner_reads;
    for (unsigned b = 0; b < handoff::kBytes; ++b) {
#pragma HLS unroll off
      s.owner_packet[b] = uint8_t(word.range(b * 8 + 7, b * 8));
    }
    if (!handoff::decode(s.owner_packet, s.owner) ||
        s.owner.kind != handoff::Kind::GRANTED || !s.owner.result ||
        !s.owner.local_committed) { s.isolated = true; return; }
    s.installed = true;
    return;
  }
  if (!s.echoed) {
    if (program_owner_receipt.write_nb(wide(s.owner_packet))) {
      s.echoed = true; ++s.owner_receipts;
    }
    return;
  }
  auto& p = s.program;
  // Check the complete LGP1 before program::begin or ordinal allocation.
  // A wrong frame stays isolated with its retained full owner and raw bytes.
  if (p.phase == program_hls::Phase::DECODE_COMMAND) {
    program_wire::Command c;
    if (!program_wire::decode(p.command_packet, c) ||
        p.command_packet != program_wire::encode(expected_command(s.owner))) {
      s.isolated = true; return;
    }
  }
  if (p.phase == program_hls::Phase::WRITE_ACTION && !s.pending_sent) {
    program_pending::Packet packet;
    if (!program_hls::observe_pending(p, packet)) {
      s.isolated = true; return;
    }
    // This is copied from graph.pending after the sole program allocator has
    // selected its actual ordinal. It is never decoded from an action prefix.
    if (program_pending.write_nb(wide(packet))) {
      s.pending_sent = true; ++s.pending_writes;
    }
    return;
  }
  if (s.completion_receipt_active) {
    const unsigned beat = s.completion_receipt_beat;
    ap_uint<512> word = 0;
    for (unsigned b = 0; b < 64; ++b) {
#pragma HLS unroll off
      word.range(b * 8 + 7, b * 8) = s.completion_receipt[beat * 64 + b];
    }
    if (action_completion_receipt.write_nb(word)) {
      ++s.completion_receipt_writes;
      if (++s.completion_receipt_beat == action::kCompletionBeats)
        s.completion_receipt_active = false;
    }
    return;
  }
  const auto before = p.phase;
  const program_pending::Key key{s.owner.session, s.owner.accepted_request,
      s.owner.binding.source.sequence, s.owner.binding.handoff_epoch};
  program_hls::step(p, s.revoked, result_consumed, &key, accepted_command,
      request_result, action_request, action_completion);
  if (before == program_hls::Phase::ACCEPT_COMPLETION &&
      p.phase == program_hls::Phase::WRITE_RESULT && !p.graph.action_active) {
    s.completion_receipt = p.completion_packet;
    s.completion_receipt_active = true;
    s.completion_receipt_beat = 0;
  }
  if (before == program_hls::Phase::WAIT_RESULT_CONSUMED &&
      p.phase == program_hls::Phase::READ_COMMAND) s.finished = true;
}
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
    hls::stream<ap_uint<512>>& action_completion_receipt) {
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_none port=cancel
#pragma HLS interface ap_none port=result_consumed
#pragma HLS interface ap_none port=isolated
#pragma HLS interface ap_fifo port=program_owner
#pragma HLS interface ap_fifo port=program_owner_receipt
#pragma HLS interface ap_fifo port=program_pending
#pragma HLS interface ap_fifo port=accepted_command
#pragma HLS interface ap_fifo port=request_result
#pragma HLS interface ap_fifo port=action_request
#pragma HLS interface ap_fifo port=action_completion
#pragma HLS interface ap_fifo port=action_completion_receipt
#pragma HLS pipeline off
  static laya::program_owned::State s;
  laya::program_owned::step(s, cancel, result_consumed, program_owner,
      program_owner_receipt, program_pending, accepted_command, request_result,
      action_request, action_completion, action_completion_receipt);
  isolated = s.isolated;
}
#endif
