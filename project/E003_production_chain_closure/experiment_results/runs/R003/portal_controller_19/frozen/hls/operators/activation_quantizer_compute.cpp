#include "laya_numeric.h"
#include "laya_numeric_service_stats.h"

#include "../common/laya_numeric_service_owner.h"
#include "../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/blackbox/laya_quant_blackbox_smoke.cpp"
#ifndef LAYA_EXTERNAL_RTL_MODELS
#include "../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/blackbox/laya_quant_group_service.cpp"
#endif

namespace laya {
namespace {
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
  uint64_t owner[16];
  numeric_service_identity(owner, request, task.ctx);
  numeric_service_ref(owner, 96, task.src, task.src_region);
  numeric_service_ref(owner, 104, task.a_dst);
  const unsigned groups = task.K / 32;
#ifndef __SYNTHESIS__
  ++numeric_service_stats().quant_tasks;
#endif
  for (unsigned r = 0; r < task.ctx.rows; ++r)
    for (unsigned g = 0; g < groups; ++g) {
      uint64_t input[31] = {}, output[23] = {};
      for (unsigned i = 0; i < 14; ++i) input[i] = owner[i];
      for (unsigned i = 0; i < 32; ++i)
        input[14 + i / 2] |= uint64_t(numeric_f32_bits(x[r][g * 32 + i]))
                              << (32 * (i % 2));
      input[30] = task.ctx.row0 + r;
#ifndef __SYNTHESIS__
      ++numeric_service_stats().quant_group_calls;
#endif
      laya_quant_blackbox_smoke(input, output);
      bool owner_ok = true;
      for (unsigned i = 0; i < 14; ++i) owner_ok &= output[i] == owner[i];
#ifndef __SYNTHESIS__
      if (owner_ok) ++numeric_service_stats().quant_owner_echoes;
#endif
      if (!owner_ok || output[21] != 0) {
        result.state = CacheState::INVALID;
        result.valid = false;
        if (owner_ok && output[21] == 1)
          return {Status::E_NUMERICAL, detail(7, uint8_t(Op::QUANT), 15),
                  uint64_t(r) * 4096 + g * 32 + uint32_t(output[22])};
        return {Status::E_PROTOCOL, detail(7, uint8_t(Op::QUANT), 5)};
      }
      for (unsigned i = 0; i < 32; ++i)
        q[r][g][i] = int8_t(output[14 + i / 8] >> (8 * (i % 8)));
      scale_bits[r][g] = uint16_t(output[18]);
      result.covered_groups[r][g / 32] |= uint32_t(1) << (g % 32);
    }
  // Each call waits for actual quant16 coverage and scalar/multiply debts.
  // The complete A tile remains FILL until every required Group32 returned.
  if (!numeric_coverage_complete(result.covered_groups, task.ctx.rows, groups, 16)) {
    result.state = CacheState::INVALID;
    result.valid = false;
    return {Status::E_PROTOCOL, detail(7, uint8_t(Op::QUANT), 5)};
  }
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
