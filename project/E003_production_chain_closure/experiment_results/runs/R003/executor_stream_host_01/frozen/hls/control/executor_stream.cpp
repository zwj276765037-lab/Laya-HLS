#include "laya_executor_stream.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::executor_stream {
namespace {
template<unsigned Bytes>
void receive(Frame<Bytes>& frame, hls::stream<ap_uint<512>>& stream,
             uint64_t& reads) {
#pragma HLS inline off
  if (frame.complete) return;
  ap_uint<512> word;
  if (!stream.read_nb(word)) return;
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    frame.packet[frame.beat * 64 + byte] =
        uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  ++reads;
  if (++frame.beat == Bytes / 64) frame.complete = true;
}
template<unsigned Bytes> void release(Frame<Bytes>& frame) {
  // The ended transport has no remaining bytes; storage is retained for
  // diagnostics. No FIFO or active owner is cleared here.
  frame.beat = 0; frame.complete = false;
}
ap_uint<512> control_word(const handoff::Packet& packet, unsigned beat) {
#pragma HLS inline off
  ap_uint<512> word = 0;
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  }
  return word;
}
Check protocol() { return {Status::E_PROTOCOL, detail(7, 0, 14)}; }
} // namespace

void step(executor::State& actor, Transport& t, const full::FullMemory& memory,
    const executor::Inputs& live, bool response_receipt_ready,
    hls::stream<ap_uint<512>>& control_request,
    hls::stream<ap_uint<512>>& control_request_receipt,
    hls::stream<ap_uint<512>>& control_response,
    hls::stream<ap_uint<512>>& host_result_receipt,
    hls::stream<ap_uint<512>>& query, hls::stream<ap_uint<512>>& proof,
    hls::stream<ap_uint<512>>& commands, hls::stream<ap_uint<512>>& program_results,
    hls::stream<ap_uint<512>>& results, hls::stream<ap_uint<512>>& actions,
    hls::stream<ap_uint<512>>& completions,
    hls::stream<ap_uint<512>>& transactions,
    hls::stream<ap_uint<512>>& transaction_completions,
    hls::stream<ap_uint<512>>& action_completion_receipt) {
#pragma HLS pipeline off
  executor::Inputs in = live;
  // Production consumption facts come exclusively from the full-frame
  // consumers below. Abstract actor test controls cannot bypass them.
  in.control_request_consumed = false;
  in.control_response_valid = false;
  in.host_result_valid = false;
  in.result_consumed = false;
  in.action_completion_consumed = false;
  in.managed_close = true;
  if (t.first_admitted) in.request_valid = false;
  if (t.transport_error) in.cancel = true;

  if (t.response_receipt_valid && response_receipt_ready)
    t.response_receipt_valid = false;

  bool control_consumed = false;
  if (t.control_receipt.complete) {
    handoff::Message decoded;
    const bool valid = handoff::decode(t.control_receipt.packet, decoded) &&
        t.control_active && t.control_beat == handoff::kBeats &&
        control_request.empty() && actor.control_pending &&
        t.control_receipt.packet == t.control_packet &&
        t.control_packet == handoff::encode(actor.control_request);
    if (valid) {
      in.control_request_consumed = true;
      control_consumed = true; ++t.control_receipts;
      t.last_consumed_control = decoded;
      t.last_consumed_control_valid = true;
      t.last_control_response_consumed = false;
    } else ++t.rejected_control_receipts;
    release(t.control_receipt);
  } else {
    receive(t.control_receipt, control_request_receipt,
            t.control_receipt_reads);
  }

  bool response_offered = false;
  if (t.response.complete && !t.response_receipt_valid) {
    handoff::Message decoded;
    if (handoff::decode(t.response.packet, decoded)) {
      // A complete response may arrive before its request receipt because
      // the two actual channels have independent backpressure. Hold it until
      // the request-consumed fact reaches the actor's matching wait state.
      const bool revoked_import = actor.revoked &&
          actor.phase == executor::Phase::WAIT_ABORT &&
          t.last_consumed_control_valid &&
          t.last_consumed_control.kind == handoff::Kind::IMPORT_OK;
      if (actor.control_sent || control_consumed || revoked_import) {
        in.control_response = decoded; in.control_response_valid = true;
        response_offered = true;
      }
    } else {
      ++t.rejected_responses;
      t.transport_error = true; in.cancel = true;
      t.response_receipt = t.response.packet;
      t.response_receipt_accepted = false;
      t.response_receipt_valid = true;
      release(t.response);
    }
  } else if (!t.response_receipt_valid) {
    receive(t.response, control_response, t.response_reads);
  }

  if (t.host_receipt.complete) {
    program_wire::Result decoded;
    if (program_wire::decode(t.host_receipt.packet, decoded) &&
        actor.phase == executor::Phase::WAIT_RESULT_CONSUMED &&
        results.empty() && t.host_receipt.packet == actor.result_packet) {
      in.host_result_valid = true; in.host_result = t.host_receipt.packet;
      ++t.host_receipts;
    } else ++t.rejected_host_receipts;
    release(t.host_receipt);
  } else {
    receive(t.host_receipt, host_result_receipt, t.host_receipt_reads);
  }

  if (t.action_receipt.complete) {
    action::Completion decoded;
    const bool cancelled = actor.cancel_consumer.phase ==
        executor::CancelPhase::WAIT_COMPLETION_CONSUMED;
    const bool normal = actor.port.phase ==
        lifecycle::PortPhase::WAIT_COMPLETION_CONSUMED;
    const auto& expected = cancelled ? actor.cancel_consumer.completion_packet :
        actor.port.completion_packet;
    if ((normal || cancelled) && completions.empty() &&
        action::decode(t.action_receipt.packet, decoded) &&
        t.action_receipt.packet == expected) {
      in.action_completion_consumed = true; ++t.action_receipts;
    } else ++t.rejected_action_receipts;
    release(t.action_receipt);
  } else {
    receive(t.action_receipt, action_completion_receipt, t.action_receipt_reads);
  }

  const auto admissions = actor.admissions;
  const auto consumed_responses = actor.control_responses_consumed;
  executor::step(actor, memory, in, query, proof, commands, program_results,
                 results, actions, completions, transactions,
                 transaction_completions);
  if (actor.admissions != admissions) t.first_admitted = true;
  if (response_offered) {
    t.response_receipt = t.response.packet;
    t.response_receipt_accepted =
        actor.control_responses_consumed != consumed_responses;
    // Revocation can make the actor issue ABORT before a previously
    // presented GRANT reaches this complete consumer. The old actual IMPORT
    // receipt still binds that GRANT. Consume it without starting work, so
    // the shell's stable response cannot block the following old cleanup.
    // CLOSED never has this fallback: only the actor's exact terminal/commit
    // validator may acknowledge request release.
    if (!t.response_receipt_accepted && actor.revoked &&
        actor.phase == executor::Phase::WAIT_ABORT &&
        t.last_consumed_control_valid &&
        !t.last_control_response_consumed &&
        t.last_consumed_control.kind == handoff::Kind::IMPORT_OK &&
        in.control_response.kind == handoff::Kind::GRANTED &&
        handoff::same_key(in.control_response, t.last_consumed_control)) {
      t.response_receipt_accepted = true; ++t.revoked_grant_receipts;
    }
    if (t.response_receipt_accepted) t.last_control_response_consumed = true;
    t.response_receipt_valid = true;
    ++t.response_frames;
    if (!t.response_receipt_accepted) ++t.rejected_responses;
    release(t.response);
  }

  if (control_consumed) {
    t.control_active = false; t.control_beat = 0;
  }
  if (!t.control_active && actor.control_pending) {
    t.control_packet = handoff::encode(actor.control_request);
    t.control_active = true; t.control_beat = 0;
  }
  // A presented old packet is immutable, even if an unexpected actor change
  // occurs. Latch revocation while leaving old task cleanup runnable.
  if (t.control_active && actor.control_pending &&
      t.control_packet != handoff::encode(actor.control_request)) {
    t.transport_error = true;
    if (actor.error) actor.error = protocol();
    actor.revoked = true;
  }
  if (t.control_active && t.control_beat < handoff::kBeats &&
      control_request.write_nb(control_word(t.control_packet, t.control_beat))) {
    ++t.control_beat; ++t.control_writes;
  }
}
} // namespace laya::executor_stream
#endif
