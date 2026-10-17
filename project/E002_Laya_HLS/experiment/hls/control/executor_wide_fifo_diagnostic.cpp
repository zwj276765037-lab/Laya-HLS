#include "laya_executor_wide_fifo_diagnostic.h"
#include <array>
#include <cstdint>

namespace {
using Packet = std::array<uint8_t, 1024>;
struct DiagnosticState {
  Packet owner{},pending{},mixed{};
  bool owner_collected=false,pending_collected=false,emitting=false;
  bool receipt_sent=false,rejection_sent=false,owner_sent=false;
};

void collect(Packet& packet, const ap_uint<8192>& word) {
#pragma HLS inline off
  for (unsigned byte=0; byte<1024; ++byte) {
#pragma HLS unroll off
    packet[byte] = uint8_t(word.range(byte*8+7, byte*8));
  }
}

ap_uint<8192> repack(const Packet& packet) {
#pragma HLS inline off
  ap_uint<8192> word=0;
  for (unsigned byte=0; byte<1024; ++byte) {
#pragma HLS unroll off
    word.range(byte*8+7, byte*8) = packet[byte];
  }
  return word;
}
} // namespace

extern "C" void laya_executor_wide_fifo_diagnostic(
    hls::stream<ap_uint<8192>>& control_response_receipt,
    hls::stream<ap_uint<8192>>& control_response_rejection,
    hls::stream<ap_uint<8192>>& program_owner,
    hls::stream<ap_uint<8192>>& program_owner_receipt,
    hls::stream<ap_uint<8192>>& program_pending) {
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_fifo port=control_response_receipt
#pragma HLS interface ap_fifo port=control_response_rejection
#pragma HLS interface ap_fifo port=program_owner
#pragma HLS interface ap_fifo port=program_owner_receipt
#pragma HLS interface ap_fifo port=program_pending
#pragma HLS pipeline off
  static DiagnosticState state;
  if (!state.emitting) {
    ap_uint<8192> word;
    if (!state.owner_collected && program_owner_receipt.read_nb(word)) {
      collect(state.owner, word); state.owner_collected=true;
    }
    if (!state.pending_collected && program_pending.read_nb(word)) {
      collect(state.pending, word); state.pending_collected=true;
    }
    if (state.owner_collected && state.pending_collected) {
      // The third output depends on every byte of both actually consumed
      // inputs. This XOR is a byte oracle diagnostic, not a protocol packet.
      for (unsigned byte=0; byte<1024; ++byte) {
#pragma HLS unroll off
        state.mixed[byte] = uint8_t(state.owner[byte] ^ state.pending[byte]);
      }
      state.emitting=true;
    }
    return;
  }
  // Each full write failure retains the original complete record and lane.
  // No new input pair can overwrite either old input while an output waits.
  if (!state.receipt_sent)
    state.receipt_sent=control_response_receipt.write_nb(repack(state.owner));
  if (!state.rejection_sent)
    state.rejection_sent=control_response_rejection.write_nb(repack(state.pending));
  if (!state.owner_sent)
    state.owner_sent=program_owner.write_nb(repack(state.mixed));
  if (state.receipt_sent && state.rejection_sent && state.owner_sent) {
    state.owner_collected=false; state.pending_collected=false; state.emitting=false;
    state.receipt_sent=false; state.rejection_sent=false; state.owner_sent=false;
  }
}
