#!/usr/bin/env python3
"""E017 bounded independent exact unsigned-integer multiplication fixtures."""
import argparse
import hashlib
import json
import random
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
edges = {0, 1, 2, 3, 0xffffffff, 0xfffffffe, 0x80000000,
         0x7fffffff, 0xaaaaaaaa, 0x55555555, 0x80000001}
for bit in range(32):
    edges.update({(1 << bit) - 1, 1 << bit, min((1 << bit) + 1, 0xffffffff)})
pairs = [(x, y) for x in sorted(edges) for y in sorted(edges)]
rng = random.Random(0xE017320064)
pairs += [(rng.getrandbits(32), rng.getrandbits(32)) for _ in range(8192)]
data = ''.join(f'{x:08x} {y:08x} {x*y:016x}\n' for x, y in pairs)
(a.out/'integer_vectors.txt').write_text(data)
manifest = {'oracle': 'Python arbitrary precision x*y of independent input pairs',
            'operand_bits': [32, 32], 'result_bits': 64,
            'truncation50': 'exact product low50', 'seed': '0xE017320064',
            'edge_values': len(edges), 'boundary_pairs': len(edges)**2,
            'seeded_pairs': 8192, 'total_pairs': len(pairs),
            'sha256': hashlib.sha256(data.encode()).hexdigest()}
(a.out/'integer_reference.json').write_text(json.dumps(manifest, indent=2)+'\n')
print('SFU_REFERENCE_PASS', json.dumps(manifest), flush=True)
