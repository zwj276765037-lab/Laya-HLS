#include "full_task_common.h"

namespace laya::full {
namespace {
Check read_qkv(const FullRuntime& rt, uint8_t plane, uint8_t batch,
               uint8_t head, uint16_t row, uint8_t d, float& value) {
  Address a;
  Check c = qkv_address(plane, batch, head, row, d,
                        rt.inputs.identity.B, rt.inputs.identity.S, a);
  if (!c) return c;
  uint8_t raw[4];
  c = full_read(rt.memory, a.bo, a.offset, raw, 4);
  if (!c) return c;
  value = numeric_bits_f32(uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                           uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24);
  return ok();
}
Check write_qkv(FullRuntime& rt, uint8_t plane, uint8_t batch,
                uint8_t head, uint16_t row, uint8_t d, float value) {
  Address a;
  Check c = qkv_address(plane, batch, head, row, d,
                        rt.inputs.identity.B, rt.inputs.identity.S, a);
  if (!c) return c;
  const uint32_t bits = numeric_f32_bits(value);
  const uint8_t raw[4] = {uint8_t(bits), uint8_t(bits >> 8),
                          uint8_t(bits >> 16), uint8_t(bits >> 24)};
  return full_write(rt.memory, a.bo, a.offset, raw, 4);
}
void qkv_specs(const FullRuntime& rt, const BufferRef (&refs)[2],
               uint8_t stage, uint8_t layer, Content content,
               FullOwnerSpec (&out)[2]) {
  for (unsigned shard = 0; shard < 2; ++shard)
    out[shard] = task::spec(refs[shard], 0, stage, layer,
                            RowSpace::TOKEN, rt.inputs.identity.S,
                            64, content);
}
Check qkv_ready(FullRuntime& rt, const FullOwnerSpec (&pair)[2]) {
  for (unsigned shard = 0; shard < 2; ++shard)
    for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch) {
      Check c = full_require_owner(rt, pair[shard], uint8_t(batch), 0,
                                   rt.inputs.identity.S);
      if (!c) return c;
    }
  return ok();
}
FullOwnerSpec kv_spec(const FullRuntime& rt, BufferRef ref,
                      const TaskContext& ctx) {
  return task::spec(ref, 0, ctx.stage, ctx.layer,
                    RowSpace::TOKEN, rt.inputs.identity.S, 64);
}
FullOwnerSpec score_spec(BufferRef ref, const TaskContext& ctx,
                          uint16_t width, Content content) {
  return {ref, 0, ctx.stage, ctx.layer, ctx.batch, RowSpace::TOKEN,
          ctx.row0, ctx.rows, width, content};
}
} // namespace

Check full_run_task(FullRuntime& rt, const RopeTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const uint8_t mode = t.ctx.layer % 3 == 0 ? 0 : 1;
  if (t.ctx.op != Op::ROPE || t.ctx.stage != 2 ||
      t.ctx.row_space != RowSpace::TOKEN || t.head >= 16 ||
      t.mode != mode || t.table_set != mode ||
      rt.loaded_rope_mode != mode ||
      rt.loaded_rope_ref.id != Buffer::ROPE_TABLE ||
      rt.loaded_rope_ref.bank != mode)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  BufferRef old_ref[2], next_ref[2];
  for (unsigned shard = 0; shard < 2; ++shard) {
    old_ref[shard] = t.src_qkv_ref[shard];
    next_ref[shard] = t.dst_qkv_ref[shard];
    if (old_ref[shard].id != Buffer::QKV ||
        next_ref[shard].id != Buffer::QKV ||
        old_ref[shard].bank != shard || next_ref[shard].bank != shard ||
        old_ref[shard].epoch >= kMaxEpoch ||
        next_ref[shard].epoch != old_ref[shard].epoch + 1)
      return task::finish(rt, t.ctx, task::buffer(Buffer::QKV),
                          OutputUnit::F32, 0, done);
  }
  FullOwnerSpec next[2];
  qkv_specs(rt, next_ref, 2, t.ctx.layer, Content::QKV_FINAL, next);
  for (unsigned shard = 0; shard < 2; ++shard) {
    FullOwnerRecord owner;
    c = full_owner_snapshot(rt, next_ref[shard], 0, owner);
    if (!c || owner.state != CacheState::EXCLUSIVE_RW ||
        owner.lease_old_ref != old_ref[shard] ||
        owner.stage != 2 || owner.layer != t.ctx.layer ||
        owner.content != Content::QKV_FINAL ||
        !numeric_identity_equal(owner.identity, rt.inputs.identity)) {
      c = task::buffer(Buffer::QKV);
      return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    }
  }
  for (unsigned plane = 0; plane < 2; ++plane)
    for (unsigned r = 0; r < t.ctx.rows; ++r) {
      const unsigned row = t.ctx.row0 + r;
      if (rt.owners.qkv_rope_rows[t.head % 2][plane][t.head]
                                  [t.ctx.batch][row / 32] &
          (uint32_t(1) << (row % 32)))
        return task::finish(rt, t.ctx, task::buffer(Buffer::QKV),
                            OutputUnit::F32, 0, done);
    }
  const FullOwnerSpec table{rt.loaded_rope_ref, 0, 2, t.ctx.layer, 0,
                             RowSpace::BATCH, 0, 1, 64, Content::F32};
  c = full_acquire_owner(rt, table, 0, 0, 1);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    const uint16_t row = uint16_t(t.ctx.row0 + r);
    for (unsigned plane = 0; plane < 2 && c; ++plane) {
      float raw[64], rotated[64];
      for (unsigned d = 0; d < 64; ++d) {
        c = read_qkv(rt, uint8_t(plane), t.ctx.batch, t.head,
                     row, uint8_t(d), raw[d]);
        if (!c) break;
      }
      if (c) c = rope_head(raw, rt.cache.rope_table[0][row],
                            rt.cache.rope_table[1][row], rotated);
      for (unsigned d = 0; d < 64 && c; ++d)
        c = write_qkv(rt, uint8_t(plane), t.ctx.batch, t.head,
                      row, uint8_t(d), rotated[d]);
    }
  }
  Check release = full_release_read_owner(rt, table);
  if (c) c = release;
  if (c) c = full_cover_qkv_rope(rt, next, t.head, t.ctx.batch,
                                 t.ctx.row0, t.ctx.rows);
  if (!c) {
    full_invalidate_owner(rt, next_ref[0], 0);
    full_invalidate_owner(rt, next_ref[1], 0);
  }
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * 128u, done);
}

