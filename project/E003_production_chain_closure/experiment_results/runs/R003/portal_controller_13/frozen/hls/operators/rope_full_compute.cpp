#include "laya_full_numeric.h"

namespace laya::full {
namespace {
bool finite32(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
Check numerical(unsigned element) {
  return {Status::E_NUMERICAL, detail(7, uint8_t(Op::ROPE), 15), element};
}
} // namespace

Check rope_head(const float x[64], const float cosine[64],
                const float sine[64], float y[64]) {
  if (x == nullptr || cosine == nullptr || sine == nullptr || y == nullptr)
    return {Status::E_SHAPE, detail(7, uint8_t(Op::ROPE), 5)};

  // Preserve both halves before writing so the documented y == x use works.
  float saved[64];
  for (unsigned i = 0; i < 64; ++i) {
    saved[i] = x[i];
    if (!finite32(saved[i]) || !finite32(cosine[i]) || !finite32(sine[i]))
      return numerical(i);
  }
  for (unsigned i = 0; i < 32; ++i) {
    const float a = saved[i] * cosine[i];
    if (!finite32(a)) return numerical(i);
    const float b = saved[i + 32] * sine[i];
    if (!finite32(b)) return numerical(i);
    const float lower = a - b;
    if (!finite32(lower)) return numerical(i);
    const float c = saved[i + 32] * cosine[i + 32];
    if (!finite32(c)) return numerical(i + 32);
    const float d = saved[i] * sine[i + 32];
    if (!finite32(d)) return numerical(i + 32);
    const float upper = c + d;
    if (!finite32(upper)) return numerical(i + 32);
    y[i] = lower;
    y[i + 32] = upper;
  }
  return ok();
}

} // namespace laya::full
