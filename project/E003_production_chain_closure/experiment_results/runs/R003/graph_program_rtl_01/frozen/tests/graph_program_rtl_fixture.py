#!/usr/bin/env python3
"""Independent explicit-byte fixtures for the finite generated program top."""
import argparse
import json
from pathlib import Path
import re
import struct

def put(p, off, fmt, value):
    struct.pack_into('<' + fmt, p, off, value)

def identity(p, request_id, tags):
    put(p, 64, 'Q', request_id)
    put(p, 72, 'Q', request_id + 1)
    put(p, 80, 'H', 1); put(p, 82, 'H', 64)
    p[84:148] = tags

def owner(p, off, buffer_id=0, epoch=0, stage=0, layer=255, rows=0):
    put(p, off, 'I', epoch)
    p[off+4] = buffer_id
    p[off+8:off+12] = bytes([stage, layer, 255, 0])
    put(p, off+14, 'H', rows)
    put(p, off+16, 'H', 1024 if buffer_id else 0)
    p[off+18] = 1 if buffer_id else 0

def program_header(magic):
    p = bytearray(256)
    put(p, 0, 'I', magic); put(p, 4, 'H', 1); put(p, 6, 'H', 4)
    p[8] = 1
    return p

def action_header(magic, beats, request_id, ordinal, tags):
    p = bytearray(beats * 64)
    put(p, 0, 'I', magic); put(p, 4, 'H', 1); put(p, 6, 'H', beats)
    p[8:13] = bytes([2, 0, 0x11, 2, 1])
    put(p, 24, 'Q', ordinal); identity(p, request_id, tags)
    return p

def command(request_id, tags):
    p = program_header(0x3150474c)
    put(p, 16, 'I', 1); identity(p, request_id, tags)
    put(p, 160, 'Q', 1); owner(p, 168, 1, 1, 2, 0, 64)
    if request_id == 903: p[0] ^= 0x80
    return p

def action_request(request_id, ordinal, tags):
    p = action_header(0x3158414c, 8, request_id, ordinal, tags)
    put(p, 168, 'Q', 1); owner(p, 176, 1, 1, 2, 0, 64)
    p[224:228] = bytes([1, 2, 0, 0]); put(p, 232, 'Q', 1)
    p[257] = 255
    return p

def completion(request_id, ordinal, tags):
    p = action_header(0x3143414c, 4, request_id, ordinal, tags)
    put(p, 16, 'I', 0x0f if request_id == 902 else 0x3f)
    put(p, 156, 'Q', (1 << 64) - 1); owner(p, 192)
    if request_id == 902:
        put(p, 148, 'H', 5); put(p, 152, 'I', 0x04020009)
    else:
        put(p, 164, 'I', 1); put(p, 168, 'I', 4); put(p, 172, 'H', 4)
        p[176] = 1; put(p, 184, 'Q', 1); owner(p, 192, 2, 1, 2, 1, 64)
    return p

def result(request_id, ordinal, tags):
    p = program_header(0x3152474c)
    put(p, 156, 'Q', (1 << 64) - 1); owner(p, 192)
    if request_id == 903:
        put(p, 16, 'I', 0x2d); put(p, 148, 'H', 7)
        put(p, 152, 'I', 0x0700000e)
        return p
    identity(p, request_id, tags); put(p, 24, 'Q', ordinal)
    if request_id == 902:
        put(p, 16, 'I', 0x0f); put(p, 148, 'H', 5)
        put(p, 152, 'I', 0x04020009)
    else:
        p[9] = 1; put(p, 16, 'I', 0x1f)
        p[176] = 1; put(p, 184, 'Q', 1); owner(p, 192, 2, 1, 2, 1, 64)
    return p

def hex_file(path, packets):
    path.write_text(''.join(bytes(p[b:b+64])[::-1].hex() + '\n'
                            for p in packets for b in range(0, len(p), 64)))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model-header', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args(); args.output.mkdir(exist_ok=False)
    header = args.model_header.read_text(); tags = bytearray()
    for name in ['Model', 'Numeric', 'Layout', 'Build']:
        match = re.search(r'kFull' + name + r'Tag\[16\]\s*=\s*\{([^}]+)\}', header)
        assert match
        tag = bytes(int(x, 16) for x in re.findall(r'0x([0-9a-fA-F]+)', match.group(1)))
        assert len(tag) == 16; tags += tag
    ids = [901, 902, 903, 904]; ordinals = [1, 2, 0, 3]
    hex_file(args.output/'commands.hex', [command(i, tags) for i in ids])
    hex_file(args.output/'actions.hex', [action_request(i, o, tags)
              for i, o in zip(ids, ordinals) if o])
    hex_file(args.output/'completions.hex', [completion(i, o, tags)
              for i, o in zip(ids, ordinals) if o])
    hex_file(args.output/'results.hex', [result(i, o, tags) for i, o in zip(ids, ordinals)])
    (args.output/'fixture.json').write_text(json.dumps({
        'schema': 'laya-graph-program-independent-rtl-fixture-v1',
        'commands': ids, 'ordinals': ordinals, 'command_beats': 16,
        'action_beats': 24, 'completion_beats': 12, 'result_beats': 16,
        'scope': 'explicit byte encoding from fixed schema; controlled safe LAC1 fixtures; no arithmetic or physical source proof'}, indent=2)+'\n')
    print('FULL_CURRENT_GRAPH_PROGRAM_RTL_FIXTURE_PASS')

if __name__ == '__main__': main()
