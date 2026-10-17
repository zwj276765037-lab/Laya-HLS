#include "laya_executor_transaction_export.h"
#include "laya_packet_equal.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::transaction_pending {
namespace {
bool transaction_phase(lifecycle::Phase phase) {
  return phase == lifecycle::Phase::TX_WRITE ||
      phase == lifecycle::Phase::TX_READ ||
      phase == lifecycle::Phase::TX_VALIDATE;
}

Key retained_key(const executor::State& a) {
  Key key;
  key.session = a.session;
  key.accepted_request = a.accepted_request_high_water;
  key.source_sequence = a.checkpoint.pending.source.sequence;
  key.handoff_epoch = a.checkpoint.pending.handoff_epoch;
  // This source handles only the actual post-GRANT executor action. No-HOLD
  // predecessor work needs its own real FSM exporter; it is not relabeled here.
  key.has_hold = a.checkpoint.hold_reserved;
  return key;
}

bool bound_action(const executor::State& a,
                  const executor_stream::Transport& t, const Key& key) {
#pragma HLS inline off
  if (!a.admitted_owner_valid || !t.program_owner_confirmed ||
      !t.program_pending_valid || !key.has_hold || !key.session ||
      !key.accepted_request || !key.source_sequence || !key.handoff_epoch ||
      key.session != a.admitted_owner.session ||
      key.accepted_request != a.admitted_owner.accepted_request ||
      portal::get(t.program_pending.data(), 16, 8) != key.session ||
      portal::get(t.program_pending.data(), 24, 8) != key.accepted_request ||
      portal::get(t.program_pending.data(), 32, 8) != key.source_sequence ||
      portal::get(t.program_pending.data(), 40, 8) != key.handoff_epoch ||
      !numeric_identity_equal(a.port.machine.action.identity,
                              a.admitted_owner.identity)) return false;
  // The unique top consumer already validated the complete LAP codec, key,
  // command and duplicate bytes before setting program_pending_valid.
  for (unsigned i = 0; i < action::kRequestBytes; ++i) {
#pragma HLS unroll off
    if (a.port.request_packet[i] !=
        t.program_pending[program_pending::kAction + i]) return false;
  }
  return packet_equal(action::encode(a.port.machine.action), a.port.request_packet);
}

bool snapshot_unchanged(const Exporter& e, const executor::State& a) {
#pragma HLS inline off
  for (unsigned i = 0; i < action::kRequestBytes; ++i) {
#pragma HLS unroll off
    if (e.packet[kAction + i] != a.port.request_packet[i]) return false;
  }
  for (unsigned i = 0; i < transaction::kRequestBytes; ++i) {
#pragma HLS unroll off
    if (e.packet[kTransaction + i] != a.port.machine.request_packet[i]) return false;
  }
  return true;
}

void capture_snapshot(Exporter& e, const executor::State& a, const Key& key) {
#pragma HLS inline off
  for (unsigned i = 0; i < 64; ++i) {
#pragma HLS unroll off
    e.packet[i] = 0;
  }
  portal::put(e.packet.data(), 0, kMagic, 4);
  portal::put(e.packet.data(), 4, kVersion, 2);
  portal::put(e.packet.data(), 6, kBeats, 2);
  e.packet[8] = 1; // The actual executor physical stream, never a live route.
  e.packet[9] = HAS_HOLD;
  portal::put(e.packet.data(), 16, key.session, 8);
  portal::put(e.packet.data(), 24, key.accepted_request, 8);
  portal::put(e.packet.data(), 32, key.source_sequence, 8);
  portal::put(e.packet.data(), 40, key.handoff_epoch, 8);
  for (unsigned i = 0; i < action::kRequestBytes; ++i) {
#pragma HLS unroll off
    e.packet[kAction + i] = a.port.request_packet[i];
  }
  for (unsigned i = 0; i < transaction::kRequestBytes; ++i) {
#pragma HLS unroll off
    e.packet[kTransaction + i] = a.port.machine.request_packet[i];
  }
  e.key = key;
  e.beat = 0;
  e.written = false;
  e.active = true;
}
} // namespace

void export_step(Exporter& e, const executor::State& a,
                 const executor_stream::Transport& t,
                 lifecycle::Phase before, unsigned before_beat,
                 hls::stream<ap_uint<512>>& output) {
#pragma HLS pipeline off
  const auto phase = a.port.machine.phase;
  const Key key = retained_key(a);
  const bool sent = !transaction_phase(before) &&
      a.port.phase == lifecycle::PortPhase::EXECUTE &&
      phase == lifecycle::Phase::TX_WRITE && a.port.machine.beat == 0;
  if (sent) {
    if (e.active || e.protocol_error || !bound_action(a, t, key)) {
      e.protocol_error = true;
    } else {
      capture_snapshot(e, a, key);
    }
  }
  if (e.active && !e.written) {
    // This uses retained bytes even if later live inputs/revoke change. It
    // neither freezes the actor nor waits for an LTX pop to create metadata.
    ap_uint<512> word = 0;
    for (unsigned i = 0; i < 64; ++i) {
#pragma HLS unroll off
      word.range(i * 8 + 7, i * 8) = e.packet[e.beat * 64 + i];
    }
    if (output.write_nb(word) && ++e.beat == kBeats) e.written = true;
  }
  const bool last_completion_pop = before == lifecycle::Phase::TX_READ &&
      before_beat == transaction::kCompletionBeats - 1 &&
      phase == lifecycle::Phase::TX_VALIDATE && a.port.machine.beat == 0;
  if (last_completion_pop) {
    // A complete LTP must have reached its real collector before it can
    // dispatch the matching LTX and return this LTC. A premature test peer
    // cannot make an incomplete metadata frame disappear.
    if (e.active && e.written && same_key(e.key, key) &&
        snapshot_unchanged(e, a)) {
      e.active = false;
    } else {
      e.protocol_error = true;
    }
  }
}
} // namespace laya::transaction_pending
#endif
