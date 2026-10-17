#include "quant16.h"
#include "laya_numeric.h"

#include <cmath>

namespace laya::quant16 {
namespace {

bool finite32(float value) {
  return (numeric_f32_bits(value) & 0x7f800000u) != 0x7f800000u;
}

Check numerical(A8TileMeta& meta, unsigned row, unsigned col) {
  meta.state = CacheState::INVALID;
  meta.valid = false;
  return {Status::E_NUMERICAL, detail(7, uint8_t(Op::QUANT), 15),
          uint64_t(row) * 4096 + col};
}

Check malformed(A8TileMeta& meta) {
  meta.state = CacheState::INVALID;
  meta.valid = false;
  return {Status::E_PROTOCOL, detail(7, uint8_t(Op::QUANT), 5)};
}

struct ScalarReturn {
  uint32_t ordinal = 0;
  uint16_t row = 0, group = 0;
  uint8_t slot = 0;
  float d_full = 0, reciprocal = 0;
  uint16_t saved = 0;
  bool valid = false;
};

void record_first(Check candidate, uint64_t position,
                  Check& first, uint64_t& first_position) {
  if (first.code == Status::OK || position < first_position) {
    first = candidate;
    first_position = position;
  }
}

} // namespace

Check run(const Task& task, const F32TileMeta& source,
          const Beat beats[4096], AStore& output) {
  Check check = numeric_check_context(task.context, task.identity);
  if (!check) return check;
  check = numeric_check_ref(task.source, task.source_region);
  if (!check) return check;
  check = numeric_check_ref(task.destination);
  if (!check) return check;
  if (task.context.op != Op::QUANT || task.destination.id != Buffer::A8 ||
      task.destination_slot > 1 || task.destination.bank != task.destination_slot ||
      !task.context.rows || task.context.rows > 16 ||
      (task.K != 256 && task.K != 1024 && task.K != 2624 && task.K != 4096))
    return {Status::E_SHAPE, detail(7, uint8_t(Op::QUANT), 5)};
  bool legal_source = false;
  if (task.context.stage == 2 && task.context.row_space == RowSpace::TOKEN)
    legal_source = (task.K == 1024 &&
                    (task.source.id == Buffer::HIDDEN ||
                     task.source.id == Buffer::NORM ||
                     task.source.id == Buffer::ATT_OUT)) ||
                   (task.K == 2624 && task.source.id == Buffer::GATE);
  else if (task.context.stage == 4 && task.context.row_space == RowSpace::TOKEN)
    legal_source = (task.K == 1024 &&
                    (task.source.id == Buffer::HIDDEN ||
                     task.source.id == Buffer::NORM ||
                     task.source.id == Buffer::ATT_OUT)) ||
                   (task.K == 4096 && task.source.id == Buffer::DEC_FF);
  else if (task.context.stage == 5 && task.context.row_space == RowSpace::MARKER)
    legal_source = task.K == 1024 && task.source.id == Buffer::HEAD_WORK &&
                   task.source_region == uint8_t(Region::SCORER_ACT);
  else if (task.context.stage == 6 && task.context.row_space == RowSpace::BATCH)
    legal_source = task.K == 256 && task.source.id == Buffer::HEAD_WORK &&
                   task.source_region == uint8_t(Region::ACT_HIDDEN);
  if (!legal_source)
    return {Status::E_SHAPE, detail(7, uint8_t(Op::QUANT), 5)};
  check = numeric_check_source(source, task.identity, task.source,
                               task.source_region, task.context, task.K);
  if (!check) return check;
  A8TileMeta& meta = output.meta[task.destination_slot];
  check = numeric_claim_a8(meta, task.destination);
  if (!check) return check;
  meta.identity = task.identity;

  // Distinct capture, scalar issue/return and replay services share the 32
  // tagged slots. A slot is reserved from its first beat through the second
  // replay half; no return can publish into a reused slot. This schedule is
  // functional, not a timing model for the physical FP divider.
  GroupSlot slots[32] = {};
  ScalarReturn returns[32] = {};
  const unsigned groups = task.K / 32;
  const unsigned total = unsigned(task.context.rows) * groups;
  unsigned capture_next = 0, capture_half = 0;
  unsigned accepted = 0, scalar_next = 0, replay_next = 0, replay_half = 0;
  unsigned return_head = 0, return_tail = 0, return_count = 0;
  bool stop_capture = false;
  Check first = ok();
  uint64_t first_position = UINT64_MAX;
  output.peak_reserved_slots[task.destination_slot] = 0;
  output.scalar_issues[task.destination_slot] = 0;
  output.scalar_returns[task.destination_slot] = 0;
  for (unsigned step = 0; step < total * 8 + 128; ++step) {
    // Replay at most one 16-lane half. The next group can be in capture or
    // scalar service on the same schedule step.
    if (replay_next < accepted) {
      GroupSlot& slot = slots[replay_next % 32];
      if (slot.ordinal == replay_next && slot.phase == GroupPhase::FAILED) {
        slot.phase = GroupPhase::EMPTY;
        ++replay_next; replay_half = 0;
      } else if (slot.ordinal == replay_next &&
                 (slot.phase == GroupPhase::SCALAR_READY ||
                  slot.phase == GroupPhase::REPLAY)) {
        slot.phase = GroupPhase::REPLAY;
        bool bad = false;
        for (unsigned lane = 0; lane < 16; ++lane) {
          const unsigned i = replay_half * 16 + lane;
          float rounded = 0.0f;
          if (slot.d_full != 0.0f) {
            const float product = slot.x[i] * slot.reciprocal;
            if (!finite32(product)) {
              record_first(numerical(meta, slot.row, slot.group * 32 + i),
                           uint64_t(replay_next) * 32 + i, first, first_position);
              bad = true; break;
            }
            rounded = ::roundf(product);
          }
          if (!finite32(rounded) || rounded < -127.0f || rounded > 127.0f) {
            record_first(numerical(meta, slot.row, slot.group * 32 + i),
                         uint64_t(replay_next) * 32 + i, first, first_position);
            bad = true; break;
          }
          output.q[task.destination_slot][slot.row][slot.group][i] = int8_t(rounded);
        }
        if (bad) {
          stop_capture = true;
          slot.phase = GroupPhase::EMPTY;
          ++replay_next; replay_half = 0;
        } else if (replay_half == 1) {
          output.scale[task.destination_slot][slot.row][slot.group] = slot.saved;
          meta.covered_groups[slot.row][slot.group / 32] |=
              uint32_t(1) << (slot.group % 32);
          slot.phase = GroupPhase::COVERED;
          slot.phase = GroupPhase::EMPTY;
          ++replay_next; replay_half = 0;
        } else replay_half = 1;
      }
    }

    // Scalar return carries the complete slot identity. Reservation was
    // made before either dependent division was issued.
    if (return_count) {
      ScalarReturn result = returns[return_head];
      return_head = (return_head + 1) % 32;
      --return_count;
      GroupSlot& slot = slots[result.slot];
      if (slot.phase != GroupPhase::SCALAR_IN_FLIGHT ||
          slot.ordinal != result.ordinal || slot.row != result.row ||
          slot.group != result.group)
        return malformed(meta);
      ++output.scalar_returns[task.destination_slot];
      if (!result.valid) {
        record_first(numerical(meta, result.row, result.group * 32),
                     uint64_t(result.ordinal) * 32, first, first_position);
        slot.phase = GroupPhase::FAILED;
        stop_capture = true;
      } else {
        slot.d_full = result.d_full;
        slot.reciprocal = result.reciprocal;
        slot.saved = result.saved;
        output.d_full_bits[task.destination_slot][slot.row][slot.group] =
            numeric_f32_bits(slot.d_full);
        output.reciprocal_bits[task.destination_slot][slot.row][slot.group] =
            numeric_f32_bits(slot.reciprocal);
        slot.phase = GroupPhase::SCALAR_READY;
      }
    }

    if (scalar_next < accepted && return_count < 32) {
      GroupSlot& slot = slots[scalar_next % 32];
      if (slot.ordinal == scalar_next && slot.phase == GroupPhase::FAILED) {
        ++scalar_next;
      } else if (slot.ordinal == scalar_next &&
                 slot.phase == GroupPhase::FILLING) {
        slot.phase = GroupPhase::SCALAR_IN_FLIGHT;
        ScalarReturn& result = returns[return_tail];
        result.ordinal = scalar_next;
        result.row = slot.row; result.group = slot.group;
        result.slot = uint8_t(scalar_next % 32);
        result.d_full = slot.amax / 127.0f;
        result.reciprocal = result.d_full == 0.0f ? 0.0f : 1.0f / result.d_full;
        result.saved = numeric_f32_to_half_rne(result.d_full);
        result.valid = finite32(result.d_full) &&
                       finite32(result.reciprocal) &&
                       (result.saved & 0x7c00u) != 0x7c00u;
        return_tail = (return_tail + 1) % 32;
        ++return_count; ++scalar_next;
        ++output.scalar_issues[task.destination_slot];
      }
    }

    if (!stop_capture && capture_next < total) {
      GroupSlot& slot = slots[capture_next % 32];
      if (slot.phase == GroupPhase::EMPTY ||
          (slot.phase == GroupPhase::FILLING &&
           slot.ordinal == capture_next)) {
        const unsigned row = capture_next / groups;
        const unsigned group = capture_next % groups;
        if (capture_half == 0) {
          slot.ordinal = capture_next;
          slot.row = row; slot.group = group;
          slot.amax = 0.0f;
          slot.phase = GroupPhase::FILLING;
        }
        const Beat& beat = beats[capture_next * 2 + capture_half];
        if (beat.task_id != task.context.task_id ||
            beat.source_epoch != task.source.epoch ||
            beat.row != task.context.row0 + row ||
            beat.group != group || beat.half != capture_half ||
            beat.valid_mask != 0xffffu) {
          record_first(malformed(meta), uint64_t(capture_next) * 32,
                       first, first_position);
          slot.phase = GroupPhase::FAILED;
          stop_capture = true;
        } else {
          for (unsigned lane = 0; lane < 16; ++lane) {
            const unsigned i = capture_half * 16 + lane;
            const float value = numeric_bits_f32(beat.bits[lane]);
            slot.x[i] = value;
            if (!finite32(value)) {
              record_first(numerical(meta, row, group * 32 + i),
                           uint64_t(capture_next) * 32 + i,
                           first, first_position);
              slot.phase = GroupPhase::FAILED;
              stop_capture = true;
              break;
            }
            const float magnitude = ::fabsf(value);
            if (magnitude > slot.amax) slot.amax = magnitude;
          }
        }
        if (stop_capture || capture_half == 1) {
          ++accepted; ++capture_next; capture_half = 0;
        } else capture_half = 1;
      }
    }
    unsigned reserved = 0;
    for (unsigned i = 0; i < 32; ++i)
      if (slots[i].phase != GroupPhase::EMPTY) ++reserved;
    if (reserved > output.peak_reserved_slots[task.destination_slot])
      output.peak_reserved_slots[task.destination_slot] = uint16_t(reserved);
    if ((stop_capture || capture_next == total) && replay_next == accepted &&
        return_count == 0) break;
  }
  if (first.code != Status::OK) {
    meta.state = CacheState::INVALID;
    meta.valid = false;
    return first;
  }
  if (capture_next != total || scalar_next != total ||
      replay_next != total || return_count != 0) return malformed(meta);
  if (!numeric_coverage_complete(meta.covered_groups, task.context.rows,
                                 groups, 16)) return malformed(meta);
  meta.identity = task.identity;
  meta.ref = task.destination;
  meta.source = source;
  meta.producer_task_id = task.context.task_id;
  meta.stage = task.context.stage;
  meta.layer = task.context.layer;
  meta.row_space = task.context.row_space;
  meta.batch = task.context.batch;
  meta.row0 = task.context.row0;
  meta.rows = task.context.rows;
  meta.K = task.K;
  meta.content = Content::Q8_TILE;
  meta.state = CacheState::READY;
  meta.valid = true;
  return ok();
}

} // namespace laya::quant16
