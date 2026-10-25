#!/usr/bin/env python3
"""Generate the scoped v2 CE variant without modifying any frozen v1 source."""
from pathlib import Path
import hashlib
import json
import re

MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[5]
RUN = ROOT / 'project/E015_m007_tanh_geglu8/experiment_results/runs/R002'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    authority = json.loads((ROOT / 'source/m007_residual_encoder30_20261023.json').read_text())['tanh_idle_ce']
    for name, expected in authority['source_versions'].items():
        assert sha(ROOT / name) == expected, ('frozen v1 source changed', name)
    path = MODULE / 'rtl/laya_m007_tanh_lane_v1.sv'
    old = path.read_text().split('\nendmodule', 1)[0] + '\nendmodule\n'
    header = 'module laya_m007_tanh_core_v1(input wire clk,reset,in_valid,input wire [31:0] in_data,'
    new_header = 'module laya_m007_tanh_core_v2(input wire clk,reset,in_valid,core_ce,input wire [31:0] in_data,'
    assert old.count(header) == 1
    core = old.replace(header, new_header)
    core = core.replace(' output wire commit_valid,output wire [31:0] result,status);',
                        ' output wire commit_valid,token_empty,output wire [31:0] result,status);')
    valid = 'always @(posedge clk)if(reset)valid_pipe<=0;else valid_pipe<={valid_pipe[150:0],in_valid};'
    assert core.count(valid) == 1
    core = core.replace(valid, valid.replace('else valid_pipe', 'else if(core_ce)valid_pipe'))
    data_pattern = r'(?m)^( always @\(posedge clk\) )([^\n]+)$'
    seq = []

    def gate(match):
        rhs = match[2]
        assert re.fullmatch(r'[A-Za-z_]\w*\s*<=.+;', rhs), rhs
        seq.append({'source_line': old[:match.start()].count('\n') + 1,
                    'register': rhs.split('<=', 1)[0].strip(), 'original': rhs})
        return match[1] + 'if(core_ce) ' + rhs

    core, count = re.subn(data_pattern, gate, core)
    assert count == 2446, count
    assert core.count('.aclken(1\'b1)') == 42
    leaves = [{'source_line': i + 1, 'instance': line.strip().split('(')[0], 'aclken': 'core_ce'}
              for i, line in enumerate(old.splitlines()) if '.aclken(' in line]
    core = core.replace('.aclken(1\'b1)', '.aclken(core_ce)')
    empty = ' assign token_empty=~(|valid_pipe[151:0]);\n'
    core = core.replace(' assign commit_valid=', empty + ' assign commit_valid=', 1)
    # Inverting the only permitted edits must recover the exact frozen core.
    inverse = core.replace(new_header, header).replace('commit_valid,token_empty,', 'commit_valid,')
    inverse = inverse.replace('else if(core_ce)valid_pipe', 'else valid_pipe')
    inverse = inverse.replace('always @(posedge clk) if(core_ce) ', 'always @(posedge clk) ')
    inverse = inverse.replace('.aclken(core_ce)', '.aclken(1\'b1)').replace(empty, '')
    assert inverse == old, 'CE edit changed the original mathematical graph'
    assert core.count('always @(posedge clk)') == 2447
    assert core.count('if(core_ce)') == 2447
    target = MODULE / 'rtl/laya_m007_tanh_core_v2.sv'
    target.write_text(core)

    wrapper_path = MODULE / 'rtl/laya_m007_tanh8_v1.sv'
    wrapper_old = wrapper_path.read_text()
    wrapper = wrapper_old.replace('module laya_m007_tanh8_v1(',
                                  'module laya_m007_tanh8_v2 #(parameter bit FORCE_CORE_CE=0)(')
    marker = ' wire req_fire=req_valid&&req_ready;'
    ce = ''' wire req_fire=req_valid&&req_ready;
 wire lease_fire=lease_valid&&lease_ready;
 wire [7:0] core_token_empty;
 wire all_token_empty=&core_token_empty;
 wire core_ce=FORCE_CORE_CE||!rst_n||lease_active||lease_fire||req_fire||
  (pending_vectors!=0)||(in_flight_vectors!=0)||!all_token_empty||protocol_fault;'''
    assert wrapper.count(marker) == 1
    wrapper = wrapper.replace(marker, ce)
    wrapper = wrapper.replace('laya_m007_tanh_core_v1 core(.clk,.reset(!rst_n),.in_valid(req_fire),',
                              'laya_m007_tanh_core_v2 core(.clk,.reset(!rst_n),.core_ce,.token_empty(core_token_empty[lane]),.in_valid(req_fire),')
    assert wrapper.count('always_ff') == wrapper_old.count('always_ff') == 1
    # Lease/credit/queue/fault logic is byte-identical after reversing wiring.
    inverse = wrapper.replace('module laya_m007_tanh8_v2 #(parameter bit FORCE_CORE_CE=0)(',
                              'module laya_m007_tanh8_v1(').replace(ce, marker)
    inverse = inverse.replace('laya_m007_tanh_core_v2 core(.clk,.reset(!rst_n),.core_ce,.token_empty(core_token_empty[lane]),.in_valid(req_fire),',
                              'laya_m007_tanh_core_v1 core(.clk,.reset(!rst_n),.in_valid(req_fire),')
    assert inverse == wrapper_old, 'handshake or credit logic changed'
    wrapper_target = MODULE / 'rtl/laya_m007_tanh8_v2.sv'
    wrapper_target.write_text(wrapper)
    RUN.mkdir(parents=True, exist_ok=True)
    inventory = {'schema': 'm007-tanh-idle-ce26-prepared-coverage-v1',
                 'status': 'GENERATED_NOT_COMPILED_OR_TESTED',
                 'source_versions': authority['source_versions'],
                 'generated_core_sha256': sha(target), 'generated_wrapper_sha256': sha(wrapper_target),
                 'new_FF_bits': 0, 'clock_gates': 0, 'original_graph_reversible_edit': True,
                 'unchanged_wrapper_handshake_credit_fault_logic': True,
                 'core_sequential_blocks': 2447, 'valid_pipe_bits': 152,
                 'valid_pipe_reset_priority': 'if(reset) zero; else if(core_ce) shift',
                 'no_reset_data_blocks': seq, 'leaf_instances': leaves,
                 'leaf_instance_count': 42, 'leaf_internal_reset_and_CE_audit': 'PENDING_STATIC_CHECK',
                 'runtime_equivalence': 'NOT_RUN', 'joint_speedup': 'NOT_RUN'}
    (RUN / 'ce26_prepared_coverage_v1.json').write_text(json.dumps(inventory, indent=2) + '\n')
    print(json.dumps({k: inventory[k] for k in ('status', 'generated_core_sha256', 'generated_wrapper_sha256', 'core_sequential_blocks', 'leaf_instance_count', 'new_FF_bits')}))


if __name__ == '__main__':
    main()
