"""Independent P2 F0 leaf oracle.  No DUT imports or captured-output expectations.

The order in each function follows hardware_agent/task.md section 12.2.  A
captured GGML tensor may be supplied as *input* to a function, never as that
function's expected output.  expf/tanhf/logf come directly from system libm;
the surrounding arithmetic and reductions are NumPy/Python implementations.
"""

from __future__ import annotations

import ctypes
import math
import struct
from pathlib import Path

import numpy as np


F32 = np.float32
F32_DTYPE = np.dtype("<f4")
LIBM = ctypes.CDLL("libm.so.6")
for _name in ("expf", "tanhf", "logf"):
    _func = getattr(LIBM, _name)
    _func.argtypes = [ctypes.c_float]
    _func.restype = ctypes.c_float


def f32(x: object) -> np.float32:
    return F32(x)


def add(a: object, b: object) -> np.float32:
    return np.add(a, b, dtype=np.float32)


def sub(a: object, b: object) -> np.float32:
    return np.subtract(a, b, dtype=np.float32)


def mul(a: object, b: object) -> np.float32:
    return np.multiply(a, b, dtype=np.float32)


def div(a: object, b: object) -> np.float32:
    return np.divide(a, b, dtype=np.float32)


def bits(value: object) -> int:
    return struct.unpack("<I", struct.pack("<f", float(value)))[0]


def _array(value: object, shape: tuple[int, ...], name: str) -> np.ndarray:
    out = np.asarray(value, dtype="<f4")
    if out.shape != shape or not np.isfinite(out).all():
        raise ValueError(f"{name}: shape or finite domain")
    return out


def _finite(value: object, name: str) -> None:
    if not np.isfinite(value).all():
        raise ArithmeticError(f"{name}: nonfinite")


def adjacent_sum(values: object) -> np.float32:
    tree = np.asarray(values, dtype="<f4").copy()
    if tree.ndim != 1 or tree.size < 1 or tree.size & (tree.size - 1):
        raise ValueError("adjacent tree requires power-of-two length")
    _finite(tree, "tree input")
    while tree.size > 1:
        tree = np.add(tree[0::2], tree[1::2], dtype=np.float32)
        _finite(tree, "tree stage")
    return F32(tree[0])


def libm_exp(x: object) -> np.float32:
    return F32(LIBM.expf(ctypes.c_float(float(x))))


def libm_tanh(x: object) -> np.float32:
    return F32(LIBM.tanhf(ctypes.c_float(float(x))))


def libm_log(x: object) -> np.float32:
    return F32(LIBM.logf(ctypes.c_float(float(x))))


def embedding_row(raw: bytes) -> np.ndarray:
    if len(raw) != 1088:
        raise ValueError("embedding Q8 row bytes")
    output = np.empty(1024, dtype="<f4")
    for g in range(32):
        block = raw[g * 34 : (g + 1) * 34]
        scale = F32(struct.unpack("<e", block[:2])[0])
        if not np.isfinite(scale) or scale < 0:
            raise ArithmeticError("embedding scale")
        q = np.frombuffer(block[2:], dtype=np.int8)
        if np.any(q < -127):
            raise ArithmeticError("embedding S8 outside Q8-F domain")
        output[g * 32 : (g + 1) * 32] = np.multiply(
            q.astype("<f4"), scale, dtype=np.float32)
    _finite(output, "embedding output")
    return output


def rope_head(x: object, cosine: object, sine: object) -> np.ndarray:
    src = _array(x, (64,), "RoPE input").copy()
    cos = _array(cosine, (64,), "RoPE cos")
    sin = _array(sine, (64,), "RoPE sin")
    y = np.empty(64, dtype="<f4")
    for i in range(32):
        a = mul(src[i], cos[i]); b = mul(src[i + 32], sin[i])
        c = mul(src[i + 32], cos[i + 32]); d = mul(src[i], sin[i + 32])
        _finite(np.asarray((a, b, c, d), dtype="<f4"), "RoPE products")
        y[i] = sub(a, b); y[i + 32] = add(c, d)
    _finite(y, "RoPE output")
    return y


def qk_row(q: object, keys: object, mask: object, S: int,
           query: int, sliding: bool) -> np.ndarray:
    if S not in (64, 128, 256, 512, 1024) or not 0 <= query < S:
        raise ValueError("QK S/query")
    qv = _array(q, (64,), "QK query")
    kv = _array(keys, (S, 64), "QK keys")
    mv = np.asarray(mask, dtype=np.uint8)
    if mv.shape != (S,) or np.any(mv > 1):
        raise ValueError("QK U8 mask")
    products = np.multiply(kv, qv[None, :], dtype=np.float32)
    _finite(products, "QK product")
    tree = products
    while tree.shape[1] > 1:
        tree = np.add(tree[:, 0::2], tree[:, 1::2], dtype=np.float32)
        _finite(tree, "QK tree")
    scaled = np.multiply(tree[:, 0], F32(0.125), dtype=np.float32)
    pad = np.multiply(np.subtract(mv.astype("<f4"), F32(1), dtype=np.float32),
                      F32(10000), dtype=np.float32)
    if sliding:
        idx = np.arange(S)
        local = np.where(np.abs(idx - query) <= 64, F32(0), F32(-10000))
        bias = np.add(local, pad, dtype=np.float32)
    else:
        bias = pad
    score = np.add(scaled, bias, dtype=np.float32)
    _finite(score, "QK score")
    return score


