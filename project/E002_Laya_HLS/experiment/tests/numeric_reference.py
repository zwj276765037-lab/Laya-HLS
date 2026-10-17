"""Independent P1 Q8-F R0 oracle; this module never imports DUT code."""

from __future__ import annotations

import math
import struct

import numpy as np


F32 = np.float32
EPS = np.frombuffer(struct.pack("<I", 0x3727C5AC), dtype="<f4")[0]


def bits(x: np.float32) -> int:
    return struct.unpack("<I", struct.pack("<f", float(x)))[0]


def float_bits_array(data: bytes) -> np.ndarray:
    return np.frombuffer(data, dtype="<u4")


def adjacent_sum(row: np.ndarray) -> np.float32:
    tree = np.asarray(row, dtype="<f4").copy()
    if tree.size != 1024:
        raise ValueError("LN tree width")
    while tree.size > 1:
        tree = np.add(tree[0::2], tree[1::2], dtype=np.float32)
        if not np.isfinite(tree).all():
            raise ArithmeticError("nonfinite LN tree")
    return F32(tree[0])


def layernorm(rows: np.ndarray, gamma: np.ndarray | None = None) -> tuple[bytes, bytes]:
    x = np.asarray(rows, dtype="<f4")
    if x.ndim != 2 or x.shape[1] != 1024 or not np.isfinite(x).all():
        raise ValueError("LN input")
    if gamma is not None:
        gamma = np.asarray(gamma, dtype="<f4")
        if gamma.shape != (1024,) or not np.isfinite(gamma).all():
            raise ValueError("gamma")
    y = np.empty_like(x)
    stats = np.empty((x.shape[0], 3), dtype="<f4")
    for r in range(x.shape[0]):
        mean = np.divide(adjacent_sum(x[r]), F32(1024), dtype=np.float32)
        delta = np.subtract(x[r], mean, dtype=np.float32)
        square = np.multiply(delta, delta, dtype=np.float32)
        var = np.divide(adjacent_sum(square), F32(1024), dtype=np.float32)
        shifted = np.add(var, EPS, dtype=np.float32)
        root = np.sqrt(shifted, dtype=np.float32)
        inverse = np.divide(F32(1), root, dtype=np.float32)
        norm = np.multiply(delta, inverse, dtype=np.float32)
        y[r] = norm if gamma is None else np.multiply(norm, gamma, dtype=np.float32)
        stats[r] = (mean, var, inverse)
        if not np.isfinite(stats[r]).all() or not np.isfinite(y[r]).all() or var < 0:
            raise ArithmeticError("nonfinite LN intermediate")
    return y.tobytes(order="C"), stats.tobytes(order="C")


def round_away_from_zero(value: np.float32) -> int:
    # The input is already an IEEE F32 product. Python float represents that
    # value exactly; the integer rule here is independent of C roundf.
    exact = float(value)
    magnitude = math.floor(abs(exact) + 0.5)
    return -magnitude if math.copysign(1.0, exact) < 0 else magnitude


