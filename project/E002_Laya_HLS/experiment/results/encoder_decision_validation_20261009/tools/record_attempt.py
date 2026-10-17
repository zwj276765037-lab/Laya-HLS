#!/usr/bin/env python3
"""Snapshot mutable inputs and hash all explicit source/fixture paths before a run."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tarfile
from datetime import datetime, timezone

out = Path(sys.argv[1]).resolve()
paths = [Path(p).resolve() for p in sys.argv[2:]]
out.mkdir(parents=True, exist_ok=True)
files = []
for root in paths:
    if not root.exists():
        raise SystemExit(f"missing input {root}")
    candidates = [root] if root.is_file() else sorted(p for p in root.rglob('*') if p.is_file())
    for path in candidates:
        digest = hashlib.sha256()
        with path.open('rb') as stream:
            for chunk in iter(lambda: stream.read(1 << 20), b''):
                digest.update(chunk)
        files.append({'path': str(path), 'bytes': path.stat().st_size,
                      'sha256': digest.hexdigest()})
stage = Path(__file__).resolve().parents[1]
with tarfile.open(out/'mutable_source_snapshot.tar.gz', 'w:gz') as archive:
    for relative in ('tb', 'rtl', 'source', 'tools'):
        path = stage/relative
        if path.exists():
            archive.add(path, arcname=relative, recursive=True)
manifest = {'schema': 'offline_validation_attempt_inputs_v1',
            'captured_utc': datetime.now(timezone.utc).isoformat(),
            'tool': '/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin',
            'inputs': files,
            'mutable_snapshot_sha256': hashlib.sha256((out/'mutable_source_snapshot.tar.gz').read_bytes()).hexdigest()}
(out/'input_manifest.json').write_text(json.dumps(manifest, indent=2, sort_keys=True)+'\n')
