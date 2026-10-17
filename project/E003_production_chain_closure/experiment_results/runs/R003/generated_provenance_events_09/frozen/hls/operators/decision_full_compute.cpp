#include "laya_full_numeric.h"

#include <cmath>

namespace laya::full {
namespace {
bool finite32(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
Check shape(Op op) {
  return {Status::E_SHAPE, detail(7, uint8_t(op), 5)};
}
Check numerical(Op op, uint64_t element) {
  return {Status::E_NUMERICAL, detail(7, uint8_t(op), 15), element};
}
} // namespace

Check candidate_mask(const float logits[16], const uint8_t mask[16],
                      float y[16]) {
  if (logits == nullptr || mask == nullptr || y == nullptr)
    return shape(Op::APPLY_CAND_MASK);
  for (unsigned i = 0; i < 16; ++i)
    if (mask[i] > 1) return shape(Op::APPLY_CAND_MASK);
  for (unsigned i = 0; i < 16; ++i) {
    if (!finite32(logits[i])) return numerical(Op::APPLY_CAND_MASK, i);
    const float m = 1.0f - float(mask[i]);
    const float b = m * -10000.0f;
    if (!finite32(m) || !finite32(b))
      return numerical(Op::APPLY_CAND_MASK, i);
    const float value = logits[i] + b;
    if (!finite32(value)) return numerical(Op::APPLY_CAND_MASK, i);
    y[i] = value;
  }
  return ok();
}

Check candidate_stats(const float p[16], uint8_t valid_options,
                       float stats[4]) {
  if (p == nullptr || stats == nullptr || valid_options < 1 ||
      valid_options > 16) return shape(Op::CAND_STATS);

  float tree[16];
  for (unsigned i = 0; i < 16; ++i) {
    if (!finite32(p[i]) || p[i] < 0.0f || p[i] > 1.0f)
      return numerical(Op::CAND_STATS, i);
    const float clamped = p[i] > 1e-9f ? p[i] : 1e-9f;
    const float logarithm = ::logf(clamped);
    if (!finite32(logarithm)) return numerical(Op::CAND_STATS, i);
    tree[i] = p[i] * logarithm;
    if (!finite32(tree[i])) return numerical(Op::CAND_STATS, i);
  }
  for (unsigned width = 16; width > 1; width /= 2) {
    for (unsigned i = 0; i < width / 2; ++i) {
      tree[i] = tree[2 * i] + tree[2 * i + 1];
      if (!finite32(tree[i])) return numerical(Op::CAND_STATS, i);
    }
  }
  const uint8_t k = valid_options < 2 ? 2 : valid_options;
  const float log_k = ::logf(float(k));
  if (!finite32(log_k) || log_k <= 0.0f)
    return numerical(Op::CAND_STATS, 16);
  const float entropy = (-tree[0]) / log_k;
  if (!finite32(entropy)) return numerical(Op::CAND_STATS, 16);

  float top1 = p[0];
  for (unsigned i = 1; i < 16; ++i) {
    const float difference = top1 - p[i];
    if (!finite32(difference)) return numerical(Op::CAND_STATS, i);
    const float rectified = difference > 0.0f ? difference : 0.0f;
    top1 = rectified + p[i];
    if (!finite32(top1)) return numerical(Op::CAND_STATS, i);
  }

  float approximate[16];
  for (unsigned i = 0; i < 16; ++i) {
    const float delta = top1 - p[i];
    if (!finite32(delta)) return numerical(Op::CAND_STATS, i);
    const float denom = delta + 1e-6f;
    if (!finite32(denom) || denom == 0.0f)
      return numerical(Op::CAND_STATS, i);
    const float ratio = delta / denom;
    if (!finite32(ratio)) return numerical(Op::CAND_STATS, i);
    approximate[i] = p[i] * ratio;
    if (!finite32(approximate[i])) return numerical(Op::CAND_STATS, i);
  }
  float top2 = approximate[0];
  for (unsigned i = 1; i < 16; ++i) {
    const float difference = top2 - approximate[i];
    if (!finite32(difference)) return numerical(Op::CAND_STATS, i);
    const float rectified = difference > 0.0f ? difference : 0.0f;
    top2 = rectified + approximate[i];
    if (!finite32(top2)) return numerical(Op::CAND_STATS, i);
  }
  const float gap = top1 - top2;
  const float normalized_k = float(k) / 255.0f;
  if (!finite32(gap) || !finite32(normalized_k))
    return numerical(Op::CAND_STATS, 16);
  stats[0] = top1;
  stats[1] = gap;
  stats[2] = entropy;
  stats[3] = normalized_k;
  return ok();
}

Check concat_act_row(const float cls[1024], const float stats[4],
                      float y[1028]) {
  if (cls == nullptr || stats == nullptr || y == nullptr)
    return shape(Op::CONCAT_ACT);
  for (unsigned i = 0; i < 1024; ++i) {
    if (!finite32(cls[i])) return numerical(Op::CONCAT_ACT, i);
    y[i] = cls[i];
  }
  for (unsigned i = 0; i < 4; ++i) {
    if (!finite32(stats[i])) return numerical(Op::CONCAT_ACT, 1024 + i);
    y[1024 + i] = stats[i];
  }
  return ok();
}

} // namespace laya::full
