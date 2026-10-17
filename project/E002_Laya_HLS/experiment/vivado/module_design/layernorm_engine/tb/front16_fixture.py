#!/usr/bin/env python3
"""Resolve and hash the frozen B1/S128 front16 fixture without guessing paths."""
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
OLD = ROOT / 'results/cpu_embedding_q8_validation_20261010/attempts/cpu_front_rtl_03/input_manifest.json'
PACKAGE = ROOT / 'build/model-cpu-embedding-ln-v4-20261010'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    old = json.loads(OLD.read_text())
    package = json.loads((PACKAGE / 'manifest.json').read_text())
    paths = {}
    for item in old['inputs']:
        p = Path(item['path'])
        if p.name == 'state0.bin' and 'new_raw_B1_from_b0_S128_03' in str(p):
            paths['state0'] = p
        elif p.name == 'io.bin' and 'new_raw_B1_from_b0_S128_03' in str(p):
            paths['io'] = p
        elif p.name == 'embedding_raw.f32.bin':
            paths['raw_gold'] = p
        elif p.name == 'embedding_norm.f32.bin':
            paths['norm_gold'] = p
    paths['aux'] = PACKAGE / package['bo']['aux']['file']
    assert set(paths) == {'state0', 'io', 'raw_gold', 'norm_gold', 'aux'}
    hashes = {}
    content = {}
    for key, path in paths.items():
        data = path.read_bytes()
        content[key] = data
        hashes[key] = {'path': str(path), 'bytes': len(data), 'sha256': sha(data)}
        for item in old['inputs']:
            if item['path'] == str(path):
                assert len(data) == item['bytes'] and sha(data) == item['sha256'], key
    gamma = next(t for t in package['tensors'] if t['name'] == 'emb_norm_w')
    assert gamma['bo'] == 'aux' and gamma['base'] == 128 and gamma['ggml_ne'][0] == 1024
    assert content['state0'][:65536] == content['raw_gold'][:65536]
    assert sha(content['raw_gold'][:65536]) == 'f6f6af0d7580cac57afa48a93559693819e04e7115d34aaa05619061346b947f'
    assert sha(content['norm_gold'][:65536]) == 'ab9710b0dec2006ab0f7a596e26f9c3521c219a4bf42a35917276ef3bfd77362'
    result = {'source_manifest': str(OLD), 'package_manifest': str(PACKAGE / 'manifest.json'),
              'gamma_offset': gamma['base'], 'inputs': hashes,
              'raw16_sha256': sha(content['raw_gold'][:65536]),
              'norm16_sha256': sha(content['norm_gold'][:65536])}
    if len(sys.argv) == 2:
        Path(sys.argv[1]).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
