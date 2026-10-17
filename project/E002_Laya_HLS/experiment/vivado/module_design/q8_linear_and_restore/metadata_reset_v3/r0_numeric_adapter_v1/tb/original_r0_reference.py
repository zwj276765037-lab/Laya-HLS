#!/usr/bin/env python3
"""Independent exact-rational model of the current R0 binary32 quantization rule.

No adapter helper, hardware output, host float arithmetic, or C++ repair code is
used as an oracle. This source is for a separately released finite CPU run.
"""

from __future__ import annotations

from fractions import Fraction


F32_EXP_MASK = 0x7F800000
F32_FRAC_MASK = 0x007FFFFF
F32_ABS_MASK = 0x7FFFFFFF


def is_finite(bits: int) -> bool:
    return bits & F32_EXP_MASK != F32_EXP_MASK


def signed_rational(bits: int) -> Fraction:
    if not is_finite(bits):
        raise ValueError(f"nonfinite binary32 encoding {bits:08x}")
    exponent = (bits >> 23) & 0xFF
    fraction = bits & F32_FRAC_MASK
    if exponent == 0:
        significand, shift = fraction, -149
    else:
        significand, shift = 0x800000 | fraction, exponent - 150
    if shift >= 0:
        value = Fraction(significand << shift)
    else:
        value = Fraction(significand, 1 << -shift)
    return -value if bits >> 31 else value


def _at_least_power_of_two(value: Fraction, exponent: int) -> bool:
    numerator, denominator = value.numerator, value.denominator
    if exponent >= 0:
        return numerator >= denominator << exponent
    return numerator << -exponent >= denominator


def _round_scaled_even(value: Fraction, shift: int) -> int:
    numerator, denominator = value.numerator, value.denominator
    if shift >= 0:
        numerator <<= shift
    else:
        denominator <<= -shift
    quotient, remainder = divmod(numerator, denominator)
    if 2 * remainder > denominator or (2 * remainder == denominator and quotient & 1):
        quotient += 1
    return quotient


def round_rational_to_binary(value: Fraction, exponent_bits: int, fraction_bits: int,
                             bias: int, negative_zero: bool = False) -> int:
    sign = int(value < 0 or (value == 0 and negative_zero))
    sign_shift = exponent_bits + fraction_bits
    magnitude = abs(value)
    if magnitude == 0:
        return sign << sign_shift
    emin = 1 - bias
    emax = ((1 << exponent_bits) - 2) - bias
    exponent = magnitude.numerator.bit_length() - magnitude.denominator.bit_length()
    if not _at_least_power_of_two(magnitude, exponent):
        exponent -= 1
    if exponent < emin:
        significand = _round_scaled_even(magnitude, fraction_bits - emin)
        if significand == 0:
            return sign << sign_shift
        if significand >= 1 << fraction_bits:
            return (sign << sign_shift) | (1 << fraction_bits)
        return (sign << sign_shift) | significand
    significand = _round_scaled_even(magnitude, fraction_bits - exponent)
    if significand == 1 << (fraction_bits + 1):
        significand >>= 1
        exponent += 1
    if exponent > emax:
        return (sign << sign_shift) | (((1 << exponent_bits) - 1) << fraction_bits)
    return ((sign << sign_shift) | ((exponent + bias) << fraction_bits) |
            (significand - (1 << fraction_bits)))


def f32(value: Fraction, negative_zero: bool = False) -> int:
    return round_rational_to_binary(value, 8, 23, 127, negative_zero)


def half_from_f32_bits(bits: int) -> int:
    if not is_finite(bits):
        return ((bits >> 16) & 0x8000) | (0x7E00 if bits & F32_FRAC_MASK else 0x7C00)
    return round_rational_to_binary(signed_rational(bits), 5, 10, 15,
                                    negative_zero=bool(bits >> 31))


def f32_div_bits(a_bits: int, b_bits: int) -> int:
    a, b = signed_rational(a_bits), signed_rational(b_bits)
    if b == 0:
        raise ZeroDivisionError("reference caller must handle zero denominator")
    return f32(a / b, negative_zero=bool((a_bits ^ b_bits) >> 31))


def f32_mul_bits(a_bits: int, b_bits: int) -> int:
    return f32(signed_rational(a_bits) * signed_rational(b_bits),
               negative_zero=bool((a_bits ^ b_bits) >> 31))


def f32_add_bits(a_bits: int, b_bits: int) -> int:
    # RNE gives +0 on cancellation; -0 only for two -0 operands.
    negative_zero = a_bits == 0x80000000 and b_bits == 0x80000000
    return f32(signed_rational(a_bits) + signed_rational(b_bits), negative_zero)


def _floor_exponent(bits: int) -> int:
    exponent = (bits >> 23) & 0xFF
    fraction = bits & F32_FRAC_MASK
    if exponent == 0:
        if fraction == 0:
            raise ValueError("zero has no floor binary exponent")
        return fraction.bit_length() - 1 - 149
    return exponent - 127


def _lane_route(x_bits: int, reciprocal_bits: int, d_zero: bool) -> str:
    if d_zero:
        return "D_ZERO"
    if x_bits & F32_ABS_MASK == 0:
        return "X_ZERO"
    if _floor_exponent(x_bits) + _floor_exponent(reciprocal_bits) <= -4:
        return "SMALL_Q_ZERO"
    return "SCALED_FP" if (x_bits & F32_EXP_MASK) == 0 else "NORMAL_FP"


