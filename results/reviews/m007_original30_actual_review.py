"""Controller-only byte/coordinate audit of saved actual RTL layer captures.

Never produces a DUT input or floating-point reference. A layer verdict is
scoped to its saved complete capture; it cannot certify the full request.
"""
import argparse
import hashlib
import json
import time
from datetime import datetime, timezone
from pathlib import Path


def sha(data):
    return hashlib.sha256(data).hexdigest()


def audit(root, work):
    binding = root / ('project/E016_m007_single_resource_parent/experiment_results/'
                      'runs/R007/attempts/AT044_original47_fullgraph_byte_binding/'
                      'work/fixture/manifest.json')
    manifest_bytes = binding.read_bytes()
    manifest = json.loads(manifest_bytes)
    refs = {r['name']: r for r in manifest['original_checkpoints_47']}
    result = {'scope': 'saved actual layer captures, not full-request verdict',
              'work': str(work), 'binding_sha256': sha(manifest_bytes),
              'checked_utc': datetime.now(timezone.utc).isoformat(), 'layers': []}
    for layer in range(30):
        base = work / f'actual_fullgraph.layer{layer}'
        metadata_path = Path(str(base) + '.capture.json')
        if not metadata_path.exists():
            continue
        metadata = json.loads(metadata_path.read_text())
        if not metadata.get('complete'):
            continue
        assert metadata['global_layer'] == layer
        assert metadata['accepted_groups32'] == metadata['unique_groups32'] == 4096
        assert metadata['bytes'] == 524288
        actual_path = Path(str(base) + '.f32.bin')
        trace_path = Path(str(base) + '.accepted.jsonl')
        actual = actual_path.read_bytes()
        name = f'encoder_{layer:02d}_out' if layer < 28 else f'decision_{layer-28:02d}_out'
        reference = (root / refs[name]['path']).read_bytes()
        assert len(actual) == len(reference) == 524288
        assert sha(reference) == refs[name]['sha256'], ('reference identity', layer)
        assert actual == reference, ('actual/reference mismatch', layer)
        trace_bytes = trace_path.read_bytes()
        restored = bytearray(524288)
        seen, previous_cycle = set(), -1
        records = trace_bytes.splitlines()
        assert len(records) == 4096, ('trace count', layer)
        for seq, line in enumerate(records):
            record = json.loads(line)
            address = record['address']
            assert record['global_layer'] == layer
            assert record['accept_seq'] == seq
            assert isinstance(address, int) and 0 <= address < 4096
            assert address not in seen
            assert record['cycle'] > previous_cycle
            payload = record['data_hex_lane0_lsb']
            assert len(payload) == 256
            restored[address * 128:(address + 1) * 128] = int(payload, 16).to_bytes(128, 'little')
            seen.add(address)
            previous_cycle = record['cycle']
        assert seen == set(range(4096))
        assert restored == actual, ('actual interface trace mismatch', layer)
        result['layers'].append({'global_layer': layer, 'verdict': 'CAPTURE_PASS',
            'reference': refs[name]['path'], 'sha256': sha(actual), 'bytes': len(actual),
            'actual': str(actual_path), 'trace_sha256': sha(trace_bytes),
            'accepted_unique_groups': len(seen), 'capture_cycle': metadata['logical_cycle']})
    result['complete_layer_captures_verified'] = len(result['layers'])
    result['full_request_verdict'] = 'NOT_ASSESSED_BY_THIS_SCRIPT'
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--work', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    started = time.monotonic()
    project_root = Path(__file__).resolve().parents[2]
    review = audit(project_root, args.work.resolve())
    review['review_wall_s'] = time.monotonic() - started
    args.output.write_text(json.dumps(review, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({'verified_layers': [r['global_layer'] for r in review['layers']],
                      'wall_s': review['review_wall_s'], 'output': str(args.output)}))
