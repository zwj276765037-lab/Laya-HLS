#!/usr/bin/env python3
"""Independent LPV1/LPA1 byte oracle for the frozen C++ fixtures."""
import struct
import sys
from pathlib import Path


def u(data, offset, size):
    return int.from_bytes(data[offset:offset + size], "little")


def zero(data, first, end):
    assert data[first:end] == bytes(end - first), (first, end)


def identity(data, offset):
    assert u(data, offset, 8) == 31
    assert u(data, offset + 8, 8) == 7
    assert u(data, offset + 16, 2) == 2
    assert u(data, offset + 18, 2) == 64
    assert data[offset + 20:offset + 36] == bytes(range(0x10, 0x20))
    assert data[offset + 36:offset + 52] == bytes(range(0x30, 0x40))
    assert data[offset + 52:offset + 68] == bytes(range(0x50, 0x60))
    assert data[offset + 68:offset + 84] == bytes(range(0x70, 0x80))


def descriptor(data, offset):
    assert u(data, offset, 4) == 3
    assert data[offset + 4:offset + 8] == bytes([1, 0, 0, 0])
    zero(data, offset + 8, offset + 16)
    assert data[offset + 16:offset + 20] == bytes([2, 1, 255, 0])
    assert u(data, offset + 20, 2) == 0
    assert u(data, offset + 22, 2) == 64
    assert u(data, offset + 24, 2) == 1024
    assert data[offset + 26:offset + 29] == bytes([1, 0, 6])
    zero(data, offset + 29, offset + 32)
    assert u(data, offset + 32, 8) == 16920576
    assert u(data, offset + 40, 8) == 0
    assert u(data, offset + 48, 8) == 4096
    assert u(data, offset + 56, 8) == 4194304
    assert u(data, offset + 64, 8) == 4456448
    zero(data, offset + 72, offset + 128)


def main():
    root = Path(sys.argv[1])
    begin = (root / "begin.bin").read_bytes()
    end = (root / "end.bin").read_bytes()
    claim = (root / "claim.bin").read_bytes()
    response = (root / "publish_response.bin").read_bytes()
    assert len(begin) == len(end) == len(claim) == 1024
    assert len(response) == 512

    assert begin[:4] == b"LPV1" and u(begin, 4, 2) == 1
    assert u(begin, 6, 2) == 2 and u(begin, 8, 8) == 102
    assert u(begin, 16, 4) == 42
    zero(begin, 20, 24)
    assert u(begin, 24, 2) == 16 and u(begin, 26, 2) == 8
    zero(begin, 28, 32)
    assert u(begin, 32, 8) == 102
    zero(begin, 40, 64)
    identity(begin, 64)
    assert begin[148:160] == bytes([42, 0, 0, 0, 0x11, 2, 1, 1, 0, 16, 0, 16])
    assert begin[160:576] == bytes((i * 19 + 3) & 0xff for i in range(416))
    assert begin[576:580] == bytes([1, 0, 1, 0])
    assert u(begin, 580, 4) == 16384
    zero(begin, 584, 608)
    descriptor(begin, 608)
    zero(begin, 736, 864)
    assert u(begin, 864, 8) == 4194304 + 16 * 4096
    assert u(begin, 872, 4) == 4096
    assert u(begin, 876, 2) == 16 and u(begin, 878, 2) == 1
    assert u(begin, 880, 8) == 4096 and u(begin, 888, 8) == 0
    assert u(begin, 896, 8) == 65536
    assert begin[904:907] == bytes([0, 255, 0])
    zero(begin, 907, 1024)

    assert u(end, 6, 2) == 3 and u(end, 8, 8) == 103
    assert u(end, 32, 8) == 102 and u(end, 40, 2) == 0
    assert end[42] == 1 and u(end, 44, 4) == 16384
    assert u(end, 56, 8) == (1 << 64) - 1
    assert u(end, 584, 8) == 65536 and u(end, 592, 8) == 0
    assert claim[:4] == b"LPV1" and u(claim, 6, 2) == 1
    zero(claim, 148, 160)
    zero(claim, 578, 608)
    zero(claim, 864, 1024)

    assert response[:4] == b"LPA1" and u(response, 4, 2) == 1
    assert u(response, 6, 2) == 4 and u(response, 8, 8) == 104
    assert u(response, 16, 8) == 0 and u(response, 24, 2) == 0
    assert response[26] == 5
    zero(response, 27, 32)
    assert u(response, 32, 8) == (1 << 64) - 1
    zero(response, 40, 45)
    assert response[45] == 1
    zero(response, 46, 64)
    identity(response, 64)
    zero(response, 148, 160)
    assert response[160:168] == bytes([3, 0, 0, 0, 1, 0, 0, 0])
    zero(response, 168, 512)
    print("FULL_CURRENT_GENERATED_PROVENANCE_WIRE_ORACLE_PASS bytes=3584")


if __name__ == "__main__":
    main()
