#!/usr/bin/env python3
"""Independent binary32 GELU-step and libm.tanhf gold for captured Wi row0."""

import argparse
import ctypes
import hashlib
import json
import math
from pathlib import Path
import struct

import numpy as np


ROOT = Path(__file__).resolve().parents[4]
LIBM = Path("/lib/x86_64-linux-gnu/libm.so.6").resolve()


def identity(path):
    path = Path(path)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def bits(value):
    return struct.unpack("<I", struct.pack("<f", float(value)))[0]


def mul(a, b):
    return np.multiply(a, b, dtype=np.float32)


def add(a, b):
    return np.add(a, b, dtype=np.float32)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--wi", type=Path, required=True)
    ap.add_argument("--capture-log", type=Path, required=True)
    ap.add_argument("--capture-source-manifest", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    wi = args.wi.resolve()
    if wi.name != "vector_enc0_wi_row0.f32.bin" or wi.stat().st_size != 5248 * 4:
        raise RuntimeError("expected observed full Wi row0 with 5248 F32")
    marker = "VECTOR_WI_CAPTURE request=3 generation=1 B=1 S=128 stage=2 layer=0 row=0 width=5248 bytes=20992"
    if marker not in args.capture_log.read_text():
        raise RuntimeError("current producer capture marker absent")
    source_manifest = json.loads(args.capture_source_manifest.read_text())
    if source_manifest.get("schema") != "laya-vector-wi-read-only-capture-sources-v1":
        raise RuntimeError("capture source identity missing")
    for path, expected in source_manifest["original_sources"].items():
        if identity(path)["sha256"] != expected:
            raise RuntimeError(f"original producer source changed: {path}")
    for path, expected in source_manifest["generated_sources"].items():
        if identity(path)["sha256"] != expected:
            raise RuntimeError(f"capture producer source changed: {path}")
    output = args.out.resolve()
    output.mkdir(parents=True, exist_ok=False)
    libm = ctypes.CDLL(str(LIBM))
    libm.tanhf.argtypes = [ctypes.c_float]
    libm.tanhf.restype = ctypes.c_float
    row = np.frombuffer(wi.read_bytes(), dtype="<f4")
    if len(row) != 5248 or not np.isfinite(row).all():
        raise RuntimeError("Wi source shape/finite")
    half = np.float32(0.5)
    a = np.float32(0.044715)
    c = np.float32(0.7978845608028654)
    one = np.float32(1)
    z_data = bytearray()
    tanh_data = bytearray()
    gate_data = bytearray()
    stages = bytearray()
    for col in range(2624):
        x, g = row[col], row[col + 2624]
        u = mul(a, x)
        v = mul(u, x)
        w = add(one, v)
        t = mul(c, x)
        z = mul(t, w)
        h = np.float32(libm.tanhf(ctypes.c_float(float(z))))
        r = add(one, h)
        s = mul(half, x)
        y = mul(s, r)
        gate = mul(y, g)
        values = (u, v, w, t, z, h, r, s, y, gate)
        if not all(math.isfinite(float(v)) for v in values):
            raise ArithmeticError(f"nonfinite original GELU step at {col}")
        stages += struct.pack("<10I", *(bits(v) for v in values))
        z_data += struct.pack("<I", bits(z))
        tanh_data += struct.pack("<I", bits(h))
        gate_data += struct.pack("<I", bits(gate))
    products = {}
    for name, data in (("z_f32.bin", z_data), ("tanh_f32.bin", tanh_data),
                       ("gate_f32.bin", gate_data),
                       ("gelu_steps_u32x10.bin", stages)):
        path = output / name
        path.write_bytes(data)
        products[name] = identity(path)
    for name, data in (("z.mem", z_data), ("tanh.mem", tanh_data)):
        path = output / name
        path.write_text("".join(f"{le:08x}\n" for le in struct.unpack("<2624I", data)))
        products[name] = identity(path)
    (output / "manifest.json").write_text(json.dumps({
        "schema": "laya-vector-real-wi-gelu-libm-reference-v1",
        "scope": "current v4 request3 enc0 observed Wi row0; 2624 ordered z/tanh/GELU/gate values",
        "input": identity(wi),
        "capture_log": identity(args.capture_log),
        "capture_source_manifest": identity(args.capture_source_manifest),
        "reference_source": identity(Path(__file__)),
        "libm": identity(LIBM),
        "ordered_steps": ["u=a*x", "v=u*x", "w=1+v", "t=c*x", "z=t*w",
                          "h=libm.tanhf(z)", "r=1+h", "s=0.5*x",
                          "y=s*r", "gate=y*G"],
        "products": products,
    }, indent=2, sort_keys=True) + "\n")
    print("VECTOR_GELU_REFERENCE_PASS row=0 elements=2624 tanh=libm.tanhf")


if __name__ == "__main__":
    main()
