#!/usr/bin/env python3
"""Copy native HLS RTL and distribute one same-domain synchronous freeze CE.

The native ap_ce pipeline adapters delay CE and keep advancing some registers.
This additive RTL closure preserves every original arithmetic/data expression,
clock, reset, configured latency, RAM shape and instance. It gates each original
posedge block and actual vendor aclken, and records the complete transformation.
"""
from pathlib import Path
import hashlib
import json
import re
import shutil
import sys

TOP = 'laya_attention_service'
CE = 'laya_global_ce'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def masked(source):
    return re.sub(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"',
                  lambda m: re.sub(r'[^\n]', ' ', m.group()), source)


def close_paren(source, start):
    assert source[start] == '('
    depth = 1
    for pos in range(start + 1, len(source)):
        depth += (source[pos] == '(') - (source[pos] == ')')
        if depth == 0:
            return pos
    raise ValueError('unclosed parentheses')


def port_open(source, pos):
    while source[pos].isspace():
        pos += 1
    if source[pos] == '#':
        pos += 1
        while source[pos].isspace():
            pos += 1
        pos = close_paren(source, pos) + 1
        while source[pos].isspace():
            pos += 1
    assert source[pos] == '('
    return pos


def module_ranges(source):
    clean = masked(source)
    result = []
    for match in re.finditer(r'\bmodule\s+(\w+)\b', clean):
        end = re.search(r'\bendmodule\b', clean[match.end():])
        assert end is not None
        result.append((match[1], match.start(), match.end() + end.end()))
    return result


def modify(source, name, names):
    assert CE not in source, 'refuse double patch'
    clean = masked(source)
    edits = []
    declaration = re.search(r'\bmodule\s+' + re.escape(name) + r'\b', clean)
    po = port_open(clean, declaration.end())
    pc = close_paren(clean, po)
    semicolon = clean.index(';', pc)
    if name == TOP:
        edits.append((semicolon + 1, semicolon + 1,
                      '\nwire ' + CE + ' = ap_ce | ap_rst;\n'))
    elif re.search(r'\b(input|output|inout)\b', clean[po:pc]):
        edits.append((pc, pc, ',\n    input wire ' + CE + '\n'))
    else:
        edits.append((pc, pc, ', ' + CE))
        edits.append((semicolon + 1, semicolon + 1,
                      '\ninput ' + CE + ';\n'))

    children = []
    pattern = r'\b(' + '|'.join(map(re.escape, sorted(names, key=len, reverse=True))) + r')\b'
    for match in re.finditer(pattern, clean):
        pos = match.end()
        while pos < len(clean) and clean[pos].isspace():
            pos += 1
        if pos < len(clean) and clean[pos] == '#':
            pos += 1
            while clean[pos].isspace():
                pos += 1
            pos = close_paren(clean, pos) + 1
            while clean[pos].isspace():
                pos += 1
        instance = re.match(r'(\w+)\s*\(', clean[pos:])
        if instance is None:
            continue
        op = pos + instance.end() - 1
        cp = close_paren(clean, op)
        assert re.match(r'\s*\.', clean[op + 1:cp]), 'named ports required'
        edits.append((cp, cp, ',\n    .' + CE + '(' + CE + ')\n'))
        children.append({'module': match[1], 'instance': instance[1]})

    sequential = list(re.finditer(r'\balways\s*@\s*\([^)]*\bposedge\b[^)]*\)\s*begin\b', clean))
    assert len(sequential) == len(re.findall(r'\balways\s*@\s*\([^)]*\bposedge\b', clean)), 'unhandled sequential syntax'
    for match in sequential:
        depth = 1
        ending = None
        for token in re.finditer(r'\bbegin\b|\bend\b', clean[match.end():]):
            depth += 1 if token.group() == 'begin' else -1
            if depth == 0:
                ending = match.end() + token.start()
                break
        assert ending is not None
        edits.append((match.end(), match.end(), '\n    if (' + CE + ') begin\n'))
        edits.append((ending, ending, '    end\n'))
    vendor = []
    for match in re.finditer(r'\bassign\s+aclken\s*=\s*([^;]+);', clean):
        original = source[match.start(1):match.end(1)]
        edits.append((match.start(1), match.end(1), '(' + original + ') & ' + CE))
        vendor.append(original.strip())
    for start, end, value in sorted(edits, reverse=True):
        source = source[:start] + value + source[end:]
    return source, {'module': name, 'posedge_blocks': len(sequential),
                    'children': children, 'vendor_aclken_original': vendor}


