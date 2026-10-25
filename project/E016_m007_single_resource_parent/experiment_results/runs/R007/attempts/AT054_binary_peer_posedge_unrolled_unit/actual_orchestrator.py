#!/usr/bin/env python3
"""Plan, then explicitly run one short old-fixture regression in a released window."""
from pathlib import Path
from decimal import Decimal
import argparse
import fcntl
import json
import re
import shlex
import shutil
import subprocess
import sys
import time
import fullmodel_r007_run as run


def ledger():
    used = run.costs()
    run.dump(run.R / 'budget_ledger.json', {
        'schema': 'm007-r007-budget-v1', 'limits_seconds': run.CAP,
        'used_seconds': {k: str(v) for k, v in used.items()},
        'remaining_seconds': {k: str(Decimal(run.CAP[k]) - v) for k, v in used.items()},
        'rtl_reserve_seconds': 400, 'old_run_budget_transferred': False,
    })


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--execute', action='store_true')
    ap.add_argument('--handoff-evidence', default='')
    args = ap.parse_args()
    r, root = run.R, run.ROOT
    fixture = r / 'attempts/AT038_binary_weight_peer_byte_fixture_build/work/fixture'
    prepared = r / 'prepared/binary_peer_posedge_unrolled_v2'
    manifest = prepared / 'source_manifest.json'
    d = run.read(manifest)
    peer = root / d['source']
    assert run.sha(peer) == d['sha256'] == 'f4d1c00d2f8da967681fd01fe393a82e7dfbd04b1ce30c650b1739ba9df75372'
    binding = run.peer_binding(fixture)
    assert binding['plusargs']['REQUESTS'] == 2897 and binding['plusargs']['WORDS'] == 23049
    at = r / 'attempts/AT054_binary_peer_posedge_unrolled_unit'
    plan = {
        'schema': 'm007-r007-peer-unroll-short-regression-plan-v1',
        'status': 'PREPARED_NOT_RUN_AWAIT_EXPLICIT_A012_WINDOW_RELEASE',
        'source': d['source'], 'sha256': d['sha256'],
        'fullgraph_manifest_sha256_unchanged': run.sha(manifest),
        'top': 'm007_binary_weight_peer_unit_tb',
        'fixture': str(fixture.relative_to(root)), 'binding': binding,
        'gold_generation': False, 'production_or_fullgraph_test': False,
        'requested_window_seconds': 40, 'nonblocking_heavy_lock': True,
        'stage_caps_seconds': {'static': 24, 'rtl': 10},
        'pending_attempt': str(at.relative_to(root)),
        'execution_command': [sys.executable, str(Path(__file__).resolve()), '--execute',
                              '--handoff-evidence', '<actual A012 window release message>'],
    }
    if not args.execute:
        run.dump(r / 'binary_peer_unroll_unit_regression_plan.json', plan)
        print(json.dumps({k: plan[k] for k in ['status', 'sha256', 'requested_window_seconds', 'stage_caps_seconds']}))
        return 0
    assert args.handoff_evidence, 'record the actual A012 heavy-window release'
    used = run.costs()
    assert Decimal(run.CAP['static']) - used['static'] >= 24
    assert Decimal(run.CAP['rtl']) - used['rtl'] >= 410
    with (root / '.research-agent/m007_heavy.lock').open('a+') as lock:
        # Never wait behind A012 or charge a dispatcher while queued.
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        started = time.monotonic()
        assert not at.exists()
        f, w = at / 'frozen', at / 'work'
        f.mkdir(parents=True)
        w.mkdir()
        shutil.copy2(Path(__file__), at / 'actual_orchestrator.py')
        old = r / 'attempts/AT038_binary_weight_peer_byte_fixture_build/frozen'
        for source in [peer, old / 'm007_parent_guard_v2.py', old / 'hls_guard_helpers.py']:
            shutil.copy2(source, f / source.name)
        run.dump(at / 'binary_peer_input_binding.json', binding)
        run.dump(at / 'source_manifest.json', plan | {
            'status': 'ACTUAL_SOURCE_BOUND_LAUNCH', 'handoff_evidence': args.handoff_evidence,
            'files': [{'frozen': p.name, 'sha256': run.sha(p)} for p in sorted(f.iterdir())],
        })
        snapshot = 'm007_peer_unroll_sim'
        commands = [
            [str(run.VIV / 'xvlog'), '--sv', str(f / peer.name)],
            [str(run.VIV / 'xelab'), 'work.m007_binary_weight_peer_unit_tb', '--relax',
             '-debug', 'off', '-mt', '4', '--O3', '-s', snapshot],
        ]
        build = w / 'build.sh'
        build.write_text('#!/bin/bash\nset -euo pipefail\n'
                         + '\n'.join(shlex.join(c) for c in commands)
                         + '\necho M007_PEER_UNROLL_BUILD_PASS\n')
        sim = [str(run.VIV / 'xsim'), snapshot, '-runall']
        for key, value in binding['plusargs'].items():
            sim += ['-testplusarg', key + '=' + str(value)]
        stages = [('static', ['/bin/bash', str(build)], 'M007_PEER_UNROLL_BUILD_PASS', 24),
                  ('rtl', sim, 'HARDWARE_AGENT_SIM_PASS M007_BINARY_WEIGHT_PEER', 10)]
        for category, command, marker, cap in stages:
            remaining_window = 38 - (time.monotonic() - started)
            timeout = min(cap, int(remaining_window - 2))
            assert timeout > 0, 'released short window exhausted'
            guard = [sys.executable, str(f / 'm007_parent_guard_v2.py'), '--out',
                     str(at / ('guard_' + category)), '--cwd', str(w), '--rss-gib',
                     '24' if category == 'static' else '8', '--timeout-seconds', str(timeout),
                     '--semantic-stall-seconds', '120', '--phase', category]
            if category == 'static':
                guard += ['--artifact-progress-root', str(w)]
            guard += ['--', *command]
            run.dump(at / ('command_' + category + '.json'), {
                'argv': guard, 'lock_held_through_descendants': True,
                'handoff_evidence': args.handoff_evidence,
                'window_elapsed_before_seconds': time.monotonic() - started,
            })
            rc = subprocess.call(guard, cwd=w, pass_fds=(lock.fileno(),))
            g = run.read(at / ('guard_' + category) / 'guard_result.json')
            log = (at / ('guard_' + category) / 'driver.log').read_text(errors='replace')
            fatal = bool(re.search(r'(?im)^\s*(?:Fatal|ERROR|FATAL_ERROR):', log))
            ok = rc == 0 and marker in log and not fatal
            run.dump(at / ('receipt_' + category + '.json'), {
                'category': category, 'wall_s': g['elapsed_seconds'], 'guard_exit': rc,
                'guard': g, 'marker': marker, 'marker_found': marker in log,
                'verdict': 'PASS' if ok else 'FAIL' if fatal else 'COST_STOP' if g['trigger'] else 'FAIL',
                'fullgraph': 'NOT_RUN', 'fixture_reused_no_gold_generation': True,
            })
            ledger()
            print(json.dumps({'category': category, 'pass': ok, 'wall_s': g['elapsed_seconds']}), flush=True)
            if not ok:
                return 1
        run.dump(at / 'window_receipt.json', {
            'elapsed_seconds': time.monotonic() - started, 'explicit_handoff': args.handoff_evidence,
            'build_and_unit_RTL': 'PASS', 'fullgraph': 'NOT_RUN',
        })
        return 0


if __name__ == '__main__':
    raise SystemExit(main())
