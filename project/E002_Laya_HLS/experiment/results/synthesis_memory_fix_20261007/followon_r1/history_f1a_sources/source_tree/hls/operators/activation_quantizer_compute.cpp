#include "laya_numeric.h"

#include <cmath>

namespace laya {
namespace {
bool finite32(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
Check numerical(A8TileMeta& result, unsigned row, unsigned col) {
  result.state = CacheState::INVALID;
  result.valid = false;
  return {Status::E_NUMERICAL, detail(7, uint8_t(Op::QUANT), 15),
          uint64_t(row) * 4096 + col};
}
Check validate_task(const QuantTask& t, const NumericIdentity& id) {
  Check c = numeric_check_context(t.ctx, id);
  if (!c) return c;
  c = numeric_check_ref(t.src, t.src_region);
  if (!c) return c;
  c = numeric_check_ref(t.a_dst);
  if (!c) return c;
  if (t.ctx.op != Op::QUANT || t.a_dst.id != Buffer::A8 ||
      t.input_lanes != 8)
    return {Status::E_SHAPE, detail(7, uint8_t(t.ctx.op), 5)};
  bool valid = false;
  if (t.ctx.stage == 2 && t.ctx.row_space == RowSpace::TOKEN)
    valid = (t.K == 1024 && (t.src.id == Buffer::HIDDEN ||
                              t.src.id == Buffer::NORM ||
                              t.src.id == Buffer::ATT_OUT)) ||
            (t.K == 2624 && t.src.id == Buffer::GATE);
  else if (t.ctx.stage == 4 && t.ctx.row_space == RowSpace::TOKEN)
    valid = (t.K == 1024 && (t.src.id == Buffer::HIDDEN ||
                              t.src.id == Buffer::NORM ||
                              t.src.id == Buffer::ATT_OUT)) ||
            (t.K == 4096 && t.src.id == Buffer::DEC_FF);
  else if (t.ctx.stage == 5 && t.ctx.row_space == RowSpace::MARKER)
    valid = t.K == 1024 && t.src.id == Buffer::HEAD_WORK &&
            t.src_region == uint8_t(Region::SCORER_ACT);
  else if (t.ctx.stage == 6 && t.ctx.row_space == RowSpace::BATCH)
    valid = t.K == 256 && t.src.id == Buffer::HEAD_WORK &&
            t.src_region == uint8_t(Region::ACT_HIDDEN);
  return valid ? ok() : Check{Status::E_SHAPE, detail(7, uint8_t(t.ctx.op), 5)};
}
} // namespace

Check activation_quantizer_compute(const QuantTask& task,
                                   const NumericIdentity& request,
                                   const F32TileMeta& source,
                                   const float x[16][4096],
                                   int8_t q[16][128][32],
                                   uint16_t scale_bits[16][128],
                                   A8TileMeta& result) {
  Check c = validate_task(task, request);
  if (!c) return c;
  c = numeric_check_source(source, request, task.src, task.src_region,
                           task.ctx, task.K);
  if (!c) return c;
  c = numeric_claim_a8(result, task.a_dst);
  if (!c) return c;
  result.identity = request;

  float group[32];
  const unsigned groups = task.K / 32;
  for (unsigned r = 0; r < task.ctx.rows; ++r) {
    for (unsigned g = 0; g < groups; ++g) {
      float amax = 0.0f;
      for (unsigned i = 0; i < 32; ++i) {
        group[i] = x[r][g * 32 + i];
        if (!finite32(group[i])) return numerical(result, r, g * 32 + i);
        const float mag = ::fabsf(group[i]);
        if (mag > amax) amax = mag;
      }
      const float d_full = amax / 127.0f;
      if (!finite32(d_full)) return numerical(result, r, g * 32);
      const float reciprocal = d_full == 0.0f ? 0.0f : 1.0f / d_full;
      if (!finite32(reciprocal)) return numerical(result, r, g * 32);
      const uint16_t saved = numeric_f32_to_half_rne(d_full);
      if ((saved & 0x7c00u) == 0x7c00u) return numerical(result, r, g * 32);
      for (unsigned i = 0; i < 32; ++i) {
        float rounded = 0.0f;
        if (d_full != 0.0f) {
          const float product = group[i] * reciprocal;
          if (!finite32(product)) return numerical(result, r, g * 32 + i);
          rounded = ::roundf(product);
        }
        if (!finite32(rounded) || rounded < -127.0f || rounded > 127.0f)
          return numerical(result, r, g * 32 + i);
        q[r][g][i] = int8_t(rounded);
      }
      scale_bits[r][g] = saved;
      result.covered_groups[r][g / 32] |= uint32_t(1) << (g % 32);
    }
  }

  result.identity = request;
  result.ref = task.a_dst;
  result.source = source;
  result.producer_task_id = task.ctx.task_id;
  result.stage = task.ctx.stage;
  result.layer = task.ctx.layer;
  result.row_space = task.ctx.row_space;
  result.batch = task.ctx.batch;
  result.row0 = task.ctx.row0;
  result.rows = task.ctx.rows;
  result.K = task.K;
  result.content = Content::Q8_TILE;
  result.state = CacheState::READY;
  result.valid = true;
  return ok();
}

} // namespace laya
