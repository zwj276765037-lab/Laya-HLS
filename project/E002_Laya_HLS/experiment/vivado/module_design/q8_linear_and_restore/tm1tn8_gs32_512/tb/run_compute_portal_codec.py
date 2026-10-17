#!/usr/bin/env python3
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]


def rec(p):
    p = p.resolve()
    return {'path': str(p), 'bytes': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--work', type=Path, required=True)
    args = parser.parse_args()
    work = args.work.resolve(); work.mkdir(exist_ok=False)
    flags = ['-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror', '-fno-fast-math',
             '-fno-associative-math', '-ffp-contract=off', '-I' + str(ROOT / 'include'),
             '-I' + str(ROOT / 'build/model-repair')]
    units = ['hls/platform/compute_portal_codec.cpp', 'hls/common/laya_numeric.cpp',
             'hls/common/laya_tasks.cpp', 'tests/compute_portal_codec_test.cpp']
    objects, closure, commands = [], set(), []
    for index, unit in enumerate(units):
        obj, dep = work / f'{index}.o', work / f'{index}.d'
        command = ['/usr/bin/g++', *flags, '-MMD', '-MF', str(dep), '-c', str(ROOT / unit), '-o', str(obj)]
        commands.append(command)
        subprocess.run(command, check=True, cwd=ROOT)
        objects.append(obj)
        for path in dep.read_text().replace('\\\n', ' ').split(':', 1)[1].split():
            closure.add(Path(path).resolve())
        print('FULL_CURRENT_PORTAL_COMPILED unit=' + unit, flush=True)
    executable = work / 'codec_test'
    command = ['/usr/bin/g++', *map(str, objects), '-o', str(executable)]
    commands.append(command); subprocess.run(command, check=True, cwd=ROOT)
    commands.append([str(executable), str(work)])
    subprocess.run(commands[-1], check=True, cwd=ROOT)
    wire = ROOT / 'tests/compute_portal_wire_test.py'
    commands.append([sys.executable, str(wire), str(work)])
    subprocess.run(commands[-1], check=True, cwd=ROOT)
    (work / 'receipt.json').write_text(json.dumps({'status': 'PASS', 'scope': 'C codec and independent byte oracle only',
        'commands': commands, 'compiler_dependencies': [rec(p) for p in sorted(closure)],
        'wire_oracle': rec(wire), 'runner': rec(Path(__file__)), 'executable': rec(executable),
        'command_packet': rec(work / 'command.bin'), 'response_packet': rec(work / 'response.bin')}, indent=2) + '\n')
    print('FULL_CURRENT_PORTAL_CPU_PASS', flush=True)


if __name__ == '__main__': main()