def _roundf_away_integer(bits: int) -> int:
    value = signed_rational(bits)
    magnitude = abs(value)
    rounded = (2 * magnitude.numerator + magnitude.denominator) // (2 * magnitude.denominator)
    return -rounded if value < 0 else rounded


def original_r0_group(lanes: list[int], row: int = 0, group: int = 0) -> dict:
    if len(lanes) != 32 or any(not 0 <= bits <= 0xFFFFFFFF for bits in lanes):
        raise ValueError("R0 group requires exactly 32 raw binary32 words")
    base = row * 4096 + group * 32
    first_bad = next((i for i, bits in enumerate(lanes) if not is_finite(bits)), None)
    if first_bad is not None:
        return {"status": 6, "bad_element": base + first_bad, "commit": False,
                "amax_bits": None, "d_bits": None, "reciprocal_bits": None,
                "saved_half": None, "d_zero_reciprocal": None,
                "d_zero_quantization": None, "q": None, "lane_records": []}
    amax_value = max(abs(signed_rational(bits)) for bits in lanes)
    amax_bits = f32(amax_value)
    d_bits = f32(amax_value / 127)
    d_zero = d_bits & F32_ABS_MASK == 0
    reciprocal_bits = 0 if d_zero else f32(Fraction(1) / signed_rational(d_bits))
    saved_half = half_from_f32_bits(d_bits)
    if not is_finite(d_bits) or not is_finite(reciprocal_bits) or saved_half & 0x7C00 == 0x7C00:
        return {"status": 6, "bad_element": base, "commit": False,
                "amax_bits": amax_bits, "d_bits": d_bits,
                "reciprocal_bits": reciprocal_bits, "saved_half": saved_half,
                "d_zero_reciprocal": d_zero, "d_zero_quantization": d_zero,
                "q": None, "lane_records": []}
    q: list[int] = []
    lane_records: list[dict] = []
    first_quant_bad = None
    for index, x_bits in enumerate(lanes):
        route = _lane_route(x_bits, reciprocal_bits, d_zero)
        product_bits = f32_mul_bits(x_bits, reciprocal_bits)
        if not is_finite(product_bits):
            lane_records.append({"index": index, "route": route, "q": None,
                                 "product_bits": product_bits if route in {"SCALED_FP", "NORMAL_FP"} else None,
                                 "rejected": True})
            first_quant_bad = index
            break
        rounded = 0 if d_zero else _roundf_away_integer(product_bits)
        if not -127 <= rounded <= 127:
            lane_records.append({"index": index, "route": route, "q": None,
                                 "product_bits": product_bits if route in {"SCALED_FP", "NORMAL_FP"} else None,
                                 "rejected": True})
            first_quant_bad = index
            break
        q.append(rounded)
        lane_records.append({"index": index, "route": route, "q": rounded,
                             "product_bits": product_bits if route in {"SCALED_FP", "NORMAL_FP"} else None,
                             "rejected": False})
    if first_quant_bad is not None:
        return {"status": 6, "bad_element": base + first_quant_bad, "commit": False,
                "amax_bits": amax_bits, "d_bits": d_bits,
                "reciprocal_bits": reciprocal_bits, "saved_half": saved_half,
                "d_zero_reciprocal": d_zero, "d_zero_quantization": d_zero,
                "q": None, "lane_records": lane_records}
    return {"status": 0, "bad_element": None, "commit": True,
            "amax_bits": amax_bits, "d_bits": d_bits,
            "reciprocal_bits": reciprocal_bits, "saved_half": saved_half,
            "d_zero_reciprocal": d_zero, "d_zero_quantization": d_zero,
            "q": q, "lane_records": lane_records}


def original_r0_bias_add(ps_bits: int, bias_bits: int) -> int:
    if not is_finite(ps_bits) or not is_finite(bias_bits):
        raise ValueError("bias reference expects finite operands")
    return f32_add_bits(ps_bits, bias_bits)


def positive_half_rational(bits: int) -> Fraction:
    """Decode a positive nonzero finite half scale without host floating point."""
    if not 0 < bits < 0x7C00:
        raise ValueError("extreme restore probe requires positive finite half scale")
    exponent, fraction = (bits >> 10) & 0x1F, bits & 0x03FF
    if exponent == 0:
        return Fraction(fraction, 1 << 24)
    significand = 0x400 | fraction
    shift = exponent - 25
    return (Fraction(significand << shift) if shift >= 0
            else Fraction(significand, 1 << -shift))


def original_r0_restore_ps(dot: int, half_a: int, half_b: int, groups: int) -> int:
    """Current Q8 ordered dot/half/product/term/PS operations for one lane."""
    if not -520192 <= dot <= 524288 or dot == 0 or not 1 <= groups <= 128:
        raise ValueError("dot or group count outside successful restore probe domain")
    scale_product = f32(positive_half_rational(half_a) *
                        positive_half_rational(half_b))
    term = f32(Fraction(dot) * signed_rational(scale_product))
    ps = 0x00000000
    for _ in range(groups):
        ps = f32_add_bits(ps, term)
    return ps
