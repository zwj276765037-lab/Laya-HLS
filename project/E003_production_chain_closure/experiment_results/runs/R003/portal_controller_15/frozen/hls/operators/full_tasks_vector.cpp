#include "full_task_common.h"

namespace laya::full {
namespace {

uint16_t length_for(Op op) {
  switch (op) {
    case Op::GEGLU: return 2624;
    case Op::RELU: return 4096;
    case Op::ADD_RESIDUAL: case Op::ADD_TYPE:
    case Op::BIAS_GELU_SCORER: return 1024;
    case Op::BIAS_GELU_ACT: return 256;
    case Op::APPLY_CAND_MASK: return 16;
    default: return 0;
  }
}
bool vector_shape(const VectorTask& t) {
  if (!length_for(t.ctx.op) || t.length != length_for(t.ctx.op) ||
      !check_ref(t.src0, t.src0_region) ||
      !check_ref(t.src1, t.src1_region) ||
      !check_ref(t.dst, t.dst_region)) return false;
  switch (t.ctx.op) {
    case Op::GEGLU:
      return t.ctx.stage == 2 && t.ctx.row_space == RowSpace::TOKEN &&
             t.src0.id == Buffer::WI && t.src1 == none() &&
             t.dst.id == Buffer::GATE && t.bias_id == 65535;
    case Op::RELU:
      return t.ctx.stage == 4 && t.ctx.row_space == RowSpace::TOKEN &&
             t.src0.id == Buffer::DEC_FF && t.src1 == none() &&
             t.dst.id == Buffer::DEC_FF &&
             t.dst.epoch == t.src0.epoch + 1 && t.bias_id == 65535;
    case Op::ADD_RESIDUAL:
      return (t.ctx.stage == 2 || t.ctx.stage == 4) &&
             t.ctx.row_space == RowSpace::TOKEN &&
             t.src0.id == Buffer::TMP && t.src1.id == Buffer::HIDDEN &&
             t.dst.id == Buffer::HIDDEN &&
             t.dst.bank != t.src1.bank && t.bias_id == 65535;
    case Op::ADD_TYPE:
      return t.ctx.stage == 3 && t.ctx.row_space == RowSpace::TOKEN &&
             t.src0.id == Buffer::HIDDEN &&
             t.src1.id == Buffer::TYPE_ROWS &&
             t.dst.id == Buffer::HIDDEN &&
             t.dst.bank != t.src0.bank && t.bias_id == 65535;
    case Op::BIAS_GELU_SCORER:
      return t.ctx.stage == 5 && t.ctx.row_space == RowSpace::MARKER &&
             t.src0.id == Buffer::HEAD_WORK &&
             t.src0_region == uint8_t(Region::SCORER_ACT) &&
             t.src1 == none() && t.dst.id == Buffer::HEAD_WORK &&
             t.dst_region == t.src0_region &&
             t.dst.epoch == t.src0.epoch + 1;
    case Op::BIAS_GELU_ACT:
      return t.ctx.stage == 6 && t.ctx.row_space == RowSpace::BATCH &&
             t.src0.id == Buffer::HEAD_WORK &&
             t.src0_region == uint8_t(Region::ACT_HIDDEN) &&
             t.src1 == none() && t.dst.id == Buffer::HEAD_WORK &&
             t.dst_region == t.src0_region &&
             t.dst.epoch == t.src0.epoch + 1;
    case Op::APPLY_CAND_MASK:
      return t.ctx.stage == 5 && t.ctx.row_space == RowSpace::BATCH &&
             t.src0.id == Buffer::HEAD_WORK &&
             t.src0_region == uint8_t(Region::CAND_RAW) &&
             t.src1 == none() && t.dst.id == Buffer::HEAD_WORK &&
             t.dst_region == uint8_t(Region::CAND_MASKED) &&
             t.bias_id == 65535;
    default: return false;
  }
}
bool inplace(Op op) {
  return op == Op::RELU || op == Op::BIAS_GELU_SCORER ||
         op == Op::BIAS_GELU_ACT;
}
Check precheck_lease(FullRuntime& rt, const VectorTask& t,
                     FullOwnerSpec& dst) {
  const RowSpace space = t.ctx.row_space;
  dst = task::spec(t.dst, t.dst_region, t.ctx.stage, t.ctx.layer,
                   space, task::extent(rt, space), t.length);
  FullOwnerRecord owner;
  Check c = full_owner_snapshot(rt, t.dst, t.dst_region, owner);
  if (!c || owner.state != CacheState::EXCLUSIVE_RW ||
      owner.lease_old_ref != t.src0 || owner.ref != t.dst ||
      owner.stage != t.ctx.stage || owner.layer != t.ctx.layer ||
      owner.content != Content::F32 || owner.width != t.length ||
      owner.row_space != space || owner.batch != 255 ||
      owner.row0 || owner.rows != task::extent(rt, space) ||
      !numeric_identity_equal(owner.identity, rt.inputs.identity))
    return task::buffer(t.dst.id);
  for (unsigned r = 0; r < t.ctx.rows; ++r) {
    const unsigned row = t.ctx.row0 + r;
    const unsigned stride = space == RowSpace::TOKEN ? 1024 :
                            space == RowSpace::MARKER ? 16 : 1;
    const unsigned bit = t.ctx.batch * stride + row;
    if ((owner.old_consumed_rows[bit / 32] | owner.covered_rows[bit / 32]) &
        (uint32_t(1) << (bit % 32))) return task::buffer(t.dst.id);
  }
  return ok();
}
Check load_bias(const FullRuntime& rt, const FullMemory& memory, const VectorTask& t,
                float bias[1024]) {
  const char* name = t.ctx.op == Op::BIAS_GELU_SCORER ?
                     "scorer_fc1.bias" : "act_fc1.bias";
  FullTensorDescriptor d;
  uint16_t index = 65535;
  Check c = full_lookup_tensor_indexed(name, d, index);
  if (!c || t.bias_id != index || d.bo != uint8_t(Bo::AUX) ||
      d.ggml_type_id != 0 || d.span != uint32_t(t.length) * 4)
    return task::buffer(t.dst.id);
  c = full_span(memory, Bo::AUX, d.base, d.span);
  if (!c) return c;
  for (unsigned i = 0; i < t.length; ++i) {
    uint8_t raw[4];
    c = full_read(memory, Bo::AUX, uint64_t(d.base) + i * 4, raw, 4);
    if (!c) return c;
    bias[i] = numeric_bits_f32(uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                               uint32_t(raw[2]) << 16 |
                               uint32_t(raw[3]) << 24);
    if (!task::finite(bias[i])) return task::numerical(t.ctx.op, i);
  }
  return ok();
}

} // namespace

Check full_run_task(FullRuntime& rt, FullMemory& memory, const VectorTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (!vector_shape(t))
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  const bool lease = inplace(t.ctx.op);
  FullOwnerSpec dst;
  if (lease) c = precheck_lease(rt, t, dst);
  else {
    dst = task::spec(t.dst, t.dst_region, t.ctx.stage, t.ctx.layer,
                     t.ctx.row_space, task::extent(rt, t.ctx.row_space),
                     t.length);
    c = full_check_uncovered_owner(rt, dst, t.ctx.batch,
                                   t.ctx.row0, t.ctx.rows);
  }
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  float bias[1024] = {};
  if (t.ctx.op == Op::BIAS_GELU_SCORER ||
      t.ctx.op == Op::BIAS_GELU_ACT) {
    c = load_bias(rt, memory, t, bias);
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  }
  FullOwnerSpec src0, src1;
  bool have_src0 = false, have_src1 = false;
  if (!lease) {
    if (t.ctx.op == Op::APPLY_CAND_MASK) {
      c = task::bound(rt, t.src0, t.src0_region, 1, src0);
      if (c && (src0.row_space != RowSpace::MARKER || src0.stage != 5 ||
                src0.batch != 255 || src0.row0 || src0.rows != 16))
        c = task::buffer(t.src0.id);
      if (c) c = full_require_owner(rt, src0, t.ctx.batch, 0, 16);
    } else {
      const uint16_t width = t.ctx.op == Op::GEGLU ? 5248 : 1024;
      c = task::source(rt, t.src0, t.src0_region, t.ctx, width, src0);
    }
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    have_src0 = true;
    if (t.ctx.op == Op::ADD_RESIDUAL)
      c = task::source(rt, t.src1, t.src1_region, t.ctx, 1024, src1);
    if (t.ctx.op == Op::ADD_TYPE) {
      c = task::bound(rt, t.src1, t.src1_region, 1024, src1);
      if (c && (src1.row_space != RowSpace::BATCH || src1.stage != 3 ||
                src1.batch != 0 || src1.row0 || src1.rows != 3))
        c = task::buffer(t.src1.id);
      if (c) c = full_require_owner(rt, src1, 0,
                                    rt.inputs.qtype[t.ctx.batch], 1);
    }
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    have_src1 = t.ctx.op == Op::ADD_RESIDUAL || t.ctx.op == Op::ADD_TYPE;
    c = full_acquire_owner(rt, src0, t.ctx.batch,
                           t.ctx.op == Op::APPLY_CAND_MASK ? 0 : t.ctx.row0,
                           t.ctx.op == Op::APPLY_CAND_MASK ? 16 : t.ctx.rows);
    const bool src0_read = bool(c);
    if (c && have_src1)
      c = full_acquire_owner(rt, src1,
                             t.ctx.op == Op::ADD_TYPE ? 0 : t.ctx.batch,
                             t.ctx.op == Op::ADD_TYPE ?
                                 rt.inputs.qtype[t.ctx.batch] : t.ctx.row0,
                             t.ctx.op == Op::ADD_TYPE ? 1 : t.ctx.rows);
    if (!c) {
      if (src0_read) full_release_read_owner(rt, src0);
      return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    }
  }
  // Every row is fully captured before its lease is consumed or destination
  // bytes are overwritten. GEGLU and bias-GELU use the production integer
  // binary32 graph shared with the actual vector module RTL probe.
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    const uint16_t row = uint16_t(t.ctx.row0 + r);
    if (t.ctx.op == Op::GEGLU) {
      float wi[5248], y[2624];
      for (unsigned i = 0; i < 5248; ++i) {
        c = task::read(rt, memory, t.src0, t.src0_region, t.ctx.batch,
                       row, uint16_t(i), wi[i]);
        if (!c) break;
      }
      if (c) c = geglu_row(wi, y);
      for (unsigned i = 0; i < 2624 && c; ++i)
        c = task::write(rt, memory, t.dst, t.dst_region, t.ctx.batch,
                        row, uint16_t(i), y[i]);
    } else if (t.ctx.op == Op::APPLY_CAND_MASK) {
      float raw[16], y[16];
      for (unsigned i = 0; i < 16; ++i) {
        c = task::read(rt, memory, t.src0, t.src0_region, t.ctx.batch,
                       uint16_t(i), 0, raw[i]);
        if (!c) break;
      }
      if (c) c = candidate_mask(raw,
                                rt.inputs.marker_mask[t.ctx.batch], y);
      for (unsigned i = 0; i < 16 && c; ++i)
        c = task::write(rt, memory, t.dst, t.dst_region, t.ctx.batch,
                        0, uint16_t(i), y[i]);
    } else if (t.ctx.op == Op::RELU) {
      float x[4096], y[4096];
      for (unsigned i = 0; i < 4096; ++i) {
        c = task::read(rt, memory, t.src0, t.src0_region, t.ctx.batch,
                       row, uint16_t(i), x[i]);
        if (!c) break;
      }
      if (c) c = relu_row(x, y);
      if (c) c = full_consume_inplace_rows(rt, dst, t.ctx.batch, row, 1);
      for (unsigned i = 0; i < 4096 && c; ++i)
        c = task::write(rt, memory, t.dst, t.dst_region, t.ctx.batch,
                        row, uint16_t(i), y[i]);
      if (c) c = full_cover_owner(rt, dst, t.ctx.batch, row, 1);
    } else if (t.ctx.op == Op::BIAS_GELU_SCORER ||
               t.ctx.op == Op::BIAS_GELU_ACT) {
      float x[1024] = {}, y[1024] = {};
      for (unsigned i = 0; i < t.length; ++i) {
        c = task::read(rt, memory, t.src0, t.src0_region, t.ctx.batch,
                       row, uint16_t(i), x[i]);
        if (!c) break;
      }
      if (c) c = bias_gelu_row(x, bias, t.length, y);
      if (c) c = full_consume_inplace_rows(rt, dst, t.ctx.batch, row, 1);
      for (unsigned i = 0; i < t.length && c; ++i)
        c = task::write(rt, memory, t.dst, t.dst_region, t.ctx.batch,
                        row, uint16_t(i), y[i]);
      if (c) c = full_cover_owner(rt, dst, t.ctx.batch, row, 1);
    } else {
      float a[1024], b[1024], y[1024];
      for (unsigned i = 0; i < 1024; ++i) {
        c = task::read(rt, memory, t.src0, t.src0_region, t.ctx.batch,
                       row, uint16_t(i), a[i]);
        if (!c) break;
      }
      for (unsigned i = 0; i < 1024 && c; ++i)
        c = task::read(rt, memory, t.src1, t.src1_region,
                       t.ctx.op == Op::ADD_TYPE ? 0 : t.ctx.batch,
                       t.ctx.op == Op::ADD_TYPE ?
                           rt.inputs.qtype[t.ctx.batch] : row,
                       uint16_t(i), b[i]);
      if (c) c = add_row(a, b, y);
      for (unsigned i = 0; i < 1024 && c; ++i)
        c = task::write(rt, memory, t.dst, t.dst_region, t.ctx.batch,
                        row, uint16_t(i), y[i]);
    }
  }
  if (have_src1) full_release_read_owner(rt, src1);
  if (have_src0) full_release_read_owner(rt, src0);
  if (c && !lease) c = full_cover_owner(rt, dst, t.ctx.batch,
                                        t.ctx.row0, t.ctx.rows);
  if (!c) full_invalidate_owner(rt, t.dst, t.dst_region);
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * t.length, done);
}

} // namespace laya::full
