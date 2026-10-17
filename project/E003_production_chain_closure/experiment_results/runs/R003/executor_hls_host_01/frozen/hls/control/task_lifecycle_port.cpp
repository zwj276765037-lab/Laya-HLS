#include "laya_task_lifecycle_port.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::lifecycle {
namespace {
template<std::size_t Bytes>
void store(std::array<uint8_t, Bytes>& packet, unsigned beat,
           const ap_uint<512>& word) {
#pragma HLS inline off
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    packet[beat * 64 + byte] = uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
}

template<std::size_t Bytes>
ap_uint<512> word(const std::array<uint8_t, Bytes>& packet, unsigned beat) {
#pragma HLS inline off
  ap_uint<512> result = 0;
  for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
    result.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
  }
  return result;
}
} // namespace

void port_step(Port& p, full::FullRuntime& rt, const full::FullMemory& memory,
               bool cancel, bool consumed,
               hls::stream<ap_uint<512>>& action_request,
               hls::stream<ap_uint<512>>& action_completion,
               hls::stream<ap_uint<512>>& transaction_request,
               hls::stream<ap_uint<512>>& transaction_completion) {
#pragma HLS pipeline off
  switch (p.phase) {
    case PortPhase::READ_ACTION: {
      if (cancel && p.beat == 0) return;
      ap_uint<512> value;
      if (!action_request.read_nb(value)) return;
      if (p.beat == 0) p.consumed_pending = false;
      store(p.request_packet, p.beat, value);
      if (++p.beat == action::kRequestBeats) {
        p.beat = 0; p.phase = PortPhase::VALIDATE_ACTION;
      }
      return;
    }
    case PortPhase::VALIDATE_ACTION: {
      action::Request request;
      Check decoded = action::decode(p.request_packet, request);
      if (!decoded) {
        // No trusted key exists for a malformed frame.  Keep the frame and
        // isolate; never copy partially decoded fields into a safe completion.
        p.transport_error = decoded; p.phase = PortPhase::ISOLATED;
        return;
      }
      Check started = start(p.machine, rt, request);
      if (!started && p.machine.phase != Phase::COMPLETE) {
        p.transport_error = started; p.phase = PortPhase::ISOLATED;
        return;
      }
      p.phase = PortPhase::EXECUTE;
      return;
    }
    case PortPhase::EXECUTE:
      step(p.machine, rt, memory, cancel,
           transaction_request, transaction_completion);
      if (p.machine.phase == Phase::ISOLATED) {
        p.phase = PortPhase::ISOLATED;
      } else if (p.machine.phase == Phase::COMPLETE) {
        p.completion_packet = action::encode(p.machine.completion);
        p.beat = 0; p.phase = PortPhase::WRITE_COMPLETION;
      }
      return;
    case PortPhase::WRITE_COMPLETION:
      if (action_completion.write_nb(word(p.completion_packet, p.beat)) &&
          ++p.beat == action::kCompletionBeats) {
        p.beat = 0; p.consumed_pending = consumed;
        p.phase = PortPhase::WAIT_COMPLETION_CONSUMED;
      }
      return;
    case PortPhase::WAIT_COMPLETION_CONSUMED:
      if (p.consumed_pending || consumed) {
        Check released = completion_consumed(p.machine, rt);
        if (!released) {
          p.transport_error = released; p.phase = PortPhase::ISOLATED;
        } else {
          p.consumed_pending = false; p.phase = PortPhase::READ_ACTION;
        }
      }
      return;
    case PortPhase::ISOLATED:
      return;
  }
}
} // namespace laya::lifecycle
#endif
