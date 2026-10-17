#!/usr/bin/env python3
"""Independent GGUF/NumPy audit of the host Q8 token-embedding producer."""

import argparse
import hashlib
import json
import mmap
from pathlib import Path
import struct
import sys

import numpy as np

PROJECT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(PROJECT))
from tools.export_gguf import GGUF  # independent metadata parser

GGUF_SHA = "6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"
ROW_BYTES = 4096
BATCH_STRIDE = 4194304
STATE0_BYTES = 16920576


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def check(args):
    if sha(args.gguf) != GGUF_SHA:
        raise ValueError("GGUF SHA256 changed")
    request = args.request.read_bytes()
    if len(request) < 320 or request[:4] != b"LYRQ":
        raise ValueError("bad LYRQ request")
    b, s = struct.unpack_from("<HH", request, 20)
    req_id, generation = struct.unpack_from("<QQ", request, 24)
    if b not in (1, 2) or s != 128:
        raise ValueError("unexpected request shape")
    tok_offset = struct.unpack_from("<I", request, 132)[0]
    mask_offset = struct.unpack_from("<I", request, 164)[0]
    if (tok_offset + b * s * 4 > len(request) or
            mask_offset + b * s > len(request)):
        raise ValueError("request token/mask outside frame")
    tokens = np.frombuffer(request, dtype="<i4", count=b * s,
                           offset=tok_offset)
    masks = np.frombuffer(request, dtype="u1", count=b * s,
                          offset=mask_offset)
    if np.any((tokens < 0) | (tokens >= 50368)) or np.any(masks > 1):
        raise ValueError("invalid token or attention mask")

    with args.gguf.open("rb") as stream:
        with mmap.mmap(stream.fileno(), 0, access=mmap.ACCESS_READ) as mapped:
            table = next((t for t in GGUF(mapped).inventory()
                          if t["name"] == "tok_emb.weight"), None)
            if (table is None or table["ggml_type_id"] != 8 or
                    table["ggml_ne"] != [1024, 50368, 1, 1]):
                raise ValueError("invalid real GGUF token table")
            table_offset = table["source_offset"]
            out = bytearray(b * s * ROW_BYTES)
            state0 = bytearray([0xa5]) * STATE0_BYTES
            for index, token in enumerate(tokens):
                row = mapped[table_offset + int(token) * 1088:
                             table_offset + (int(token) + 1) * 1088]
                if len(row) != 1088:
                    raise ValueError("truncated Q8 row")
                values = np.empty(1024, dtype="<f4")
                for group in range(32):
                    block = row[group * 34:(group + 1) * 34]
                    scale = np.frombuffer(block[:2], dtype="<f2")[0].astype("<f4")
                    q = np.frombuffer(block[2:], dtype="i1")
                    if not np.isfinite(scale) or scale < 0 or np.any(q == -128):
                        raise ValueError("invalid scale or signed Q8 code")
                    values[group * 32:(group + 1) * 32] = q.astype("<f4") * scale
                if not np.all(np.isfinite(values)):
                    raise ValueError("nonfinite independent raw result")
                start = index * ROW_BYTES
                payload = values.tobytes()
                out[start:start + ROW_BYTES] = payload
                physical = (index // s) * BATCH_STRIDE + (index % s) * ROW_BYTES
                state0[physical:physical + ROW_BYTES] = payload

    actual = args.raw.read_bytes()
    mapped_state0 = args.state0.read_bytes()
    oracle = args.oracle.read_bytes()
    if len(actual) != b * s * ROW_BYTES or len(oracle) != len(actual):
        raise ValueError("raw/oracle byte count mismatch")
    if actual != out or oracle != out:
        first = next((i for i, (a, e) in enumerate(zip(actual, out)) if a != e), None)
        raise ValueError(f"raw or oracle differs from independent GGUF result at byte {first}")
    if mapped_state0 != state0:
        first = next(i for i, (a, e) in enumerate(zip(mapped_state0, state0)) if a != e)
        raise ValueError(f"STATE0 mapping/sentinel differs at byte {first}")
    result = {
        "status": "PASS",
        "method": "real GGUF metadata parsed separately; NumPy binary16-to-binary32 and signed Q8 multiply; all B*S rows including masked padding",
        "shape": {"B": b, "S": s, "hidden": 1024, "rows": b * s,
                  "padding_rows": int(np.count_nonzero(masks == 0))},
        "request_id": req_id,
        "generation": generation,
        "token_table_source_offset": table_offset,
        "gguf_sha256": GGUF_SHA,
        "request_sha256": sha(args.request),
        "producer_source_sha256": sha(PROJECT / "host/cpu_embedding_raw.cpp"),
        "raw_sha256": sha(args.raw),
        "independent_raw_sha256": hashlib.sha256(out).hexdigest(),
        "oracle_raw_sha256": sha(args.oracle),
        "state0_sha256": sha(args.state0),
        "verified_f32": b * s * 1024,
        "state0_bytes": STATE0_BYTES,
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(result, indent=2) + "\n")
    print("CPU_EMBED_RAW_INDEPENDENT_PASS", result["verified_f32"],
          result["raw_sha256"])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("gguf", "request", "raw", "state0", "oracle", "report"):
        parser.add_argument(name, type=Path)
    check(parser.parse_args())


if __name__ == "__main__":
    main()
