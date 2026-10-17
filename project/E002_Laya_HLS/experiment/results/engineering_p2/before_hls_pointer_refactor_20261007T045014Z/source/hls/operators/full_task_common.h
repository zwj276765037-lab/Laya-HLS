#pragma once

#include "laya_full_runtime.h"
#include "laya_numeric.h"

namespace laya::full::task {

inline Check shape(Op op) {
  return {Status::E_SHAPE, detail(7, uint8_t(op), 5)};
}
inline Check buffer(Buffer id) {
  return {Status::E_BUFFER, detail(4, uint8_t(id), 9)};
}
inline Check numerical(Op op, uint64_t element) {
  return {Status::E_NUMERICAL, detail(7, uint8_t(op), 15), element};
}
inline bool finite(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
inline Check context(const FullRuntime& rt, const TaskContext& ctx) {
  if (!rt.request_valid || !rt.model_header_valid ||
      ctx.task_id != rt.last_task_id + 1 || ctx.task_id > kMaxEpoch)
    return {Status::E_PROTOCOL, detail(7, uint8_t(ctx.op), 4)};
  return check_context(ctx, rt.inputs.identity.B, rt.inputs.identity.S);
}
inline Check finish(FullRuntime& rt, const TaskContext& ctx, Check result,
                    OutputUnit unit, uint32_t elements, TaskDone& done) {
  done = TaskDone{};
  done.task_id = ctx.task_id;
  done.status = result.code;
  done.error_detail = result.detail;
  done.bad_element = result.bad_element;
  done.drained = true;
  if (result) {
    done.output_unit = unit;
    done.output_elements = elements;
  }
  if (ctx.task_id == rt.last_task_id + 1 && ctx.task_id <= kMaxEpoch) {
    rt.last_task_id = ctx.task_id;
    ++rt.tasks_retired;
    ++rt.op_calls[uint8_t(ctx.op)];
  }
  rt.expected_task_source_count = 0;
  return result;
}
inline FullOwnerSpec spec(BufferRef ref, uint8_t region, uint8_t stage,
                          uint8_t layer, RowSpace space, uint16_t extent,
                          uint16_t width, Content content = Content::F32) {
  return {ref, region, stage, layer, 255, space, 0, extent, width, content};
}
inline uint16_t extent(const FullRuntime& rt, RowSpace space) {
  return space == RowSpace::TOKEN ? rt.inputs.identity.S :
         space == RowSpace::MARKER ? 16 : 1;
}
inline FullOwnerSpec record_spec(const FullOwnerRecord& r) {
  return {r.ref, r.region, r.stage, r.layer, r.batch, r.row_space,
          r.row0, r.rows, r.width, r.content};
}
inline Check bound(const FullRuntime& rt, BufferRef ref, uint8_t region,
                   uint16_t width, FullOwnerSpec& out,
                   Content content = Content::F32) {
  for (unsigned i = 0; i < rt.expected_task_source_count; ++i) {
    const FullOwnerSpec& expected = rt.expected_task_source[i];
    if (expected.ref == ref && expected.region == region) {
      if (expected.content != content || expected.width != width)
        return buffer(ref.id);
      out = expected;
      return ok();
    }
  }
  return buffer(ref.id);
}
inline Check source(FullRuntime& rt, BufferRef ref, uint8_t region,
                    const TaskContext& ctx, uint16_t width,
                    FullOwnerSpec& out, Content content = Content::F32) {
  Check c = bound(rt, ref, region, width, out, content);
  if (!c) return c;
  if (out.row_space != ctx.row_space) return buffer(ref.id);
  return full_require_owner(rt, out, ctx.batch, ctx.row0, ctx.rows);
}
inline Check read(const FullRuntime& rt, BufferRef ref, uint8_t region,
                  uint8_t batch, uint16_t row, uint16_t col, float& output) {
  Address address;
  Check c = full_f32_address(rt, ref, region, batch, row, col, address);
  if (!c) return c;
  uint8_t raw[4];
  c = full_read(rt.memory, address.bo, address.offset, raw, 4);
  if (!c) return c;
  output = numeric_bits_f32(uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                            uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24);
  return ok();
}
inline Check write(FullRuntime& rt, BufferRef ref, uint8_t region,
                   uint8_t batch, uint16_t row, uint16_t col, float value) {
  Address address;
  Check c = full_f32_address(rt, ref, region, batch, row, col, address);
  if (!c) return c;
  const uint32_t bits = numeric_f32_bits(value);
  const uint8_t raw[4] = {uint8_t(bits), uint8_t(bits >> 8),
                          uint8_t(bits >> 16), uint8_t(bits >> 24)};
  return full_write(rt.memory, address.bo, address.offset, raw, 4);
}
inline Check read_tile(FullRuntime& rt, const FullOwnerSpec& src,
                       const TaskContext& ctx, uint16_t width,
                       float values[16][1024]) {
  Check c = full_acquire_owner(rt, src, ctx.batch, ctx.row0, ctx.rows);
  if (!c) return c;
  for (unsigned r = 0; r < ctx.rows && c; ++r)
    for (unsigned k = 0; k < width; ++k) {
      c = read(rt, src.ref, src.region, ctx.batch, uint16_t(ctx.row0 + r),
               uint16_t(k), values[r][k]);
      if (!c) break;
    }
  Check release = full_release_read_owner(rt, src);
  return c ? release : c;
}

} // namespace laya::full::task
