#!/usr/bin/env python3
"""Literal LAP1/LAC1/LGR1 oracle, independent of DUT codecs and outputs."""
import argparse
import struct
from pathlib import Path

def generate(output):
    identity = (output / 'v2/v1/snapshot_request.bin').read_bytes()[64:148]
    owner = bytearray(19)
    struct.pack_into('<IBBBB', owner, 0, 1, 1, 0, 0, 0)
    owner[8:12] = bytes([2, 0, 255, 0])
    struct.pack_into('<HHH', owner, 12, 0, 64, 1024)
    owner[18] = 1
    command = bytearray(256)
    struct.pack_into('<IHH', command, 0, 0x3150474c, 1, 4)
    command[8] = 1
    struct.pack_into('<I', command, 16, 1)
    command[64:148] = identity
    struct.pack_into('<Q', command, 160, 1)
    command[168:187] = owner
    action = bytearray(512)
    struct.pack_into('<IHH5B', action, 0, 0x3158414c, 1, 8, 2, 0, 0x11, 2, 1)
    struct.pack_into('<Q', action, 24, 1)
    action[64:148] = identity
    struct.pack_into('<Q', action, 168, 1)
    action[176:195] = owner
    action[224:228] = bytes([1, 2, 0, 0])
    struct.pack_into('<Q', action, 232, 1)
    action[257] = 255
    pending = bytearray(1024)
    struct.pack_into('<IHHB', pending, 0, 0x3150414c, 1, 16, 1)
    struct.pack_into('<4Q', pending, 16, 29, 101, 1, 19)
    pending[256:512] = command
    pending[512:1024] = action
    completion = bytearray(256)
    struct.pack_into('<IHH5B', completion, 0, 0x3143414c, 1, 4, 2, 0, 0x11, 2, 1)
    struct.pack_into('<I', completion, 16, 79)
    struct.pack_into('<Q', completion, 24, 1)
    completion[64:148] = identity
    struct.pack_into('<H', completion, 148, 7)
    struct.pack_into('<IQ', completion, 152, 0x0700000e, (1 << 64) - 1)
    completion[201:203] = bytes([255, 255])
    result = bytearray(256)
    struct.pack_into('<IHHB', result, 0, 0x3152474c, 1, 4, 1)
    struct.pack_into('<I', result, 16, 15)
    struct.pack_into('<Q', result, 24, 1)
    result[64:148] = identity
    struct.pack_into('<H', result, 148, 7)
    struct.pack_into('<IQ', result, 152, 0x0700000e, (1 << 64) - 1)
    result[201:203] = bytes([255, 255])
    for name, data in [('pending', pending), ('cancel_completion', completion), ('cancel_result', result)]:
        (output / (name + '.bin')).write_bytes(data)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    generate(parser.parse_args().output)
