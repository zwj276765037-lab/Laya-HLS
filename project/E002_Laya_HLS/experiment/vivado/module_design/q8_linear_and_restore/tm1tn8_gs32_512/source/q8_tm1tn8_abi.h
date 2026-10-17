#pragma once

#include <cstdint>

// The joint-prototype command is exactly 128 little-endian U32 words. This
// header describes indices and decoded scalar state; no C++ object layout is
// serialized to the descriptor or retained with an external AXI pointer.
namespace q8_tm1tn8 {

constexpr uint32_t kDescriptorWords = 128;
constexpr uint32_t kDescriptorMagic = 0x31543851u;
constexpr uint32_t kDescriptorVersion = 1;
constexpr uint32_t kObservedWords = 32768;
constexpr uint32_t kObservedMagic = 0x51384f42u;
constexpr uint32_t kObservedVersion = 1;
constexpr uint32_t kMaximumEpoch = 0xfffffffeu;

enum Command : uint32_t { LOAD_W = 0, RUN_TILE = 1 };

enum DescriptorWord : uint32_t {
  D_MAGIC = 0, D_VERSION = 1, D_COMMAND = 2, D_FLAGS = 3,
  D_REQUEST_LO = 4, D_REQUEST_HI = 5,
  D_GENERATION_LO = 6, D_GENERATION_HI = 7,
  D_TASK_ID = 8, D_OP = 9, D_STAGE = 10, D_LAYER = 11,
  D_B = 12, D_S = 13, D_BATCH = 14, D_ROW0 = 15,
  D_ROWS = 16, D_K = 17, D_N = 18,
  D_WEIGHT_FAMILY = 19, D_WEIGHT_LAYER = 20,
  D_SRC_ID = 21, D_SRC_BANK = 22, D_SRC_EPOCH = 23, D_SRC_REGION = 24,
  D_DST_ID = 25, D_DST_BANK = 26, D_DST_EPOCH = 27, D_DST_REGION = 28,
  D_W_EPOCH = 29, D_PS_EPOCH = 30, D_QUANT_TASK_ID = 31,
  D_MODEL_TAG_0 = 32, D_NUMERIC_TAG_0 = 36,
  D_LAYOUT_TAG_0 = 40, D_BUILD_TAG_0 = 44,
  D_ACT_BASE_LO = 48, D_ACT_BASE_HI = 49,
  D_OUT0_BASE_LO = 50, D_OUT0_BASE_HI = 51,
  D_OUT1_BASE_LO = 52, D_OUT1_BASE_HI = 53,
  D_ACT_SPAN_LO = 54, D_ACT_SPAN_HI = 55,
  D_OUT0_SPAN_LO = 56, D_OUT0_SPAN_HI = 57,
  D_OUT1_SPAN_LO = 58, D_OUT1_SPAN_HI = 59,
  D_TRACE_ROW_LOCAL = 60, D_TRACE_COLUMN = 61,
  D_OBSERVED_WORDS = 62, D_ZERO_63 = 63,
  D_RESERVED_BEGIN = 64
};

// Every command writes the fixed status header. A failing command may leave
// already acknowledged output bytes, but its state/TaskDone is never READY.
enum ObservedWord : uint32_t {
  O_MAGIC = 0, O_VERSION = 1, O_COMMAND = 2, O_STATUS = 3,
  O_DETAIL = 4, O_BAD_ELEMENT_LO = 5, O_BAD_ELEMENT_HI = 6,
  O_COMMAND_TASK = 7, O_LAST_TASK = 8, O_DONE_TASK = 9,
  O_DONE_STATUS = 10, O_DONE_DRAINED = 11,
  O_DONE_OUTPUT_ELEMENTS = 12, O_DONE_OUTPUT_UNIT = 13,
  O_REQUEST_LO = 14, O_REQUEST_HI = 15,
  O_GENERATION_LO = 16, O_GENERATION_HI = 17,
  O_B = 18, O_S = 19, O_STAGE = 20, O_LAYER = 21,
  O_BATCH = 22, O_ROW0 = 23, O_ROWS = 24, O_K = 25, O_N = 26,
  O_WEIGHT_FAMILY = 27, O_WEIGHT_LAYER = 28,
  O_W_EPOCH = 29, O_A8_EPOCH = 30, O_PS_EPOCH = 31,
  O_SRC_ID = 32, O_SRC_BANK = 33, O_SRC_EPOCH = 34, O_SRC_REGION = 35,
  O_DST_ID = 36, O_DST_BANK = 37, O_DST_EPOCH = 38, O_DST_REGION = 39,
  O_W_STATE = 40, O_A8_STATE = 41, O_PS_STATE = 42, O_DST_STATE = 43,
  O_W_MAX_CLAIMED = 44, O_A8_MAX_CLAIMED = 45,
  O_PS_MAX_CLAIMED = 46, O_DST_MAX_CLAIMED = 47,
  O_W_LOADS = 48, O_W_REUSES = 49,
  O_QUANT_GROUPS = 50, O_QUANT_INPUTS = 51,
  O_ACCEPTED_ISSUES = 52, O_INFLIGHT = 53,
  O_RETIRED_GROUPS = 54, O_COMMITTED_WRITES = 55,
  O_DOT_MACS_LO = 56, O_DOT_MACS_HI = 57,
  O_TRACE_ROW = 58, O_TRACE_COLUMN = 59,
  O_TRACE_BIAS_BITS = 60, O_TRACE_BIAS_ENABLE = 61,
  O_TRACE_FINAL_BITS = 62, O_TRACE_GROUP_COUNT = 63,
  O_PORT_BYTES_BEGIN = 64, O_PORT_BYTES_END = 100,
  O_MODEL_TAG_0 = 100, O_NUMERIC_TAG_0 = 104,
  O_LAYOUT_TAG_0 = 108, O_BUILD_TAG_0 = 112,
  O_QUANT_DONE_TASK = 116, O_QUANT_DONE_STATUS = 117,
  O_QUANT_DONE_DRAINED = 118, O_LINEAR_STARTED = 119,
  O_LOAD_STARTED = 120, O_ERROR_PHASE = 121,
  O_HEADER_RESERVED_BEGIN = 122,
  O_HEADER_WORDS = 256
};

enum Port : uint32_t {
  P_DESCRIPTOR = 0, P_W_Q0 = 1, P_W_Q1 = 2, P_W_SCALE = 3,
  P_AUX = 4, P_ACTIVATION = 5, P_OUT0 = 6, P_OUT1 = 7,
  P_OBSERVED = 8, P_COUNT = 9
};

constexpr uint32_t port_useful_lo(Port p) {
  return O_PORT_BYTES_BEGIN + 4u * uint32_t(p);
}
constexpr uint32_t port_useful_hi(Port p) { return port_useful_lo(p) + 1u; }
constexpr uint32_t port_total_lo(Port p) { return port_useful_lo(p) + 2u; }
constexpr uint32_t port_total_hi(Port p) { return port_useful_lo(p) + 3u; }

constexpr uint32_t kTraceQWord = 256;
constexpr uint32_t kTraceQCapacityWords = 16384;
constexpr uint32_t kTraceScaleWord = kTraceQWord + kTraceQCapacityWords;
constexpr uint32_t kTraceScaleCapacityWords = 1024;
constexpr uint32_t kTraceGroupWord = kTraceScaleWord + kTraceScaleCapacityWords;
constexpr uint32_t kTraceGroupWords = 8;
constexpr uint32_t kTraceGroupCapacity = 128;
static_assert(kTraceGroupWord + kTraceGroupWords * kTraceGroupCapacity <=
                  kObservedWords, "observed trace layout");
static_assert(port_total_hi(P_OBSERVED) + 1u == O_PORT_BYTES_END,
              "observed per-port byte region");

// Trace group words: dot I32 two's-complement, sa F32, sw F32, scale product
// F32, term F32, committed PS F32, group index and valid=1. Only the selected
// actual output lane writes these words after the real arithmetic retires.
enum TraceGroupField : uint32_t {
  T_DOT = 0, T_SA = 1, T_SW = 2, T_PRODUCT = 3,
  T_TERM = 4, T_PS = 5, T_GROUP = 6, T_VALID = 7
};

struct Ref {
  uint32_t id = 0, bank = 0, epoch = 0, region = 0;
};

struct Descriptor {
  uint32_t command = 0, flags = 0;
  uint64_t request_id = 0, generation = 0;
  uint32_t task_id = 0, op = 0, stage = 0, layer = 0;
  uint32_t B = 0, S = 0, batch = 0, row0 = 0, rows = 0;
  uint32_t K = 0, N = 0, family = 0, weight_layer = 0;
  Ref src, dst;
  uint32_t w_epoch = 0, ps_epoch = 0, quant_task_id = 0;
  uint32_t tags[4][4] = {};
  uint64_t activation_base = 0, out0_base = 0, out1_base = 0;
  uint64_t activation_span = 0, out0_span = 0, out1_span = 0;
  uint32_t trace_row_local = 0, trace_column = 0;
};

constexpr uint64_t join_u64(uint32_t lo, uint32_t hi) {
  return uint64_t(lo) | (uint64_t(hi) << 32);
}
constexpr uint32_t lo32(uint64_t value) { return uint32_t(value); }
constexpr uint32_t hi32(uint64_t value) { return uint32_t(value >> 32); }

}  // namespace q8_tm1tn8
