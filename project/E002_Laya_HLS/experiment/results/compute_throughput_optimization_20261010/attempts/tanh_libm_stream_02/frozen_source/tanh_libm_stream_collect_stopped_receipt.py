#!/usr/bin/env python3
"""Record passed spatial RTL and the preserved bounded OOC cost stop."""
import hashlib
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

a=Path(sys.argv[1]).resolve()
def ident(path):
 p=Path(path);b=p.read_bytes()
 return dict(path=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def dump(name,value):
 (a/name).write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')
guards={}
for d in sorted(a.glob('guard_*')):
 f=d/'guard_result.json'
 if f.exists():guards[d.name]=json.loads(f.read_text())
passed=('guard_cpu_01','guard_hls_01','guard_helper_static_01',
        'guard_helper_static_02','guard_static_02','guard_pilot_01',
        'guard_helper_rtl_02','guard_rtl_01')
for name in passed:
 assert guards[name]['child_exit_code']==0 and guards[name]['trigger'] is None,(name,guards[name])
assert guards['guard_static_01']['child_exit_code']==1
assert guards['guard_helper_rtl_01']['child_exit_code']==1
g=guards['guard_ooc_01']
assert g['child_exit_code']==-9 and g['trigger']=='semantic_stall'
trigger=json.loads((a/'guard_ooc_01/guard_trigger.json').read_text())
assert trigger['last_progress_line']=='Start Cross Boundary and Area Optimization'
assert not list((a/'ooc').glob('*.rpt')) and not list((a/'ooc').glob('*.dcp'))
xml=ET.parse(a/'hls_project/solution1/syn/report/tanh_libm_stream_leaf_csynth.xml').getroot()
hls={}
for k,t in [('latency_min','Best-caseLatency'),('latency_max','Worst-caseLatency'),
            ('interval_min','Interval-min'),('interval_max','Interval-max')]:
 hls[k]=int(xml.find(f'.//SummaryOfOverallLatency/{t}').text)
for t in ('DSP','FF','LUT','BRAM_18K','URAM'):
 hls['estimated_'+t.lower()]=int(xml.find(f'.//AreaEstimates/Resources/{t}').text)
assert hls['latency_min']==hls['latency_max']==375 and hls['interval_min']==hls['interval_max']==1
top=a/'hls_project/solution1/syn/verilog/tanh_libm_stream_leaf.v'
nodes=[]
for match in re.finditer(r'^(tanh_libm_stream_leaf_stream_(add|mul|div)_node_(\d+)_s) (grp_\w+)\(',top.read_text(),re.M):
 nodes.append(dict(module=match[1],op=match[2],node=int(match[3]),instance=match[4]))
counts={op:sum(n['op']==op for n in nodes) for op in ('add','mul','div')}
assert counts==dict(add=23,mul=17,div=2)
rtl=(a/'rtl_run/xsim.log').read_text();helper=(a/'helper_rtl_run02/xsim.log').read_text()
assert 'TANH_STREAM_RTL_PASS count=3270 profiles=2 mixed_credit=640' in rtl
assert 'TANH_STREAM_HELPER_RTL_PASS count=1159 add=345 mul=409 div=405' in helper
assert 'actual_main_children=1 accepted_gap=1 after_nba_latency_cycles=5,13,11 capture_edges=6,14,12' in helper
keys=('mode','count','first_accept','first_valid','last_retire','span_cycles','min_accept_gap','max_accept_gap','core_fixed_latency','peak_credit','credit_stops')
pattern=r'TANH_STREAM_PROFILE_PASS mode=(\d+) count=(\d+) first_accept=(\d+) first_valid=(\d+) last_retire=(\d+) span=(\d+) min_gap=(\d+) max_gap=(\d+) core_fixed_latency=(\d+) peak_credit=(\d+) credit_stops=(\d+)'
profiles=[dict(zip(keys,map(int,m.groups()))) for m in re.finditer(pattern,rtl)]
assert len(profiles)==2 and profiles[0]['span_cycles']==3645 and profiles[1]['span_cycles']==6448
assert all(p['core_fixed_latency']==375 for p in profiles)
assert profiles[0]['min_accept_gap']==profiles[0]['max_accept_gap']==1
dividers=[]
for match in re.finditer(r'TANH_STREAM_DIVIDER_PASS mode=(\d+) div0_issue=(\d+) div0_return=(\d+) div1_issue=(\d+) div1_return=(\d+)',rtl):
 dividers.append(dict(zip(('mode','div0_issue','div0_return','div1_issue','div1_return'),map(int,match.groups()))))
assert len(dividers)==2 and all(all(d[k]==3270 for k in ('div0_issue','div0_return','div1_issue','div1_return')) for d in dividers)
old_mem=a.parent/'tanh_libm_round1_02/cpu/add_directed.mem'
old=old_mem.read_text().split();old_cases=[tuple(old[i:i+3]) for i in range(0,len(old),3)]
new=(a/'cpu/ops_directed.mem').read_text().split();ops=[tuple(new[i:i+4]) for i in range(0,len(new),4)]
assert len(old_cases)==52
assert [o[1:] for o in ops if int(o[0],16)==0][:52]==old_cases
manifest=json.loads((a/'source_manifest.json').read_text())
for f in manifest['files']:
 assert ident(f['path'])['sha256']==f['sha256'],f['path']
baseline=a.parent/'tanh_libm_round2_01/receipt.json';base=json.loads(baseline.read_text())
files=[*sorted(a.glob('source_manifest*.json')),*sorted((a/'frozen_source').glob('*')),
 *sorted((a/'fixture').glob('*')),a/'cpu/add_directed.mem',a/'cpu/ops_directed.mem',old_mem,
 *sorted((a/'hls_project/solution1/syn/verilog').glob('*.v')),
 *sorted((a/'hls_project/solution1/syn/report').glob('*csynth*')),
 a/'hls_project/solution1/.autopilot/db/tanh_libm_stream_leaf.verbose.sched.rpt',
 a/'rtl_run/xsim.log',a/'pilot/xsim.log',a/'helper_rtl_run/xsim.log',a/'helper_rtl_run02/xsim.log']
for d in sorted(a.glob('guard_*')):files+=sorted(d.glob('*'))
for directory in ('static','static_02','helper_static','helper_static_02'):
 files += [f for f in (a/directory).glob('*') if f.is_file() and f.suffix in ('.log','.sv')]
dump('evidence_manifest.json',dict(schema='laya-tanh-spatial-rtl-ooc-stop-evidence-v1',files=[ident(f) for f in files if f.is_file()]))
cpu=(a/'guard_cpu_01/driver.log').read_text()
receipt=dict(
 schema='laya-tanh-spatial-stream-experiment-v1',
 status='RTL_COMPLETE_OOC_COST_ABORTED',
 proof_scope='CHECKPOINT_REPLAY',
 numerical_pass=True,actual_module_ooc_complete=False,
 scope='one same-graph tanhf spatial stream with 512 total reserved return slots; standalone actual RTL; no complete accelerator or board claim',
 numeric_rules='original binary32 RNE graph/constants/order/branches, subnormals and signed zeros; no FMA, FTZ, reassociation or approximate inverse',
 source_graph_positions=dict(add=24,mul=17,div=2),
 actual_generated_operator_instances=counts,generated_nodes=nodes,
 constant_fold='add23 has two compile-time constant operands and folds to 0x3f800000; 23 actual add instances remain',
 hls=hls,
 rtl=dict(profiles=profiles,divider_tokens=dividers,
  divider_accounting='actual parent valid call stages 250,357 and operand edges; capture stages 262,369 and output edges; ap_ce alone is not a token handshake',
  full_fixture_comparisons=6540,mixed_credit_comparisons=640,
  reset_inflight=True,reset_pending=True,credit_fill_to512_and_drain=True,
  native_arithmetic=dict(add=345,mul=409,div=405,original_add52_unchanged=True,
   gold='independent native volatile float FE_TONEAREST',
   original52_mem=ident(old_mem),native_ops_mem=ident(a/'cpu/ops_directed.mem'),
   actual_main_children=['add0','mul14','div0'],full32_operands=True,
   accepted_gap_cycles=1,after_nba_latency_cycles=[5,13,11],capture_edges=[6,14,12])),
 return_storage=dict(total_reserved_slots=512,includes_inflight_and_returned=True,
  declared_data_tag_status_bytes=6144,actual_mapped_resources='unavailable; OOC did not complete'),
 ooc=dict(status='COST_ABORTED_SEMANTIC_STALL',top='tanh_libm_stream_wrapper',
  part='xcu55c-fsvh2892-2L-e',clock_period_ns=6.667,
  configuration='out_of_context flatten_hierarchy none RuntimeOptimized resource_sharing off',
  actual_resources=None,timing=None,dcp=None,blackboxes_after_synthesis=None,
  failure_stage=trigger['last_progress_line'],seconds_without_semantic_progress=trigger['seconds_since_progress'],
  guard_result=ident(a/'guard_ooc_01/guard_result.json'),guard_trigger=ident(a/'guard_ooc_01/guard_trigger.json'),
  same_caps_as_contract=True,no_full_net_or_place_route=True),
 preserved_failures=[
  'static01: testbench literal adjacent to ternary caused syntax error before elaboration; source arithmetic unchanged',
  'helperRTL01: testbench omitted actual a_int_reg/b_int_reg interface capture and sampled 1 cycle early; fixed in helper02 with native gold unchanged',
  'OOC01: bounded Cross Boundary/Area Optimization semantic stop; RTL numerical/throughput PASS remains valid'],
 same_configuration_scalar_baseline=ident(baseline),
 fixture_normal_span_improvement_fraction=1-profiles[0]['span_cycles']/base['profiles'][0]['span_cycles'],
 performance_scope='measured fixture profiles only; whole-model conditional projections must charge each independent row/task drain tail and external arithmetic/read/write/publication',
 guards=guards,cpu_pass_lines=[l for l in cpu.splitlines() if 'PASS' in l],
 rtl_pass_lines=[l for l in rtl.splitlines() if '_PASS' in l],
 helper_rtl_pass_lines=[l for l in helper.splitlines() if '_PASS' in l],
 source_manifest=ident(a/'source_manifest.json'),evidence_manifest=ident(a/'evidence_manifest.json'))
dump('receipt.json',receipt)
print(json.dumps(dict(receipt=ident(a/'receipt.json'),status=receipt['status'],profiles=profiles,ooc_guard=g)))

