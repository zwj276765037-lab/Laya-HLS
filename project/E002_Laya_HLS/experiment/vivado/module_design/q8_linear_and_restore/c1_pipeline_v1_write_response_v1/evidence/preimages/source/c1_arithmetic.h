#pragma once

#include "ap_int.h"
#include <cmath>
#include <cstdint>
#include <cstring>

// Source-only C1 candidate. Each operation and bypass has an explicit bit
// contract; the requested pipeline latency still needs wrapper measurements.
namespace c1 {

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
inline uint32_t abs_bits(uint32_t raw) { return raw & 0x7fffffffu; }
inline bool finite_bits(uint32_t raw) { return (raw & 0x7f800000u) != 0x7f800000u; }
inline bool zero_bits(uint32_t raw) { return abs_bits(raw) == 0; }
inline bool subnormal_bits(uint32_t raw) {
  return (raw & 0x7f800000u) == 0 && (raw & 0x007fffffu) != 0;
}
inline bool nonnegative_finite_bits(uint32_t raw) {
  return finite_bits(raw) && (!(raw & 0x80000000u) || zero_bits(raw));
}

inline unsigned msb_index23(uint32_t fraction) {
  unsigned index = 0;
  for (unsigned bit = 0; bit < 23; ++bit)
    if (fraction & (uint32_t(1) << bit)) index = bit;
  return index;
}
inline int floor_binary_exponent(uint32_t raw) {
  const unsigned exponent = (raw >> 23) & 255u;
  return exponent ? int(exponent) - 127 : int(msb_index23(raw & 0x7fffffu)) - 149;
}

// Exact subnormal-grid division for finite amax <= 0x03fe0000.
inline uint32_t tiny_div127_bits(uint32_t amax) {
  const unsigned exponent = (amax >> 23) & 255u;
  const uint32_t fraction = amax & 0x7fffffu;
  const uint32_t units = exponent ? ((0x800000u | fraction) << (exponent - 1u)) : fraction;
  const uint32_t quotient = units / 127u;
  const uint32_t remainder = units % 127u;
  return quotient + uint32_t(remainder >= 64u);
}
inline uint32_t subnormal_up24(uint32_t raw) {
  const uint32_t fraction = raw & 0x7fffffu;
  const unsigned highest = msb_index23(fraction);
  const uint32_t normalized = (fraction << (23u - highest)) & 0x7fffffu;
  return (raw & 0x80000000u) | ((highest + 2u) << 23) | normalized;
}
inline uint32_t normal_down24(uint32_t raw) {
  return (raw & 0x807fffffu) | ((((raw >> 23) & 255u) - 24u) << 23);
}
inline uint32_t positive_normal_up24_or_inf(uint32_t raw) {
  const unsigned exponent = ((raw >> 23) & 255u) + 24u;
  return exponent >= 255u ? 0x7f800000u : ((exponent << 23) | (raw & 0x7fffffu));
}

inline uint32_t div127_bits(uint32_t amax) {
  if (amax <= 0x03fe0000u) return tiny_div127_bits(amax);
  return bits(f32(amax) / 127.0f);
}
inline uint32_t reciprocal_bits(uint32_t d_raw) {
  if (zero_bits(d_raw)) return 0;
  if (subnormal_bits(d_raw)) {
    const uint32_t normalized = subnormal_up24(d_raw);
    const uint32_t quotient = bits(1.0f / f32(normalized));
    return positive_normal_up24_or_inf(quotient);
  }
  return bits(1.0f / f32(d_raw));
}

inline uint16_t f32_to_half_rne_bits(uint32_t raw) {
  const uint16_t sign = uint16_t((raw >> 16) & 0x8000u);
  const unsigned exponent = (raw >> 23) & 255u;
  uint32_t mantissa = raw & 0x7fffffu;
  if (exponent == 255u) return uint16_t(sign | (mantissa ? 0x7e00u : 0x7c00u));
  const int half_exponent = int(exponent) - 112;
  if (half_exponent >= 31) return uint16_t(sign | 0x7c00u);
  if (half_exponent <= -11) return sign;
  if (half_exponent <= 0) {
    mantissa |= 0x800000u;
    const unsigned shift = unsigned(14 - half_exponent);
    uint32_t result = mantissa >> shift;
    const uint32_t remainder = mantissa & ((uint32_t(1) << shift) - 1u);
    const uint32_t halfway = uint32_t(1) << (shift - 1);
    if (remainder > halfway || (remainder == halfway && (result & 1u))) ++result;
    return uint16_t(sign | result);
  }
  uint32_t result = (uint32_t(half_exponent) << 10) | (mantissa >> 13);
  const uint32_t remainder = mantissa & 0x1fffu;
  if (remainder > 0x1000u || (remainder == 0x1000u && (result & 1u))) ++result;
  return uint16_t(sign | result);
}
inline uint32_t half_to_f32_bits(uint16_t h) {
  const uint32_t sign = uint32_t(h & 0x8000u) << 16;
  const unsigned exponent = (h >> 10) & 31u;
  uint32_t mantissa = h & 1023u;
  if (exponent == 0) {
    if (mantissa == 0) return sign;
    int e = -14;
    while ((mantissa & 0x400u) == 0) { mantissa <<= 1; --e; }
    return sign | (uint32_t(e + 127) << 23) | ((mantissa & 1023u) << 13);
  }
  if (exponent == 31) return sign | 0x7f800000u | (mantissa << 13);
  return sign | ((exponent + 112u) << 23) | (mantissa << 13);
}

enum QuantRoute : uint8_t { D_ZERO = 0, PROVEN_ZERO = 1, NORMAL = 2, SCALED = 3 };
inline QuantRoute quant_route(uint32_t x, uint32_t reciprocal, bool d_zero) {
  if (d_zero) return D_ZERO;
  if (zero_bits(x) || floor_binary_exponent(x) + floor_binary_exponent(reciprocal) <= -4)
    return PROVEN_ZERO;
  return subnormal_bits(x) ? SCALED : NORMAL;
}

struct QuantGroup {
  ap_uint<256> packed;
  uint16_t scale_half;
  uint8_t first_bad;
  uint32_t amax_raw, d_raw, reciprocal_raw;
  QuantRoute route[32];
  bool valid;
};

struct QuantToken {
  uint64_t generation;
  uint8_t row;
  uint8_t group;
  uint32_t raw[32];
  QuantGroup result;
};

inline QuantGroup quant_group(const uint32_t raw[32]) {
#pragma HLS INLINE off
  QuantGroup out = {};
  out.first_bad = 32;
  uint32_t amax = 0;
  for (unsigned i = 0; i < 32; ++i) {
#pragma HLS UNROLL
    if (!finite_bits(raw[i])) {
      if (i < out.first_bad) out.first_bad = uint8_t(i);
    } else if (abs_bits(raw[i]) > amax) amax = abs_bits(raw[i]);
  }
  out.amax_raw = amax;
  if (out.first_bad != 32) return out;
  out.d_raw = div127_bits(amax);
  out.reciprocal_raw = reciprocal_bits(out.d_raw);
  out.scale_half = f32_to_half_rne_bits(out.d_raw);
  if (!finite_bits(out.d_raw) || !finite_bits(out.reciprocal_raw) ||
      (out.scale_half & 0x7c00u) == 0x7c00u) {
    out.first_bad = 0;
    return out;
  }
  uint8_t q[32] = {};
#pragma HLS ARRAY_PARTITION variable=q complete
  const bool d_zero = zero_bits(out.d_raw);
  for (unsigned batch = 0; batch < 4; ++batch) {
    uint8_t batch_bad = 32;
    for (unsigned lane = 0; lane < 8; ++lane) {
#pragma HLS UNROLL
      const unsigned i = batch * 8 + lane;
      const QuantRoute route = quant_route(raw[i], out.reciprocal_raw, d_zero);
      out.route[i] = route;
      uint32_t product_raw = 0;
      if (route == NORMAL) product_raw = bits(f32(raw[i]) * f32(out.reciprocal_raw));
      if (route == SCALED)
        product_raw = bits(f32(subnormal_up24(raw[i])) *
                           f32(normal_down24(out.reciprocal_raw)));
      const float rounded = route <= PROVEN_ZERO ? 0.0f : ::roundf(f32(product_raw));
      if (!finite_bits(product_raw) || !finite_bits(bits(rounded)) ||
          rounded < -127.0f || rounded > 127.0f) {
        if (i < batch_bad) batch_bad = uint8_t(i);
      } else q[i] = uint8_t(int8_t(rounded));
    }
    if (batch_bad < 32) {
      out.first_bad = batch_bad;
      return out;
    }
  }
  out.packed = 0;
  for (unsigned i = 0; i < 32; ++i)
    out.packed.range(8 * i + 7, 8 * i) = q[i];
  out.valid = true;
  return out;
}

// Five fixed adder levels. Call from 32 independently unrolled restore lanes;
// the source binds each signed 8x8 product to DSP, subject to generated review.
inline int32_t dot32(ap_uint<256> a, ap_uint<256> w) {
#pragma HLS INLINE
#pragma HLS LATENCY min=7 max=7
  ap_int<16> p[32];
  ap_int<17> s1[16]; ap_int<18> s2[8]; ap_int<19> s3[4];
  ap_int<20> s4[2]; ap_int<21> s5;
#pragma HLS ARRAY_PARTITION variable=p complete
#pragma HLS ARRAY_PARTITION variable=s1 complete
#pragma HLS ARRAY_PARTITION variable=s2 complete
#pragma HLS ARRAY_PARTITION variable=s3 complete
#pragma HLS ARRAY_PARTITION variable=s4 complete
  for (unsigned k = 0; k < 32; ++k) {
#pragma HLS UNROLL
    const ap_int<8> av = a.range(8 * k + 7, 8 * k);
    const ap_int<8> wv = w.range(8 * k + 7, 8 * k);
    ap_int<16> product = av * wv;
#pragma HLS BIND_OP variable=product op=mul impl=dsp latency=1
    p[k] = product;
  }
  for (unsigned k = 0; k < 16; ++k) {
#pragma HLS UNROLL
    s1[k] = ap_int<17>(p[2*k]) + ap_int<17>(p[2*k+1]);
  }
  for (unsigned k = 0; k < 8; ++k) {
#pragma HLS UNROLL
    s2[k] = ap_int<18>(s1[2*k]) + ap_int<18>(s1[2*k+1]);
  }
  for (unsigned k = 0; k < 4; ++k) {
#pragma HLS UNROLL
    s3[k] = ap_int<19>(s2[2*k]) + ap_int<19>(s2[2*k+1]);
  }
  for (unsigned k = 0; k < 2; ++k) {
#pragma HLS UNROLL
    s4[k] = ap_int<20>(s3[2*k]) + ap_int<20>(s3[2*k+1]);
  }
  s5 = ap_int<21>(s4[0]) + ap_int<21>(s4[1]);
  return int32_t(s5);
}

struct RestoreLane {
  uint32_t dot_raw, sa_raw, sw_raw, product_raw, term_raw, next_raw;
  uint8_t phase;  // 0 scale, 1 product, 2 term, 3 next, 4 success
};
inline RestoreLane restore_lane(int32_t dot, uint32_t sa_raw, uint32_t sw_raw,
                               uint32_t old_raw, bool g0) {
#pragma HLS INLINE off
  RestoreLane out = {};
  out.dot_raw = uint32_t(dot); out.sa_raw = sa_raw; out.sw_raw = sw_raw;
  const float product = f32(sa_raw) * f32(sw_raw);
  out.product_raw = bits(product);
  const float term = float(dot) * product;
  out.term_raw = bits(term);
  const float old = g0 ? 0.0f : f32(old_raw);
  const float next = old + term;  // g0 still performs the real FP add.
  out.next_raw = bits(next);
  out.phase = !nonnegative_finite_bits(sa_raw) || !nonnegative_finite_bits(sw_raw) ? 0 :
              !finite_bits(out.product_raw) ? 1 :
              !finite_bits(out.term_raw) ? 2 :
              !finite_bits(out.next_raw) ? 3 : 4;
  return out;
}

struct BiasValue { uint32_t raw; bool finite, invariant_ok; uint8_t route; };
inline BiasValue final_bias(uint32_t ps_raw, uint32_t bias_raw, bool enabled) {
  BiasValue out = {ps_raw, finite_bits(bias_raw), true, 0};
  if (!out.finite || !enabled) return out;
  if (ps_raw == 0x80000000u) { out.invariant_ok = false; out.route = 3; return out; }
  if (ps_raw == 0) {
    out.route = 0;
    out.raw = zero_bits(bias_raw) ? 0 : bias_raw;
  } else if (abs_bits(bias_raw) < 0x00800000u) {
    out.route = 1;
  } else {
    out.route = 2;
    out.raw = bits(f32(ps_raw) + f32(bias_raw));
  }
  out.finite = out.finite && finite_bits(out.raw);
  return out;
}

}  // namespace c1