def main():
    hls, output = map(lambda x: Path(x).resolve(), sys.argv[1:3])
    native = hls / 'hls_project/solution1/syn/verilog'
    assert not output.exists(), 'fresh output required'
    patched = output / 'hls_project/solution1/syn/verilog'
    patched.mkdir(parents=True)
    sources = {p.name: p.read_text() for p in native.glob('*.v')}
    names = {name for s in sources.values() for name, _, _ in module_ranges(s)}
    assert TOP in names
    records = []
    for filename, source in sorted(sources.items()):
        ranges = module_ranges(source)
        mapping = []
        for name, start, end in reversed(ranges):
            changed, record = modify(source[start:end], name, names)
            source = source[:start] + changed + source[end:]
            mapping.append(record)
        dst = patched / filename
        dst.write_text(source)
        records.append({'original': str(native / filename),
                        'original_sha256': digest(native / filename),
                        'patched': str(dst), 'patched_sha256': digest(dst),
                        'modules': list(reversed(mapping))})
    dependencies = []
    for p in sorted(native.iterdir()):
        if p.suffix in ('.tcl', '.dat'):
            dst = patched / p.name
            shutil.copy2(p, dst)
            record = {'original': str(p), 'patched': str(dst),
                      'sha256': digest(p), 'unchanged': digest(p) == digest(dst)}
            if p.name.endswith('_ip.tcl'):
                latency = re.search(r'CONFIG\.c_latency\s+(\d+)', p.read_text())
                if latency:
                    record['configured_core_latency'] = int(latency[1])
            dependencies.append(record)
    report = hls / 'hls_project/solution1/syn/report'
    shutil.copytree(report, output / 'hls_project/solution1/syn/report')
    all_modules = [m for r in records for m in r['modules']]
    graph = {m['module']: m for m in all_modules}
    hierarchy = []
    def visit(name, path):
        hierarchy.append({'path': path, 'module': name,
                          'posedge_blocks': graph[name]['posedge_blocks'],
                          'vendor_aclken_gates': len(graph[name]['vendor_aclken_original'])})
        for child in graph[name]['children']:
            visit(child['module'], path + '.' + child['instance'])
    visit(TOP, 'dut')
    manifest = {'schema': 'attention_same_clock_ce_closure_v1',
        'status': 'CANDIDATE_NOT_RTL_VERIFIED', 'native_hls_attempt': str(hls),
        'generator': {'path': str(Path(__file__).resolve()),
                      'sha256': digest(Path(__file__).resolve())},
        'clock_reset_rule': 'Same ap_clk and original synchronous reset. top global_ce=ap_ce|ap_rst; original posedge blocks hold when low. Vendor aclken=original&global_ce. No clock gating, arithmetic/data/latency/RAM/instance edits.',
        'module_count': len(all_modules),
        'posedge_block_count': sum(m['posedge_blocks'] for m in all_modules),
        'vendor_aclken_gate_count': sum(len(m['vendor_aclken_original']) for m in all_modules),
        'files': records, 'dependencies': dependencies, 'hierarchy': hierarchy}
    (output / 'ce_patch_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('ATTENTION_SAME_CLOCK_CE_CLOSURE modules=%d posedge=%d vendor=%d' %
          (manifest['module_count'], manifest['posedge_block_count'], manifest['vendor_aclken_gate_count']))


if __name__ == '__main__':
    main()
