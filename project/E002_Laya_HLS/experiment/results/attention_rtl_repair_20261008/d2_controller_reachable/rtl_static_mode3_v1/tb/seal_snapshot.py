#!/usr/bin/env python3
"""Record an exact compiled XSim snapshot after a separately released build."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            h.update(block)
    return h.hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('snapshot_root', type=Path)
    ap.add_argument('output', type=Path)
    args = ap.parse_args()
    root = args.snapshot_root.resolve(strict=True)
    if root.name != 'xsim.dir' or not (root / 'vector_mode3_static').is_dir():
        raise ValueError('compiled snapshot root')
    if args.output.exists():
        raise FileExistsError(args.output)
    files = {}
    for path in sorted(root.rglob('*')):
        if path.is_file():
            rel = str(path.relative_to(root))
            files[rel] = {'bytes': path.stat().st_size, 'sha256': sha(path)}
    if not files:
        raise ValueError('empty snapshot')
    output = {'schema': 'd2_i_mode3_compiled_snapshot_manifest_v1',
              'snapshot_root': str(root), 'file_count': len(files), 'files': files}
    args.output.write_text(json.dumps(output, indent=2, sort_keys=True) + '\n')
    print('D2_MODE3_SNAPSHOT_SEALED files=', len(files))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
