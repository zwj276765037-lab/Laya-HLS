#!/usr/bin/env python3
"""Validate the complete immutable static model package before an offline upload."""
from __future__ import annotations

import argparse
import hashlib
import json
import mmap
from pathlib import Path, PurePosixPath
import sys
import time

import numpy as np

SOURCE_SHA256 = '6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18'
BO_ROLES = ('embedding', 'w_q0', 'w_q1', 'w_scale', 'aux')
EXPECTED_Q8 = 122
EXPECTED_HALVES = 11_542_592
EXPECTED_PADDING = 48


class PackageError(ValueError):
    pass


def require(test: bool, message: str) -> None:
    if not test:
        raise PackageError(message)


def digest_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def digest_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def package_file(package: Path, name: str) -> Path:
    relative = PurePosixPath(name)
    require(not relative.is_absolute() and '..' not in relative.parts,
            f'unsafe package path {name}')
    return package / relative


def independent_half_truth() -> dict:
    """NumPy's binary16 decoder is independent of the bit-mask predicate."""
    bits = np.arange(65536, dtype=np.uint16)
    value = bits.view(np.float16)
    with np.errstate(invalid='ignore'):
        decoded = np.isfinite(value) & ((value >= np.float16(0)) | (value == np.float16(0)))
    predicate = ((bits & 0x7c00) != 0x7c00) & (((bits & 0x8000) == 0) | ((bits & 0x7fff) == 0))
    mismatch = np.flatnonzero(decoded != predicate)
    require(len(mismatch) == 0,
            f'binary16 predicate mismatch bits=0x{int(mismatch[0]):04x}' if len(mismatch) else '')
    return {'checked_bit_patterns': 65536, 'accepted': int(np.count_nonzero(predicate)),
            'rejected': int(np.count_nonzero(~predicate)),
            'negative_zero_accepted': bool(predicate[0x8000])}


def category_counts(bits: np.ndarray) -> dict[str, int]:
    sign = (bits & 0x8000) != 0
    magnitude = bits & 0x7fff
    exponent = bits & 0x7c00
    return {'positive_finite_nonzero': int(np.count_nonzero(~sign & (exponent != 0x7c00) & (magnitude != 0))),
            'positive_zero': int(np.count_nonzero(bits == 0)),
            'negative_zero': int(np.count_nonzero(bits == 0x8000)),
            'negative_nonzero': int(np.count_nonzero(sign & (magnitude != 0))),
            'inf_or_nan': int(np.count_nonzero(exponent == 0x7c00)),
            'positive_subnormal': int(np.count_nonzero(~sign & (exponent == 0) & (magnitude != 0)))}