Check full_run_task(FullRuntime& rt, const QKTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const uint8_t mode = t.ctx.stage == 2 && t.ctx.layer % 3 != 0 ? 1 : 0;
  if (t.ctx.op != Op::QK ||
      (t.ctx.stage != 2 && t.ctx.stage != 4) ||
      t.ctx.row_space != RowSpace::TOKEN || t.head >= 16 ||
      t.S != rt.inputs.identity.S || t.mask_mode != mode ||
      t.scale_bits != 0x3e000000u ||
      t.kv != rt.loaded_kv_ref || rt.loaded_kv_head != t.head ||
      t.score.id != Buffer::SCORE_PROB || t.score.bank != 0)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  BufferRef refs[2] = {t.qkv_ref[0], t.qkv_ref[1]};
  if (refs[0].id != Buffer::QKV || refs[0].bank != 0 ||
      refs[1].id != Buffer::QKV || refs[1].bank != 1 ||
      refs[0] != rt.final_qkv_ref[0] ||
      refs[1] != rt.final_qkv_ref[1])
    return task::finish(rt, t.ctx, task::buffer(Buffer::QKV),
                        OutputUnit::F32, 0, done);
  FullOwnerSpec qkv[2];
  qkv_specs(rt, refs, t.ctx.stage, t.ctx.layer, Content::QKV_FINAL, qkv);
  c = qkv_ready(rt, qkv);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const FullOwnerSpec kv = kv_spec(rt, t.kv, t.ctx);
  c = full_require_owner(rt, kv, t.ctx.batch, 0,
                         rt.inputs.identity.S);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const FullOwnerSpec score = score_spec(t.score, t.ctx, t.S,
                                          Content::SCORE);
  c = full_claim_owner(rt, score);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  bool q_read = false, kv_read = false;
  c = full_acquire_owner(rt, qkv[t.head % 2], t.ctx.batch,
                         t.ctx.row0, t.ctx.rows);
  if (c) {
    q_read = true;
    c = full_acquire_owner(rt, kv, t.ctx.batch, 0,
                           rt.inputs.identity.S);
    if (c) kv_read = true;
  }
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    float q[64];
    for (unsigned d = 0; d < 64; ++d) {
      c = read_qkv(rt, 0, t.ctx.batch, t.head,
                   uint16_t(t.ctx.row0 + r), uint8_t(d), q[d]);
      if (!c) break;
    }
    if (c) c = qk_row(q, rt.cache.kv[0][t.ctx.batch],
                      rt.inputs.attention_mask[t.ctx.batch], t.S,
                      uint16_t(t.ctx.row0 + r), mode != 0,
                      rt.cache.score[t.ctx.batch][r]);
  }
  if (kv_read) full_release_read_owner(rt, kv);
  if (q_read) full_release_read_owner(rt, qkv[t.head % 2]);
  if (c) c = full_cover_owner(rt, score, t.ctx.batch,
                              t.ctx.row0, t.ctx.rows);
  if (c) c = full_publish_owner(rt, score);
  if (!c) full_invalidate_owner(rt, t.score, 0);
  else {
    rt.score_ref = t.score;
    rt.score_kv_ref = t.kv;
    rt.score_qkv_ref[0] = refs[0];
    rt.score_qkv_ref[1] = refs[1];
    rt.score_head = t.head;
    rt.score_stage = t.ctx.stage;
    rt.score_layer = t.ctx.layer;
    rt.score_batch = t.ctx.batch;
    rt.score_row0 = t.ctx.row0;
    rt.score_rows = t.ctx.rows;
    rt.score_valid = true;
  }
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * t.S, done);
}

