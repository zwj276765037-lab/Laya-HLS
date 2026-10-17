#include "laya_packet_equal.h"
#include "laya_executor_hls.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace {
using namespace laya;
enum class EntryPhase : uint8_t { FIRST, ADMIT, WRITE_OWNER, READ_OWNER_RECEIPT, RUN, REJECTED };
struct Entry {
  executor::State actor;
  executor_stream::Transport transport;
  EntryPhase phase = EntryPhase::FIRST;
  uint64_t session = 0;
  ap_uint<2496> configuration = 0;
  admission_owner::PhysicalMap physical;
  admission_owner::Packet owner_packet{};
  executor_stream::Frame<admission_owner::kBytes> owner_receipt;
  unsigned beat = 0;
  bool revoked = false;
};
ap_uint<512> owner_word(const admission_owner::Packet& p, unsigned beat) {
#pragma HLS inline off
  ap_uint<512> word = 0;
  for (unsigned b = 0; b < 64; ++b) {
#pragma HLS unroll off
    word.range(b * 8 + 7, b * 8) = p[beat * 64 + b];
  }
  return word;
}
void configure(Entry& s, full::FullMemory& m, uint8_t* io, const uint8_t* aux) {
#pragma HLS inline off
  s.physical.known_roles = admission_owner::kAllRoles;
  for (unsigned role = 0; role < 13; ++role) {
#pragma HLS unroll off
    auto& p = s.physical.role[role]; const unsigned bit = role * 192;
    p.epoch = s.configuration.range(bit + 63, bit);
    p.address = s.configuration.range(bit + 127, bit + 64);
    p.capacity = s.configuration.range(bit + 191, bit + 128);
  }
  m.io = io; m.aux = aux;
  m.embedding_bytes = s.physical.role[0].capacity;
  m.io_bytes = s.physical.role[1].capacity;
  m.w_q0_bytes = s.physical.role[2].capacity;
  m.w_q1_bytes = s.physical.role[3].capacity;
  m.w_scale_bytes = s.physical.role[4].capacity;
  m.aux_bytes = s.physical.role[5].capacity;
  m.state0_bytes = s.physical.role[6].capacity;
  m.state1_bytes = s.physical.role[7].capacity;
  m.qkv0_bytes = s.physical.role[8].capacity;
  m.qkv1_bytes = s.physical.role[9].capacity;
  m.ff0_bytes = s.physical.role[10].capacity;
  m.ff1_bytes = s.physical.role[11].capacity;
  m.att_out_bytes = s.physical.role[12].capacity;
#ifndef __SYNTHESIS__
  // These eleven pointers only satisfy host mapping checks. The generated
  // metadata partition has exactly two read masters; arithmetic uses adapter.
  m.embedding = reinterpret_cast<const uint8_t*>(s.physical.role[0].address);
  m.w_q0 = reinterpret_cast<const uint8_t*>(s.physical.role[2].address);
  m.w_q1 = reinterpret_cast<const uint8_t*>(s.physical.role[3].address);
  m.w_scale = reinterpret_cast<const uint8_t*>(s.physical.role[4].address);
  m.state0 = reinterpret_cast<uint8_t*>(s.physical.role[6].address);
  m.state1 = reinterpret_cast<uint8_t*>(s.physical.role[7].address);
  m.qkv0 = reinterpret_cast<uint8_t*>(s.physical.role[8].address);
  m.qkv1 = reinterpret_cast<uint8_t*>(s.physical.role[9].address);
  m.ff0 = reinterpret_cast<uint8_t*>(s.physical.role[10].address);
  m.ff1 = reinterpret_cast<uint8_t*>(s.physical.role[11].address);
  m.att_out = reinterpret_cast<uint8_t*>(s.physical.role[12].address);
#endif
}
} // namespace

