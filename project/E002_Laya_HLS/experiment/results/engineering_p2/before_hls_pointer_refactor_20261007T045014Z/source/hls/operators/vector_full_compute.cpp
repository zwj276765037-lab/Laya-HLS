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

Check gelu_scalar(float x, float& y) {
  if (!finite32(x)) return numerical(Op::GEGLU, 0);
  const float a = 0.044715f;
  const float c = 0.7978845608028654f;
  const float u = a * x;
  if (!finite32(u)) return numerical(Op::GEGLU, 0);
  const float v = u * x;
  if (!finite32(v)) return numerical(Op::GEGLU, 0);
  const float w = 1.0f + v;
  if (!finite32(w)) return numerical(Op::GEGLU, 0);
  const float t = c * x;
  if (!finite32(t)) return numerical(Op::GEGLU, 0);
  const float z = t * w;
  if (!finite32(z)) return numerical(Op::GEGLU, 0);
  const float h = ::tanhf(z);
  if (!finite32(h)) return numerical(Op::GEGLU, 0);
  const float r = 1.0f + h;
  if (!finite32(r)) return numerical(Op::GEGLU, 0);
  const float s = 0.5f * x;
  if (!finite32(s)) return numerical(Op::GEGLU, 0);
  const float result = s * r;
  if (!finite32(result)) return numerical(Op::GEGLU, 0);
  y = result;
  return ok();
}

Check geglu_row(const float wi[5248], float y[2624]) {
  if (wi == nullptr || y == nullptr) return shape(Op::GEGLU);
  for (unsigned i = 0; i < 2624; ++i) {
    if (!finite32(wi[i + 2624])) return numerical(Op::GEGLU, i + 2624);
    float activated = 0.0f;
    Check c = gelu_scalar(wi[i], activated);
    if (!c) return numerical(Op::GEGLU, i);
    const float value = activated * wi[i + 2624];
    if (!finite32(value)) return numerical(Op::GEGLU, i);
    y[i] = value;
  }
  return ok();
}

Check relu_row(const float x[4096], float y[4096]) {
  if (x == nullptr || y == nullptr) return shape(Op::RELU);
  for (unsigned i = 0; i < 4096; ++i) {
    const float value = x[i];
    if (!finite32(value)) return numerical(Op::RELU, i);
    y[i] = value > 0.0f ? value : 0.0f;
  }
  return ok();
}

Check add_row(const float a[1024], const float b[1024], float y[1024]) {
  if (a == nullptr || b == nullptr || y == nullptr)
    return shape(Op::ADD_RESIDUAL);
  for (unsigned i = 0; i < 1024; ++i) {
    const float lhs = a[i], rhs = b[i];
    if (!finite32(lhs) || !finite32(rhs))
      return numerical(Op::ADD_RESIDUAL, i);
    const float value = lhs + rhs;
    if (!finite32(value)) return numerical(Op::ADD_RESIDUAL, i);
    y[i] = value;
  }
  return ok();
}

Check bias_gelu_row(const float x[1024], const float bias[1024],
                    uint16_t length, float y[1024]) {
  if (x == nullptr || bias == nullptr || y == nullptr ||
      (length != 256 && length != 1024))
    return shape(length == 256 ? Op::BIAS_GELU_ACT : Op::BIAS_GELU_SCORER);
  const Op op = length == 256 ? Op::BIAS_GELU_ACT : Op::BIAS_GELU_SCORER;
  for (unsigned i = 0; i < length; ++i) {
    if (!finite32(x[i]) || !finite32(bias[i])) return numerical(op, i);
    const float biased = x[i] + bias[i];
    if (!finite32(biased)) return numerical(op, i);
    float value = 0.0f;
    Check c = gelu_scalar(biased, value);
    if (!c) return numerical(op, i);
    y[i] = value;
  }
  return ok();
}

} // namespace laya::full