def softmax_row(values: object, length: int) -> np.ndarray:
    if length not in (16, 64, 128, 256, 512, 1024):
        raise ValueError("softmax length")
    x = _array(values, (length,), "softmax input")
    maximum = x[0]
    for val in x[1:]:
        if val > maximum:
            maximum = val
    z = np.subtract(x, maximum, dtype=np.float32)
    _finite(z, "softmax shifted")
    e = np.fromiter((libm_exp(val) for val in z), dtype="<f4", count=length)
    _finite(e, "softmax exp")
    total = adjacent_sum(e)
    if total <= 0:
        raise ArithmeticError("softmax sum")
    p = np.divide(e, total, dtype=np.float32)
    _finite(p, "softmax probability")
    return p


def av_row(p: object, values: object, S: int) -> np.ndarray:
    if S not in (64, 128, 256, 512, 1024):
        raise ValueError("AV S")
    prob = _array(p, (S,), "AV probabilities")
    vv = _array(values, (S, 64), "AV values")
    acc = np.zeros(64, dtype="<f4")
    for k in range(S):
        product = np.multiply(prob[k], vv[k], dtype=np.float32)
        _finite(product, "AV product")
        acc = np.add(acc, product, dtype=np.float32)
        _finite(acc, "AV partial")
    return acc


def fp_scorer_row(x: object, w: object, bias: object) -> np.float32:
    xv = _array(x, (1024,), "scorer input")
    wv = _array(w, (1024,), "scorer weight")
    b = f32(bias); _finite(b, "scorer bias")
    acc = F32(0)
    for k in range(1024):
        product = mul(xv[k], wv[k]); _finite(product, "scorer product")
        acc = add(acc, product); _finite(acc, "scorer partial")
    acc = add(acc, b); _finite(acc, "scorer output")
    return acc


def fp_act_row(x: object, weight_bits: object) -> np.ndarray:
    xv = _array(x, (1028,), "act input")
    wb = np.asarray(weight_bits, dtype="<u2")
    if wb.shape != (256, 1028):
        raise ValueError("act F16 weight shape")
    w = wb.view("<f2").astype("<f4")
    _finite(w, "act F16 weight")
    acc = np.zeros(256, dtype="<f4")
    for k in range(1028):
        product = np.multiply(xv[k], w[:, k], dtype=np.float32)
        _finite(product, "act product")
        acc = np.add(acc, product, dtype=np.float32)
        _finite(acc, "act partial")
    return acc


def gelu_scalar(value: object) -> np.float32:
    x = f32(value); _finite(x, "GELU input")
    c = F32(0.7978845608028654)
    a = F32(0.044715)
    u = mul(a, x); v = mul(u, x); w = add(F32(1), v)
    t = mul(c, x); z = mul(t, w)
    _finite(np.asarray((u, v, w, t, z), dtype="<f4"), "GELU polynomial")
    h = libm_tanh(z); r = add(F32(1), h); s = mul(F32(0.5), x)
    y = mul(s, r)
    _finite(np.asarray((h, r, s, y), dtype="<f4"), "GELU output")
    return y


def geglu_row(wi: object) -> np.ndarray:
    x = _array(wi, (5248,), "GEGLU Wi")
    gelu = np.fromiter((gelu_scalar(v) for v in x[:2624]),
                       dtype="<f4", count=2624)
    out = np.multiply(gelu, x[2624:], dtype=np.float32)
    _finite(out, "GEGLU gate")
    return out


def relu_row(x: object) -> np.ndarray:
    values = _array(x, (4096,), "ReLU")
    return np.where(values > 0, values, F32(0)).astype("<f4")


def add_row(a: object, b: object) -> np.ndarray:
    av = _array(a, (1024,), "add lhs"); bv = _array(b, (1024,), "add rhs")
    out = np.add(av, bv, dtype=np.float32)
    _finite(out, "add output")
    return out


def bias_gelu_row(x: object, bias: object, length: int) -> np.ndarray:
    if length not in (256, 1024):
        raise ValueError("bias/GELU length")
    xv = _array(x, (length,), "bias/GELU input")
    bv = _array(bias, (length,), "bias/GELU bias")
    z = np.add(xv, bv, dtype=np.float32)
    _finite(z, "bias/GELU sum")
    return np.fromiter((gelu_scalar(v) for v in z), dtype="<f4", count=length)


