#!/usr/bin/env python3
"""Serialize existing original CPU input/checker bits; no numerical reference work."""
import datetime as dt
import hashlib
import json
from pathlib import Path
import struct
import time

ROOT = Path(__file__).resolve().parents[3]
RUN = ROOT / 'project/E016_m007_single_resource_parent/experiment_results/runs/R006'
INVENTORY = ROOT / 'results/reviews/m007_model_checkpoint_inventory_20261023.json'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    started = time.monotonic()
    inventory_bytes = INVENTORY.read_bytes()
    inventory = json.loads(inventory_bytes)
    assert inventory['count'] == inventory['matches'] == 47
    dest = RUN / 'data/original_encoder0_fixture'
    dest.mkdir(parents=True, exist_ok=True)
    rows = []
    for name, role in [('embedding_norm', 'ONLY_INITIAL_PUBLIC_H_INPUT'),
                       ('encoder_00_out', 'CHECKER_ONLY_NEVER_PRODUCER')]:
        entry = next(r for r in inventory['rows'] if r['name'] == name)
        source = Path(entry['copied_path'])
        data = source.read_bytes()
        assert entry['shape'] == [1, 128, 1024]
        assert len(data) == entry['bytes'] == 524288
        assert sha(data) == entry['sha256'] == entry['verified_sha256']
        words = struct.unpack('<131072I', data)
        text = ''.join(''.join(f'{word:08x}' for word in reversed(words[i:i+32])) + '\n'
                       for i in range(0, len(words), 32))
        # Independent inverse checks every coordinate and exact original bytes.
        restored = b''.join(struct.pack('<I', int(line[248-lane*8:256-lane*8], 16))
                            for line in text.splitlines() for lane in range(32))
        assert restored == data
        target = dest / (name + '.groups1024.hex')
        encoded = text.encode('ascii')
        if target.exists():
            assert target.read_bytes() == encoded, 'Preserve any old differing fixture'
        else:
            target.write_bytes(encoded)
        rows.append({'name': name, 'role': role, 'shape': entry['shape'],
                     'original_source': str(source.relative_to(ROOT)),
                     'original_sha256': sha(data), 'original_bytes': len(data),
                     'serialized_path': str(target.relative_to(ROOT)),
                     'serialized_sha256': sha(encoded), 'serialized_bytes': len(encoded),
                     'groups': 4096, 'bits_per_group': 1024,
                     'layout': 'row-major row*32+group; hex lane31...lane0; F32 bits unchanged',
                     'roundtrip_bytes_equal': True,
                     'nonfinite_exponent_words': sum((w >> 23) & 255 == 255 for w in words)})
    report = {'schema': 'm007-encoder0-original-fixture-serialization-v1',
              'created_at': dt.datetime.now(dt.timezone.utc).isoformat(),
              'scope': 'Existing original CPU input and checker serialization only; no arithmetic or newgold',
              'inventory_path': str(INVENTORY.relative_to(ROOT)),
              'inventory_sha256': sha(inventory_bytes),
              'files': rows, 'eda_launched': False,
              'preparation_wall_s': time.monotonic() - started}
    manifest = dest / 'manifest.json'
    if manifest.exists():
        old = json.loads(manifest.read_text())
        assert old['inventory_sha256'] == report['inventory_sha256'] and old['files'] == rows
        print('M007_ENCODER0_ORIGINAL_FIXTURE_ALREADY_IDENTICAL')
    else:
        manifest.write_text(json.dumps(report, indent=2) + '\n')
        print('M007_ENCODER0_ORIGINAL_FIXTURE_SERIALIZED ' + json.dumps(report))


if __name__ == '__main__':
    main()
