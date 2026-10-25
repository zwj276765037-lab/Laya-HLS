#!/usr/bin/env python3
"""Generate owned bindings to A007 frozen public bundle; no RTL/EDA launch."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
MOD = ROOT / 'project/E002_Laya_HLS/experiment/vivado/module_design'
OUT = MOD / 'forward_controller/rtl'
REPORT = ROOT / 'project/E016_m007_single_resource_parent/experiment_results/runs/R006/reports/wrapper_port_mapping.json'
PARENT = OUT / 'laya_m007_single_parent_v1.sv'
HEADER = MOD / 'attention_and_fp_engine/rtl/laya_m007_resident_joint_v2_header.svh'
PORTS = ROOT / 'project/E019_m007_residual_ln_residency/experiment_source/resident_joint_v2_public_ports_v1.json'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def instance_ports(text, module, instance):
    match = re.search(r'\b' + re.escape(module) + r'\s+' + instance + r'\s*\(([\s\S]*?)\);', text)
    assert match, (module, instance)
    found = re.findall(r'\.(\w+)\(([^()]*)\)', match[1])
    assert len(found) == len(dict(found))
    return dict(found)


def main():
    assert sha(PARENT) == '62cf04f53be966ac3b214dc955fda236efba2dc0cc20b90c539352c96312b86f'
    assert sha(HEADER) == '7c918134a3b67303cba291d429b12493411d2e5c3f1568d30af7a0c0e0c69cf2'
    text = PARENT.read_text()
    old_joint = instance_ports(text, 'laya_m007_control_workspace_joint_v1', 'layer')
    old_resource = instance_ports(text, 'laya_attention_resources_v1', 'resources')
    ports = json.loads(PORTS.read_text())['ports']
    names = [row[2] for row in ports]
    assert len(names) == len(set(names)) == 465
    aliases = {'clk': 'clk', 'rst_n': 'rst_n',
               'owner_req_valid': 'ws_owner_req_valid', 'owner_req_ready': 'ws_owner_req_ready',
               'owner_req': 'v2_owner_req', 'owner': 'v2_owner',
               'a_enable': 'ws_a_enable', 'g_enable': 'ws_g_enable', 'rearm': 'ws_rearm',
               'g_tanh_lease_ready': 'tanh_lease_ready',
               'g_tanh_release_ready': 'tanh_release_ready',
               'g_tanh_lease_active': 'tanh_lease_active', 'g_tanh_draining': 'tanh_draining',
               'g_tanh_pending_vectors': 'tanh_pending', 'g_tanh_in_flight_vectors': 'tanh_flight'}
    bindings = []
    declarations = []
    for direction, width, name in ports:
        if name in aliases:
            signal, origin = aliases[name], 'explicit public alias'
            if name in ['owner_req', 'owner']:
                declarations.append(f'logic {width} {signal};')
        elif name.startswith('a_') or name.startswith('g_') and not name.startswith('g_tanh_'):
            assert name in old_joint, name
            signal, origin = old_joint[name], 'same existing A/G public binding'
        elif name.startswith('ext_res_'):
            old = name[4:]
            assert old in old_resource, name
            signal, origin = old_resource[old], 'same original physical service type'
        elif name.startswith('coeff_'):
            signal, origin = name, 'existing top coefficient public interface'
        else:
            signal, origin = 'v2_' + name, 'new independent v2 wire; parent FSM owns its drive/observation'
            declarations.append(f'logic {width + " " if width else ""}{signal};')
        bindings.append({'direction': direction, 'width': width, 'port': name,
                         'signal': signal, 'origin': origin})
    (OUT / 'laya_m007_encoder0_wrapper_declarations_v2.svh').write_text(
        '// Generated from frozen A007 public header; wire declarations only.\n' + '\n'.join(declarations) + '\n')
    (OUT / 'laya_m007_encoder0_wrapper_instance_v2.svh').write_text(
        '// Generated public bindings; body owned by A007, not copied here.\n'
        'laya_m007_resident_joint_v2 resident(\n' +
        ',\n'.join(f"  .{r['port']}({r['signal']})" for r in bindings) + '\n);\n')
    report = {'schema': 'm007-encoder0-frozen-wrapper-bindings-v1',
              'parent_v1_sha256': sha(PARENT), 'public_header_sha256': sha(HEADER),
              'public_ports_manifest_sha256': sha(PORTS), 'port_count': len(bindings),
              'bindings': bindings, 'status': 'PREPARED_NOT_COMPILED_NOT_CONNECTED_TO_PARENT_FSM',
              'new_registers_in_generated_fragments': 0,
              'eda_launched': False, 'v1_changed': False}
    REPORT.write_text(json.dumps(report, indent=2) + '\n')
    print('M007_ENCODER0_FROZEN_WRAPPER_BINDINGS_PREPARED ports=' + str(len(bindings)))


if __name__ == '__main__':
    main()
