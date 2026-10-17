#pragma once

#include "laya_numeric_tasks.h"
#include <cstdint>

namespace laya::quant16 {

// Separate 16-lane microbenchmark contract. QuantTask.input_lanes remains 8.
struct Task {
  NumericIdentity identity;
  TaskContext context;
  BufferRef source, destination;
  uint8_t source_region = 0;
  uint16_t K = 0;
  uint8_t destination_slot = 0;
};

struct Beat {
  uint32_t bits[16] = {};
  uint32_t task_id = 0, source_epoch = 0;
  uint16_t row = 0, group = 0;
  uint8_t half = 0;
  uint16_t valid_mask = 0;
};

enum class GroupPhase : uint8_t {
  EMPTY, FILLING, SCALAR_IN_FLIGHT, SCALAR_READY, REPLAY, COVERED, FAILED
};
struct GroupSlot {
  float x[32] = {};
  float amax = 0, d_full = 0, reciprocal = 0;
  uint16_t saved = 0, row = 0, group = 0;
  uint32_t ordinal = 0;
  GroupPhase phase = GroupPhase::EMPTY;
};

struct AStore {
  int8_t q[2][16][128][32] = {};
  uint16_t scale[2][16][128] = {};
  uint32_t d_full_bits[2][16][128] = {};
  uint32_t reciprocal_bits[2][16][128] = {};
  uint16_t peak_reserved_slots[2] = {};
  uint16_t scalar_issues[2] = {}, scalar_returns[2] = {};
  A8TileMeta meta[2] = {};
};

// Exactly two 16-F32 beats per Group32 in row/group order. The source must
// already be a fully published F32 tile. The other A slot is untouched.
Check run(const Task& task, const F32TileMeta& source,
          const Beat beats[4096], AStore& output);

} // namespace laya::quant16
