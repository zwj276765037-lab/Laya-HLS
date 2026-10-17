#include "laya_full_runtime.h"
#include "laya_full_cache_storage.h"
#include "laya_numeric.h"

namespace laya::full {
namespace {
Check bad(Op op, uint16_t reason = 5) {
  return {Status::E_SHAPE, detail(7, uint8_t(op), reason)};
}
Check buffer(Buffer id, uint16_t reason = 4) {
  return {Status::E_BUFFER, detail(4, uint8_t(id), reason)};
}
Check finish(FullRuntime& rt, const TaskContext& ctx, Check c,
             OutputUnit unit, uint32_t elements, TaskDone& done) {
  return full_finish_task(rt, ctx, c, unit, elements, done);
}
bool next_task(const FullRuntime& rt, const TaskContext& ctx) {
  return rt.request_valid && rt.model_header_valid &&
         ctx.task_id == rt.last_task_id + 1 && ctx.task_id <= kMaxEpoch;
}
bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}
Check read_f32(const FullRuntime& rt, const FullMemory& memory, BufferRef ref, uint8_t region,
               uint8_t batch, uint16_t row, uint16_t col, float& output) {
  Address a;
  Check c = full_f32_address(rt, memory, ref, region, batch, row, col, a);
  if (!c) return c;
  uint8_t raw[4];
  c = full_read(memory, a.bo, a.offset, raw, 4);
  if (!c) return c;
  const uint32_t bits = uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                        uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24;
  output = numeric_bits_f32(bits);
  return ok();
}
Check write_at(FullRuntime& rt, FullMemory& memory, Address a, float value) {
  const uint32_t bits = numeric_f32_bits(value);
  const uint8_t raw[4] = {uint8_t(bits), uint8_t(bits >> 8),
                          uint8_t(bits >> 16), uint8_t(bits >> 24)};
  Check c = full_note_generated_store(rt, a, 4);
  return c ? full_write(memory, a.bo, a.offset, raw, 4) : c;
}
Check write_f32(FullRuntime& rt, FullMemory& memory, BufferRef ref, uint8_t region,
                uint8_t batch, uint16_t row, uint16_t col, float value) {
  Address a;
  Check c = full_f32_address(rt, memory, ref, region, batch, row, col, a);
  return c ? write_at(rt, memory, a, value) : c;
}
bool quant_shape(const QuantTask& t) {
  if (t.ctx.op != Op::QUANT || t.a_dst.id != Buffer::A8 ||
      t.a_dst.bank != 0 || t.input_lanes != 8) return false;
  if (t.ctx.stage == 2 && t.ctx.row_space == RowSpace::TOKEN)
    return (t.K == 1024 && (t.src.id == Buffer::HIDDEN ||
                            t.src.id == Buffer::NORM ||
                            t.src.id == Buffer::ATT_OUT)) ||
           (t.K == 2624 && t.src.id == Buffer::GATE);
  if (t.ctx.stage == 4 && t.ctx.row_space == RowSpace::TOKEN)
    return (t.K == 1024 && (t.src.id == Buffer::HIDDEN ||
                            t.src.id == Buffer::NORM ||
                            t.src.id == Buffer::ATT_OUT)) ||
           (t.K == 4096 && t.src.id == Buffer::DEC_FF);
  if (t.ctx.stage == 5 && t.ctx.row_space == RowSpace::MARKER)
    return t.K == 1024 && t.src.id == Buffer::HEAD_WORK &&
           t.src_region == uint8_t(Region::SCORER_ACT);
  if (t.ctx.stage == 6 && t.ctx.row_space == RowSpace::BATCH)
    return t.K == 256 && t.src.id == Buffer::HEAD_WORK &&
           t.src_region == uint8_t(Region::ACT_HIDDEN);
  return false;
}
FullOwnerSpec tile_spec(BufferRef ref, uint8_t region,
                        const TaskContext& ctx, uint16_t width,
                        Content content) {
  return {ref, region, ctx.stage, ctx.layer, ctx.batch, ctx.row_space,
          ctx.row0, ctx.rows, width, content};
}
F32TileMeta p1_source(const FullRuntime& rt, const QuantTask& task) {
  F32TileMeta source;
  source.identity = rt.inputs.identity;
  source.ref = task.src;
  source.region = task.src_region;
  source.row_space = task.ctx.row_space;
  source.batch = task.ctx.batch;
  source.row0 = task.ctx.row0;
  source.rows = task.ctx.rows;
  source.K = task.K;
  source.state = CacheState::READY;
  source.content = Content::F32;
  source.valid = true;
  numeric_cover_all(source.covered_groups, task.ctx.rows, task.K / 32, 16);
  return source;
}
uint8_t linear_family(const LinearTask& t) {
  switch (t.ctx.op) {
    case Op::LIN_QKV: return t.ctx.stage == 2 ? 1 : t.ctx.stage == 4 ? 5 : 0;
    case Op::LIN_WO: return t.ctx.stage == 2 ? 2 : t.ctx.stage == 4 ? 6 : 0;
    case Op::LIN_WI: return t.ctx.stage == 2 ? 3 : 0;
    case Op::LIN_DOWN: return t.ctx.stage == 2 ? 4 : 0;
    case Op::LIN_DEC_FC1: return t.ctx.stage == 4 ? 7 : 0;
    case Op::LIN_DEC_FC2: return t.ctx.stage == 4 ? 8 : 0;
    case Op::LIN_SCORER_FC1: return t.ctx.stage == 5 ? 9 : 0;
    case Op::LIN_ACT_FC2: return t.ctx.stage == 6 ? 12 : 0;
    default: return 0;
  }
}
bool correct_linear_dst(const LinearTask& t) {
  switch (t.ctx.op) {
    case Op::LIN_QKV: return t.dst.id == Buffer::QKV && t.dst.bank == 0;
    case Op::LIN_WO: case Op::LIN_DOWN: case Op::LIN_DEC_FC2:
      return t.dst.id == Buffer::TMP;
    case Op::LIN_WI: return t.dst.id == Buffer::WI;
    case Op::LIN_DEC_FC1: return t.dst.id == Buffer::DEC_FF;
    case Op::LIN_SCORER_FC1:
      return t.dst.id == Buffer::HEAD_WORK &&
             t.dst_region == uint8_t(Region::SCORER_ACT);
    case Op::LIN_ACT_FC2:
      return t.dst.id == Buffer::HEAD_WORK &&
             t.dst_region == uint8_t(Region::ACT_LOGITS);
    default: return false;
  }
}
FullOwnerSpec matrix_spec(const LinearTask& t, const NumericIdentity& id) {
  const RowSpace space = t.ctx.row_space;
  const uint16_t rows = space == RowSpace::TOKEN ? id.S :
                        space == RowSpace::MARKER ? 16 : 1;
  const uint16_t width = t.ctx.op == Op::LIN_QKV ? 64 : t.N;
  return {t.dst, t.dst_region, t.ctx.stage, t.ctx.layer, 255,
          space, 0, rows, width,
          t.ctx.op == Op::LIN_QKV ?
              (t.ctx.stage == 4 ? Content::QKV_FINAL : Content::QKV_RAW) :
              Content::F32};
}
bool a8_can_claim(const A8TileMeta& owner, BufferRef next) {
  if (owner.valid || owner.readers ||
      (owner.state != CacheState::FREE &&
       owner.state != CacheState::INVALID)) return false;
  if (owner.ref.id == Buffer::NONE) return next.epoch == 1;
  return owner.ref.id == Buffer::A8 && owner.ref.bank == 0 &&
         owner.ref.epoch < kMaxEpoch &&
         next.epoch == owner.ref.epoch + 1;
}
Check scorer_old_readable(FullRuntime& rt, const FullOwnerSpec& old,
                          const TaskContext& ctx, FullOwnerSpec& next) {
  if (old.ref.id != Buffer::HEAD_WORK ||
      old.region != uint8_t(Region::SCORER_ACT) ||
      old.stage != 5 || old.layer != 255 || old.batch != 255 ||
      old.row_space != RowSpace::MARKER || old.row0 || old.rows != 16 ||
      old.width != 1024 || old.ref.epoch >= kMaxEpoch)
    return buffer(Buffer::HEAD_WORK);
  next = old;
  next.ref.epoch = old.ref.epoch + 1;
  FullOwnerRecord owner;
  Check c = full_owner_snapshot(rt, next.ref, next.region, owner);
  if (!c || owner.state != CacheState::EXCLUSIVE_RW ||
      owner.lease_old_ref != old.ref || owner.ref != next.ref ||
      owner.stage != 5 || owner.layer != 255 || owner.batch != 255 ||
      owner.row_space != RowSpace::MARKER || owner.rows != 16 ||
      owner.width != 1024 || owner.content != Content::F32 ||
      !numeric_identity_equal(owner.identity, rt.inputs.identity))
    return buffer(Buffer::HEAD_WORK);
  for (unsigned r = 0; r < ctx.rows; ++r) {
    const unsigned index = ctx.batch * 16 + ctx.row0 + r;
    if ((owner.old_consumed_rows[index / 32] |
         owner.covered_rows[index / 32]) &
        (uint32_t(1) << (index % 32))) return buffer(Buffer::HEAD_WORK);
  }
  return ok();
}
Check scorer_new_writable(FullRuntime& rt, const FullOwnerSpec& next,
                           const F32TileMeta& source,
                           const TaskContext& ctx) {
  if (next.ref.id != Buffer::HEAD_WORK ||
      next.region != uint8_t(Region::SCORER_ACT) ||
      source.ref.id != Buffer::HEAD_WORK ||
      source.ref.epoch + 1 != next.ref.epoch ||
      source.ref.bank != next.ref.bank ||
      source.region != next.region ||
      source.row_space != RowSpace::MARKER ||
      source.batch != ctx.batch || source.row0 != ctx.row0 ||
      source.rows != ctx.rows || source.K != 1024)
    return buffer(Buffer::HEAD_WORK);
  FullOwnerRecord owner;
  Check c = full_owner_snapshot(rt, next.ref, next.region, owner);
  if (!c || owner.state != CacheState::EXCLUSIVE_RW ||
      owner.lease_old_ref != source.ref || owner.ref != next.ref ||
      owner.stage != 5 || owner.layer != 255 || owner.batch != 255 ||
      owner.row_space != RowSpace::MARKER || owner.rows != 16 ||
      owner.width != 1024 || owner.content != Content::F32 ||
      !numeric_identity_equal(owner.identity, rt.inputs.identity))
    return buffer(Buffer::HEAD_WORK);
  for (unsigned r = 0; r < ctx.rows; ++r) {
    const unsigned index = ctx.batch * 16 + ctx.row0 + r;
    if (!(owner.old_consumed_rows[index / 32] &
          (uint32_t(1) << (index % 32))) ||
        (owner.covered_rows[index / 32] &
         (uint32_t(1) << (index % 32)))) return buffer(Buffer::HEAD_WORK);
  }
  return ok();
}
Check write_linear_output(FullRuntime& rt, FullMemory& memory, const LinearTask& t) {
  for (unsigned r = 0; r < t.ctx.rows; ++r) {
    const uint16_t row = uint16_t(t.ctx.row0 + r);
    for (unsigned n = 0; n < t.N; ++n) {
      const float value = full_cache_ps_tile(rt)[r][n];
      Check c;
      if (t.ctx.op == Op::LIN_QKV) {
        const uint8_t plane = uint8_t(n / 1024);
        const uint8_t head = uint8_t((n % 1024) / 64);
        const uint8_t d = uint8_t(n % 64);
        Address a;
        c = qkv_address(plane, t.ctx.batch, head, row, d,
                        rt.inputs.identity.B, rt.inputs.identity.S, a);
        if (c) c = full_span(memory, a.bo, a.offset, 4);
        if (c) c = write_at(rt, memory, a, value);
      } else {
        c = write_f32(rt, memory, t.dst, t.dst_region, t.ctx.batch, row,
                      uint16_t(n), value);
      }
      if (!c) return c;
    }
  }
  return ok();
}
} // namespace

