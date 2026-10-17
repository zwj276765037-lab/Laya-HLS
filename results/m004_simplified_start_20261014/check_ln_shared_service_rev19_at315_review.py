"""Bounded read-only audit of AT313–315; no EDA or numerical evaluation."""
import hashlib
import json
import os
import re
import subprocess
from decimal import Decimal
from pathlib import Path

R = Path(__file__).resolve().parents[2]
B = R / 'project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts'
A = {n: next(B.glob(f'AT{n}_*')) for n in range(307, 316)}
checks, identities, fixtures, guards = [], [], [], []

def ck(name, value):
    checks.append({'name': name, 'pass': bool(value)})

def read(p, expected=None):
    data = p.read_bytes()
    sha = hashlib.sha256(data).hexdigest()
    identities.append({'path': str(p.relative_to(R)), 'sha256': sha, 'bytes': len(data)})
    if expected is not None:
        ck('sha:' + str(p.relative_to(R)), sha == expected)
    return data

manifests = {}
for n in [313, 314, 315]:
    m = json.loads(read(A[n] / 'source_manifest.json'))
    manifests[n] = {e['name']: e for e in m['entries']}
    ck(f'AT{n}:manifest_count', len(m['entries']) == (117 if n == 315 else 120))
    for e in m['entries']:
        data = read(A[n] / 'frozen' / e['name'], e['sha256'])
        ck(f'AT{n}:size:' + e['name'], len(data) == e['bytes'])

lower = 'laya_lnq_bank_service_v1.sv'
ck('same_lower_service_three_attempts', all(manifests[n][lower]['sha256'] ==
   'd39a5479c3b1bad96e0eeb406ca66d2a28cc87a9388748e3d35d73639c0f89e3' for n in manifests))
changed = [k for k in manifests[313] if manifests[313][k]['sha256'] != manifests[314][k]['sha256']]
ck('AT314_only_tb_changed', changed == ['laya_shared_q16_service_tb.sv'])
tb313 = (A[313] / 'frozen/laya_shared_q16_service_tb.sv').read_text()
tb314 = (A[314] / 'frozen/laya_shared_q16_service_tb.sv').read_text()
ck('exact_last_word_stall_fix', tb314 == tb313.replace(
    'if(r==15 && i==1023)repeat(4)@(negedge clk);',
    'if(r==15 && i==1023)begin\n        prep_write_valid=0;\n        repeat(4)@(negedge clk);\n      end'))

