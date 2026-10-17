#!/usr/bin/env python3
"""Recheck the CT0 generation and finite RTL evidence without DUT tools."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[6]
BASE = ROOT / ('project/E005_full_request_performance/experiment_results/'
               'runs/R001/attempts')
AT005 = BASE / 'AT005_CT0_owner_table_hls_02'
AT006 = BASE / 'AT006_CT0_owner_table_hls_03'
AT012 = BASE / 'AT012_CT0_owner_table_rtl_06'
OUT = ROOT / ('project/E005_full_request_performance/experiment_results/'
              'runs/R001/reports/CT0_owner_table_verification_20261013.json')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def main():
    fail = json.loads((AT005 / 'receipt.json').read_text())
    hls = json.loads((AT006 / 'receipt.json').read_text())
    rtl = json.loads((AT012 / 'receipt.json').read_text())
    require(fail['status'] == 'FAIL' and fail['hls']['guard']['trigger'] is None,
            'AT005 terminal mismatch')
    error_log = (AT005 / 'guard_hls/driver.log').read_text()
    require(error_log.count('Unsupported aggregate pragma/directive') == 2,
            'AT005 fail localization changed')
    require(hls['status'] == 'PASS_SCOPED_GENERATION', 'HLS terminal mismatch')
    require(rtl['status'] == 'PASS_SCOPED_RTL', 'RTL terminal mismatch')
    for result in (hls['host_build'], hls['host_run'], hls['hls'],
                   rtl['host_build'], rtl['host_run'], rtl['xvlog'],
                   rtl['xelab'], rtl['pilot'], rtl['full'],
                   rtl['request_off'], rtl['model_off'],
                   rtl['inactive_host']['request_off']['host'],
                   rtl['inactive_host']['model_off']['host']):
        require(result['pass'] and result['guard']['child_exit_code'] == 0 and
                result['guard']['trigger'] is None, 'guard result changed')
    module = Path('hls/control/owner_ct0/owner_ct0.cpp')
    hls_source = AT006 / 'frozen' / module
    rtl_source = AT012 / 'frozen' / module
    require(sha(hls_source) == sha(rtl_source), 'RTL did not freeze generated DUT source')
    top_source = AT006 / 'work/hls/syn/verilog/laya_owner_ct0.v'
    top_copy = AT012 / 'frozen/generated/laya_owner_ct0.v'
    require(sha(top_source) == sha(top_copy), 'generated top was edited')
    top = top_source.read_text()
    for port in ('request_dout', 'response_din'):
        require(re.search(r'\[(?:511):0\]\s+' + port + r'\b', top),
                port + ' is not a real 512-bit FIFO port')
    for port in ('request_empty_n', 'request_read', 'response_full_n',
                 'response_write', 'ap_clk', 'ap_rst'):
        require(re.search(r'\b' + port + r'\b', top), port + ' is absent')
    require('ap_start' not in top.split(');', 1)[0], 'unexpected control port')
    memory = (AT006 / 'work/hls/syn/verilog/'
              'laya_owner_ct0_table_r_RAM_1P_BRAM_1R1W.v').read_text()
    require('parameter DataWidth = 5009;' in memory and
            'parameter AddressRange = 32;' in memory and
            'reg [DataWidth-1:0] ram[0:AddressRange-1]' in memory and
            'if (we0)' in memory, 'complete indexed table RAM is absent')
    report = (AT006 / 'work/hls/syn/report/laya_owner_ct0_csynth.rpt').read_text()
    require(re.search(r'\|table_r_U\s+\|table_r_RAM_1P_BRAM_1R1W\s+\|\s*8\|', report),
            'HLS table memory estimate changed')
    trace_cmd = (AT012 / 'trace/commands.mem').read_text().splitlines()
    trace_rsp = (AT012 / 'trace/responses.mem').read_text().splitlines()
    require(len(trace_cmd) == 1572 and len(trace_rsp) == 1441 and
            all(len(x) == 128 for x in trace_cmd + trace_rsp),
            'full beat trace changed')
    full = rtl['full']
    match = re.search(r'cycles=(\d+) transactions=(\d+) input_words=(\d+) '
                      r'output_words=(\d+) held_cycles=(\d+)', full['marker'])
    require(match and tuple(map(int, match.groups())) ==
            (73429, 131, 1572, 1441, 617), 'finite RTL coverage changed')
    for name in ('request_off', 'model_off'):
        negative = rtl[name]
        require(re.search(r'cycles=5073 transactions=9 input_words=108 '
                          r'output_words=99 held_cycles=40',
                          negative['marker']), name + ' RTL contrast changed')
        host_marker = Path(rtl['inactive_host'][name]['host']['log']['path']).read_text()
        require('CT0_HOST_INACTIVE_PASS case=' + name in host_marker,
                name + ' original-helper contrast changed')
        case = AT012 / ('trace_' + name)
        cmd = (case / 'commands.mem').read_text().splitlines()
        rsp = (case / 'responses.mem').read_text().splitlines()
        require(len(cmd) == 1572 and len(rsp) == 1441 and
                all(int(word, 16) == 0 for word in cmd[108:] + rsp[99:]),
                name + ' trace padding changed')
    obj = {
        'schema': 'laya-ct0-scoped-verification-v1',
        'source_top_sha256': sha(hls_source),
        'generated_top_sha256': sha(top_source),
        'hls_attempt': str(AT006.relative_to(ROOT)),
        'rtl_attempt': str(AT012.relative_to(ROOT)),
        'previous_hls_failure': str(AT005.relative_to(ROOT)),
        'ports': 'two complete 512-bit FIFO ports, clock, reset; no ap_start',
        'table': {'words': 32, 'bits_per_word': 5009,
                  'semantic_bits': 160288, 'generated_indexed_RAM': True},
        'hls_estimate': {'BRAM_18K': 8, 'DSP': 1, 'FF': 49533,
                         'LUT': 39937, 'URAM': 0,
                         'not_physical_or_joint': True},
        'host_marker': Path(rtl['host_run']['log']['path']).read_text().splitlines()[0],
        'rtl': {'transactions': 131, 'input_words': 1572,
                'output_words': 1441, 'cycles': 73429,
                'pending_response_blocked_cycles': 617,
                'request_off': {'transactions': 9, 'cycles': 5073,
                                'pending_response_blocked_cycles': 40},
                'model_off': {'transactions': 9, 'cycles': 5073,
                              'pending_response_blocked_cycles': 40}},
        'guards': {'hls_elapsed_s': hls['hls']['guard']['elapsed_seconds'],
                   'hls_peak_owned_rss_kib': hls['hls']['guard']['peak_owned_rss_kb'],
                   'rtl_full_elapsed_s': full['guard']['elapsed_seconds'],
                   'rtl_full_peak_owned_rss_kib': full['guard']['peak_owned_rss_kb']},
        'limits': ['diagnostic table only', 'one cold sequence',
                   'no production owner/CLAIM/publish/retire',
                   'no complete request or physical implementation'],
    }
    OUT.write_text(json.dumps(obj, indent=2, sort_keys=True) + '\n')
    print('CT0_SCOPED_AUDIT_PASS')


if __name__ == '__main__':
    main()
