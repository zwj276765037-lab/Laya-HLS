#pragma once

// Source contract for three independent bounded write-response owners.
// The installed Vitis synthesis and C simulation headers define burst_maxi.
#include "ap_int.h"
#include "hls_burst_maxi.h"
#include "hls_stream.h"
#include <cstddef>
#include <cstdint>
#ifndef __SYNTHESIS__
#include <mutex>
#endif

namespace c1_write {
constexpr unsigned kCommandBits = 618;
constexpr unsigned kAckBits = 37;
constexpr unsigned kPayloadWords = 16;
constexpr unsigned kCommandFifoDepth = 1;
constexpr unsigned kAckFifoDepth = 1;
constexpr unsigned kPorts = 3;
constexpr unsigned kPacketStorageBits =
    kPorts * (kCommandBits * (kCommandFifoDepth + 1) +
              kAckBits * kAckFifoDepth);
static_assert(kCommandBits == 64 + 5 + 3 + 2 + 32 + 512,
              "packed command width changed");
static_assert(kAckBits == 3 + 2 + 32, "packed acknowledgment width changed");
static_assert(kPacketStorageBits == 3819,
              "three FIFO pairs and three packet registers changed");

enum Kind : uint8_t {
  QUANT_Q = 0, QUANT_SCALE = 1, GROUP_TRACE = 2,
  FINAL_OUTPUT = 3, REPORT = 4, EOS = 7
};

// LSB first: offset[63:0], count[68:64], kind[71:69], slot[73:72],
// sequence[105:74], payload[617:106]. count=0 is reserved for EOS.
struct Command {
  ap_uint<64> word_offset;
  ap_uint<5> count;
  ap_uint<3> kind;
  ap_uint<2> trace_slot;
  ap_uint<32> sequence;
  ap_uint<512> payload;
};
struct Ack {
  ap_uint<3> kind;
  ap_uint<2> trace_slot;
  ap_uint<32> sequence;
};
using CommandWord = ap_uint<kCommandBits>;
using AckWord = ap_uint<kAckBits>;
using CommandStream = hls::stream<CommandWord>;
using AckStream = hls::stream<AckWord>;

inline CommandWord pack(const Command& c) {
  CommandWord raw = 0;
  raw.range(63, 0) = c.word_offset;
  raw.range(68, 64) = c.count;
  raw.range(71, 69) = c.kind;
  raw.range(73, 72) = c.trace_slot;
  raw.range(105, 74) = c.sequence;
  raw.range(617, 106) = c.payload;
  return raw;
}
inline Command unpack(CommandWord raw) {
  Command c = {};
  c.word_offset = raw.range(63, 0);
  c.count = raw.range(68, 64);
  c.kind = raw.range(71, 69);
  c.trace_slot = raw.range(73, 72);
  c.sequence = raw.range(105, 74);
  c.payload = raw.range(617, 106);
  return c;
}
inline AckWord pack(const Ack& a) {
  AckWord raw = 0;
  raw.range(2, 0) = a.kind;
  raw.range(4, 3) = a.trace_slot;
  raw.range(36, 5) = a.sequence;
  return raw;
}
inline Ack unpack(AckWord raw) {
  Ack a = {};
  a.kind = raw.range(2, 0);
  a.trace_slot = raw.range(4, 3);
  a.sequence = raw.range(36, 5);
  return a;
}
inline bool valid(const Command& c, bool observed_port) {
  if (c.kind == EOS)
    return c.count == 0 && c.trace_slot == 0;
  if (c.count == 0 || c.count > kPayloadWords) return false;
  if (!observed_port) return c.kind == FINAL_OUTPUT && c.trace_slot == 0 &&
                            c.count == 1;
  if (c.kind == QUANT_Q || c.kind == QUANT_SCALE || c.kind == REPORT)
    return c.trace_slot == 0;
  return c.kind == GROUP_TRACE && c.count == 8;
}
inline bool matches(const Ack& a, const Command& c) {
  return a.kind == c.kind && a.trace_slot == c.trace_slot &&
         a.sequence == c.sequence;
}

// Core-side one-debt ledger. The at-edge snapshot prohibits immediate reuse
// of credit released by an acknowledgment in this same logical edge.
struct Credit {
  bool unsettled;
  bool free_at_edge;
  bool stopped;
  ap_uint<32> next_sequence;
  Command expected;
  void reset_quiescent() {
    unsettled = false;
    free_at_edge = false;
    stopped = false;
    next_sequence = 0;
    expected = {};
  }
  void start_edge() { free_at_edge = !unsettled && !stopped; }
  bool poll(AckStream& acks, bool& got, Ack& received) {
    got = false;
    AckWord raw;
    if (!acks.read_nb(raw)) return true;
    received = unpack(raw);
    got = true;
    if (!unsettled || !matches(received, expected)) {
      stopped = true;
      return false;
    }
    unsettled = false;
    return true;
  }
  bool submit(CommandStream& commands, Command command, bool observed_port) {
    if (!free_at_edge || unsettled || stopped ||
        next_sequence == 0xffffffffu || !valid(command, observed_port))
      return false;
    command.sequence = next_sequence;
    if (!commands.write_nb(pack(command))) return false;
    expected = command;
    unsettled = true;
    free_at_edge = false;
    next_sequence = next_sequence + 1;
    return true;
  }
  bool drained() const { return !unsettled && !stopped; }
};

#ifndef __SYNTHESIS__
// The vendor CPU model stores all pointer records in one std::map. Guard
// calls from the three host actor threads; this is not a hardware mutex.
inline std::mutex& cpu_maxi_mutex() {
  static std::mutex lock;
  return lock;
}
#endif

// Exactly one packet register per actor. This is the only owner of its port.
// write_response returns only after the logical burst response is consumed;
// physical split-B aggregation still needs generated RTL proof.
inline void writer(hls::burst_maxi<uint32_t>& port, CommandStream& commands,
                   AckStream& acknowledgments, bool observed_port) {
#pragma HLS INLINE off
  while (true) {
    CommandWord packet = commands.read();
    const Command c = unpack(packet);
    if (!valid(c, observed_port)) {
#ifndef __SYNTHESIS__
      __builtin_trap();
#endif
      while (true) {}  // verification failure; never grant credit
    }
    if (c.kind == EOS) {
      acknowledgments.write(pack(Ack{c.kind, c.trace_slot, c.sequence}));
      break;
    }
#ifndef __SYNTHESIS__
    {
      std::lock_guard<std::mutex> lock(cpu_maxi_mutex());
#endif
    port.write_request(static_cast<size_t>(c.word_offset),
                       static_cast<unsigned>(c.count));
#ifndef __SYNTHESIS__
    }
#endif
    for (unsigned i = 0; i < static_cast<unsigned>(c.count); ++i) {
#pragma HLS PIPELINE II=1
      const uint32_t value = static_cast<uint32_t>(
          c.payload.range(i * 32 + 31, i * 32));
#ifndef __SYNTHESIS__
      {
        std::lock_guard<std::mutex> lock(cpu_maxi_mutex());
#endif
      port.write(value, ap_int<4>(-1));
#ifndef __SYNTHESIS__
      }
#endif
    }
#ifndef __SYNTHESIS__
    {
      std::lock_guard<std::mutex> lock(cpu_maxi_mutex());
#endif
    port.write_response();
#ifndef __SYNTHESIS__
    }
#endif
    acknowledgments.write(pack(Ack{c.kind, c.trace_slot, c.sequence}));
  }
}
inline void write_out0(hls::burst_maxi<uint32_t>& port,
                       CommandStream& commands, AckStream& acks) {
#pragma HLS INLINE off
  writer(port, commands, acks, false);
}
inline void write_out1(hls::burst_maxi<uint32_t>& port,
                       CommandStream& commands, AckStream& acks) {
#pragma HLS INLINE off
  writer(port, commands, acks, false);
}
inline void write_observed(hls::burst_maxi<uint32_t>& port,
                           CommandStream& commands, AckStream& acks) {
#pragma HLS INLINE off
  writer(port, commands, acks, true);
}
}  // namespace c1_write
