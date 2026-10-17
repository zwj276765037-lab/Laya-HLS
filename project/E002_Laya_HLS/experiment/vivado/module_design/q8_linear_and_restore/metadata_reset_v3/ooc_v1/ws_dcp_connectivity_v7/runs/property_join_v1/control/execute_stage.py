#!/usr/bin/env python3
"""Launch one command from the immutable Ws v7 release, recording its result."""

import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


RELEASE = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_ws_v7_single_actual_structure_parameter_join_release.json')
RELEASE_SHA256 = '6294417e39e325f9e3f42ad4a63f739b91f291fcb5ff80176aa1fffce978505c'


def utc_now():
    return dt.datetime.now(dt.timezone.utc).isoformat()


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + '\n')


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ('binding_pre', 'guarded_join', 'binding_post'):
        raise SystemExit('expected one released stage')
    stage = sys.argv[1]
    content = RELEASE.read_bytes()
    assert hashlib.sha256(content).hexdigest() == RELEASE_SHA256
    release = json.loads(content)
    command = next(item for item in release['commands'] if item['stage'] == stage)
    control = Path(release['fresh_control'])
    reports = Path(release['fresh_reports'])
    assert Path.cwd() == control
    assert command['cwd'] == str(control)
    assert (control / 'execution_preflight.json').is_file()
    if stage in ('binding_pre', 'guarded_join'):
        assert not reports.exists()
    if stage == 'guarded_join':
        assert json.loads((control / 'binding_pre.record.json').read_text())['exit_code'] == 0
    if stage == 'binding_post':
        assert (control / 'guarded_join.record.json').is_file()
    marker = control / f'{stage}.started.json'
    record = control / f'{stage}.record.json'
    stdout = control / f'{stage}.stdout'
    stderr = control / f'{stage}.stderr'
    assert not any(path.exists() for path in (marker, record, stdout, stderr)), 'stage already attempted'
    started = utc_now()
    write_json(marker, {'at_utc': started, 'stage': stage, 'argv': command['argv'], 'cwd': command['cwd'], 'launcher_pid': os.getpid()})
    with stdout.open('wb') as out, stderr.open('wb') as err:
        result = subprocess.run(command['argv'], cwd=command['cwd'], stdout=out, stderr=err, check=False)
    data = {'stage': stage, 'argv': command['argv'], 'cwd': command['cwd'], 'start_utc': started,
            'finish_utc': utc_now(), 'exit_code': result.returncode,
            'launcher': {'pid': os.getpid(), 'uid': os.getuid(), 'euid': os.geteuid(), 'executable': sys.executable},
            'environment': {'variable_names': sorted(os.environ),
                            'selected': {key: os.environ[key] for key in ('PATH', 'LANG', 'LC_ALL', 'LC_CTYPE', 'PYTHONPATH') if key in os.environ},
                            'full_environment_sha256': hashlib.sha256(b'\0'.join((key + '=' + value).encode() for key, value in sorted(os.environ.items()))).hexdigest()}}
    write_json(record, data)
    print(json.dumps({'stage': stage, 'exit_code': result.returncode, 'record': str(record),
                      'stdout': str(stdout), 'stderr': str(stderr)}))
    return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
