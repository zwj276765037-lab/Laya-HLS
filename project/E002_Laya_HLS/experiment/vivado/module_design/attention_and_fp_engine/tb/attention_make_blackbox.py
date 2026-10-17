#!/usr/bin/env python3
"""Bind the C model to HLS RTL and optional matching module receipts."""
from pathlib import Path
import argparse
import hashlib
import json
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('hls', type=Path)
parser.add_argument('--ooc-result', type=Path)
parser.add_argument('--rtl-result', type=Path)
args = parser.parse_args()
module = Path(__file__).resolve().parents[1]
hls = args.hls.resolve()
rtl = hls / 'hls_project/solution1/syn/verilog'
top = (rtl / 'laya_attention_service.v').read_text()
for port in ['ap_clk', 'ap_rst', 'ap_ce', 'ap_start', 'ap_continue',
             'ap_done', 'ap_idle', 'ap_ready', 'result_ap_vld', 'status_ap_vld']:
    assert port in top, port
resources = ET.parse(hls / 'hls_project/solution1/syn/report/laya_attention_service_csynth.xml').find('.//AreaEstimates/Resources')
parameters = []
for name in ['command', 'index', 'payload', 'epoch']:
    parameters.append({'c_name': name, 'c_port_direction': 'in',
                       'rtl_ports': {'data_read_in': name}})
for name in ['result', 'status']:
    parameters.append({'c_name': name, 'c_port_direction': 'out',
                       'rtl_ports': {'data_write_out': name,
                                     'data_write_valid': name + '_ap_vld'}})
files = sorted(rtl.glob('*.v'))
ip_tcl = sorted(rtl.glob('*_ip.tcl'))
data = sorted(rtl.glob('*.dat'))
ce_manifest = hls / 'ce_patch_manifest.json'
ce_closure = json.loads(ce_manifest.read_text()) if ce_manifest.is_file() else None
receipt_files = []
verification = {}
resource_usage = {out: resources.find(src).text for out, src in
    [('FF', 'FF'), ('LUT', 'LUT'), ('BRAM', 'BRAM_18K'), ('URAM', 'URAM'), ('DSP', 'DSP')]}
resource_scope = 'Original HLS estimates; actual complete CE closure physical OOC is billed separately.'
for kind, path in [('module_ooc', args.ooc_result), ('module_rtl', args.rtl_result)]:
    if path is None:
        continue
    path = path.resolve()
    receipt = json.loads(path.read_text())
    assert ce_closure, 'Module receipts require a frozen CE closure'
    assert receipt['status'] == 'PASS', (kind, receipt['status'])
    assert Path(receipt['ce_closure_manifest']).resolve() == ce_manifest, kind
    assert receipt['ce_closure_manifest_sha256'] == hashlib.sha256(ce_manifest.read_bytes()).hexdigest(), kind
    assert receipt['guard']['child_exit_code'] == 0 and receipt['guard']['trigger'] is None, kind
    receipt_files.append(path)
    verification[kind] = {'path': str(path), 'status': 'PASS', 'scope': receipt['scope']}
    if kind == 'module_ooc':
        assert receipt['blackboxes'] == 0
        measured = receipt['resources']
        resource_usage = {name: str(measured[key]) for name, key in
            [('FF', 'FF'), ('LUT', 'LUT'), ('BRAM', 'BRAM18_equivalent'), ('URAM', 'URAM'), ('DSP', 'DSP')]}
        resource_scope = 'Actual standalone CE closure Vivado OOC synthesis; BRAM is RAMB18-equivalent. Not full-top fit or P&R.'
record = {'c_function_name': 'laya_attention_service',
          'rtl_top_module_name': 'laya_attention_service',
          'c_files': [{'c_file': str(module / 'source' / name),
                       'cflag': '-I' + str(module / 'source') + ' -std=c++17 -fno-fast-math -ffp-contract=off'}
                      for name in ['attention_service.cpp', 'attention_exp_bits.cpp']],
          'rtl_files': [str(p) for p in files],
          'c_parameters': parameters,
          'rtl_common_signal': {'module_clock': 'ap_clk', 'module_reset': 'ap_rst',
              'module_clock_enable': 'ap_ce', 'ap_ctrl_chain_protocol_idle': 'ap_idle',
              'ap_ctrl_chain_protocol_start': 'ap_start', 'ap_ctrl_chain_protocol_ready': 'ap_ready',
              'ap_ctrl_chain_protocol_done': 'ap_done', 'ap_ctrl_chain_protocol_continue': 'ap_continue'},
          # Scheduler metadata only. Variable commands must retire from actual
          # ap_done and have no overlapping caller; unit integration must prove it.
          'rtl_performance': {'latency': '1', 'II': '1'},
          'rtl_resource_usage': resource_usage}
target = module / 'source/blackbox/laya_attention_service.json'
target.parent.mkdir(exist_ok=True)
target.write_text(json.dumps(record, indent=2) + '\n')
closure_files = [ce_manifest, Path(ce_closure['generator']['frozen_path'])] if ce_closure else []
model_files = [module / 'source' / name for name in
               ['attention_service.cpp', 'attention_service.h', 'attention_exp_bits.cpp', 'attention_exp_bits.h']]
metadata_files = [Path(__file__).resolve()]
inputs = [{'path': str(p), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
          for p in files + ip_tcl + data + closure_files + model_files + metadata_files + receipt_files]
(target.parent / 'dependencies.json').write_text(json.dumps({
    'schema': 'attention_native_blackbox_dependencies_v1',
    'hls_attempt': ce_closure['native_hls_attempt'] if ce_closure else str(hls),
    'rtl_closure': str(hls),
    'ce_patch_manifest': str(ce_manifest) if ce_closure else None,
    'status': 'CANDIDATE_NOT_UNIT_VERIFIED',
    'module_verification': verification,
    'scheduler_metadata_is_measurement': False,
    'ip_setup_tcl': [str(p) for p in ip_tcl],
    'memory_init': [str(p) for p in data],
    'integration_requirement': 'Create the actual vendor IP from every ip_setup_tcl in the enclosing Vivado project, and preserve the memory_init files in its runtime directory; unresolved IP wrappers are not an implemented blackbox.',
    'resource_scope': resource_scope,
    'inputs': inputs}, indent=2) + '\n')
print('ATTENTION_BLACKBOX_CANDIDATE_READY ' + str(target))
