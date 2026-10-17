#!/usr/bin/env python3
"""Collect actual stream02 evidence without changing numerical references."""
import hashlib
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

attempt=Path(sys.argv[1]).resolve()
def ident(path):
    path=Path(path);data=path.read_bytes()
    return dict(path=str(path.resolve()),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def dump(name,value):
    (attempt/name).write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')
def resources(fields):
    vals=list(map(int,fields[2:]))
    return dict(lut=vals[0],logic_lut=vals[1],lutram=vals[2],srl=vals[3],
                ff=vals[4],bram36=vals[5],bram18=vals[6],uram=vals[7],dsp=vals[8])
guards={}
for directory in sorted(attempt.glob('guard_*')):
    f=directory/'guard_result.json'
    if f.exists():
        g=json.loads(f.read_text())
        guards[directory.name]=g
for name in ('guard_cpu_01','guard_hls_01','guard_helper_static_02',
             'guard_static_02','guard_pilot_01','guard_helper_rtl_02',
             'guard_rtl_01','guard_ooc_01'):
    assert name in guards,name
    assert guards[name]['child_exit_code']==0 and guards[name]['trigger'] is None,(name,guards[name])
assert guards['guard_static_01']['child_exit_code']==1 and guards['guard_static_01']['trigger'] is None
assert guards['guard_helper_rtl_01']['child_exit_code']==1 and guards['guard_helper_rtl_01']['trigger'] is None
xml=ET.parse(attempt/'hls_project/solution1/syn/report/tanh_libm_stream_leaf_csynth.xml').getroot()
hls={}
for key,tag in [('latency_min','Best-caseLatency'),('latency_max','Worst-caseLatency'),
                ('interval_min','Interval-min'),('interval_max','Interval-max')]:
    hls[key]=int(xml.find(f'.//SummaryOfOverallLatency/{tag}').text)
for tag in ('DSP','FF','LUT','BRAM_18K','URAM'):
    hls['estimated_'+tag.lower()]=int(xml.find(f'.//AreaEstimates/Resources/{tag}').text)
assert hls['latency_min']==hls['latency_max']==375
assert hls['interval_min']==hls['interval_max']==1
rtl_top=attempt/'hls_project/solution1/syn/verilog/tanh_libm_stream_leaf.v'
generated_nodes=[]
for match in re.finditer(r'^(tanh_libm_stream_leaf_stream_(add|mul|div)_node_(\d+)_s) (grp_\w+)\(',rtl_top.read_text(),re.M):
    generated_nodes.append(dict(module=match[1],op=match[2],node=int(match[3]),instance=match[4]))
counts={op:sum(n['op']==op for n in generated_nodes) for op in ('add','mul','div')}
assert counts==dict(add=23,mul=17,div=2),counts
hier=(attempt/'ooc/utilization_hierarchical.rpt').read_text()
nodes=[];top=None;wrapper_own=None
for line in hier.splitlines():
    f=[x.strip() for x in line.split('|')[1:-1]]
    if len(f)!=11:continue
    if f[0]=='tanh_libm_stream_wrapper':top=resources(f)
    elif f[0]=='(tanh_libm_stream_wrapper)':wrapper_own=resources(f)
    elif re.fullmatch(r'grp_stream_(?:add|mul|div)_node_\d+_s_fu_\d+',f[0]):
        nodes.append(dict(instance=f[0],module=f[1],**resources(f)))
assert top is not None and wrapper_own is not None
assert {n['instance'] for n in nodes}=={n['instance'] for n in generated_nodes}
timing=(attempt/'ooc/timing_summary.rpt').read_text()
wns=re.search(r'WNS\(ns\).*?\n\s*-.*?\n\s*([\d.-]+)\s+([\d.-]+)',timing,re.S)
assert wns
ooclog=(attempt/'guard_ooc_01/driver.log').read_text()
assert 'TANH_LIBM_STREAM_VIVADO_OOC_PASS blackboxes=0' in ooclog
warnings=[l for l in ooclog.splitlines() if l.startswith('WARNING:')]
errors=[l for l in ooclog.splitlines() if l.startswith(('ERROR:','CRITICAL WARNING:'))]
assert not errors,errors
rtl=(attempt/'rtl_run/xsim.log').read_text()
helper=(attempt/'helper_rtl_run02/xsim.log').read_text()
cpu=(attempt/'guard_cpu_01/driver.log').read_text()
pilot=(attempt/'pilot/xsim.log').read_text()
assert 'TANH_STREAM_RTL_PASS count=3270 profiles=2 mixed_credit=640' in rtl
assert 'TANH_STREAM_HELPER_RTL_PASS count=1159 add=345 mul=409 div=405' in helper
assert 'actual_main_children=1 accepted_gap=1' in helper
assert 'TANH_STREAM_PILOT_PASS count=128' in pilot
profiles=[]
pattern=r'TANH_STREAM_PROFILE_PASS mode=(\d+) count=(\d+) first_accept=(\d+) first_valid=(\d+) last_retire=(\d+) span=(\d+) min_gap=(\d+) max_gap=(\d+) core_fixed_latency=(\d+) peak_credit=(\d+) credit_stops=(\d+)'
keys=('mode','count','first_accept','first_valid','last_retire','span_cycles',
      'min_accept_gap','max_accept_gap','core_fixed_latency','peak_credit','credit_stops')
for match in re.finditer(pattern,rtl):profiles.append(dict(zip(keys,map(int,match.groups()))))
assert len(profiles)==2 and all(p['count']==3270 and p['core_fixed_latency']==375 for p in profiles)
assert profiles[0]['min_accept_gap']==profiles[0]['max_accept_gap']==1
divider=[]
for match in re.finditer(r'TANH_STREAM_DIVIDER_PASS mode=(\d+) div0_issue=(\d+) div0_return=(\d+) div1_issue=(\d+) div1_return=(\d+)',rtl):
    divider.append(dict(zip(('mode','div0_issue','div0_return','div1_issue','div1_return'),map(int,match.groups()))))
assert len(divider)==2 and all(all(d[k]==3270 for k in ('div0_issue','div0_return','div1_issue','div1_return')) for d in divider)
old_words=(attempt.parent/'tanh_libm_round1_02/cpu/add_directed.mem').read_text().split()
old_cases=[tuple(old_words[i:i+3]) for i in range(0,len(old_words),3)]
words=(attempt/'cpu/ops_directed.mem').read_text().split()
ops=[tuple(words[i:i+4]) for i in range(0,len(words),4)]
new_add=[o[1:] for o in ops if int(o[0],16)==0]
assert len(old_cases)==52 and new_add[:52]==old_cases
baseline=attempt.parent/'tanh_libm_round2_01/receipt.json'
baseline_receipt=json.loads(baseline.read_text())
receipt={
 'schema':'laya-tanh-spatial-stream-actual-module-v1',
 'status':'CPU_RTL_ACTUAL_OOC_COMPLETE_PENDING_POST_SYNTHESIS_ASSESSMENT',
 'scope':'one same-graph tanhf spatial stream with 512 total reserved return slots; checkpoint replay; no complete accelerator or board claim',
 'numeric_rules':'original binary32 RNE graph, constants/order/branches, subnormals and signed zeros; no FMA, FTZ, reassociation or approximate inverse',
 'source_graph_positions':dict(add=24,mul=17,div=2),
 'actual_generated_operator_instances':counts,
 'constant_fold':'add position23 has two compile-time constants and folds to binary32 0x3f800000; it is not an extra arithmetic instance',
 'hls':hls,
 'rtl':dict(profiles=profiles,divider_tokens=divider,
            divider_accounting='actual generated parent token stage250/357 and operand edge, stage262/369 and output capture edge; child ap_ce alone is not treated as valid',
            independent_fixture_comparisons=6540,mixed_credit_comparisons=640,
            reset_inflight=True,reset_pending=True,credit_fill_to_512=True,
            native_arithmetic=dict(add=345,mul=409,div=405,original_add52_unchanged=True,
                                  original52_mem=ident(attempt.parent/'tanh_libm_round1_02/cpu/add_directed.mem'),
                                  native_ops_mem=ident(attempt/'cpu/ops_directed.mem'),
                                  gold='independent native volatile float FE_TONEAREST',
                                  actual_main_generated_children=['add0','mul14','div0'],
                                  full32_operands=True,accepted_gap_cycles=1,
                                  child_after_nba_latency_cycles=[5,13,11],
                                  child_capture_edges=[6,14,12])),
 'return_storage':dict(total_credit_slots=512,includes_inflight_and_returned=True,
                       declared_data_tag_status_bytes=6144,
                       status_values=[0,1],wrapper_actual_resources=wrapper_own),
 'ooc':dict(top='tanh_libm_stream_wrapper',part='xcu55c-fsvh2892-2L-e',
            clock_period_ns=6.667,
            configuration='out_of_context flatten_hierarchy none RuntimeOptimized resource_sharing off',
            **top,operator_instances=nodes,blackboxes=0,
            setup_wns_ns=float(wns[1]),setup_tns_ns=float(wns[2]),
            warning_count=len(warnings),warning_lines=warnings,error_count=0,
            stage='synthesized only; no place/route, interface timing or achieved Fmax claim',
            dcp=ident(attempt/'ooc/tanh_libm_stream_wrapper_synth.dcp')),
 'same_configuration_scalar_baseline':ident(baseline),
 'normal_span_improvement_fraction':1-profiles[0]['span_cycles']/baseline_receipt['profiles'][0]['span_cycles'],
 'guards':guards,'cpu_pass_lines':[l for l in cpu.splitlines() if 'PASS' in l],
 'preserved_failed_build':'guard_static_01: testbench numeric literal/ternary whitespace caused syntax error before elaboration; static02 retains HLS arithmetic source and fixes only test/script paths',
 'preserved_failed_helper':'guard_helper_rtl_01: TB sampled1cycle early, omitting actual child input port capture register; fresh static02/RTL02 align actual interface; native gold and HLS arithmetic are unchanged',
 'rtl_pass_lines':[l for l in rtl.splitlines() if '_PASS' in l],
 'helper_rtl_pass_lines':[l for l in helper.splitlines() if '_PASS' in l],
 'source_manifest':ident(attempt/'source_manifest.json')
}
files=[*sorted(attempt.glob('source_manifest*.json')),
       *sorted((attempt/'frozen_source').glob('*')),*sorted((attempt/'fixture').glob('*')),
       attempt/'cpu/ops_directed.mem',attempt/'cpu/add_directed.mem',
       attempt.parent/'tanh_libm_round1_02/cpu/add_directed.mem',
       *sorted((attempt/'hls_project/solution1/syn/verilog').glob('*.v')),
       *sorted((attempt/'hls_project/solution1/syn/report').glob('*csynth*')),
       attempt/'hls_project/solution1/.autopilot/db/tanh_libm_stream_leaf.verbose.sched.rpt',
       *sorted((attempt/'ooc').glob('*.rpt')),
       attempt/'ooc/tanh_libm_stream_wrapper_synth.dcp',
       attempt/'rtl_run/xsim.log',attempt/'helper_rtl_run/xsim.log',
       attempt/'helper_rtl_run02/xsim.log',attempt/'pilot/xsim.log']
for g in sorted(attempt.glob('guard_*')):files+=sorted(g.glob('*'))
for static in ('static','static_02','helper_static','helper_static_02'):
    files+=[f for f in (attempt/static).glob('*') if f.is_file() and f.suffix in ('.log','.sv')]
dump('evidence_manifest.json',dict(schema='laya-tanh-stream-actual-evidence-v1',files=[ident(f) for f in files if f.is_file()]))
receipt['evidence_manifest']=ident(attempt/'evidence_manifest.json')
dump('receipt.json',receipt)
print(json.dumps(dict(receipt=ident(attempt/'receipt.json'),ooc=top,profiles=profiles)))

