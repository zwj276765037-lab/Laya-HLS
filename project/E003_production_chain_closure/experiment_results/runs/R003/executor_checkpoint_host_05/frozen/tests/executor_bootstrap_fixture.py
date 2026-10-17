#!/usr/bin/env python3
"""Literal-byte LBS1/LBR1 and real LYRQ fixtures from the selected model tags."""
import argparse
from pathlib import Path
import re
import struct


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model-header', type=Path, required=True)
    ap.add_argument('--model-aux', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    args = ap.parse_args()
    args.output.mkdir(exist_ok=False)
    text = args.model_header.read_text()
    def array(name, count):
        m = re.search(r'\b' + name + r'\[' + str(count) + r'\]\s*=\s*\{([^}]+)\}', text)
        assert m, name
        values = [int(x, 0) for x in re.findall(r'0x[0-9a-fA-F]+|\d+', m.group(1))]
        assert len(values) == count
        return values
    tags = b''.join(bytes(array('kFull' + n + 'Tag', 16))
                    for n in ['Model', 'Numeric', 'Layout', 'Build'])
    source = bytes(array('kFullSourceSha256', 32))
    sizes = array('kFullModelBoSizes', 5)
    model = bytearray(416)
    model[:64] = tags
    struct.pack_into('<IHHII', model, 64, 0x4d33314c, 1, 416, 0, 1)
    model[80:112] = source
    struct.pack_into('<III', model, 112, 5, 16, 128)
    for index, (role, size) in enumerate(zip([0, 2, 3, 4, 5], sizes)):
        struct.pack_into('<IIQ', model, 128 + 16 * index, role, 1, size)
    aux = args.model_aux.open('rb').read(128)
    expected_aux = bytearray(128)
    struct.pack_into('<4sHHIII', expected_aux, 0, b'LYMP', 1, 0, 128, 13, 1)
    expected_aux[32:96] = tags; expected_aux[96:128] = source
    assert aux == expected_aux
    identity = struct.pack('<QQHH', 1101, 51, 1, 64) + tags
    request = bytearray(768)
    struct.pack_into('<IHHH', request, 0, 0x3153424c, 1, 12, 1)
    struct.pack_into('<Q', request, 16, 1)
    struct.pack_into('<QQQ', request, 40, 7, 0x1200000000, 16920576)
    request[64:148] = identity; request[160:576] = model
    struct.pack_into('<IBBBB', request, 576, 1, 1, 0, 0, 0)
    request[592:596] = bytes([2, 0, 255, 0])
    struct.pack_into('<HHHBBB', request, 596, 0, 64, 1024, 1, 0, 6)
    struct.pack_into('<7Q', request, 608, 16920576, 0, 4096,
                     4194304, 262144, 0, 0)
    response = bytearray(request)
    struct.pack_into('<I', response, 0, 0x3152424c)
    struct.pack_into('<I', response, 12, 63)
    struct.pack_into('<Q', response, 32, (1 << 64) - 1)
    # Original LYRQ ABI, B1/S64. All five payload arrays are actually checked
    # by the DUT parser; this fixture is unrelated to the snapshot wire bytes.
    lyrq = bytearray(320)
    struct.pack_into('<4sHHHHHHIHHQQ', lyrq, 0, b'LYRQ', 1, 0,
                     128, 32, 5, 0, 832, 1, 64, 1101, 51)
    lyrq[40:104] = tags
    struct.pack_into('<4I', lyrq, 104, 128, 320, 16384, 4096)
    payloads = [struct.pack('<64i', *range(64)), bytes([1] * 64),
                struct.pack('<16i', *range(16)), bytes([1] * 16), struct.pack('<i', 1)]
    offset = 320
    for i, payload in enumerate(payloads):
        stride0 = [256, 64, 64, 16, 4][i]
        stride1 = [4, 1, 4, 1, 0][i]
        struct.pack_into('<HBBIIHHIIII', lyrq, 128 + i * 32,
                         i + 1, 2 if i in [1, 3] else 1, 1 if i == 4 else 2,
                         offset, len(payload), 1, 64 if i < 2 else 1 if i == 4 else 16,
                         stride0, stride1, 64 if i < 2 else 1 if i == 4 else 16, 0)
        lyrq.extend(payload); lyrq.extend(bytes((-len(lyrq)) % 64)); offset = len(lyrq)
    assert len(lyrq) == 832
    for name, data in [('snapshot_request', request), ('snapshot_response', response),
                       ('request', lyrq), ('aux_header', aux)]:
        (args.output / (name + '.bin')).write_bytes(data)
        (args.output / (name + '.hex')).write_text(''.join(
            data[i:i+64][::-1].hex() + '\n' for i in range(0, len(data), 64)))
    print('FULL_CURRENT_EXECUTOR_BOOTSTRAP_FIXTURE_PASS snapshot_bytes=1536 lyrq_bytes=832 real_aux=128')

if __name__ == '__main__':
    main()
