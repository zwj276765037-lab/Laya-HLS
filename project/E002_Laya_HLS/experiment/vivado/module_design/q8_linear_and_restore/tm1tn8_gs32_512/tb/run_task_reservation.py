#!/usr/bin/env python3
"""Freeze the dispatcher reservation closure and run the bounded control test."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]

def rec(p):
    return dict(path=str(p.resolve()), bytes=p.stat().st_size, sha256=hashlib.sha256(p.read_bytes()).hexdigest())

def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--work', type=Path, required=True)
    work = parser.parse_args().work.resolve(); work.mkdir(exist_ok=False)
    frozen = work / 'frozen'
    units = ['tests/task_reservation_test.cpp', 'hls/common/laya_numeric.cpp', 'hls/common/laya_tasks.cpp']
    flags = ['-std=c++17', '-O2', '-Wall', '-Wextra', '-Werror', '-fno-fast-math',
             '-fno-associative-math', '-ffp-contract=off']
    syntax_units = ['hls/control/full_forward_controller.cpp']
    closure = set()
    for unit in units + syntax_units:
        deps = subprocess.check_output(['/usr/bin/g++', *flags, '-I' + str(ROOT/'include'),
                                        '-MM', str(ROOT/unit)], text=True)
        closure.update(Path(p).resolve() for p in deps.replace('\\\n', ' ').split(':', 1)[1].split())
    files = []
    for p in sorted(closure):
        target = frozen / p.relative_to(ROOT); target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(p, target); files.append(dict(original=rec(p), frozen=rec(target)))
    manifest = dict(files=files, runner=rec(Path(__file__)), compiler=subprocess.check_output(['/usr/bin/g++','--version'],text=True), commands=[])
    objects = []
    result = 0
    try:
        for i, unit in enumerate(units):
            obj = work / f'{i}.o'; objects.append(obj)
            command = ['/usr/bin/g++', *flags, '-I'+str(frozen/'include'), '-c', str(frozen/unit), '-o', str(obj)]
            manifest['commands'].append(command); (work/'input_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
            subprocess.run(command, check=True)
            print('FULL_CURRENT_RESERVATION_COMPILED unit='+unit, flush=True)
        for unit in syntax_units:
            command = ['/usr/bin/g++', *flags, '-I'+str(frozen/'include'), '-fsyntax-only', str(frozen/unit)]
            manifest['commands'].append(command); subprocess.run(command, check=True)
            print('FULL_CURRENT_DISPATCH_SYNTAX_PASS unit='+unit, flush=True)
        exe = work / 'reservation_test'
        command = ['/usr/bin/g++', *map(str,objects), '-o',str(exe)]
        manifest['commands'].append(command); subprocess.run(command,check=True)
        command = [str(exe)]; manifest['commands'].append(command); subprocess.run(command, check=True)
    except subprocess.CalledProcessError as error:
        result = error.returncode
    (work/'input_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (work/'receipt.json').write_text(json.dumps(dict(status='PASS' if result==0 else 'FAIL', exit_code=result,
        scope='dispatch reservation/control only; no numerical, physical producer/lease or generated-caller claim',
        manifest=rec(work/'input_manifest.json')),indent=2)+'\n')
    sys.exit(0 if result==0 else 1)

if __name__ == '__main__': main()
