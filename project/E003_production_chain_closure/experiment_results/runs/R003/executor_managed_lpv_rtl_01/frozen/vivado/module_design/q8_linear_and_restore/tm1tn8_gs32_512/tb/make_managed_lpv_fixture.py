#!/usr/bin/env python3
"""Literal LPV requests/results around an actual C++-captured full LAD1 A."""
import argparse
import importlib.util
import json
import struct
from pathlib import Path


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--base-generator', type=Path, required=True)
    p.add_argument('--admission', type=Path, required=True)
    p.add_argument('--literal', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    spec = importlib.util.spec_from_file_location('base', a.base_generator)
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    owner = a.admission.read_bytes()
    assert owner == a.literal.read_bytes() and len(owner) == 1024
    assert struct.unpack_from('<IHHIIQQ', owner) == (0x3144414c, 1, 16, 3, 64, 29, 101)
    identity, model = owner[64:148], owner[160:576]
    capacity = struct.unpack_from('<Q', owner, 736)[0]
    d = bytearray(base.descriptor(1))
    struct.pack_into('<Q', d, 32, capacity)

    def request(action, seq, task=0, origin=0, reported=0, issued=0):
        b = base.request(model, action, seq, 1101, (d,), task, origin, reported, issued)
        b[64:148] = identity
        return b

    packets = {
        'claim': request(1, 1), 'invalidate': request(6, 10),
        'claim_partial': request(1, 20), 'preowned_claim': request(1, 21),
        'active_claim': request(1, 30), 'begin': request(2, 31, 1, 31),
        'bad_end': request(3, 32, 1, 99, 7, 64),
        'end': request(3, 33, 1, 31, 7, 64),
        'active_invalidate': request(6, 34),
        'repeated_invalidate': request(6, 35),
        'unknown_invalidate': request(6, 40),
    }
    for name, seq, offset, fmt, value in [
        ('wrong_epoch', 2, 608, 'I', 2),
        ('wrong_ref', 3, 612, 'B', 4),
        ('wrong_offset', 4, 648, 'Q', 64),
        ('unknown_role', 5, 636, 'B', 8),
    ]:
        b = request(6, seq)
        struct.pack_into('<' + fmt, b, offset, value)
        packets[name] = b
    # Syntax-valid full model changes are rejected before hub admission.
    b = request(6, 6)
    b[160 + 72] ^= 1
    packets['wrong_model'] = b
    b = request(6, 7)
    b[1000] = 1
    packets['bad_reserved'] = b

    def response(req, status=0, flags=1, detail=0, bad=(1 << 64)-1, observed=0):
        b = bytearray(512)
        struct.pack_into('<IHHQQHBBIQ', b, 0, 0x3141504c, 1,
                         struct.unpack_from('<H', req, 6)[0],
                         struct.unpack_from('<Q', req, 8)[0],
                         struct.unpack_from('<Q', req, 32)[0], status, flags, 0, detail, bad)
        b[45] = 1
        struct.pack_into('<Q', b, 48, observed)
        b[64:148], b[148:160] = req[64:148], req[148:160]
        b[160:168], b[168:176] = req[608:616], req[616:624]
        return b

    expected = {
        'claim': (0, 1, 0), 'invalidate': (0, 1, 0),
        'wrong_epoch': (5, 1, 0x04000008),
        'wrong_ref': (5, 1, 0x04000008),
        'wrong_offset': (5, 1, 0x04000008),
        'unknown_role': (7, 0, 0x04000017),
        'wrong_model': (7, 0, 0x04000017),
        'bad_reserved': (1, 0, 0x04000016),
        'claim_partial': (7, 1, 0x04000017),
        'preowned_claim': (7, 1, 0x04000017),
        'active_claim': (0, 1, 0), 'begin': (0, 3, 0),
        'bad_end': (7, 2, 0x04000017),
        'end': (7, 1, 0x07100007), 'active_invalidate': (0, 1, 0),
        'repeated_invalidate': (5, 1, 0x04000008),
        'unknown_invalidate': (5, 1, 0x04000008),
    }
    a.out.mkdir(exist_ok=False, parents=True)
    base.write_hex(a.out/'admission.hex', owner)
    for name, req in packets.items():
        base.write_hex(a.out/(name+'.hex'), req)
        status, flags, detail = expected[name]
        gold = response(req, status, flags, detail, 19 if name=='end' else (1<<64)-1,
                        64 if name=='end' else 0)
        base.write_hex(a.out/(name+'_gold.hex'), gold)
    (a.out/'fixture.json').write_text(json.dumps({
        'scope': 'actual C++ A bytes, controlled whole-record RTL install, single STATE0',
        'packets': list(packets), 'literal_results': len(expected),
        'request_beats': 16, 'response_beats': 8, 'no_hardware_rearm': True,
    }, indent=2)+'\n')
    print('FULL_CURRENT_MANAGED_LPV_LITERAL_PASS actual_A_equal_literal=1 packets='+str(len(packets)))


if __name__ == '__main__':
    main()
