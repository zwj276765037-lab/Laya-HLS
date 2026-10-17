#pragma once

#include <cstdint>
#include <cstring>

// The live stage path uses only these finite bit predicates/conversions.
// Functional whole-vector evaluation stays in the archived reference source.
namespace c1_stage {
inline uint32_t bits(float value) {
  uint32_t raw;
  std::memcpy(&raw, &value, sizeof(raw));
  return raw;
}
inline float f32(uint32_t raw) {
  float value;
  std::memcpy(&value, &raw, sizeof(value));
  return value;
}
inline bool finite(uint32_t raw) {
  return (raw & 0x7f800000u) != 0x7f800000u;
}
inline bool nonnegative_finite(uint32_t raw) {
  return finite(raw) && ((raw & 0x80000000u) == 0 ||
                         (raw & 0x7fffffffu) == 0);
}
inline uint32_t half_to_f32_bits(uint16_t half) {
  const uint32_t sign = uint32_t(half & 0x8000u) << 16;
  const uint32_t exponent = (half >> 10) & 31u;
  uint32_t mantissa = half & 1023u;
  if (exponent == 0) {
    if (!mantissa) return sign;
    int e = -14;
    while ((mantissa & 0x400u) == 0) {
      mantissa <<= 1;
      --e;
    }
    return sign | (uint32_t(e + 127) << 23) | ((mantissa & 1023u) << 13);
  }
  if (exponent == 31) return sign | 0x7f800000u | (mantissa << 13);
  return sign | ((exponent + 112u) << 23) | (mantissa << 13);
}
}  // namespace c1_stage
