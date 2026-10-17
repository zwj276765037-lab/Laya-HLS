#!/usr/bin/env python3
"""Materialize passive full-group RTL checks from independent real fixtures.

One vector follows every row->group->tile issue. PS old values are supplied
by the RTL testbench's committed PS RAM, never by this gold. dot, dotf,
scale product, term and next PS are checked against independent fixture
steps at the actual pipeline stages.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys


def digest(path: Path) -> dict:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while part := f.read(8 << 20):
            h.update(part)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": h.hexdigest()}


def f32_bits(value: float) -> int:
    return struct.unpack("<I", struct.pack("<f", value))[0]


def half_bits_to_f32(half: bytes) -> int:
    return f32_bits(struct.unpack("<e", half)[0])


def hex_word(values: list[int], width: int) -> str:
    return "".join(f"{value:0{width}x}" for value in reversed(values)) + "\n"


def main() -> None:
    if sys.byteorder != "little":
        raise RuntimeError("little-endian host required")
    ap = argparse.ArgumentParser()
    ap.add_argument("fixtures", type=Path)
    ap.add_argument("case", choices=("act", "qkv_row1", "qkv_rows4"))
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    fixtures, out = args.fixtures.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    case = args.case
    K, N, rows = ((256, 2, 1) if case == "act" else
                  (1024, 3072, 1 if case == "qkv_row1" else 4))
    G, T = K // 32, (N + 7) // 8
    prefix = case + "_"
    inputs = {name: fixtures / (prefix + name + ".bin") for name in
              ("q0", "q1", "w_scale", "a8_q", "a8_scale", "steps_u32x6")}
    raw = {name: path.read_bytes() for name, path in inputs.items()}
    assert len(raw["a8_q"]) == rows * G * 32
    assert len(raw["a8_scale"]) == rows * G * 2
    assert len(raw["steps_u32x6"]) == rows * G * N * 24
    assert len(raw["w_scale"]) == T * G * 8 * 2
    assert len(raw["q0"]) + len(raw["q1"]) == T * G * 8 * 32
    steps = memoryview(raw["steps_u32x6"]).cast("I")
    names = ("a", "w", "sa", "sw", "mask", "dot", "dotf",
             "product", "term", "ps")
    files = {name: (out / (name + ".hex")).open("w") for name in names}
    try:
        for r in range(rows):
            for g in range(G):
                a = raw["a8_q"][(r * G + g) * 32:(r * G + g + 1) * 32]
                sa = half_bits_to_f32(
                    raw["a8_scale"][(r * G + g) * 2:(r * G + g + 1) * 2])
                for tile in range(T):
                    q_shard = raw["q1"] if tile & 1 else raw["q0"]
                    local_tile = tile // 2
                    ws_bytes = bytearray()
                    sw = []
                    mask = 0
                    expected = {field: [] for field in
                                ("dot", "dotf", "product", "term", "ps")}
                    for lane in range(8):
                        n = tile * 8 + lane
                        qoff = ((local_tile * G + g) * 8 + lane) * 32
                        ws_bytes += q_shard[qoff:qoff + 32]
                        soff = ((tile * G + g) * 8 + lane) * 2
                        sw.append(half_bits_to_f32(raw["w_scale"][soff:soff + 2]))
                        if n < N:
                            mask |= 1 << lane
                            at = ((r * G + g) * N + n) * 6
                            dot = steps[at]
                            signed = dot if dot < 1 << 31 else dot - (1 << 32)
                            assert steps[at + 1] == sa and steps[at + 2] == sw[-1]
                            expected["dot"].append(dot)
                            expected["dotf"].append(f32_bits(float(signed)))
                            for field, offset in (("product", 3), ("term", 4),
                                                  ("ps", 5)):
                                expected[field].append(steps[at + offset])
                        else:
                            for field in expected:
                                expected[field].append(0)
                    if len(ws_bytes) != 256:
                        raise AssertionError("W tile size")
                    files["a"].write(f"{int.from_bytes(a, 'little'):064x}\n")
                    files["w"].write(f"{int.from_bytes(ws_bytes, 'little'):0512x}\n")
                    files["sa"].write(f"{sa:08x}\n")
                    files["sw"].write(hex_word(sw, 8))
                    files["mask"].write(f"{mask:02x}\n")
                    for field in expected:
                        files[field].write(hex_word(expected[field], 8))
    finally:
        for f in files.values():
            f.close()
    output_path = fixtures / (prefix + "output_f32.bin")
    output_words = output_path.read_bytes()
    if len(output_words) != rows * N * 4:
        raise AssertionError(f"{case} output shape")
    inputs["output_f32"] = output_path
    (out / "output.hex").write_text(
        "".join(f"{word:08x}\n" for word in
                struct.unpack("<" + "I" * (rows * N), output_words)))
    names += ("output",)
    if case == "act":
        bias_path = fixtures / (prefix + "bias.bin")
        bias_words = bias_path.read_bytes()
        if len(bias_words) != N * 4:
            raise AssertionError("ACT bias shape")
        inputs["bias"] = bias_path
        (out / "bias.hex").write_text(
            "".join(f"{word:08x}\n" for word in
                    struct.unpack("<" + "I" * N, bias_words)))
        names += ("bias",)
    manifest = {"schema": "tm1tn8_arithmetic_vectors_v1", "case": case,
                "rows": rows, "K": K, "N": N, "G": G, "T": T,
                "issues": rows * G * T,
                "input_files": {key: digest(path) for key, path in inputs.items()},
                "generator": digest(Path(__file__)),
                "outputs": {name: digest(out / (name + ".hex")) for name in names}}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2,
                                                  sort_keys=True) + "\n")
    print("TM1TN8_ARITHMETIC_VECTORS_PASS case=" + case +
          " issues=" + str(rows * G * T))


if __name__ == "__main__":
    main()
