#!/usr/bin/env python3
"""Pack independent four-row Q8 fixture data for a TM4 arithmetic replay.

This only changes representation: every expected dot, FP intermediate and PS
comes from the fixture's independent reference, never from the TM4 DUT.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        while block := stream.read(8 << 20):
            h.update(block)
    return h.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def pack_bytes(data: np.ndarray, bits: int) -> str:
    raw = np.asarray(data).tobytes(order="C")
    require(len(raw) * 8 == bits, "stream word width")
    return f"{int.from_bytes(raw, 'little'):0{bits // 4}x}\n"


def read_product(products: dict, role: str, dtype: str) -> np.ndarray:
    item = products[role]
    path = Path(item["path"])
    require(path.stat().st_size == item["bytes"] and
            sha(path) == item["sha256"], f"frozen product {role}")
    return np.fromfile(path, dtype=dtype)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("fixture_manifest", type=Path)
    parser.add_argument("case")
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    source = args.fixture_manifest.resolve()
    fixture = json.loads(source.read_text())
    require(fixture["session"] == {"request_id": 3, "generation": 1,
                                   "B": 1, "S": 128}, "v4 B1/S128 request identity")
    require(fixture["schema"] in ("tm1tn8_real_fixtures_v2",
                                  "t2_widown_v4_b1_four_row_fixtures_v1"),
            "recognized independent fixture")
    cases = [item for item in fixture["cases"] if item["name"] == args.case]
    require(len(cases) == 1, "unique fixture case")
    case = cases[0]
    shape = case.get("shape", case)
    rows, K, N = (int(shape[key]) for key in ("rows", "K", "N"))
    G, T = K // 32, (N + 7) // 8
    require(rows in (1, 4) and (K, N) in
            ((256, 2), (1024, 3072), (1024, 5248), (2624, 1024)),
            "TM4 whitelist shape")
    if (fixture["schema"] == "t2_widown_v4_b1_four_row_fixtures_v1"):
        require(case["status"] == "GENERATED_NO_WIDOWN_DUT_COMPARISON" and
                rows == 4, "current producer Wi/Down fixture")
    products = case["products"]
    prefix = "w_" if "w_q0" in products else ""
    a = read_product(products, "a8_q", "i1").reshape(rows, G, 32)
    sa_half = read_product(products, "a8_scale", "<u2").reshape(rows, G)
    q0 = read_product(products, prefix + "q0", "i1").reshape((T + 1)//2, G, 8, 32)
    q1 = read_product(products, prefix + "q1", "i1").reshape(T//2, G, 8, 32)
    sw_half = read_product(products, "w_scale", "<u2").reshape(T, G, 8)
    steps = read_product(products, "steps_u32x6", "<u4").reshape(rows, G, N, 6)
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    names = ("a8", "sa", "w8", "sw", "dot", "dotf", "product",
             "term", "ps", "trace")
    files = {name: (out / (name + ".mem")).open("w") for name in names}
    try:
        for g in range(G):
            for t in range(T):
                valid = min(8, N - t*8)
                a_word = np.zeros((4, 32), dtype="u1")
                a_word[:rows] = a[:, g, :].view("u1")
                sa_word = np.zeros(4, dtype="<u4")
                sa_word[:rows] = sa_half[:, g].view("<f2").astype("<f4").view("<u4")
                w_word = (q1 if t & 1 else q0)[t//2, g].view("u1")
                sw_word = sw_half[t, g].view("<f2").astype("<f4").view("<u4")
                value = np.zeros((4, 8, 6), dtype="<u4")
                value[:rows, :valid] = steps[:, g, t*8:t*8+valid, :]
                dotf = value[:, :, 0].view("<i4").astype("<f4").view("<u4")
                trace = np.zeros((4, 8), dtype="<u4")
                if t == 0:
                    lane = g % valid
                    trace[:rows, :6] = value[:rows, lane, :]
                    trace[:rows, 6] = g
                    trace[:rows, 7] = 1
                record = {"a8": (a_word, 1024), "sa": (sa_word, 128),
                          "w8": (w_word, 2048), "sw": (sw_word, 256),
                          "dot": (value[:, :, 0], 1024),
                          "dotf": (dotf, 1024),
                          "product": (value[:, :, 3], 1024),
                          "term": (value[:, :, 4], 1024),
                          "ps": (value[:, :, 5], 1024),
                          "trace": (trace, 1024)}
                for name, (data, bits) in record.items():
                    files[name].write(pack_bytes(data, bits))
    finally:
        for stream in files.values():
            stream.close()
    generated = {name: {"path": str(out / (name + ".mem")),
                        "bytes": (out / (name + ".mem")).stat().st_size,
                        "sha256": sha(out / (name + ".mem"))}
                 for name in names}
    (out / "manifest.json").write_text(json.dumps({
        "schema": "tm4_real_streams_v1", "case": args.case,
        "source_manifest": {"path": str(source), "sha256": sha(source)},
        "rows": rows, "K": K, "N": N, "G": G, "T": T,
        "stripes": G*T, "valid_group_records": rows*G*N,
        "trace_rule": "all active rows on tile0 of each group, lane=group%valid_lanes",
        "files": generated,
        "status": "PACKED_INDEPENDENT_REFERENCE_NO_DUT_RUN"
    }, indent=2, sort_keys=True) + "\n")
    print(f"TM4_REAL_STREAMS_PREPARED case={args.case} stripes={G*T} rows={rows}")


if __name__ == "__main__":
    main()
