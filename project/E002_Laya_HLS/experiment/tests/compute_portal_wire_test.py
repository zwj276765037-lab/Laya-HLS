#!/usr/bin/env python3
"""Independent literal byte-level v2 oracle for all four services."""
import argparse
from pathlib import Path
import re
import struct


ROOT = Path(__file__).resolve().parents[1]


def generated_values():
    text = (ROOT / 'build/model-repair/laya_model_layout_generated.h').read_text()

    def array(name, count):
        match = re.search(rf'\b{name}\s*\[{count}\]\s*=\s*\{{([^}}]+)\}}', text)
        assert match, name
        values = [int(token, 0) for token in re.findall(r'0x[0-9a-fA-F]+|\d+', match.group(1))]
        assert len(values) == count and all(value <= 255 for value in values), name
        return bytes(values)

    match = re.search(r'\bkFullModelBoSizes\s*\[5\]\s*=\s*\{([^}]+)\}', text)
    assert match
    sizes = [int(token, 0) for token in re.findall(r'0x[0-9a-fA-F]+|\d+', match.group(1))]
    assert len(sizes) == 5
    tags = [array('kFullModelTag', 16), array('kFullNumericTag', 16),
            array('kFullLayoutTag', 16), array('kFullBuildTag', 16)]
    source = array('kFullSourceSha256', 32)

    model_identity = bytearray(416)
    for index, tag in enumerate(tags): model_identity[16*index:16*(index+1)] = tag
    struct.pack_into('<IHHII', model_identity, 64, 0x4d33314c, 1, 416, 0, 1)
    model_identity[80:112] = source
    struct.pack_into('<III', model_identity, 112, 5, 16, 128)
    for index, (role, size) in enumerate(zip((0, 2, 3, 4, 5), sizes)):
        struct.pack_into('<IIQ', model_identity, 128 + 16*index, role, 1, size)

    aux = bytearray(128)
    struct.pack_into('<4sHHIII', aux, 0, b'LYMP', 1, 0, 128, 13, 1)
    for index, tag in enumerate(tags): aux[32+16*index:48+16*index] = tag
    aux[96:128] = source
    return tags, bytes(model_identity), bytes(aux)


TAGS, MODEL_IDENTITY_BYTES, AUX_HEADER_BYTES = generated_values()


def fixture(service):
    command = bytearray(1024)
    task = {1: 0x12345678, 2: 0x12345671, 3: 0x12345678, 4: 0x12345670}[service]
    struct.pack_into('<IHHQI', command, 0, 0x3150434c, 2, service, 0x8877665544332211, task)
    struct.pack_into('<HH', command, 24, 16, 8)
    identity = struct.pack('<QQHH', 0x0123456789abcdef, 0x1020304050607080, 2, 128)
    identity += b''.join(TAGS)
    producer = struct.pack('<IBBBBBHB', 0x12345670, 0x60, 2, 27, 1, 0, 7, 16)
    quant = struct.pack('<IBBBBBHB', 0x12345671, 0x20, 2, 27, 1, 0, 7, 16)
    linear = struct.pack('<IBBBBBHB', 0x12345678, 0x33, 2, 27, 1, 0, 7, 16)
    context = {1: struct.pack('<IBBBBBHB', task, 0x80, 2, 27, 0, 2, 0, 1),
               2: quant, 3: linear, 4: producer}[service]
    refs = [(9, 7, 0, 0), (10, 0x22, 0, 0), (11, 0x23, 1, 0), (12, 0x24, 0, 0), (13, 10, 0, 3)]
    if service == 1:
        refs = [(0, 0, 0, 0), (0, 0, 0, 0), (11, 0x23, 1, 0), (0, 0, 0, 0), (0, 0, 0, 0)]
    elif service == 2:
        refs[4] = refs[1]
    elif service == 4:
        refs[0] = (8, 6, 0, 0); refs[4] = (9, 7, 0, 0)
    refs = b''.join(struct.pack('<IBBBB', epoch, buffer, bank, region, 0) for epoch, buffer, bank, region in refs)
    command[64:148] = identity; command[148:160] = context; command[160:200] = refs
    command[200:616] = MODEL_IDENTITY_BYTES
    rows = {1: 0, 2: 16, 3: 4, 4: 16}[service]; block = 8 if service == 3 else 0
    a_epoch = 0 if service == 1 else 10
    out0 = {1: 0, 2: 0, 3: 7, 4: 11}[service]; source_role = {1: 0, 2: 11, 3: 0, 4: 10}[service]
    struct.pack_into('<HHBBBBIIHBBBB', command, 616, 2624, 1024, rows, block, 0, 1, a_epoch, 11, 0x1b04, 1, out0, 0, source_role)
    if service in (3, 4):
        struct.pack_into('<QQQ', command, 640, 0x1234567800000000, 0x1122334455667700, 0x1020304050607000)
    if service == 3: struct.pack_into('<QQ', command, 688, 4096, 4194304)
    if service in (2, 4):
        struct.pack_into('<QQ', command, 688, 10496, 10747904)
        struct.pack_into('<QQQ', command, 904, 0x9000, 0x10000 if service == 2 else 0x20000, 10496 if service == 2 else 20992)
    if service == 1:
        for i in range(3): struct.pack_into('<QQ', command, 704 + 16*i, 0x12340000 + 0x10000*i, 0x80000 + 0x40000*i)
        command[752:880] = AUX_HEADER_BYTES
        struct.pack_into('<QQI', command, 880, 0x100, 0x200, 4096)
    else:
        command[928:940] = producer; command[940:952] = quant; command[952:964] = linear
        struct.pack_into('<IBBBB', command, 964, 13, 10, 0, 3, 0)
    response = bytearray(512)
    elements = {1: 2854912, 2: 1312, 3: 4096, 4: 41984}[service]
    struct.pack_into('<IHHQIIQQI', response, 0, 0x3152434c, 2, 0, 0x8877665544332211, task, 0, 2**64-1, 2**64-1, elements)
    response[44:46] = bytes([{1: 3, 2: 2, 3: 1, 4: 1}[service], 3])
    struct.pack_into('<Q', response, 48, 0x0a0b0c0d0e0f1011)
    struct.pack_into('<14I', response, 64, *(0x10203040+i for i in range(14)))
    response[128:212] = identity; response[212:224] = context; response[224:264] = refs
    struct.pack_into('<II', response, 264, a_epoch, 11)
    response[272:316] = command[928:972]
    struct.pack_into('<BBH', response, 316, rows, block, service)
    return command, response


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('work', type=Path)
    work = parser.parse_args().work
    for service in range(1, 5):
        command, response = fixture(service)
        for kind, data, size in [('command', command, 1024), ('response', response, 512)]:
            assert (work / f'{service}_{kind}.bin').read_bytes() == data, (service, kind)
            encoded = ''.join(data[i:i+64][::-1].hex() + '\n' for i in range(0, size, 64))
            (work / f'{service}_{kind}.hex').write_text(encoded)
            if service == 3:
                assert (work / f'{kind}.bin').read_bytes() == data
                (work / f'{kind}.hex').write_text(encoded)
    print('FULL_CURRENT_PORTAL_WIRE_PASS version=2 services=4 independent_bytes=6144')


if __name__ == '__main__': main()