Check full_run_task(FullRuntime& rt, const SoftmaxTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (t.ctx.op == Op::SOFTMAX_ATT) {
    if ((t.ctx.stage != 2 && t.ctx.stage != 4) ||
        t.ctx.row_space != RowSpace::TOKEN || t.mode != 0 ||
        t.length != rt.inputs.identity.S ||
        t.src.id != Buffer::SCORE_PROB ||
        t.dst.id != Buffer::SCORE_PROB ||
        t.src.bank != 0 || t.dst.bank != 0 ||
        t.dst.epoch != t.src.epoch + 1 ||
        t.src_region || t.dst_region ||
        !rt.score_valid || rt.score_ref != t.src ||
        rt.score_head != rt.loaded_kv_head ||
        rt.score_kv_ref != rt.loaded_kv_ref ||
        rt.score_qkv_ref[0] != rt.final_qkv_ref[0] ||
        rt.score_qkv_ref[1] != rt.final_qkv_ref[1] ||
        rt.score_stage != t.ctx.stage ||
        rt.score_layer != t.ctx.layer ||
        rt.score_batch != t.ctx.batch ||
        rt.score_row0 != t.ctx.row0 ||
        rt.score_rows != t.ctx.rows)
      return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                          OutputUnit::F32, 0, done);
    const FullOwnerSpec next = score_spec(t.dst, t.ctx, t.length,
                                           Content::PROB);
    FullOwnerRecord owner;
    c = full_owner_snapshot(rt, t.dst, 0, owner);
    if (!c || owner.state != CacheState::EXCLUSIVE_RW ||
        owner.lease_old_ref != t.src ||
        owner.stage != t.ctx.stage || owner.layer != t.ctx.layer ||
        owner.content != Content::PROB || owner.batch != t.ctx.batch ||
        owner.row0 != t.ctx.row0 || owner.rows != t.ctx.rows ||
        !numeric_identity_equal(owner.identity, rt.inputs.identity)) {
      c = task::buffer(Buffer::SCORE_PROB);
      return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    }
    for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
      float p[1024];
      c = softmax_row(rt.cache.score[t.ctx.batch][r], t.length, p);
      if (c) c = full_consume_inplace_rows(rt, next, t.ctx.batch,
                                           uint16_t(t.ctx.row0 + r), 1);
      if (c)
        for (unsigned k = 0; k < t.length; ++k)
          rt.cache.score[t.ctx.batch][r][k] = p[k];
      if (c) c = full_cover_owner(rt, next, t.ctx.batch,
                                  uint16_t(t.ctx.row0 + r), 1);
    }
    if (c) c = full_commit_inplace_owner(rt, next);
    if (!c) {
      full_invalidate_owner(rt, t.dst, 0);
      rt.score_valid = false;
    } else rt.score_ref = t.dst;
  } else if (t.ctx.op == Op::SOFTMAX_CAND) {
    if (t.ctx.stage != 6 || t.ctx.row_space != RowSpace::BATCH ||
        t.mode != 1 || t.length != 16 ||
        t.src.id != Buffer::HEAD_WORK ||
        t.src_region != uint8_t(Region::CAND_MASKED) ||
        t.dst.id != Buffer::HEAD_WORK ||
        t.dst_region != uint8_t(Region::CAND_PROB))
      return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                          OutputUnit::F32, 0, done);
    FullOwnerSpec src;
    c = task::source(rt, t.src, t.src_region, t.ctx, 16, src);
    const FullOwnerSpec dst = task::spec(t.dst, t.dst_region, 6, 255,
                                        RowSpace::BATCH, 1, 16);
    if (c) c = full_check_uncovered_owner(rt, dst, t.ctx.batch, 0, 1);
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    c = full_acquire_owner(rt, src, t.ctx.batch, 0, 1);
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    float x[1024] = {}, y[1024] = {};
    for (unsigned col = 0; col < 16 && c; ++col)
      c = task::read(rt, t.src, t.src_region, t.ctx.batch, 0,
                     uint16_t(col), x[col]);
    Check release = full_release_read_owner(rt, src);
    if (c) c = release;
    if (c) c = softmax_row(x, 16, y);
    for (unsigned col = 0; col < 16 && c; ++col)
      c = task::write(rt, t.dst, t.dst_region, t.ctx.batch, 0,
                      uint16_t(col), y[col]);
    if (c) c = full_cover_owner(rt, dst, t.ctx.batch, 0, 1);
    if (!c) full_invalidate_owner(rt, t.dst, t.dst_region);
  } else {
    c = task::shape(t.ctx.op);
  }
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * t.length, done);
}

