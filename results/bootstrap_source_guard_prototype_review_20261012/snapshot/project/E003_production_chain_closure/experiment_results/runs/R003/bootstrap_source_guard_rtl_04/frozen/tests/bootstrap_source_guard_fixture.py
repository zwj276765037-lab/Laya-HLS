#!/usr/bin/env python3
"""Independent byte fixtures for the finite source-exclusion shell test.

Action/producer keys and safe-error reports are controlled protocol fixtures;
they do not assert that a generated producer or executor ran.
"""
import argparse
from pathlib import Path
import struct


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--fixture', type=Path, required=True)
    args = ap.parse_args()
    q = (args.fixture / 'snapshot.bin').read_bytes()
    identity, model = q[64:148], q[160:576]
    def save(name, p):
        (args.fixture / (name + '.bin')).write_bytes(p)
        (args.fixture / (name + '.hex')).write_text(''.join(
            p[i:i+64][::-1].hex()+'\n' for i in range(0, len(p), 64)))
    action = bytearray(512)
    struct.pack_into('<IHH', action, 0, 0x3158414c, 1, 8)
    action[8:13] = bytes([2, 1, 0x11, 2, 1])
    struct.pack_into('<Q', action, 24, 1)
    action[64:148] = identity
    struct.pack_into('<Q', action, 168, 1)
    action[176:184] = q[576:584]
    action[184:195] = q[592:603]
    action[224:228] = bytes([1, 2, 0, 0])
    struct.pack_into('<Q', action, 232, 1)
    action[257] = 255
    save('guard_action', action)
    producer = bytearray(1024)
    struct.pack_into('<IHHHHH', producer, 0, 0x3145504c, 1, 16, 1, 0, 8)
    struct.pack_into('<QQ', producer, 16, 1, 12)
    producer[64:148] = identity
    struct.pack_into('<IBBBBBHB', producer, 148, 5, 0x11, 2, 1, 0, 0, 0, 16)
    producer[160:576] = model
    producer[576:584] = q[576:584]
    struct.pack_into('<IBBBB', producer, 584, 1, 2, 0, 0, 0)
    struct.pack_into('<H', producer, 592, 1024)
    producer[597:599] = bytes([6, 6])
    struct.pack_into('<II', producer, 600, 0x3727c5ac, 4096)
    struct.pack_into('<6Q', producer, 608, 0, 262144, 4096, 4096, 16920576, 16920576)
    struct.pack_into('<I', producer, 656, 16384); producer[660] = 1
    save('guard_producer', producer)
    complete = bytearray(256)
    complete[:148] = action[:148]
    struct.pack_into('<IHH', complete, 0, 0x3143414c, 1, 4)
    struct.pack_into('<I', complete, 16, 15)
    struct.pack_into('<H', complete, 148, 7)  # E_PROTOCOL, safe error fixture
    struct.pack_into('<I', complete, 152, 0x0700000e)
    struct.pack_into('<Q', complete, 156, (1 << 64)-1)
    save('guard_completion', complete)
    for name, kind, sequence in [('guard_claim', 1, 11), ('guard_invalidate', 6, 12)]:
        event = bytearray((args.fixture / 'claim.bin').read_bytes())
        struct.pack_into('<H', event, 6, kind)
        struct.pack_into('<Q', event, 8, sequence)
        event[612] = 2; event[625] = 1
        struct.pack_into('<Q', event, 648, 262144)
        save(name, event)
    print('FULL_CURRENT_BOOTSTRAP_SOURCE_GUARD_FIXTURE_PASS controlled_action_producer_safe_error=1')


if __name__ == '__main__':
    main()
