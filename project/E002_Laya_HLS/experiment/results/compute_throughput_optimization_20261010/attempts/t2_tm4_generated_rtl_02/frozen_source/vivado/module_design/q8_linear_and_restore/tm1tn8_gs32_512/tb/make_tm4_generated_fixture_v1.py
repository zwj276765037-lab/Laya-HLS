#!/usr/bin/env python3
"""Select two full-G four-row stripes from immutable independent fixtures."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path


def record(path):
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def word(data, offset, width):
    return int.from_bytes(data[offset:offset + width], "little")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fixture", type=Path, required=True)
    ap.add_argument("--reference", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    if args.out.exists():
        raise RuntimeError("fresh output directory required")
    args.out.mkdir(parents=True)
    spec = importlib.util.spec_from_file_location("immutable_reference", args.reference)
    ref = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ref)
    records, inputs, gold = [record(args.reference)], [], []

    def owner(sequence):
        out = [0] * 112
        for i in range(16):
            out[i] = 0x916CC843390125A7 ^ ((i + 1) << 41) ^ sequence
        out[0], out[1], out[111] = 3, 1, sequence
        return out

    for name, groups, columns, tile in [("wi_rows4", 32, 5248, 655),
                                        ("down_rows4", 82, 1024, 127)]:
        data = {}
        for suffix in ["a8_q.bin", "a8_scale.bin", "w_q0.bin", "w_q1.bin",
                       "w_scale.bin", "steps_u32x6.bin"]:
            path = args.fixture / (name + "_" + suffix)
            records.append(record(path))
            data[suffix] = path.read_bytes()
        aq, sa, sw, steps = [data[k] for k in ["a8_q.bin", "a8_scale.bin",
                                              "w_scale.bin", "steps_u32x6.bin"]]
        if len(aq) != 4 * groups * 32 or len(sa) != 4 * groups * 2 or \
                len(sw) != columns // 8 * groups * 16 or \
                len(steps) != 4 * groups * columns * 24:
            raise RuntimeError("immutable fixture dimensions")
        wq = data["w_q1.bin"]  # Both selected final tiles are physically odd.
        previous = [0] * 32
        for group in range(groups):
            x = owner(len(inputs))
            for row in range(4):
                for part in range(4):
                    x[16 + row * 4 + part] = word(aq, (row * groups + group) * 32 + part * 8, 8)
                x[64 + row] = ref.f32(ref.positive_half_rational(word(sa, (row * groups + group) * 2, 2)))
            for lane in range(8):
                for part in range(4):
                    x[32 + lane * 4 + part] = word(wq, (((tile // 2) * groups + group) * 8 + lane) * 32 + part * 8, 8)
                x[68 + lane] = ref.f32(ref.positive_half_rational(word(sw, ((tile * groups + group) * 8 + lane) * 2, 2)))
            x[76:108] = previous
            x[108:111] = [0xFFFFFFFF, group, tile]
            expected = [word(steps, ((row * groups + group) * columns + tile * 8 + lane) * 24 + 20, 4)
                        for row in range(4) for lane in range(8)]
            inputs.append(x)
            gold.append(x[:16] + expected + [0] * 4 + [0x924924] * 4 + [0])
            previous = expected

    for kind in ["maximum", "late_scale", "group_reject", "recovery", "caller_return_hold"]:
        x = owner(len(inputs))
        x[16:64] = [0x0101010101010101] * 48
        x[64:76] = [0x3F800000] * 12
        x[108:111] = [0xFFFFFFFF, 127, 655]
        expected, bad, phases, status = [0x42000000] * 32, [0] * 4, [0x924924] * 4, 0
        if kind == "late_scale":
            x[67] = 0x7F800000
            expected[24:32], bad[3], phases[3], status = [0] * 8, 255, 0, 1
        elif kind == "group_reject":
            x[109], expected, status = 128, [0] * 32, 2
        elif kind in ["recovery", "caller_return_hold"]:
            x[109], x[110] = 0, 0
        inputs.append(x)
        gold.append(x[:16] + expected + bad + phases + [status])

    for name, rows in [("input.hex", inputs), ("gold.hex", gold)]:
        (args.out / name).write_text("".join(f"{v:016x}\n" for row in rows for v in row))
    receipt = {"schema": "tm4-generated-controller-independent-fixture-v1",
               "status": "PASS", "real_calls": 114, "calls": len(inputs),
               "real_row_lane_groups": 3648, "physical_tiles": [655, 127],
               "reference_inputs": records,
               "outputs": [record(args.out / n) for n in ["input.hex", "gold.hex"]],
               "scope": "independent immutable per-group gold; actual TB must use prior actual returns for PS feedback; no C/RTL-produced gold"}
    (args.out / "receipt.json").write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    print("TM4_GENERATED_FIXTURE_PASS real_calls=114 calls=119 row_lane_groups=3648")


if __name__ == "__main__":
    main()