def quantize(rows: np.ndarray) -> tuple[bytes, list[tuple[float, float, float]]]:
    x = np.asarray(rows, dtype="<f4")
    if x.ndim != 2 or x.shape[0] < 1 or x.shape[0] > 16 or x.shape[1] not in (256, 1024, 2624, 4096):
        raise ValueError("quant shape")
    if not np.isfinite(x).all():
        raise ArithmeticError("nonfinite quant input")
    encoded = bytearray()
    diagnostics: list[tuple[float, float, float]] = []
    for r in range(x.shape[0]):
        for g in range(x.shape[1] // 32):
            group = x[r, g * 32 : (g + 1) * 32]
            amax = F32(np.max(np.abs(group)))
            d_full = np.divide(amax, F32(127), dtype=np.float32)
            inverse = F32(0) if d_full == 0 else np.divide(F32(1), d_full, dtype=np.float32)
            if not np.isfinite(inverse):
                raise ArithmeticError("nonfinite reciprocal")
            try:
                scale = struct.pack("<e", float(d_full))
            except OverflowError as exc:
                raise ArithmeticError("FP16 scale overflow") from exc
            qbytes = bytearray()
            for value in group:
                product = F32(0) if d_full == 0 else np.multiply(value, inverse, dtype=np.float32)
                if not np.isfinite(product):
                    raise ArithmeticError("nonfinite quant product")
                q = round_away_from_zero(product)
                if q < -127 or q > 127:
                    raise ArithmeticError("S8 quant range")
                qbytes.append(q & 0xFF)
            encoded += scale + qbytes
            diagnostics.append((float(amax), float(d_full), float(inverse)))
    return bytes(encoded), diagnostics


def linear(qbytes: bytes, weight_bytes: bytes, rows: int, K: int, cols: int,
           bias: np.ndarray | None = None) -> tuple[bytes, bytes]:
    groups = K // 32
    if len(qbytes) != rows * groups * 34 or len(weight_bytes) != cols * groups * 34:
        raise ValueError("Q8 block lengths")
    if bias is not None and len(bias) != cols:
        raise ValueError("bias shape")
    aq = np.empty((rows, groups, 32), dtype=np.int8)
    wa = np.empty((cols, groups, 32), dtype=np.int8)
    ascale = np.empty((rows, groups), dtype="<f4")
    wscale = np.empty((cols, groups), dtype="<f4")
    for r in range(rows):
        for g in range(groups):
            block = qbytes[(r * groups + g) * 34 : (r * groups + g + 1) * 34]
            ascale[r, g] = F32(struct.unpack("<e", block[:2])[0])
            aq[r, g] = np.frombuffer(block[2:], dtype=np.int8)
    for col in range(cols):
        for g in range(groups):
            block = weight_bytes[(col * groups + g) * 34 : (col * groups + g + 1) * 34]
            wscale[col, g] = F32(struct.unpack("<e", block[:2])[0])
            wa[col, g] = np.frombuffer(block[2:], dtype=np.int8)
    outputs = np.empty((rows, cols), dtype="<f4")
    trace = bytearray()
    for r in range(rows):
        for col in range(cols):
            acc = F32(0)
            for g in range(groups):
                # Integer work is a NumPy int32 vector reduction, independent
                # of the C++ scalar loop and with a proved 32-term I32 bound.
                products = np.multiply(aq[r, g].astype(np.int32),
                                       wa[col, g].astype(np.int32), dtype=np.int32)
                dot = int(np.sum(products, dtype=np.int32))
                sa, sw = ascale[r, g], wscale[col, g]
                if not np.isfinite(sa) or not np.isfinite(sw) or sa < 0 or sw < 0:
                    raise ArithmeticError("scale domain")
                product = np.multiply(sa, sw, dtype=np.float32)
                term = np.multiply(product, F32(dot), dtype=np.float32)
                acc = np.add(acc, term, dtype=np.float32)
                if not np.isfinite(acc) or not np.isfinite(term):
                    raise ArithmeticError("restore/partial nonfinite")
                trace += struct.pack("<iII", dot, bits(term), bits(acc))
            if bias is not None:
                acc = np.add(acc, F32(bias[col]), dtype=np.float32)
            if not np.isfinite(acc):
                raise ArithmeticError("bias nonfinite")
            outputs[r, col] = acc
    return outputs.tobytes(order="C"), bytes(trace)


def half_boundary_selftest() -> None:
    cases = (
        (1.0, 0x3C00),
        (1.00048828125, 0x3C00),
        (1.00146484375, 0x3C02),
        (2.0 ** -24, 0x0001),
        (2.0 ** -25, 0x0000),
        (3.0 * 2.0 ** -25, 0x0002),
    )
    for value, expected in cases:
        actual = struct.unpack("<H", struct.pack("<e", value))[0]
        if actual != expected:
            raise AssertionError(f"Python IEEE half selftest {value}: {actual:#x}")
    try:
        struct.pack("<e", 65520.0)
    except OverflowError:
        return
    raise AssertionError("Python IEEE half overflow selftest")
