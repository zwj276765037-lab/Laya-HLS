#!/usr/bin/env python3
"""Independent LAX1 request byte oracle for the frozen mapping probe."""

import argparse
import struct
from pathlib import Path


def put(buf: bytearray, off: int, fmt: str, value: int) -> None:
    struct.pack_into("<" + fmt, buf, off, value)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    p = bytearray(512)
    put(p, 0, "I", 0x3158414C)
    put(p, 4, "H", 1)
    put(p, 6, "H", 8)
    p[8:13] = bytes([2, 7, 0x11, 2, 3])
    put(p, 24, "Q", 0x0102030405060708)
    put(p, 64, "Q", 0x1111222233334444)
    put(p, 72, "Q", 0x5555666677778888)
    put(p, 80, "H", 1)
    put(p, 82, "H", 64)
    p[84:100] = bytes(range(0x10, 0x20))
    p[100:116] = bytes(range(0x20, 0x30))
    p[116:132] = bytes(range(0x30, 0x40))
    p[132:148] = bytes(range(0x40, 0x50))
    p[160] = 0
    put(p, 168, "Q", 0x1112131415161718)
    put(p, 176, "I", 9)
    p[180:183] = bytes([1, 0, 0])
    p[184:188] = bytes([2, 2, 255, 0])
    put(p, 188, "H", 0)
    put(p, 190, "H", 64)
    put(p, 192, "H", 1024)
    p[194] = 1
    p[224:228] = bytes([1, 2, 1, 0])
    put(p, 232, "Q", 2)
    p[256:260] = bytes([0, 255, 0, 0])
    args.output.write_bytes(p)


if __name__ == "__main__":
    main()