def candidate_mask(logits: object, mask: object) -> np.ndarray:
    x = _array(logits, (16,), "candidate logits")
    mv = np.asarray(mask, dtype=np.uint8)
    if mv.shape != (16,) or np.any(mv > 1):
        raise ValueError("candidate U8 mask")
    complement = np.subtract(F32(1), mv.astype("<f4"), dtype=np.float32)
    bias = np.multiply(complement, F32(-10000), dtype=np.float32)
    result = np.add(x, bias, dtype=np.float32)
    _finite(result, "candidate mask output")
    return result


def candidate_stats(probability: object, valid_options: int) -> np.ndarray:
    p = _array(probability, (16,), "candidate p")
    if not 1 <= valid_options <= 16 or np.any(p < 0) or np.any(p > 1):
        raise ValueError("candidate p/count domain")
    k = max(valid_options, 2)
    terms = np.empty(16, dtype="<f4")
    floor = F32(1e-9)
    for i in range(16):
        log_arg = p[i] if p[i] > floor else floor
        terms[i] = mul(p[i], libm_log(log_arg))
    _finite(terms, "entropy terms")
    # Unary negation preserves IEEE signed zero from the sixteen-term tree.
    entropy = div(np.negative(adjacent_sum(terms), dtype=np.float32),
                  libm_log(F32(k)))
    _finite(entropy, "entropy")
    top1 = p[0]
    for item in p[1:]:
        delta = sub(top1, item)
        relu = delta if delta > 0 else F32(0)
        top1 = add(relu, item)
        _finite(top1, "top1")
    r = np.empty(16, dtype="<f4")
    for i in range(16):
        delta = sub(top1, p[i]); denom = add(delta, F32(1e-6))
        if denom == 0:
            raise ArithmeticError("top2 denominator")
        ratio = div(delta, denom); r[i] = mul(p[i], ratio)
        _finite(np.asarray((delta, denom, ratio, r[i]), dtype="<f4"),
                "top2 terms")
    top2 = r[0]
    for item in r[1:]:
        delta = sub(top2, item)
        relu = delta if delta > 0 else F32(0)
        top2 = add(relu, item)
        _finite(top2, "top2")
    out = np.asarray((top1, sub(top1, top2), entropy,
                      div(F32(k), F32(255))), dtype="<f4")
    _finite(out, "candidate stats")
    return out


def concat_act_row(cls: object, stats: object) -> np.ndarray:
    cv = _array(cls, (1024,), "act CLS")
    sv = _array(stats, (4,), "act stats")
    return np.concatenate((cv, sv)).astype("<f4")


def layernorm_rows(rows: object, gamma: object | None = None) -> tuple[np.ndarray, np.ndarray]:
    """P1 R0 LN recomposed here for complete P2 tiles, without DUT helpers."""
    x = np.asarray(rows, dtype="<f4")
    if x.ndim != 2 or not 1 <= x.shape[0] <= 16 or x.shape[1] != 1024:
        raise ValueError("LayerNorm tile shape")
    _finite(x, "LayerNorm source")
    g = None if gamma is None else _array(gamma, (1024,), "LayerNorm gamma")
    y = np.empty_like(x)
    diagnostics = np.empty((x.shape[0], 3), dtype="<f4")
    eps = np.frombuffer(struct.pack("<I", 0x3727C5AC), dtype="<f4")[0]
    for row in range(x.shape[0]):
        mean = div(adjacent_sum(x[row]), F32(1024))
        delta = np.subtract(x[row], mean, dtype=np.float32)
        squared = np.multiply(delta, delta, dtype=np.float32)
        _finite(delta, "LayerNorm delta"); _finite(squared, "LayerNorm square")
        variance = div(adjacent_sum(squared), F32(1024))
        if variance < 0:
            raise ArithmeticError("LayerNorm negative variance")
        shifted = add(variance, eps)
        root = np.sqrt(shifted, dtype=np.float32)
        inverse = div(F32(1), root)
        _finite(np.asarray((mean, variance, shifted, root, inverse)),
                "LayerNorm statistics")
        normalized = np.multiply(delta, inverse, dtype=np.float32)
        y[row] = normalized if g is None else np.multiply(normalized, g, dtype=np.float32)
        _finite(y[row], "LayerNorm output")
        diagnostics[row] = (mean, variance, inverse)
    return y, diagnostics


Q8_DTYPE = np.dtype([("scale", "<f2"), ("q", "i1", (32,))])


