#!/usr/bin/env python3
"""Reproduce the isolated 13-port pilot from the current memory functions."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = ROOT / "hls/common/laya_full_memory.cpp"
EXPECTED_SOURCE_SHA256 = (
    "00b4374c6418ea939a44b9c8e358305eba4e9e7b87fb90f54b26caf63873e861")
FUNCTIONS = ("bad_bo", "present", "capacity", "full_span", "full_read")
PORTS = (
    ("embedding", "EMBEDDING", True), ("io", "IO", False),
    ("w_q0", "W_Q0", True), ("w_q1", "W_Q1", True),
    ("w_scale", "W_SCALE", True), ("aux", "AUX", True),
    ("state0", "STATE0", False), ("state1", "STATE1", False),
    ("qkv0", "QKV0", False), ("qkv1", "QKV1", False),
    ("ff0", "FF0", False), ("ff1", "FF1", False),
    ("att_out", "ATT_OUT", False),
)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def extract(source: str, name: str) -> tuple[str, int, int]:
    import re

    matches = list(re.finditer(
        rf"(?m)^(?:Check|bool|uint64_t) {name}\(", source))
    if len(matches) != 1:
        raise AssertionError(f"expected one {name} definition")
    start = matches[0].start()
    opening = source.index("{", start)
    depth = 0
    end = opening
    for end in range(opening, len(source)):
        if source[end] == "{":
            depth += 1
        elif source[end] == "}":
            depth -= 1
            if depth == 0:
                end += 1
                break
    else:
        raise AssertionError(f"unclosed {name}")
    fragment = source[start:end] + "\n"
    return (fragment, source.count("\n", 0, start) + 1,
            source.count("\n", 0, end) + 1)


def main() -> None:
    source_bytes = SOURCE.read_bytes()
    if sha256(source_bytes) != EXPECTED_SOURCE_SHA256:
        raise AssertionError("production memory source changed since pilot design")
    source = source_bytes.decode()
    functions = {}
    records = {}
    for name in FUNCTIONS:
        fragment, first, last = extract(source, name)
        functions[name] = fragment
        records[name] = {"source_lines": [first, last],
                         "sha256": sha256(fragment.encode()),
                         "bytes": len(fragment.encode())}

    lines = ['#include "laya_full_runtime.h"', '',
             'namespace laya::full {', 'namespace {',
             functions['bad_bo'], functions['present'],
             functions['capacity'], '} // namespace', '',
             functions['full_span'], functions['full_read'],
             '} // namespace laya::full', '',
             'extern "C" void axi_base_zero_pilot(']
    args = [f"{'const ' if readonly else ''}uint8_t* {name}"
            for name, _, readonly in PORTS]
    lines.append('    ' + ',\n    '.join(args) + ') {')
    lines.append('#ifdef __SYNTHESIS__')
    for name, _, readonly in PORTS:
        extra = '' if readonly else ' num_write_outstanding=1'
        lines.append(f'#pragma HLS INTERFACE m_axi port={name} '
                     f'offset=slave bundle={name} max_widen_bitwidth=512 '
                     f'num_read_outstanding=1{extra}')
    lines.extend(['#pragma HLS INTERFACE s_axilite port=return bundle=control',
                  '#endif', '  laya::full::FullMemory memory{};'])
    for name, _, _ in PORTS:
        lines.append(f'  memory.{name} = {name};')
        lines.append(f'  memory.{name}_bytes = 4096;')
    lines.extend(['  uint8_t observed[13] = {};',
                  '  uint16_t status[13] = {};'])
    for index, (_, bo, _) in enumerate(PORTS):
        lines.append('  status[' + str(index) + '] = uint16_t('
                     'laya::full::full_read(memory, laya::Bo::' + bo +
                     ', 0, &observed[' + str(index) + '], 1).code);')
    lines.extend([
        '  for (unsigned i = 0; i < 13; ++i) {',
        '    const unsigned at = 2048 + 4 * i;',
        '    io[at] = uint8_t(status[i]);',
        '    io[at + 1] = uint8_t(status[i] >> 8);',
        '    io[at + 2] = observed[i];',
        '    io[at + 3] = 0xa5;',
        '  }',
        '}',
        '',
    ])
    output = ('\n'.join(lines)).encode()
    (HERE / 'pilot.cpp').write_bytes(output)
    manifest = {
        'production_source': str(SOURCE),
        'production_source_sha256': sha256(source_bytes),
        'fragments': records,
        'pilot_source_sha256': sha256(output),
        'port_order': [name for name, _, _ in PORTS],
        'diagnostic_base': 2048,
        'diagnostic_stride': 4,
    }
    (HERE / 'extraction_manifest.json').write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + '\n')
    print('PILOT_EXTRACT_PASS source=' + manifest['pilot_source_sha256'])


if __name__ == '__main__':
    main()
