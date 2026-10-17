#!/usr/bin/env python3
"""Seal the selected immutable compiled XSim snapshot files for phase reuse."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys


def identity(path: Path) -> dict:
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            h.update(block)
    return {'path': str(path), 'bytes': path.stat().st_size, 'sha256': h.hexdigest()}


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit('usage: make_compile_identity.py BUILD_DIR PREPARED_DIR')
    build, prepared = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
    output = build / 'compile_identity.json'
    if output.exists():
        raise SystemExit('fresh compile identity required')
    chosen = [
        build / 'xvlog.log', build / 'xelab.log', build / 'xvlog.pb',
        build / 'xelab.pb', build / 'xsim.dir/ws_capacity_static/xsimk',
        build / 'xsim.dir/ws_capacity_static/Compile_Options.txt',
        build / 'xsim.dir/ws_capacity_static/xsim.version',
        prepared / 'preparation.json', prepared / 'ws_capacity_top.sv',
        *(prepared / f'bank_{i}.v' for i in range(8))]
    if any(not path.is_file() for path in chosen):
        raise SystemExit('compiled/prepared identity file missing')
    report = {'schema': 'ws_capacity_compiled_snapshot_identity_v1',
              'files': [identity(path) for path in chosen]}
    output.write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
    print(f'WS_CAPACITY_COMPILE_IDENTITY files={len(chosen)}')


if __name__ == '__main__':
    main()
