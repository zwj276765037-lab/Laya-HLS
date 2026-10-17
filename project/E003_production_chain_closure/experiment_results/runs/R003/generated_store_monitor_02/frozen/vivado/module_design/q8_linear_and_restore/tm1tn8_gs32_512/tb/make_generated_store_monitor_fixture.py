#!/usr/bin/env python3
import argparse
import importlib.util
import json
from pathlib import Path
import re


def load_base(path):
    spec = importlib.util.spec_from_file_location('provenance_fixture_base', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--base-generator', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    base = load_base(args.base_generator)
    text = args.package.read_text()
    match = re.search(r"L13M_CANONICAL=3328'h([0-9a-fA-F]+)", text)
    if not match:
        raise RuntimeError('L13M canonical constant is absent')
    l13m = int(match.group(1), 16).to_bytes(416, 'little')
    ordinary1 = base.descriptor(1)
    ordinary2 = base.descriptor(2)
    ordinary3 = base.descriptor(3)
    ordinary4 = base.descriptor(4)
    unsupported = bytearray(base.descriptor(1))
    unsupported[28] = 7
    packets = {
        'claim1': base.request(l13m, 1, 100, 910, (ordinary1,)),
        'begin1': base.request(l13m, 2, 101, 910, (ordinary1,), 1001, 101),
        'end1': base.request(l13m, 3, 102, 910, (ordinary1,), 1001, 101,
                             0, 16 * 4096),
        'publish1': base.request(l13m, 4, 103, 910, (ordinary1,)),
        'release1': base.request(l13m, 5, 104, 910, (ordinary1,)),
        'claim2': base.request(l13m, 1, 105, 911, (ordinary2,)),
        'begin2': base.request(l13m, 2, 106, 911, (ordinary2,), 1002, 106),
        'failed_end2': base.request(l13m, 3, 107, 911, (ordinary2,), 1002,
                                    106, 6, 64),
        'invalidate2': base.request(l13m, 6, 108, 911, (ordinary2,)),
        'claim3': base.request(l13m, 1, 109, 912, (ordinary3,)),
        'begin3': base.request(l13m, 2, 110, 912, (ordinary3,), 1003, 110),
        'failed_end3': base.request(l13m, 3, 111, 912, (ordinary3,), 1003,
                                    110, 7, 128),
        'invalidate3': base.request(l13m, 6, 112, 912, (ordinary3,)),
        'claim4': base.request(l13m, 1, 113, 913, (ordinary4,)),
        'unsupported_claim': base.request(l13m, 1, 114, 914, (unsupported,)),
        'unsupported_begin': base.request(l13m, 2, 115, 914, (unsupported,),
                                          1004, 115),
        'unsupported_invalidate': base.request(l13m, 6, 116, 914,
                                               (unsupported,)),
    }
    args.out.mkdir(parents=True, exist_ok=False)
    for name, packet in packets.items():
        base.write_hex(args.out / (name + '.hex'), packet)
    (args.out / 'fixture.json').write_text(json.dumps({
        'schema': 'laya-generated-store-monitor-fixture-v1',
        'packets': list(packets),
        'bo_role': 6,
        'bo_base': '0x0000001200000000',
        'ordinary_bytes': 16 * 4096,
        'failed_bytes': [64, 128],
        'scope': ('one ordinary contiguous rows16 owner, 1024 real AXI512 '
                  'single-beat writes, W-before-AW, final-B/adapter-fence '
                  'blocking, pre-forward out-of-range rejection, complete '
                  'two-beat illegal-burst drain, unsupported-role BEGIN '
                  'rejection and recovery')
    }, indent=2) + '\n')


if __name__ == '__main__':
    main()
