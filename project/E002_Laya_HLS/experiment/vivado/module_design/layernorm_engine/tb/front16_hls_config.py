#!/usr/bin/env python3
"""Write reproducible independent HLS configurations for the two fixed tops."""
import hashlib
import json
from pathlib import Path
import sys

BASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline')
MODULE = BASE / 'vivado/module_design/layernorm_engine'
SOURCES = [MODULE / 'source/front16.cpp',
           BASE / 'hls/operators/layernorm_compute.cpp',
           BASE / 'hls/common/laya_numeric.cpp']
HEADERS = [MODULE / 'source/front16.h', *sorted((BASE / 'include').glob('*.h'))]


def main():
    assert len(sys.argv) == 2 and sys.argv[1] in ('byte', 'wide')
    mode = sys.argv[1]
    out = MODULE / 'rtl' / f'front16_{mode}'
    out.mkdir(exist_ok=True)
    config = out / 'front16.cfg'
    cfg = [
        'part=xcu55c-fsvh2892-2L-e', 'freqhz=150000000', '[hls]',
        'flow_target=vivado', f'syn.top=laya_front16_{mode}',
        'syn.compile.pipeline_loops=0',
        'syn.array_partition.throughput_driven=off',
        'syn.array_partition.complete_threshold=0',
        *(f'syn.file={p}' for p in SOURCES),
        f'syn.cflags=-I{BASE}/include -I{MODULE}/source -std=c++17 '
        '-fno-fast-math -ffp-contract=off',
    ]
    config.write_text('\n'.join(cfg) + '\n')
    files = [*SOURCES, *HEADERS, config, MODULE / 'tb/front16_hls_config.py']
    digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    (out / 'source_manifest.json').write_text(json.dumps({
        'top': f'laya_front16_{mode}', 'part': 'xcu55c-fsvh2892-2L-e',
        'frequency_hz': 150000000,
        'inputs': [{'path': str(p), 'bytes': p.stat().st_size, 'sha256': digest(p)}
                   for p in files]}, indent=2) + '\n')
    print(config)


if __name__ == '__main__':
    main()