def quantize_rows(rows: object) -> bytes:
    """Group32 q uses FP32 inverse before IEEE FP16 scale storage."""
    x = np.asarray(rows, dtype="<f4")
    if x.ndim != 2 or not 1 <= x.shape[0] <= 16 or x.shape[1] not in (256, 1024, 2624, 4096):
        raise ValueError("Q8 tile shape")
    _finite(x, "Q8 source")
    K = x.shape[1]
    output = bytearray()
    for row in range(x.shape[0]):
        for group in range(K // 32):
            values = x[row, group * 32 : (group + 1) * 32]
            amax = F32(np.max(np.abs(values)))
            d_full = div(amax, F32(127))
            inverse = F32(0) if d_full == 0 else div(F32(1), d_full)
            _finite(np.asarray((amax, d_full, inverse)), "Q8 scale")
            try:
                half = struct.pack("<e", float(d_full))
            except OverflowError as exc:
                raise ArithmeticError("Q8 FP16 scale overflow") from exc
            product = (np.zeros(32, dtype="<f4") if d_full == 0 else
                       np.multiply(values, inverse, dtype=np.float32))
            _finite(product, "Q8 scaled value")
            # Float64 exactly represents every finite F32 product. A half
            # integer is rounded away from zero, matching roundf here.
            magnitude = np.floor(np.abs(product.astype(np.float64)) + 0.5)
            rounded = np.copysign(magnitude, product.astype(np.float64)).astype(np.int32)
            if np.any(rounded < -127) or np.any(rounded > 127):
                raise ArithmeticError("Q8 S8 range")
            output += half + rounded.astype(np.int8).tobytes()
    return bytes(output)


def q8_linear_full(activation: bytes, weights: bytes, rows: int,
                   K: int, N: int, bias: object | None = None,
                   trace: tuple[int, int] | None = None) -> tuple[np.ndarray, list[tuple[int, int, int]]]:
    """Full-N exact R0 matrix oracle with vectorized independent I32 dots.

    Each group produces all row/column dots in NumPy I32. Multiplication,
    restore and accumulation still retire group 0..G-1 with distinct FP32
    roundings. The integer dot is associative because its absolute bound is
    32*128*128, far below signed 32-bit capacity.
    """
    if rows < 1 or K not in (256, 1024, 2624, 4096) or N < 1 or K % 32:
        raise ValueError("Q8 Linear shape")
    G = K // 32
    if len(activation) != rows * G * 34 or len(weights) != N * G * 34:
        raise ValueError("Q8 Linear byte spans")
    aq = np.frombuffer(activation, dtype=Q8_DTYPE).reshape(rows, G)
    wq = np.frombuffer(weights, dtype=Q8_DTYPE).reshape(N, G)
    ascale = aq["scale"].astype("<f4")
    wscale = wq["scale"].astype("<f4")
    if not np.isfinite(ascale).all() or not np.isfinite(wscale).all() or \
       np.any(ascale < 0) or np.any(wscale < 0):
        raise ArithmeticError("Q8 Linear scale domain")
    b = None if bias is None else _array(bias, (N,), "Q8 Linear bias")
    acc = np.zeros((rows, N), dtype="<f4")
    group_trace: list[tuple[int, int, int]] = []
    if trace is not None and not (0 <= trace[0] < rows and 0 <= trace[1] < N):
        raise ValueError("Q8 Linear trace index")
    for group in range(G):
        left = aq["q"][:, group, :].astype(np.int32)
        right = wq["q"][:, group, :].astype(np.int32)
        dots = left @ right.T
        scale_product = np.multiply(ascale[:, group, None],
                                    wscale[None, :, group], dtype=np.float32)
        term = np.multiply(scale_product, dots.astype("<f4"), dtype=np.float32)
        _finite(scale_product, "Q8 scale product")
        _finite(term, "Q8 restore term")
        acc = np.add(acc, term, dtype=np.float32)
        _finite(acc, "Q8 group partial")
        if trace is not None:
            row, col = trace
            group_trace.append((int(dots[row, col]), bits(term[row, col]),
                                bits(acc[row, col])))
    if b is not None:
        acc = np.add(acc, b[None, :], dtype=np.float32)
        _finite(acc, "Q8 bias output")
    return acc, group_trace


def libm_accuracy_audit(samples: list[tuple[str, float]]) -> list[dict]:
    """Measure current libm ULP error against 100-digit mpmath values."""
    import mpmath as mp

    mp.mp.dps = 100
    result = []
    functions = {"expf": (libm_exp, mp.exp),
                 "tanhf": (libm_tanh, mp.tanh),
                 "logf": (libm_log, mp.log)}
    for name, value in samples:
        actual_fn, precise_fn = functions[name]
        x = F32(value)
        actual = actual_fn(x)
        precise = precise_fn(mp.mpf(float(x)))
        reference = F32(str(precise))
        ulp = abs(int(bits(actual)) - int(bits(reference)))
        result.append({"function": name, "input_bits": bits(x),
                       "libm_bits": bits(actual), "nearest_f32_bits": bits(reference),
                       "ulp_diff": ulp, "abs_error": abs(float(actual) - float(precise))})
    return result


# Full-graph array kernels preserve the scalar §12.2 evaluation order while
# batching independent rows/features. Only expf/tanhf/logf are delegated to
# a tiny independent host-libm adapter, never to the DUT's math helpers.
_BATCH_LIBM: dict[str, object] = {}


def configure_batch_libm(library: str | Path) -> None:
    module = ctypes.CDLL(str(library))
    pointer = ctypes.POINTER(ctypes.c_float)
    for name in ("expf", "tanhf", "logf"):
        function = getattr(module, "full_ref_" + name)
        function.argtypes = [pointer, pointer, ctypes.c_size_t]
        function.restype = None
        _BATCH_LIBM[name] = function


def libm_array(name: str, values: object) -> np.ndarray:
    source = np.ascontiguousarray(values, dtype="<f4")
    output = np.empty_like(source)
    function = _BATCH_LIBM.get(name)
    if function is None:
        scalar = {"expf": libm_exp, "tanhf": libm_tanh,
                  "logf": libm_log}[name]
        output.flat[:] = np.fromiter((scalar(x) for x in source.flat),
                                     dtype="<f4", count=source.size)
    else:
        pointer = ctypes.POINTER(ctypes.c_float)
        function(source.ctypes.data_as(pointer),
                 output.ctypes.data_as(pointer), source.size)
    _finite(output, "libm " + name)
    return output


def gelu_array(values: object) -> np.ndarray:
    x = np.asarray(values, dtype="<f4")
    _finite(x, "GELU array input")
    a, c = F32(0.044715), F32(0.7978845608028654)
    u = mul(a, x)
    v = mul(u, x)
    w = add(F32(1), v)
    t = mul(c, x)
    z = mul(t, w)
    _finite(u, "GELU u"); _finite(v, "GELU v")
    _finite(w, "GELU w"); _finite(t, "GELU t")
    _finite(z, "GELU z")
    h = libm_array("tanhf", z)
    r = add(F32(1), h)
    s = mul(F32(0.5), x)
    y = mul(s, r)
    _finite(y, "GELU array output")
    return y


def softmax_many(values: object) -> np.ndarray:
    x = np.asarray(values, dtype="<f4")
    if x.ndim != 2 or x.shape[1] not in (16, 64, 128, 256, 512, 1024):
        raise ValueError("softmax rows/length")
    _finite(x, "softmax array input")
    maximum = x[:, 0].copy()
    for index in range(1, x.shape[1]):
        maximum = np.where(x[:, index] > maximum, x[:, index], maximum)
    shifted = sub(x, maximum[:, None])
    _finite(shifted, "softmax array shifted")
    exponential = libm_array("expf", shifted)
    tree = exponential
    while tree.shape[1] > 1:
        tree = add(tree[:, 0::2], tree[:, 1::2])
        _finite(tree, "softmax array tree")
    total = tree[:, 0]
    if np.any(total <= 0):
        raise ArithmeticError("softmax array sum")
    probability = div(exponential, total[:, None])
    _finite(probability, "softmax array probability")
    return probability


def layernorm_many(values: object, gamma: object | None = None) -> np.ndarray:
    x = np.asarray(values, dtype="<f4")
    if x.ndim != 2 or x.shape[1] != 1024:
        raise ValueError("LayerNorm sequence shape")
    result = np.empty_like(x)
    for row0 in range(0, x.shape[0], 16):
        tile = x[row0 : row0 + 16]
        result[row0 : row0 + len(tile)] = layernorm_rows(tile, gamma)[0]
    return result


def quantize_many(values: object) -> bytes:
    x = np.asarray(values, dtype="<f4")
    if x.ndim != 2 or x.shape[1] not in (256, 1024, 2624, 4096):
        raise ValueError("Q8 sequence shape")
    _finite(x, "Q8 sequence input")
    rows, K = x.shape
    groups = x.reshape(rows, K // 32, 32)
    amax = np.max(np.abs(groups), axis=2).astype("<f4")
    scale = div(amax, F32(127))
    inverse = np.zeros_like(scale)
    nonzero = scale != 0
    inverse[nonzero] = div(F32(1), scale[nonzero])
    _finite(scale, "Q8 sequence scale")
    _finite(inverse, "Q8 sequence inverse")
    half = scale.astype("<f2")
    _finite(half, "Q8 sequence half scale")
    product = mul(groups, inverse[:, :, None])
    _finite(product, "Q8 sequence product")
    magnitude = np.floor(np.abs(product.astype(np.float64)) + 0.5)
    rounded = np.copysign(magnitude, product.astype(np.float64)).astype(np.int32)
    if np.any(rounded < -127) or np.any(rounded > 127):
        raise ArithmeticError("Q8 sequence S8 range")
    packed = np.empty((rows, K // 32), dtype=Q8_DTYPE)
    packed["scale"] = half
    packed["q"] = rounded.astype(np.int8)
    return packed.tobytes()


def q8_linear_many(values: object, weights: bytes, N: int,
                   bias: object | None = None) -> np.ndarray:
    x = np.asarray(values, dtype="<f4")
    if x.ndim != 2:
        raise ValueError("Q8 Linear sequence rows")
    rows, K = x.shape
    packed = quantize_many(x)
    bytes_per_row = K // 32 * 34
    output = np.empty((rows, N), dtype="<f4")
    for row0 in range(0, rows, 16):
        count = min(16, rows - row0)
        tile = packed[row0 * bytes_per_row : (row0 + count) * bytes_per_row]
        output[row0 : row0 + count] = q8_linear_full(
            tile, weights, count, K, N, bias)[0]
    return output


def fp_scorer_many(values: object, weight: object, bias: object) -> np.ndarray:
    x = np.asarray(values, dtype="<f4")
    w = _array(weight, (1024,), "scorer weight")
    if x.ndim != 2 or x.shape[1] != 1024:
        raise ValueError("scorer rows")
    acc = np.zeros(x.shape[0], dtype="<f4")
    for k in range(1024):
        acc = add(acc, mul(x[:, k], w[k]))
        _finite(acc, "scorer accumulator")
    result = add(acc, F32(bias))
    _finite(result, "scorer output")
    return result


def fp_act_many(values: object, weight_bits: object) -> np.ndarray:
    x = np.asarray(values, dtype="<f4")
    wb = np.asarray(weight_bits, dtype="<u2")
    if x.ndim != 2 or x.shape[1] != 1028 or wb.shape != (256, 1028):
        raise ValueError("act FC1 rows/weight")
    weight = wb.view("<f2").astype("<f4")
    _finite(weight, "act F16 weight")
    acc = np.zeros((x.shape[0], 256), dtype="<f4")
    for k in range(1028):
        acc = add(acc, mul(x[:, k, None], weight[None, :, k]))
        _finite(acc, "act FC1 accumulator")
    return acc


def rope_qkv_many(qkv: object, cosine: object, sine: object) -> np.ndarray:
    data = np.asarray(qkv, dtype="<f4")
    cos = np.asarray(cosine, dtype="<f4")
    sin = np.asarray(sine, dtype="<f4")
    if (data.ndim != 3 or data.shape[2] != 3072 or
            cos.shape != (data.shape[1], 64) or
            sin.shape != (data.shape[1], 64)):
        raise ValueError("RoPE sequence shapes")
    _finite(data, "RoPE QKV input")
    _finite(cos, "RoPE cosine")
    _finite(sin, "RoPE sine")
    result = data.copy()
    for plane in (0, 1):
        heads = data[:, :, plane * 1024 : (plane + 1) * 1024].reshape(
            data.shape[0], data.shape[1], 16, 64)
        target = result[:, :, plane * 1024 : (plane + 1) * 1024].reshape(
            data.shape[0], data.shape[1], 16, 64)
        a = mul(heads[..., :32], cos[None, :, None, :32])
        b = mul(heads[..., 32:], sin[None, :, None, :32])
        c = mul(heads[..., 32:], cos[None, :, None, 32:])
        d = mul(heads[..., :32], sin[None, :, None, 32:])
        for step in (a, b, c, d): _finite(step, "RoPE sequence product")
        target[..., :32] = sub(a, b)
        target[..., 32:] = add(c, d)
        _finite(target, "RoPE sequence output")
    return result


def attention_many(qkv: object, attention_mask: object,
                   sliding: bool) -> np.ndarray:
    data = np.asarray(qkv, dtype="<f4")
    mask = np.asarray(attention_mask, dtype=np.uint8)
    if (data.ndim != 3 or data.shape[2] != 3072 or
            data.shape[1] not in (64, 128, 256, 512, 1024) or
            mask.shape != data.shape[:2] or np.any(mask > 1)):
        raise ValueError("attention sequence shapes/mask")
    _finite(data, "attention QKV")
    B, S, _ = data.shape
    planes = data.reshape(B, S, 3, 16, 64)
    q = planes[:, :, 0].transpose(0, 2, 1, 3)
    k = planes[:, :, 1].transpose(0, 2, 1, 3)
    v = planes[:, :, 2].transpose(0, 2, 1, 3)
    scores = np.empty((B, 16, S, S), dtype="<f4")
    key_index = np.arange(S)
    pad = mul(sub(mask.astype("<f4"), F32(1)), F32(10000))
    for b in range(B):
        for h in range(16):
            for row0 in range(0, S, 8):
                end = min(row0 + 8, S)
                products = mul(q[b, h, row0:end, None, :],
                               k[b, h, None, :, :])
                _finite(products, "attention QK products")
                tree = products
                while tree.shape[-1] > 1:
                    tree = add(tree[..., 0::2], tree[..., 1::2])
                    _finite(tree, "attention QK tree")
                scaled = mul(tree[..., 0], F32(0.125))
                if sliding:
                    queries = np.arange(row0, end)
                    local = np.where(np.abs(queries[:, None] -
                                            key_index[None, :]) <= 64,
                                     F32(0), F32(-10000))
                    bias = add(local, pad[b, None, :])
                else:
                    bias = pad[b, None, :]
                scores[b, h, row0:end] = add(scaled, bias)
    _finite(scores, "attention scores")
    probability = softmax_many(scores.reshape(B * 16 * S, S)).reshape(
        B, 16, S, S)
    acc = np.zeros((B, 16, S, 64), dtype="<f4")
    for key in range(S):
        acc = add(acc, mul(probability[..., key, None],
                           v[:, :, None, key, :]))
        _finite(acc, "attention AV accumulator")
    return acc.transpose(0, 2, 1, 3).reshape(B, S, 1024)


def full_forward_graph(token_ids: object, attention_mask: object,
                       marker_positions: object, marker_mask: object,
                       qtype: object, read_weight,
                       checkpoint=lambda name, value: None) -> np.ndarray:
    """Independent complete F0 candidate for one B≤2 request.

    read_weight(name) reads the frozen GGUF source payload, not a DUT BO or
    captured intermediate. checkpoint receives a copy at each named graph
    boundary; callers decide which byte arrays to persist.
    """
    ids = np.asarray(token_ids, dtype="<i4")
    mask = np.asarray(attention_mask, dtype=np.uint8)
    marker = np.asarray(marker_positions, dtype="<i4")
    marker_valid = np.asarray(marker_mask, dtype=np.uint8)
    types = np.asarray(qtype, dtype=np.uint8)
    if (ids.ndim != 2 or ids.shape[0] not in (1, 2) or
            ids.shape[1] not in (64, 128, 256, 512, 1024) or
            mask.shape != ids.shape or marker.shape != (ids.shape[0], 16) or
            marker_valid.shape != marker.shape or
            types.shape != (ids.shape[0],) or np.any(ids < 0) or
            np.any(ids >= 50368) or np.any(mask > 1) or
            np.any(marker_valid > 1) or np.any(types > 2)):
        raise ValueError("full graph request shape/domain")
    B, S = ids.shape
    for b in range(B):
        if not np.any(mask[b]) or not np.any(marker_valid[b]):
            raise ValueError("full graph empty mask")
        for c in range(16):
            pos = int(marker[b, c])
            if marker_valid[b, c]:
                if not b * S <= pos < (b + 1) * S or not mask[b, pos - b * S]:
                    raise ValueError("full graph valid marker")
            elif pos != b * S:
                raise ValueError("full graph invalid marker CLS")

    def keep(name: str, value: np.ndarray) -> np.ndarray:
        _finite(value, name)
        checkpoint(name, np.asarray(value, dtype="<f4").copy())
        return value

    def f32_weight(name: str, count: int) -> np.ndarray:
        raw = read_weight(name)
        if len(raw) != count * 4:
            raise ValueError("F32 source weight span " + name)
        output = np.frombuffer(raw, dtype="<f4")
        _finite(output, "source weight " + name)
        return output

    def q8_linear(name: str, source: np.ndarray, N: int,
                  bias_name: str | None = None) -> np.ndarray:
        rows = source.reshape(-1, source.shape[-1])
        bias = f32_weight(bias_name, N) if bias_name else None
        output = q8_linear_many(rows, read_weight(name), N, bias)
        return output.reshape(source.shape[:-1] + (N,))

    token_table = read_weight("tok_emb.weight")
    if len(token_table) != 50368 * 1088:
        raise ValueError("token embedding source span")
    cache: dict[int, np.ndarray] = {}
    raw_embedding = np.empty((B, S, 1024), dtype="<f4")
    for b in range(B):
        for s in range(S):
            token = int(ids[b, s])
            if token not in cache:
                start = token * 1088
                cache[token] = embedding_row(token_table[start:start + 1088])
            raw_embedding[b, s] = cache[token]
    keep("embedding_raw", raw_embedding)
    emb_gamma = f32_weight("emb_norm_w", 1024)
    hidden = layernorm_many(raw_embedding.reshape(-1, 1024),
                            emb_gamma).reshape(B, S, 1024)
    keep("embedding_norm", hidden)

    rope_tables = {}
    for name in ("cos_full", "sin_full", "cos_slide", "sin_slide"):
        rope_tables[name] = f32_weight(name, 1025 * 64).reshape(1025, 64)[:S]
    for layer in range(28):
        source = hidden if layer == 0 else layernorm_many(
            hidden.reshape(-1, 1024)).reshape(B, S, 1024)
        qkv = q8_linear(f"qkv.{layer}.weight", source, 3072)
        family = "full" if layer % 3 == 0 else "slide"
        qkv = rope_qkv_many(qkv, rope_tables["cos_" + family],
                            rope_tables["sin_" + family])
        attended = attention_many(qkv, mask, layer % 3 != 0)
        projected = q8_linear(f"wo.{layer}.weight", attended, 1024)
        hidden = add(hidden, projected)
        _finite(hidden, "Encoder attention residual")
        norm_ff = layernorm_many(hidden.reshape(-1, 1024)).reshape(B, S, 1024)
        wi = q8_linear(f"mlp_wi.{layer}.weight", norm_ff, 5248)
        gated = mul(gelu_array(wi[..., :2624]), wi[..., 2624:])
        _finite(gated, "Encoder GEGLU")
        down = q8_linear(f"mlp_wo.{layer}.weight", gated, 1024)
        hidden = add(hidden, down)
        keep(f"encoder_{layer:02d}_out", hidden)

    final_gamma = f32_weight("final_norm_w", 1024)
    final_norm = layernorm_many(hidden.reshape(-1, 1024),
                                final_gamma).reshape(B, S, 1024)
    keep("final_norm", final_norm)
    type_table = read_weight("type_emb.weight")
    if len(type_table) != 3 * 1088:
        raise ValueError("type embedding source span")
    hidden = final_norm.copy()
    for b in range(B):
        start = int(types[b]) * 1088
        typed = embedding_row(type_table[start:start + 1088])
        hidden[b] = add(final_norm[b], typed[None, :])
    keep("type_add", hidden)

    for layer in range(2):
        norm_attn = layernorm_many(hidden.reshape(-1, 1024)).reshape(B, S, 1024)
        qkv = q8_linear(f"head_qkv.{layer}.weight", norm_attn, 3072,
                        f"head_qkv.{layer}.bias")
        attended = attention_many(qkv, mask, False)
        projected = q8_linear(f"head_wo.{layer}.weight", attended, 1024,
                               f"head_wo.{layer}.bias")
        hidden = add(hidden, projected)
        _finite(hidden, "Decision attention residual")
        norm_ff = layernorm_many(hidden.reshape(-1, 1024)).reshape(B, S, 1024)
        fc1 = q8_linear(f"head_fc1.{layer}.weight", norm_ff, 4096,
                         f"head_fc1.{layer}.bias")
        activated = np.where(fc1 > 0, fc1, F32(0)).astype("<f4")
        fc2 = q8_linear(f"head_fc2.{layer}.weight", activated, 1024,
                         f"head_fc2.{layer}.bias")
        hidden = add(hidden, fc2)
        keep(f"decision_{layer:02d}_out", hidden)

    gathered = np.empty((B, 16, 1024), dtype="<f4")
    for b in range(B):
        for col in range(16):
            gathered[b, col] = hidden[b, int(marker[b, col]) - b * S]
    keep("marker_gather", gathered)
    marker_norm = layernorm_many(gathered.reshape(-1, 1024)).reshape(
        B, 16, 1024)
    keep("marker_norm", marker_norm)
    scorer_baked = q8_linear("scorer_fc1.weight", marker_norm, 1024,
                             "linear_120_baked_bias")
    keep("scorer_fc1_baked", scorer_baked)
    scorer_bias = f32_weight("scorer_fc1.bias", 1024)
    scorer_hidden = gelu_array(add(scorer_baked, scorer_bias[None, None, :]))
    keep("scorer_post_bias_gelu", scorer_hidden)
    scorer_weight = f32_weight("scorer_fc2.weight", 1024)
    scorer_fc2_bias = f32_weight("scorer_fc2.bias", 1)[0]
    candidate_raw = fp_scorer_many(scorer_hidden.reshape(-1, 1024),
                                    scorer_weight, scorer_fc2_bias).reshape(B, 16)
    keep("candidate_raw", candidate_raw)
    candidate_masked = np.stack([candidate_mask(candidate_raw[b],
                                                marker_valid[b])
                                 for b in range(B)])
    keep("candidate_masked", candidate_masked)
    probability = softmax_many(candidate_masked)
    keep("candidate_prob", probability)
    stats = np.stack([candidate_stats(probability[b],
                                      int(marker_valid[b].sum()))
                      for b in range(B)])
    keep("stats", stats)
    act_input = np.stack([concat_act_row(hidden[b, 0], stats[b])
                          for b in range(B)])
    keep("act_input", act_input)
    act_weight_raw = read_weight("act_fc1.weight")
    if len(act_weight_raw) != 256 * 1028 * 2:
        raise ValueError("act FC1 F16 source span")
    act_weight = np.frombuffer(act_weight_raw, dtype="<u2").reshape(256, 1028)
    act_dot = fp_act_many(act_input, act_weight)
    keep("act_dot", act_dot)
    act_bias = f32_weight("act_fc1.bias", 256)
    act_hidden = gelu_array(add(act_dot, act_bias[None, :]))
    keep("act_hidden", act_hidden)
    act_logits = q8_linear("act_fc2.weight", act_hidden, 2,
                            "act_fc2.bias")
    keep("act_logits", act_logits)
    final18 = np.concatenate((candidate_masked, act_logits), axis=1)
    return keep("final18", final18)