# These runtime inputs are NOT entries in the new frozen-source manifests.
for n, folder, origin_n, names in [
    (314, 'fixture_qkv', 225, ['model_identity.hex', 'norm_row0.hex', 'norm_row1.hex',
                             'q_row0.hex', 'q_row1.hex', 'scale_row0.hex', 'scale_row1.hex']),
    (315, 'fixture', 304, ['model_identity.hex', 'expected_aux_header.hex',
                         'raw_s128.hex', 'norm_s128.hex', 'gamma.hex']),
]:
    origin = next(B.glob(f'AT{origin_n}_*')) / folder
    for name in names:
        actual, old = A[n] / folder / name, origin / name
        data, prior = read(actual), read(old)
        ck(f'AT{n}:runtime_fixture_binding:' + name, data == prior)
        fixtures.append({'path': str(actual.relative_to(R)), 'reference': str(old.relative_to(R)),
                         'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)})

totals = {'static': Decimal(0), 'RTL': Decimal(0)}
new_totals = dict(totals)
policy_count = 0
for n, a in A.items():
    for g in sorted(a.glob('guard*')):
        if not (g / 'guard_result.json').is_file():
            continue
        result = json.loads(read(g / 'guard_result.json'), parse_float=Decimal)
        plan = json.loads(read(g / 'guard_plan.json'))
        kind = 'static' if 'static' in g.name else 'RTL'
        ck(f'AT{n}:{g.name}:command_class',
           any(Path(s).name == 'xsim' for s in plan['command']) == (kind == 'RTL'))
        totals[kind] += result['elapsed_seconds']
        entry = {'attempt': a.name, 'guard': g.name, 'class': kind,
                 'seconds': str(result['elapsed_seconds']), 'exit': result['child_exit_code'],
                 'trigger': result['trigger'], 'configured_cap_seconds': plan['maximum_seconds'],
                 'evidence_scope': 'cost-only' if n < 313 else 'milestone'}
        if n >= 313:
            new_totals[kind] += result['elapsed_seconds']
            pol = json.loads(read(g / 'policy_checks.json'))
            policy_count += len(pol)
            for j, p in enumerate(pol):
                ck(f'AT{n}:{g.name}:policy{j}', p['matches'] and p['affinity'] == [0,1,2,3]
                   and p['nice'] == 19 and p['ionice'] == 'idle' and p['ionice_exit'] == 0)
            ck(f'AT{n}:{g.name}:memory', result['minimum_mem_available_kb'] > 192*1024**2
               and result['peak_owned_rss_kb'] <= plan['maximum_owned_rss_kb'])
            ck(f'AT{n}:{g.name}:exit', result['child_exit_code'] == 0 and result['trigger'] is None)
            log = read(g / 'driver.log').decode()
            fatal = bool(re.search(r'^(?:Fatal:|ERROR:)', log, re.M))
            ck(f'AT{n}:{g.name}:fatal_expected', fatal == (n == 313 and kind == 'RTL'))
            entry['log_fatal_or_error'] = fatal
        guards.append(entry)

ck('six_new_guards_38_policy_samples', len([g for g in guards if g['evidence_scope']=='milestone']) == 6 and policy_count == 38)
ck('16_guards_through_AT315', len(guards) == 16 and sum(g['class']=='static' for g in guards) == 9)
ck('exact_static_total', totals['static'] == Decimal('879.9686042405664817'))
ck('exact_rtl_total', totals['RTL'] == Decimal('395.898595323786132'))
log313 = (A[313] / 'guard_rtl/driver.log').read_text()
log314 = (A[314] / 'guard_rtl/driver.log').read_text()
log315 = (A[315] / 'guard_rtl_row0/driver.log').read_text()
ck('AT313_original_failure_preserved', 'Fatal: SHARED_Q16_PREP_WRITE row=15 word=1023' in log313)
ck('AT314_unique_terminal', log314.count('SHARED_Q16_SERVICE_PASS rows=16 words=4352 rsp=512') == 1)
ck('AT315_observed_row0_retirement', re.findall(r'STAGED_LN_ROW_RETIRED row=(\d+) B=(\d+) sourceR=(\d+) cycle=(\d+)', log315) == [('0','64','64','15375')])
ck('AT315_norm_handshake_progress', 'STAGED_LN_PROGRESS gamma=256 raw=64 norm=1024 B=2' in log315)
ck('AT315_fixed_prefix', 'run 160 us' in (A[315] / 'frozen/run_row0_prefix.tcl').read_text())
parent_log = (A[315] / 'guard_static/driver.log').read_text()
parent_modules = [lower, 'laya_source_norm_service_v1.sv', 'laya_lnq_wi_gqdown_row_v1.sv',
                  'laya_qkv_scratch_row_v1.sv', 'laya_qkv_s128_request_v1.sv']
for name in parent_modules:
    ck('AT315_actual_compile:' + name, str(A[315] / 'frozen' / name) in parent_log
       and 'Compiling module work.' + Path(name).stem in parent_log)

report = {
    'decision': 'D-M004-REV19-AT315-01', 'checks': checks,
    'check_count': len(checks), 'failures': [c for c in checks if not c['pass']],
    'identities': identities, 'manifest_entries': 357, 'runtime_fixture_bindings': fixtures,
    'new_guards': 6, 'new_policy_samples': policy_count, 'guards_through_AT315': guards,
    'cost_only_through_AT315': {k: str(v) for k,v in totals.items()},
    'new_costs_AT313_AT315': {k: str(v) for k,v in new_totals.items()},
    'remaining_at_AT315_checkpoint_only': {k: str(Decimal(lim)-totals[k]) for k,lim in [('static',1800),('RTL',3600)]},
    'frozen_parent_identities': {name: manifests[315][name]['sha256'] for name in parent_modules},
    'scope': {
        'AT313': 'FAIL_TB_LAST_INPUT_STALL; child0 does not override Fatal',
        'AT314': 'PASS_LOCAL_Q16: two saved norm samples repeated over16 slots; per-row immediate4352 word checks and512 responses; no final4352 word full-window rescan',
        'AT315': 'OBSERVED_REAL_PARENT_ROW0_PREFIX; no full TB success terminal; source64R is at row0 retirement, whole-run final source count UNKNOWN',
        'production_ownership': 'lower LN_ONLY local lifecycle and upper source/norm/128-loop/16-row error barrier migration still required',
        'full16_LN': 'NOT_RUN', 'LN128': 'NOT_RUN', 'revision19': 'running',
    },
    'report_corrections': {'AT314_static_seconds': '31.224050499498844',
                           '32.49943132698536_belongs_to': 'AT313_static'},
    'guard_plan_note': 'AT313 first independent-service RTL configured240s, actual23.629135239869356s; future unknown-path pilots must retain original<=120s cap',
    'host_complete_cumulative': 'UNKNOWN',
    'controller_policy': {'affinity': sorted(os.sched_getaffinity(0)), 'nice': os.getpriority(os.PRIO_PROCESS,0),
                          'ionice': subprocess.check_output(['ionice','-p',str(os.getpid())], text=True).strip()},
}
Path(__file__).with_name('ln_shared_service_rev19_at315_review_20261016.json').write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n')
print(json.dumps({k: report[k] for k in ['check_count','failures','manifest_entries','new_policy_samples','cost_only_through_AT315']}, ensure_ascii=False))
raise SystemExit(bool(report['failures']))