extern "C" void laya_task_lifecycle_executor(
    uint8_t* io, const uint8_t* aux,
    bool first_valid, uint64_t hardware_session,
    const ap_uint<2496>& physical_config, bool physical_safe, bool cancel,
    bool checkpoint_valid, uint32_t source_epoch,
    uint64_t handoff_epoch, bool predecessor_held, bool source_held,
    bool target_held,
    bool& first_ready, bool& admission_valid, bool& admission_rejected,
    bool& program_result_consumed,
    hls::stream<ap_uint<8192>>& control_response_receipt,
    hls::stream<ap_uint<8192>>& control_response_rejection,
    hls::stream<ap_uint<512>>& admission_owner,
    hls::stream<ap_uint<512>>& admission_owner_receipt,
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
    hls::stream<ap_uint<512>>& action_completion_receipt,
    hls::stream<ap_uint<8192>>& program_owner,
    hls::stream<ap_uint<8192>>& program_owner_receipt,
    hls::stream<ap_uint<8192>>& program_pending) {
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface m_axi port=io offset=direct bundle=io depth=16920576 max_read_burst_length=64 num_read_outstanding=1
#pragma HLS interface m_axi port=aux offset=direct bundle=aux depth=1671872 max_read_burst_length=64 num_read_outstanding=1
#pragma HLS interface ap_none port=first_valid
#pragma HLS interface ap_none port=hardware_session
#pragma HLS interface ap_none port=physical_config
#pragma HLS interface ap_none port=physical_safe
#pragma HLS interface ap_none port=cancel
#pragma HLS interface ap_none port=checkpoint_valid
#pragma HLS interface ap_none port=source_epoch
#pragma HLS interface ap_none port=handoff_epoch
#pragma HLS interface ap_none port=predecessor_held
#pragma HLS interface ap_none port=source_held
#pragma HLS interface ap_none port=target_held
#pragma HLS interface ap_none port=first_ready
#pragma HLS interface ap_none port=admission_valid
#pragma HLS interface ap_none port=admission_rejected
#pragma HLS interface ap_fifo port=control_response_receipt
#pragma HLS interface ap_fifo port=control_response_rejection
#pragma HLS interface ap_none port=program_result_consumed
#pragma HLS interface ap_fifo port=admission_owner
#pragma HLS interface ap_fifo port=admission_owner_receipt
#pragma HLS interface ap_fifo port=control_request
#pragma HLS interface ap_fifo port=control_request_receipt
#pragma HLS interface ap_fifo port=control_response
#pragma HLS interface ap_fifo port=host_result_receipt
#pragma HLS interface ap_fifo port=checkpoint_request
#pragma HLS interface ap_fifo port=checkpoint_response
#pragma HLS interface ap_fifo port=accepted_command
#pragma HLS interface ap_fifo port=program_result
#pragma HLS interface ap_fifo port=request_result
#pragma HLS interface ap_fifo port=action_request
#pragma HLS interface ap_fifo port=action_completion
#pragma HLS interface ap_fifo port=transaction_request
#pragma HLS interface ap_fifo port=transaction_completion
#pragma HLS interface ap_fifo port=action_completion_receipt
#pragma HLS interface ap_fifo port=program_owner
#pragma HLS interface ap_fifo port=program_owner_receipt
#pragma HLS interface ap_fifo port=program_pending
#pragma HLS pipeline off
  static Entry s;
  s.transport.require_program_owner = true;
  first_ready = s.phase == EntryPhase::FIRST && physical_safe && !cancel;
  // Publish the accepted ingress fact only after the real full A consumer
  // confirms installation; an A producer's partial write grants nothing.
  admission_valid = s.phase == EntryPhase::RUN && s.actor.admitted_owner_valid;
  admission_rejected = s.phase == EntryPhase::REJECTED;
  program_result_consumed = s.actor.program_result_consumed;
  if (s.phase == EntryPhase::FIRST) {
    if (first_valid && first_ready) {
      // FIRST is used once from true static session initialization, never
      // asserted by Host or re-used after a rejected/closed request.
      s.session = hardware_session; s.configuration = physical_config;
      s.phase = hardware_session ? EntryPhase::ADMIT : EntryPhase::REJECTED;
    }
    return;
  }
  if (cancel || hardware_session != s.session ||
      physical_config != s.configuration) s.revoked = true;
  full::FullMemory memory;
  configure(s, memory, io, aux);
  if (uint64_t(reinterpret_cast<uintptr_t>(io)) != s.physical.role[1].address ||
      uint64_t(reinterpret_cast<uintptr_t>(aux)) != s.physical.role[5].address)
    s.revoked = true;
  executor::Inputs in;
  in.session = s.session; in.accepted_request = 1;
  in.request_valid = s.phase == EntryPhase::ADMIT;
  in.admission = {physical_safe, true}; // FIRST has no earlier result.
  in.physical_map = s.physical;
  in.cancel = s.revoked;
  in.source = {Buffer::HIDDEN, 0, source_epoch};
  const auto& base = s.physical.role[unsigned(Bo::STATE0)];
  in.fence.base = {base.epoch, base.address, base.capacity};
  in.fence.handoff_epoch = handoff_epoch;
  in.fence.physical_quiescent = physical_safe;
  in.fence.predecessor_dispatch_held = predecessor_held;
  in.fence.source_held = source_held; in.fence.target_held = target_held;
  in.checkpoint_valid = s.phase == EntryPhase::RUN && checkpoint_valid;
  bool response_receipt_consumed = false;
  if (s.transport.response_receipt_valid) {
    ap_uint<8192> packet = 0;
    for (unsigned b = 0; b < 1024; ++b) {
#pragma HLS unroll off
      packet.range(b * 8 + 7, b * 8) = s.transport.response_receipt[b];
    }
    // The generated FIFO write is the atomic whole-record handshake. In
    // production full_n is supplied directly by the unique complete shell
    // validator, not by an intermediate write-side buffering acknowledgement.
    response_receipt_consumed = s.transport.response_receipt_accepted ?
        control_response_receipt.write_nb(packet) :
        control_response_rejection.write_nb(packet);
  }
  if (s.phase == EntryPhase::ADMIT || s.phase == EntryPhase::RUN) {
    auto& t = s.transport;
    // The program receives the original complete GRANT only after the unique
    // shell has consumed its matching accepted receipt. No command precedes
    // the program's exact full-record installation receipt.
    if (t.program_owner_valid && !t.program_owner_sent &&
        !t.response_receipt_valid) {
      ap_uint<8192> packet = 0;
      for (unsigned b = 0; b < 1024; ++b) {
#pragma HLS unroll off
        packet.range(b * 8 + 7, b * 8) = t.program_owner[b];
      }
      t.program_owner_sent = program_owner.write_nb(packet);
    }
    if (!t.program_owner_confirmed && t.program_owner_sent && !t.transport_error) {
      ap_uint<8192> packet;
      if (program_owner_receipt.read_nb(packet)) {
        handoff::Packet echo{};
        for (unsigned b = 0; b < 1024; ++b) {
#pragma HLS unroll off
          echo[b] = uint8_t(packet.range(b * 8 + 7, b * 8));
        }
        handoff::Message decoded;
        if (handoff::decode(echo, decoded) && packet_equal(echo, t.program_owner) &&
            program_owner.empty()) t.program_owner_confirmed = true;
        else { t.transport_error = true; s.revoked = true; }
      }
    }
    if (t.program_owner_confirmed && !t.transport_error) {
      ap_uint<8192> packet;
      if (program_pending.read_nb(packet)) {
        program_pending::Packet pending{};
        for (unsigned b = 0; b < 1024; ++b) {
#pragma HLS unroll off
          pending[b] = uint8_t(packet.range(b * 8 + 7, b * 8));
        }
        program_pending::Record decoded;
        const program_pending::Key key{s.actor.session,
            s.actor.accepted_request_high_water,
            s.actor.checkpoint.pending.source.sequence,
            s.actor.checkpoint.pending.handoff_epoch};
        if (program_pending::decode(pending, decoded) &&
            program_pending::same_key(decoded.key, key) &&
            packet_equal(program_wire::encode(decoded.command), s.actor.command_packet) &&
            (!t.program_pending_valid || packet_equal(pending, t.program_pending))) {
          t.program_pending = pending; t.program_pending_valid = true;
        } else { t.transport_error = true; s.revoked = true; }
      }
    }
    executor_stream::step_in_place(s.actor, s.transport, memory, in, response_receipt_consumed,
        control_request, control_request_receipt, control_response,
        host_result_receipt, checkpoint_request, checkpoint_response,
        accepted_command, program_result, request_result, action_request,
        action_completion, transaction_request, transaction_completion,
        action_completion_receipt);
    if (s.phase == EntryPhase::ADMIT) {
      if (s.actor.admitted_owner_valid && s.actor.admissions == 1) {
        s.owner_packet = admission_owner::encode(s.actor.admitted_owner);
        s.phase = EntryPhase::WRITE_OWNER;
      } else if (s.actor.phase == executor::Phase::ISOLATED || s.revoked) {
        s.phase = EntryPhase::REJECTED;
      }
    }
    return;
  }
  if (s.phase == EntryPhase::WRITE_OWNER) {
    if (admission_owner.write_nb(owner_word(s.owner_packet, s.beat)) &&
        ++s.beat == admission_owner::kBeats) {
      s.beat = 0; s.phase = EntryPhase::READ_OWNER_RECEIPT;
    }
    return;
  }
  if (s.phase == EntryPhase::READ_OWNER_RECEIPT) {
    if (!s.owner_receipt.complete) {
      ap_uint<512> word;
      if (admission_owner_receipt.read_nb(word)) {
        for (unsigned b = 0; b < 64; ++b) {
#pragma HLS unroll off
          s.owner_receipt.packet[s.owner_receipt.beat * 64 + b] =
              uint8_t(word.range(b * 8 + 7, b * 8));
        }
        if (++s.owner_receipt.beat == admission_owner::kBeats)
          s.owner_receipt.complete = true;
      }
    } else {
      admission_owner::Record decoded;
      if (admission_owner::decode(s.owner_receipt.packet, decoded) &&
          packet_equal(s.owner_receipt.packet, s.owner_packet) && admission_owner.empty())
        s.phase = EntryPhase::RUN;
      else s.phase = EntryPhase::REJECTED;
    }
  }
}
#endif
