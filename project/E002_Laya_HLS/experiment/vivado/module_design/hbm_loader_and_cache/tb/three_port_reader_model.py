#!/usr/bin/env python3
"""Independent byte/address and bounded-burst model for the T4 W reader."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

BEAT = 64
PAGE = 4096
MAX_BEATS = 64


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bursts(base: int, size: int) -> list[dict[str, int]]:
    if base < 0 or size < 0 or base % BEAT or size % BEAT:
        raise ValueError("reader extent must be aligned to 64 bytes")
    result = []
    cursor = base
    end = base + size
    while cursor < end:
        count = min(MAX_BEATS, (end - cursor) // BEAT,
                    (PAGE - cursor % PAGE) // BEAT)
        if count <= 0:
            raise ValueError("zero-length burst")
        result.append({"addr": cursor, "beats": count, "reserved_bytes": count * BEAT,
                       "last_byte": cursor + count * BEAT - 1})
        cursor += count * BEAT
    if sum(x["reserved_bytes"] for x in result) != size:
        raise AssertionError("burst byte coverage")
    if any(x["beats"] > MAX_BEATS or
           x["addr"] // PAGE != x["last_byte"] // PAGE for x in result):
        raise AssertionError("burst cap/page crossing")
    return result


def shape(weight: dict) -> tuple[int, int]:
    k, n = weight["K"], weight["N"]
    if weight["dtype"] != 8 or k <= 0 or k % 32 or n <= 0:
        raise ValueError("unsupported weight shape")
    groups, tiles = k // 32, (n + 7) // 8
    expected_q = [((tiles + 1) // 2) * groups * 256,
                  (tiles // 2) * groups * 256]
    if (weight["q_span"] != expected_q or
            weight["scale_span"] != tiles * groups * 8 * 2):
        raise ValueError(f"payload span drift for {weight['name']}")
    return groups, tiles


def q_byte(weight: dict, tile: int, group: int, lane: int, k: int) -> tuple[int, int]:
    groups, tiles = shape(weight)
    if not (0 <= tile < tiles and 0 <= group < groups and
            0 <= lane < 8 and 0 <= k < 32):
        raise ValueError("q index out of range")
    shard = tile & 1
    byte = weight["q_base"][shard] + ((tile // 2) * groups + group) * 256
    byte += lane * 32 + k
    if byte >= weight["q_base"][shard] + weight["q_span"][shard]:
        raise AssertionError("q address leaves the weight extent")
    return shard, byte


def scale_byte(weight: dict, tile: int, group: int, lane: int) -> int:
    groups, tiles = shape(weight)
    if not (0 <= tile < tiles and 0 <= group < groups and 0 <= lane < 8):
        raise ValueError("scale index out of range")
    byte = weight["scale_base"] + 2 * ((tile * groups + group) * 8 + lane)
    if byte + 2 > weight["scale_base"] + weight["scale_span"]:
        raise AssertionError("scale address leaves the weight extent")
    return byte


def sampled(weight: dict) -> list[dict]:
    groups, tiles = shape(weight)
    if weight["K"] == 1024 and weight["N"] == 5248:
        points = [(0, 0), (511, 0), (512, 0), (655, groups - 1)]
    elif weight["K"] == 2624 and weight["N"] == 1024:
        points = [(0, 0), (0, 63), (0, 64), (tiles - 1, 81)]
    else:
        return []
    result = []
    for tile, group in points:
        shard0, start = q_byte(weight, tile, group, 0, 0)
        shard1, last = q_byte(weight, tile, group, 7, 31)
        if shard0 != shard1 or last - start != 255:
            raise AssertionError("a full shared-W group must be contiguous")
        result.append({"tile": tile, "group": group, "shard": shard0,
                       "q_first": start, "q_last": last,
                       "scale_first": scale_byte(weight, tile, group, 0),
                       "scale_last": scale_byte(weight, tile, group, 7) + 1})
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("report", type=Path)
    args = parser.parse_args()
    manifest = args.manifest.resolve(strict=True)
    package = json.loads(manifest.read_text())
    weights = [w for w in package["weights"] if w["dtype"] == 8]
    if len(weights) != 122:
        raise ValueError("expected all 122 Q8 weight descriptors")
    serial = concurrent = 0
    details = []
    for weight in weights:
        groups, tiles = shape(weight)
        streams = {
            "q0": (weight["q_base"][0], weight["q_span"][0]),
            "q1": (weight["q_base"][1], weight["q_span"][1]),
            "scale": (weight["scale_base"], weight["scale_span"]),
        }
        port_bursts = {name: bursts(base, size)
                       for name, (base, size) in streams.items()}
        if weight["bias_span"] and (
                weight["bias_base"] % 4 or weight["bias_span"] % 4):
            raise ValueError("bias byte alignment")
        cycles = (weight["q_span"][0] // 64, weight["q_span"][1] // 64,
                  weight["scale_span"] // 16, (weight["bias_span"] + 15) // 16)
        serial += sum(cycles[:3])
        concurrent += max(cycles)
        if ((weight["K"], weight["N"]) in ((1024, 5248), (2624, 1024))
                and weight["layer"] == 0):
            details.append({
                "weight_key": [weight["family"], weight["layer"]],
                "name": weight["name"], "K": weight["K"], "N": weight["N"],
                "G": groups, "T": tiles,
                "port_burst_count": {name: len(bs) for name, bs in port_bursts.items()},
                "port_first_last": {name: [bs[0], bs[-1]] if bs else []
                                    for name, bs in port_bursts.items()},
                "sampled_groups": sampled(weight),
                "ideal_port_cycles": list(cycles),
            })
    report = {
        "schema": "t4_three_port_reader_address_model_v1",
        "scope": "address, exact bytes, 4KiB/64-beat splitting and ideal port fee only",
        "manifest": {"path": str(manifest), "sha256": sha(manifest)},
        "model_script": {"path": str(Path(__file__).resolve()),
                         "sha256": sha(Path(__file__).resolve())},
        "q8_weights": len(weights),
        "serial_payload_cycles": serial,
        "three_port_ideal_cycles_including_bias_fee": concurrent,
        "cases": details,
        "hardware_state": "NOT_RUN",
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    if args.report.exists():
        raise FileExistsError("fresh report path required")
    args.report.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"T4_READER_ADDRESS_MODEL_PASS weights={len(weights)} "
          f"serial={serial} three_port_ideal={concurrent} cases={len(details)}")


if __name__ == "__main__":
    main()
