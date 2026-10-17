#!/usr/bin/env python3
"""Exhaustively check the independent signed two-product packing identity.

This is a bit-vector/mathematical check, not a DSP-mapping or timing result.
Only one 256x256 weight plane is resident at a time.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

import numpy as np


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    w0, w1 = np.meshgrid(np.arange(-128, 128, dtype=np.int64),
                         np.arange(-128, 128, dtype=np.int64), indexing="ij")
    x = (w1 << 17) + w0
    assert x.min() >= -(1 << 26) and x.max() < (1 << 26)
    checked = 0
    limits = {key: [None, None] for key in ("X", "P45", "p0", "p1")}
    digest = hashlib.sha256()
    for a in range(-128, 128):
        p = x * np.int64(a)
        p0 = ((p & 0xffff) ^ 0x8000) - 0x8000
        p1 = (p >> 17) + (p0 < 0).astype(np.int64)
        golden0 = w0 * np.int64(a)
        golden1 = w1 * np.int64(a)
        bad = np.argwhere((p0 != golden0) | (p1 != golden1))
        if bad.size:
            i, j = map(int, bad[0])
            raise AssertionError(dict(a=a, w0=int(w0[i, j]), w1=int(w1[i, j]),
                                      X=int(x[i, j]), P45=int(p[i, j]),
                                      p0=int(p0[i, j]), p1=int(p1[i, j]),
                                      expected0=int(golden0[i, j]),
                                      expected1=int(golden1[i, j])))
        assert p.min() >= -(1 << 44) and p.max() < (1 << 44)
        assert p0.min() >= -(1 << 15) and p0.max() < (1 << 15)
        assert p1.min() >= -(1 << 15) and p1.max() < (1 << 15)
        for key, value in (("X", x), ("P45", p), ("p0", p0), ("p1", p1)):
            lo, hi = int(value.min()), int(value.max())
            limits[key][0] = lo if limits[key][0] is None else min(limits[key][0], lo)
            limits[key][1] = hi if limits[key][1] is None else max(limits[key][1], hi)
        # Stable little-endian record for every checked (a,w0,w1,p0,p1).
        chunk = np.empty((256, 256), dtype=np.dtype([
            ("a", "i1"), ("w0", "i1"), ("w1", "i1"),
            ("p0", "<i2"), ("p1", "<i2")]))
        chunk["a"], chunk["w0"], chunk["w1"] = a, w0, w1
        chunk["p0"], chunk["p1"] = p0, p1
        digest.update(chunk.tobytes(order="C"))
        checked += chunk.size
        if (a + 128) % 32 == 0:
            print(f"PACK_PROGRESS a={a} checked={checked}", flush=True)
    assert checked == 256 ** 3
    result = {
        "schema": "tm1tn8_signed_pack_exhaustive_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "status": "PASS_MATHEMATICAL_ONLY",
        "checked_tuples": checked,
        "domain": "every signed8 a,w0,w1 in [-128,127]",
        "construction": "X=(signed(w1)<<17)+signed(w0); Y=signed(a); P45=X*Y",
        "extraction": "p0=signed16(P[15:0]); p1=(P>>>17)+(p0<0)",
        "independent_golden": "signed int64 a*w0 and a*w1",
        "min_max": limits,
        "checked_records_sha256": digest.hexdigest(),
        "record_layout": "row-major a,w0,w1,p0,p1 as i8,i8,i8,LE-i16,LE-i16",
        "source_sha256": sha256(Path(__file__)),
        "numpy_version": np.__version__,
        "limitation": "does not establish RTL behavior, DSP48E2 inference, LUT/FF cost, timing, or R0/PS service",
    }
    (output / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"PACK_EXHAUSTIVE_PASS checked={checked} records_sha256={digest.hexdigest()}")


if __name__ == "__main__":
    main()
