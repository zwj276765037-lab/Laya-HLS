#include "laya_full_runtime.h"

namespace laya::full {
namespace {

Check retirement_error(const TaskContext& context) {
  return {Status::E_PROTOCOL, detail(7, uint8_t(context.op), 14)};
}

bool same_done(const TaskContext& context, const TaskDone& done) {
  return done.task_id == context.task_id && done.drained;
}

bool store_contains(const FullRuntime::GeneratedStoreTracker::Geometry& g,
                    Address address, uint32_t bytes) {
  if (!bytes || address.bo != g.role || !g.segment_bytes ||
      !g.row_count || !g.repeat_count || bytes > g.segment_bytes)
    return false;
  const uint64_t first = address.offset;
  const uint64_t end = first + bytes;
  if (end < first) return false;
  for (uint16_t repeat = 0; repeat < g.repeat_count; ++repeat)
    for (uint16_t row = 0; row < g.row_count; ++row) {
      const uint64_t start = g.first_offset +
          uint64_t(repeat) * g.repeat_step + uint64_t(row) * g.row_step;
      const uint64_t limit = start + g.segment_bytes;
      if (limit >= start && first >= start && end <= limit) return true;
    }
  return false;
}

} // namespace

Check full_retire_prepared_task(FullRuntime& rt, const TaskContext& context,
                                const TaskDone& done) {
  if (!same_done(context, done) ||
      context.task_id != rt.last_task_id + 1 ||
      context.task_id > kMaxEpoch)
    return retirement_error(context);
  rt.last_task_id = context.task_id;
  ++rt.tasks_retired;
  ++rt.op_calls[uint8_t(context.op)];
  rt.expected_task_source_count = 0;
  return {done.status, done.error_detail, done.bad_element};
}

Check full_finish_task(FullRuntime& rt, const TaskContext& context,
                       Check result, OutputUnit unit, uint32_t elements,
                       TaskDone& done) {
  done = TaskDone{};
  done.task_id = context.task_id;
  done.status = result.code;
  done.error_detail = result.detail;
  done.bad_element = result.bad_element;
  done.drained = true;
  if (result) {
    done.output_unit = unit;
    done.output_elements = elements;
  }
  if (!rt.defer_task_retirement &&
      context.task_id == rt.last_task_id + 1 &&
      context.task_id <= kMaxEpoch) {
    rt.last_task_id = context.task_id;
    ++rt.tasks_retired;
    ++rt.op_calls[uint8_t(context.op)];
    rt.expected_task_source_count = 0;
  }
  return result;
}

Check full_note_generated_store(FullRuntime& rt, Address address,
                                uint32_t bytes) {
  auto& tracker = rt.generated_store;
  if (!tracker.active) return ok();
  unsigned match = 2;
  for (unsigned i = 0; i < tracker.descriptor_count; ++i) {
    if (!store_contains(tracker.geometry[i], address, bytes)) continue;
    if (match != 2) {
      const Check error{Status::E_PROTOCOL, detail(7, 0, 9)};
      if (tracker.first_error) tracker.first_error = error;
      return error;
    }
    match = i;
  }
  if (match == 2) {
    const Check error{Status::E_BUFFER, detail(4, 0, 8), address.offset};
    if (tracker.first_error) tracker.first_error = error;
    return error;
  }
  if (tracker.issued_bytes[match] > UINT64_MAX - bytes) {
    const Check error{Status::E_PROTOCOL, detail(7, 0, 9)};
    if (tracker.first_error) tracker.first_error = error;
    return error;
  }
  tracker.issued_bytes[match] += bytes;
  return ok();
}

} // namespace laya::full
