#include "laya_full_numeric.h"

#include <cmath>

namespace laya::full {
namespace {
bool finite32(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
bool valid_s(uint16_t s) {
  return s == 64 || s == 128 || s == 256 || s == 512 || s == 1024;
}
Check shape(Op op) {
  return {Status::E_SHAPE, detail(7, uint8_t(op), 5)};
}
Check numerical(Op op, uint64_t element) {
  return {Status::E_NUMERICAL, detail(7, uint8_t(op), 15), element};
}
} // namespace

Check qk_row(const float q[64], const float k[1024][64],
             const uint8_t mask[1024], uint16_t S, uint16_t query,
             bool sliding, float score[1024]) {
  if (q == nullptr || k == nullptr || mask == nullptr || score == nullptr ||
      !valid_s(S) || query >= S) return shape(Op::QK);
  for (unsigned key = 0; key < S; ++key)
    if (mask[key] > 1) return shape(Op::QK);
  for (unsigned d = 0; d < 64; ++d)
    if (!finite32(q[d])) return numerical(Op::QK, d);

  float tree[64];
  for (unsigned key = 0; key < S; ++key) {
    for (unsigned d = 0; d < 64; ++d) {
      if (!finite32(k[key][d])) return numerical(Op::QK, uint64_t(key) * 64 + d);
      tree[d] = q[d] * k[key][d];
      if (!finite32(tree[d])) return numerical(Op::QK, uint64_t(key) * 64 + d);
    }
    for (unsigned width = 64; width > 1; width /= 2) {
      for (unsigned i = 0; i < width / 2; ++i) {
        tree[i] = tree[2 * i] + tree[2 * i + 1];
        if (!finite32(tree[i])) return numerical(Op::QK, uint64_t(key) * 64 + i);
      }
    }
    const float scaled = tree[0] * 0.125f;
    if (!finite32(scaled)) return numerical(Op::QK, key);
    const float mask_minus_one = float(mask[key]) - 1.0f;
    const float pad = mask_minus_one * 10000.0f;
    if (!finite32(pad)) return numerical(Op::QK, key);
    const unsigned distance = query > key ? query - key : key - query;
    const float local = sliding && distance > 64 ? -10000.0f : 0.0f;
    const float bias = sliding ? local + pad : pad;
    if (!finite32(bias)) return numerical(Op::QK, key);
    const float value = scaled + bias;
    if (!finite32(value)) return numerical(Op::QK, key);
    score[key] = value;
  }
  return ok();
}

Check softmax_row(const float x[1024], uint16_t length, float p[1024]) {
  if (x == nullptr || p == nullptr || (length != 16 && !valid_s(length)))
    return shape(Op::SOFTMAX_ATT);
  for (unsigned i = 0; i < length; ++i)
    if (!finite32(x[i])) return numerical(Op::SOFTMAX_ATT, i);
  float maximum = x[0];
  for (unsigned i = 1; i < length; ++i)
    if (x[i] > maximum) maximum = x[i];

  float exponential[1024];
  float tree[1024];
  for (unsigned i = 0; i < length; ++i) {
    const float z = x[i] - maximum;
    if (!finite32(z)) return numerical(Op::SOFTMAX_ATT, i);
    const float e = ::expf(z);
    if (!finite32(e)) return numerical(Op::SOFTMAX_ATT, i);
    exponential[i] = e;
    tree[i] = e;
  }
  for (unsigned width = length; width > 1; width /= 2) {
    for (unsigned i = 0; i < width / 2; ++i) {
      tree[i] = tree[2 * i] + tree[2 * i + 1];
      if (!finite32(tree[i])) return numerical(Op::SOFTMAX_ATT, i);
    }
  }
  const float sum = tree[0];
  if (!finite32(sum) || sum <= 0.0f) return numerical(Op::SOFTMAX_ATT, 0);
  for (unsigned i = 0; i < length; ++i) {
    const float value = exponential[i] / sum;
    if (!finite32(value)) return numerical(Op::SOFTMAX_ATT, i);
    p[i] = value;
  }
  return ok();
}

Check av_row(const float p[1024], const float v[1024][64],
             uint16_t S, float y[64]) {
  if (p == nullptr || v == nullptr || y == nullptr || !valid_s(S))
    return shape(Op::AV);
  for (unsigned key = 0; key < S; ++key) {
    if (!finite32(p[key])) return numerical(Op::AV, uint64_t(key) * 64);
    for (unsigned d = 0; d < 64; ++d)
      if (!finite32(v[key][d])) return numerical(Op::AV, uint64_t(key) * 64 + d);
  }
  for (unsigned d = 0; d < 64; ++d) {
    float acc = 0.0f;
    for (unsigned key = 0; key < S; ++key) {
      const float product = p[key] * v[key][d];
      if (!finite32(product)) return numerical(Op::AV, uint64_t(key) * 64 + d);
      acc = acc + product;
      if (!finite32(acc)) return numerical(Op::AV, uint64_t(key) * 64 + d);
    }
    y[d] = acc;
  }
  return ok();
}

Check fp_scorer_row(const float x[1024], const float w[1024],
                    float bias, float& y) {
  if (x == nullptr || w == nullptr) return shape(Op::FP_SCORER_FC2);
  if (!finite32(bias)) return numerical(Op::FP_SCORER_FC2, 1024);
  float acc = 0.0f;
  for (unsigned i = 0; i < 1024; ++i) {
    if (!finite32(x[i]) || !finite32(w[i]))
      return numerical(Op::FP_SCORER_FC2, i);
    const float product = x[i] * w[i];
    if (!finite32(product)) return numerical(Op::FP_SCORER_FC2, i);
    acc = acc + product;
    if (!finite32(acc)) return numerical(Op::FP_SCORER_FC2, i);
  }
  acc = acc + bias;
  if (!finite32(acc)) return numerical(Op::FP_SCORER_FC2, 1024);
  y = acc;
  return ok();
}

Check fp_act_row(const float x[1028], const uint16_t w[256][1028],
                 float y[256]) {
  if (x == nullptr || w == nullptr || y == nullptr) return shape(Op::FP_ACT_FC1);
  for (unsigned k = 0; k < 1028; ++k)
    if (!finite32(x[k])) return numerical(Op::FP_ACT_FC1, k);
  for (unsigned n = 0; n < 256; ++n) {
    float acc = 0.0f;
    for (unsigned k = 0; k < 1028; ++k) {
      const float weight = numeric_half_to_f32(w[n][k]);
      if (!finite32(weight))
        return numerical(Op::FP_ACT_FC1, uint64_t(n) * 1028 + k);
      const float product = x[k] * weight;
      if (!finite32(product))
        return numerical(Op::FP_ACT_FC1, uint64_t(n) * 1028 + k);
      acc = acc + product;
      if (!finite32(acc))
        return numerical(Op::FP_ACT_FC1, uint64_t(n) * 1028 + k);
    }
    y[n] = acc;
  }
  return ok();
}

} // namespace laya::full
