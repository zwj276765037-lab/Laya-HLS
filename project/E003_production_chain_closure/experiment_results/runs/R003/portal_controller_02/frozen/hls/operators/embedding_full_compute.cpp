#include "laya_full_numeric.h"

namespace laya::full {
namespace {
bool finite32(float x) {
  return (numeric_f32_bits(x) & 0x7f800000u) != 0x7f800000u;
}
Check numerical(unsigned element) {
  return {Status::E_NUMERICAL, detail(7, uint8_t(Op::EMB_TOKEN), 15), element};
}
} // namespace

Check embedding_row(const uint8_t raw[1088], float y[1024]) {
  if (raw == nullptr || y == nullptr)
    return {Status::E_SHAPE, detail(7, uint8_t(Op::EMB_TOKEN), 5)};

  for (unsigned group = 0; group < 32; ++group) {
    const unsigned offset = group * 34;
    const uint16_t scale_bits = uint16_t(raw[offset]) |
                                (uint16_t(raw[offset + 1]) << 8);
    const float scale = numeric_half_to_f32(scale_bits);
    if (!finite32(scale) || scale < 0.0f) return numerical(group * 32);
    for (unsigned lane = 0; lane < 32; ++lane) {
      const unsigned element = group * 32 + lane;
      const unsigned byte = raw[offset + 2 + lane];
      const int q = byte < 128 ? int(byte) : int(byte) - 256;
      if (q < -127 || q > 127) return numerical(element);
      const float value = float(q) * scale;
      if (!finite32(value)) return numerical(element);
      y[element] = value;
    }
  }
  return ok();
}

} // namespace laya::full