def scan_matrix_scale(scale: bytes | bytearray | mmap.mmap, w: dict) -> tuple[dict, dict]:
    """Enumerate every padded n/g address and report the first illegal half."""
    key = [w['family'], w['layer']]
    K, N = int(w['K']), int(w['N'])
    require(K > 0 and K % 32 == 0 and N > 0, f'{key} K/N')
    G, padded_N = K // 32, ((N + 7) // 8) * 8
    base, span = int(w['scale_base']), int(w['scale_span'])
    require(base % 2 == 0 and span == padded_N * G * 2 and
            0 <= base <= len(scale) and span <= len(scale) - base,
            f'{key} scale span/bounds')
    n = np.arange(padded_N, dtype=np.int64)[:, None]
    g = np.arange(G, dtype=np.int64)[None, :]
    offsets = base + 2 * (((n // 8) * G + g) * 8 + n % 8)
    # A unique, contiguous half address for every manifest-declared byte.
    sorted_offsets = np.sort(offsets.reshape(-1))
    expected_offsets = np.arange(base, base + span, 2, dtype=np.int64)
    require(np.array_equal(sorted_offsets, expected_offsets), f'{key} scale byte coverage')
    values = np.frombuffer(scale, dtype='<u2', count=span // 2, offset=base)
    indexed = values[((offsets - base) // 2).reshape(-1)]
    del values
    legal = ((indexed & 0x7c00) != 0x7c00) & (
        ((indexed & 0x8000) == 0) | ((indexed & 0x7fff) == 0))
    bad = np.flatnonzero(~legal)
    if len(bad):
        i = int(bad[0]); bad_n, bad_g = divmod(i, G)
        raise PackageError(json.dumps({'reason': 'illegal static scale half',
            'WeightKey': key, 'name': w['name'], 'n': bad_n, 'g': bad_g,
            'offset': int(offsets[bad_n, bad_g]), 'half': f'0x{int(indexed[i]):04x}'}))
    return ({'WeightKey': key, 'name': w['name'], 'K': K, 'N': N,
             'padded_N': padded_N, 'G': G, 'scale_base': base,
             'scale_span': span, 'halves_checked': len(indexed),
             'padding_halves': (padded_N - N) * G}, category_counts(indexed))


def validate(package: Path) -> dict:
    started = time.perf_counter()
    root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(root / 'tests'))
    from full_model_package_test import verify as verify_entire_package

    # This independently checks every GGUF tensor, BO span, padding byte,
    # directory binding and tag header. A stale v4 build-source hash is
    # recorded, not misrepresented as the new kernel's implementation identity.
    package_check = verify_entire_package(root, package, strict_current_sources=False)
    require(package_check['status'] == 'MODEL_PACKAGE_PASS', 'independent package verification')
    package_seconds = time.perf_counter() - started
    manifest_path = package / 'manifest.json'
    manifest_raw = manifest_path.read_bytes()
    manifest = json.loads(manifest_raw)
    require(manifest['schema'] == 'laya-model-p2-v1', 'manifest schema')
    manifest_sha = digest_bytes(manifest_raw)
    model = manifest['source_model']
    source_path = Path(model['path'])
    require(source_path.is_file() and source_path.stat().st_size == model['size'], 'source GGUF size')
    require(model['sha256'] == SOURCE_SHA256 and digest_file(source_path) == SOURCE_SHA256,
            'source GGUF SHA256')
    tags = manifest['tags']
    require(set(tags) == {'model', 'numeric', 'layout', 'build'} and
            tags['model'] == SOURCE_SHA256[:32], 'model tags')
    preimages = {}
    for role in ('numeric', 'layout', 'build'):
        item = manifest['tag_preimages'][role]
        path = package_file(package, item['file'])
        raw = path.read_bytes()
        actual = digest_bytes(raw)
        require(actual == item['sha256'] and tags[role] == actual[:32],
                f'{role} preimage identity')
        preimages[role] = {'file': item['file'], 'sha256': actual}
    layout = json.loads(package_file(package, manifest['tag_preimages']['layout']['file']).read_bytes())
    build = json.loads(package_file(package, manifest['tag_preimages']['build']['file']).read_bytes())
    require(layout['tensors'] == manifest['tensors'] and layout['weights'] == manifest['weights'] and
            layout['bo_sizes'] == {name: manifest['bo'][name]['size'] for name in BO_ROLES} and
            layout['source_model_sha256'] == SOURCE_SHA256, 'layout preimage binding')
    require(build['model_sha256'] == SOURCE_SHA256 and
            build['layout_sha256'] == preimages['layout']['sha256'] and
            build['numeric_sha256'] == preimages['numeric']['sha256'], 'build preimage binding')

    require(set(manifest['bo']) == set(BO_ROLES), 'BO roles')
    bo_records = {}
    bo_maps = {}
    bo_files = []
    try:
        for role in BO_ROLES:
            item = manifest['bo'][role]
            path = package_file(package, item['file'])
            require(path.stat().st_size == item['size'], f'{role} BO size')
            actual = digest_file(path)
            require(actual == item['sha256'], f'{role} BO hash')
            handle = path.open('rb')
            bo_files.append(handle)
            bo_maps[role] = mmap.mmap(handle.fileno(), 0, access=mmap.ACCESS_READ)
            bo_records[role] = {'file': item['file'], 'bytes': item['size'], 'sha256': actual}
        hash_seconds = time.perf_counter() - started
        half_truth = independent_half_truth()
        weights = manifest['weights']
        require(len(weights) == 124, 'weight directory count')
        keys = [(w['family'], w['layer']) for w in weights]
        require(len(set(keys)) == 124, 'WeightKey uniqueness')
        q8 = [w for w in weights if w['dtype'] == 8]
        require(len(q8) == EXPECTED_Q8, 'Q8 directory count')
        scale = bo_maps['w_scale']
        scale_spans = []
        matrix_records = []
        total_halves = 0
        total_padding = 0
        totals = {key: 0 for key in category_counts(np.empty(0, dtype=np.uint16))}
        scan_started = time.perf_counter()
        for w in q8:
            record, cats = scan_matrix_scale(scale, w)
            scale_spans.append((record['scale_base'], record['scale_base'] +
                                record['scale_span'], record['WeightKey']))
            for name, count in cats.items(): totals[name] += count
            total_halves += record['halves_checked']
            total_padding += record['padding_halves']
            matrix_records.append(record)
        scale_spans.sort()
        for previous, current in zip(scale_spans, scale_spans[1:]):
            require(previous[1] <= current[0], f'scale spans overlap {previous[2]} {current[2]}')
        require(total_halves == EXPECTED_HALVES and total_padding == EXPECTED_PADDING,
                'full scale count/padding count')
        scan_seconds = time.perf_counter() - scan_started
        return {'schema': 'laya-validated-static-model-v1',
                'profile': 'VALIDATED_STATIC_MODEL_V1', 'status': 'PASS',
                'package': str(package), 'manifest_sha256': manifest_sha,
                'source_gguf_sha256': SOURCE_SHA256, 'tags': tags,
                'tag_preimages': preimages, 'bos': bo_records,
                'weight_key_count': len(keys), 'q8_matrix_count': len(q8),
                'half_truth': half_truth, 'scale_halves_checked': total_halves,
                'scale_bytes_covered': total_halves * 2,
                'padding_halves_checked': total_padding,
                'scale_categories': totals, 'matrices': matrix_records,
                'independent_package_check': package_check,
                'validator_source_sha256': digest_file(Path(__file__)),
                'validator_version': 1,
                'cost_seconds': {'cold_independent_package_check': package_seconds,
                                 'cold_identity_hash_and_package_check': hash_seconds,
                                 'cold_scale_scan': scan_seconds,
                                 'cold_total': time.perf_counter() - started}}
    finally:
        for mapping in bo_maps.values(): mapping.close()
        for handle in bo_files: handle.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    result = validate(args.package.resolve())
    args.out.parent.mkdir(parents=True, exist_ok=True)
    data = (json.dumps(result, indent=2, sort_keys=True) + '\n').encode()
    args.out.write_bytes(data)
    print(json.dumps({'record': str(args.out.resolve()), 'record_sha256': digest_bytes(data),
                      'matrix_count': result['q8_matrix_count'],
                      'half_count': result['scale_halves_checked']}))


if __name__ == '__main__':
    main()
