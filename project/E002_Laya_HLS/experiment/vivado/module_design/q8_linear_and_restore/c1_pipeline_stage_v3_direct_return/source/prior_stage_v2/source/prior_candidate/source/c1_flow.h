#pragma once

#include "ap_int.h"
#include <cstdint>

// Finite C1 scheduling state. Source cycle conventions are candidate values;
// generated hardware latency/ports remain unverified.
namespace c1 {

constexpr unsigned kResultSlots = 64;
constexpr unsigned kTraceSlots = 4;
constexpr unsigned kTileDepth = 656;
constexpr unsigned kResultPayloadBits = 1299;
constexpr unsigned kResultStateBits = 2;
constexpr unsigned kResultCandidateBits = kResultSlots * (kResultPayloadBits + kResultStateBits);
static_assert(kResultCandidateBits == 83264, "result register budget drift");
static_assert(1024 + 4*32 + 17 + 4 + 7 + 10 + 1 + 6 + 1 + 2 + 1 + 28 + 64 + 6 ==
              kResultPayloadBits, "result payload field budget drift");

enum ResultState : uint8_t { RESULT_FREE=0, RESULT_RESERVED=1, RESULT_RETURNED=2 };
enum TraceState : uint8_t { TRACE_FREE=0, TRACE_RESERVED=1, TRACE_READY=2,
                            TRACE_SENDING=3, TRACE_CANCELED=4 };

struct ResultPayload {
  ap_uint<32> next_ps[32];
  ap_uint<32> shape_mask, active_mask, success_mask, failure_mask;
  ap_uint<17> seq;
  ap_uint<4> m0;
  ap_uint<7> g;
  ap_uint<10> tile;
  ap_uint<1> last_g;
  ap_uint<6> result_slot;
  ap_uint<1> trace_reserved;
  ap_uint<2> trace_slot;
  ap_uint<1> error_valid;
  ap_uint<28> error_key;
  ap_uint<64> error_bad_element;
  ap_uint<6> active_dot_count;
};

inline ap_uint<kResultPayloadBits> pack_result(const ResultPayload& value) {
  ap_uint<kResultPayloadBits> out = 0;
  unsigned offset = 0;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    out.range(offset+31,offset)=value.next_ps[lane]; offset+=32;
  }
  out.range(offset+31,offset)=value.shape_mask; offset+=32;
  out.range(offset+31,offset)=value.active_mask; offset+=32;
  out.range(offset+31,offset)=value.success_mask; offset+=32;
  out.range(offset+31,offset)=value.failure_mask; offset+=32;
  out.range(offset+16,offset)=value.seq; offset+=17;
  out.range(offset+3,offset)=value.m0; offset+=4;
  out.range(offset+6,offset)=value.g; offset+=7;
  out.range(offset+9,offset)=value.tile; offset+=10;
  out[offset++]=value.last_g;
  out.range(offset+5,offset)=value.result_slot; offset+=6;
  out[offset++]=value.trace_reserved;
  out.range(offset+1,offset)=value.trace_slot; offset+=2;
  out[offset++]=value.error_valid;
  out.range(offset+27,offset)=value.error_key; offset+=28;
  out.range(offset+63,offset)=value.error_bad_element; offset+=64;
  out.range(offset+5,offset)=value.active_dot_count;
  return out;
}

inline ResultPayload unpack_result(ap_uint<kResultPayloadBits> raw) {
  ResultPayload value = {};
  unsigned offset = 0;
  for (unsigned lane=0;lane<32;++lane) {
#pragma HLS UNROLL
    value.next_ps[lane]=raw.range(offset+31,offset); offset+=32;
  }
  value.shape_mask=raw.range(offset+31,offset); offset+=32;
  value.active_mask=raw.range(offset+31,offset); offset+=32;
  value.success_mask=raw.range(offset+31,offset); offset+=32;
  value.failure_mask=raw.range(offset+31,offset); offset+=32;
  value.seq=raw.range(offset+16,offset); offset+=17;
  value.m0=raw.range(offset+3,offset); offset+=4;
  value.g=raw.range(offset+6,offset); offset+=7;
  value.tile=raw.range(offset+9,offset); offset+=10;
  value.last_g=raw[offset++];
  value.result_slot=raw.range(offset+5,offset); offset+=6;
  value.trace_reserved=raw[offset++];
  value.trace_slot=raw.range(offset+1,offset); offset+=2;
  value.error_valid=raw[offset++];
  value.error_key=raw.range(offset+27,offset); offset+=28;
  value.error_bad_element=raw.range(offset+63,offset); offset+=64;
  value.active_dot_count=raw.range(offset+5,offset);
  return value;
}

struct RankedError { bool valid; ap_uint<28> key; ap_uint<64> bad_element; };
inline ap_uint<28> error_key(unsigned tile, unsigned row, unsigned column,
                             unsigned group_or_G, unsigned phase) {
  return (ap_uint<28>(tile & 1023u) << 18) |
         (ap_uint<28>(row & 15u) << 14) |
         (ap_uint<28>(column & 7u) << 11) |
         (ap_uint<28>(group_or_G & 255u) << 3) |
         ap_uint<28>(phase & 7u);
}
inline void take_minimum(RankedError& current, bool candidate_valid,
                         ap_uint<28> key, ap_uint<64> bad_element) {
  if (candidate_valid && (!current.valid || key < current.key)) {
    current.valid=true; current.key=key; current.bad_element=bad_element;
  }
}

