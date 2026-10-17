#!/usr/bin/env python3
"""Independent LGP1 command plus LGR1 result byte oracle."""

import argparse
import struct
from pathlib import Path


def put(buf: bytearray, off: int, fmt: str, value: int) -> None:
    struct.pack_into("<" + fmt, buf, off, value)


def put_identity(p: bytearray, off: int) -> None:
    put(p, off, "Q", 0x1111222233334444)
    put(p, off + 8, "Q", 0x5555666677778888)
    put(p, off + 16, "H", 1)
    put(p, off + 18, "H", 64)
    p[off + 20:off + 36] = bytes(range(0x10, 0x20))
    p[off + 36:off + 52] = bytes(range(0x20, 0x30))
    p[off + 52:off + 68] = bytes(range(0x30, 0x40))
    p[off + 68:off + 84] = bytes(range(0x40, 0x50))


def put_owner(p: bytearray, off: int, buffer_id: int, bank: int,
              epoch: int, stage: int, layer: int, rows: int) -> None:
    put(p, off, "I", epoch)
    p[off + 4:off + 7] = bytes([buffer_id, bank, 0])
    p[off + 8:off + 12] = bytes([stage, layer, 255, 0])
    put(p, off + 12, "H", 0)
    put(p, off + 14, "H", rows)
    put(p, off + 16, "H", 1024)
    p[off + 18] = 1


def command() -> bytes:
    p = bytearray(256)
    put(p, 0, "I", 0x3150474C)
    put(p, 4, "H", 1)
    put(p, 6, "H", 4)
    p[8] = 1
    p[9] = 3
    put(p, 16, "I", 1)
    put_identity(p, 64)
    put(p, 160, "Q", 0x1112131415161718)
    put_owner(p, 168, 1, 0, 9, 2, 2, 64)
    return bytes(p)


def result() -> bytes:
    p = bytearray(256)
    put(p, 0, "I", 0x3152474C)
    put(p, 4, "H", 1)
    put(p, 6, "H", 4)
    p[8] = 1
    p[9] = 8
    put(p, 16, "I", 0x1F)
    put(p, 24, "Q", 0x0102030405060708)
    put_identity(p, 64)
    put(p, 148, "H", 0)
    put(p, 156, "Q", 0xFFFFFFFFFFFFFFFF)
    p[176] = 1
    put(p, 184, "Q", 2)
    put_owner(p, 192, 2, 1, 10, 2, 3, 64)
    return bytes(p)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.write_bytes(command() + result())


if __name__ == "__main__":
    main()
