#!/usr/bin/env python3
"""Controlled encoder checkpoint prelude using ordinary LPV1 events."""
import argparse
from pathlib import Path
import struct


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--host-fixture', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args(); args.output.mkdir(exist_ok=False)
    query = (args.host_fixture / 'snapshot_request.bin').read_bytes()
    assert len(query) == 768
    identity = query[64:148]; model = query[160:576]; descriptor = query[576:704]
    def save(name, p):
        (args.output / (name + '.hex')).write_text(''.join(
            p[i:i+64][::-1].hex() + '\n' for i in range(0, len(p), 64)))
        (args.output / (name + '.bin')).write_bytes(p)
    def event(action, sequence, window=None, origin=0):
        p = bytearray(1024)
        struct.pack_into('<IHHQ', p, 0, 0x3156504c, 1, action, sequence)
        struct.pack_into('<HH', p, 24, 16, 8)
        p[64:148] = identity; p[160:576] = model; p[576] = 1
        p[608:736] = descriptor
        if window is not None:
            row = window * 16; task = window + 1
            struct.pack_into('<I', p, 16, task)
            struct.pack_into('<Q', p, 32, sequence if action == 2 else origin)
            struct.pack_into('<IBBBBBHB', p, 148, task, 0x62, 2, 0, 0, 0, row, 16)
            p[578] = 1; struct.pack_into('<I', p, 580, 16384)
            struct.pack_into('<QIHHQQQBBB', p, 864,
                             row * 4096, 4096, 16, 1, 4096, 0, 65536, 0, 255, 0)
            if action == 3:
                p[42] = 1; struct.pack_into('<I', p, 44, 16384)
                struct.pack_into('<Q', p, 56, (1 << 64) - 1)
                struct.pack_into('<Q', p, 584, 65536)
        return p
    save('claim', event(1, 1))
    for i in range(4):
        begin_seq = 2 + 2 * i
        save('begin' + str(i), event(2, begin_seq, i))
        save('end' + str(i), event(3, begin_seq + 1, i, begin_seq))
    save('publish', event(4, 10)); save('invalidate', event(6, 11))
    save('snapshot', query)
    print('FULL_CURRENT_BOOTSTRAP_SNAPSHOT_RTL_FIXTURE_PASS prelude_tasks=4 prelude_events=10 bytes=262144')

if __name__ == '__main__':
    main()