Check full_run_task(FullRuntime& rt, FullMemory& memory, const QuantTask& t, TaskDone& done) {
  Check c = next_task(rt, t.ctx) ?
            check_context(t.ctx, rt.inputs.identity.B, rt.inputs.identity.S) :
            buffer(Buffer::A8);
  if (!c || !quant_shape(t) || !check_ref(t.src, t.src_region) ||
      !check_ref(t.a_dst) || !rt.expected_quant_source_valid) {
    if (c) c = bad(t.ctx.op);
    return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  const FullOwnerSpec expected = rt.expected_quant_source;
  if (expected.ref != t.src || expected.region != t.src_region ||
      expected.row_space != t.ctx.row_space ||
      expected.width != t.K || expected.content != Content::F32) {
    c = buffer(t.src.id);
    return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  if (!a8_can_claim(rt.cache.activation_meta, t.a_dst)) {
    c = buffer(Buffer::A8);
    return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  const bool scorer_lease = t.ctx.stage == 5;
  FullOwnerSpec scorer_next;
  c = scorer_lease ?
      scorer_old_readable(rt, expected, t.ctx, scorer_next) :
      full_require_owner(rt, expected, t.ctx.batch,
                         t.ctx.row0, t.ctx.rows);
  if (!c) return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  if (!scorer_lease) {
    c = full_acquire_owner(rt, expected, t.ctx.batch,
                           t.ctx.row0, t.ctx.rows);
    if (!c) return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  // The complete valid row tile is captured before any A8 owner mutation.
  for (unsigned r = 0; r < t.ctx.rows; ++r)
    for (unsigned k = 0; k < t.K; ++k) {
      c = read_f32(rt, memory, t.src, t.src_region, t.ctx.batch,
                   uint16_t(t.ctx.row0 + r), uint16_t(k),
                   full_cache_input_tile(rt)[r][k]);
      if (!c) {
        if (!scorer_lease) full_release_read_owner(rt, expected);
        else full_invalidate_owner(rt, scorer_next.ref, scorer_next.region);
        return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
      }
    }
  if (!scorer_lease) {
    c = full_release_read_owner(rt, expected);
    if (!c) return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  const FullOwnerSpec a = tile_spec(t.a_dst, 0, t.ctx, t.K,
                                    Content::Q8_TILE);
  c = full_claim_owner(rt, a);
  if (!c) {
    if (scorer_lease)
      full_invalidate_owner(rt, scorer_next.ref, scorer_next.region);
    return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  const F32TileMeta source = p1_source(rt, t);
  c = activation_quantizer_compute(t, rt.inputs.identity, source,
                                   full_cache_input_tile(rt),
                                   full_cache_activation_q(rt),
                                   full_cache_activation_scale(rt),
                                   rt.cache.activation_meta);
  if (!c) {
    full_invalidate_owner(rt, t.a_dst, 0);
    if (scorer_lease)
      full_invalidate_owner(rt, scorer_next.ref, scorer_next.region);
    return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  c = full_cover_owner(rt, a, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (c) c = full_publish_owner(rt, a);
  if (c && scorer_lease)
    c = full_consume_inplace_rows(rt, scorer_next, t.ctx.batch,
                                  t.ctx.row0, t.ctx.rows);
  if (!c) {
    full_invalidate_owner(rt, t.a_dst, 0);
    if (scorer_lease)
      full_invalidate_owner(rt, scorer_next.ref, scorer_next.region);
    return finish(rt, t.ctx, c, OutputUnit::Q8_GROUP, 0, done);
  }
  rt.cache.activation_source_ledger = source;
  rt.expected_quant_source_valid = false;
  return finish(rt, t.ctx, ok(), OutputUnit::Q8_GROUP,
                uint32_t(t.ctx.rows) * (t.K / 32), done);
}

Check full_run_task(FullRuntime& rt, FullMemory& memory, const LinearTask& t, TaskDone& done) {
  Check c = next_task(rt, t.ctx) ?
            check_context(t.ctx, rt.inputs.identity.B, rt.inputs.identity.S) :
            buffer(Buffer::PS);
  if (!c) return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const uint8_t family = linear_family(t);
  if (!family || t.weight.family != family ||
      t.a.id != Buffer::A8 || t.a.bank != 0 ||
      t.w.id != Buffer::WEIGHT || t.w.bank != 0 ||
      t.ps.id != Buffer::PS || t.ps.bank != 0 ||
      !correct_linear_dst(t) || !check_ref(t.a) || !check_ref(t.w) ||
      !check_ref(t.ps) || !check_ref(t.dst, t.dst_region) ||
      (t.ctx.stage == 5 && t.ctx.row_space != RowSpace::MARKER) ||
      (t.ctx.stage == 6 && t.ctx.row_space != RowSpace::BATCH) ||
      ((t.ctx.stage == 2 || t.ctx.stage == 4) &&
       t.ctx.row_space != RowSpace::TOKEN)) {
    c = bad(t.ctx.op);
    return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  c = check_weight(t.weight, t.ctx.stage, t.ctx.layer, t.K, t.N);
  if (!c) return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  FullWeightDescriptor descriptor;
  c = full_lookup_weight(t.weight, descriptor);
  if (!c || descriptor.dtype != 8 || descriptor.K != t.K ||
      descriptor.N != t.N || descriptor.bias_kind != t.bias_kind ||
      rt.current_weight_ref != t.w ||
      !full_equal_weight(rt.current_weight, descriptor)) {
    c = {Status::E_MODEL, detail(4, 0, 4)};
    return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  const FullOwnerSpec weight{t.w, 0, t.ctx.stage, t.ctx.layer, 0,
                             RowSpace::BATCH, 0, 1, t.N,
                             Content::Q8_WEIGHT};
  c = full_require_owner(rt, weight, 0, 0, 1);
  if (!c) return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const FullOwnerSpec activation =
      tile_spec(t.a, 0, t.ctx, t.K, Content::Q8_TILE);
  c = full_require_owner(rt, activation, t.ctx.batch,
                         t.ctx.row0, t.ctx.rows);
  if (!c) return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  c = numeric_check_a8(rt.cache.activation_meta, rt.inputs.identity,
                       t, rt.cache.activation_source_ledger);
  if (c && rt.dispatch_binding.valid) {
    const DispatchBinding& binding = rt.dispatch_binding;
    const A8TileMeta& a = rt.cache.activation_meta;
    if (!same_context(binding.producer_context, a.source_context) ||
        !same_context(binding.quant.ctx, a.quant_context) ||
        !same_context(binding.linear.ctx, t.ctx) ||
        binding.quant.src != a.source.ref ||
        binding.quant.src_region != a.source.region ||
        binding.quant.a_dst != t.a || binding.linear.a != t.a)
      c = {Status::E_PROTOCOL, detail(7, uint8_t(t.ctx.op), 14)};
  }
  if (!c) return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const FullOwnerSpec dst = matrix_spec(t, rt.inputs.identity);
  FullOwnerSpec qkv[2] = {dst, dst};
  if (t.ctx.op == Op::LIN_QKV) qkv[1].ref.bank = 1;
  const bool scorer_lease = t.ctx.op == Op::LIN_SCORER_FC1;
  c = scorer_lease ?
      scorer_new_writable(rt, dst, rt.cache.activation_source_ledger,
                          t.ctx) :
      full_check_fill_owner(rt, dst);
  if (c && t.ctx.op == Op::LIN_QKV)
    c = full_check_fill_owner(rt, qkv[1]);
  if (c && t.ctx.op == Op::LIN_QKV)
    c = full_check_uncovered_qkv(rt, qkv, t.ctx.batch,
                                 t.ctx.row0, t.ctx.rows);
  else if (c && !scorer_lease)
    c = full_check_uncovered_owner(rt, dst, t.ctx.batch,
                                   t.ctx.row0, t.ctx.rows);
  if (!c) return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  bool weight_read = false, activation_read = false, ps_read = false;
  c = full_acquire_owner(rt, weight, 0, 0, 1);
  if (!c) return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  weight_read = true;
  c = full_acquire_owner(rt, activation, t.ctx.batch,
                         t.ctx.row0, t.ctx.rows);
  if (!c) {
    full_release_read_owner(rt, weight);
    return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  activation_read = true;
  const FullOwnerSpec ps = tile_spec(t.ps, 0, t.ctx, t.N, Content::F32);
  c = full_claim_owner(rt, ps);
  if (!c) {
    full_release_read_owner(rt, activation);
    full_release_read_owner(rt, weight);
    return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  const unsigned groups = t.K / 32;
  for (unsigned n0 = 0; n0 < t.N; n0 += 8) {
    const uint8_t cols = uint8_t(t.N - n0 < 8 ? t.N - n0 : 8);
    int8_t wq[8][128][32] = {};
    uint16_t ws[8][128] = {};
    float bias[8] = {};
    float y[16][8] = {};
    for (unsigned col = 0; col < cols; ++col) {
      const unsigned n = n0 + col;
      bias[col] = full_cache_weight_bias(rt)[n];
      for (unsigned g = 0; g < groups; ++g) {
        const unsigned entry = n * groups + g;
        ws[col][g] = full_cache_weight_scale(rt)[entry];
        for (unsigned k = 0; k < 32; ++k)
          wq[col][g][k] = full_cache_weight_q(rt)[entry * 32 + k];
      }
    }
    c = q8_linear_owned_window_arithmetic(t, rt.inputs.identity,
                                           uint16_t(n0), cols,
                                           full_cache_activation_q(rt),
                                           full_cache_activation_scale(rt),
                                           wq, ws, bias, y);
    if (!c) goto failed_after_claim;
    for (unsigned r = 0; r < t.ctx.rows; ++r)
      for (unsigned col = 0; col < cols; ++col)
        full_cache_ps_tile(rt)[r][n0 + col] = y[r][col];
  }
  c = full_cover_owner(rt, ps, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (c) c = full_publish_owner(rt, ps);
  if (!c) goto failed_after_claim;
  c = full_acquire_owner(rt, ps, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (!c) goto failed_after_claim;
  ps_read = true;
  c = write_linear_output(rt, memory, t);
  if (!c) goto failed_after_claim;
  c = full_release_read_owner(rt, ps);
  if (!c) goto failed_after_claim;
  ps_read = false;
  if (t.ctx.op == Op::LIN_QKV) {
    for (uint8_t plane = 0; plane < 3; ++plane)
      for (uint8_t head = 0; head < 16; ++head) {
        c = full_cover_qkv(rt, qkv, plane, head, t.ctx.batch,
                           t.ctx.row0, t.ctx.rows);
        if (!c) goto failed_after_claim;
      }
  } else {
    c = full_cover_owner(rt, dst, t.ctx.batch, t.ctx.row0, t.ctx.rows);
    if (!c) goto failed_after_claim;
  }
  c = full_release_read_owner(rt, activation);
  if (!c) goto failed_after_claim;
  activation_read = false;
  c = full_release_read_owner(rt, weight);
  if (!c) goto failed_after_claim;
  weight_read = false;
  c = full_release_owner(rt, ps);
  if (!c) goto failed_after_claim;
  c = full_release_owner(rt, activation);
  if (!c) goto failed_after_claim;
  c = numeric_release_a8(rt.cache.activation_meta);
  if (!c) goto failed_after_claim;
  return finish(rt, t.ctx, ok(), OutputUnit::F32,
                uint32_t(t.ctx.rows) * t.N, done);

failed_after_claim:
  if (ps_read) full_release_read_owner(rt, ps);
  if (activation_read) full_release_read_owner(rt, activation);
  if (weight_read) full_release_read_owner(rt, weight);
  full_invalidate_owner(rt, t.ps, 0);
  full_invalidate_owner(rt, t.dst, t.dst_region);
  if (t.ctx.op == Op::LIN_QKV)
    full_invalidate_owner(rt, qkv[1].ref, 0);
  return finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
}

} // namespace laya::full
