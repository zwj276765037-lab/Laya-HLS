#include "full_task_common.h"

namespace laya::full {
namespace {
Check aux_f32(const FullRuntime& rt, uint32_t offset,
              uint64_t element, Op op,
              float& value) {
  uint8_t raw[4];
  Check c = full_read(rt.memory, Bo::AUX, offset, raw, 4);
  if (!c) return c;
  value = numeric_bits_f32(uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                           uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24);
  return task::finite(value) ? ok() : task::numerical(op, element);
}
} // namespace

Check full_run_task(FullRuntime& rt, const FPLinearTask& t,
                    TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const bool scorer = t.ctx.op == Op::FP_SCORER_FC2 &&
                      t.ctx.stage == 5 &&
                      t.ctx.row_space == RowSpace::MARKER &&
                      t.weight.family == 10 &&
                      t.src.id == Buffer::HEAD_WORK &&
                      t.src_region == uint8_t(Region::SCORER_ACT) &&
                      t.dst.id == Buffer::HEAD_WORK &&
                      t.dst_region == uint8_t(Region::CAND_RAW);
  const bool act = t.ctx.op == Op::FP_ACT_FC1 &&
                   t.ctx.stage == 6 &&
                   t.ctx.row_space == RowSpace::BATCH &&
                   t.weight.family == 11 &&
                   t.src.id == Buffer::HEAD_WORK &&
                   t.src_region == uint8_t(Region::ACT_INPUT) &&
                   t.dst.id == Buffer::HEAD_WORK &&
                   t.dst_region == uint8_t(Region::ACT_HIDDEN);
  if ((!scorer && !act) || !check_ref(t.src, t.src_region) ||
      !check_ref(t.dst, t.dst_region))
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  c = check_weight(t.weight, t.ctx.stage, t.ctx.layer, t.K, t.N, true);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  FullWeightDescriptor weight;
  c = full_lookup_weight(t.weight, weight);
  if (!c || weight.K != t.K || weight.N != t.N ||
      weight.dtype != (scorer ? 0 : 1) ||
      weight.aux_span != uint32_t(t.K) * t.N * (scorer ? 4u : 2u) ||
      weight.bias_kind != (scorer ? 1 : 0))
    return task::finish(rt, t.ctx,
                        {Status::E_MODEL, detail(4, 0, 4)},
                        OutputUnit::F32, 0, done);
  c = full_span(rt.memory, Bo::AUX, weight.aux_base, weight.aux_span);
  if (c && scorer)
    c = full_span(rt.memory, Bo::AUX, weight.bias_base, 4);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  FullOwnerSpec src;
  c = task::source(rt, t.src, t.src_region, t.ctx, t.K, src);
  const FullOwnerSpec dst = task::spec(t.dst, t.dst_region, t.ctx.stage,
                                      255, t.ctx.row_space,
                                      task::extent(rt, t.ctx.row_space), t.N);
  if (c) c = full_check_uncovered_owner(rt, dst, t.ctx.batch,
                                        t.ctx.row0, t.ctx.rows);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  float scorer_weight[1024] = {};
  float scorer_bias = 0.0f;
  if (scorer) {
    for (unsigned k = 0; k < 1024 && c; ++k)
      c = aux_f32(rt, weight.aux_base + k * 4, k, t.ctx.op,
                  scorer_weight[k]);
    if (c) c = aux_f32(rt, weight.bias_base, 0, t.ctx.op, scorer_bias);
  } else {
    for (unsigned n = 0; n < 256 && c; ++n)
      for (unsigned k = 0; k < 1028; ++k) {
        uint8_t raw[2];
        c = full_read(rt.memory, Bo::AUX,
                      uint64_t(weight.aux_base) + (n * 1028u + k) * 2,
                      raw, 2);
        if (!c) break;
        rt.cache.fp_act_weight[n][k] =
            uint16_t(raw[0]) | uint16_t(uint16_t(raw[1]) << 8);
      }
  }
  if (!c) {
    full_invalidate_owner(rt, t.dst, t.dst_region);
    return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  c = full_acquire_owner(rt, src, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    if (scorer) {
      float x[1024], y = 0.0f;
      for (unsigned k = 0; k < 1024; ++k) {
        c = task::read(rt, t.src, t.src_region, t.ctx.batch,
                       uint16_t(t.ctx.row0 + r), uint16_t(k), x[k]);
        if (!c) break;
      }
      if (c) c = fp_scorer_row(x, scorer_weight, scorer_bias, y);
      if (c) c = task::write(rt, t.dst, t.dst_region, t.ctx.batch,
                             uint16_t(t.ctx.row0 + r), 0, y);
    } else {
      float x[1028], y[256];
      for (unsigned k = 0; k < 1028; ++k) {
        c = task::read(rt, t.src, t.src_region, t.ctx.batch,
                       0, uint16_t(k), x[k]);
        if (!c) break;
      }
      if (c) c = fp_act_row(x, rt.cache.fp_act_weight, y);
      for (unsigned n = 0; n < 256 && c; ++n)
        c = task::write(rt, t.dst, t.dst_region, t.ctx.batch,
                        0, uint16_t(n), y[n]);
    }
  }
  Check release = full_release_read_owner(rt, src);
  if (c) c = release;
  if (c) c = full_cover_owner(rt, dst, t.ctx.batch,
                              t.ctx.row0, t.ctx.rows);
  if (!c) full_invalidate_owner(rt, t.dst, t.dst_region);
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * t.N, done);
}

Check full_run_task(FullRuntime& rt, const GatherTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (t.ctx.op != Op::GATHER_MARKER || t.ctx.stage != 5 ||
      t.ctx.row_space != RowSpace::MARKER || t.ctx.row0 ||
      t.ctx.rows != 16 || t.columns != 16 ||
      t.hidden.id != Buffer::HIDDEN || t.markers.id != Buffer::MARKER)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  FullOwnerSpec hidden;
  c = task::bound(rt, t.hidden, 0, 1024, hidden);
  if (c && (hidden.stage != 4 || hidden.layer != 1 ||
            hidden.row_space != RowSpace::TOKEN || hidden.batch != 255 ||
            hidden.row0 || hidden.rows != rt.inputs.identity.S))
    c = task::buffer(t.hidden.id);
  if (c) c = full_require_owner(rt, hidden, t.ctx.batch, 0,
                                rt.inputs.identity.S);
  const FullOwnerSpec dst = task::spec(t.markers, 0, 5, 255,
                                      RowSpace::MARKER, 16, 1024);
  if (c) c = full_check_uncovered_owner(rt, dst, t.ctx.batch, 0, 16);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  uint16_t rows[16];
  for (unsigned col = 0; col < 16; ++col) {
    const int32_t marker = rt.inputs.marker_positions[t.ctx.batch][col];
    if (marker < 0) { c = {Status::E_INDEX, detail(3, 3, 4), col}; break; }
    c = marker_token_row(uint32_t(marker), t.ctx.batch,
                          rt.inputs.identity.S, rows[col]);
    if (!c) break;
    // marker_token_row validates and returns a physical 1024-stride row.
    // The typed F32 accessor takes a per-batch logical token row and applies
    // that stride itself.
    rows[col] = uint16_t(rows[col] - uint16_t(t.ctx.batch * 1024u));
  }
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  c = full_acquire_owner(rt, hidden, t.ctx.batch, 0,
                         rt.inputs.identity.S);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  for (unsigned col = 0; col < 16 && c; ++col)
    for (unsigned d = 0; d < 1024; ++d) {
      float value = 0.0f;
      c = task::read(rt, t.hidden, 0, t.ctx.batch, rows[col],
                     uint16_t(d), value);
      if (c) c = task::write(rt, t.markers, 0, t.ctx.batch,
                             uint16_t(col), uint16_t(d), value);
      if (!c) break;
    }
  Check release = full_release_read_owner(rt, hidden);
  if (c) c = release;
  if (c) c = full_cover_owner(rt, dst, t.ctx.batch, 0, 16);
  if (!c) full_invalidate_owner(rt, t.markers, 0);
  return task::finish(rt, t.ctx, c, OutputUnit::F32, 16u * 1024u, done);
}

Check full_run_task(FullRuntime& rt, const StatsTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (t.ctx.op != Op::CAND_STATS || t.ctx.stage != 6 ||
      t.ctx.row_space != RowSpace::BATCH ||
      t.probs.id != Buffer::HEAD_WORK ||
      t.prob_region != uint8_t(Region::CAND_PROB) ||
      t.stats.id != Buffer::HEAD_WORK ||
      t.stats_region != uint8_t(Region::STATS) ||
      t.valid_options < 1 || t.valid_options > 16)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  uint8_t actual = 0;
  for (unsigned i = 0; i < 16; ++i)
    actual += rt.inputs.marker_mask[t.ctx.batch][i];
  if (actual != t.valid_options)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  FullOwnerSpec src;
  c = task::source(rt, t.probs, t.prob_region, t.ctx, 16, src,
                   Content::F32);
  const FullOwnerSpec dst = task::spec(t.stats, t.stats_region, 6, 255,
                                      RowSpace::BATCH, 1, 4);
  if (c) c = full_check_uncovered_owner(rt, dst, t.ctx.batch, 0, 1);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  c = full_acquire_owner(rt, src, t.ctx.batch, 0, 1);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  float p[16], stats[4];
  for (unsigned i = 0; i < 16 && c; ++i)
    c = task::read(rt, t.probs, t.prob_region, t.ctx.batch, 0,
                   uint16_t(i), p[i]);
  Check release = full_release_read_owner(rt, src);
  if (c) c = release;
  if (c) c = candidate_stats(p, t.valid_options, stats);
  for (unsigned i = 0; i < 4 && c; ++i)
    c = task::write(rt, t.stats, t.stats_region, t.ctx.batch, 0,
                    uint16_t(i), stats[i]);
  if (c) c = full_cover_owner(rt, dst, t.ctx.batch, 0, 1);
  if (!c) full_invalidate_owner(rt, t.stats, t.stats_region);
  return task::finish(rt, t.ctx, c, OutputUnit::F32, 4, done);
}

Check full_run_task(FullRuntime& rt, const ConcatActTask& t,
                    TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (t.ctx.op != Op::CONCAT_ACT || t.ctx.stage != 6 ||
      t.ctx.row_space != RowSpace::BATCH ||
      t.hidden.id != Buffer::HIDDEN ||
      t.stats.id != Buffer::HEAD_WORK ||
      t.stats_region != uint8_t(Region::STATS) ||
      t.dst.id != Buffer::HEAD_WORK ||
      t.dst_region != uint8_t(Region::ACT_INPUT))
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  FullOwnerSpec hidden, stats;
  c = task::bound(rt, t.hidden, 0, 1024, hidden);
  if (c && (hidden.stage != 4 || hidden.layer != 1 ||
            hidden.row_space != RowSpace::TOKEN || hidden.batch != 255 ||
            hidden.row0 || hidden.rows != rt.inputs.identity.S))
    c = task::buffer(t.hidden.id);
  if (c) c = full_require_owner(rt, hidden, t.ctx.batch, 0, 1);
  if (c) c = task::source(rt, t.stats, t.stats_region, t.ctx, 4, stats);
  const FullOwnerSpec dst = task::spec(t.dst, t.dst_region, 6, 255,
                                      RowSpace::BATCH, 1, 1028);
  if (c) c = full_check_uncovered_owner(rt, dst, t.ctx.batch, 0, 1);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  c = full_acquire_owner(rt, hidden, t.ctx.batch, 0, 1);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  c = full_acquire_owner(rt, stats, t.ctx.batch, 0, 1);
  if (!c) {
    full_release_read_owner(rt, hidden);
    return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  float cls[1024], s[4], y[1028];
  for (unsigned i = 0; i < 1024 && c; ++i)
    c = task::read(rt, t.hidden, 0, t.ctx.batch, 0, uint16_t(i), cls[i]);
  for (unsigned i = 0; i < 4 && c; ++i)
    c = task::read(rt, t.stats, t.stats_region, t.ctx.batch,
                   0, uint16_t(i), s[i]);
  Check release_stats = full_release_read_owner(rt, stats);
  Check release_hidden = full_release_read_owner(rt, hidden);
  if (c) c = release_stats;
  if (c) c = release_hidden;
  if (c) c = concat_act_row(cls, s, y);
  for (unsigned i = 0; i < 1028 && c; ++i)
    c = task::write(rt, t.dst, t.dst_region, t.ctx.batch,
                    0, uint16_t(i), y[i]);
  if (c) c = full_cover_owner(rt, dst, t.ctx.batch, 0, 1);
  if (!c) full_invalidate_owner(rt, t.dst, t.dst_region);
  return task::finish(rt, t.ctx, c, OutputUnit::F32, 1028, done);
}

} // namespace laya::full
