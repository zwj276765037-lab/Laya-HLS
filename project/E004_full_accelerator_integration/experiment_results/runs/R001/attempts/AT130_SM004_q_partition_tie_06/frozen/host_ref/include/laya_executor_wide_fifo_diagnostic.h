#pragma once
#ifndef AP_INT_MAX_W
#define AP_INT_MAX_W 8192
#endif
#include <ap_int.h>

#if defined(LAYA_WIDE_FIFO_DIAGNOSTIC_HOST_FIFO) && defined(__SYNTHESIS__)
#error "The bounded host peer must never enter the synthesis source closure"
#endif

// The installed host hls::stream model has no capacity and write_nb cannot
// fail. This test-only depth2 peer exercises the same source's real nb calls;
// synthesis always uses the installed Vitis stream and its real FIFO pins.
#ifdef LAYA_WIDE_FIFO_DIAGNOSTIC_HOST_FIFO
#include <array>
#include <cstddef>
namespace hls {
template<class T, int Depth=0> class stream {
 public:
  bool read_nb(T& value) {
    ++read_attempts;
    if (!count_) return false;
    value = words_[read_index_]; read_index_ ^= 1; --count_; ++reads;
    return true;
  }
  bool write_nb(const T& value) {
    ++write_attempts;
    if (count_ == 2) {
      ++blocked_writes;
      if (!blocking_) { blocked_word_=value; blocking_=true; }
      else if (value != blocked_word_) blocked_payload_changed=true;
      return false;
    }
    blocking_=false;
    words_[write_index_] = value; write_index_ ^= 1; ++count_; ++writes;
    return true;
  }
  bool empty() const { return count_ == 0; }
  bool full() const { return count_ == 2; }
  std::size_t size() const { return count_; }
  const T& front() const { return words_[read_index_]; }
  const T& blocked_word() const { return blocked_word_; }
  bool blocked_payload_changed=false;
  unsigned long long reads=0,writes=0,read_attempts=0,write_attempts=0,blocked_writes=0;
 private:
  std::array<T, 2> words_{};
  T blocked_word_{};
  bool blocking_=false;
  unsigned read_index_=0,write_index_=0,count_=0;
};
} // namespace hls
#else
#include <hls_stream.h>
#endif

// Raw diagnostic transport only. These names match the executor directions;
// no output creates admission, shell acceptance, helper commit, or retirement.
extern "C" void laya_executor_wide_fifo_diagnostic(
    hls::stream<ap_uint<8192>>& control_response_receipt,
    hls::stream<ap_uint<8192>>& control_response_rejection,
    hls::stream<ap_uint<8192>>& program_owner,
    hls::stream<ap_uint<8192>>& program_owner_receipt,
    hls::stream<ap_uint<8192>>& program_pending);