Check full_run_task(FullRuntime& rt, const AVTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (t.ctx.op != Op::AV || (t.ctx.stage != 2 && t.ctx.stage != 4) ||
      t.ctx.row_space != RowSpace::TOKEN || t.S != rt.inputs.identity.S ||
      t.head >= 16 || t.prob.id != Buffer::SCORE_PROB ||
      t.kv != rt.loaded_kv_ref || rt.loaded_kv_head != t.head ||
      t.partial.id != Buffer::AV_PARTIAL || t.partial.bank != 0 ||
      t.dst.id != Buffer::ATT_OUT ||
      !rt.score_valid || rt.score_ref != t.prob ||
      rt.score_kv_ref != t.kv || rt.score_head != t.head ||
      rt.score_qkv_ref[0] != rt.final_qkv_ref[0] ||
      rt.score_qkv_ref[1] != rt.final_qkv_ref[1] ||
      rt.score_stage != t.ctx.stage || rt.score_layer != t.ctx.layer ||
      rt.score_batch != t.ctx.batch || rt.score_row0 != t.ctx.row0 ||
      rt.score_rows != t.ctx.rows)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  const FullOwnerSpec prob = score_spec(t.prob, t.ctx, t.S, Content::PROB);
  const FullOwnerSpec kv = kv_spec(rt, t.kv, t.ctx);
  const FullOwnerSpec dst = task::spec(t.dst, 0, t.ctx.stage,
                                      t.ctx.layer, RowSpace::TOKEN,
                                      t.S, 1024);
  c = full_require_owner(rt, prob, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (c) c = full_require_owner(rt, kv, t.ctx.batch, 0, t.S);
  if (c) c = full_check_fill_owner(rt, dst);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  for (unsigned r = 0; r < t.ctx.rows; ++r) {
    const uint16_t row = uint16_t(t.ctx.row0 + r);
    if (rt.owners.att_head_rows[t.head][t.ctx.batch][row / 32] &
        (uint32_t(1) << (row % 32)))
      return task::finish(rt, t.ctx, task::buffer(Buffer::ATT_OUT),
                          OutputUnit::F32, 0, done);
  }
  const FullOwnerSpec partial = {t.partial, 0, t.ctx.stage, t.ctx.layer,
                                 t.ctx.batch, RowSpace::TOKEN,
                                 t.ctx.row0, t.ctx.rows, 64, Content::F32};
  c = full_claim_owner(rt, partial);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  bool p_read = false, kv_read = false;
  c = full_acquire_owner(rt, prob, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (c) {
    p_read = true;
    c = full_acquire_owner(rt, kv, t.ctx.batch, 0, t.S);
    if (c) kv_read = true;
  }
  for (unsigned r = 0; r < t.ctx.rows && c; ++r)
    c = av_row(rt.cache.score[t.ctx.batch][r],
                rt.cache.kv[1][t.ctx.batch], t.S,
                rt.cache.av_partial[r]);
  if (kv_read) full_release_read_owner(rt, kv);
  if (p_read) full_release_read_owner(rt, prob);
  if (c) c = full_cover_owner(rt, partial, t.ctx.batch,
                              t.ctx.row0, t.ctx.rows);
  if (c) c = full_publish_owner(rt, partial);
  bool partial_read = false;
  if (c) {
    c = full_acquire_owner(rt, partial, t.ctx.batch,
                           t.ctx.row0, t.ctx.rows);
    partial_read = bool(c);
  }
  for (unsigned r = 0; r < t.ctx.rows && c; ++r)
    for (unsigned d = 0; d < 64; ++d) {
      c = task::write(rt, t.dst, 0, t.ctx.batch,
                      uint16_t(t.ctx.row0 + r),
                      uint16_t(t.head * 64 + d),
                      rt.cache.av_partial[r][d]);
      if (!c) break;
    }
  if (partial_read) {
    Check release = full_release_read_owner(rt, partial);
    if (c) c = release;
  }
  if (c) c = full_cover_att_head(rt, dst, t.head, t.ctx.batch,
                                 t.ctx.row0, t.ctx.rows);
  if (c) c = full_release_owner(rt, partial);
  if (c) c = full_release_owner(rt, prob);
  if (!c) {
    full_invalidate_owner(rt, t.partial, 0);
    full_invalidate_owner(rt, t.dst, 0);
    full_invalidate_owner(rt, t.prob, 0);
  }
  rt.score_valid = false;
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * 64u, done);
}

} // namespace laya::full