struct ASlot {
  ap_uint<1152> data;  // 4 x (256 Aq bits + 16 As bits + 16 spare/tag bits)
  ap_uint<4> m0;
  ap_uint<7> g;
  bool valid;
};

struct ResultRing {
  ap_uint<kResultPayloadBits> payload[kResultSlots];
  ap_uint<kResultStateBits> state[kResultSlots];
  ap_uint<6> issue_head, commit_head;
  ap_uint<7> free_count, reserved_count, returned_count, free_at_edge;

  void reset_metadata() {
    issue_head=0; commit_head=0; free_count=kResultSlots;
    reserved_count=0; returned_count=0; free_at_edge=0;
    for (unsigned i=0;i<kResultSlots;++i) state[i]=RESULT_FREE;
  }
  void start_edge() { free_at_edge=free_count; }
  bool can_reserve() const { return free_at_edge != 0 && state[issue_head]==RESULT_FREE; }
  bool reserve(ap_uint<6>& index) {
    if (!can_reserve()) return false;
    index=issue_head;
    state[index]=RESULT_RESERVED;
    issue_head=issue_head+1;
    --free_at_edge; --free_count; ++reserved_count;
    return true;
  }
  bool return_result(ap_uint<6> index, const ResultPayload& value) {
    if (state[index]!=RESULT_RESERVED || value.result_slot!=index) return false;
    payload[index]=pack_result(value);  // one full-vector reserved-index write
    state[index]=RESULT_RETURNED;
    --reserved_count; ++returned_count;
    return true;
  }
  bool can_commit() const { return state[commit_head]==RESULT_RETURNED; }
  bool peek_oldest(ResultPayload& value) const {
    if (!can_commit()) return false;
    value=unpack_result(payload[commit_head]);  // oldest-slot read
    return value.result_slot==commit_head;
  }
  bool retire_oldest() {
    if (!can_commit()) return false;
    state[commit_head]=RESULT_FREE;
    commit_head=commit_head+1;
    --returned_count; ++free_count;  // free_at_edge does not change
    return true;
  }
  bool commit_oldest(ResultPayload& value) {
    return peek_oldest(value) && retire_oldest();
  }
  bool conserved() const {
    return free_count+reserved_count+returned_count==kResultSlots &&
           state[issue_head]!=3 && state[commit_head]!=3;
  }
};

struct TraceRing {
  ap_uint<256> payload[kTraceSlots];
  ap_uint<3> state[kTraceSlots];
  ap_uint<17> seq[kTraceSlots];
  ap_uint<2> issue_head, drain_head;
  ap_uint<3> free_count, free_at_edge;

  void reset_metadata() {
    issue_head=0;drain_head=0;free_count=kTraceSlots;free_at_edge=0;
    for (unsigned i=0;i<kTraceSlots;++i) { state[i]=TRACE_FREE;seq[i]=0; }
  }
  void start_edge() { free_at_edge=free_count; }
  bool can_reserve() const { return free_at_edge!=0 && state[issue_head]==TRACE_FREE; }
  bool reserve(ap_uint<17> tag, ap_uint<2>& index) {
    if (!can_reserve()) return false;
    index=issue_head;state[index]=TRACE_RESERVED;seq[index]=tag;
    issue_head=issue_head+1;--free_at_edge;--free_count;
    return true;
  }
  bool return_payload(ap_uint<2> index, ap_uint<17> tag, ap_uint<256> data) {
    if (state[index]!=TRACE_RESERVED || seq[index]!=tag) return false;
    payload[index]=data;return true;
  }
  bool publish(ap_uint<2> index, ap_uint<17> tag, bool success) {
    if (state[index]!=TRACE_RESERVED || seq[index]!=tag) return false;
    state[index]=success ? TRACE_READY : TRACE_CANCELED;return true;
  }
  bool head_ready() const { return state[drain_head]==TRACE_READY; }
  bool head_canceled() const { return state[drain_head]==TRACE_CANCELED; }
  bool start_send(ap_uint<256>& data) {
    if (!head_ready()) return false;
    data=payload[drain_head];state[drain_head]=TRACE_SENDING;return true;
  }
  bool retire_head_after_b() {
    if (state[drain_head]!=TRACE_SENDING && state[drain_head]!=TRACE_CANCELED) return false;
    state[drain_head]=TRACE_FREE;drain_head=drain_head+1;++free_count;return true;
  }
};

struct TileHazards {
  bool busy[kTileDepth];
  bool committed[kTileDepth];
  uint32_t commit_edge[kTileDepth];
  void reset_metadata() {
    for (unsigned tile=0;tile<kTileDepth;++tile) {
      busy[tile]=false;committed[tile]=false;commit_edge[tile]=0;
    }
  }
  bool issue_ready(unsigned tile, uint32_t edge) const {
    return tile<kTileDepth && !busy[tile] &&
           (!committed[tile] || edge>commit_edge[tile]+1u);
  }
  void on_issue(unsigned tile) { busy[tile]=true; }
  void on_physical_commit(unsigned tile,uint32_t edge) {
    busy[tile]=false;committed[tile]=true;commit_edge[tile]=edge;
  }
};

}  // namespace c1
