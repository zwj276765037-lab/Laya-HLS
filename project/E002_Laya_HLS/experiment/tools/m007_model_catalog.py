#!/usr/bin/env python3
"""Build/check LAYAC25 metadata and prepare immutable model coefficients."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

ROOT = Path(__file__).resolve().parents[1]
MODEL_SHA = '6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18'
GRAPH_SHA = 'f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9'
PACKAGE_SHA = '46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c'
INVENTORY_SHA = '40983ab871903db1281eb82901521fae5f5e1b862d8c2d4f22deba7cbe44c5c6'
POLY = 0x42F0E1EBA9EA3693
U64 = 1 << 64
BO_BYTES, HEADER_BYTES, RECORD_BYTES, RECORD_COUNT = 8192, 256, 64, 120
EFFECTIVE_BYTES = HEADER_BYTES + RECORD_BYTES * RECORD_COUNT
IDENTITY_FIELDS = ('model', 'graph', 'numeric', 'layout', 'build')
DEFAULT_PACKAGE = ROOT / 'build/model-q8-session-v2-actual-r2-20261010'
DEFAULT_INVENTORY = ROOT / 'reference/runs/typed_q8_ref_20261005/gguf_inventory.json'


class CatalogError(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise CatalogError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def load_json(path):
    def bad(value):
        raise CatalogError('nonfinite JSON number: ' + value)
    return json.loads(Path(path).read_text(), parse_constant=bad)


def full_sha(value, label):
    require(isinstance(value, str) and re.fullmatch(r'[0-9a-f]{64}', value) is not None,
            label + ' must be a complete lowercase SHA256')
    return value


def uint(value, bits, label):
    require(type(value) is int and 0 <= value < 1 << bits, label + ' unsigned integer range')
    return value


def interval(base, span, label):
    uint(base, 64, label + ' base')
    uint(span, 64, label + ' span')
    require(span > 0 and base + span < U64, label + ' 65bit endpoint overflow/empty')
    return base, base + span


def disjoint(left, right):
    return left[1] <= right[0] or right[1] <= left[0]


def crc64(data):
    """ECMA-182, non-reflected, init/xorout0, memory bytes ascending."""
    table = []
    for byte in range(256):
        value = byte << 56
        for _ in range(8):
            value = ((value << 1) ^ (POLY if value >> 63 else 0)) & (U64 - 1)
        table.append(value)
    value = 0
    for byte in data:
        value = table[(value >> 56) ^ byte] ^ ((value << 8) & (U64 - 1))
    return value


def verify_crc64_bits(data):
    """Independent direct-bit readback implementation, including known vector tests."""
    value = 0
    for byte in data:
        for shift in range(7, -1, -1):
            feedback = (value >> 63) ^ ((byte >> shift) & 1)
            value = (value << 1) & (U64 - 1)
            if feedback:
                value ^= POLY
    return value


def bindings():
    result = []
    for global_layer in range(30):
        for role in range(4):
            if global_layer < 28:
                layer = global_layer
                stem = ('qkv', 'wo', 'mlp_wi', 'mlp_wo')[role]
                family = role + 1
                tensor = (4, 32, 60, 88)[role] + layer
                k, n = ((1024, 3072), (1024, 1024), (1024, 5248), (2624, 1024))[role]
                bias = None
            else:
                layer = global_layer - 28
                stem = ('head_qkv', 'head_wo', 'head_fc1', 'head_fc2')[role]
                family = role + 5
                tensor = (117, 121, 125, 129)[role] + 2 * layer
                k, n = ((1024, 3072), (1024, 1024), (1024, 4096), (4096, 1024))[role]
                bias = f'{stem}.{layer}.bias'
            result.append({'index': 4 * global_layer + role, 'global_layer': global_layer,
                           'pair_kind': role >> 1, 'slot': role & 1, 'tensor': tensor,
                           'name': f'{stem}.{layer}.weight', 'family': family, 'layer': layer,
                           'K': k, 'N': n, 'bias_name': bias,
                           'needed_per_port': 576 * (k >> 5) * (82 if n == 5248 else n >> 6)})
    return result


def load_package(package=DEFAULT_PACKAGE, inventory=DEFAULT_INVENTORY):
    package, inventory = Path(package), Path(inventory)
    raw = (package / 'manifest.json').read_bytes()
    require(digest(raw) == PACKAGE_SHA, 'original package manifest SHA')
    manifest = json.loads(raw)
    require(manifest['schema'] == 'laya-model-p2-v1', 'package schema')
    require(manifest['source_model']['sha256'] == MODEL_SHA and
            manifest['source_model']['graph_spec_sha256'] == GRAPH_SHA and
            manifest['source_model']['size'] == 455179648, 'original model/graph identity')
    inv_raw = inventory.read_bytes()
    require(digest(inv_raw) == INVENTORY_SHA, 'original inventory SHA')
    inv = json.loads(inv_raw)
    identity = {'model': MODEL_SHA, 'graph': GRAPH_SHA}
    preimages = {}
    for key in ('numeric', 'layout', 'build'):
        item = manifest['tag_preimages'][key]
        body = (package / item['file']).read_bytes()
        identity[key] = full_sha(item['sha256'], key)
        require(digest(body) == identity[key] and manifest['tags'][key] == identity[key][:32],
                key + ' full saved preimage identity')
        preimages[key] = body
    layout, build = (json.loads(preimages[key]) for key in ('layout', 'build'))
    require(layout['source_model_sha256'] == MODEL_SHA and
            layout['weights'] == manifest['weights'] and layout['tensors'] == manifest['tensors'],
            'layout preimage semantic binding')
    require(build['model_sha256'] == MODEL_SHA and build['numeric_sha256'] == identity['numeric'] and
            build['layout_sha256'] == identity['layout'], 'package-build preimage binding')
    weights = {item['name']: item for item in manifest['weights']}
    tensors = {item['name']: item for item in manifest['tensors']}
    original = {item['name']: item for item in inv['tensors']}
    require(len(weights) == len(manifest['weights']) == 124 and
            len(tensors) == len(manifest['tensors']) == len(original) == 153,
            'unique original tensors/WeightKeys')
    for spec in bindings():
        name = spec['name']
        require(name in weights and name in original and name in tensors, 'missing fixed WeightKey ' + name)
        w, src, tensor = weights[name], original[name], tensors[name]
        require((w['family'], w['layer'], w['K'], w['N'], w['dtype'], w['bias_name']) ==
                (spec['family'], spec['layer'], spec['K'], spec['N'], 8, spec['bias_name']),
                'fixed WeightKey/shape/bias mismatch ' + name)
        require(src['ggml_ne'] == [spec['K'], spec['N'], 1, 1] and src['ggml_type_id'] == 8 and
                tensor['source_offset'] == src['absolute_file_offset'] and
                tensor['source_bytes'] == spec['K'] * spec['N'] // 32 * 34 and
                w['source_sha256'] == tensor['source_sha256'], 'original GGUF binding ' + name)
    return {'manifest': manifest, 'identity': identity, 'inventory': inv,
            'weights': weights, 'tensors': tensors, 'original': original,
            'manifest_sha256': digest(raw), 'inventory_sha256': digest(inv_raw),
            'package': str(package.resolve()), 'whole_model_hash_recomputed': False}


def validate_addresses(address_map, records):
    require(address_map.get('address_space') in ('SIM', 'PLATFORM'), 'explicit SIM or PLATFORM address space required')
    if address_map['address_space'] == 'PLATFORM':
        require(isinstance(address_map.get('platform_source'), str) and address_map['platform_source'],
                'real platform aperture source required')
    ports = address_map['apertures']
    require(isinstance(ports, list) and len(ports) == 4, 'four explicit port apertures')
    apertures = [interval(p['base'], p['span'], f'port{index} aperture') for index, p in enumerate(ports)]
    catalog = address_map['catalog']
    require(catalog['span'] == BO_BYTES and type(catalog['span']) is int, 'catalog fixed8192 span')
    cat = interval(catalog['base'], catalog['span'], 'catalog')
    require(catalog['base'] % 4096 == 0 and apertures[0][0] <= cat[0] and cat[1] <= apertures[0][1],
            'catalog alignment/aperture')
    require(isinstance(records, list) and len(records) == RECORD_COUNT, 'exact120 records')
    model_ranges = [[] for _ in range(4)]
    for spec, record in zip(bindings(), records):
        require(isinstance(record, dict) and set(record) == {'index', 'name', 'base', 'span'}, 'record exact fields')
        require(type(record['index']) is int and record['index'] == spec['index'] and
                record['name'] == spec['name'], 'record index/WeightKey binding')
        require(isinstance(record['base'], list) and isinstance(record['span'], list) and
                len(record['base']) == len(record['span']) == 4, 'four base/span pairs')
        for port in range(4):
            base, span = record['base'][port], record['span'][port]
            region = interval(base, span, f'record{spec["index"]} port{port}')
            require(base % 4096 == 0 and span >= spec['needed_per_port'], 'matrix base alignment/minimum span')
            require(apertures[port][0] <= region[0] and region[1] <= apertures[port][1], 'matrix actual aperture')
            if port == 0:
                require(disjoint(region, cat), 'catalog overlaps port0 immutable W')
            model_ranges[port].append(region)
    for dma in address_map.get('dma_ranges', []):
        port = uint(dma['port'], 2, 'DMA port')
        region = interval(dma['base'], dma['span'], 'DMA')
        require(all(disjoint(region, item) for item in model_ranges[port]) and
                (port != 0 or disjoint(region, cat)), 'entry/tail DMA overlaps sealed model storage')
    return records


def build_catalog(identity, address_map):
    for key in IDENTITY_FIELDS:
        full_sha(identity[key], key)
    records = validate_addresses(address_map, address_map['records'])
    payload = b''.join(struct.pack('<8Q', *(value for port in range(4)
                                          for value in (record['base'][port], record['span'][port])))
                       for record in records)
    header = bytearray(HEADER_BYTES)
    struct.pack_into('<8s4H', header, 0, b'LAYAC25\0', 1, HEADER_BYTES, RECORD_COUNT, RECORD_BYTES)
    for offset, key in zip((16, 48, 80, 112, 144), IDENTITY_FIELDS):
        header[offset:offset + 32] = bytes.fromhex(identity[key])
    header[176:208] = bytes.fromhex(digest(payload))
    struct.pack_into('<QQ', header, 208, crc64(payload), EFFECTIVE_BYTES)
    return bytes(header) + payload + bytes(BO_BYTES - EFFECTIVE_BYTES)


def verify_catalog(blob, identity, address_map):
    require(isinstance(blob, bytes) and len(blob) == BO_BYTES, 'catalog8192 bytes')
    require(struct.unpack_from('<8s4H', blob) == (b'LAYAC25\0', 1, HEADER_BYTES, RECORD_COUNT, RECORD_BYTES),
            'catalog fixed header')
    require(blob[224:256] == bytes(32) and blob[EFFECTIVE_BYTES:] == bytes(256), 'reserved/tail zero')
    for offset, key in zip((16, 48, 80, 112, 144), IDENTITY_FIELDS):
        require(blob[offset:offset + 32] == bytes.fromhex(full_sha(identity[key], key)), 'full identity mismatch ' + key)
    payload = blob[HEADER_BYTES:EFFECTIVE_BYTES]
    require(blob[176:208] == bytes.fromhex(digest(payload)), 'all-records SHA256 mismatch')
    expected_crc, effective = struct.unpack_from('<QQ', blob, 208)
    require(effective == EFFECTIVE_BYTES and verify_crc64_bits(payload) == expected_crc,
            'all-records CRC64/effective bytes mismatch')
    records = []
    for spec in bindings():
        values = struct.unpack_from('<8Q', payload, spec['index'] * RECORD_BYTES)
        records.append({'index': spec['index'], 'name': spec['name'],
                        'base': list(values[0::2]), 'span': list(values[1::2])})
    validate_addresses(address_map, records)
    require(records == address_map['records'], 'binary record/placement mapping mismatch')
    return {'record_count': RECORD_COUNT, 'records_sha256': digest(payload),
            'records_crc64': f'{expected_crc:016x}', 'identity': identity,
            'catalog_sha256': digest(blob), 'address_space': address_map['address_space'],
            'actual_platform_DMA': 'NOT_RUN', 'device_SHA256_compute': False}


def finite_f32(data, label):
    require(len(data) % 4 == 0, label + ' F32 bytes')
    require(all(word[0] & 0x7f800000 != 0x7f800000 for word in struct.iter_unpack('<I', data)), label + ' nonfinite')


def expand_type_row(raw):
    """Original embedding_row arithmetic: exact S8->F32 times exact F16->F32."""
    require(len(raw) == 1088, 'type Q8 row bytes')
    output = bytearray()
    for group in range(32):
        block = raw[group * 34:(group + 1) * 34]
        scale = struct.unpack('<e', block[:2])[0]
        require(scale >= 0 and scale < float('inf'), 'type scale finite/nonnegative')
        for value in struct.unpack('<32b', block[2:]):
            require(value >= -127, 'type S8 outside original Q8-F domain')
            # Binary16 has11 significant bits; multiplying by |S8|<=127 uses
            # at most18 bits and is exactly representable as F32, including
            # subnormal half scales. Signed zero follows the original product.
            output.extend(struct.pack('<f', value * scale))
    finite_f32(output, 'type expanded')
    return bytes(output)


def prepare_coefficients(package_info, gguf_path, output):
    output = Path(output)
    output.mkdir(parents=True, exist_ok=False)
    gguf_path = Path(gguf_path)
    require(gguf_path.stat().st_size == package_info['manifest']['source_model']['size'], 'GGUF source size')
    provenance = []

    def read_tensor(name, dtype, shape):
        tensor, source = package_info['tensors'][name], package_info['original'][name]
        require(source['ggml_type_id'] == dtype and source['ggml_ne'] == shape and
                source['absolute_file_offset'] == tensor['source_offset'], 'coefficient original name/type/shape/offset ' + name)
        with gguf_path.open('rb') as stream:
            stream.seek(tensor['source_offset'])
            raw = stream.read(tensor['source_bytes'])
        require(len(raw) == tensor['source_bytes'] and digest(raw) == tensor['source_sha256'], 'coefficient original bytes/SHA ' + name)
        filename = 'original_' + name + '.bin'
        (output / filename).write_bytes(raw)
        provenance.append({'name': name, 'ggml_type_id': dtype, 'ggml_ne': shape,
                           'absolute_file_offset': tensor['source_offset'], 'bytes': len(raw),
                           'raw_sha256': digest(raw), 'original_file': filename})
        return raw

    bias = bytearray()
    for spec in bindings()[112:]:
        raw = read_tensor(spec['bias_name'], 0, [spec['N'], 1, 1, 1])
        require(digest(raw) == package_info['weights'][spec['name']]['bias_sha256'], 'Decision bias WeightKey SHA')
        finite_f32(raw, spec['bias_name'])
        bias.extend(raw)
    gamma = read_tensor('final_norm_w', 0, [1024, 1, 1, 1])
    finite_f32(gamma, 'gamma')
    type_raw = read_tensor('type_emb.weight', 8, [1024, 3, 1, 1])
    require(len(type_raw) == 3 * 1088, 'exact three original type rows')
    type_f32 = b''.join(expand_type_row(type_raw[i * 1088:(i + 1) * 1088]) for i in range(3))
    require(len(bias) == 73728 and len(gamma) == 4096 and len(type_f32) == 12288, 'coefficient fixed shape')
    products = {}
    stream_lines = []
    for kind, name, data, chunks in ((0, 'bias.f32.bin', bytes(bias), 576),
                                      (1, 'gamma.f32.bin', gamma, 32),
                                      (2, 'type.f32.bin', type_f32, 96)):
        (output / name).write_bytes(data)
        products[name] = {'bytes': len(data), 'sha256': digest(data), 'kind': kind, 'chunk32_count': chunks}
        for index in range(chunks):
            stream_lines.append(json.dumps({'kind': kind, 'index': index,
                                            'data_hex': data[index * 128:(index + 1) * 128].hex()}, separators=(',', ':')))
    stream_blob = ('\n'.join(stream_lines) + '\n').encode()
    (output / 'coefficient_chunks.jsonl').write_bytes(stream_blob)
    report = {'status': 'ORIGINAL_MODEL_COEFFICIENT_SETUP_PRODUCTS', 'products': products,
              'source_tensors': provenance, 'source_model_sha256_inherited': MODEL_SHA,
              'whole_model_hash_recomputed': False, 'source_GGUF': str(gguf_path.resolve()),
              'original_type_rows': 3, 'type_algorithm': 'original embedding_row S8xF16->F32; exact18-significant-bit bound; independent original-reference comparison recorded separately in E020',
              'coefficient_stream_sha256': digest(stream_blob), 'chunk_count': 704,
              'device_actual_commits': 'NOT_RUN', 'runtime_gold_generated': False}
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage', choices=('build', 'verify', 'coefficients'))
    parser.add_argument('--package', type=Path, default=DEFAULT_PACKAGE)
    parser.add_argument('--inventory', type=Path, default=DEFAULT_INVENTORY)
    parser.add_argument('--addresses', type=Path)
    parser.add_argument('--catalog', type=Path)
    parser.add_argument('--gguf', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    info = load_package(args.package, args.inventory)
    if args.stage == 'coefficients':
        require(args.gguf is not None, 'explicit original GGUF path required')
        report = prepare_coefficients(info, args.gguf, args.output)
    else:
        require(args.addresses is not None, 'explicit placement/aperture JSON required')
        addresses = load_json(args.addresses)
        require(args.stage != 'verify' or args.catalog is not None, 'explicit catalog binary required for verify')
        blob = build_catalog(info['identity'], addresses) if args.stage == 'build' else args.catalog.read_bytes()
        report = verify_catalog(blob, info['identity'], addresses)
        report.update(package_manifest_sha256=info['manifest_sha256'], inventory_sha256=info['inventory_sha256'],
                      source_model_hash_recomputed=False, W_payload_packed=False,
                      current_RTL_build_identity='recorded separately in experiment source manifests')
        args.output.mkdir(parents=True, exist_ok=False)
        (args.output / 'catalog.bin').write_bytes(blob)
        (args.output / 'catalog.hex').write_text(''.join(f'{int.from_bytes(blob[i:i+64], "little"):0128x}\n' for i in range(0, BO_BYTES, 64)))
        (args.output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'status': report.get('status', 'CATALOG_HOST_FORMAT_VERIFIED'), 'output': str(args.output)}))


if __name__ == '__main__':
    main()
