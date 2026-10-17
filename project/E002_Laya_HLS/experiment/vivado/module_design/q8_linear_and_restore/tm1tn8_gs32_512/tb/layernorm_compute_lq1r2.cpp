#include "laya_numeric.h"

#include <cmath>

namespace laya {
namespace {
bool finite32(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
Check numerical(Op op, unsigned row, unsigned col) {
  return {Status::E_NUMERICAL, detail(7, uint8_t(op), 15),
          uint64_t(row) * 1024 + col};
}
Check validate_task(const LayerNormTask& t, const NumericIdentity& id) {
  Check c = numeric_check_context(t.ctx, id);
  if (!c) return c;
  c = numeric_check_ref(t.src);
  if (!c) return c;
  c = numeric_check_ref(t.dst);
  if (!c) return c;
  if (t.D != 1024 || t.eps_bits != 0x3727c5acu ||
      (t.src.id == t.dst.id && t.src.bank == t.dst.bank))
    return {Status::E_SHAPE, detail(7, uint8_t(t.ctx.op), 5)};
  bool valid = false;
  switch (t.ctx.op) {
    case Op::LN_EMB:
      valid = t.ctx.stage == 1 && t.ctx.row_space == RowSpace::TOKEN &&
              t.gamma == 1 && t.src.id == Buffer::HIDDEN &&
              (t.dst.id == Buffer::NORM ||
               (t.dst.id == Buffer::HIDDEN && t.dst.bank != t.src.bank));
      break;
    case Op::LN_ATTN:
      valid = (t.ctx.stage == 2 || t.ctx.stage == 4) &&
              !(t.ctx.stage == 2 && t.ctx.layer == 0) &&
              t.ctx.row_space == RowSpace::TOKEN && t.gamma == 0 &&
              t.src.id == Buffer::HIDDEN && t.dst.id == Buffer::NORM;
      break;
    case Op::LN_FFN:
      valid = (t.ctx.stage == 2 || t.ctx.stage == 4) &&
              t.ctx.row_space == RowSpace::TOKEN && t.gamma == 0 &&
              t.src.id == Buffer::HIDDEN && t.dst.id == Buffer::NORM;
      break;
    case Op::LN_FINAL:
      valid = t.ctx.stage == 3 && t.ctx.row_space == RowSpace::TOKEN &&
              t.gamma == 2 && t.src.id == Buffer::HIDDEN &&
              (t.dst.id == Buffer::NORM ||
               (t.dst.id == Buffer::HIDDEN && t.dst.bank != t.src.bank));
      break;
    case Op::LN_MARKER:
      valid = t.ctx.stage == 5 && t.ctx.row_space == RowSpace::MARKER &&
              t.gamma == 0 && t.src.id == Buffer::MARKER &&
              t.dst.id == Buffer::HEAD_WORK;
      break;
    default: break;
  }
  return valid ? ok() : Check{Status::E_SHAPE, detail(7, uint8_t(t.ctx.op), 5)};
}
} // namespace

Check layernorm_row_arithmetic(Op op, unsigned row_index,
                               const float x[1024], const float gamma[1024],
                               uint8_t gamma_kind, float y[1024],
                               float& mean, float& variance, float& inverse) {
  if (gamma_kind > 2)
    return {Status::E_SHAPE, detail(7, uint8_t(op), 5)};
  float row[1024];
  float tree[1024];
  const float eps = numeric_bits_f32(0x3727c5acu);
  for (unsigned i = 0; i < 1024; ++i) {
    row[i] = x[i];
    if (!finite32(row[i])) return numerical(op, row_index, i);
    tree[i] = row[i];
  }
  for (unsigned width = 1024; width > 1; width /= 2) {
    for (unsigned i = 0; i < width / 2; ++i) {
      const float lhs = tree[2 * i], rhs = tree[2 * i + 1];
      tree[i] = lhs + rhs;
      if (!finite32(tree[i])) return numerical(op, row_index, i);
    }
  }
  const float m = tree[0] / 1024.0f;
  if (!finite32(m)) return numerical(op, row_index, 0);
  mean = m;
  for (unsigned i = 0; i < 1024; ++i) {
    const float delta = row[i] - m;
    if (!finite32(delta)) return numerical(op, row_index, i);
    tree[i] = delta * delta;
    if (!finite32(tree[i])) return numerical(op, row_index, i);
  }
  for (unsigned width = 1024; width > 1; width /= 2) {
    for (unsigned i = 0; i < width / 2; ++i) {
      const float lhs = tree[2 * i], rhs = tree[2 * i + 1];
      tree[i] = lhs + rhs;
      if (!finite32(tree[i])) return numerical(op, row_index, i);
    }
  }
  const float v = tree[0] / 1024.0f;
  if (!finite32(v) || v < 0.0f) return numerical(op, row_index, 0);
  variance = v;
  const float shifted = v + eps;
  if (!finite32(shifted)) return numerical(op, row_index, 0);
  const float root = ::sqrtf(shifted);
  if (!finite32(root) || root <= 0.0f) return numerical(op, row_index, 0);
  const float inv = 1.0f / root;
  if (!finite32(inv)) return numerical(op, row_index, 0);
  inverse = inv;
  for (unsigned i = 0; i < 1024; ++i) {
#pragma HLS PIPELINE II=1
    const float delta = row[i] - m;
#pragma HLS BIND_OP variable=delta op=fsub impl=fulldsp latency=5
    if (!finite32(delta)) return numerical(op, row_index, i);
    const float norm = delta * inv;
#pragma HLS BIND_OP variable=norm op=fmul impl=maxdsp latency=3
    if (!finite32(norm)) return numerical(op, row_index, i);
    float out = norm;
    if (gamma_kind != 0) {
      if (!finite32(gamma[i])) return numerical(op, row_index, i);
      out = norm * gamma[i];
      if (!finite32(out)) return numerical(op, row_index, i);
    }
    y[i] = out;
  }
  return ok();
}

Check layernorm_compute(const LayerNormTask& task,
                        const NumericIdentity& request,
                        const F32TileMeta& source, const GammaMeta& gamma_meta,
                        const float x[16][1024], const float gamma[1024],
                        float y[16][1024], float mean[16],
                        float variance[16], float inverse[16],
                        F32TileMeta& result) {
  Check c = validate_task(task, request);
  if (!c) return c;
  c = numeric_check_source(source, request, task.src, 0, task.ctx, 1024);
  if (!c) return c;
  c = numeric_check_gamma(gamma_meta, request, task.gamma);
  if (!c) return c;
  c = numeric_claim_f32(result, task.dst, 0);
  if (!c) return c;
  result.identity = request;

  for (unsigned r = 0; r < task.ctx.rows; ++r) {
    c = layernorm_row_arithmetic(task.ctx.op, r, x[r], gamma,
                                  task.gamma, y[r], mean[r], variance[r],
                                  inverse[r]);
    if (!c) {
      result.state = CacheState::INVALID;
      result.valid = false;
      return c;
    }
  }

  result.identity = request;
  result.ref = task.dst;
  result.region = 0;
  result.row_space = task.ctx.row_space;
  result.batch = task.ctx.batch;
  result.row0 = task.ctx.row0;
  result.rows = task.ctx.rows;
  result.K = 1024;
  numeric_cover_all(result.covered_groups, result.rows, 32, 16);
  result.content = Content::F32;
  result.state = CacheState::READY;
  result.valid = true;
  return ok();
}

} // namespace laya
